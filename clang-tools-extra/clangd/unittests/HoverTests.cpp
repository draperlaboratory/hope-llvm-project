//===-- HoverTests.cpp ----------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "AST.h"
#include "Annotations.h"
#include "Hover.h"
#include "TestIndex.h"
#include "TestTU.h"
#include "index/MemIndex.h"
#include "clang/Basic/Specifiers.h"
#include "clang/Index/IndexSymbol.h"
#include "llvm/ADT/None.h"
#include "llvm/ADT/StringRef.h"

#include "gmock/gmock.h"
#include "gtest/gtest.h"
#include <string>
#include <vector>

namespace clang {
namespace clangd {
namespace {

using PassMode = HoverInfo::PassType::PassMode;

TEST(Hover, Structured) {
  struct {
    const char *const Code;
    const std::function<void(HoverInfo &)> ExpectedBuilder;
  } Cases[] = {
      // Global scope.
      {R"cpp(
          // Best foo ever.
          void [[fo^o]]() {}
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "foo";
         HI.Kind = index::SymbolKind::Function;
         HI.Documentation = "Best foo ever.";
         HI.Definition = "void foo()";
         HI.ReturnType = "void";
         HI.Type = "void ()";
         HI.Parameters.emplace();
       }},
      // Inside namespace
      {R"cpp(
          namespace ns1 { namespace ns2 {
            /// Best foo ever.
            void [[fo^o]]() {}
          }}
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "ns1::ns2::";
         HI.Name = "foo";
         HI.Kind = index::SymbolKind::Function;
         HI.Documentation = "Best foo ever.";
         HI.Definition = "void foo()";
         HI.ReturnType = "void";
         HI.Type = "void ()";
         HI.Parameters.emplace();
       }},
      // Field
      {R"cpp(
          namespace ns1 { namespace ns2 {
            struct Foo {
              char [[b^ar]];
            };
          }}
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "ns1::ns2::";
         HI.LocalScope = "Foo::";
         HI.Name = "bar";
         HI.Kind = index::SymbolKind::Field;
         HI.Definition = "char bar";
         HI.Type = "char";
         HI.Offset = 0;
         HI.Size = 1;
         HI.AccessSpecifier = "public";
       }},
      // Local to class method.
      {R"cpp(
          namespace ns1 { namespace ns2 {
            struct Foo {
              void foo() {
                int [[b^ar]];
              }
            };
          }}
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "ns1::ns2::";
         HI.LocalScope = "Foo::foo::";
         HI.Name = "bar";
         HI.Kind = index::SymbolKind::Variable;
         HI.Definition = "int bar";
         HI.Type = "int";
       }},
      // Anon namespace and local scope.
      {R"cpp(
          namespace ns1 { namespace {
            struct {
              char [[b^ar]];
            } T;
          }}
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "ns1::";
         HI.LocalScope = "(anonymous struct)::";
         HI.Name = "bar";
         HI.Kind = index::SymbolKind::Field;
         HI.Definition = "char bar";
         HI.Type = "char";
         HI.Offset = 0;
         HI.Size = 1;
         HI.AccessSpecifier = "public";
       }},
      // Struct definition shows size.
      {R"cpp(
          struct [[^X]]{};
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "X";
         HI.Kind = index::SymbolKind::Struct;
         HI.Definition = "struct X {}";
         HI.Size = 1;
       }},
      // Variable with template type
      {R"cpp(
          template <typename T, class... Ts> class Foo { public: Foo(int); };
          Foo<int, char, bool> [[fo^o]] = Foo<int, char, bool>(5);
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "foo";
         HI.Kind = index::SymbolKind::Variable;
         HI.Definition = "Foo<int, char, bool> foo = Foo<int, char, bool>(5)";
         HI.Type = "Foo<int, char, bool>";
       }},
      // Implicit template instantiation
      {R"cpp(
          template <typename T> class vector{};
          [[vec^tor]]<int> foo;
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "vector<int>";
         HI.Kind = index::SymbolKind::Class;
         HI.Definition = "template <> class vector<int> {}";
       }},
      // Class template
      {R"cpp(
          template <template<typename, bool...> class C,
                    typename = char,
                    int = 0,
                    bool Q = false,
                    class... Ts> class Foo {};
          template <template<typename, bool...> class T>
          [[F^oo]]<T> foo;
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "Foo";
         HI.Kind = index::SymbolKind::Class;
         HI.Definition =
             R"cpp(template <template <typename, bool...> class C, typename = char, int = 0,
          bool Q = false, class... Ts>
class Foo {})cpp";
         HI.TemplateParameters = {
             {std::string("template <typename, bool...> class"),
              std::string("C"), llvm::None},
             {std::string("typename"), llvm::None, std::string("char")},
             {std::string("int"), llvm::None, std::string("0")},
             {std::string("bool"), std::string("Q"), std::string("false")},
             {std::string("class..."), std::string("Ts"), llvm::None},
         };
       }},
      // Function template
      {R"cpp(
          template <template<typename, bool...> class C,
                    typename = char,
                    int = 0,
                    bool Q = false,
                    class... Ts> void foo();
          template<typename, bool...> class Foo;

          void bar() {
            [[fo^o]]<Foo>();
          }
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "foo";
         HI.Kind = index::SymbolKind::Function;
         HI.Definition = "template <> void foo<Foo, char, 0, false, <>>()";
         HI.ReturnType = "void";
         HI.Type = "void ()";
         HI.Parameters.emplace();
       }},
      // Function decl
      {R"cpp(
          template<typename, bool...> class Foo {};
          Foo<bool, true, false> foo(int, bool T = false);

          void bar() {
            [[fo^o]](3);
          }
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "foo";
         HI.Kind = index::SymbolKind::Function;
         HI.Definition = "Foo<bool, true, false> foo(int, bool T = false)";
         HI.ReturnType = "Foo<bool, true, false>";
         HI.Type = "Foo<bool, true, false> (int, bool)";
         HI.Parameters = {
             {std::string("int"), llvm::None, llvm::None},
             {std::string("bool"), std::string("T"), std::string("false")},
         };
       }},
      // Pointers to lambdas
      {R"cpp(
        void foo() {
          auto lamb = [](int T, bool B) -> bool { return T && B; };
          auto *b = &lamb;
          auto *[[^c]] = &b;
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.LocalScope = "foo::";
         HI.Name = "c";
         HI.Kind = index::SymbolKind::Variable;
         HI.Definition = "auto *c = &b";
         HI.Type = "class (lambda) **";
         HI.ReturnType = "bool";
         HI.Parameters = {
             {std::string("int"), std::string("T"), llvm::None},
             {std::string("bool"), std::string("B"), llvm::None},
         };
         return HI;
       }},
      // Lambda parameter with decltype reference
      {R"cpp(
        auto lamb = [](int T, bool B) -> bool { return T && B; };
        void foo(decltype(lamb)& bar) {
          [[ba^r]](0, false);
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.LocalScope = "foo::";
         HI.Name = "bar";
         HI.Kind = index::SymbolKind::Parameter;
         HI.Definition = "decltype(lamb) &bar";
         HI.Type = "decltype(lamb) &";
         HI.ReturnType = "bool";
         HI.Parameters = {
             {std::string("int"), std::string("T"), llvm::None},
             {std::string("bool"), std::string("B"), llvm::None},
         };
         return HI;
       }},
      // Lambda parameter with decltype
      {R"cpp(
        auto lamb = [](int T, bool B) -> bool { return T && B; };
        void foo(decltype(lamb) bar) {
          [[ba^r]](0, false);
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.LocalScope = "foo::";
         HI.Name = "bar";
         HI.Kind = index::SymbolKind::Parameter;
         HI.Definition = "decltype(lamb) bar";
         HI.Type = "class (lambda)";
         HI.ReturnType = "bool";
         HI.Parameters = {
             {std::string("int"), std::string("T"), llvm::None},
             {std::string("bool"), std::string("B"), llvm::None},
         };
         HI.Value = "false";
         return HI;
       }},
      // Lambda variable
      {R"cpp(
        void foo() {
          int bar = 5;
          auto lamb = [&bar](int T, bool B) -> bool { return T && B && bar; };
          bool res = [[lam^b]](bar, false);
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.LocalScope = "foo::";
         HI.Name = "lamb";
         HI.Kind = index::SymbolKind::Variable;
         HI.Definition = "auto lamb = [&bar](int T, bool B) -> bool {}";
         HI.Type = "class (lambda)";
         HI.ReturnType = "bool";
         HI.Parameters = {
             {std::string("int"), std::string("T"), llvm::None},
             {std::string("bool"), std::string("B"), llvm::None},
         };
         return HI;
       }},
      // Local variable in lambda
      {R"cpp(
        void foo() {
          auto lamb = []{int [[te^st]];};
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.LocalScope = "foo::(anonymous class)::operator()::";
         HI.Name = "test";
         HI.Kind = index::SymbolKind::Variable;
         HI.Definition = "int test";
         HI.Type = "int";
       }},
      // Partially-specialized class template. (formerly type-parameter-0-0)
      {R"cpp(
        template <typename T> class X;
        template <typename T> class [[^X]]<T*> {};
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "X<T *>";
         HI.NamespaceScope = "";
         HI.Kind = index::SymbolKind::Class;
         HI.Definition = "template <typename T> class X<T *> {}";
       }},
      // Constructor of partially-specialized class template
      {R"cpp(
          template<typename, typename=void> struct X;
          template<typename T> struct X<T*>{ [[^X]](); };
          )cpp",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "X";
         HI.LocalScope = "X<T *>::"; // FIXME: X<T *, void>::
         HI.Kind = index::SymbolKind::Constructor;
         HI.Definition = "X()";
         HI.Parameters.emplace();
         HI.AccessSpecifier = "public";
       }},
      {"class X { [[^~]]X(); };", // FIXME: Should be [[~X]]()
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "~X";
         HI.LocalScope = "X::";
         HI.Kind = index::SymbolKind::Destructor;
         HI.Definition = "~X()";
         HI.Parameters.emplace();
         HI.AccessSpecifier = "private";
       }},
      {"class X { [[op^erator]] int(); };",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "operator int";
         HI.LocalScope = "X::";
         HI.Kind = index::SymbolKind::ConversionFunction;
         HI.Definition = "operator int()";
         HI.Parameters.emplace();
         HI.AccessSpecifier = "private";
       }},
      {"class X { operator [[^X]](); };",
       [](HoverInfo &HI) {
         HI.NamespaceScope = "";
         HI.Name = "X";
         HI.Kind = index::SymbolKind::Class;
         HI.Definition = "class X {}";
       }},

      // auto on structured bindings
      {R"cpp(
        void foo() {
          struct S { int x; float y; };
          [[au^to]] [x, y] = S();
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "auto";
         HI.Kind = index::SymbolKind::TypeAlias;
         HI.Definition = "struct S";
       }},
      // undeduced auto
      {R"cpp(
        template<typename T>
        void foo() {
          [[au^to]] x = T{};
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "auto";
         HI.Kind = index::SymbolKind::TypeAlias;
         HI.Definition = "/* not deduced */";
       }},
      // auto on lambda
      {R"cpp(
        void foo() {
          [[au^to]] lamb = []{};
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "auto";
         HI.Kind = index::SymbolKind::TypeAlias;
         HI.Definition = "class(lambda)";
       }},
      // auto on template instantiation
      {R"cpp(
        template<typename T> class Foo{};
        void foo() {
          [[au^to]] x = Foo<int>();
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "auto";
         HI.Kind = index::SymbolKind::TypeAlias;
         HI.Definition = "class Foo<int>";
       }},
      // auto on specialized template
      {R"cpp(
        template<typename T> class Foo{};
        template<> class Foo<int>{};
        void foo() {
          [[au^to]] x = Foo<int>();
        }
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "auto";
         HI.Kind = index::SymbolKind::TypeAlias;
         HI.Definition = "class Foo<int>";
       }},

      // macro
      {R"cpp(
        // Best MACRO ever.
        #define MACRO(x,y,z) void foo(x, y, z);
        [[MAC^RO]](int, double d, bool z = false);
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "MACRO", HI.Kind = index::SymbolKind::Macro,
         HI.Definition = "#define MACRO(x, y, z) void foo(x, y, z);";
       }},

      // constexprs
      {R"cpp(
        constexpr int add(int a, int b) { return a + b; }
        int [[b^ar]] = add(1, 2);
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "bar";
         HI.Definition = "int bar = add(1, 2)";
         HI.Kind = index::SymbolKind::Variable;
         HI.Type = "int";
         HI.NamespaceScope = "";
         HI.Value = "3";
       }},
      {R"cpp(
        int [[b^ar]] = sizeof(char);
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "bar";
         HI.Definition = "int bar = sizeof(char)";
         HI.Kind = index::SymbolKind::Variable;
         HI.Type = "int";
         HI.NamespaceScope = "";
         HI.Value = "1";
       }},
      {R"cpp(
        template<int a, int b> struct Add {
          static constexpr int result = a + b;
        };
        int [[ba^r]] = Add<1, 2>::result;
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "bar";
         HI.Definition = "int bar = Add<1, 2>::result";
         HI.Kind = index::SymbolKind::Variable;
         HI.Type = "int";
         HI.NamespaceScope = "";
         HI.Value = "3";
       }},
      {R"cpp(
        enum Color { RED, GREEN, };
        Color x = [[GR^EEN]];
       )cpp",
       [](HoverInfo &HI) {
         HI.Name = "GREEN";
         HI.NamespaceScope = "";
         HI.LocalScope = "Color::";
         HI.Definition = "GREEN";
         HI.Kind = index::SymbolKind::EnumConstant;
         HI.Type = "enum Color";
         HI.Value = "1"; // Numeric when hovering on the enumerator name.
       }},
      {R"cpp(
        enum Color { RED, GREEN, };
        Color x = GREEN;
        Color y = [[^x]];
       )cpp",
       [](HoverInfo &HI) {
         HI.Name = "x";
         HI.NamespaceScope = "";
         HI.Definition = "Color x = GREEN";
         HI.Kind = index::SymbolKind::Variable;
         HI.Type = "enum Color";
         HI.Value = "GREEN (1)"; // Symbolic when hovering on an expression.
       }},
      {R"cpp(
        template<int a, int b> struct Add {
          static constexpr int result = a + b;
        };
        int bar = Add<1, 2>::[[resu^lt]];
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "result";
         HI.Definition = "static constexpr int result = 1 + 2";
         HI.Kind = index::SymbolKind::StaticProperty;
         HI.Type = "const int";
         HI.NamespaceScope = "";
         HI.LocalScope = "Add<1, 2>::";
         HI.Value = "3";
         HI.AccessSpecifier = "public";
       }},
      {R"cpp(
        constexpr int answer() { return 40 + 2; }
        int x = [[ans^wer]]();
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "answer";
         HI.Definition = "constexpr int answer()";
         HI.Kind = index::SymbolKind::Function;
         HI.Type = "int ()";
         HI.ReturnType = "int";
         HI.Parameters.emplace();
         HI.NamespaceScope = "";
         HI.Value = "42";
       }},
      {R"cpp(
        const char *[[ba^r]] = "1234";
        )cpp",
       [](HoverInfo &HI) {
         HI.Name = "bar";
         HI.Definition = "const char *bar = \"1234\"";
         HI.Kind = index::SymbolKind::Variable;
         HI.Type = "const char *";
         HI.NamespaceScope = "";
         HI.Value = "&\"1234\"[0]";
       }},
      {R"cpp(// Should not crash
        template <typename T>
        struct Tmpl {
          Tmpl(int name);
        };

        template <typename A>
        void boom(int name) {
          new Tmpl<A>([[na^me]]);
        })cpp",
       [](HoverInfo &HI) {
         HI.Name = "name";
         HI.Definition = "int name";
         HI.Kind = index::SymbolKind::Parameter;
         HI.Type = "int";
         HI.NamespaceScope = "";
         HI.LocalScope = "boom::";
       }},
      {
          R"cpp(// Should not print inline or anon namespaces.
          namespace ns {
            inline namespace in_ns {
              namespace a {
                namespace {
                  namespace b {
                    inline namespace in_ns2 {
                      class Foo {};
                    } // in_ns2
                  } // b
                } // anon
              } // a
            } // in_ns
          } // ns
          void foo() {
            ns::a::b::[[F^oo]] x;
            (void)x;
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "Foo";
            HI.Kind = index::SymbolKind::Class;
            HI.NamespaceScope = "ns::a::b::";
            HI.Definition = "class Foo {}";
          }},
      {
          R"cpp(
          template <typename T> class Foo {};
          class X;
          void foo() {
            [[^auto]] x = Foo<X>();
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "class Foo<class X>";
          }},
      {// Falls back to primary template, when the type is not instantiated.
       R"cpp(
          // comment from primary
          template <typename T> class Foo {};
          // comment from specialization
          template <typename T> class Foo<T*> {};
          void foo() {
            [[Fo^o]]<int*> *x = nullptr;
          }
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "Foo<int *>";
         HI.Kind = index::SymbolKind::Class;
         HI.NamespaceScope = "";
         HI.Definition = "template <> class Foo<int *>";
         // FIXME: Maybe force instantiation to make use of real template
         // pattern.
         HI.Documentation = "comment from primary";
       }},
      {// Template Type Parameter
       R"cpp(
          template <typename [[^T]] = int> void foo();
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "T";
         HI.Kind = index::SymbolKind::TemplateTypeParm;
         HI.NamespaceScope = "";
         HI.Definition = "typename T = int";
         HI.LocalScope = "foo::";
         HI.Type = "typename";
         HI.AccessSpecifier = "public";
       }},
      {// TemplateTemplate Type Parameter
       R"cpp(
          template <template<typename> class [[^T]]> void foo();
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "T";
         HI.Kind = index::SymbolKind::TemplateTemplateParm;
         HI.NamespaceScope = "";
         HI.Definition = "template <typename> class T";
         HI.LocalScope = "foo::";
         HI.Type = "template <typename> class";
         HI.AccessSpecifier = "public";
       }},
      {// NonType Template Parameter
       R"cpp(
          template <int [[^T]] = 5> void foo();
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "T";
         HI.Kind = index::SymbolKind::NonTypeTemplateParm;
         HI.NamespaceScope = "";
         HI.Definition = "int T = 5";
         HI.LocalScope = "foo::";
         HI.Type = "int";
         HI.AccessSpecifier = "public";
       }},

      {// Getter
       R"cpp(
          struct X { int Y; float [[^y]]() { return Y; } };
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "y";
         HI.Kind = index::SymbolKind::InstanceMethod;
         HI.NamespaceScope = "";
         HI.Definition = "float y()";
         HI.LocalScope = "X::";
         HI.Documentation = "Trivial accessor for `Y`.";
         HI.Type = "float ()";
         HI.ReturnType = "float";
         HI.Parameters.emplace();
         HI.AccessSpecifier = "public";
       }},
      {// Setter
       R"cpp(
          struct X { int Y; void [[^setY]](float v) { Y = v; } };
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "setY";
         HI.Kind = index::SymbolKind::InstanceMethod;
         HI.NamespaceScope = "";
         HI.Definition = "void setY(float v)";
         HI.LocalScope = "X::";
         HI.Documentation = "Trivial setter for `Y`.";
         HI.Type = "void (float)";
         HI.ReturnType = "void";
         HI.Parameters.emplace();
         HI.Parameters->emplace_back();
         HI.Parameters->back().Type = "float";
         HI.Parameters->back().Name = "v";
         HI.AccessSpecifier = "public";
       }},
      {// Setter (builder)
       R"cpp(
          struct X { int Y; X& [[^setY]](float v) { Y = v; return *this; } };
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "setY";
         HI.Kind = index::SymbolKind::InstanceMethod;
         HI.NamespaceScope = "";
         HI.Definition = "X &setY(float v)";
         HI.LocalScope = "X::";
         HI.Documentation = "Trivial setter for `Y`.";
         HI.Type = "struct X &(float)";
         HI.ReturnType = "struct X &";
         HI.Parameters.emplace();
         HI.Parameters->emplace_back();
         HI.Parameters->back().Type = "float";
         HI.Parameters->back().Name = "v";
         HI.AccessSpecifier = "public";
       }},
      {// Setter (move)
       R"cpp(
          namespace std { template<typename T> T&& move(T&& t); }
          struct X { int Y; void [[^setY]](float v) { Y = std::move(v); } };
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "setY";
         HI.Kind = index::SymbolKind::InstanceMethod;
         HI.NamespaceScope = "";
         HI.Definition = "void setY(float v)";
         HI.LocalScope = "X::";
         HI.Documentation = "Trivial setter for `Y`.";
         HI.Type = "void (float)";
         HI.ReturnType = "void";
         HI.Parameters.emplace();
         HI.Parameters->emplace_back();
         HI.Parameters->back().Type = "float";
         HI.Parameters->back().Name = "v";
         HI.AccessSpecifier = "public";
       }},
      {// Field type initializer.
       R"cpp(
          struct X { int x = 2; };
          X ^[[x]];
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "x";
         HI.Kind = index::SymbolKind::Variable;
         HI.NamespaceScope = "";
         HI.Definition = "X x";
         HI.Type = "struct X";
       }},
      {// Don't crash on null types.
       R"cpp(auto [^[[x]]] = 1; /*error-ok*/)cpp",
       [](HoverInfo &HI) {
         HI.Name = "x";
         HI.Kind = index::SymbolKind::Variable;
         HI.NamespaceScope = "";
         HI.Definition = "";
         HI.Type = "NULL TYPE";
         // Bindings are in theory public members of an anonymous struct.
         HI.AccessSpecifier = "public";
       }},
      {// Extra info for function call.
       R"cpp(
          void fun(int arg_a, int &arg_b) {};
          void code() {
            int a = 1, b = 2;
            fun(a, [[^b]]);
          }
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "b";
         HI.Kind = index::SymbolKind::Variable;
         HI.NamespaceScope = "";
         HI.Definition = "int b = 2";
         HI.LocalScope = "code::";
         HI.Value = "2";
         HI.Type = "int";
         HI.CalleeArgInfo.emplace();
         HI.CalleeArgInfo->Name = "arg_b";
         HI.CalleeArgInfo->Type = "int &";
         HI.CallPassType.emplace();
         HI.CallPassType->PassBy = PassMode::Ref;
         HI.CallPassType->Converted = false;
       }},
      {// Extra info for method call.
       R"cpp(
          class C {
           public:
            void fun(int arg_a = 3, int arg_b = 4) {}
          };
          void code() {
            int a = 1, b = 2;
            C c;
            c.fun([[^a]], b);
          }
          )cpp",
       [](HoverInfo &HI) {
         HI.Name = "a";
         HI.Kind = index::SymbolKind::Variable;
         HI.NamespaceScope = "";
         HI.Definition = "int a = 1";
         HI.LocalScope = "code::";
         HI.Value = "1";
         HI.Type = "int";
         HI.CalleeArgInfo.emplace();
         HI.CalleeArgInfo->Name = "arg_a";
         HI.CalleeArgInfo->Type = "int";
         HI.CalleeArgInfo->Default = "3";
         HI.CallPassType.emplace();
         HI.CallPassType->PassBy = PassMode::Value;
         HI.CallPassType->Converted = false;
       }},
      {// Dont crash on invalid decl
       R"cpp(
        // error-ok
        struct Foo {
          Bar [[x^x]];
        };)cpp",
       [](HoverInfo &HI) {
         HI.Name = "xx";
         HI.Kind = index::SymbolKind::Field;
         HI.NamespaceScope = "";
         HI.Definition = "int xx";
         HI.LocalScope = "Foo::";
         HI.Type = "int";
         HI.AccessSpecifier = "public";
       }},
      {R"cpp(
        // error-ok
        struct Foo {
          Bar xx;
          int [[y^y]];
        };)cpp",
       [](HoverInfo &HI) {
         HI.Name = "yy";
         HI.Kind = index::SymbolKind::Field;
         HI.NamespaceScope = "";
         HI.Definition = "int yy";
         HI.LocalScope = "Foo::";
         HI.Type = "int";
         HI.AccessSpecifier = "public";
       }},
      {// No crash on InitListExpr.
       R"cpp(
          struct Foo {
            int a[10];
          };
          constexpr Foo k2 = {
            ^[[{]]1} // FIXME: why the hover range is 1 character?
          };
         )cpp",
       [](HoverInfo &HI) {
         HI.Name = "expression";
         HI.Kind = index::SymbolKind::Unknown;
         HI.Type = "int [10]";
         HI.Value = "{1}";
       }}};
  for (const auto &Case : Cases) {
    SCOPED_TRACE(Case.Code);

    Annotations T(Case.Code);
    TestTU TU = TestTU::withCode(T.code());
    TU.ExtraArgs.push_back("-std=c++17");
    // Types might be different depending on the target triplet, we chose a
    // fixed one to make sure tests passes on different platform.
    TU.ExtraArgs.push_back("--target=x86_64-pc-linux-gnu");
    auto AST = TU.build();

    auto H = getHover(AST, T.point(), format::getLLVMStyle(), nullptr);
    ASSERT_TRUE(H);
    HoverInfo Expected;
    Expected.SymRange = T.range();
    Case.ExpectedBuilder(Expected);

    EXPECT_EQ(H->NamespaceScope, Expected.NamespaceScope);
    EXPECT_EQ(H->LocalScope, Expected.LocalScope);
    EXPECT_EQ(H->Name, Expected.Name);
    EXPECT_EQ(H->Kind, Expected.Kind);
    EXPECT_EQ(H->Documentation, Expected.Documentation);
    EXPECT_EQ(H->Definition, Expected.Definition);
    EXPECT_EQ(H->Type, Expected.Type);
    EXPECT_EQ(H->ReturnType, Expected.ReturnType);
    EXPECT_EQ(H->Parameters, Expected.Parameters);
    EXPECT_EQ(H->TemplateParameters, Expected.TemplateParameters);
    EXPECT_EQ(H->SymRange, Expected.SymRange);
    EXPECT_EQ(H->Value, Expected.Value);
    EXPECT_EQ(H->Size, Expected.Size);
    EXPECT_EQ(H->Offset, Expected.Offset);
    EXPECT_EQ(H->AccessSpecifier, Expected.AccessSpecifier);
    EXPECT_EQ(H->CalleeArgInfo, Expected.CalleeArgInfo);
    EXPECT_EQ(H->CallPassType, Expected.CallPassType);
  }
}

