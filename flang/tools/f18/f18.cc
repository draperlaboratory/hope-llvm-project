// Temporary Fortran front end driver main program for development scaffolding.

#include "../../lib/parser/basic-parsers.h"
#include "../../lib/parser/char-buffer.h"
#include "../../lib/parser/cooked-chars.h"
#include "../../lib/parser/grammar.h"
#include "../../lib/parser/idioms.h"
#include "../../lib/parser/message.h"
#include "../../lib/parser/parse-tree.h"
#include "../../lib/parser/preprocessor.h"
#include "../../lib/parser/prescan.h"
#include "../../lib/parser/provenance.h"
#include "../../lib/parser/user-state.h"
#include <cerrno>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <limits>
#include <list>
#include <memory>
#include <optional>
#include <sstream>
#include <string>
#include <unistd.h>

namespace {

std::list<std::string> argList(int argc, char *const argv[]) {
  std::list<std::string> result;
  for (int j = 0; j < argc; ++j) {
    result.emplace_back(argv[j]);
  }
  return result;
}

}  // namespace

namespace Fortran {
namespace parser {
constexpr auto grammar = program;
}  // namespace parser
}  // namespace Fortran
using Fortran::parser::grammar;

int main(int argc, char *const argv[]) {

  auto args = argList(argc, argv);
  std::string progName{args.front()};
  args.pop_front();

  bool dumpCookedChars{false};
  bool fixedForm{false};
  bool backslashEscapes{true};
  bool standard{false};
  bool enableOldDebugLines{false};
  int columns{72};

  Fortran::parser::AllSources allSources;

  while (!args.empty()) {
    if (args.front().empty()) {
      args.pop_front();
    } else if (args.front().at(0) != '-' || args.front() == "-") {
      break;
    } else if (args.front() == "--") {
      args.pop_front();
      break;
    } else {
      std::string flag{std::move(args.front())};
      args.pop_front();
      if (flag == "-Mfixed") {
        fixedForm = true;
      } else if (flag == "-Mbackslash") {
        backslashEscapes = false;
      } else if (flag == "-Mstandard") {
        standard = false;
      } else if (flag == "-Mextend") {
        columns = 132;
      } else if (flag == "-fdebug-dump-cooked-chars") {
        dumpCookedChars = true;
      } else if (flag == "-ed") {
        enableOldDebugLines = true;
      } else if (flag == "-I") {
        allSources.PushSearchPathDirectory(args.front());
        args.pop_front();
      } else if (flag.substr(0, 2) == "-I") {
        allSources.PushSearchPathDirectory(flag.substr(2, std::string::npos));
      } else {
        std::cerr << "unknown flag: '" << flag << "'\n";
        return 1;
      }
    }
  }

  std::string path{"-"};
  if (!args.empty()) {
    path = std::move(args.front());
    args.pop_front();
    if (!args.empty()) {
      std::cerr << "multiple input files\n";
      ;
      return 1;
    }
  }

  std::stringstream error;
  const auto *sourceFile = allSources.Open(path, &error);
  if (!sourceFile) {
    std::cerr << error.str() << '\n';
    return 1;
  }

  Fortran::parser::ProvenanceRange range{allSources.AddIncludedFile(
      *sourceFile, Fortran::parser::ProvenanceRange{})};
  Fortran::parser::Messages messages{allSources};
  Fortran::parser::CookedSource cooked{&allSources};
  Fortran::parser::Preprocessor preprocessor{&allSources};
  Fortran::parser::Prescanner prescanner{&messages, &cooked, &preprocessor};
  bool prescanOk{prescanner.set_fixedForm(fixedForm)
                     .set_enableBackslashEscapesInCharLiterals(backslashEscapes)
                     .set_fixedFormColumnLimit(columns)
                     .set_enableOldDebugLines(enableOldDebugLines)
                     .Prescan(range)};
  messages.Emit(std::cerr);
  if (!prescanOk) {
    return 1;
  }
  columns = std::numeric_limits<int>::max();

  cooked.Marshal();
  Fortran::parser::ParseState state{cooked};
  state.set_inFixedForm(fixedForm);
  state.set_enableBackslashEscapesInCharLiterals(backslashEscapes);
  state.set_strictConformance(standard);
  state.set_columns(columns);
  state.set_enableOldDebugLines(enableOldDebugLines);
  Fortran::parser::UserState ustate;
  state.set_userState(&ustate);

  if (dumpCookedChars) {
    while (std::optional<char> och{
        Fortran::parser::cookedNextChar.Parse(&state)}) {
      std::cout << *och;
    }
    return 0;
  }

  std::optional<typename decltype(grammar)::resultType> result;
#if 0
  for (int j = 0; j < 1000; ++j) {
    Fortran::parser::ParseState state1{state};
    result = grammar.Parse(&state1);
    if (!result) {
      std::cerr << "demo FAIL in timing loop\n";
      break;
    }
  }
#endif
  result = grammar.Parse(&state);
  if (result.has_value() && !state.anyErrorRecovery()) {
    std::cout << "demo PASS\n" << *result << '\n';
  } else {
    std::cerr << "demo FAIL\n";
    if (!state.IsAtEnd()) {
      std::cerr << "final position: ";
      allSources.Identify(std::cerr, state.GetProvenance(), "   ");
    }
    state.messages()->Emit(std::cerr);
    return EXIT_FAILURE;
  }
}
