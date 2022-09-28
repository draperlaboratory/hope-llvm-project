#include "llvm/CodeGen/MachineInstr.h"
#include "RISCV.h"
#include "RISCVAsmPrinter.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCStreamer.h"

using namespace llvm;

class ISPAsmPrinter : public RISCVAsmPrinter {
  
public:
  explicit ISPAsmPrinter(TargetMachine &TM,
			 std::unique_ptr<MCStreamer> Streamer)
    : RISCVAsmPrinter(TM, std::move(Streamer)) {}
  
  void EmitFnRangeMetadata(MCSymbol *begin, MCSymbol *end);

  void EmitInstruction(const MachineInstr *MI) override;
};