TEST(Hover, CallPassType) {
  const llvm::StringRef CodePrefix = R"cpp(
class Base {};
class Derived : public Base {};
class CustomClass {
 public:
  CustomClass() {}
  CustomClass(const Base &x) {}
  CustomClass(int &x) {}
  CustomClass(float x) {}
};

void int_by_ref(int &x) {}
void int_by_const_ref(const int &x) {}
void int_by_value(int x) {}
void base_by_ref(Base &x) {}
void base_by_const_ref(const Base &x) {}
void base_by_value(Base x) {}
void float_by_value(float x) {}
void custom_by_value(CustomClass x) {}

void fun() {
  int int_x;
  int &int_ref = int_x;
  const int &int_const_ref = int_x;
  Base base;
  const Base &base_const_ref = base;
  Derived derived;
  float float_x;
)cpp";
  const llvm::StringRef CodeSuffix = "}";

  struct {
    const char *const Code;
    HoverInfo::PassType::PassMode PassBy;
    bool Converted;
  } Tests[] = {
      // Integer tests
      {"int_by_value([[^int_x]]);", PassMode::Value, false},
      {"int_by_ref([[^int_x]]);", PassMode::Ref, false},
      {"int_by_const_ref([[^int_x]]);", PassMode::ConstRef, false},
      {"int_by_value([[^int_ref]]);", PassMode::Value, false},
      {"int_by_const_ref([[^int_ref]]);", PassMode::ConstRef, false},
      {"int_by_const_ref([[^int_ref]]);", PassMode::ConstRef, false},
      {"int_by_const_ref([[^int_const_ref]]);", PassMode::ConstRef, false},
      // Custom class tests
      {"base_by_ref([[^base]]);", PassMode::Ref, false},
      {"base_by_const_ref([[^base]]);", PassMode::ConstRef, false},
      {"base_by_const_ref([[^base_const_ref]]);", PassMode::ConstRef, false},
      {"base_by_value([[^base]]);", PassMode::Value, false},
      {"base_by_value([[^base_const_ref]]);", PassMode::Value, false},
      {"base_by_ref([[^derived]]);", PassMode::Ref, false},
      {"base_by_const_ref([[^derived]]);", PassMode::ConstRef, false},
      {"base_by_value([[^derived]]);", PassMode::Value, false},
      // Converted tests
      {"float_by_value([[^int_x]]);", PassMode::Value, true},
      {"float_by_value([[^int_ref]]);", PassMode::Value, true},
      {"float_by_value([[^int_const_ref]]);", PassMode::Value, true},
      {"custom_by_value([[^int_x]]);", PassMode::Ref, true},
      {"custom_by_value([[^float_x]]);", PassMode::Value, true},
      {"custom_by_value([[^base]]);", PassMode::ConstRef, true},
  };
  for (const auto &Test : Tests) {
    SCOPED_TRACE(Test.Code);

    const auto Code = (CodePrefix + Test.Code + CodeSuffix).str();
    Annotations T(Code);
    TestTU TU = TestTU::withCode(T.code());
    TU.ExtraArgs.push_back("-std=c++17");
    auto AST = TU.build();
    auto H = getHover(AST, T.point(), format::getLLVMStyle(), nullptr);
    ASSERT_TRUE(H);
    EXPECT_EQ(H->CallPassType->PassBy, Test.PassBy);
    EXPECT_EQ(H->CallPassType->Converted, Test.Converted);
  }
}

