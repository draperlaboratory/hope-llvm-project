implicit none
allocatable :: x
integer :: x
!ERROR: No explicit type declared for 'y'
allocatable :: y
end
