//===-- runtime/io-api.h ----------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//----------------------------------------------------------------------------//

// Defines API between compiled code and I/O runtime library.

#ifndef FORTRAN_RUNTIME_IO_API_H_
#define FORTRAN_RUNTIME_IO_API_H_

#include "entry-names.h"
#include "magic-numbers.h"
#include <cinttypes>
#include <cstddef>

namespace Fortran::runtime {
class Descriptor;
class NamelistGroup;
};

namespace Fortran::runtime::io {

class IoStatementState;
using Cookie = IoStatementState *;
using ExternalUnit = int;
using AsynchronousId = int;
static constexpr ExternalUnit DefaultUnit{-1};  // READ(*), WRITE(*), PRINT

extern "C" {

#define IONAME(name) RTNAME(io##name)

// These functions initiate data transfer statements (READ, WRITE, PRINT).
// Example: PRINT *, 666 is implemented as the series of calls:
//   Cookie cookie{BeginExternalListOutput(DefaultUnit,__FILE__,__LINE__)};
//   OutputInteger64(cookie, 666);
//   EndIoStatement(cookie);

// Internal I/O initiation
// Internal I/O can loan the runtime library an optional block of memory
// in which the library can maintain state across the calls that implement
// the internal transfer; use of these blocks can reduce the need for dynamic
// memory allocation &/or thread-local storage.  The block must be sufficiently
// aligned to hold a pointer.
constexpr std::size_t RecommendedInternalIoScratchAreaBytes(
    int maxFormatParenthesesNestingDepth) {
  return 32 + 8 * maxFormatParenthesesNestingDepth;
}

// Internal I/O to/from character arrays &/or non-default-kind character
// requires a descriptor, which must remain unchanged until the I/O
// statement is complete.
Cookie IONAME(BeginInternalArrayListOutput)(const Descriptor &,
    void **scratchArea = nullptr, std::size_t scratchBytes = 0,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInternalArrayListInput)(const Descriptor &,
    void **scratchArea = nullptr, std::size_t scratchBytes = 0,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInternalArrayFormattedOutput)(const Descriptor &,
    const char *format, std::size_t formatBytes, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginInternalArrayFormattedInput)(const Descriptor &,
    const char *format, std::size_t formatBytes, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);

// Internal I/O to/from a default-kind character scalar can avoid a
// descriptor.
Cookie IONAME(BeginInternalListOutput)(char *internal, std::size_t bytes,
    void **scratchArea = nullptr, std::size_t scratchBytes = 0,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInternalListInput)(char *internal, std::size_t bytes,
    void **scratchArea = nullptr, std::size_t scratchBytes = 0,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInternalFormattedOutput)(char *internal, std::size_t bytes,
    const char *format, std::size_t formatBytes, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginInternalFormattedInput)(char *internal, std::size_t bytes,
    const char *format, std::size_t formatBytes, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);

// Internal namelist I/O
Cookie IONAME(BeginInternalNamelistOutput)(const Descriptor &,
    const NamelistGroup &, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginInternalNamelistInput)(const Descriptor &,
    const NamelistGroup &, void **scratchArea = nullptr,
    std::size_t scratchBytes = 0, const char *sourceFile = nullptr,
    int sourceLine = 0);

// External synchronous I/O initiation
Cookie IONAME(BeginExternalListOutput)(ExternalUnit = DefaultUnit,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginExternalListInput)(ExternalUnit = DefaultUnit,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginExternalFormattedOutput)(const char *format, std::size_t,
    ExternalUnit = DefaultUnit, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginExternalFormattedInput)(const char *format, std::size_t,
    ExternalUnit = DefaultUnit, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginUnformattedOutput)(ExternalUnit = DefaultUnit,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginUnformattedInput)(ExternalUnit = DefaultUnit,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginNamelistOutput)(const NamelistGroup &,
    ExternalUnit = DefaultUnit, const char *sourceFile = nullptr,
    int sourceLine = 0);
Cookie IONAME(BeginNamelistInput)(const NamelistGroup &,
    ExternalUnit = DefaultUnit, const char *sourceFile = nullptr,
    int sourceLine = 0);

// Asynchronous I/O is supported (at most) for unformatted direct access
// block transfers.
AsynchronousId IONAME(BeginAsynchronousOutput)(ExternalUnit, std::int64_t REC,
    const char *, std::size_t, const char *sourceFile = nullptr,
    int sourceLine = 0);
AsynchronousId IONAME(BeginAsynchronousInput)(ExternalUnit, std::int64_t REC,
    char *, std::size_t, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginWait)(ExternalUnit, AsynchronousId);

// Other I/O statements
Cookie IONAME(BeginClose)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginFlush)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginBackspace)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginEndfile)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginRewind)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);