TEST(Hover, NoHover) {
  llvm::StringRef Tests[] = {
      "^int main() {}",
      "void foo() {^}",
      // FIXME: "decltype(auto)" should be a single hover
      "decltype(au^to) x = 0;",
      // FIXME: not supported yet
      R"cpp(// Lambda auto parameter
            auto lamb = [](a^uto){};
          )cpp",
      R"cpp(// non-named decls don't get hover. Don't crash!
            ^static_assert(1, "");
          )cpp",
      R"cpp(// non-evaluatable expr
          template <typename T> void foo() {
            (void)[[size^of]](T);
          })cpp",
      R"cpp(// should not crash on invalid semantic form of init-list-expr.
            /*error-ok*/
            struct Foo {
              int xyz = 0;
            };
            class Bar {};
            constexpr Foo s = ^{
              .xyz = Bar(),
            };
          )cpp",
      // literals
      "auto x = t^rue;",
      "auto x = '^A';",
      "auto x = ^(int){42};",
      "auto x = ^42.;",
      "auto x = ^42.0i;",
      "auto x = ^42;",
      "auto x = ^nullptr;",
      "auto x = ^\"asdf\";",
  };

  for (const auto &Test : Tests) {
    SCOPED_TRACE(Test);

    Annotations T(Test);
    TestTU TU = TestTU::withCode(T.code());
    TU.ExtraArgs.push_back("-std=c++17");
    auto AST = TU.build();
    auto H = getHover(AST, T.point(), format::getLLVMStyle(), nullptr);
    ASSERT_FALSE(H);
  }
}

