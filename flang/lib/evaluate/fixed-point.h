// Copyright (c) 2018, NVIDIA CORPORATION.  All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#ifndef FORTRAN_EVALUATE_FIXED_POINT_H_
#define FORTRAN_EVALUATE_FIXED_POINT_H_

// Emulates integers of a arbitrary static size for use when the C++
// environment does not support that size or when a fixed interface
// is needed.  The data are typeless, so signed and unsigned operations
// are distinguished from each other with distinct member function interfaces.
// ("Signed" here means two's-complement, just to be clear.)

#include "leading-zero-bit-count.h"
#include <cinttypes>
#include <climits>
#include <cstddef>

namespace Fortran::evaluate {

// Integers are always ordered.
enum class Ordering { Less, Equal, Greater };

static constexpr Ordering Reverse(Ordering ordering) {
  if (ordering == Ordering::Less) {
    return Ordering::Greater;
  } else if (ordering == Ordering::Greater) {
    return Ordering::Less;
  } else {
    return Ordering::Equal;
  }
}

// Implements an integer as an assembly of smaller (i.e., 32-bit) integers.
// These are stored in either little- or big-endian order, independent of
// the host's endianness.
// To facilitate exhaustive testing of what would otherwise be more rare
// edge cases, this class template may be configured to use other part
// types &/or partial fields in the parts.
// Member functions that correspond to Fortran intrinsic functions are
// named accordingly.
template<int BITS, int PARTBITS = 32, typename PART = std::uint32_t,
    typename BIGPART = std::uint64_t, bool LITTLE_ENDIAN = true>
class FixedPoint {
public:
  static constexpr int bits{BITS};
  static constexpr int partBits{PARTBITS};
  using Part = PART;
  using BigPart = BIGPART;
  static_assert(sizeof(BigPart) >= 2 * sizeof(Part));
  static constexpr bool littleEndian{LITTLE_ENDIAN};

private:
  static constexpr int maxPartBits{CHAR_BIT * sizeof(Part)};
  static_assert(partBits > 0 && partBits <= maxPartBits);
  static constexpr int extraPartBits{maxPartBits - partBits};
  static constexpr int parts{(bits + partBits - 1) / partBits};
  static_assert(parts >= 1);
  static constexpr int extraTopPartBits{
      extraPartBits + (parts * partBits) - bits};
  static constexpr int topPartBits{maxPartBits - extraTopPartBits};
  static_assert(topPartBits > 0 && topPartBits <= partBits);
  static_assert((parts - 1) * partBits + topPartBits == bits);
  static constexpr Part partMask{static_cast<Part>(~0) >> extraPartBits};
  static constexpr Part topPartMask{static_cast<Part>(~0) >> extraTopPartBits};

public:
  // Constructors and value-generating static functions
  constexpr FixedPoint() { Clear(); }  // default constructor: zero
  constexpr FixedPoint(const FixedPoint &) = default;
  constexpr FixedPoint(std::uint64_t n) {
    for (int j{0}; j + 1 < parts; ++j) {
      SetLEPart(j, n);
      if constexpr (partBits < 64) {
        n >>= partBits;
      } else {
        n = 0;
      }
    }
    SetLEPart(parts - 1, n);
  }
  constexpr FixedPoint(std::int64_t n) {
    std::int64_t signExtension{-(n < 0)};
    signExtension <<= partBits;
    for (int j{0}; j + 1 < parts; ++j) {
      SetLEPart(j, n);
      if constexpr (partBits < 64) {
        n = (n >> partBits) | signExtension;
      } else {
        n = signExtension;
      }
    }
    SetLEPart(parts - 1, n);
  }

