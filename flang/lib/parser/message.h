#ifndef FORTRAN_PARSER_MESSAGE_H_
#define FORTRAN_PARSER_MESSAGE_H_

// Defines a representation for sequences of compiler messages.
// Supports nested contextualization.

#include "idioms.h"
#include "provenance.h"
#include "reference-counted.h"
#include <cstddef>
#include <forward_list>
#include <optional>
#include <ostream>
#include <string>
#include <utility>

namespace Fortran {
namespace parser {

// Use "..."_err_en_US and "..."_en_US literals to define the static
// text and fatality of a message.
class MessageFixedText {
public:
  MessageFixedText() {}
  constexpr MessageFixedText(
      const char str[], std::size_t n, bool isFatal = false)
    : str_{str}, bytes_{n}, isFatal_{isFatal} {}
  constexpr MessageFixedText(const MessageFixedText &) = default;
  MessageFixedText(MessageFixedText &&) = default;
  constexpr MessageFixedText &operator=(const MessageFixedText &) = default;
  MessageFixedText &operator=(MessageFixedText &&) = default;

  const char *str() const { return str_; }
  std::size_t size() const { return bytes_; }
  bool empty() const { return bytes_ == 0; }
  bool isFatal() const { return isFatal_; }

  std::string ToString() const;

private:
  const char *str_{nullptr};
  std::size_t bytes_{0};
  bool isFatal_{false};
};

inline namespace literals {
constexpr MessageFixedText operator""_en_US(const char str[], std::size_t n) {
  return MessageFixedText{str, n, false /* not fatal */};
}

constexpr MessageFixedText operator""_err_en_US(
    const char str[], std::size_t n) {
  return MessageFixedText{str, n, true /* fatal */};
}
}  // namespace literals

std::ostream &operator<<(std::ostream &, const MessageFixedText &);

class MessageFormattedText {
public:
  MessageFormattedText(MessageFixedText, ...);
  std::string MoveString() { return std::move(string_); }
  bool isFatal() const { return isFatal_; }

private:
  std::string string_;
  bool isFatal_{false};
};

// Represents a formatted rendition of "expected '%s'"_err_en_US
// on a constant text.
class MessageExpectedText {
public:
  MessageExpectedText(const char *s, std::size_t n) : str_{s}, bytes_{n} {}
  explicit MessageExpectedText(char ch) : singleton_{ch} {}
  MessageFixedText AsMessageFixedText() const;

private:
  const char *str_{nullptr};
  char singleton_;
  std::size_t bytes_{1};
};


class Message : public ReferenceCounted<Message> {
public:
  using Context = CountedReference<Message>;

  Message() {}
  Message(Message &&) = default;
  Message &operator=(Message &&that) = default;

  // TODO: Change these to cover ranges of provenance
  Message(Provenance p, MessageFixedText t, Message *c = nullptr)
    : provenance_{p}, text_{t}, context_{c}, isFatal_{t.isFatal()} {}
  Message(Provenance p, MessageFormattedText &&s, Message *c = nullptr)
    : provenance_{p}, string_{s.MoveString()}, context_{c},
      isFatal_{s.isFatal()} {}
  Message(Provenance p, MessageExpectedText t, Message *c = nullptr)
    : provenance_{p}, text_{t.AsMessageFixedText()},
      isExpectedText_{true}, context_{c}, isFatal_{true} {}

  Message(const char *csl, MessageFixedText t, Message *c = nullptr)
    : cookedSourceLocation_{csl}, text_{t}, context_{c}, isFatal_{t.isFatal()} {}
  Message(const char *csl, MessageFormattedText &&s, Message *c = nullptr)
    : cookedSourceLocation_{csl}, string_{s.MoveString()}, context_{c},
      isFatal_{s.isFatal()} {}
  Message(const char *csl, MessageExpectedText t, Message *c = nullptr)
    : cookedSourceLocation_{csl}, text_{t.AsMessageFixedText()},
      isExpectedText_{true}, context_{c}, isFatal_{true} {}

  bool operator<(const Message &that) const {
    if (cookedSourceLocation_ != nullptr) {
      return cookedSourceLocation_ < that.cookedSourceLocation_;
    } else if (that.cookedSourceLocation_ != nullptr) {
      return false;
    } else {
      return provenance_ < that.provenance_;
    }
  }

  Provenance provenance() const { return provenance_; }
  const char *cookedSourceLocation() const { return cookedSourceLocation_; }
  Context context() const { return context_; }
  bool isFatal() const { return isFatal_; }

  Provenance Emit(
      std::ostream &, const CookedSource &, bool echoSourceLine = true) const;

private:
  Provenance provenance_;
  const char *cookedSourceLocation_{nullptr};
  MessageFixedText text_;
  bool isExpectedText_{false};  // implies "expected '%s'"_err_en_US
  std::string string_;
  Context context_;
  bool isFatal_{false};
};

class Messages {
  using listType = std::forward_list<Message>;

public:
  using iterator = listType::iterator;
  using const_iterator = listType::const_iterator;

  explicit Messages(const CookedSource &cooked) : cooked_{cooked} {}
  Messages(Messages &&that)
    : cooked_{that.cooked_}, messages_{std::move(that.messages_)} {
    if (!messages_.empty()) {
      last_ = that.last_;
      that.last_ = that.messages_.before_begin();
    }
  }
  Messages &operator=(Messages &&that) {
    messages_ = std::move(that.messages_);
    if (messages_.empty()) {
      last_ = messages_.before_begin();
    } else {
      last_ = that.last_;
      that.last_ = that.messages_.before_begin();
    }
    return *this;
  }

  bool empty() const { return messages_.empty(); }
  iterator begin() { return messages_.begin(); }
  iterator end() { return messages_.end(); }
  const_iterator begin() const { return messages_.cbegin(); }
  const_iterator end() const { return messages_.cend(); }
  const_iterator cbegin() const { return messages_.cbegin(); }
  const_iterator cend() const { return messages_.cend(); }

  const CookedSource &cooked() const { return cooked_; }

  bool IsValidLocation(const Message &m) {
    if (auto p{m.cookedSourceLocation()}) {
      return cooked_.IsValid(p);
    } else {
      return cooked_.IsValid(m.provenance());
    }
  }

  void Put(Message &&m) {
    CHECK(IsValidLocation(m));
    last_ = messages_.emplace_after(last_, std::move(m));
  }

  template<typename... A> void Say(A &&... args) {
    last_ = messages_.emplace_after(last_, std::forward<A>(args)...);
  }

  void Annex(Messages &that) {
    if (!that.messages_.empty()) {
      messages_.splice_after(last_, that.messages_);
      last_ = that.last_;
      that.last_ = that.messages_.before_begin();
    }
  }

  void Emit(std::ostream &, const char *prefix = nullptr,
      bool echoSourceLines = true) const;

  bool AnyFatalError() const;

private:
  const CookedSource &cooked_;
  listType messages_;
  iterator last_{messages_.before_begin()};
};
}  // namespace parser
}  // namespace Fortran
#endif  // FORTRAN_PARSER_MESSAGE_H_
