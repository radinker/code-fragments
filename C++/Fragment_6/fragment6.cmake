# This C++ modules example is dependent on the GNU C++ compiler.
# Compiler commands:
# g++ -std=c++23 -fmodules-ts -x c++-system-header iostream
# g++ -std=c++23 -fmodules-ts -x c++-system-header string
# g++ -std=c++23 -fmodules-ts -c dummy.cpp
# g++ -std=c++23 -fmodules-ts main.cpp dummy.o
if(CMAKE_COMPILER_IS_GNUCXX)
  # Compiler options to generate the gcm files for the system modules being used.
  set(SYS_MODULES_COMPILE_OPTIONS -fmodules-ts -xc++-system-header)

  # Generate the gcm files for iostream and string.
  add_custom_target(iostream_module COMMAND ${CMAKE_CXX_COMPILER} -std=c++${CMAKE_CXX_STANDARD} ${SYS_MODULES_COMPILE_OPTIONS} iostream)
  add_custom_target(string_module COMMAND ${CMAKE_CXX_COMPILER} -std=c++${CMAKE_CXX_STANDARD} ${SYS_MODULES_COMPILE_OPTIONS} string)

  # Target for the dummy module.
  add_library(dummy OBJECT ${CMAKE_CURRENT_LIST_DIR}/src/dummy.cpp)
  target_compile_options(dummy PRIVATE -fmodules-ts PRIVATE -c)
  add_dependencies(dummy iostream_module string_module)

  # Target for the fragment.
  add_executable(fragment6 ${CMAKE_CURRENT_LIST_DIR}/src/main.cpp)
  target_compile_options(fragment6 PRIVATE -fmodules-ts)
  target_link_libraries(fragment6 PRIVATE dummy)
else()
  message(WARNING "Fragment 6 only supported by GNU C++ compiler...")
endif()
