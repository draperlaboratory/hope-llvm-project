//===- unittest/Tooling/SourceCodeTest.cpp --------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "clang/Tooling/Transformer/SourceCode.h"
#include "TestVisitor.h"
#include "clang/Basic/Diagnostic.h"
#include "llvm/Testing/Support/Annotations.h"
#include "llvm/Testing/Support/Error.h"
#include "llvm/Testing/Support/SupportHelpers.h"
#include <gmock/gmock.h>
#include <gtest/gtest.h>

using namespace clang;

using llvm::Failed;
using llvm::Succeeded;
using llvm::ValueIs;
using tooling::getAssociatedRange;
using tooling::getExtendedText;
using tooling::getRangeForEdit;
using tooling::getText;
using tooling::validateEditRange;

namespace {

struct IntLitVisitor : TestVisitor<IntLitVisitor> {
  bool VisitIntegerLiteral(IntegerLiteral *Expr) {
    OnIntLit(Expr, Context);
    return true;
  }

  std::function<void(IntegerLiteral *, ASTContext *Context)> OnIntLit;
};

struct CallsVisitor : TestVisitor<CallsVisitor> {
  bool VisitCallExpr(CallExpr *Expr) {
    OnCall(Expr, Context);
    return true;
  }

  std::function<void(CallExpr *, ASTContext *Context)> OnCall;
};

// Equality matcher for `clang::CharSourceRange`, which lacks `operator==`.
MATCHER_P(EqualsRange, R, "") {
  return arg.isTokenRange() == R.isTokenRange() &&
         arg.getBegin() == R.getBegin() && arg.getEnd() == R.getEnd();
}

MATCHER_P2(EqualsAnnotatedRange, SM, R, "") {
  if (arg.getBegin().isMacroID()) {
    *result_listener << "which starts in a macro";
    return false;
  }
  if (arg.getEnd().isMacroID()) {
    *result_listener << "which ends in a macro";
    return false;
  }

  unsigned Begin = SM->getFileOffset(arg.getBegin());
  unsigned End = SM->getFileOffset(arg.getEnd());

  *result_listener << "which is [" << Begin << ",";
  if (arg.isTokenRange()) {
    *result_listener << End << "]";
    return Begin == R.Begin && End + 1 == R.End;
  }
  *result_listener << End << ")";
  return Begin == R.Begin && End == R.End;
}

static ::testing::Matcher<CharSourceRange> AsRange(const SourceManager &SM,
                                                   llvm::Annotations::Range R) {
  return EqualsRange(CharSourceRange::getCharRange(
      SM.getLocForStartOfFile(SM.getMainFileID()).getLocWithOffset(R.Begin),
      SM.getLocForStartOfFile(SM.getMainFileID()).getLocWithOffset(R.End)));
}

// Base class for visitors that expect a single match corresponding to a
// specific annotated range.
template <typename T>
class AnnotatedCodeVisitor : public TestVisitor<T> {
  llvm::Annotations Code;
  int MatchCount = 0;

 public:
  AnnotatedCodeVisitor() : Code("$r[[]]") {}
  bool VisitDeclHelper(Decl *Decl) {
    // Only consider explicit declarations.
    if (Decl->isImplicit())
      return true;

    ++MatchCount;
    EXPECT_THAT(
        getAssociatedRange(*Decl, *this->Context),
        EqualsAnnotatedRange(&this->Context->getSourceManager(), Code.range("r")))
        << Code.code();
    return true;
  }

  bool runOverAnnotated(llvm::StringRef AnnotatedCode) {
    Code = llvm::Annotations(AnnotatedCode);
    MatchCount = 0;
    bool result = this->runOver(Code.code());
    EXPECT_EQ(MatchCount, 1);
    return result;
  }
};

TEST(SourceCodeTest, getText) {
  CallsVisitor Visitor;

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("foo(x, y)", getText(*CE, *Context));
  };
  Visitor.runOver("void foo(int x, int y) { foo(x, y); }");

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("APPLY(foo, x, y)", getText(*CE, *Context));
  };
  Visitor.runOver("#define APPLY(f, x, y) f(x, y)\n"
                  "void foo(int x, int y) { APPLY(foo, x, y); }");
}

