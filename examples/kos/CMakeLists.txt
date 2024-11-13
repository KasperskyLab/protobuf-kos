# © 2024 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

cmake_minimum_required(VERSION 3.25)
project(async_resolver_example)

# Initialize CMake library for the KasperskyOS SDK.
include(platform)

initialize_platform()

# Include the CMake library named nk
# for working with the NK compiler (nk-gen-c).
include(platform/nk)

# Find required protobuf package.
find_package(protobuf REQUIRED)

# Find protobuf compiler for .proto files.
# Due to cross-compilation we should use protoc build for host.
find_program(protoc NAMES protoc REQUIRED)

# Add a package for working with the virtual file system.
find_package(vfs REQUIRED)
include_directories(${vfs_INCLUDE})

# Add a package with the VFS program implementations.
find_package(precompiled_vfs REQUIRED)
include_directories(${precompiled_vfs_INCLUDE})

# Include the directory with the generated config header files.
include_directories(${CMAKE_CURRENT_BINARY_DIR})

# Include the directory with header files.
set(RESOURCES ${CMAKE_CURRENT_LIST_DIR}/resources)
include_directories(${RESOURCES}/include ${CMAKE_CURRENT_LIST_DIR})

# Include the directory with header files.
set(RESOURCES ${CMAKE_CURRENT_SOURCE_DIR}/resources)

# Add target to generate protobuf files.
set(PROTOBUF_GENERATED_DIR "${CMAKE_CURRENT_BINARY_DIR}")
set(PROTOBUF_GENERATED_FILES
  "${PROTOBUF_GENERATED_DIR}/addressbook.pb.cc"
  "${PROTOBUF_GENERATED_DIR}/addressbook.pb.h"
)
set(PROTOBUF_SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
set(PROTOBUF_SOURCE_FILE "${PROTOBUF_SOURCE_DIR}/addressbook.proto")
add_custom_command(
  OUTPUT ${PROTOBUF_GENERATED_FILES}
  COMMAND ${protoc} -I${PROTOBUF_SOURCE_DIR}
                    --cpp_out=${PROTOBUF_GENERATED_DIR}
                    ${PROTOBUF_SOURCE_FILE}
)
add_custom_target(PROTOBUF_GENERATE DEPENDS ${PROTOBUF_GENERATED_FILES})

add_nk_idl(CONSUMER_IDL
  "${RESOURCES}/idl/IConsumer.idl"
  NK_MODULE example
  LANG "CXX"
)

add_subdirectory(consumer)
add_subdirectory(producer)
add_subdirectory(einit)
