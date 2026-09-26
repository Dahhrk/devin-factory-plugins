subroutine read_vector(path, values, n, ok)
  use, intrinsic :: iso_fortran_env, only: iostat_end
  implicit none
  character(len=*), intent(in) :: path
  real, intent(out) :: values(:)
  integer, intent(out) :: n
  logical, intent(out) :: ok
  integer :: unit, ios, i
  character(len=256) :: iom
  ok = .false.
  n = 0
  open (newunit=unit, file=path, status="old", action="read", iostat=ios, iomsg=iom)
  if (ios /= 0) return
  do i = 1, size(values)
    read (unit, *, iostat=ios, iomsg=iom) values(i)
    if (ios == iostat_end) exit
    if (ios /= 0) then
      close (unit, iostat=ios)
      return
    end if
    n = i
  end do
  close (unit, iostat=ios)
  ok = .true.
end subroutine read_vector