TEST(Hover, All) {
  struct {
    const char *const Code;
    const std::function<void(HoverInfo &)> ExpectedBuilder;
  } Cases[] = {
      {
          R"cpp(// Local variable
            int main() {
              int bonjour;
              ^[[bonjour]] = 2;
              int test1 = bonjour;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "bonjour";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.LocalScope = "main::";
            HI.Type = "int";
            HI.Definition = "int bonjour";
          }},
      {
          R"cpp(// Local variable in method
            struct s {
              void method() {
                int bonjour;
                ^[[bonjour]] = 2;
              }
            };
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "bonjour";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.LocalScope = "s::method::";
            HI.Type = "int";
            HI.Definition = "int bonjour";
          }},
      {
          R"cpp(// Struct
            namespace ns1 {
              struct MyClass {};
            } // namespace ns1
            int main() {
              ns1::[[My^Class]]* Params;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MyClass";
            HI.Kind = index::SymbolKind::Struct;
            HI.NamespaceScope = "ns1::";
            HI.Definition = "struct MyClass {}";
          }},
      {
          R"cpp(// Class
            namespace ns1 {
              class MyClass {};
            } // namespace ns1
            int main() {
              ns1::[[My^Class]]* Params;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MyClass";
            HI.Kind = index::SymbolKind::Class;
            HI.NamespaceScope = "ns1::";
            HI.Definition = "class MyClass {}";
          }},
      {
          R"cpp(// Union
            namespace ns1 {
              union MyUnion { int x; int y; };
            } // namespace ns1
            int main() {
              ns1::[[My^Union]] Params;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MyUnion";
            HI.Kind = index::SymbolKind::Union;
            HI.NamespaceScope = "ns1::";
            HI.Definition = "union MyUnion {}";
          }},
      {
          R"cpp(// Function definition via pointer
            void foo(int) {}
            int main() {
              auto *X = &^[[foo]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Type = "void (int)";
            HI.Definition = "void foo(int)";
            HI.Documentation = "Function definition via pointer";
            HI.ReturnType = "void";
            HI.Parameters = {
                {std::string("int"), llvm::None, llvm::None},
            };
          }},
      {
          R"cpp(// Function declaration via call
            int foo(int);
            int main() {
              return ^[[foo]](42);
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Type = "int (int)";
            HI.Definition = "int foo(int)";
            HI.Documentation = "Function declaration via call";
            HI.ReturnType = "int";
            HI.Parameters = {
                {std::string("int"), llvm::None, llvm::None},
            };
          }},
      {
          R"cpp(// Field
            struct Foo { int x; };
            int main() {
              Foo bar;
              (void)bar.^[[x]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "int x";
          }},
      {
          R"cpp(// Field with initialization
            struct Foo { int x = 5; };
            int main() {
              Foo bar;
              (void)bar.^[[x]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "int x = 5";
          }},
      {
          R"cpp(// Static field
            struct Foo { static int x; };
            int main() {
              (void)Foo::^[[x]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::StaticProperty;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "static int x";
          }},
      {
          R"cpp(// Field, member initializer
            struct Foo {
              int x;
              Foo() : ^[[x]](0) {}
            };
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "int x";
          }},
      {
          R"cpp(// Field, GNU old-style field designator
            struct Foo { int x; };
            int main() {
              Foo bar = { ^[[x]] : 1 };
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "int x";
            // FIXME: Initializer for x is a DesignatedInitListExpr, hence it is
            // of struct type and omitted.
          }},
      {
          R"cpp(// Field, field designator
            struct Foo { int x; int y; };
            int main() {
              Foo bar = { .^[[x]] = 2, .y = 2 };
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int";
            HI.Definition = "int x";
          }},
      {
          R"cpp(// Method call
            struct Foo { int x(); };
            int main() {
              Foo bar;
              bar.^[[x]]();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::InstanceMethod;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int ()";
            HI.Definition = "int x()";
            HI.ReturnType = "int";
            HI.Parameters = std::vector<HoverInfo::Param>{};
          }},
      {
          R"cpp(// Static method call
            struct Foo { static int x(); };
            int main() {
              Foo::^[[x]]();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "x";
            HI.Kind = index::SymbolKind::StaticMethod;
            HI.NamespaceScope = "";
            HI.LocalScope = "Foo::";
            HI.Type = "int ()";
            HI.Definition = "static int x()";
            HI.ReturnType = "int";
            HI.Parameters = std::vector<HoverInfo::Param>{};
          }},
      {
          R"cpp(// Typedef
            typedef int Foo;
            int main() {
              ^[[Foo]] bar;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "Foo";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.NamespaceScope = "";
            HI.Definition = "typedef int Foo";
            HI.Documentation = "Typedef";
            // FIXME: Maybe put underlying type into HI.Type for aliases?
          }},
      {
          R"cpp(// Typedef with embedded definition
            typedef struct Bar {} Foo;
            int main() {
              ^[[Foo]] bar;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "Foo";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.NamespaceScope = "";
            HI.Definition = "typedef struct Bar Foo";
            HI.Documentation = "Typedef with embedded definition";
          }},
      {
          R"cpp(// Namespace
            namespace ns {
            struct Foo { static void bar(); };
            } // namespace ns
            int main() { ^[[ns]]::Foo::bar(); }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "ns";
            HI.Kind = index::SymbolKind::Namespace;
            HI.NamespaceScope = "";
            HI.Definition = "namespace ns {}";
          }},
      {
          R"cpp(// Anonymous namespace
            namespace ns {
              namespace {
                int foo;
              } // anonymous namespace
            } // namespace ns
            int main() { ns::[[f^oo]]++; }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "ns::";
            HI.Type = "int";
            HI.Definition = "int foo";
          }},
      {
          R"cpp(// Macro
            #define MACRO 0
            int main() { return ^[[MACRO]]; }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MACRO";
            HI.Kind = index::SymbolKind::Macro;
            HI.Definition = "#define MACRO 0";
          }},
      {
          R"cpp(// Macro
            #define MACRO 0
            #define MACRO2 ^[[MACRO]]
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MACRO";
            HI.Kind = index::SymbolKind::Macro;
            HI.Definition = "#define MACRO 0";
          }},
      {
          R"cpp(// Macro
            #define MACRO {\
              return 0;\
            }
            int main() ^[[MACRO]]
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MACRO";
            HI.Kind = index::SymbolKind::Macro;
            HI.Definition =
                R"cpp(#define MACRO                                                                  \
  { return 0; })cpp";
          }},
      {
          R"cpp(// Forward class declaration
            class Foo;
            class Foo {};
            [[F^oo]]* foo();
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "Foo";
            HI.Kind = index::SymbolKind::Class;
            HI.NamespaceScope = "";
            HI.Definition = "class Foo {}";
            HI.Documentation = "Forward class declaration";
          }},
      {
          R"cpp(// Function declaration
            void foo();
            void g() { [[f^oo]](); }
            void foo() {}
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Type = "void ()";
            HI.Definition = "void foo()";
            HI.Documentation = "Function declaration";
            HI.ReturnType = "void";
            HI.Parameters = std::vector<HoverInfo::Param>{};
          }},
      {
          R"cpp(// Enum declaration
            enum Hello {
              ONE, TWO, THREE,
            };
            void foo() {
              [[Hel^lo]] hello = ONE;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "Hello";
            HI.Kind = index::SymbolKind::Enum;
            HI.NamespaceScope = "";
            HI.Definition = "enum Hello {}";
            HI.Documentation = "Enum declaration";
          }},
      {
          R"cpp(// Enumerator
            enum Hello {
              ONE, TWO, THREE,
            };
            void foo() {
              Hello hello = [[O^NE]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "ONE";
            HI.Kind = index::SymbolKind::EnumConstant;
            HI.NamespaceScope = "";
            HI.LocalScope = "Hello::";
            HI.Type = "enum Hello";
            HI.Definition = "ONE";
            HI.Value = "0";
          }},
      {
          R"cpp(// Enumerator in anonymous enum
            enum {
              ONE, TWO, THREE,
            };
            void foo() {
              int hello = [[O^NE]];
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "ONE";
            HI.Kind = index::SymbolKind::EnumConstant;
            HI.NamespaceScope = "";
            // FIXME: This should be `(anon enum)::`
            HI.LocalScope = "";
            HI.Type = "enum (anonymous)";
            HI.Definition = "ONE";
            HI.Value = "0";
          }},
      {
          R"cpp(// Global variable
            static int hey = 10;
            void foo() {
              [[he^y]]++;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "hey";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.Type = "int";
            HI.Definition = "static int hey = 10";
            HI.Documentation = "Global variable";
            // FIXME: Value shouldn't be set in this case
            HI.Value = "10";
          }},
      {
          R"cpp(// Global variable in namespace
            namespace ns1 {
              static int hey = 10;
            }
            void foo() {
              ns1::[[he^y]]++;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "hey";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "ns1::";
            HI.Type = "int";
            HI.Definition = "static int hey = 10";
            HI.Value = "10";
          }},
      {
          R"cpp(// Field in anonymous struct
            static struct {
              int hello;
            } s;
            void foo() {
              s.[[he^llo]]++;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "hello";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "(anonymous struct)::";
            HI.Type = "int";
            HI.Definition = "int hello";
          }},
      {
          R"cpp(// Templated function
            template <typename T>
            T foo() {
              return 17;
            }
            void g() { auto x = [[f^oo]]<int>(); }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Type = "int ()";
            HI.Definition = "template <> int foo<int>()";
            HI.Documentation = "Templated function";
            HI.ReturnType = "int";
            HI.Parameters = std::vector<HoverInfo::Param>{};
            // FIXME: We should populate template parameters with arguments in
            // case of instantiations.
          }},
      {
          R"cpp(// Anonymous union
            struct outer {
              union {
                int abc, def;
              } v;
            };
            void g() { struct outer o; o.v.[[d^ef]]++; }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "def";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "";
            HI.LocalScope = "outer::(anonymous union)::";
            HI.Type = "int";
            HI.Definition = "int def";
          }},
      {
          R"cpp(// documentation from index
            int nextSymbolIsAForwardDeclFromIndexWithNoLocalDocs;
            void indexSymbol();
            void g() { [[ind^exSymbol]](); }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "indexSymbol";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Type = "void ()";
            HI.Definition = "void indexSymbol()";
            HI.ReturnType = "void";
            HI.Parameters = std::vector<HoverInfo::Param>{};
            HI.Documentation = "comment from index";
          }},
      {
          R"cpp(// Simple initialization with auto
            void foo() {
              ^[[auto]] i = 1;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with const auto
            void foo() {
              const ^[[auto]] i = 1;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with const auto&
            void foo() {
              const ^[[auto]]& i = 1;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with auto&
            void foo() {
              int x;
              ^[[auto]]& i = x;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with auto*
            void foo() {
              int a = 1;
              ^[[auto]]* i = &a;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with auto from pointer
            void foo() {
              int a = 1;
              ^[[auto]] i = &a;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int *";
          }},
      {
          R"cpp(// Auto with initializer list.
            namespace std
            {
              template<class _E>
              class initializer_list {};
            }
            void foo() {
              ^[[auto]] i = {1,2};
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "class std::initializer_list<int>";
          }},
      {
          R"cpp(// User defined conversion to auto
            struct Bar {
              operator ^[[auto]]() const { return 10; }
            };
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with decltype(auto)
            void foo() {
              ^[[decltype]](auto) i = 1;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Simple initialization with const decltype(auto)
            void foo() {
              const int j = 0;
              ^[[decltype]](auto) i = j;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "const int";
          }},
      {
          R"cpp(// Simple initialization with const& decltype(auto)
            void foo() {
              int k = 0;
              const int& j = k;
              ^[[decltype]](auto) i = j;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "const int &";
          }},
      {
          R"cpp(// Simple initialization with & decltype(auto)
            void foo() {
              int k = 0;
              int& j = k;
              ^[[decltype]](auto) i = j;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &";
          }},
      {
          R"cpp(// simple trailing return type
            ^[[auto]] main() -> int {
              return 0;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// auto function return with trailing type
            struct Bar {};
            ^[[auto]] test() -> decltype(Bar()) {
              return Bar();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "auto function return with trailing type";
          }},
      {
          R"cpp(// trailing return type
            struct Bar {};
            auto test() -> ^[[decltype]](Bar()) {
              return Bar();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "trailing return type";
          }},
      {
          R"cpp(// auto in function return
            struct Bar {};
            ^[[auto]] test() {
              return Bar();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "auto in function return";
          }},
      {
          R"cpp(// auto& in function return
            struct Bar {};
            ^[[auto]]& test() {
              static Bar x;
              return x;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "auto& in function return";
          }},
      {
          R"cpp(// auto* in function return
            struct Bar {};
            ^[[auto]]* test() {
              Bar* bar;
              return bar;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "auto* in function return";
          }},
      {
          R"cpp(// const auto& in function return
            struct Bar {};
            const ^[[auto]]& test() {
              static Bar x;
              return x;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "const auto& in function return";
          }},
      {
          R"cpp(// decltype(auto) in function return
            struct Bar {};
            ^[[decltype]](auto) test() {
              return Bar();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation = "decltype(auto) in function return";
          }},
      {
          R"cpp(// decltype(auto) reference in function return
            ^[[decltype]](auto) test() {
              static int a;
              return (a);
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &";
          }},
      {
          R"cpp(// decltype lvalue reference
            void foo() {
              int I = 0;
              ^[[decltype]](I) J = I;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// decltype lvalue reference
            void foo() {
              int I= 0;
              int &K = I;
              ^[[decltype]](K) J = I;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &";
          }},
      {
          R"cpp(// decltype lvalue reference parenthesis
            void foo() {
              int I = 0;
              ^[[decltype]]((I)) J = I;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &";
          }},
      {
          R"cpp(// decltype rvalue reference
            void foo() {
              int I = 0;
              ^[[decltype]](static_cast<int&&>(I)) J = static_cast<int&&>(I);
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &&";
          }},
      {
          R"cpp(// decltype rvalue reference function call
            int && bar();
            void foo() {
              int I = 0;
              ^[[decltype]](bar()) J = bar();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int &&";
          }},
      {
          R"cpp(// decltype of function with trailing return type.
            struct Bar {};
            auto test() -> decltype(Bar()) {
              return Bar();
            }
            void foo() {
              ^[[decltype]](test()) i = test();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct Bar";
            HI.Documentation =
                "decltype of function with trailing return type.";
          }},
      {
          R"cpp(// decltype of var with decltype.
            void foo() {
              int I = 0;
              decltype(I) J = I;
              ^[[decltype]](J) K = J;
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// decltype of dependent type
            template <typename T>
            struct X {
              using Y = ^[[decltype]](T::Z);
            };
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "<dependent type>";
          }},
      {
          R"cpp(// More complicated structured types.
            int bar();
            ^[[auto]] (*foo)() = bar;
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// Should not crash when evaluating the initializer.
            struct Test {};
            void test() { Test && [[te^st]] = {}; }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "test";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.LocalScope = "test::";
            HI.Type = "struct Test &&";
            HI.Definition = "Test &&test = {}";
          }},
      {
          R"cpp(// auto on alias
          typedef int int_type;
          ^[[auto]] x = int_type();
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "int";
          }},
      {
          R"cpp(// auto on alias
          struct cls {};
          typedef cls cls_type;
          ^[[auto]] y = cls_type();
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct cls";
            HI.Documentation = "auto on alias";
          }},
      {
          R"cpp(// auto on alias
          template <class>
          struct templ {};
          ^[[auto]] z = templ<int>();
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "struct templ<int>";
            HI.Documentation = "auto on alias";
          }},
      {
          R"cpp(// Undeduced auto declaration
            template<typename T>
            void foo() {
              ^[[auto]] x = T();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "/* not deduced */";
          }},
      {
          R"cpp(// Undeduced auto return type
            template<typename T>
            ^[[auto]] foo() {
              return T();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "/* not deduced */";
          }},
      {
          R"cpp(// Template auto parameter
            template<[[a^uto]] T>
              void func() {
            }
          )cpp",
          [](HoverInfo &HI) {
            // FIXME: not sure this is what we want, but this
            // is what we currently get with getDeducedType
            HI.Name = "auto";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "/* not deduced */";
          }},
      {
          R"cpp(// Undeduced decltype(auto) return type
            template<typename T>
            ^[[decltype]](auto) foo() {
              return T();
            }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "decltype";
            HI.Kind = index::SymbolKind::TypeAlias;
            HI.Definition = "/* not deduced */";
          }},
      {
          R"cpp(// should not crash.
          template <class T> struct cls {
            int method();
          };

          auto test = cls<int>().[[m^ethod]]();
          )cpp",
          [](HoverInfo &HI) {
            HI.Definition = "int method()";
            HI.Kind = index::SymbolKind::InstanceMethod;
            HI.NamespaceScope = "";
            HI.LocalScope = "cls<int>::";
            HI.Name = "method";
            HI.Parameters.emplace();
            HI.ReturnType = "int";
            HI.Type = "int ()";
          }},
      {
          R"cpp(// type of nested templates.
          template <class T> struct cls {};
          cls<cls<cls<int>>> [[fo^o]];
          )cpp",
          [](HoverInfo &HI) {
            HI.Definition = "cls<cls<cls<int>>> foo";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.Name = "foo";
            HI.Type = "cls<cls<cls<int>>>";
          }},
      {
          R"cpp(// type of nested templates.
          template <class T> struct cls {};
          [[cl^s]]<cls<cls<int>>> foo;
          )cpp",
          [](HoverInfo &HI) {
            HI.Definition = "template <> struct cls<cls<cls<int>>> {}";
            HI.Kind = index::SymbolKind::Struct;
            HI.NamespaceScope = "";
            HI.Name = "cls<cls<cls<int>>>";
            HI.Documentation = "type of nested templates.";
          }},
      {
          R"cpp(// type with decltype
          int a;
          decltype(a) [[b^]] = a;)cpp",
          [](HoverInfo &HI) {
            HI.Definition = "decltype(a) b = a";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.Name = "b";
            HI.Type = "int";
          }},
      {
          R"cpp(// type with decltype
          int a;
          decltype(a) c;
          decltype(c) [[b^]] = a;)cpp",
          [](HoverInfo &HI) {
            HI.Definition = "decltype(c) b = a";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.Name = "b";
            HI.Type = "int";
          }},
      {
          R"cpp(// type with decltype
          int a;
          const decltype(a) [[b^]] = a;)cpp",
          [](HoverInfo &HI) {
            HI.Definition = "const decltype(a) b = a";
            HI.Kind = index::SymbolKind::Variable;
            HI.NamespaceScope = "";
            HI.Name = "b";
            HI.Type = "int";
          }},
      {
          R"cpp(// type with decltype
          int a;
          auto [[f^oo]](decltype(a) x) -> decltype(a) { return 0; })cpp",
          [](HoverInfo &HI) {
            HI.Definition = "auto foo(decltype(a) x) -> decltype(a)";
            HI.Kind = index::SymbolKind::Function;
            HI.NamespaceScope = "";
            HI.Name = "foo";
            // FIXME: Handle composite types with decltype with a printing
            // policy.
            HI.Type = "auto (decltype(a)) -> decltype(a)";
            HI.ReturnType = "int";
            HI.Parameters = {
                {std::string("int"), std::string("x"), llvm::None}};
          }},
      {
          R"cpp(// sizeof expr
          void foo() {
            (void)[[size^of]](char);
          })cpp",
          [](HoverInfo &HI) {
            HI.Name = "expression";
            HI.Type = "unsigned long";
            HI.Value = "1";
          }},
      {
          R"cpp(// alignof expr
          void foo() {
            (void)[[align^of]](char);
          })cpp",
          [](HoverInfo &HI) {
            HI.Name = "expression";
            HI.Type = "unsigned long";
            HI.Value = "1";
          }},
      {
          R"cpp(
          template <typename T = int>
          void foo(const T& = T()) {
            [[f^oo]]<>(3);
          })cpp",
          [](HoverInfo &HI) {
            HI.Name = "foo";
            HI.Kind = index::SymbolKind::Function;
            HI.Type = "void (const int &)";
            HI.ReturnType = "void";
            HI.Parameters = {
                {std::string("const int &"), llvm::None, std::string("T()")}};
            HI.Definition = "template <> void foo<int>(const int &)";
            HI.NamespaceScope = "";
          }},
      {
          R"cpp(// should not crash
           @interface ObjC {
             char [[da^ta]];
           }@end
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "data";
            HI.Type = "char";
            HI.Kind = index::SymbolKind::Field;
            HI.NamespaceScope = "ObjC::"; // FIXME: fix it
            HI.Definition = "char data";
          }},
      {
          R"cpp(
          @interface MYObject
          @end
          @interface Interface
          @property(retain) [[MYOb^ject]] *x;
          @end
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MYObject";
            HI.Kind = index::SymbolKind::Class;
            HI.NamespaceScope = "";
            HI.Definition = "@interface MYObject\n@end";
          }},
      {
          R"cpp(
          @interface MYObject
          @end
          @interface Interface
          - (void)doWith:([[MYOb^ject]] *)object;
          @end
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "MYObject";
            HI.Kind = index::SymbolKind::Class;
            HI.NamespaceScope = "";
            HI.Definition = "@interface MYObject\n@end";
          }},
      {
          R"cpp(// this expr
          // comment
          namespace ns {
            class Foo {
              Foo* bar() {
                return [[t^his]];
              }
            };
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "this";
            HI.Definition = "Foo *";
          }},
      {
          R"cpp(// this expr for template class
          namespace ns {
            template <typename T>
            class Foo {
              Foo* bar() const {
                return [[t^his]];
              }
            };
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "this";
            HI.Definition = "const Foo<T> *";
          }},
      {
          R"cpp(// this expr for specialization class
          namespace ns {
            template <typename T> class Foo {};
            template <>
            struct Foo<int> {
              Foo* bar() {
                return [[thi^s]];
              }
            };
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "this";
            HI.Definition = "Foo<int> *";
          }},
      {
          R"cpp(// this expr for partial specialization struct
          namespace ns {
            template <typename T, typename F> struct Foo {};
            template <typename F>
            struct Foo<int, F> {
              Foo* bar() const {
                return [[thi^s]];
              }
            };
          }
          )cpp",
          [](HoverInfo &HI) {
            HI.Name = "this";
            HI.Definition = "const Foo<int, F> *";
          }},
  };

  // Create a tiny index, so tests above can verify documentation is fetched.
  Symbol IndexSym = func("indexSymbol");
  IndexSym.Documentation = "comment from index";
  SymbolSlab::Builder Symbols;
  Symbols.insert(IndexSym);
  auto Index =
      MemIndex::build(std::move(Symbols).build(), RefSlab(), RelationSlab());

  for (const auto &Case : Cases) {
    SCOPED_TRACE(Case.Code);

    Annotations T(Case.Code);
    TestTU TU = TestTU::withCode(T.code());
    TU.ExtraArgs.push_back("-std=c++17");
    TU.ExtraArgs.push_back("-xobjective-c++");

    TU.ExtraArgs.push_back("-Wno-gnu-designator");
    // Types might be different depending on the target triplet, we chose a
    // fixed one to make sure tests passes on different platform.
    TU.ExtraArgs.push_back("--target=x86_64-pc-linux-gnu");
    auto AST = TU.build();

    auto H = getHover(AST, T.point(), format::getLLVMStyle(), Index.get());
    ASSERT_TRUE(H);
    HoverInfo Expected;
    Expected.SymRange = T.range();
    Case.ExpectedBuilder(Expected);

    SCOPED_TRACE(H->present().asPlainText());
    EXPECT_EQ(H->NamespaceScope, Expected.NamespaceScope);
    EXPECT_EQ(H->LocalScope, Expected.LocalScope);
    EXPECT_EQ(H->Name, Expected.Name);
    EXPECT_EQ(H->Kind, Expected.Kind);
    EXPECT_EQ(H->Documentation, Expected.Documentation);
    EXPECT_EQ(H->Definition, Expected.Definition);
    EXPECT_EQ(H->Type, Expected.Type);
    EXPECT_EQ(H->ReturnType, Expected.ReturnType);
    EXPECT_EQ(H->Parameters, Expected.Parameters);
    EXPECT_EQ(H->TemplateParameters, Expected.TemplateParameters);
    EXPECT_EQ(H->SymRange, Expected.SymRange);
    EXPECT_EQ(H->Value, Expected.Value);
  }
}

