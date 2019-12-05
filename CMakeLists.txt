# 2019.5.21
# Project Tooru
# CMakeFile

cmake_minimum_required (VERSION 3.0)
project (Tooru)
# The version number.
set (Tooru_VERSION_MAJOR 0)
set (Tooru_VERSION_MINOR 1)

configure_file (
  "${PROJECT_SOURCE_DIR}/config.h.in"
  "${PROJECT_BINARY_DIR}/config.h"
)

include_directories("${PROJECT_BINARY_DIR}")
include_directories("${PROJECT_SOURCE_DIR}/lib/include")

find_library(libgt_path libgt ${PROJECT_SOURCE_DIR}/lib/gt)
find_library(liblua54 lua54 ${PROJECT_SOURCE_DIR})

add_compile_definitions(_CRT_SECURE_NO_WARNINGS)

aux_source_directory("${PROJECT_SOURCE_DIR}/tooru/src" TOORU_SRC)

add_library(tooru SHARED ${TOORU_SRC})
target_link_libraries(tooru ${liblua54} ${libgt_path})
