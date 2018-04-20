#ifndef FORTRAN_PARSER_TOKEN_PARSERS_H_
#define FORTRAN_PARSER_TOKEN_PARSERS_H_

// These parsers are driven by the Fortran grammar (grammar.h) to consume
// the prescanned character stream and recognize context-sensitive tokens.

#include "basic-parsers.h"
#include "char-set.h"
#include "characters.h"
#include "idioms.h"
#include "provenance.h"
#include <cstddef>
#include <cstring>
#include <functional>
#include <limits>
#include <list>
#include <optional>
#include <string>

namespace Fortran {
namespace parser {

// "xyz"_ch matches one instance of the characters x, y, or z without skipping
// any spaces before or after.  The parser returns the location of the character
// on success.
class AnyOfChars {
public:
  using resultType = const char *;
  constexpr AnyOfChars(const AnyOfChars &) = default;
  constexpr AnyOfChars(SetOfChars set) : set_{set} {}
  std::optional<const char *> Parse(ParseState *state) const {
    if (std::optional<const char *> at{state->PeekAtNextChar()}) {
      if (set_.Has(**at)) {
        state->UncheckedAdvance();
        return at;
      }
    }
    state->Say(MessageExpectedText{set_});
    return {};
  }

private:
  const SetOfChars set_;
};

constexpr AnyOfChars operator""_ch(const char str[], std::size_t n) {
  return AnyOfChars{SetOfChars(str, n)};
}

constexpr auto letter = "abcdefghijklmnopqrstuvwxyz"_ch;
constexpr auto digit = "0123456789"_ch;

// Skips over optional spaces.  Always succeeds.
constexpr struct Space {
  using resultType = Success;
  constexpr Space() {}
  static std::optional<Success> Parse(ParseState *state) {
    while (std::optional<const char *> p{state->PeekAtNextChar()}) {
      if (**p != ' ') {
        break;
      }
      state->UncheckedAdvance();
    }
    return {Success{}};
  }
} space;

// Skips a space that in free form requires a warning if it precedes a
// character that could begin an identifier or keyword.  Always succeeds.
inline void MissingSpace(ParseState *state) {
  if (!state->inFixedForm()) {
    state->set_anyConformanceViolation();
    if (state->warnOnNonstandardUsage()) {
      state->Say("expected space"_err_en_US);
    }
  }
}

constexpr struct SpaceCheck {
  using resultType = Success;
  constexpr SpaceCheck() {}
  static std::optional<Success> Parse(ParseState *state) {
    if (std::optional<const char *> p{state->PeekAtNextChar()}) {
      char ch{**p};
      if (ch == ' ') {
        state->UncheckedAdvance();
        return space.Parse(state);
      }
      if (IsLegalInIdentifier(ch)) {
        MissingSpace(state);
      }
    }
    return {Success{}};
  }
} spaceCheck;

// Matches a token string.  Spaces in the token string denote where
// spaces may appear in the source; they can be made mandatory for
// some free form keyword sequences.  Missing mandatory spaces in free
// form elicit a warning; they are not necessary for recognition.
// Spaces before and after the token are also skipped.
//
// Token strings appear in the grammar as C++ user-defined literals
// like "BIND ( C )"_tok and "SYNC ALL"_sptok.  The _tok suffix is implied
// when a string literal appears before the sequencing operator >> or
// after the sequencing operator /.
class TokenStringMatch {
public:
  using resultType = Success;
  constexpr TokenStringMatch(const TokenStringMatch &) = default;
  constexpr TokenStringMatch(const char *str, std::size_t n, bool mandatory)
    : str_{str}, bytes_{n}, mandatoryFreeFormSpace_{mandatory} {}
  constexpr TokenStringMatch(const char *str, bool mandatory)
    : str_{str}, mandatoryFreeFormSpace_{mandatory} {}
  std::optional<Success> Parse(ParseState *state) const {
    space.Parse(state);
    const char *start{state->GetLocation()};
    const char *p{str_};
    std::optional<const char *> at;  // initially empty
    for (std::size_t j{0}; j < bytes_ && *p != '\0'; ++j, ++p) {
      const auto spaceSkipping{*p == ' '};
      if (spaceSkipping) {
        if (j + 1 == bytes_ || p[1] == ' ' || p[1] == '\0') {
          continue;  // redundant; ignore
        }
      }
      if (!at.has_value()) {
        at = nextCh.Parse(state);
        if (!at.has_value()) {
          return {};
        }
      }
      if (spaceSkipping) {
        if (**at == ' ') {
          at = nextCh.Parse(state);
          if (!at.has_value()) {
            return {};
          }
        } else if (mandatoryFreeFormSpace_) {
          MissingSpace(state);
        }
        // 'at' remains full for next iteration
      } else if (**at == ToLowerCaseLetter(*p)) {
        at.reset();
      } else {
        state->Say(start, MessageExpectedText{str_, bytes_});
        return {};
      }
    }
    if (IsLegalInIdentifier(p[-1])) {
      return spaceCheck.Parse(state);
    } else {
      return space.Parse(state);
    }
  }

private:
  const char *const str_;
  const std::size_t bytes_{std::string::npos};
  const bool mandatoryFreeFormSpace_;
};

constexpr TokenStringMatch operator""_tok(const char str[], std::size_t n) {
  return TokenStringMatch{str, n, false};
}

constexpr TokenStringMatch operator""_sptok(const char str[], std::size_t n) {
  return TokenStringMatch{str, n, true};
}

template<class PA, std::enable_if_t<std::is_class<PA>::value, int> = 0>
inline constexpr SequenceParser<TokenStringMatch, PA> operator>>(
    const char *str, const PA &p) {
  return SequenceParser<TokenStringMatch, PA>{TokenStringMatch{str, false}, p};
}

template<class PA, std::enable_if_t<std::is_class<PA>::value, int> = 0>
inline constexpr InvertedSequenceParser<PA, TokenStringMatch> operator/(
    const PA &p, const char *str) {
  return InvertedSequenceParser<PA, TokenStringMatch>{
      p, TokenStringMatch{str, false}};
}

template<class PA>
inline constexpr SequenceParser<TokenStringMatch,
    InvertedSequenceParser<PA, TokenStringMatch>>
parenthesized(const PA &p) {
  return "(" >> p / ")";
}

template<class PA>
inline constexpr SequenceParser<TokenStringMatch,
    InvertedSequenceParser<PA, TokenStringMatch>>
bracketed(const PA &p) {
  return "[" >> p / "]";
}

// Quoted character literal constants.
struct CharLiteralChar {
  struct Result {
    Result(char c, bool esc) : ch{c}, wasEscaped{esc} {}
    static Result Bare(char c) { return Result{c, false}; }
    static Result Escaped(char c) { return Result{c, true}; }
    char ch;
    bool wasEscaped;
  };
  using resultType = Result;
  static std::optional<Result> Parse(ParseState *state) {
    auto at = state->GetLocation();
    std::optional<const char *> och{nextCh.Parse(state)};
    if (!och.has_value()) {
      return {};
    }
    char ch{**och};
    if (ch == '\n') {
      state->Say(at, "unclosed character constant"_err_en_US);
      return {};
    }
    if (ch != '\\') {
      return {Result::Bare(ch)};
    }
    if (!(och = nextCh.Parse(state)).has_value()) {
      return {};
    }
    ch = **och;
    if (ch == '\n') {
      state->Say(at, "unclosed character constant"_err_en_US);
      return {};
    }
    if (std::optional<char> escChar{BackslashEscapeValue(ch)}) {
      return {Result::Escaped(*escChar)};
    }
    if (IsOctalDigit(ch)) {
      ch -= '0';
      for (int j = (ch > 3 ? 1 : 2); j-- > 0;) {
        static constexpr auto octalDigit = "01234567"_ch;
        och = octalDigit.Parse(state);
        if (och.has_value()) {
          ch = 8 * ch + **och - '0';
        } else {
          break;
        }
      }
    } else if (ch == 'x' || ch == 'X') {
      ch = 0;
      for (int j = 0; j++ < 2;) {
        static constexpr auto hexDigit = "0123456789abcdefABCDEF"_ch;
        och = hexDigit.Parse(state);
        if (och.has_value()) {
          ch = 16 * ch + HexadecimalDigitValue(**och);
        } else {
          break;
        }
      }
    } else {
      state->Say(at, "bad escaped character"_en_US);
    }
    return {Result::Escaped(ch)};
  }
};

template<char quote> struct CharLiteral {
  using resultType = std::string;
  static std::optional<std::string> Parse(ParseState *state) {
    std::string str;
    static constexpr auto nextch = attempt(CharLiteralChar{});
    while (std::optional<CharLiteralChar::Result> ch{nextch.Parse(state)}) {
      if (ch->ch == quote && !ch->wasEscaped) {
        static constexpr auto doubled = attempt(AnyOfChars{SetOfChars{quote}});
        if (!doubled.Parse(state).has_value()) {
          return {str};
        }
      }
      str += ch->ch;
    }
    return {};
  }
};

static bool IsNonstandardUsageOk(ParseState *state) {
  if (state->strictConformance()) {
    return false;
  }
  state->set_anyConformanceViolation();
  if (state->warnOnNonstandardUsage()) {
    state->Say("nonstandard usage"_en_US);
  }
  return true;
}

// Parse "BOZ" binary literal quoted constants.
// As extensions, support X as an alternate hexadecimal marker, and allow
// BOZX markers to appear as suffixes.
struct BOZLiteral {
  using resultType = std::uint64_t;
  static std::optional<std::uint64_t> Parse(ParseState *state) {
    std::optional<int> shift;
    auto baseChar = [&shift](char ch) -> bool {
      switch (ch) {
      case 'b': shift = 1; return true;
      case 'o': shift = 3; return true;
      case 'z': shift = 4; return true;
      case 'x': shift = 4; return true;
      default: return false;
      }
    };

    space.Parse(state);
    const char *start{state->GetLocation()};
    std::optional<const char *> at{nextCh.Parse(state)};
    if (!at.has_value()) {
      return {};
    }
    if (**at == 'x' && !IsNonstandardUsageOk(state)) {
      return {};
    }
    if (baseChar(**at)) {
      at = nextCh.Parse(state);
      if (!at.has_value()) {
        return {};
      }
    }

    char quote = **at;
    if (quote != '\'' && quote != '"') {
      return {};
    }

    std::string content;
    while (true) {
      at = nextCh.Parse(state);
      if (!at.has_value()) {
        return {};
      }
      if (**at == quote) {
        break;
      }
      if (**at == ' ') {
        continue;
      }
      if (!IsHexadecimalDigit(**at)) {
        return {};
      }
      content += **at;
    }

    if (!shift) {
      // extension: base allowed to appear as suffix, too
      if (!IsNonstandardUsageOk(state) || !(at = nextCh.Parse(state)) ||
          !baseChar(**at)) {
        return {};
      }
      spaceCheck.Parse(state);
    }

    if (content.empty()) {
      state->Say(start, "no digit in BOZ literal"_err_en_US);
      return {};
    }

    std::uint64_t value{0};
    for (auto digit : content) {
      digit = HexadecimalDigitValue(digit);
      if ((digit >> *shift) > 0) {
        state->Say(start, "bad digit in BOZ literal"_err_en_US);
        return {};
      }
      std::uint64_t was{value};
      value <<= *shift;
      if ((value >> *shift) != was) {
        state->Say(start, "excessive digits in BOZ literal"_err_en_US);
        return {};
      }
      value |= digit;
    }
    return {value};
  }
};

// Unsigned decimal digit string; no space skipping
struct DigitString {
  using resultType = std::uint64_t;
  static std::optional<std::uint64_t> Parse(ParseState *state) {
    static constexpr auto getDigit = attempt(digit);
    std::optional<const char *> firstDigit{getDigit.Parse(state)};
    if (!firstDigit.has_value()) {
      return {};
    }
    std::uint64_t value = **firstDigit - '0';
    bool overflow{false};
    while (auto nextDigit{getDigit.Parse(state)}) {
      if (value > std::numeric_limits<std::uint64_t>::max() / 10) {
        overflow = true;
      }
      value *= 10;
      int digitValue = **nextDigit - '0';
      if (value > std::numeric_limits<std::uint64_t>::max() - digitValue) {
        overflow = true;
      }
      value += digitValue;
    }
    if (overflow) {
      state->Say(*firstDigit, "overflow in decimal literal"_err_en_US);
    }
    return {value};
  }
};

constexpr struct SkipDigitString {
  using resultType = Success;
  static std::optional<Success> Parse(ParseState *state) {
    if (std::optional<const char *> ch1{state->PeekAtNextChar()}) {
      if (IsDecimalDigit(**ch1)) {
        state->UncheckedAdvance();
        while (std::optional<const char *> p{state->PeekAtNextChar()}) {
          if (!IsDecimalDigit(**p)) {
            break;
          }
          state->UncheckedAdvance();
        }
        return {Success{}};
      }
    }
    return {};
  }
} skipDigitString;

struct DigitStringAsPositive {
  using resultType = std::int64_t;
  static std::optional<std::int64_t> Parse(ParseState *state) {
    Location at{state->GetLocation()};
    std::optional<std::uint64_t> x{DigitString{}.Parse(state)};
    if (!x.has_value()) {
      return {};
    }
    if (*x > std::numeric_limits<std::int64_t>::max()) {
      state->Say(at, "overflow in positive decimal literal"_err_en_US);
    }
    std::int64_t value = *x;
    return {value};
  }
};

struct SignedDigitString {
  using resultType = std::int64_t;
  static std::optional<std::int64_t> Parse(ParseState *state) {
    std::optional<const char *> sign{state->PeekAtNextChar()};
    if (!sign.has_value()) {
      return {};
    }
    bool negate{**sign == '-'};
    if (negate || **sign == '+') {
      state->UncheckedAdvance();
    }
    std::optional<std::uint64_t> x{DigitString{}.Parse(state)};
    if (!x.has_value()) {
      return {};
    }
    std::uint64_t limit{std::numeric_limits<std::int64_t>::max()};
    if (negate) {
      limit = -(limit + 1);
    }
    if (*x > limit) {
      state->Say(*sign, "overflow in signed decimal literal"_err_en_US);
    }
    std::int64_t value = *x;
    return {negate ? -value : value};
  }
};

// Legacy feature: Hollerith literal constants
struct HollerithLiteral {
  using resultType = std::string;
  static std::optional<std::string> Parse(ParseState *state) {
    space.Parse(state);
    const char *start{state->GetLocation()};
    std::optional<std::uint64_t> charCount{DigitString{}.Parse(state)};
    if (!charCount || *charCount < 1) {
      return {};
    }
    static const auto letterH = "h"_ch;
    std::optional<const char *> h{letterH.Parse(state)};
    if (!h.has_value()) {
      return {};
    }
    std::string content;
    for (auto j = *charCount; j-- > 0;) {
      int bytes{1};
      const char *p{state->GetLocation()};
      if (state->encoding() == Encoding::EUC_JP) {
        std::optional<int> chBytes{EUC_JPCharacterBytes(p)};
        if (!chBytes.has_value()) {
          state->Say(start, "bad EUC_JP characters in Hollerith"_err_en_US);
          return {};
        }
        bytes = *chBytes;
      } else if (state->encoding() == Encoding::UTF8) {
        std::optional<int> chBytes{UTF8CharacterBytes(p)};
        if (!chBytes.has_value()) {
          state->Say(start, "bad UTF-8 characters in Hollerith"_err_en_US);
          return {};
        }
        bytes = *chBytes;
      }
      if (bytes == 1) {
        std::optional<const char *> at{nextCh.Parse(state)};
        if (!at.has_value() || !isprint(**at)) {
          state->Say(
              start, "insufficient or bad characters in Hollerith"_err_en_US);
          return {};
        }
        content += **at;
      } else {
        // Multi-byte character
        while (bytes-- > 0) {
          std::optional<const char *> byte{nextCh.Parse(state)};
          CHECK(byte.has_value());
          content += **byte;
        }
      }
    }
    return {content};
  }
};

struct ConsumedAllInputParser {
  using resultType = Success;
  constexpr ConsumedAllInputParser() {}
  static std::optional<Success> Parse(ParseState *state) {
    if (state->IsAtEnd()) {
      return {Success{}};
    }
    return {};
  }
} consumedAllInput;

template<char goal> struct SkipPast {
  using resultType = Success;
  constexpr SkipPast() {}
  constexpr SkipPast(const SkipPast &) {}
  static std::optional<Success> Parse(ParseState *state) {
    while (std::optional<const char *> p{state->GetNextChar()}) {
      if (**p == goal) {
        return {Success{}};
      }
    }
    return {};
  }
};

template<char goal> struct SkipTo {
  using resultType = Success;
  constexpr SkipTo() {}
  constexpr SkipTo(const SkipTo &) {}
  static std::optional<Success> Parse(ParseState *state) {
    while (std::optional<const char *> p{state->PeekAtNextChar()}) {
      if (**p == goal) {
        return {Success{}};
      }
      state->UncheckedAdvance();
    }
    return {};
  }
};

// A common idiom in the Fortran grammar is an optional item (usually
// a nonempty comma-separated list) that, if present, must follow a comma
// and precede a doubled colon.  When the item is absent, the comma must
// not appear, and the doubled colons are optional.
//   [[, xyz] ::]     is  optionalBeforeColons(xyz)
//   [[, xyz]... ::]  is  optionalBeforeColons(nonemptyList(xyz))
template<typename PA> inline constexpr auto optionalBeforeColons(const PA &p) {
  return "," >> construct<std::optional<typename PA::resultType>>{}(p) / "::" ||
      ("::"_tok || !","_tok) >> defaulted(cut >> maybe(p));
}
template<typename PA>
inline constexpr auto optionalListBeforeColons(const PA &p) {
  return "," >> nonemptyList(p) / "::" ||
      ("::"_tok || !","_tok) >> defaulted(cut >> nonemptyList(p));
}

// Compiler directives can switch the parser between fixed and free form.
constexpr struct FormDirectivesAndEmptyLines {
  using resultType = Success;
  static std::optional<Success> Parse(ParseState *state) {
    if (UserState * ustate{state->userState()}) {
      if (ParsingLog * log{ustate->log()}) {
        if (!ustate->instrumentedParse()) {
          // Save memory; zap the parsing log before each statement, unless
          // we're logging the whole parse for debugging.
          log->clear();
        }
      }
    }
    while (std::optional<const char *> at{state->PeekAtNextChar()}) {
      if (**at == '\n') {
        state->UncheckedAdvance();
      } else if (**at == '!') {
        static const char fixed[] = "!dir$ fixed\n", free[] = "!dir$ free\n";
        static constexpr std::size_t fixedBytes{sizeof fixed - 1};
        static constexpr std::size_t freeBytes{sizeof free - 1};
        std::size_t remain{state->BytesRemaining()};
        if (remain >= fixedBytes && std::memcmp(*at, fixed, fixedBytes) == 0) {
          state->set_inFixedForm(true).UncheckedAdvance(fixedBytes);
        } else if (remain >= freeBytes &&
            std::memcmp(*at, free, freeBytes) == 0) {
          state->set_inFixedForm(false).UncheckedAdvance(freeBytes);
        } else {
          break;
        }
      } else {
        break;
      }
    }
    return {Success{}};
  }
} skipEmptyLines;
}  // namespace parser
}  // namespace Fortran
#endif  // FORTRAN_PARSER_TOKEN_PARSERS_H_