TEST(Hover, DocsFromIndex) {
  Annotations T(R"cpp(
  template <typename T> class X {};
  void foo() {
    auto t = X<int>();
    X^<int> w;
    (void)w;
  })cpp");

  TestTU TU = TestTU::withCode(T.code());
  auto AST = TU.build();
  Symbol IndexSym;
  IndexSym.ID = getSymbolID(&findDecl(AST, "X"));
  IndexSym.Documentation = "comment from index";
  SymbolSlab::Builder Symbols;
  Symbols.insert(IndexSym);
  auto Index =
      MemIndex::build(std::move(Symbols).build(), RefSlab(), RelationSlab());

  for (const auto &P : T.points()) {
    auto H = getHover(AST, P, format::getLLVMStyle(), Index.get());
    ASSERT_TRUE(H);
    EXPECT_EQ(H->Documentation, IndexSym.Documentation);
  }
}

TEST(Hover, DocsFromAST) {
  Annotations T(R"cpp(
  // doc
  template <typename T> class X {};
  // doc
  template <typename T> void bar() {}
  // doc
  template <typename T> T baz;
  void foo() {
    au^to t = X<int>();
    X^<int>();
    b^ar<int>();
    au^to T = ba^z<X<int>>;
    ba^z<int> = 0;
  })cpp");

  TestTU TU = TestTU::withCode(T.code());
  auto AST = TU.build();
  for (const auto &P : T.points()) {
    auto H = getHover(AST, P, format::getLLVMStyle(), nullptr);
    ASSERT_TRUE(H);
    EXPECT_EQ(H->Documentation, "doc");
  }
}

