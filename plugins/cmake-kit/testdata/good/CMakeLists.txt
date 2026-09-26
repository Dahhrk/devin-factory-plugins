cmake_minimum_required(VERSION 3.16)
project(cmake_kit_good LANGUAGES CXX)
add_library(app
  src/main.cpp
  src/util.cpp
)
include(CheckCXXCompilerFlag)
