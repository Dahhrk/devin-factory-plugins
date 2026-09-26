# Good fixture: hashed DOWNLOAD, checked execute_process, explicit sources, CACHE no FORCE, static include.
file(DOWNLOAD https://example.com/deps.tgz ${CMAKE_BINARY_DIR}/deps.tgz EXPECTED_HASH SHA256=0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef)
execute_process(COMMAND ${CMAKE_COMMAND} -E true RESULT_VARIABLE _ok_rc)
if(NOT _ok_rc EQUAL 0)
  message(FATAL_ERROR "fail ${_ok_rc}")
endif()
set(APP_FEATURE OFF CACHE BOOL "feature")
include(CheckCXXCompilerFlag)
