//===-- VEInstPrinter.h - Convert VE MCInst to assembly syntax ------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This class prints an VE MCInst to a .s file.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_VE_INSTPRINTER_VEINSTPRINTER_H
#define LLVM_LIB_TARGET_VE_INSTPRINTER_VEINSTPRINTER_H

#include "VEMCTargetDesc.h"
#include "llvm/MC/MCInstPrinter.h"

namespace llvm {

class VEInstPrinter : public MCInstPrinter {
public:
  VEInstPrinter(const MCAsmInfo &MAI, const MCInstrInfo &MII,
                const MCRegisterInfo &MRI)
      : MCInstPrinter(MAI, MII, MRI) {}

  void printRegName(raw_ostream &OS, unsigned RegNo) const override;
  void printInst(const MCInst *MI, uint64_t Address, StringRef Annot,
                 const MCSubtargetInfo &STI, raw_ostream &OS) override;

  // Autogenerated by tblgen.
  bool printAliasInstr(const MCInst *, uint64_t Address,
                       const MCSubtargetInfo &, raw_ostream &);
  void printInstruction(const MCInst *, uint64_t, const MCSubtargetInfo &,
                        raw_ostream &);
  static const char *getRegisterName(unsigned RegNo,
                                     unsigned AltIdx = VE::NoRegAltName);

  void printOperand(const MCInst *MI, int OpNum, const MCSubtargetInfo &STI,
                    raw_ostream &OS);
  void printMemASXOperand(const MCInst *MI, int OpNum,
                          const MCSubtargetInfo &STI, raw_ostream &OS,
                          const char *Modifier = nullptr);
  void printMemASOperandASX(const MCInst *MI, int OpNum,
                            const MCSubtargetInfo &STI, raw_ostream &OS,
                            const char *Modifier = nullptr);
  void printMemASOperand(const MCInst *MI, int OpNum,
                         const MCSubtargetInfo &STI, raw_ostream &OS,
                         const char *Modifier = nullptr);
  void printMImmOperand(const MCInst *MI, int OpNum, const MCSubtargetInfo &STI,
                        raw_ostream &OS);
  void printCCOperand(const MCInst *MI, int OpNum, const MCSubtargetInfo &STI,
                      raw_ostream &OS);
};
} // namespace llvm

#endif