  // Right-justified mask (e.g., MASKR(1) == 1, MASKR(2) == 3, &c.)
  static constexpr FixedPoint MASKR(int places) {
    FixedPoint result{nullptr};
    int j{0};
    for (; j + 1 < parts && places >= partBits; ++j, places -= partBits) {
      result.LEPart(j) = partMask;
    }
    if (places > 0) {
      if (j + 1 < parts) {
        result.LEPart(j++) = partMask >> (partBits - places);
      } else if (j + 1 == parts) {
        if (places >= topPartBits) {
          result.LEPart(j++) = topPartMask;
        } else {
          result.LEPart(j++) = topPartMask >> (topPartBits - places);
        }
      }
    }
    for (; j < parts; ++j) {
      result.LEPart(j) = 0;
    }
    return result;
  }

  // Left-justified mask (e.g., MASKL(1) has only its sign bit set)
  static constexpr FixedPoint MASKL(int places) {
    if (places <= 0) {
      return {};
    } else if (places >= bits) {
      return MASKR(bits);
    } else {
      return MASKR(bits - places).NOT();
    }
  }

  constexpr FixedPoint &operator=(const FixedPoint &) = default;

  constexpr bool IsZero() const {
    for (int j{0}; j < parts; ++j) {
      if (part_[j] != 0) {
        return false;
      }
    }
    return true;
  }

  constexpr bool IsNegative() const {
    return (LEPart(parts - 1) >> (topPartBits - 1)) & 1;
  }

  constexpr Ordering CompareToZeroSigned() const {
    if (IsNegative()) {
      return Ordering::Less;
    } else if (IsZero()) {
      return Ordering::Equal;
    } else {
      return Ordering::Greater;
    }
  }

  // Count the number of contiguous most-significant bit positions
  // that are clear.
  constexpr int LEADZ() const {
    if (LEPart(parts - 1) != 0) {
      int lzbc{LeadingZeroBitCount(LEPart(parts - 1))};
      return lzbc - extraTopPartBits;
    }
    int upperZeroes{topPartBits};
    for (int j{1}; j < parts; ++j) {
      if (Part p{LEPart(parts - 1 - j)}) {
        int lzbc{LeadingZeroBitCount(p)};
        return upperZeroes + lzbc - extraPartBits;
      }
      upperZeroes += partBits;
    }
    return bits;
  }

  // POPCNT intrinsic
  // TODO pmk
  // pmk also POPPAR

  constexpr Ordering CompareUnsigned(const FixedPoint &y) const {
    for (int j{parts}; j-- > 0;) {
      if (LEPart(j) > y.LEPart(j)) {
        return Ordering::Greater;
      }
      if (LEPart(j) < y.LEPart(j)) {
        return Ordering::Less;
      }
    }
    return Ordering::Equal;
  }

  constexpr Ordering CompareSigned(const FixedPoint &y) const {
    bool isNegative{IsNegative()};
    if (isNegative != y.IsNegative()) {
      return isNegative ? Ordering::Less : Ordering::Greater;
    }
    return CompareUnsigned(y);
  }

  constexpr std::uint64_t ToUInt64() const {
    std::uint64_t n{LEPart(0)};
    int filled{partBits};
    for (int j{1}; filled < 64 && j < parts; ++j, filled += partBits) {
      n |= LEPart(j) << filled;
    }
    return n;
  }

  constexpr std::int64_t ToInt64() const {
    std::int64_t signExtended = ToUInt64();
    if (bits < 64) {
      signExtended |= -(signExtended >> (bits - 1)) << bits;
    }
    return signExtended;
  }

  // Ones'-complement (i.e., C's ~)
  constexpr FixedPoint NOT() const {
    FixedPoint result{nullptr};
    for (int j{0}; j < parts; ++j) {
      result.SetLEPart(j, ~LEPart(j));
    }
    return result;
  }

  // Two's-complement negation (-x = ~x + 1).
  // An overflow flag accompanies the result, and will be true when the
  // operand is the most negative signed number (MASKL(1)).
  struct ValueWithOverflow {
    FixedPoint value;
    bool overflow;
  };
  constexpr ValueWithOverflow Negate() const {
    FixedPoint result{nullptr};
    Part carry{1};
    for (int j{0}; j + 1 < parts; ++j) {
      Part newCarry{LEPart(j) == 0 && carry};
      result.SetLEPart(j, ~LEPart(j) + carry);
      carry = newCarry;
    }
    Part top{LEPart(parts - 1)};
    result.SetLEPart(parts - 1, ~top + carry);
    bool overflow{top != 0 && result.LEPart(parts - 1) == top};
    return {result, overflow};
  }

