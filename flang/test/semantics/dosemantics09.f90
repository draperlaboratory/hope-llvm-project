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

!C1129 
!A variable that is referenced by the scalar-mask-expr of a
!concurrent-header or by any concurrent-limit or concurrent-step in that
!concurrent-header shall not appear in a LOCAL locality-spec in the same DO
!CONCURRENT statement.

subroutine s1()

!ERROR: 'i' is already declared in this scoping unit
  do concurrent (i=1:10) local(i)
  end do
end subroutine s1

subroutine s2()
!ERROR: 'i' is already declared in this scoping unit
  do concurrent (i=1:10) local_init(i)
  end do
end subroutine s2

subroutine s3()
!ERROR: 'i' is already declared in this scoping unit
  do concurrent (i=i:10) shared(i)
  end do
end subroutine s3

subroutine s4()
!ERROR: concurrent-header expression references variable 'i' in locality-spec
  do concurrent (j=i:10) local(i)
  end do
end subroutine s4

subroutine s5()
  !OK because the locality-spec is local_init
  do concurrent (j=i:10) local_init(i)
  end do
end subroutine s5

subroutine s6()
  !OK because the locality-spec is shared
  do concurrent (j=i:10) shared(i)
  end do
end subroutine s6

subroutine s7()
!ERROR: concurrent-header expression references variable 'i' in locality-spec
  do concurrent (j=1:i) local(i)
  end do
end subroutine s7

subroutine s8()
  !OK because the locality-spec is local_init
  do concurrent (j=1:i) local_init(i)
  end do
end subroutine s8

subroutine s9()
  !OK because the locality-spec is shared
  do concurrent (j=1:i) shared(i)
  end do
end subroutine s9

subroutine s10()
!ERROR: concurrent-header expression references variable 'i' in locality-spec
  do concurrent (j=1:10:i) local(i)
  end do
end subroutine s10

subroutine s11()
  !OK because the locality-spec is local_init
  do concurrent (j=1:10:i) local_init(i)
  end do
end subroutine s11

subroutine s12()
  !OK because the locality-spec is shared
  do concurrent (j=1:10:i) shared(i)
  end do
end subroutine s12

subroutine s13()
  ! Test construct-association, in this case, established by the "shared"
  integer :: ivar
  associate (avar => ivar)
!ERROR: concurrent-header expression references variable 'ivar' in locality-spec
    do concurrent (j=1:10:avar) local(avar)
    end do
  end associate
end subroutine s13

module m1
  integer :: mvar
end module m1
subroutine s14()
  ! Test use-association, in this case, established by the "shared"
  use m1

!ERROR: concurrent-header expression references variable 'mvar' in locality-spec
  do concurrent (k=mvar:10) local(mvar)
  end do
end subroutine s14

subroutine s15()
  ! Test host-association, in this case, established by the "shared"
  ! locality-spec
  ivar = 3
  do concurrent (j=ivar:10) shared(ivar)
!ERROR: concurrent-header expression references variable 'ivar' in locality-spec
    do concurrent (k=ivar:10) local(ivar)
    end do
  end do
end subroutine s15
