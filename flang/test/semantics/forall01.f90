subroutine forall
  real :: a(9)
  !ERROR: 'i' is already declared in this scoping unit
  forall (i=1:8, i=1:9)  a(i) = i
  forall (j=1:8)
  !ERROR: 'j' is already declared in this scoping unit
    forall (j=1:9)
    end forall
  end forall
end subroutine forall