  // Shifts the operand left when the count is positive, right when negative.
  // Vacated bit positions are filled with zeroes.
  constexpr FixedPoint ISHFT(int count) const {
    if (count < 0) {
      return SHIFTR(-count);
    } else {
      return SHIFTL(count);
    }
  }

  // Left shift with zero fill.
  constexpr FixedPoint SHIFTL(int count) const {
    if (count <= 0) {
      return *this;
    } else {
      FixedPoint result{nullptr};
      int shiftParts{count / partBits};
      int bitShift{count - partBits * shiftParts};
      int j{parts - 1};
      if (bitShift == 0) {
        for (; j >= shiftParts; --j) {
          result.SetLEPart(j, LEPart(j - shiftParts));
        }
        for (; j >= 0; --j) {
          result.LEPart(j) = 0;
        }
      } else {
        for (; j > shiftParts; --j) {
          result.SetLEPart(j,
              ((LEPart(j - shiftParts) << bitShift) |
                  (LEPart(j - shiftParts - 1) >> (partBits - bitShift))));
        }
        if (j == shiftParts) {
          result.SetLEPart(j, LEPart(0) << bitShift);
          --j;
        }
        for (; j >= 0; --j) {
          result.LEPart(j) = 0;
        }
      }
      return result;
    }
  }

  // TODO pmk
  // ISHFTC intrinsic - shift some least-significant bits circularly
  // DSHIFTL/R

  // Vacated upper bits are filled with zeroes.
  constexpr FixedPoint SHIFTR(int count) const {
    if (count <= 0) {
      return *this;
    } else {
      FixedPoint result{nullptr};
      int shiftParts{count / partBits};
      int bitShift{count - partBits * shiftParts};
      int j{0};
      if (bitShift == 0) {
        for (; j + shiftParts < parts; ++j) {
          result.LEPart(j) = LEPart(j + shiftParts);
        }
        for (; j < parts; ++j) {
          result.LEPart(j) = 0;
        }
      } else {
        for (; j + shiftParts + 1 < parts; ++j) {
          result.SetLEPart(j,
              (LEPart(j + shiftParts) >> bitShift) |
                  (LEPart(j + shiftParts + 1) << (partBits - bitShift)));
        }
        if (j + shiftParts + 1 == parts) {
          result.LEPart(j++) = LEPart(parts - 1) >> bitShift;
        }
        for (; j < parts; ++j) {
          result.LEPart(j) = 0;
        }
      }
      return result;
    }
  }

  // Be advised, an arithmetic (sign-filling) right shift is not
  // the same as a division by a power of two in all cases.
  constexpr FixedPoint SHIFTA(int count) const {
    if (count <= 0) {
      return *this;
    } else if (IsNegative()) {
      return SHIFTR(count).IOR(MASKL(count));
    } else {
      return SHIFTR(count);
    }
  }

  constexpr FixedPoint IAND(const FixedPoint &y) const {
    FixedPoint result{nullptr};
    for (int j{0}; j < parts; ++j) {
      result.LEPart(j) = LEPart(j) & y.LEPart(j);
    }
    return result;
  }

  constexpr FixedPoint IOR(const FixedPoint &y) const {
    FixedPoint result{nullptr};
    for (int j{0}; j < parts; ++j) {
      result.LEPart(j) = LEPart(j) | y.LEPart(j);
    }
    return result;
  }

  constexpr FixedPoint IEOR(const FixedPoint &y) const {
    FixedPoint result{nullptr};
    for (int j{0}; j < parts; ++j) {
      result.LEPart(j) = LEPart(j) ^ y.LEPart(j);
    }
    return result;
  }

