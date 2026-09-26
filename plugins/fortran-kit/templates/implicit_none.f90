module example_mod
  implicit none
  private
  public :: add_one
contains
  pure integer function add_one(x) result(y)
    integer, intent(in) :: x
    y = x + 1
  end function add_one
end module example_mod
