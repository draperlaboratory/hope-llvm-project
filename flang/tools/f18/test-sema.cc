#include "../../lib/parser/grammar.h"
#include "../../lib/parser/idioms.h"
#include "../../lib/parser/indirection.h"
#include "../../lib/parser/message.h"
#include "../../lib/parser/parse-state.h"
#include "../../lib/parser/parse-tree.h"
#include "../../lib/parser/preprocessor.h"
#include "../../lib/parser/prescan.h"
#include "../../lib/parser/provenance.h"
#include "../../lib/parser/source.h"
#include "../../lib/parser/user-state.h"
#include "../../lib/semantics/attr.h"
#include "../../lib/semantics/type.h"
#include <cstdlib>
#include <iostream>
#include <list>
#include <optional>
#include <sstream>
#include <string>
#include <stddef.h>

using namespace Fortran;
using namespace parser;

extern void DoSemanticAnalysis(const Program &);

//static void visitProgramUnit(const ProgramUnit &unit);

int main(int argc, char *const argv[]) {
  if (argc != 2) {
    std::cerr << "Expected 1 source file, got " << (argc - 1) << "\n";
    return EXIT_FAILURE;
  }

  std::string path{argv[1]};
  AllSources allSources;
  std::stringstream error;
  const auto *sourceFile = allSources.Open(path, &error);
  if (!sourceFile) {
    std::cerr << error.str() << '\n';
    return 1;
  }

  ProvenanceRange range{allSources.AddIncludedFile(
      *sourceFile, ProvenanceRange{})};
  Messages messages{allSources};
  CookedSource cooked{&allSources};
  Preprocessor preprocessor{&allSources};
  bool prescanOk{Prescanner{&messages, &cooked, &preprocessor}.Prescan(range)};
  messages.Emit(std::cerr);
  if (!prescanOk) {
    return EXIT_FAILURE;
  }
  cooked.Marshal();
  ParseState state{cooked};
  UserState ustate;
  std::optional<Program> result{program.Parse(&state)};
  if (!result.has_value() || state.anyErrorRecovery()) {
    std::cerr << "parse FAILED\n";
    state.messages()->Emit(std::cerr);
    return EXIT_FAILURE;
  }
  DoSemanticAnalysis(*result) ;
  return EXIT_SUCCESS;
}
