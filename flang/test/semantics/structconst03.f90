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

! Error tests for structure constructors: C1594 violations
! from assigning globally-visible data to POINTER components.

module usefrom
  real :: usedfrom1
end module usefrom

module module1
  use usefrom
  implicit none
  type :: has_pointer1
    real, pointer :: p
    type(has_pointer1), allocatable :: link1
  end type has_pointer1
  type :: has_pointer2
    type(has_pointer1) :: p
    type(has_pointer2), allocatable :: link2
  end type has_pointer2
  type, extends(has_pointer2) :: has_pointer3
    type(has_pointer3), allocatable :: link3
  end type has_pointer3
  type :: t1(k)
    integer, kind :: k
    real, pointer :: p
    type(t1(k)), allocatable :: link
  end type t1
  type :: t2(k)
    integer, kind :: k
    type(has_pointer1) :: hp1
    type(t2(k)), allocatable :: link
  end type t2
  type :: t3(k)
    integer, kind :: k
    type(has_pointer2) :: hp2
    type(t3(k)), allocatable :: link
  end type t3
  type :: t4(k)
    integer, kind :: k
    type(has_pointer3) :: hp3
    type(t4(k)), allocatable :: link
  end type t4
  real :: modulevar1
  real :: commonvar1
  type(has_pointer1) :: modulevar2, commonvar2
  type(has_pointer2) :: modulevar3, commonvar3
  type(has_pointer3) :: modulevar4, commonvar4
  common /cblock/ commonvar1

 contains

  pure real function pf1(dummy1, dummy2, dummy3, dummy4)
    real :: local1
    type(t1(0)) :: x1
    type(t2(0)) :: x2
    type(t3(0)) :: x3
    type(t4(0)) :: x4
    real, intent(in) :: dummy1
    real, intent(inout) :: dummy2
    real, pointer :: dummy3
    real, intent(inout) :: dummy4[*]
    pf1 = 0.
    x1 = t1(0)(local1)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x1 = t1(0)(usedfrom1)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x1 = t1(0)(modulevar1)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x1 = t1(0)(commonvar1)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x1 = t1(0)(dummy1)
    x1 = t1(0)(dummy2)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x1 = t1(0)(dummy3)
! TODO when semantics handles coindexing:
! TODO !ERROR: Externally visible object must not be associated with a pointer in a PURE function
! TODO x1 = t1(0)(dummy4[0])
    x1 = t1(0)(dummy4)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x2 = t2(0)(modulevar2)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x2 = t2(0)(commonvar2)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x3 = t3(0)(modulevar3)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x3 = t3(0)(commonvar3)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x4 = t4(0)(modulevar4)
    !ERROR: Externally visible object must not be associated with a pointer in a PURE function
    x4 = t4(0)(commonvar4)
   contains
    subroutine subr(dummy1a, dummy2a, dummy3a, dummy4a)
      real :: local1a
      type(t1(0)) :: x1a
      type(t2(0)) :: x2a
      type(t3(0)) :: x3a
      type(t4(0)) :: x4a
      real, intent(in) :: dummy1a
      real, intent(inout) :: dummy2a
      real, pointer :: dummy3a
      real, intent(inout) :: dummy4a[*]
      x1a = t1(0)(local1a)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(usedfrom1)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(modulevar1)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(commonvar1)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(dummy1)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(dummy1a)
      x1a = t1(0)(dummy2a)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(dummy3)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x1a = t1(0)(dummy3a)
! TODO when semantics handles coindexing:
! TODO !ERROR: Externally visible object must not be associated with a pointer in a PURE function
! TODO x1a = t1(0)(dummy4a[0])
      x1a = t1(0)(dummy4a)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x2a = t2(0)(modulevar2)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x2a = t2(0)(commonvar2)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x3a = t3(0)(modulevar3)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x3a = t3(0)(commonvar3)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x4a = t4(0)(modulevar4)
      !ERROR: Externally visible object must not be associated with a pointer in a PURE function
      x4a = t4(0)(commonvar4)
    end subroutine subr
  end function pf1

  impure real function ipf1(dummy1, dummy2, dummy3, dummy4)
    real :: local1
    type(t1(0)) :: x1
    type(t2(0)) :: x2
    type(t3(0)) :: x3
    type(t4(0)) :: x4
    real, intent(in) :: dummy1
    real, intent(inout) :: dummy2
    real, pointer :: dummy3
    real, intent(inout) :: dummy4[*]
    ipf1 = 0.
    x1 = t1(0)(local1)
    x1 = t1(0)(usedfrom1)
    x1 = t1(0)(modulevar1)
    x1 = t1(0)(commonvar1)
    x1 = t1(0)(dummy1)
    x1 = t1(0)(dummy2)
    x1 = t1(0)(dummy3)
! TODO when semantics handles coindexing:
! TODO x1 = t1(0)(dummy4[0])
    x1 = t1(0)(dummy4)
    x2 = t2(0)(modulevar2)
    x2 = t2(0)(commonvar2)
    x3 = t3(0)(modulevar3)
    x3 = t3(0)(commonvar3)
    x4 = t4(0)(modulevar4)
    x4 = t4(0)(commonvar4)
  end function ipf1
end module module1
