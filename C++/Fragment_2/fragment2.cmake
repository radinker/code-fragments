add_executable(fragment2 ${CMAKE_CURRENT_LIST_DIR}/src/main.cpp)

set(GIO_VERSION "2.68")

string(CONCAT GIO "giomm-" ${GIO_VERSION})

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBGIO REQUIRED ${GIO})

message(STATUS "${LIBGIO_INCLUDE_DIRS}")

target_include_directories(fragment2 PRIVATE ${LIBGIO_INCLUDE_DIRS})
target_link_libraries(fragment2 ${LIBGIO_LINK_LIBRARIES})