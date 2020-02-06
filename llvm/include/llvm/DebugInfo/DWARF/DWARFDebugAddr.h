//===- DWARFDebugAddr.h -------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===------------------------------------------------------------------===//

#ifndef LLVM_DEBUGINFO_DWARFDEBUGADDR_H
#define LLVM_DEBUGINFO_DWARFDEBUGADDR_H

#include "llvm/BinaryFormat/Dwarf.h"
#include "llvm/DebugInfo/DIContext.h"
#include "llvm/DebugInfo/DWARF/DWARFDataExtractor.h"
#include "llvm/Support/Errc.h"
#include "llvm/Support/Error.h"
#include <cstdint>
#include <map>
#include <vector>

namespace llvm {

class Error;
class raw_ostream;

/// A class representing an address table as specified in DWARF v5.
/// The table consists of a header followed by an array of address values from
/// .debug_addr section.
class DWARFDebugAddrTable {
  dwarf::DwarfFormat Format;
  uint64_t Offset;
  /// The total length of the entries for this table, not including the length
  /// field itself.
  uint32_t Length = 0;
  /// The DWARF version number.
  uint16_t Version;
  /// The size in bytes of an address on the target architecture. For
  /// segmented addressing, this is the size of the offset portion of the
  /// address.
  uint8_t AddrSize;
  /// The size in bytes of a segment selector on the target architecture.
  /// If the target system uses a flat address space, this value is 0.
  uint8_t SegSize;
  std::vector<uint64_t> Addrs;

  /// Invalidate Length field to stop further processing.
  void invalidateLength() { Length = 0; }

  Error extractAddresses(const DWARFDataExtractor &Data, uint64_t *OffsetPtr,
                         uint64_t EndOffset);

public:

  /// Extract the entire table, including all addresses.
  Error extract(const DWARFDataExtractor &Data, uint64_t *OffsetPtr,
                uint16_t CUVersion, uint8_t CUAddrSize,
                std::function<void(Error)> WarnCallback);

  /// Extract a DWARFv5 address table.
  Error extractV5(const DWARFDataExtractor &Data, uint64_t *OffsetPtr,
                  uint8_t CUAddrSize, std::function<void(Error)> WarnCallback);

  /// Extract a pre-DWARFv5 address table. Such tables do not have a header
  /// and consist only of a series of addresses.
  /// See https://gcc.gnu.org/wiki/DebugFission for details.
  Error extractPreStandard(const DWARFDataExtractor &Data, uint64_t *OffsetPtr,
                           uint16_t CUVersion, uint8_t CUAddrSize);

  void dump(raw_ostream &OS, DIDumpOptions DumpOpts = {}) const;

  /// Return the address based on a given index.
  Expected<uint64_t> getAddrEntry(uint32_t Index) const;

  /// Return the full length of this table, including the length field.
  /// Return None if the length cannot be identified reliably.
  Optional<uint64_t> getFullLength() const;
};

} // end namespace llvm

#endif // LLVM_DEBUGINFO_DWARFDEBUGADDR_H
