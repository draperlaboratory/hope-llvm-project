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

#ifndef FORTRAN_PARSER_CHAR_BUFFER_H_
#define FORTRAN_PARSER_CHAR_BUFFER_H_

// Defines a simple expandable buffer suitable for efficiently accumulating
// a stream of bytes.

#include <cstddef>
#include <forward_list>
#include <string>
#include <utility>
#include <vector>

namespace Fortran::parser {

class CharBuffer {
public:
  CharBuffer() {}
  CharBuffer(CharBuffer &&that)
    : blocks_(std::move(that.blocks_)), last_{that.last_}, bytes_{that.bytes_},
      lastBlockEmpty_{that.lastBlockEmpty_} {
    that.clear();
  }
  CharBuffer &operator=(CharBuffer &&that) {
    blocks_ = std::move(that.blocks_);
    last_ = that.last_;
    bytes_ = that.bytes_;
    lastBlockEmpty_ = that.lastBlockEmpty_;
    that.clear();
    return *this;
  }

  bool empty() const { return bytes_ == 0; }
  std::size_t size() const { return bytes_; }

  void clear() {
    blocks_.clear();
    last_ = blocks_.end();
    bytes_ = 0;
    lastBlockEmpty_ = false;
  }

  char *FreeSpace(std::size_t *);
  void Claim(std::size_t);
  void Put(const char *data, std::size_t n);
  void Put(const std::string &);
  void Put(char x) { Put(&x, 1); }

  std::string Marshal() const;

  // Removes carriage returns ('\r') and ensures a final line feed ('\n').
  std::string MarshalNormalized() const;

private:
  struct Block {
    static constexpr std::size_t capacity{1 << 20};
    char data[capacity];
  };

  int LastBlockOffset() const { return bytes_ % Block::capacity; }
  std::forward_list<Block> blocks_;
  std::forward_list<Block>::iterator last_{blocks_.end()};
  std::size_t bytes_{0};
  bool lastBlockEmpty_{false};
};

}  // namespace Fortran::parser
#endif  // FORTRAN_PARSER_CHAR_BUFFER_H_
