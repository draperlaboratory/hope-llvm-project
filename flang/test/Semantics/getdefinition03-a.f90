! Tests -fget-definition with INCLUDE
INCLUDE "Inputs/getdefinition03-b.f90"

program main
 use m3
 integer :: x
 x = f
end program

! RUN: %f18 -fget-definition 7 6 7 -fparse-only %s | FileCheck --check-prefix=CHECK1 %s
! RUN: %f18 -fget-definition 7 2 3 -fparse-only %s | FileCheck --check-prefix=CHECK2 %s
! CHECK1: f:{{.*}}getdefinition03-b.f90, 2, 12-13
! CHECK2: x:{{.*}}getdefinition03-a.f90, 6, 13-14
