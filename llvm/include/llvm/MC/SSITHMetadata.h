/*
 * Copyright © 2017-2018 The Charles Stark Draper Laboratory, Inc. and/or Dover Microsystems, Inc.
 * All rights reserved. 
 *
 * Use and disclosure subject to the following license. 
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef METADATA_H
#define METADATA_H

#include <cstdint>

typedef uint8_t ISPMetadataTag_t;

#define ISP_METADATA_ELF_SECTION_NAME ".dover_metadata"

/* New metadata format in images:

The goal with this format is to establish a smaller encoding, and a somewhat more general purpose
descriptive encoding.  Ultimately, some of these fields will be uleb128 encoded, as soon as we
can figure out some tool bugs.  For now, some of the uleb128 destined fields are fixed width.
We note these fields in the descriptions here for future notice.

Metadata operations in the image now consist of a stream, with some operations being dependent
on data from previous operations.  This is similar to DWARF debug information encoding.  Code
which processes the metadata should process the stream of operations in order, changing
internal state as it goes.

The first operation encountered in any metadata stream sets the current base address off which
subsequent operations should be based.

DMD_SET_BASE_ADDRESS_OP  (uleb128, but currently byte)
<address>                (uintptr_t)

Following the SET_BASE_ADDRESS operation, will be a sequence of zero or more other operations.
The SET_BASE_ADDRESS operation can appear multiple times.  It just resets the current base
address value for interpretation of operations that follow it in the stream.

DMD_TAG_ADDRESS_OP  (uleb128, but currently byte)
<relative address>  (uleb128, but currently 32bits)
<tag specifier>     (uleb128, but currently byte)

The TAG_ADDRESS operation causes a tag to be applied to a specific address.  The address to be
tagged is formed by adding the <relative address> field to the current base address.  The
<tag specifier> field names the tag to be applied to the resulting address.  The specifier
is a known, stable constant specific to supported policies.  The constant value is invariant
across minor revisions and builds of the operating kernel and policy code, to allow compiled
binaries to have some longevity.  Tagging code will use this constant to look up the appropriate
runtime tag handle or value to apply to the address.

DMD_TAG_ADDRESS_RANGE     (uleb128, but currently byte)
<relative start address>  (uleb128, but currently 32bits)
<relative end address>    (uleb128, but currently 32bits)
<tag specifier>           (uleb128, but currently byte)

The TAG_ADDRESS_RANGE operations causes a tag to be applied to a range of addresses.
The start and end address ranges are formed by taking their respective relative address
fields and adding them to the current base address.  The <tag specifier> field names
the tag to be applied to the resulting address, as per the TAG_ADDRESS operation.

DMD_TAG_POLICY_SYMBOL  (uleb128, but currently byte)
<symbol name>          (asciiz)
<tag type>             (uleb128, but currently 32bits)

DMD_TAG_POLICY_SYMBOL operations cause a symbol whose length can be determined from
a symbol table (e.g. ELF symbol table) to be tagged.  The <tag type> field is generated
by the policy tool, and is not the same as a tag specifier.  Tag types are not stable,
and can and will change from build to build of policies.  The symbol name is a null
terminated name.  These records are generated by the policy tool, exclusively.

DMD_TAG_POLICY_RANGE   (uleb128, but currently byte)
<start address>        (uintptr_t)
<end address>          (uintptr_t)
<tag type>             (uleb128, but currently 32bits)

DMD_TAG_POLICY_RANGE operations cause an address range to be tagged.  The <tag type> 
field is generated by the policy tool, and is not the same as a tag specifier.
Tag types are not stable, and can and will change from build to build of policies.
These records are generated by the policy tool, exclusively.

DMD_TAG_POLICY_SYMBOL_RANKED  (uleb128, but currently byte)
<symbol name>                 (asciiz)
<tag category>                (uleb128, but currently 32bits)
<rank>                        (uleb128, but currently 32bits)
<tag type>                    (uleb128, but currently 32bits)

DMD_TAG_POLICY_SYMBOL_RANKED operations cause a symbol whose length can be determined from
a symbol table (e.g. ELF symbol table) to be tagged.  The <tag type> field is generated
by the policy tool, and is not the same as a tag specifier.  Tag types are not stable,
and can and will change from build to build of policies.  The symbol name is a null
terminated name.  These records are generated by the policy tool, exclusively.
The tag category and rank fields are used to determine overrides of tags.  A tag in
the same category as another with a higher rank will supercede a lower ranked tag
on any given address.

DMD_TAG_POLICY_RANGE_RANKED   (uleb128, but currently byte)
<start address>               (uintptr_t)
<end address>                 (uintptr_t)
<tag category>                (uleb128, but currently 32bits)
<rank>                        (uleb128, but currently 32bits)
<tag type>                    (uleb128, but currently 32bits)

DMD_TAG_POLICY_RANGE_RANKED operations cause an address range to be tagged.  The <tag type> 
field is generated by the policy tool, and is not the same as a tag specifier.
Tag types are not stable, and can and will change from build to build of policies.
These records are generated by the policy tool, exclusively.
The tag category and rank fields are used to determine overrides of tags.  A tag in
the same category as another with a higher rank will supercede a lower ranked tag
on any given address.
 */

/*
  Meta data operations:
 */
#define DMD_SET_BASE_ADDRESS_OP 1u
#define DMD_TAG_ADDRESS_OP 2u
#define DMD_TAG_ADDRESS_RANGE_OP 3u
#define DMD_TAG_POLICY_SYMBOL 4u /* deprecated? */
#define DMD_TAG_POLICY_RANGE 5u /* deprecated? */
#define DMD_TAG_POLICY_SYMBOL_RANKED 6u
#define DMD_TAG_POLICY_RANGE_RANKED 7u
#define DMD_END_BLOCK 8u   
#define DMD_END_BLOCK_WEAK_DECL_HACK 9u
#define DMD_FUNCTION_RANGE 10u  /*Followed by 32bit start and 32bit end addresses*/

/*
  Tag specifiers:
 */
#define DMT_CFI3L_VALID_TGT 1u
#define DMT_STACK_PROLOGUE_AUTHORITY 2u
#define DMT_STACK_EPILOGUE_AUTHORITY 3u
#define DMT_FPTR_STORE_AUTHORITY 4u
#define DMT_BRANCH_VALID_TGT 5u
#define DMT_RET_VALID_TGT 6u
#define DMT_RETURN_INSTR 7u
#define DMT_CALL_INSTR 8u
#define DMT_BRANCH_INSTR 9u
#define DMT_FPTR_CREATE_AUTHORITY 10u
#define DMT_WRITE_ONCE 11u

#endif
