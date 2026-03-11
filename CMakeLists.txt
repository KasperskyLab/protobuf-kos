# © 2026 AO Kaspersky Lab
# Licensed under the MIT License

cmake_minimum_required (VERSION 3.29)

project (protobuf-kos LANGUAGES C CXX)

include (FetchContent)

# Configure the source location and patch application for protobuf.
# The official protobuf repository.
set (GIT_REPOSITORY https://github.com/protocolbuffers/protobuf.git)
# Specific version to fetch.
set (GIT_TAG        v30.0)
if (KOS)
    # Apply KasperskyOS adaptation patch after downloading.
    set (GIT_PATCH     ${PROJECT_SOURCE_DIR}/KasperskyOS-CE-adaptation.patch)
    set (PATCH_COMMAND git apply ${GIT_PATCH})
else ()
    set (PATCH_COMMAND)
endif ()

# Prevent redundant patch application on subsequent builds.
if (PROTOBUF_CPP_POPULATED)
    # Library has already been fetched — skip patching to avoid conflicts.
    set (PATCH_COMMAND)
else ()
    message (STATUS "Downloading protobuf ${GIT_TAG}")
endif ()

# Override default values for original project options.
option (protobuf_BUILD_TESTS "Build tests" OFF)
if (KOS)
    option (protobuf_BUILD_PROTOC_BINARIES "Build libprotoc and protoc compiler" OFF)
    option (protobuf_BUILD_LIBPROTOC "Build libprotoc" ON)
endif ()

# Declare the external dependency with patch configuration.
FetchContent_Declare (protobuf
                      GIT_REPOSITORY ${GIT_REPOSITORY}
                      GIT_TAG        ${GIT_TAG}
                      GIT_SHALLOW    TRUE
                      PATCH_COMMAND  ${PATCH_COMMAND})

# Execute the download and integration of protobuf into the build system.
FetchContent_MakeAvailable (protobuf)

# Cache the population state to optimize subsequent builds.
set (PROTOBUF_CPP_POPULATED ${protobuf_POPULATED} CACHE INTERNAL "")
