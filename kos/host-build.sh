#!/usr/bin/env bash
#
# © 2024 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

KOS_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${KOS_DIR}")"
BUILD="${ROOT_DIR}/build/host"

if [ -z "${INSTALL_PREFIX}" ]; then
    INSTALL_PREFIX="${ROOT_DIR}/install/host"
fi

while [ -n "${1}" ]; do
    case "${1}" in
    -i | --install-prefix) INSTALL_PREFIX="${2}"
        shift ;;
    *) echo "Unknown option -'${1}'."
        exit 1;;
    esac
    shift
done

# Build protobuf on host to use it as part of toolchain.
cmake -G "Unix Makefiles" -B "${BUILD}" \
      -D protobuf_BUILD_TESTS=OFF \
      -D protobuf_INSTALL_EXAMPLES=OFF \
      -D CMAKE_BUILD_TYPE:STRING=Debug \
      -D CMAKE_INSTALL_PREFIX:STRING="${INSTALL_PREFIX}" \
      -D BUILD_SHARED_LIBS=OFF \
      "${ROOT_DIR}/cmake" && \
cmake --build "${BUILD}" -j`nproc` --target install
