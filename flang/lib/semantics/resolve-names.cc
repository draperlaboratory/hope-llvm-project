#include "../parser/indirection.h"
#include "../parser/parse-tree-visitor.h"
#include "../parser/parse-tree.h"
#include "attr.h"
#include "scope.h"
#include "symbol.h"
#include "type.h"
#include <iostream>
#include <list>
#include <memory>
#include <stack>

namespace Fortran::semantics {

// Provide Post methods to collect attributes into a member variable.
class AttrsVisitor {
public:
  void beginAttrs() {
    CHECK(!attrs_);
    attrs_ = std::make_unique<Attrs>();
  }
  Attrs endAttrs() {
    const auto result = attrs_ ? *attrs_ : Attrs::EMPTY;
    attrs_.reset();
    return result;
  }

  void Post(const parser::LanguageBindingSpec &x) {
    attrs_->Set(Attr::BIND_C);
    if (x.v) {
      // TODO: set langBindingName_ from ScalarDefaultCharConstantExpr
    }
  }
  void Post(const parser::PrefixSpec::Elemental &) {
    attrs_->Set(Attr::ELEMENTAL);
  }
  void Post(const parser::PrefixSpec::Impure &) { attrs_->Set(Attr::IMPURE); }
  void Post(const parser::PrefixSpec::Module &) { attrs_->Set(Attr::MODULE); }
  void Post(const parser::PrefixSpec::Non_Recursive &) {
    attrs_->Set(Attr::NON_RECURSIVE);
  }
  void Post(const parser::PrefixSpec::Pure &) { attrs_->Set(Attr::PURE); }
  void Post(const parser::PrefixSpec::Recursive &) {
    attrs_->Set(Attr::RECURSIVE);
  }

protected:
  std::unique_ptr<Attrs> attrs_;
  std::string langBindingName_{""};
};

// Find and create types from declaration-type-spec nodes.
class DeclTypeSpecVisitor : public AttrsVisitor {
public:
  using AttrsVisitor::Post;

  void beginDeclTypeSpec() {
    CHECK(!expectDeclTypeSpec_);
    expectDeclTypeSpec_ = true;
  }
  std::optional<DeclTypeSpec> getDeclTypeSpec() {
    return declTypeSpec_ ? *declTypeSpec_.get() : std::optional<DeclTypeSpec>();
  }
  void endDeclTypeSpec() {
    CHECK(expectDeclTypeSpec_);
    expectDeclTypeSpec_ = false;
    declTypeSpec_.reset();
  }

  bool Pre(const parser::IntegerTypeSpec &x) {
    MakeIntrinsic(IntegerTypeSpec::Make(GetKindParamValue(x.v)));
    return false;
  }
  bool Pre(const parser::IntrinsicTypeSpec::Logical &x) {
    MakeIntrinsic(LogicalTypeSpec::Make(GetKindParamValue(x.kind)));
    return false;
  }
  bool Pre(const parser::IntrinsicTypeSpec::Real &x) {
    MakeIntrinsic(RealTypeSpec::Make(GetKindParamValue(x.kind)));
    return false;
  }
  bool Pre(const parser::IntrinsicTypeSpec::Complex &x) {
    MakeIntrinsic(ComplexTypeSpec::Make(GetKindParamValue(x.kind)));
    return false;
  }

protected:
  std::unique_ptr<DeclTypeSpec> declTypeSpec_;

private:
  bool expectDeclTypeSpec_{false};  // should only see decl-type-spec when true

  void MakeIntrinsic(const IntrinsicTypeSpec *intrinsicTypeSpec) {
    CHECK(expectDeclTypeSpec_ && !declTypeSpec_);
    declTypeSpec_ = std::make_unique<DeclTypeSpec>(
        DeclTypeSpec::MakeIntrinsic(intrinsicTypeSpec));
  }

  static KindParamValue GetKindParamValue(
      const std::optional<parser::KindSelector> &kind) {
    if (!kind) {
      return KindParamValue();
    } else if (std::holds_alternative<parser::ScalarIntConstantExpr>(kind->u)) {
      const auto &expr = std::get<parser::ScalarIntConstantExpr>(kind->u);
      const auto &lit =
          std::get<parser::LiteralConstant>(expr.thing.thing.thing->u);
      const auto &intlit = std::get<parser::IntLiteralConstant>(lit.u);
      return KindParamValue(std::get<std::uint64_t>(intlit.t));
    } else {
      CHECK(false && "TODO: translate star-size to kind");
    }
  }
};

// Walk the parse tree and resolve names to symbols.
class ResolveNamesVisitor : public DeclTypeSpecVisitor {
public:
  using DeclTypeSpecVisitor::Post;
  using DeclTypeSpecVisitor::Pre;

  ResolveNamesVisitor() { PushScope(Scope::globalScope); }

  Scope &CurrScope() { return *scopes_.top(); }
  void PushScope(Scope &scope) { scopes_.push(&scope); }
  void PopScope() { scopes_.pop(); }

