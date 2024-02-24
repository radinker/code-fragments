#
# CMakeLists.txt
#
# Copyright (c) 2024 Jose Arboleda
# MIT License
#

# Project name and version
project(CodeFragments VERSION 0.0.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

configure_file(CHConfig.hpp.in CHConfig.hpp)
