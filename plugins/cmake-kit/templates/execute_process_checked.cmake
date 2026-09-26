# Boundary: execute_process with RESULT_VARIABLE on the same physical line.
execute_process(COMMAND ${CMAKE_COMMAND} -E true RESULT_VARIABLE _ep_rc)
if(NOT _ep_rc EQUAL 0)
  message(FATAL_ERROR "execute_process failed: ${_ep_rc}")
endif()