  // Helpers to make a Symbol in the current scope
  template<typename D>
  Symbol &MakeSymbol(const Name &name, D &&details) {
    return CurrScope().MakeSymbol(name, details);
  }
  template<typename D>
  Symbol &MakeSymbol(const Name &name, const Attrs &attrs, D &&details) {
    return CurrScope().MakeSymbol(name, attrs, details);
  }

  // Default action for a parse tree node is to visit children.
  template<typename T> bool Pre(const T &x) { return true; }
  template<typename T> void Post(const T &) {}

  bool Pre(const parser::TypeDeclarationStmt &x) {
    beginDeclTypeSpec();
    beginAttrs();
    return true;
  }
  void Post(const parser::TypeDeclarationStmt &x) {
    endDeclTypeSpec();
    endAttrs();
  }

  void Post(const parser::EntityDecl &x) {
    // TODO: may be under StructureStmt
    const auto &name = std::get<parser::ObjectName>(x.t);
    // TODO: optional ArraySpec, CoarraySpec, CharLength, Initialization
    Symbol &symbol = CurrScope().GetOrMakeSymbol(name.ToString());
    if (symbol.has<UnknownDetails>()) {
      symbol.set_details(EntityDetails());
    } else if (EntityDetails *details = symbol.detailsIf<EntityDetails>()) {
      if (details->type().has_value()) {
        std::cerr << "ERROR: symbol already has a type declared: "
            << name.ToString() << "\n";
      } else {
        details->set_type(*declTypeSpec_);
      }
    } else {
      std::cerr
          << "ERROR: symbol already declared, can't appear in entity-decl: "
          << name.ToString() << "\n";
    }
  }

  bool Pre(const parser::PrefixSpec &stmt) {
    // TODO
    return true;
  }
  void Post(const parser::EndFunctionStmt &subp) {
    std::cout << "End of function scope\n";
    std::cout << CurrScope();
    PopScope();
  }
  bool Pre(const parser::Suffix &suffix) {
    if (suffix.resultName.has_value()) {
      funcResultName_ =
          std::make_optional(suffix.resultName->ToString());
    }
    return true;
  }

  bool Pre(const parser::SubroutineStmt &stmt) {
    beginAttrs();
    return true;
  }

  // Common Post() for functions and subroutines.
  void PostSubprogram(
      const Name &name, const std::list<Name> &dummyNames) {
    const auto attrs = endAttrs();
    MakeSymbol(name, attrs, SubprogramDetails(dummyNames));
    Scope &subpScope = CurrScope().MakeScope(Scope::Kind::Subprogram);
    PushScope(subpScope);
    for (const auto &dummyName : dummyNames) {
      MakeSymbol(dummyName, EntityDetails(true));
    }
  }

  void Post(const parser::SubroutineStmt &stmt) {
    Name subrName = std::get<parser::Name>(stmt.t).ToString();
    std::list<Name> dummyNames;
    const auto &dummyArgs = std::get<std::list<parser::DummyArg>>(stmt.t);
    for (const parser::DummyArg &dummyArg : dummyArgs) {
      const parser::Name *dummyName = std::get_if<parser::Name>(&dummyArg.u);
      CHECK(dummyName != nullptr && "TODO: alternate return indicator");
      dummyNames.push_back(dummyName->ToString());
    }
    PostSubprogram(subrName, dummyNames);
    MakeSymbol(subrName, SubprogramDetails(dummyNames));
  }

  bool Pre(const parser::FunctionStmt &stmt) {
    beginAttrs();
    beginDeclTypeSpec();
    CHECK(!funcResultName_);
    return true;
  }
  // TODO: MakeSymbol function
  void Post(const parser::FunctionStmt &stmt) {
    Name funcName = std::get<parser::Name>(stmt.t).ToString();
    std::list<Name> dummyNames;
    for (const auto &dummy : std::get<std::list<parser::Name>>(stmt.t)) {
      dummyNames.push_back(dummy.ToString());
    }
    PostSubprogram(funcName, dummyNames);
    // add function result to function scope
    EntityDetails funcResultDetails;
    if (declTypeSpec_) {
      funcResultDetails.set_type(*declTypeSpec_);
    }
    const auto &resultName = funcResultName_ ? *funcResultName_ : funcName;
    MakeSymbol(resultName, funcResultDetails);
    if (resultName != funcName) {
      // add symbol for function to its scope; name can't be reused
      MakeSymbol(funcName, SubprogramDetails(dummyNames, funcResultName_));
    }
    endDeclTypeSpec();
    funcResultName_ = std::nullopt;
  }

  void Post(const parser::Program &) {
    // ensure that all temps were deallocated
    CHECK(!attrs_);
    CHECK(!declTypeSpec_);
  }

private:
  // Stack of containing scopes; memory referenced is owned by parent scopes
  std::stack<Scope *, std::list<Scope *>> scopes_;
  std::optional<Name> funcResultName_;
};

void ResolveNames(const parser::Program &program) {
  ResolveNamesVisitor visitor;
  parser::Walk(program, visitor);
}
}  // namespace Fortran::semantics