TEST(SourceCodeTest, getTextWithMacro) {
  CallsVisitor Visitor;

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("F OO", getText(*CE, *Context));
    Expr *P0 = CE->getArg(0);
    Expr *P1 = CE->getArg(1);
    EXPECT_EQ("", getText(*P0, *Context));
    EXPECT_EQ("", getText(*P1, *Context));
  };
  Visitor.runOver("#define F foo(\n"
                  "#define OO x, y)\n"
                  "void foo(int x, int y) { F OO ; }");

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("", getText(*CE, *Context));
    Expr *P0 = CE->getArg(0);
    Expr *P1 = CE->getArg(1);
    EXPECT_EQ("x", getText(*P0, *Context));
    EXPECT_EQ("y", getText(*P1, *Context));
  };
  Visitor.runOver("#define FOO(x, y) (void)x; (void)y; foo(x, y);\n"
                  "void foo(int x, int y) { FOO(x,y) }");
}

TEST(SourceCodeTest, getExtendedText) {
  CallsVisitor Visitor;

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("foo(x, y);",
              getExtendedText(*CE, tok::TokenKind::semi, *Context));

    Expr *P0 = CE->getArg(0);
    Expr *P1 = CE->getArg(1);
    EXPECT_EQ("x", getExtendedText(*P0, tok::TokenKind::semi, *Context));
    EXPECT_EQ("x,", getExtendedText(*P0, tok::TokenKind::comma, *Context));
    EXPECT_EQ("y", getExtendedText(*P1, tok::TokenKind::semi, *Context));
  };
  Visitor.runOver("void foo(int x, int y) { foo(x, y); }");
  Visitor.runOver("void foo(int x, int y) { if (true) foo(x, y); }");
  Visitor.runOver("int foo(int x, int y) { if (true) return 3 + foo(x, y); }");
  Visitor.runOver("void foo(int x, int y) { for (foo(x, y);;) ++x; }");
  Visitor.runOver(
      "bool foo(int x, int y) { for (;foo(x, y);) x = 1; return true; }");

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    EXPECT_EQ("foo()", getExtendedText(*CE, tok::TokenKind::semi, *Context));
  };
  Visitor.runOver("bool foo() { if (foo()) return true; return false; }");
  Visitor.runOver("void foo() { int x; for (;; foo()) ++x; }");
  Visitor.runOver("int foo() { return foo() + 3; }");
}

TEST(SourceCodeTest, getAssociatedRange) {
  struct VarDeclsVisitor : AnnotatedCodeVisitor<VarDeclsVisitor> {
    bool VisitVarDecl(VarDecl *Decl) {
      return VisitDeclHelper(Decl);
    }
  };
  VarDeclsVisitor Visitor;

  // Includes semicolon.
  Visitor.runOverAnnotated("$r[[int x = 4;]]");

  // Includes newline and semicolon.
  Visitor.runOverAnnotated("$r[[int x = 4;\n]]");

  // Includes trailing comments.
  Visitor.runOverAnnotated("$r[[int x = 4; // Comment\n]]");
  Visitor.runOverAnnotated("$r[[int x = 4; /* Comment */\n]]");

  // Does *not* include trailing comments when another entity appears between
  // the decl and the comment.
  Visitor.runOverAnnotated("$r[[int x = 4;]] class C {}; // Comment\n");

  // Includes attributes.
  Visitor.runOverAnnotated(R"cpp(
      #define ATTR __attribute__((deprecated("message")))
      $r[[ATTR
      int x;]])cpp");

  // Includes attributes and comments together.
  Visitor.runOverAnnotated(R"cpp(
      #define ATTR __attribute__((deprecated("message")))
      $r[[ATTR
      // Commment.
      int x;]])cpp");
}

TEST(SourceCodeTest, getAssociatedRangeClasses) {
  struct RecordDeclsVisitor : AnnotatedCodeVisitor<RecordDeclsVisitor> {
    bool VisitRecordDecl(RecordDecl *Decl) {
      return VisitDeclHelper(Decl);
    }
  };
  RecordDeclsVisitor Visitor;

  Visitor.runOverAnnotated("$r[[class A;]]");
  Visitor.runOverAnnotated("$r[[class A {};]]");

  // Includes leading template annotation.
  Visitor.runOverAnnotated("$r[[template <typename T> class A;]]");
  Visitor.runOverAnnotated("$r[[template <typename T> class A {};]]");
}

