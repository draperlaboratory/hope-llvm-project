//===-- ISPELFStreamer.cpp - ISP ELF Target Streamer Methods --------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides ISP specific target streamer methods.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/RISCVELFStreamer.h"
#include "MCTargetDesc/RISCVMCExpr.h"
#include "MCTargetDesc/RISCVAsmBackend.h"
#include "MCTargetDesc/RISCVMCTargetDesc.h"
#include "Utils/RISCVBaseInfo.h"
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCObjectFileInfo.h"

#include "ISP.h"

ISPTargetELFStreamer::ISPTargetELFStreamer(MCStreamer &S,
					   const MCSubtargetInfo &STI)
  : RISCVTargetELFStreamer(S, STI) {

  ISPSecInitialized = false;
}

//SSITH Addition
void ISPTargetELFStreamer::EmitSSITHMetadataHeader(MCObjectStreamer &Streamer){

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
void ISPTargetELFStreamer::EmitSSITHMetadataEntry(SmallVector<MCFixup, 4> &Fixups,
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

#if 0
//SSITH
void ISPTargetELFStreamer::EmitSSITHMetadataFnRange(MCSymbol *begin, MCSymbol *end){
  
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

void ISPTargetELFStreamer::EmitMCSymbolMetadata(MCSymbol *Sym) {

  if ( !Sym->containsISPMetadata() )
    return;

  const MCExpr *ME = MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, getStreamer().getContext());

  SmallVector<MCFixup, 4> Fixups;  
  Fixups.push_back(
		   MCFixup::create(0, ME, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  // todo get rid of magic number
  for ( int i = 1; i <= 11; i++ )
    if ( Sym->containsISPMetadataTag(i) )
      EmitSSITHMetadataEntry(Fixups, DMD_TAG_ADDRESS_OP, i);
}

void ISPTargetELFStreamer::EmitMCInstMetadata(const MCInst &Inst) {

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

void ISPTargetELFStreamer::emitLabel(MCSymbol *Symbol) {

  // TODO: include if this is not a comiler error
  //  RISCVTargetELFStreamer::emitLabel(Symbol);
  
  EmitMCSymbolMetadata(Symbol);

  return;
}

void ISPTargetELFStreamer::emitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI) {

  // TODO: include if this is not a comiler error  
  //  RISCVTargetELFStreamer::emitInstruction(Inst, STI);
  
  EmitMCInstMetadata(Inst);
  
  return;
}

void ISPTargetELFStreamer::emitCommonSymbol(MCSymbol *Symbol, uint64_t Size,
					      unsigned ByteAlignment) {

  // TODO: include if this is not a comiler error
  //  RISCVTargetELFStreamer::emitCommonSymbol(Symbol, Size, ByteAlignment);

  EmitMCSymbolMetadata(Symbol);

  return;
}

