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

#ifndef FORTRAN_SEMANTICS_LABELTABLE_H_
#define FORTRAN_SEMANTICS_LABELTABLE_H_

#include <cassert>
#include <stack>

namespace Fortran::semantics {

// Each statement label is in one of those groups    
enum class LabelGroup
{
  BranchTarget, ///< A label a possible branch target
  Format,       ///< A label on a FORMAT statement
  Other         ///< A label on another statement  
};

  
//
// Hold all the labels of a Program Unit 
//
// This is going to a integrated into the Scope/SymbolTable
// once we have it implemented. For now, I am just simulating
// scopes with LabelTable and LabelTableStack
//
class LabelTable 
{
private:
  
  struct Entry {
    // TODO: what to put here
  Fortran::parser::Provenance loc; 
  }; 

  std::map<int,Entry> entries_ ;
  
public:
  
  void add( int label , Fortran::parser::Provenance loc ) 
  { 
    if (label<1 || label>99999) return ; // Hoops! 
    auto &entry = entries_[label] ;
    entry.loc = loc ; 
  }

  bool find(int label, Fortran::parser::Provenance &loc)
  {
    
    auto it = entries_.find(label);
    if( it != entries_.end()) {
      Entry & entry{it->second}; 
      loc = entry.loc; 
      return true; 
    }
    return false;
  }


}; // of class LabelTable


class LabelTableStack {
private:
  std::stack<LabelTable*> stack ; 
public:
  LabelTable *PushLabelTable( LabelTable *table ) 
  {
    assert(table!=NULL);
    stack.push(table);
    return table; 
  }

  void PopLabelTable( LabelTable *table ) 
  {
    assert( !stack.empty() ) ;
    assert( stack.top() == table ) ;
    stack.pop(); 
  }

  LabelTable & GetLabelTable() {
    assert( !stack.empty() ) ;
    return *stack.top() ;
  }
  
  bool NoLabelTable() {
    return stack.empty() ; 
  }

}; // of class LabelTableStack

} // of namespace Fortran::semantics

#endif  // FORTRAN_SEMANTICS_LABELTABLE_H_
