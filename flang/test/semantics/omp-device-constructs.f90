! Copyright (c) 2019, Arm Ltd.  All rights reserved.
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

! OPTIONS: -fopenmp
! Check OpenMP clause validity for the following directives:
!     2.10 Device constructs
program main

  real(8) :: arrayA(256), arrayB(256)
  integer :: N

  arrayA = 1.414
  arrayB = 3.14
  N = 256

  !$omp target map(arrayA)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !$omp target device(0)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !ERROR: At most one DEVICE clause can appear on the TARGET directive
  !$omp target device(0) device(1)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !ERROR: SCHEDULE clause is not allowed on the TARGET directive
  !$omp target schedule(static)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !$omp target defaultmap(tofrom:scalar)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !ERROR: The argument TOFROM:SCALAR must be specified on the DEFAULTMAP clause
  !$omp target defaultmap(tofrom)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !ERROR: At most one DEFAULTMAP clause can appear on the TARGET directive
  !$omp target defaultmap(tofrom:scalar) defaultmap(tofrom:scalar)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !$omp teams num_teams(3) thread_limit(10) default(shared) private(i) shared(a)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !ERROR: At most one NUM_TEAMS clause can appear on the TEAMS directive
  !$omp teams num_teams(2) num_teams(3)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !ERROR: The parameter of the NUM_TEAMS clause must be a positive integer expression
  !$omp teams num_teams(-1)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !ERROR: At most one THREAD_LIMIT clause can appear on the TEAMS directive
  !$omp teams thread_limit(2) thread_limit(3)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !ERROR: The parameter of the THREAD_LIMIT clause must be a positive integer expression
  !$omp teams thread_limit(-1)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !ERROR: At most one DEFAULT clause can appear on the TEAMS directive
  !$omp teams default(shared) default(none)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end teams

  !$omp target map(tofrom:a)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !ERROR: Only the to, from, tofrom or alloc map types are permitted for MAP clauses on the TARGET directive
  !$omp target map(delete:a)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target

  !$omp target data device(0) map(to:a)
  do i = 1, N
    a = 3.14
  enddo
  !$omp end target data

  !ERROR: At least one MAP clause must appear on the TARGET DATA directive
  !$omp target data device(0)
  do i = 1, N
     a = 3.14
  enddo
  !$omp end target data

  !ERROR: At most one IF clause can appear on the TARGET ENTER DATA directive
  !$omp target enter data map(to:a) if(.true.) if(.false.)

  !ERROR: Only the to or alloc map types are permitted for MAP clauses on the TARGET ENTER DATA directive
  !$omp target enter data map(from:a)

  !$omp target exit data map(delete:a)

  !ERROR: At most one DEVICE clause can appear on the TARGET EXIT DATA directive
  !$omp target exit data map(from:a) device(0) device(1)

  !ERROR: Only the from, release or delete map types are permitted for MAP clauses on the TARGET EXIT DATA directive
  !$omp target exit data map(to:a)
end program main
