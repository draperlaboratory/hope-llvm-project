! Copyright (c) 2019, NVIDIA CORPORATION.  All rights reserved.
!
! Licensed under the Apache License, Version 2.0 (the "License");
! you may not use this file except in compliance with the License.
! You may obtain a copy of the License at
!
!     http://www.apache.org/licenses/LICENSE-2.0
!
! Unless required by applicable law or agreed to in writing, software
! distributed under the License is distributed on an "AS IS" BASIS,
! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
! See the License for the specific language governing permissions and
! limitations under the License.

! Issue 458 -- semantic checks for a normal DO loop.  The DO variable
! and the initial, final, and step expressions must be INTEGER if the
! options for standard conformance and turning warnings into errors
! are both in effect.  This test turns on the options for standards
! conformance and turning warnings into errors.  This produces error
! messages for the cases where REAL and DOUBLE PRECISION variables
! and expressions are used in the DO controls.

! C1123 -- Expressions in DO CONCURRENT header cannot reference variables
! declared in the same header
PROGRAM dosemantics04
  IMPLICIT NONE
  INTEGER :: a, i, j, k, n

! No problems here
  DO CONCURRENT (INTEGER *2 :: i = 1:10, i < j + n) LOCAL(n)
    PRINT *, "hello"
  END DO

  DO 30 CONCURRENT (i = 1:n:1, j=1:n:2, k=1:n:3, a<3) LOCAL (a)
    PRINT *, "hello"
30 END DO

!ERROR: concurrent-control expression references index-name
  DO CONCURRENT (i = j:3, j=1:3)
  END DO

!ERROR: concurrent-control expression references index-name
  DO CONCURRENT (INTEGER*2 :: i = 1:3, j=i:3)
  END DO

END PROGRAM dosemantics04
