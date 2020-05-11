! RUN: %S/test_errors.sh %s %t %f18
! Tests valid and invalid ENTRY statements

module m1
  !ERROR: ENTRY may appear only in a subroutine or function
  entry badentryinmodule
  interface
    module subroutine separate
    end subroutine
  end interface
 contains
  subroutine modproc
    entry entryinmodproc ! ok
    block
      !ERROR: ENTRY may not appear in an executable construct
      entry badentryinblock ! C1571
    end block
    if (.true.) then
      !ERROR: ENTRY may not appear in an executable construct
      entry ibadconstr() ! C1571
    end if
   contains
    subroutine internal
      !ERROR: ENTRY may not appear in an internal subprogram
      entry badentryininternal ! C1571
    end subroutine
  end subroutine
end module

submodule(m1) m1s1
 contains
  module procedure separate
    !ERROR: ENTRY may not appear in a separate module procedure
    entry badentryinsmp ! 1571
  end procedure
end submodule

program main
  !ERROR: ENTRY may appear only in a subroutine or function
  entry badentryinprogram ! C1571
end program

block data bd1
  !ERROR: ENTRY may appear only in a subroutine or function
  entry badentryinbd ! C1571
end block data

subroutine subr(goodarg1)
  real, intent(in) :: goodarg1
  real :: goodarg2
  !ERROR: A dummy argument may not also be a named constant
  integer, parameter :: badarg1 = 1
  type :: badarg2
  end type
  common /badarg3/ x
  namelist /badarg4/ x
  !ERROR: A dummy argument may not have the SAVE attribute
  integer :: badarg5 = 2
  entry okargs(goodarg1, goodarg2)
  !ERROR: RESULT(br1) may appear only in a function
  entry badresult() result(br1) ! C1572
  !ERROR: ENTRY dummy argument 'badarg2' is previously declared as an item that may not be used as a dummy argument
  !ERROR: ENTRY dummy argument 'badarg4' is previously declared as an item that may not be used as a dummy argument
  entry badargs(badarg1,badarg2,badarg3,badarg4,badarg5)
end subroutine

function ifunc()
  integer :: ifunc
  integer :: ibad1
  type :: ibad2
  end type
  save :: ibad3
  real :: weird1
  double precision :: weird2
  complex :: weird3
  logical :: weird4
  character :: weird5
  type(ibad2) :: weird6
  integer :: iarr(1)
  integer, allocatable :: alloc
  integer, pointer :: ptr
  entry iok1()
  !ERROR: ENTRY name 'ibad1' may not be declared when RESULT() is present
  entry ibad1() result(ibad1res) ! C1570
  !ERROR: 'ibad2' was previously declared as an item that may not be used as a function result
  entry ibad2()
  !ERROR: ENTRY in a function may not have an alternate return dummy argument
  entry ibadalt(*) ! C1573
  !ERROR: RESULT(ifunc) may not have the same name as the function
  entry isameres() result(ifunc) ! C1574
  entry iok()
  !ERROR: RESULT(iok) may not have the same name as an ENTRY in the function
  entry isameres2() result(iok) ! C1574
  entry isameres3() result(iok2) ! C1574
  entry iok2()
  !These cases are all acceptably incompatible
  entry iok3() result(weird1)
  entry iok4() result(weird2)
  entry iok5() result(weird3)
  entry iok6() result(weird4)
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry ibadt1() result(weird5)
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry ibadt2() result(weird6)
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry ibadt3() result(iarr)
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry ibadt4() result(alloc)
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry ibadt5() result(ptr)
  call isubr
  !ERROR: 'isubr' was previously called as a subroutine
  entry isubr()
  continue ! force transition to execution part
  entry implicit()
  implicit = 666 ! ok, just ensure that it works
end function

function chfunc() result(chr)
  character(len=1) :: chr
  character(len=2) :: chr1
  !ERROR: Result of ENTRY is not compatible with result of containing function
  entry chfunc1() result(chr1)
end function

subroutine externals
  !ERROR: 'subr' is already defined as a global identifier
  entry subr
  !ERROR: 'ifunc' is already defined as a global identifier
  entry ifunc
  !ERROR: 'm1' is already defined as a global identifier
  entry m1
  !ERROR: 'iok1' is already defined as a global identifier
  entry iok1
  integer :: ix
  ix = iproc()
  !ERROR: 'iproc' was previously called as a function
  entry iproc
end subroutine

module m2
  external m2entry2
 contains
  subroutine m2subr1
    entry m2entry1 ! ok
    entry m2entry2 ! ok
    entry m2entry3 ! ok
  end subroutine
end module

subroutine usem2
  use m2
  interface
    subroutine simplesubr
    end subroutine
  end interface
  procedure(simplesubr), pointer :: p
  p => m2subr1 ! ok
  p => m2entry1 ! ok
  p => m2entry2 ! ok
  p => m2entry3 ! ok
end subroutine

module m3
  interface
    module subroutine m3entry1
    end subroutine
  end interface
 contains
  subroutine m3subr1
    !ERROR: 'm3entry1' is already declared in this scoping unit
    entry m3entry1
  end subroutine
end module

function inone
  implicit none
  integer :: inone
  !ERROR: No explicit type declared for 'implicitbad1'
  entry implicitbad1
  inone = 0 ! force transition to execution part
  !ERROR: No explicit type declared for 'implicitbad2'
  entry implicitbad2
end