TEST(SourceCodeTest, getAssociatedRangeClassTemplateSpecializations) {
  struct CXXRecordDeclsVisitor : AnnotatedCodeVisitor<CXXRecordDeclsVisitor> {
    bool VisitCXXRecordDecl(CXXRecordDecl *Decl) {
      return Decl->getTemplateSpecializationKind() !=
                 TSK_ExplicitSpecialization ||
             VisitDeclHelper(Decl);
    }
  };
  CXXRecordDeclsVisitor Visitor;

  Visitor.runOverAnnotated(R"cpp(
      template <typename T> class A{};
      $r[[template <> class A<int>;]])cpp");
  Visitor.runOverAnnotated(R"cpp(
      template <typename T> class A{};
      $r[[template <> class A<int> {};]])cpp");
}

TEST(SourceCodeTest, getAssociatedRangeFunctions) {
  struct FunctionDeclsVisitor : AnnotatedCodeVisitor<FunctionDeclsVisitor> {
    bool VisitFunctionDecl(FunctionDecl *Decl) {
      return VisitDeclHelper(Decl);
    }
  };
  FunctionDeclsVisitor Visitor;

  Visitor.runOverAnnotated("$r[[int f();]]");
  Visitor.runOverAnnotated("$r[[int f() { return 0; }]]");
  // Includes leading template annotation.
  Visitor.runOverAnnotated("$r[[template <typename T> int f();]]");
  Visitor.runOverAnnotated("$r[[template <typename T> int f() { return 0; }]]");
}

TEST(SourceCodeTest, getAssociatedRangeMemberTemplates) {
  struct CXXMethodDeclsVisitor : AnnotatedCodeVisitor<CXXMethodDeclsVisitor> {
    bool VisitCXXMethodDecl(CXXMethodDecl *Decl) {
      // Only consider the definition of the template.
      return !Decl->doesThisDeclarationHaveABody() || VisitDeclHelper(Decl);
    }
  };
  CXXMethodDeclsVisitor Visitor;

  Visitor.runOverAnnotated(R"cpp(
      template <typename C>
      struct A { template <typename T> int member(T v); };

      $r[[template <typename C>
      template  <typename T>
      int A<C>::member(T v) { return 0; }]])cpp");
}

