//===-- RISCVELFStreamer.cpp - RISCV ELF Target Streamer Methods ----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides RISCV specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "RISCVELFStreamer.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "MCTargetDesc/RISCVAsmBackend.h"
#include "RISCVMCTargetDesc.h"
#include "Utils/RISCVBaseInfo.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCObjectFileInfo.h"

using namespace llvm;

// This part is for ELF object output.
RISCVTargetELFStreamer::RISCVTargetELFStreamer(MCStreamer &S,
                                               const MCSubtargetInfo &STI)
    : RISCVTargetStreamer(S) {
  MCAssembler &MCA = getStreamer().getAssembler();
  const FeatureBitset &Features = STI.getFeatureBits();
  auto &MAB = static_cast<RISCVAsmBackend &>(MCA.getBackend());
  RISCVABI::ABI ABI = MAB.getTargetABI();
  assert(ABI != RISCVABI::ABI_Unknown && "Improperly initialised target ABI");

  ISPSecInitialized = false;
  
  unsigned EFlags = MCA.getELFHeaderEFlags();

  if (Features[RISCV::FeatureStdExtC])
    EFlags |= ELF::EF_RISCV_RVC;

  switch (ABI) {
  case RISCVABI::ABI_ILP32:
  case RISCVABI::ABI_LP64:
    break;
  case RISCVABI::ABI_ILP32F:
  case RISCVABI::ABI_LP64F:
    EFlags |= ELF::EF_RISCV_FLOAT_ABI_SINGLE;
    break;
  case RISCVABI::ABI_ILP32D:
  case RISCVABI::ABI_LP64D:
    EFlags |= ELF::EF_RISCV_FLOAT_ABI_DOUBLE;
    break;
  case RISCVABI::ABI_ILP32E:
    EFlags |= ELF::EF_RISCV_RVE;
    break;
  case RISCVABI::ABI_Unknown:
    llvm_unreachable("Improperly initialised target ABI");
  }

  MCA.setELFHeaderEFlags(EFlags);
}

//SSITH Addition
void RISCVTargetELFStreamer::EmitSSITHMetadataHeader(MCObjectStreamer &Streamer){

  SmallString<256> Code;
  raw_svector_ostream VecOS(Code);

  printf("emitting metadata header!\n");
  
  //Emit the Metadata tag
  uint8_t MD = DMD_SET_BASE_ADDRESS_OP;
  support::endian::write(VecOS, MD, support::little);

  uint64_t Base = 0u;
  support::endian::write(VecOS, Base, support::little);

  MCDataFragment *DF = Streamer.getOrCreateDataFragment();
  DF->getContents().append(Code.begin(), Code.end());

  ISPSecInitialized = true;
}

//SSITH Addition
void RISCVTargetELFStreamer::EmitSSITHMetadataEntry(SmallVector<MCFixup, 4> &Fixups,
						 uint8_t MD_type, uint8_t tag){
  SmallString<256> Code;
  raw_svector_ostream VecOS(Code);
  MCDataFragment *DF;

  bool switchSection = false;
  
  MCELFStreamer &Streamer = getStreamer();
  MCContext &Context = Streamer.getContext();
  
  const auto ISPMetadataSection =
    Context.getObjectFileInfo()->getISPMetadataSection();

  if ( Streamer.getCurrentSectionOnly() != ISPMetadataSection ) {
    switchSection = true;
    Streamer.PushSection();
    Streamer.SwitchSection(ISPMetadataSection);
  }

  if ( !ISPSecInitialized ) 
    EmitSSITHMetadataHeader(Streamer);
  
  // Emit the Metadata tag
  assert(MD_type && "[SSITH Error] MD_TYPE must be nonnull");
  uint8_t MD = MD_type;
  support::endian::write(VecOS, MD, support::little);
  
  //Our placeholder 0 bytes for the relative address
  uint32_t Bits = 0;
  support::endian::write(VecOS, Bits, support::little);
 
  if(MD_type == DMD_FUNCTION_RANGE)
    support::endian::write(VecOS, Bits, support::little);
  
  //The metadata tag specifier
  if(MD_type != DMD_FUNCTION_RANGE){
    assert(tag && 
        "[SSITH Error] Must have a non null tag for op types other than function range");
    MD = tag;
    support::endian::write(VecOS, MD, support::little);
  }

  DF = Streamer.getOrCreateDataFragment();
  // Add the fixup and data.
  for(unsigned i = 0; i < Fixups.size(); i++){
    //hack this to account for the prologue byte
    Fixups[i].setOffset(Fixups[i].getOffset() + DF->getContents().size() + 1 + i*4);
    DF->getFixups().push_back(Fixups[i]);
  }
  DF->getContents().append(Code.begin(), Code.end());

  if ( switchSection )
    Streamer.PopSection();
}

