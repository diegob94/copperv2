cmake_minimum_required(VERSION 3.16)
project(copperv)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

add_executable(sim ${PROJECT_SOURCE_DIR}/sim_main.cpp)

set(ROOT_DIR ${PROJECT_SOURCE_DIR}/../..)
set(RESOURCES_DIR ${ROOT_DIR}/src/main/resources)

verilate(sim 
    SOURCES 
        "${RESOURCES_DIR}/rtl_v1/copperv.v"
        "${RESOURCES_DIR}/rtl_v1/control_unit.v"
        "${RESOURCES_DIR}/rtl_v1/idecoder.v"
        "${RESOURCES_DIR}/rtl_v1/register_file.v"
        "${RESOURCES_DIR}/rtl_v1/execution.v"
    INCLUDE_DIRS "${RESOURCES_DIR}/rtl_v1/include"
    TOP_MODULE copperv
)
