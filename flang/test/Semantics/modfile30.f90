! RUN: %S/test_modfile.sh %s %f18 %t
! Verify miscellaneous bugs

! The function result must be declared after the dummy arguments
module m1
contains
  function f1(x) result(y)
    integer :: x(:)
    integer :: y(size(x))
  end
  function f2(x)
    integer :: x(:)
    integer :: f2(size(x))
  end
end

!Expect: m1.mod
!module m1
!contains
! function f1(x) result(y)
!  integer(4)::x(:)
!  integer(4)::y(1_8:int(int(1_8*size(x,dim=1),kind=4),kind=8))
! end
! function f2(x)
!  integer(4)::x(:)
!  integer(4)::f2(1_8:int(int(1_8*size(x,dim=1),kind=4),kind=8))
! end
!end

! Order of names in PUBLIC statement shouldn't affect .mod file.
module m2
  public :: a
  type t
  end type
  type(t), parameter :: a = t()
end

!Expect: m2.mod
!module m2
! type::t
! end type
! type(t),parameter::a=t()
!end

! Don't write out intrinsics
module m3a
  integer, parameter :: i4 = selected_int_kind(9)
end
module m3b
  use m3a
  integer(i4) :: j
end

!Expect: m3a.mod
!module m3a
! integer(4),parameter::i4=4_4
! intrinsic::selected_int_kind
!end

!Expect: m3b.mod
!module m3b
! use m3a,only:i4
! use m3a,only:selected_int_kind
! integer(4)::j
!end

! Test that character literals written with backslash escapes are read correctly.
module m4a
  character(1), parameter :: a = achar(1)
end
module m4b
  use m4a
  character(1), parameter :: b = a
end

!Expect: m4a.mod
!module m4a
! character(1_4,1),parameter::a=1_"\001"
! intrinsic::achar
!end

!Expect: m4b.mod
!module m4b
! use m4a,only:a
! use m4a,only:achar
! character(1_4,1),parameter::b=1_"\001"
!end

