program ok
  implicit none
  integer :: unit, ios
  character(len=128) :: iom
  real :: x
  open (newunit=unit, file="x.dat", status="old", action="read", iostat=ios, iomsg=iom)
  if (ios /= 0) stop 1
  read (unit, *, iostat=ios, iomsg=iom) x
  if (ios /= 0) stop 2
  close (unit, iostat=ios)
  ! Documented intentional seam; keep allow on the smell line.
  goto 100 ! fortran-rg-allow: fixture documents allow marker for intentional GOTO seam
100 continue
end program ok