TEST(SourceCodeTest, getAssociatedRangeWithComments) {
  struct VarDeclsVisitor : TestVisitor<VarDeclsVisitor> {
    llvm::Annotations Code;
    int Count;

    VarDeclsVisitor() : Code("$r[[]]") {}
    bool VisitVarDecl(VarDecl *Decl) {
      ++Count;
      EXPECT_THAT(
          getAssociatedRange(*Decl, *Context),
          EqualsAnnotatedRange(&Context->getSourceManager(), Code.range("r")))
          << Code.code();
      return true;
    }

    bool runOverAnnotated(llvm::StringRef AnnotatedCode) {
      Code = llvm::Annotations(AnnotatedCode);
      Count = 0;
      std::vector<std::string> Args = {"-std=c++11", "-fparse-all-comments"};
      bool result =
          tooling::runToolOnCodeWithArgs(CreateTestAction(), Code.code(), Args);
      EXPECT_EQ(Count, 1) << Code.code();
      return result;
    }
  };

  VarDeclsVisitor Visitor;

  // Includes leading comments.
  Visitor.runOverAnnotated("$r[[// Comment.\nint x = 4;]]");
  Visitor.runOverAnnotated("$r[[// Comment.\nint x = 4;\n]]");
  Visitor.runOverAnnotated("$r[[/* Comment.*/\nint x = 4;\n]]");
  // ... even if separated by (extra) horizontal whitespace.
  Visitor.runOverAnnotated("$r[[/* Comment.*/  \nint x = 4;\n]]");

  // Includes comments even in the presence of trailing whitespace.
  Visitor.runOverAnnotated("$r[[// Comment.\nint x = 4;]]  ");


  // Includes comments when the declaration is followed by the beginning or end
  // of a compound statement.
  Visitor.runOverAnnotated(R"cpp(
  void foo() {
    $r[[/* C */
    int x = 4;
  ]]};)cpp");
  Visitor.runOverAnnotated(R"cpp(
  void foo() {
    $r[[/* C */
    int x = 4;
   ]]{ class Foo {}; }
   })cpp");

  // Includes comments inside macros (when decl is in the same macro).
  Visitor.runOverAnnotated(R"cpp(
      #define DECL /* Comment */ int x
      $r[[DECL;]])cpp");

  // Does not include comments when only the decl or the comment come from a
  // macro.
  // FIXME: Change code to allow this.
  Visitor.runOverAnnotated(R"cpp(
      #define DECL int x
      // Comment
      $r[[DECL;]])cpp");
  Visitor.runOverAnnotated(R"cpp(
      #define COMMENT /* Comment */
      COMMENT
      $r[[int x;]])cpp");

  // Includes multi-line comments.
  Visitor.runOverAnnotated(R"cpp(
      $r[[/* multi
       * line
       * comment
       */
      int x;]])cpp");
  Visitor.runOverAnnotated(R"cpp(
      $r[[// multi
      // line
      // comment
      int x;]])cpp");

  // Does not include comments separated by multiple empty lines.
  Visitor.runOverAnnotated("// Comment.\n\n\n$r[[int x = 4;\n]]");
  Visitor.runOverAnnotated("/* Comment.*/\n\n\n$r[[int x = 4;\n]]");

  // Does not include comments before a *series* of declarations.
  Visitor.runOverAnnotated(R"cpp(
      // Comment.
      $r[[int x = 4;
      ]]class foo {};)cpp");

  // Does not include IfThisThenThat comments
  Visitor.runOverAnnotated("// LINT.IfChange.\n$r[[int x = 4;]]");
  Visitor.runOverAnnotated("// LINT.ThenChange.\n$r[[int x = 4;]]");

  // Includes attributes.
  Visitor.runOverAnnotated(R"cpp(
      #define ATTR __attribute__((deprecated("message")))
      $r[[ATTR
      int x;]])cpp");

  // Includes attributes and comments together.
  Visitor.runOverAnnotated(R"cpp(
      #define ATTR __attribute__((deprecated("message")))
      $r[[ATTR
      // Commment.
      int x;]])cpp");
}

TEST(SourceCodeTest, getAssociatedRangeInvalidForPartialExpansions) {
  struct FailingVarDeclsVisitor : TestVisitor<FailingVarDeclsVisitor> {
    FailingVarDeclsVisitor() {}
    bool VisitVarDecl(VarDecl *Decl) {
      EXPECT_TRUE(getAssociatedRange(*Decl, *Context).isInvalid());
      return true;
    }
  };

  FailingVarDeclsVisitor Visitor;
  // Should fail because it only includes a part of the expansion.
  std::string Code = R"cpp(
      #define DECL class foo { }; int x
      DECL;)cpp";
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, EditRangeWithMacroExpansionsShouldSucceed) {
  // The call expression, whose range we are extracting, includes two macro
  // expansions.
  llvm::Annotations Code(R"cpp(
#define M(a) a * 13
int foo(int x, int y);
int a = $r[[foo(M(1), M(2))]];
)cpp");

  CallsVisitor Visitor;

  Visitor.OnCall = [&Code](CallExpr *CE, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(CE->getSourceRange());
    EXPECT_THAT(getRangeForEdit(Range, *Context),
                ValueIs(AsRange(Context->getSourceManager(), Code.range("r"))));
  };
  Visitor.runOver(Code.code());
}

TEST(SourceCodeTest, EditWholeMacroExpansionShouldSucceed) {
  llvm::Annotations Code(R"cpp(
#define FOO 10
int a = $r[[FOO]];
)cpp");

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [&Code](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT(getRangeForEdit(Range, *Context),
                ValueIs(AsRange(Context->getSourceManager(), Code.range("r"))));
  };
  Visitor.runOver(Code.code());
}