  // Unsigned addition with carry.
  struct ValueWithCarry {
    FixedPoint value;
    bool carry;
  };
  constexpr ValueWithCarry AddUnsigned(
      const FixedPoint &y, bool carryIn = false) const {
    FixedPoint sum{nullptr};
    BigPart carry{carryIn};
    for (int j{0}; j + 1 < parts; ++j) {
      carry += LEPart(j);
      carry += y.LEPart(j);
      sum.SetLEPart(j, carry);
      carry >>= partBits;
    }
    carry += LEPart(parts - 1);
    carry += y.LEPart(parts - 1);
    sum.SetLEPart(parts - 1, carry);
    return {sum, carry > topPartMask};
  }

  constexpr ValueWithOverflow AddSigned(const FixedPoint &y) const {
    bool isNegative{IsNegative()};
    bool sameSign{isNegative == y.IsNegative()};
    ValueWithCarry sum{AddUnsigned(y)};
    bool overflow{sameSign && sum.value.IsNegative() != isNegative};
    return {sum.value, overflow};
  }

  constexpr ValueWithOverflow SubtractSigned(const FixedPoint &y) const {
    bool isNegative{IsNegative()};
    bool sameSign{isNegative == y.IsNegative()};
    ValueWithCarry diff{AddUnsigned(y.Negate().value)};
    bool overflow{!sameSign && diff.value.IsNegative() != isNegative};
    return {diff.value, overflow};
  }

  struct Product {
    FixedPoint upper, lower;
  };
  constexpr Product MultiplyUnsigned(const FixedPoint &y) const {
    Part product[2 * parts]{};  // little-endian full product
    for (int j{0}; j < parts; ++j) {
      if (Part xpart{LEPart(j)}) {
        for (int k{0}; k < parts; ++k) {
          if (Part ypart{y.LEPart(k)}) {
            BigPart xy{xpart};
            xy *= ypart;
            for (int to{j + k}; xy != 0; ++to) {
              xy += product[to];
              product[to] = xy & partMask;
              xy >>= partBits;
            }
          }
        }
      }
    }
    FixedPoint upper{nullptr}, lower{nullptr};
    for (int j{0}; j < parts; ++j) {
      lower.LEPart(j) = product[j];
      upper.LEPart(j) = product[j + parts];
    }
    if (topPartBits < partBits) {
      upper = upper.SHIFTL(partBits - topPartBits);
      upper.LEPart(0) |= lower.LEPart(parts - 1) >> topPartBits;
      lower.LEPart(parts - 1) &= topPartMask;
    }
    return {upper, lower};
  }

  constexpr Product MultiplySigned(const FixedPoint &y) const {
    bool yIsNegative{y.IsNegative()};
    FixedPoint absy{y};
    if (yIsNegative) {
      absy = y.Negate().value;
    }
    bool isNegative{IsNegative()};
    FixedPoint absx{*this};
    if (isNegative) {
      absx = Negate().value;
    }
    Product product{absx.MultiplyUnsigned(absy)};
    if (isNegative != yIsNegative) {
      product.lower = product.lower.NOT();
      product.upper = product.upper.NOT();
      FixedPoint one{std::uint64_t{1}};
      auto incremented{product.lower.AddUnsigned(one)};
      product.lower = incremented.value;
      if (incremented.carry) {
        product.upper = product.upper.AddUnsigned(one).value;
      }
    }
    return product;
  }

  // Overwrites *this with quotient.  Returns true on division by zero.
  constexpr bool DivideUnsigned(
      const FixedPoint &divisor, FixedPoint &remainder) {
    remainder.Clear();
    if (divisor.IsZero()) {
      *this = MASKR(bits);
      return true;
    }
    int bitsDone{LEADZ()};
    FixedPoint top{SHIFTL(bitsDone)};
    Clear();
    for (; bitsDone < bits; ++bitsDone) {
      auto doubledTop{top.AddUnsigned(top)};
      top = doubledTop.value;
      remainder = remainder.AddUnsigned(remainder, doubledTop.carry).value;
      bool nextBit{remainder.CompareUnsigned(divisor) != Ordering::Less};
      *this = AddUnsigned(*this, nextBit).value;
      if (nextBit) {
        remainder = remainder.SubtractSigned(divisor).value;
      }
    }
    return false;
  }

