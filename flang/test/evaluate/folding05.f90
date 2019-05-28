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

! Test character intrinsic function folding

module character_intrinsic_tests
  logical, parameter :: test_char1_ok1 = char(0_4, 1).EQ." "
  logical, parameter :: test_char1_ok2 = char(127_4, 1).EQ.""
  logical, parameter :: test_char1_ok3 = char(97_4, 1).EQ."a"
  logical, parameter :: test_char1_ok4 = .NOT.char(97_4, 1).EQ."b"
  logical, parameter :: test_char1_ok5 = .NOT.char(127_4, 1).EQ." "
  !WARN: Character code 4294967295 is invalid for CHARACTER(1) type in char intrinsic function
  character(kind=1, len=1), parameter :: char1_nok1 = char(-1_4, 1)
  !WARN: Character code 128 is invalid for CHARACTER(1) type in char intrinsic function
  character(kind=1, len=1), parameter :: char1_nok2 = char(128_4, 1)
  !WARN: Character code 255 is invalid for CHARACTER(1) type in char intrinsic function
  character(kind=1, len=1), parameter :: char1_nok3 = char(-1_1, 1)

  logical, parameter :: test_char2_ok1 = char(0_4, 2).EQ.2_" "
  logical, parameter :: test_char2_ok2 = char(127_4, 2).EQ.2_""
  ! EUC-JP values cannot be tested in UTF-8 file so far.
  character(kind=2, len=1), parameter :: char2_ok3 = char(INT(Z'A1A1', 4), 2) ! JIS X 208
  character(kind=2, len=1), parameter :: char2_ok4 = char(INT(Z'FEFE', 4), 2) ! JIS X 208
  character(kind=2, len=1), parameter :: char2_ok5 = char(INT(Z'8EA1', 4), 2) ! JIS X 201
  character(kind=2, len=1), parameter :: char2_ok6 = char(INT(Z'8EDF', 4), 2) ! JIS X 201
  !WARN: Character code 4294967295 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok1 = char(-1_4, 2)
  !WARN: Character code 128 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok2 = char(128_4, 2)
  !WARN: Character code 65279 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok3 = char(INT(Z'FEFF', 4), 2)
  !WARN: Character code 65534 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok4 = char(INT(Z'FFFE', 4), 2)
  !WARN: Character code 41121 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok5 = char(INT(Z'A0A1', 4), 2)
  !WARN: Character code 41376 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok6 = char(INT(Z'A1A0', 4), 2)
  !WARN: Character code 36576 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok7 = char(INT(Z'8EE0', 4), 2)
  !WARN: Character code 36512 is invalid for CHARACTER(2) type in char intrinsic function
  character(kind=2, len=1), parameter :: char2_nok8 = char(INT(Z'8EA0', 4), 2)

  logical, parameter :: test_char4_ok1 = char(0, 4).EQ.4_" "
  logical, parameter :: test_char4_ok2 = char(INT(Z'D7FF', 4), 4).EQ.4_"퟿"
  logical, parameter :: test_char4_ok3 = char(INT(Z'DC01', 4), 4).EQ.4_"���"
  logical, parameter :: test_char4_ok4 = char(INT(Z'10FFFF', 4), 4).EQ.4_"􏿿"
  !WARN: Character code 55296 is invalid for CHARACTER(4) type in char intrinsic function
  character(kind=4, len=1), parameter :: char4_nok1 = char(INT(Z'D800', 4), 4)
  !WARN: Character code 56320 is invalid for CHARACTER(4) type in char intrinsic function
  character(kind=4, len=1), parameter :: char4_nok2 = char(INT(Z'DC00', 4), 4)
  !WARN: Character code 4294967295 is invalid for CHARACTER(4) type in char intrinsic function
  character(kind=4, len=1), parameter :: char4_nok3 = char(-1_4, 4)
  !WARN: Character code 1114112 is invalid for CHARACTER(4) type in char intrinsic function
  character(kind=4, len=1), parameter :: char4_nok4 = char(INT(Z'110000', 4), 4)

  character(kind=4, len=:), parameter :: c4aok(:) = char([97_4, 98_4, 99_4, 20320_4, 22909_4], 4)
  logical, parameter :: test_char4_array = (c4aok(1).EQ.4_"a").AND.(c4aok(2).EQ.4_"b") &
    .AND.(c4aok(3).EQ.4_"c").AND.(c4aok(4).EQ.4_"你").AND.(c4aok(5).EQ.4_"好")

  !WARN: Character code 4294967295 is invalid for CHARACTER(4) type in char intrinsic function
  character(kind=4, len=3), parameter :: c4anok(3) = char([97_4, -1_4, 22909_4], 4)

  logical, parameter :: test_achar4_ok1 = achar(0_4, 4).EQ.4_" "
  logical, parameter :: test_achar4_ok2 = achar(127_4, 4).EQ.4_""
  !WARN: Character code 4294967295 is invalid for CHARACTER(4) type in achar intrinsic function
  character(kind=4, len=1), parameter :: achar4_nok1 = achar(-1_4, 4)
  !WARN: Character code 128 is invalid for CHARACTER(4) type in achar intrinsic function
  character(kind=4, len=1), parameter :: achar4_nok2 = achar(128_4, 4)
  !WARN: Character code 255 is invalid for CHARACTER(4) type in achar intrinsic function
  character(kind=4, len=1), parameter :: achar4_nok3 = achar(-1_1, 4)

  character(kind=1, len=:), parameter :: c1aok(:) = achar([97_4, 0_4, 98_4], 1)
  logical, parameter :: test_char1_array = (c1aok(1).EQ.1_"a").AND.(c1aok(2).EQ.1_" ") &
    .AND.(c1aok(3).EQ.1_"b")


  ! Not yet recognized as intrinsic
  !character(kind=1, len=1), parameter :: test_c1_new_line = new_line("a")

  logical, parameter :: test_c1_adjustl1 = adjustl("  this is a test").EQ.("this is a test  ")
  logical, parameter :: test_c1_adjustl2 = .NOT."  this is a test".EQ.("this is a test  ")
  logical, parameter :: test_c1_adjustl3 = adjustl("").EQ.("")
  logical, parameter :: test_c1_adjustl4 = adjustl("that").EQ.("that")
  logical, parameter :: test_c1_adjustl5 = adjustl("that ").EQ.("that ")
  logical, parameter :: test_c1_adjustl6 = adjustl(" that ").EQ.("that  ")
  logical, parameter :: test_c1_adjustl7 = adjustl("    ").EQ.("    ")
  character(kind=1, len=:), parameter :: c1_adjustl8(:) = adjustl(["  this is a test", " that is a test "])
  logical, parameter :: test_c1_adjustl8 = (c1_adjustl8(1).EQ.1_"this is a test  ").AND.(c1_adjustl8(2).EQ.1_"that is a test  ")

  logical, parameter :: test_c4_adjustr1 = adjustr(4_"  你好吗 ? ").EQ.(4_"   你好吗 ?")
  logical, parameter :: test_c4_adjustr2 = .NOT.(4_"  你好吗 ? ").EQ.(4_"  你好吗 ?")
  logical, parameter :: test_c4_adjustr3 = adjustr(4_"").EQ.(4_"")
  logical, parameter :: test_c4_adjustr4 = adjustr(4_"   ").EQ.(4_"   ")
  logical, parameter :: test_c4_adjustr5 = adjustr(4_"你 好吗?").EQ.(4_"你 好吗?")
  logical, parameter :: test_c4_adjustr6 = adjustr(4_" 你好吗?").EQ.(4_" 你好吗?")
  logical, parameter :: test_c4_adjustr7 = adjustr(4_" 你好吗? ").EQ.(4_"  你好吗?")
  character(kind=4, len=:), parameter :: c4_adjustr8(:) = adjustr([4_"  你 好吗?%%% ", 4_"你a好b 吗c?   "])
  logical, parameter :: test_c4_adjustr8 = (c4_adjustr8(1).EQ.4_"   你 好吗?%%%").AND.(c4_adjustr8(2).EQ.4_"   你a好b 吗c?")

end module