TEST(SourceCodeTest, EditPartialMacroExpansionShouldFail) {
  std::string Code = R"cpp(
#define BAR 10+
int c = BAR 3.0;
)cpp";

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_FALSE(getRangeForEdit(Range, *Context).hasValue());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, EditWholeMacroArgShouldSucceed) {
  llvm::Annotations Code(R"cpp(
#define FOO(a) a + 7.0;
int a = FOO($r[[10]]);
)cpp");

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [&Code](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT(getRangeForEdit(Range, *Context),
                ValueIs(AsRange(Context->getSourceManager(), Code.range("r"))));
  };
  Visitor.runOver(Code.code());
}

TEST(SourceCodeTest, EditPartialMacroArgShouldSucceed) {
  llvm::Annotations Code(R"cpp(
#define FOO(a) a + 7.0;
int a = FOO($r[[10]] + 10.0);
)cpp");

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [&Code](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT(getRangeForEdit(Range, *Context),
                ValueIs(AsRange(Context->getSourceManager(), Code.range("r"))));
  };
  Visitor.runOver(Code.code());
}

TEST(SourceCodeTest, EditRangeWithMacroExpansionsIsValid) {
  // The call expression, whose range we are extracting, includes two macro
  // expansions.
  llvm::StringRef Code = R"cpp(
#define M(a) a * 13
int foo(int x, int y);
int a = foo(M(1), M(2));
)cpp";

  CallsVisitor Visitor;

  Visitor.OnCall = [](CallExpr *CE, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(CE->getSourceRange());
    EXPECT_THAT_ERROR(validateEditRange(Range, Context->getSourceManager()),
                      Succeeded());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, SpellingRangeOfMacroArgIsValid) {
  llvm::StringRef Code = R"cpp(
#define FOO(a) a + 7.0;
int a = FOO(10);
)cpp";

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *Expr, ASTContext *Context) {
    SourceLocation ArgLoc =
        Context->getSourceManager().getSpellingLoc(Expr->getBeginLoc());
    // The integer literal is a single token.
    auto ArgRange = CharSourceRange::getTokenRange(ArgLoc);
    EXPECT_THAT_ERROR(validateEditRange(ArgRange, Context->getSourceManager()),
                      Succeeded());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, InvalidEditRangeIsInvalid) {
  llvm::StringRef Code = "int c = 10;";

  // We use the visitor just to get a valid context.
  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *, ASTContext *Context) {
    CharSourceRange Invalid;
    EXPECT_THAT_ERROR(validateEditRange(Invalid, Context->getSourceManager()),
                      Failed());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, InvertedEditRangeIsInvalid) {
  llvm::StringRef Code = R"cpp(
int foo(int x);
int a = foo(2);
)cpp";

  CallsVisitor Visitor;
  Visitor.OnCall = [](CallExpr *Expr, ASTContext *Context) {
    auto InvertedRange = CharSourceRange::getTokenRange(
        SourceRange(Expr->getEndLoc(), Expr->getBeginLoc()));
    EXPECT_THAT_ERROR(
        validateEditRange(InvertedRange, Context->getSourceManager()),
        Failed());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, MacroArgIsInvalid) {
  llvm::StringRef Code = R"cpp(
#define FOO(a) a + 7.0;
int a = FOO(10);
)cpp";

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT_ERROR(validateEditRange(Range, Context->getSourceManager()),
                      Failed());
  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, EditWholeMacroExpansionIsInvalid) {
  llvm::StringRef Code = R"cpp(
#define FOO 10
int a = FOO;
)cpp";

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT_ERROR(validateEditRange(Range, Context->getSourceManager()),
                      Failed());

  };
  Visitor.runOver(Code);
}

TEST(SourceCodeTest, EditPartialMacroExpansionIsInvalid) {
  llvm::StringRef Code = R"cpp(
#define BAR 10+
int c = BAR 3.0;
)cpp";

  IntLitVisitor Visitor;
  Visitor.OnIntLit = [](IntegerLiteral *Expr, ASTContext *Context) {
    auto Range = CharSourceRange::getTokenRange(Expr->getSourceRange());
    EXPECT_THAT_ERROR(validateEditRange(Range, Context->getSourceManager()),
                      Failed());
  };
  Visitor.runOver(Code);
}
} // end anonymous namespace