TEST(Hover, DocsFromMostSpecial) {
  Annotations T(R"cpp(
  // doc1
  template <typename T> class $doc1^X {};
  // doc2
  template <> class $doc2^X<int> {};
  // doc3
  template <typename T> class $doc3^X<T*> {};
  void foo() {
    X$doc1^<char>();
    X$doc2^<int>();
    X$doc3^<int*>();
  })cpp");

  TestTU TU = TestTU::withCode(T.code());
  auto AST = TU.build();
  for (auto Comment : {"doc1", "doc2", "doc3"}) {
    for (const auto &P : T.points(Comment)) {
      auto H = getHover(AST, P, format::getLLVMStyle(), nullptr);
      ASSERT_TRUE(H);
      EXPECT_EQ(H->Documentation, Comment);
    }
  }
}

TEST(Hover, Present) {
  struct {
    const std::function<void(HoverInfo &)> Builder;
    llvm::StringRef ExpectedRender;
  } Cases[] = {
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Unknown;
            HI.Name = "X";
          },
          R"(X)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::NamespaceAlias;
            HI.Name = "foo";
          },
          R"(namespace-alias foo)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Class;
            HI.Size = 10;
            HI.TemplateParameters = {
                {std::string("typename"), std::string("T"), llvm::None},
                {std::string("typename"), std::string("C"),
                 std::string("bool")},
            };
            HI.Documentation = "documentation";
            HI.Definition =
                "template <typename T, typename C = bool> class Foo {}";
            HI.Name = "foo";
            HI.NamespaceScope.emplace();
          },
          R"(class foo

