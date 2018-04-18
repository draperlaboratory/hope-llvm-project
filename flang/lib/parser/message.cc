#include "message.h"
#include "char-set.h"
#include <cstdarg>
#include <cstddef>
#include <cstdio>
#include <cstring>

namespace Fortran {
namespace parser {

std::ostream &operator<<(std::ostream &o, const MessageFixedText &t) {
  for (std::size_t j{0}; j < t.size(); ++j) {
    o << t.str()[j];
  }
  return o;
}

std::string MessageFixedText::ToString() const {
  return std::string{str_, /*not in std::*/ strnlen(str_, bytes_)};
}

MessageFormattedText::MessageFormattedText(MessageFixedText text, ...)
  : isFatal_{text.isFatal()} {
  const char *p{text.str()};
  std::string asString;
  if (p[text.size()] != '\0') {
    // not NUL-terminated
    asString = text.ToString();
    p = asString.data();
  }
  char buffer[256];
  va_list ap;
  va_start(ap, text);
  vsnprintf(buffer, sizeof buffer, p, ap);
  va_end(ap);
  string_ = buffer;
}

std::string Message::ToString() const {
  std::string s{string_};
  bool isExpected{isExpected_};
  if (string_.empty()) {
    if (fixedText_ != nullptr) {
      if (fixedBytes_ > 0) {
        s = std::string{fixedText_, fixedBytes_};
      } else {
        s = std::string{fixedText_};  // NUL-terminated
      }
    } else {
      s = SetOfCharsToString(expected_);
      if (!IsSingleton(expected_)) {
        return MessageFormattedText("expected one of '%s'"_err_en_US, s)
            .MoveString();
      }
      if (expected_ == SingletonChar('\n')) {
        return "expected end of line"_err_en_US.ToString();
      }
      isExpected = true;
    }
  }
  if (isExpected) {
    return MessageFormattedText("expected '%s'"_err_en_US, s).MoveString();
  }
  return s;
}

Provenance Message::Emit(
    std::ostream &o, const CookedSource &cooked, bool echoSourceLine) const {
  Provenance provenance{provenance_};
  if (cookedSourceLocation_ != nullptr) {
    provenance = cooked.GetProvenance(cookedSourceLocation_).start();
  }
  if (!context_ || context_->Emit(o, cooked, false) != provenance) {
    cooked.allSources().Identify(o, provenance, "", echoSourceLine);
  }
  o << "   ";
  if (isFatal_) {
    o << "ERROR: ";
  }
  o << ToString() << '\n';
  return provenance;
}

void Messages::Emit(
    std::ostream &o, const char *prefix, bool echoSourceLines) const {
  for (const auto &msg : messages_) {
    if (prefix) {
      o << prefix;
    }
    if (msg.context()) {
      o << "In the context ";
    }
    msg.Emit(o, cooked_, echoSourceLines);
  }
}

bool Messages::AnyFatalError() const {
  for (const auto &msg : messages_) {
    if (msg.isFatal()) {
      return true;
    }
  }
  return false;
}
}  // namespace parser
}  // namespace Fortran
