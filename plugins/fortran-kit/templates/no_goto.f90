pure integer function classify(n) result(code)
  implicit none
  integer, intent(in) :: n
  select case (n)
  case (:-1)
    code = -1
  case (0)
    code = 0
  case default
    code = 1
  end select
end function classify