Size: 10 bytes
documentation

template <typename T, typename C = bool> class Foo {})",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Function;
            HI.Name = "foo";
            HI.Type = "type";
            HI.ReturnType = "ret_type";
            HI.Parameters.emplace();
            HoverInfo::Param P;
            HI.Parameters->push_back(P);
            P.Type = "type";
            HI.Parameters->push_back(P);
            P.Name = "foo";
            HI.Parameters->push_back(P);
            P.Default = "default";
            HI.Parameters->push_back(P);
            HI.NamespaceScope = "ns::";
            HI.Definition = "ret_type foo(params) {}";
          },
          "function foo\n"
          "\n"
          "→ ret_type\n"
          "Parameters:\n"
          "- \n"
          "- type\n"
          "- type foo\n"
          "- type foo = default\n"
          "\n"
          "// In namespace ns\n"
          "ret_type foo(params) {}",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Field;
            HI.LocalScope = "test::Bar::";
            HI.Value = "value";
            HI.Name = "foo";
            HI.Type = "type";
            HI.Definition = "def";
            HI.Size = 4;
            HI.Offset = 12;
          },
          R"(field foo

Type: type
Value = value
Offset: 12 bytes
Size: 4 bytes

// In test::Bar
def)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Field;
            HI.AccessSpecifier = "public";
            HI.Name = "foo";
            HI.LocalScope = "test::Bar::";
            HI.Definition = "def";
          },
          R"(field foo