MCELFStreamer &RISCVTargetELFStreamer::getStreamer() {
  return static_cast<MCELFStreamer &>(Streamer);
}

#if 0
//SSITH
void RISCVTargetELFStreamer::EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end){
  
  SmallVector<MCFixup, 4> Fixups;

  //Make MCExpr for the fixups -- Inspired by LowerSymbolOperand in RISCVMCInstLower.cpp
  MCContext &Ctx = getStreamer().getContext();
  RISCVMCExpr::VariantKind Kind = RISCVMCExpr::VK_RISCV_None;
  const MCExpr *MEbegin = MCSymbolRefExpr::create(begin, MCSymbolRefExpr::VK_None, Ctx);
  const MCExpr *MEend = MCSymbolRefExpr::create(end, MCSymbolRefExpr::VK_None, Ctx);
  MEbegin = RISCVMCExpr::create(MEbegin, Kind, Ctx);
  MEend = RISCVMCExpr::create(MEend, Kind, Ctx);
  
  //Push fixup -- the linker will write the 4 byte address for us
  Fixups.push_back(
      MCFixup::create(0, MEbegin, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));
  Fixups.push_back(
      MCFixup::create(0, MEend, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  getStreamer().EmitLabel(end);
  EmitSSITHMetadataEntry(Fixups, DMD_FUNCTION_RANGE, 0);
}
#endif

void RISCVTargetELFStreamer::EmitMCSymbolMetadata(MCSymbol *Sym) {

  if ( !Sym->containsISPMetadata() )
    return;

  //Make MCExpr for the fixups -- Inspired by LowerSymbolOperand in RISCVMCInstLower.cpp
  //  RISCVMCExpr::VariantKind Kind = RISCVMCExpr::VK_RISCV_None;
  const MCExpr *ME = MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, getStreamer().getContext());
  //  ME = RISCVMCExpr::create(ME, Kind, es->getContext());

  SmallVector<MCFixup, 4> Fixups;  
  Fixups.push_back(
		   MCFixup::create(0, ME, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  // todo get rid of magic number
  for ( int i = 1; i <= 11; i++ )
    if ( Sym->containsISPMetadataTag(i) )
      EmitSSITHMetadataEntry(Fixups, DMD_TAG_ADDRESS_OP, i);
}

void RISCVTargetELFStreamer::EmitMCInstMetadata(const MCInst &Inst) {

  if ( !Inst.containsISPMetadata() )
    return;
  
  // todo get rid of magic number 
  for ( int i = 1; i <= 11; i++ )
    if ( Inst.containsISPMetadataTag(i) ) {
      MCSymbol *InstSym = getStreamer().getContext().createTempSymbol();
      InstSym->setISPMetadataTag(i);
      getStreamer().EmitLabel(InstSym);
      //      if ( i == DMT_RETURN_INSTR )
      //	EmitSSITHMetadataFnRange((MCSymbol*)Inst.getISPSym(), getStreamer().getContext().createTempSymbol());
    }
}

void RISCVTargetELFStreamer::emitLabel(MCSymbol *Symbol) {

  EmitMCSymbolMetadata(Symbol);

  return;
}

void RISCVTargetELFStreamer::emitInstruction(const MCInst &Inst, const MCSubtargetInfo &) {

  EmitMCInstMetadata(Inst);
  
  return;
}

void RISCVTargetELFStreamer::emitCommonSymbol(MCSymbol *Symbol, uint64_t Size,
					      unsigned ByteAlignment) {
  EmitMCSymbolMetadata(Symbol);
}

void RISCVTargetELFStreamer::emitDirectiveOptionPush() {}
void RISCVTargetELFStreamer::emitDirectiveOptionPop() {}
void RISCVTargetELFStreamer::emitDirectiveOptionRVC() {}
void RISCVTargetELFStreamer::emitDirectiveOptionNoRVC() {}
void RISCVTargetELFStreamer::emitDirectiveOptionRelax() {}
void RISCVTargetELFStreamer::emitDirectiveOptionNoRelax() {}
