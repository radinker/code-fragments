#
# CMakeLists.txt
#
# Copyright (c) 2024 Jose Arboleda
# MIT License
#

cmake_minimum_required(VERSION 3.25)

# Project name and version
project(CodeFragmentsCPP VERSION 0.1.0)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED True)

#Include all fragments
set(FRAGMENTS 2) # Total C++ fragments to be configured
math(EXPR LIMIT "${FRAGMENTS} - 1" OUTPUT_FORMAT DECIMAL)

foreach (F RANGE ${LIMIT})
    string(CONCAT FRAGMENT_FOLDER "Fragment_" "${F}")
    string(CONCAT FRAGMENT_FILE "fragment" "${F}" ".cmake")

    include(${FRAGMENT_FOLDER}/${FRAGMENT_FILE})
endforeach ()

configure_file(CFConfig.hpp.in CFConfig.hpp)
