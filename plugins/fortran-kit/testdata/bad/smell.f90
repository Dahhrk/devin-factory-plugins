! Intentional smells for fortran-rg-gate discrimination (not product code).
program smell
  implicit real (a-h, o-z)
  integer :: ios
  open (10, file="x.dat")
  read (10, *) ios
  write (10, *) ios
  close (10)
  goto 100
100 continue
end program smell
