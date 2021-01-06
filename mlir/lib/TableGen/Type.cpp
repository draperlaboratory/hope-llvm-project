//===- Type.cpp - Type class ----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Type wrapper to simplify using TableGen Record defining a MLIR Type.
//
//===----------------------------------------------------------------------===//

#include "mlir/TableGen/Type.h"
#include "llvm/ADT/TypeSwitch.h"
#include "llvm/TableGen/Record.h"

using namespace mlir;
using namespace mlir::tblgen;

TypeConstraint::TypeConstraint(const llvm::Record *record)
    : Constraint(Constraint::CK_Type, record) {
  assert(def->isSubClassOf("TypeConstraint") &&
         "must be subclass of TableGen 'TypeConstraint' class");
}

TypeConstraint::TypeConstraint(const llvm::DefInit *init)
    : TypeConstraint(init->getDef()) {}

bool TypeConstraint::isOptional() const {
  return def->isSubClassOf("Optional");
}

bool TypeConstraint::isVariadic() const {
  return def->isSubClassOf("Variadic");
}

// Returns the builder call for this constraint if this is a buildable type,
// returns None otherwise.
Optional<StringRef> TypeConstraint::getBuilderCall() const {
  const llvm::Record *baseType = def;
  if (isVariableLength())
    baseType = baseType->getValueAsDef("baseType");

  // Check to see if this type constraint has a builder call.
  const llvm::RecordVal *builderCall = baseType->getValue("builderCall");
  if (!builderCall || !builderCall->getValue())
    return llvm::None;
  return TypeSwitch<llvm::Init *, Optional<StringRef>>(builderCall->getValue())
      .Case<llvm::StringInit>([&](auto *init) {
        StringRef value = init->getValue();
        return value.empty() ? Optional<StringRef>() : value;
      })
      .Default([](auto *) { return llvm::None; });
}

// Return the C++ class name for this type (which may just be ::mlir::Type).
StringRef TypeConstraint::getCPPClassName() const {
  return def->getValueAsString("cppClassName");
}

Type::Type(const llvm::Record *record) : TypeConstraint(record) {}

StringRef Type::getDescription() const {
  return def->getValueAsString("description");
}

Dialect Type::getDialect() const {
  return Dialect(def->getValueAsDef("dialect"));
}