// OPEN(UNIT=) and OPEN(NEWUNIT=) have distinct interfaces.
Cookie IONAME(BeginOpenUnit)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginOpenNewUnit)(
    const char *sourceFile = nullptr, int sourceLine = 0);

// The variant forms of INQUIRE() statements have distinct interfaces.
// BeginInquireIoLength() is basically a no-op output statement.
Cookie IONAME(BeginInquireUnit)(
    ExternalUnit, const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInquireFile)(const char *, std::size_t, int kind = 1,
    const char *sourceFile = nullptr, int sourceLine = 0);
Cookie IONAME(BeginInquireIoLength(const char *sourceFile = nullptr, int sourceLine = 0);

// If an I/O statement has any IOSTAT=, ERR=, END=, or EOR= specifiers,
// call EnableHandlers() immediately after the Begin...() call.
// An output or OPEN statement may not enable HasEnd or HasEor.
// This call makes the runtime library defer those particular error/end
// conditions to the EndIoStatement() call rather than terminating
// the image.  E.g., for READ(*,*,END=666) A, B, (C(J),J=1,N)
//   Cookie cookie{BeginExternalListInput(DefaultUnit,__FILE__,__LINE__)};
//   EnableHandlers(cookie, false, false, true /*END=*/, false);
//   if (InputReal64(cookie, &A)) {
//     if (InputReal64(cookie, &B)) {
//       for (int J{1}; J<=N; ++J) {
//         if (!InputReal64(cookie, &C[J])) break;
//       }
//     }
//   }
//   if (EndIoStatement(cookie) == FORTRAN_RUTIME_IOSTAT_END) goto label666;
void IONAME(EnableHandlers)(Cookie, bool HasIostat = false, bool HasErr = false,
    bool HasEnd = false, bool HasEor = false);

// Control list options.  These return false on a error that the
// Begin...() call has specified will be handled by the caller.
// The interfaces that pass a default-kind CHARACTER argument
// are limited to passing specific case-insensitive keyword values.
// ADVANCE=YES, NO
bool IONAME(SetAdvance)(Cookie, const char *, std::size_t);
// BLANK=NULL, ZERO
bool IONAME(SetBlank)(Cookie, const char *, std::size_t);
// DECIMAL=COMMA, POINT
bool IONAME(SetDecimal)(Cookie, const char *, std::size_t);
// DELIM=APOSTROPHE, QUOTE, NONE
bool IONAME(SetDelim)(Cookie, const char *, std::size_t);
// PAD=YES, NO
bool IONAME(SetPad)(Cookie, const char *, std::size_t);
bool IONAME(SetPos)(Cookie, std::int64_t);
bool IONAME(SetRec)(Cookie, std::int64_t);
// ROUND=UP, DOWN, ZERO, NEAREST, COMPATIBLE, PROCESSOR_DEFINED
bool IONAME(SetRound)(Cookie, const char *, std::size_t);
// SIGN=PLUS, SUPPRESS, PROCESSOR_DEFINED
bool IONAME(SetSign)(Cookie, const char *, std::size_t);

// Data item transfer for modes other than namelist.
// Any data object that can be passed as an actual argument without the
// use of a temporary can be transferred by means of a descriptor;
// vector-valued subscripts and coindexing will require elementwise
// transfers &/or data copies.  Unformatted transfers to/from contiguous
// blocks of local image memory can avoid the descriptor, and there
// are specializations for the most common scalar types.
//
// These functions return false when the I/O statement has encountered an
// error or end-of-file/record condition that the caller has indicated
// should not cause termination of the image by the runtime library.
// Once the statement has encountered an error, all following items will be
// ignored and also return false; but compiled code should check for errors
// and avoid the following items when they might crash.
bool IONAME(OutputDescriptor)(Cookie, const Descriptor &);
bool IONAME(InputDescriptor)(Cookie, const Descriptor &);
bool IONAME(OutputUnformattedBlock)(Cookie, const char *, std::size_t);
bool IONAME(InputUnformattedBlock)(Cookie, char *, std::size_t);
bool IONAME(OutputInteger64)(Cookie, std::int64_t);
bool IONAME(InputInteger64)(Cookie, std::int64_t &, int kind = 8);
bool IONAME(OutputReal32)(Cookie, float);
bool IONAME(InputReal32)(Cookie, float &);
bool IONAME(OutputReal64)(Cookie, double);
bool IONAME(InputReal64)(Cookie, double &);
bool IONAME(OutputComplex32)(Cookie, float, float);
bool IONAME(OutputComplex64)(Cookie, double, double);
bool IONAME(OutputAscii)(Cookie, const char *, std::size_t);
bool IONAME(InputAscii)(Cookie, char *, std::size_t);
bool IONAME(OutputLogical)(Cookie, bool);
bool IONAME(InputLogical)(Cookie, bool &);

// Additional specifier interfaces for the connection-list of
// on OPEN statement (only).  SetBlank(), SetDecimal(),
// SetDelim(), GetIoMsg(), SetPad(), SetRound(), & SetSign()
// are also acceptable for OPEN.
// ACCESS=SEQUENTIAL, DIRECT, STREAM
bool IONAME(SetAccess, Cookie, const char *, std::size_t);
// ACTION=READ, WRITE, or READWRITE
bool IONAME(SetAction, Cookie, const char *, std::size_t);
// ASYNCHRONOUS=YES, NO
bool IONAME(SetAsynchronous, Cookie, const char *, std::size_t);
// ENCODING=UTF-8, DEFAULT
bool IONAME(SetEncoding, Cookie, const char *, std::size_t);
// FORM=FORMATTED, UNFORMATTED
bool IONAME(SetForm, Cookie, const char *, std::size_t);
// POSITION=ASIS, REWIND, APPEND
bool IONAME(SetPosition, Cookie, const char *, std::size_t);
bool IONAME(SetRecl, Cookie, std::size_t);  // RECL=

// STATUS can be set during an OPEN or CLOSE statement.
// For OPEN: STATUS=OLD, NEW, SCRATCH, REPLACE, UNKNOWN
// For CLOSE: STATUS=KEEP, DELETE
bool IONAME(SetStatus, Cookie, const char *, std::size_t);

// SetFile() may pass a CHARACTER argument of non-default kind,
// and such filenames are converted to UTF-8 before being
// presented to the filesystem.
bool IONAME(SetFile, Cookie, const char *, std::size_t, int kind = 1);

// GetNewUnit() must not be called until after all Set...()
// connection list specifiers have been called after
// BeginOpenNewUnit().
bool IONAME(GetNewUnit)(Cookie, int &, int kind = 4);  // NEWUNIT=

// READ(SIZE=), after all input items
bool IONAME(GetSize)(Cookie, std::int64_t, int kind = 8);

// INQUIRE(IOLENGTH=), after all output items
bool IONAME(GetIoLength)(Cookie, std::int64_t, int kind = 8);

// GetIoMsg() does not modify its argument unless an error or
// end-of-record/file condition is present.
void IONAME(GetIoMsg)(Cookie, char *, std::size_t);  // IOMSG=

// INQUIRE() specifiers are mostly identified by their NUL-terminated
// case-insensitive names.
// ACCESS, ACTION, ASYNCHRONOUS, BLANK, DECIMAL, DELIM, DIRECT, ENCODING,
// FORM, FORMATTED, NAME, PAD, POSITION, READ, READWRITE, ROUND,
// SEQUENTIAL, SIGN, STREAM, UNFORMATTED, WRITE:
bool IONAME(InquireCharacter)(Cookie, const char *specifier, char *, std::size_t);
// EXIST, NAMED, OPENED, and PENDING (without ID):
bool IONAME(InquireLogical)(Cookie, const char *specifier, bool &);
// PENDING with ID
bool IONAME(InquirePendingId)(Cookie, std::int64_t, bool &);
// NEXTREC, NUMBER, POS, RECL, SIZE
bool IONAME(InquireInteger64)(Cookie, const char *specifier, std::int64_t &, int kind = 8);

// The value of IOSTAT= is zero when no error, end-of-record,
// or end-of-file condition has arisen; errors are positive values.
// (See 12.11.5 in Fortran 2018 for the complete requirements;
// these constants must match the values of their corresponding
// named constants in the predefined module ISO_FORTRAN_ENV, so
// they're actually defined in another magic-numbers.h header file
// so that they can be included both here and there.)
enum Iostat {
  // Other errors have values >1
  IostatInquireInternalUnit = FORTRAN_RUNTIME_IOSTAT_INQUIRE_INTERNAL_UNIT,
  IostatOk = 0,
  IostatEnd = FORTRAN_RUNTIME_IOSTAT_END,  // end-of-file & no error
  IostatEor = FORTRAN_RUNTIME_IOSTAT_EOR,  // end-of-record & no error or EOF
  IostatFlush =
      FORTRAN_RUNTIME_IOSTAT_FLUSH,  // attempt to FLUSH an unflushable unit
};

// This function must be called to end an I/O statement, and its
// cookie value may not be used afterwards unless it is recycled
// by the runtime library to serve a later I/O statement.
// The return value can be used to implement IOSTAT=, ERR=, END=, & EOR=;
// store it into the IOSTAT= variable if there is one, and test
// it to implement the various branches.  The error condition
// returned is guaranteed to only be one of the problems that the
// EnableHandlers() call has indicated should be handled in compiled code
// rather than by terminating the image.
enum Iostat IONAME(EndIoStatement)(Cookie);

};  // extern "C"
}
#endif
