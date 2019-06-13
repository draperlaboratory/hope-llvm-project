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
#include "llvm/CodeGen/MachineInstr.h"

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

void ISPTargetELFStreamer::EmitMCSymbolMetadata(MCSymbol *Sym) {

  const MCExpr *ME = MCSymbolRefExpr::create(Sym, MCSymbolRefExpr::VK_None, getStreamer().getContext());

  SmallVector<MCFixup, 4> Fixups;  
  Fixups.push_back(
		   MCFixup::create(0, ME, MCFixupKind(FK_Data_4), SMLoc::getFromPointer(nullptr)));

  for ( auto const &pair : MachineInstFlagToMetadata )
    if ( Sym->getFlag(pair.first) )
      EmitSSITHMetadataEntry(Fixups, DMD_TAG_ADDRESS_OP, pair.second);
}

void ISPTargetELFStreamer::EmitMCInstMetadata(const MCInst &Inst) {

  // note: need one temp label per metadata entry,
  //       even if they're on the same instruction  
  for ( auto const &pair : MachineInstFlagToMetadata ) {
    if ( Inst.getFlag(pair.first) ) {
      MCSymbol *InstSym = getStreamer().getContext().createTempSymbol();
      InstSym->setFlag(pair.first);
      getStreamer().EmitLabel(InstSym);
    }
  }

}

void ISPTargetELFStreamer::emitLabel(MCSymbol *Symbol) {

  RISCVTargetELFStreamer::emitLabel(Symbol);
  
  EmitMCSymbolMetadata(Symbol);

  return;
}

void ISPTargetELFStreamer::emitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI) {

  RISCVTargetELFStreamer::emitInstruction(Inst, STI);
  
  EmitMCInstMetadata(Inst);
  
  return;
}

void ISPTargetELFStreamer::emitCommonSymbol(MCSymbol *Symbol, uint64_t Size,
					      unsigned ByteAlignment) {

  RISCVTargetELFStreamer::emitCommonSymbol(Symbol, Size, ByteAlignment);

  EmitMCSymbolMetadata(Symbol);

  return;
}