  // Overwrites *this with quotient.  Returns true on overflow (viz.,
  // the most negative value divided by -1) and on division by zero.
  // A nonzero remainder has the sign of the dividend, i.e., it is
  // the MOD intrinsic (X-INT(X/Y)*Y), not MODULO (below).
  // 8/5 = 1r3;  -8/5 = -1r-3;  8/-5 = -1r3;  -8/-5 = 1r-3
  constexpr bool DivideSigned(FixedPoint divisor, FixedPoint &remainder) {
    bool dividendIsNegative{IsNegative()};
    bool negateQuotient{dividendIsNegative};
    Ordering divisorOrdering{divisor.CompareToZeroSigned()};
    if (divisorOrdering == Ordering::Less) {
      negateQuotient = !negateQuotient;
      auto negated{divisor.Negate()};
      if (negated.overflow) {
        // divisor was (and is) the most negative number
        if (CompareUnsigned(divisor) == Ordering::Equal) {
          *this = MASKR(1);
          remainder.Clear();
          return bits <= 1;  // edge case: 1-bit signed numbers overflow on 1!
        } else {
          remainder = *this;
          Clear();
          return false;
        }
      }
      divisor = negated.value;
    } else if (divisorOrdering == Ordering::Equal) {
      // division by zero
      remainder.Clear();
      if (dividendIsNegative) {
        *this = MASKL(1);  // most negative signed number
      } else {
        *this = MASKR(bits - 1);  // most positive signed number
      }
      return true;
    }
    if (dividendIsNegative) {
      auto negated{Negate()};
      if (negated.overflow) {
        // Dividend was (and remains) the most negative number.
        // See whether the original divisor was -1 (if so, it's 1 now).
        if (divisorOrdering == Ordering::Less &&
            divisor.CompareUnsigned(FixedPoint{std::uint64_t{1}}) ==
                Ordering::Equal) {
          // most negative number / -1 is the sole overflow case
          remainder.Clear();
          return true;
        }
      } else {
        *this = negated.value;
      }
    }
    // Overflow is not possible, and both the dividend (*this) and divisor
    // are now positive.
    DivideUnsigned(divisor, remainder);
    if (negateQuotient) {
      *this = Negate().value;
    }
    if (dividendIsNegative) {
      remainder = remainder.Negate().value;
    }
    return false;
  }

  // MODULO intrinsic.  Returns true on overflow.  Has the sign of
  // the divisor argument.
  // 8 mod 5 = 3;  -8 mod 5 = 2;  8 mod -5 = -2;  -8 mod -5 = -3
  constexpr bool ModuloSigned(const FixedPoint &divisor) {
    FixedPoint quotient{*this};
    bool negativeDivisor{divisor.IsNegative()};
    bool distinctSigns{IsNegative() != negativeDivisor};
    bool overflow{quotient.DivideSigned(divisor, *this)};
    if (distinctSigns && !IsZero()) {
      *this = AddUnsigned(divisor).value;
    }
    return overflow;
  }

private:
  constexpr FixedPoint(std::nullptr_t) {}  // does not initialize

  // Accesses parts in little-endian order.
  constexpr const Part &LEPart(int part) const {
    if constexpr (littleEndian) {
      return part_[part];
    } else {
      return part_[parts - 1 - part];
    }
  }

  constexpr Part &LEPart(int part) {
    if constexpr (littleEndian) {
      return part_[part];
    } else {
      return part_[parts - 1 - part];
    }
  }

  constexpr void SetLEPart(int part, Part x) {
    LEPart(part) = x & PartMask(part);
  }

  static constexpr Part PartMask(int part) {
    return part == parts - 1 ? topPartMask : partMask;
  }

  constexpr void Clear() {
    for (int j{0}; j < parts; ++j) {
      part_[j] = 0;
    }
  }

  Part part_[parts];
};
}  // namespace Fortran::evaluate
#endif  // FORTRAN_EVALUATE_FIXED_POINT_H_
