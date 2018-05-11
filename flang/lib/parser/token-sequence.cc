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

#include "token-sequence.h"
#include "characters.h"

namespace Fortran::parser {

TokenSequence &TokenSequence::operator=(TokenSequence &&that) {
  clear();
  swap(that);
  return *this;
}

void TokenSequence::clear() {
  start_.clear();
  nextStart_ = 0;
  char_.clear();
  provenances_.clear();
}

void TokenSequence::pop_back() {
  std::size_t bytes{nextStart_ - start_.back()};
  nextStart_ = start_.back();
  start_.pop_back();
  char_.resize(nextStart_);
  provenances_.RemoveLastBytes(bytes);
}

void TokenSequence::shrink_to_fit() {
  start_.shrink_to_fit();
  char_.shrink_to_fit();
  provenances_.shrink_to_fit();
}

void TokenSequence::swap(TokenSequence &that) {
  start_.swap(that.start_);
  std::swap(nextStart_, that.nextStart_);
  char_.swap(that.char_);
  provenances_.swap(that.provenances_);
}

void TokenSequence::Put(const TokenSequence &that) {
  if (nextStart_ < char_.size()) {
    start_.push_back(nextStart_);
  }
  int offset = char_.size();
  for (int st : that.start_) {
    start_.push_back(st + offset);
  }
  char_.insert(char_.end(), that.char_.begin(), that.char_.end());
  nextStart_ = char_.size();
  provenances_.Put(that.provenances_);
}

void TokenSequence::Put(const TokenSequence &that, ProvenanceRange range) {
  std::size_t offset{0};
  std::size_t tokens{that.SizeInTokens()};
  for (std::size_t j{0}; j < tokens; ++j) {
    CharBlock tok{that.TokenAt(j)};
    Put(tok, range.OffsetMember(offset));
    offset += tok.size();
  }
  CHECK(offset == range.size());
}

void TokenSequence::Put(
    const TokenSequence &that, std::size_t at, std::size_t tokens) {
  ProvenanceRange provenance;
  std::size_t offset{0};
  for (; tokens-- > 0; ++at) {
    CharBlock tok{that.TokenAt(at)};
    std::size_t tokBytes{tok.size()};
    for (std::size_t j{0}; j < tokBytes; ++j) {
      if (offset == provenance.size()) {
        provenance = that.provenances_.Map(that.start_[at] + j);
        offset = 0;
      }
      PutNextTokenChar(tok[j], provenance.OffsetMember(offset++));
    }
    CloseToken();
  }
}

void TokenSequence::Put(
    const char *s, std::size_t bytes, Provenance provenance) {
  for (std::size_t j{0}; j < bytes; ++j) {
    PutNextTokenChar(s[j], provenance + j);
  }
  CloseToken();
}

void TokenSequence::Put(const CharBlock &t, Provenance provenance) {
  Put(&t[0], t.size(), provenance);
}

void TokenSequence::Put(const std::string &s, Provenance provenance) {
  Put(s.data(), s.size(), provenance);
}

void TokenSequence::Put(const std::stringstream &ss, Provenance provenance) {
  Put(ss.str(), provenance);
}

TokenSequence &TokenSequence::ToLowerCase() {
  std::size_t tokens{start_.size()};
  std::size_t chars{char_.size()};
  std::size_t atToken{0};
  for (std::size_t j{0}; j < chars;) {
    std::size_t nextStart{atToken + 1 < tokens ? start_[++atToken] : chars};
    char *p{&char_[j]}, *limit{&char_[nextStart]};
    j = nextStart;
    if (IsDecimalDigit(*p)) {
      while (p < limit && IsDecimalDigit(*p)) {
        ++p;
      }
      if (p < limit && (*p == 'h' || *p == 'H')) {
        // Hollerith
        *p = 'h';
      } else {
        // exponent
        for (; p < limit; ++p) {
          *p = ToLowerCaseLetter(*p);
        }
      }
    } else if (limit[-1] == '\'' || limit[-1] == '"') {
      if (*p == limit[-1]) {
        // Character literal without prefix
      } else if (p[1] == limit[-1]) {
        // BOZX-prefixed constant
        for (; p < limit; ++p) {
          *p = ToLowerCaseLetter(*p);
        }
      } else {
        // Kanji NC'...' character literal or literal with kind-param prefix.
        for (; *p != limit[-1]; ++p) {
          *p = ToLowerCaseLetter(*p);
        }
      }
    } else {
      for (; p < limit; ++p) {
        *p = ToLowerCaseLetter(*p);
      }
    }
  }
  return *this;
}

bool TokenSequence::HasBlanks() const {
  std::size_t tokens{SizeInTokens()};
  for (std::size_t j{0}; j < tokens; ++j) {
    if (TokenAt(j).IsBlank()) {
      return true;
    }
  }
  return false;
}

bool TokenSequence::HasRedundantBlanks() const {
  std::size_t tokens{SizeInTokens()};
  bool lastWasBlank{false};
  for (std::size_t j{0}; j < tokens; ++j) {
    bool isBlank{TokenAt(j).IsBlank()};
    if (isBlank && lastWasBlank) {
      return true;
    }
    lastWasBlank = isBlank;
  }
  return false;
}

TokenSequence &TokenSequence::RemoveBlanks() {
  std::size_t tokens{SizeInTokens()};
  TokenSequence result;
  for (std::size_t j{0}; j < tokens; ++j) {
    if (!TokenAt(j).IsBlank()) {
      result.Put(*this, j);
    }
  }
  swap(result);
  return *this;
}

TokenSequence &TokenSequence::RemoveRedundantBlanks() {
  std::size_t tokens{SizeInTokens()};
  TokenSequence result;
  bool lastWasBlank{false};
  for (std::size_t j{0}; j < tokens; ++j) {
    bool isBlank{TokenAt(j).IsBlank()};
    if (isBlank && lastWasBlank) {
      continue;
    }
    lastWasBlank = isBlank;
    result.Put(*this, j);
  }
  swap(result);
  return *this;
}

void TokenSequence::Emit(CookedSource &cooked) const {
  cooked.Put(&char_[0], char_.size());
  cooked.PutProvenanceMappings(provenances_);
}

void TokenSequence::Dump(std::ostream &o) const {
  o << "TokenSequence has " << char_.size() << " chars; nextStart_ "
    << nextStart_ << '\n';
  for (std::size_t j{0}; j < start_.size(); ++j) {
    o << '[' << j << "] @ " << start_[j] << " '" << TokenAt(j).ToString()
      << "'\n";
  }
}

Provenance TokenSequence::GetTokenProvenance(
    std::size_t token, std::size_t offset) const {
  ProvenanceRange range{provenances_.Map(start_[token] + offset)};
  return range.start();
}

ProvenanceRange TokenSequence::GetTokenProvenanceRange(
    std::size_t token, std::size_t offset) const {
  ProvenanceRange range{provenances_.Map(start_[token] + offset)};
  return range.Prefix(TokenBytes(token) - offset);
}

ProvenanceRange TokenSequence::GetIntervalProvenanceRange(
    std::size_t token, std::size_t tokens) const {
  if (tokens == 0) {
    return {};
  }
  ProvenanceRange range{provenances_.Map(start_[token])};
  while (--tokens > 0 &&
      range.AnnexIfPredecessor(provenances_.Map(start_[++token]))) {
  }
  return range;
}

ProvenanceRange TokenSequence::GetProvenanceRange() const {
  return GetIntervalProvenanceRange(0, start_.size());
}
}  // namespace Fortran::parser
