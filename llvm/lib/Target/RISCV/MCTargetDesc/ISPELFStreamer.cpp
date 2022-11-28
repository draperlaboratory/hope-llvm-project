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
#include "llvm/BinaryFormat/ELF.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCContext.h"
#include "llvm/MC/MCObjectWriter.h"
#include "llvm/MC/MCObjectFileInfo.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/Support/EndianStream.h"

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
						 uint8_t MD_type, uint8_t Tag) {
  SmallString<256> Code;
  raw_svector_ostream VecOS(Code);
  MCDataFragment *DF;

  bool switchSection = false;

  MCELFStreamer &Streamer = getStreamer();
  MCContext &Context = Streamer.getContext();

  const auto ISPMetadataSection =
    Context.getObjectFileInfo()->getISPMetadataSection();

  if (Streamer.getCurrentSectionOnly() != ISPMetadataSection) {
    switchSection = true;
    Streamer.pushSection();
    Streamer.switchSection(ISPMetadataSection);
  }

  if (!ISPSecInitialized)
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
  if(MD_type != DMD_FUNCTION_RANGE) {
    assert(Tag &&
        "[SSITH Error] Must have a non null tag for op types other than function range");
    MD = Tag;
    support::endian::write(VecOS, MD, support::little);
  }

  DF = Streamer.getOrCreateDataFragment();

  // Add the fixup and data.
  for(unsigned i = 0; i < Fixups.size(); i++){
    //hack this to account for the prologue byte
    Fixups[i].setOffset(DF->getContents().size() + 1 + i * 4);
    DF->getFixups().push_back(Fixups[i]);
  }

  DF->getContents().append(Code.begin(), Code.end());

  if (switchSection)
    Streamer.popSection();
}

static SmallVector<MCFixup, 4> GetFixups(MCSymbol *Sym, MCELFStreamer &Streamer) {
  const MCExpr *ME = MCSymbolRefExpr::create(Sym, Streamer.getContext());

  SmallVector<MCFixup, 4> Fixups;
  Fixups.push_back(MCFixup::create(0, ME, MCFixupKind(FK_Data_4)));

  return Fixups;
}

void ISPTargetELFStreamer::EmitMCSymbolMetadata(MCSymbol *Sym) {
  auto Fixups = GetFixups(Sym, getStreamer());
  for (auto const &Pair : MachineInstFlagToMetadata) {
    if (Sym->getFlag(Pair.first)) {
      EmitSSITHMetadataEntry(Fixups, DMD_TAG_ADDRESS_OP, Pair.second);
    }
  }
}

void ISPTargetELFStreamer::EmitMCInstMetadata(const MCInst &Inst) {
  // Instructions from inline assembly are currently unsupported.
  if (!Inst.getFlag(MachineInstr::HasParentFn)) {
    return;
  }

  auto &Streamer = getStreamer();

  auto *InstSym = Streamer.getContext().createNamedTempSymbol("ISP_INST_");
  for (auto const &Pair : MachineInstFlagToMetadata) {
    if (Inst.getFlag(Pair.first)) {
      InstSym->setFlag(Pair.first);
    }
  }
  Streamer.emitLabel(InstSym);
}

void ISPTargetELFStreamer::emitLabel(MCSymbol *Symbol) {
  RISCVTargetELFStreamer::emitLabel(Symbol);
  EmitMCSymbolMetadata(Symbol);
}

void ISPTargetELFStreamer::emitInstruction(const MCInst &Inst, const MCSubtargetInfo &STI) {
  EmitMCInstMetadata(Inst);
  RISCVTargetELFStreamer::emitInstruction(Inst, STI);
}

void ISPTargetELFStreamer::emitCommonSymbol(MCSymbol *Symbol, uint64_t Size,
					      unsigned ByteAlignment) {
  RISCVTargetELFStreamer::emitCommonSymbol(Symbol, Size, ByteAlignment);
  EmitMCSymbolMetadata(Symbol);
}