// In test::Bar
public: def)",
      },
      {
          [](HoverInfo &HI) {
            HI.Definition = "int method()";
            HI.AccessSpecifier = "protected";
            HI.Kind = index::SymbolKind::InstanceMethod;
            HI.NamespaceScope = "";
            HI.LocalScope = "cls<int>::";
            HI.Name = "method";
            HI.Parameters.emplace();
            HI.ReturnType = "int";
            HI.Type = "int ()";
          },
          R"(instance-method method

→ int

// In cls<int>
protected: int method())",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Union;
            HI.AccessSpecifier = "private";
            HI.Name = "foo";
            HI.NamespaceScope = "ns1::";
            HI.Definition = "union foo {}";
          },
          R"(union foo

// In namespace ns1
private: union foo {})",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Variable;
            HI.Name = "foo";
            HI.Definition = "int foo = 3";
            HI.LocalScope = "test::Bar::";
            HI.Value = "3";
            HI.Type = "int";
            HI.CalleeArgInfo.emplace();
            HI.CalleeArgInfo->Name = "arg_a";
            HI.CalleeArgInfo->Type = "int";
            HI.CalleeArgInfo->Default = "7";
            HI.CallPassType.emplace();
            HI.CallPassType->PassBy = PassMode::Value;
            HI.CallPassType->Converted = false;
          },
          R"(variable foo

Type: int
Value = 3
Passed as arg_a

// In test::Bar
int foo = 3)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Variable;
            HI.Name = "foo";
            HI.Definition = "int foo = 3";
            HI.LocalScope = "test::Bar::";
            HI.Value = "3";
            HI.Type = "int";
            HI.CalleeArgInfo.emplace();
            HI.CalleeArgInfo->Name = "arg_a";
            HI.CalleeArgInfo->Type = "int";
            HI.CalleeArgInfo->Default = "7";
            HI.CallPassType.emplace();
            HI.CallPassType->PassBy = PassMode::Ref;
            HI.CallPassType->Converted = false;
          },
          R"(variable foo

Type: int
Value = 3
Passed by reference as arg_a

// In test::Bar
int foo = 3)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Variable;
            HI.Name = "foo";
            HI.Definition = "int foo = 3";
            HI.LocalScope = "test::Bar::";
            HI.Value = "3";
            HI.Type = "int";
            HI.CalleeArgInfo.emplace();
            HI.CalleeArgInfo->Name = "arg_a";
            HI.CalleeArgInfo->Type = "int";
            HI.CalleeArgInfo->Default = "7";
            HI.CallPassType.emplace();
            HI.CallPassType->PassBy = PassMode::Value;
            HI.CallPassType->Converted = true;
          },
          R"(variable foo

Type: int
Value = 3
Passed as arg_a (converted to int)

// In test::Bar
int foo = 3)",
      },
      {
          [](HoverInfo &HI) {
            HI.Kind = index::SymbolKind::Variable;
            HI.Name = "foo";
            HI.Definition = "int foo = 3";
            HI.LocalScope = "test::Bar::";
            HI.Value = "3";
            HI.Type = "int";
            HI.CalleeArgInfo.emplace();
            HI.CalleeArgInfo->Name = "arg_a";
            HI.CalleeArgInfo->Type = "int";
            HI.CalleeArgInfo->Default = "7";
            HI.CallPassType.emplace();
            HI.CallPassType->PassBy = PassMode::ConstRef;
            HI.CallPassType->Converted = true;
          },
          R"(variable foo

Type: int
Value = 3
Passed by const reference as arg_a (converted to int)

// In test::Bar
int foo = 3)",
      }};

  for (const auto &C : Cases) {
    HoverInfo HI;
    C.Builder(HI);
    EXPECT_EQ(HI.present().asPlainText(), C.ExpectedRender);
  }
}

TEST(Hover, ParseDocumentation) {
  struct Case {
    llvm::StringRef Documentation;
    llvm::StringRef ExpectedRenderMarkdown;
    llvm::StringRef ExpectedRenderPlainText;
  } Cases[] = {{
                   " \n foo\nbar",
                   "foo bar",
                   "foo bar",
               },
               {
                   "foo\nbar \n  ",
                   "foo bar",
                   "foo bar",
               },
               {
                   "foo  \nbar",
                   "foo bar",
                   "foo bar",
               },
               {
                   "foo    \nbar",
                   "foo bar",
                   "foo bar",
               },
               {
                   "foo\n\n\nbar",
                   "foo  \nbar",
                   "foo\nbar",
               },
               {
                   "foo\n\n\n\tbar",
                   "foo  \nbar",
                   "foo\nbar",
               },
               {
                   "foo\n\n\n bar",
                   "foo  \nbar",
                   "foo\nbar",
               },
               {
                   "foo.\nbar",
                   "foo.  \nbar",
                   "foo.\nbar",
               },
               {
                   "foo. \nbar",
                   "foo.  \nbar",
                   "foo.\nbar",
               },
               {
                   "foo\n*bar",
                   "foo  \n\\*bar",
                   "foo\n*bar",
               },
               {
                   "foo\nbar",
                   "foo bar",
                   "foo bar",
               },
               {
                   "Tests primality of `p`.",
                   "Tests primality of `p`.",
                   "Tests primality of `p`.",
               },
               {
                   "'`' should not occur in `Code`",
                   "'\\`' should not occur in `Code`",
                   "'`' should not occur in `Code`",
               },
               {
                   "`not\nparsed`",
                   "\\`not parsed\\`",
                   "`not parsed`",
               }};

  for (const auto &C : Cases) {
    markup::Document Output;
    parseDocumentation(C.Documentation, Output);

    EXPECT_EQ(Output.asMarkdown(), C.ExpectedRenderMarkdown);
    EXPECT_EQ(Output.asPlainText(), C.ExpectedRenderPlainText);
  }
}

// This is a separate test as headings don't create any differences in plaintext
// mode.
TEST(Hover, PresentHeadings) {
  HoverInfo HI;
  HI.Kind = index::SymbolKind::Variable;
  HI.Name = "foo";

  EXPECT_EQ(HI.present().asMarkdown(), "### variable `foo`");
}

// This is a separate test as rulers behave differently in markdown vs
// plaintext.
TEST(Hover, PresentRulers) {
  HoverInfo HI;
  HI.Kind = index::SymbolKind::Variable;
  HI.Name = "foo";
  HI.Value = "val";
  HI.Definition = "def";

  llvm::StringRef ExpectedMarkdown = //
      "### variable `foo`  \n"
      "\n"
      "---\n"
      "Value = `val`  \n"
      "\n"
      "---\n"
      "```cpp\n"
      "def\n"
      "```";
  EXPECT_EQ(HI.present().asMarkdown(), ExpectedMarkdown);

  llvm::StringRef ExpectedPlaintext = R"pt(variable foo

Value = val

def)pt";
  EXPECT_EQ(HI.present().asPlainText(), ExpectedPlaintext);
}
} // namespace
} // namespace clangd
} // namespace clang
