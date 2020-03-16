//===- DialectGen.cpp - MLIR dialect definitions generator ----------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// DialectGen uses the description of dialects to generate C++ definitions.
//
//===----------------------------------------------------------------------===//

#include "mlir/Support/STLExtras.h"
#include "mlir/Support/StringExtras.h"
#include "mlir/TableGen/Format.h"
#include "mlir/TableGen/GenInfo.h"
#include "mlir/TableGen/OpClass.h"
#include "mlir/TableGen/OpInterfaces.h"
#include "mlir/TableGen/OpTrait.h"
#include "mlir/TableGen/Operator.h"
#include "llvm/ADT/Sequence.h"
#include "llvm/ADT/StringExtras.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/Signals.h"
#include "llvm/TableGen/Error.h"
#include "llvm/TableGen/Record.h"
#include "llvm/TableGen/TableGenBackend.h"

#define DEBUG_TYPE "mlir-tblgen-opdefgen"

using namespace mlir;
using namespace mlir::tblgen;

static llvm::cl::OptionCategory dialectGenCat("Options for -gen-dialect-*");
static llvm::cl::opt<std::string>
    selectedDialect("dialect", llvm::cl::desc("The dialect to gen for"),
                    llvm::cl::cat(dialectGenCat), llvm::cl::CommaSeparated);

/// Utility iterator used for filtering records for a specific dialect.
namespace {
using DialectFilterIterator =
    llvm::filter_iterator<ArrayRef<llvm::Record *>::iterator,
                          std::function<bool(const llvm::Record *)>>;
} // end anonymous namespace

/// Given a set of records for a T, filter the ones that correspond to
/// the given dialect.
template <typename T>
static iterator_range<DialectFilterIterator>
filterForDialect(ArrayRef<llvm::Record *> records, Dialect &dialect) {
  auto filterFn = [&](const llvm::Record *record) {
    return T(record).getDialect() == dialect;
  };
  return {DialectFilterIterator(records.begin(), records.end(), filterFn),
          DialectFilterIterator(records.end(), records.end(), filterFn)};
}

//===----------------------------------------------------------------------===//
// GEN: Dialect declarations
//===----------------------------------------------------------------------===//

/// The code block for the start of a dialect class declaration.
///
/// {0}: The name of the dialect class.
/// {1}: The dialect namespace.
static const char *const dialectDeclBeginStr = R"(
class {0} : public ::mlir::Dialect {
public:
  explicit {0}(::mlir::MLIRContext *context);
  static ::llvm::StringRef getDialectNamespace() { return "{1}"; }
)";

/// The code block for the attribute parser/printer hooks.
static const char *const attrParserDecl = R"(
  /// Parse an attribute registered to this dialect.
  ::mlir::Attribute parseAttribute(::mlir::DialectAsmParser &parser,
                                   ::mlir::Type type) const override;

  /// Print an attribute registered to this dialect.
  void printAttribute(::mlir::Attribute attr,
                      ::mlir::DialectAsmPrinter &os) const override;
)";

/// The code block for the type parser/printer hooks.
static const char *const typeParserDecl = R"(
  /// Parse a type registered to this dialect.
  ::mlir::Type parseType(::mlir::DialectAsmParser &parser) const override;

  /// Print a type registered to this dialect.
  void printType(::mlir::Type type,
                 ::mlir::DialectAsmPrinter &os) const override;
)";

/// The code block for the constant materializer hook.
static const char *const constantMaterializerDecl = R"(
  /// Materialize a single constant operation from a given attribute value with
  /// the desired resultant type.
  ::mlir::Operation *materializeConstant(::mlir::OpBuilder &builder,
                                         ::mlir::Attribute value,
                                         ::mlir::Type type,
                                         ::mlir::Location loc) override;
)";

/// Generate the declaration for the given dialect class.
static void emitDialectDecl(Dialect &dialect,
                            iterator_range<DialectFilterIterator> dialectAttrs,
                            iterator_range<DialectFilterIterator> dialectTypes,
                            raw_ostream &os) {
  // Emit the start of the decl.
  std::string cppName = dialect.getCppClassName();
  os << llvm::formatv(dialectDeclBeginStr, cppName, dialect.getName());

  // Check for any attributes/types registered to this dialect.  If there are,
  // add the hooks for parsing/printing.
  if (!dialectAttrs.empty())
    os << attrParserDecl;
  if (!dialectTypes.empty())
    os << typeParserDecl;

  // Add the decls for the various features of the dialect.
  if (dialect.hasConstantMaterializer())
    os << constantMaterializerDecl;
  if (llvm::Optional<StringRef> extraDecl = dialect.getExtraClassDeclaration())
    os << *extraDecl;

  // End the dialect decl.
  os << "};\n";
}

static bool emitDialectDecls(const llvm::RecordKeeper &recordKeeper,
                             raw_ostream &os) {
  emitSourceFileHeader("Dialect Declarations", os);

  auto defs = recordKeeper.getAllDerivedDefinitions("Dialect");
  if (defs.empty())
    return false;

  // Select the dialect to gen for.
  const llvm::Record *dialectDef = nullptr;
  if (defs.size() == 1 && selectedDialect.getNumOccurrences() == 0) {
    dialectDef = defs.front();
  } else if (selectedDialect.getNumOccurrences() == 0) {
    llvm::errs() << "when more than 1 dialect is present, one must be selected "
                    "via '-dialect'";
    return true;
  } else {
    auto dialectIt = llvm::find_if(defs, [](const llvm::Record *def) {
      return Dialect(def).getName() == selectedDialect;
    });
    if (dialectIt == defs.end()) {
      llvm::errs() << "selected dialect with '-dialect' does not exist";
      return true;
    }
    dialectDef = *dialectIt;
  }

  auto attrDefs = recordKeeper.getAllDerivedDefinitions("DialectAttr");
  auto typeDefs = recordKeeper.getAllDerivedDefinitions("DialectType");
  Dialect dialect(dialectDef);
  emitDialectDecl(dialect, filterForDialect<Attribute>(attrDefs, dialect),
                  filterForDialect<Type>(typeDefs, dialect), os);
  return false;
}

//===----------------------------------------------------------------------===//
// GEN: Dialect registration hooks
//===----------------------------------------------------------------------===//

static mlir::GenRegistration
    genDialectDecls("gen-dialect-decls", "Generate dialect declarations",
                    [](const llvm::RecordKeeper &records, raw_ostream &os) {
                      return emitDialectDecls(records, os);
                    });
