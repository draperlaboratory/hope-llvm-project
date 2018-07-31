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

#include "derived-type.h"
#include "descriptor.h"
#include <cstring>

namespace Fortran::runtime {

TypeParameterValue TypeParameter::GetValue(const Descriptor &descriptor) const {
  if (which_ < 0) {
    return value_;
  } else {
    return descriptor.Addendum()->LenParameterValue(which_);
  }
}

bool DerivedType::IsNontrivialAnalysis() const {
  if (kindParameters_ > 0 || lenParameters_ > 0 || typeBoundProcedures_ > 0 ||
      definedAssignments_ > 0) {
    return true;
  }
  for (int j{0}; j < components_; ++j) {
    if (component_[j].IsDescriptor()) {
      return true;
    }
    if (const Descriptor * staticDescriptor{component_[j].staticDescriptor()}) {
      if (const DescriptorAddendum * addendum{staticDescriptor->Addendum()}) {
        if (const DerivedType * dt{addendum->derivedType()}) {
          if (dt->IsNontrivial()) {
            return true;
          }
        }
      }
    }
  }
  return false;
}
}  // namespace Fortran::runtime
