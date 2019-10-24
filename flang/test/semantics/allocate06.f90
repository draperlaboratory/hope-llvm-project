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

! Check for semantic errors in ALLOCATE statements


subroutine C935(l, ac1, ac2, ac3, dc1, dc2, ec1, ec2, aa, ab, ab2, ea, eb, da, db, whatever, something, something_else)
! A type-param-value in a type-spec shall be an asterisk if and only if each
! allocate-object is a dummy argument for which the corresponding type parameter
! is assumed.

  type A(la)
    integer, len :: la
    integer vector(la)
  end type

  type, extends(A) :: B(lb)
    integer, len :: lb
    integer matrix(lb, lb)
  end type

  type, extends(B) :: C(lc1, lc2, lc3)
    integer, len :: lc1, lc2, lc3
    integer array(lc1, lc2, lc3)
  end type

  integer l
  character(len=*), pointer :: ac1, ac2(:)
  character*(*), allocatable :: ac3(:)
  character*(:), allocatable :: dc1
  character(len=:), pointer :: dc2(:)
  character(len=l), pointer :: ec1
  character*5, allocatable :: ec2(:)

  class(A(*)), pointer :: aa
  type(B(* , 5)), allocatable :: ab(:)
  type(B(* , *)), pointer :: ab2(:)
  class(A(l)), allocatable :: ea
  type(B(5 , 5)), pointer :: eb(:)
  class(A(:)), allocatable :: da
  type(B(: , 5)), pointer :: db(:)
  class(*), allocatable :: whatever
  type(C(la=*, lb=:, lc1=*, lc2=5, lc3=*)), pointer :: something(:)
  type(C(la=*, lb=:, lc1=5, lc2=5, lc3=*)), pointer :: something_else(:)

  ! OK
  allocate(character(len=*):: ac1, ac3(3))
  allocate(character*(*):: ac2(5))
  allocate(B(*, 5):: aa, ab(2)) !OK but segfault GCC
  allocate(B(*, *):: ab2(2))
  allocate(C(la=*, lb=10, lc1=*, lc2=5, lc3=*):: something(5))
  allocate(C(la=*, lb=10, lc1=2, lc2=5, lc3=3):: aa)
  allocate(character(5):: whatever)

  ! Not OK

  ! Should be * or no type-spec
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=5):: ac1)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=5):: ac2(3), ac3)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=l):: ac1)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=l):: ac2(3), ac3)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(A(5):: aa)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(B(5, 5):: ab(5))
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(B(l, 5):: aa, ab(5))

  ! Must not be *
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=*):: ac1, dc1, ac3(2))
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character*(*):: dc2(5))
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character*(*):: ec1)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(*):: whatever)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(character(len=*):: ac2(5), ec2(5))
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(A(*):: ea) !segfault gfortran
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(B(*, 5):: eb(2)) !segfault gfortran
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(A(*):: da) !segfault gfortran
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(B(*, 5):: db(2)) !segfault gfortran
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(A(*):: aa, whatever)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(B(*, *):: aa)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(C(la=*, lb=10, lc1=*, lc2=5, lc3=*):: something_else(5))
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(C(la=5, lb=10, lc1=4, lc2=5, lc3=3):: aa)
  !ERROR: Type parameters in type-spec must be assumed if and only if they are assumed for allocatable object in ALLOCATE
  allocate(C(la=*, lb=10, lc1=*, lc2=5, lc3=*):: aa)
end subroutine
