# This C++ modules example is dependent on the GNU C++ compiler.
# Compiler commands:
# g++ -std=c++20 -fmodules-ts -c -x c++-system-header iostream string
# g++ -std=c++23 -fmodules-ts -c dummy.cpp
# g++ -std=c++23 -fmodules-ts main.cpp dummy.o
if(CMAKE_COMPILER_IS_GNUCXX)
  # Compiler options to generate the gcm files for the system modules being used.
  set(SYS_MODULES_COMPILE_OPTIONS -fmodules-ts -c -xc++-system-header)

  # GNU g++ modules cache.
  set(CPP_MODULES_CACHE "gcm.cache")

  message(STATUS "Cleaning gcm.cache...")
  file(REMOVE_RECURSE ${CMAKE_CURRENT_BINARY_DIR}/gcm.cache)

  message(STATUS "Generating CPP modules cache...")

  # Generate the gcm files for iostream and string.
  execute_process(COMMAND ${CMAKE_CXX_COMPILER}
                          -std=c++${CMAKE_CXX_STANDARD}
                          ${SYS_MODULES_COMPILE_OPTIONS} iostream string
                  RESULT_VARIABLE RESULT)

  if(NOT RESULT EQUAL 0)
      message(WARNING "Could not generate CPP modules cache. Fragment 6 is broken.\n"
              "Try clean_cpp_modules target and generate again.")
  endif()

  # Target for the dummy module.
  add_library(dummy OBJECT ${CMAKE_CURRENT_LIST_DIR}/src/dummy.cpp)
  target_compile_options(dummy PRIVATE -fmodules-ts PRIVATE -c)

  # Target for the fragment.
  add_executable(fragment6 ${CMAKE_CURRENT_LIST_DIR}/src/main.cpp)
  target_compile_options(fragment6 PRIVATE -fmodules-ts)
  target_link_libraries(fragment6 PRIVATE dummy)
else()
  message(WARNING "Fragment 6 only supported by GNU C++ compiler...")
endif()
