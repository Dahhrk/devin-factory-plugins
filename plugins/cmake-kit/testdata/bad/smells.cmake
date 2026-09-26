# Intentional smells for cmake-rg-gate (not product).
file(DOWNLOAD https://example.com/deps.tgz ${CMAKE_BINARY_DIR}/deps.tgz)
execute_process(COMMAND ${CMAKE_COMMAND} -E echo unchecked)
file(GLOB SRC_FILES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
set(SMELL_CACHE_VAR "forced" CACHE STRING "smell" FORCE)
include(${UNTRUSTED_CMAKE_MODULE})
