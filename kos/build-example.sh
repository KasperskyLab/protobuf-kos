#!/usr/bin/env bash
#
# © 2024 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

KOS_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${KOS_DIR}")"
BUILD="${ROOT_DIR}/build/example_kos"
BUILD_TARGET=sim

function PrintHelp () {
    cat<<HELP

Script to create and run an example of using the previously built protobuf with KasperskyOS.

USAGE:

    ${0} [BUILD_TARGET] [-h | --help]

BUILD_TARGET:

    qemu - to build and run the example on QEMU (default value).
    rpi  - to create a file system image called rpi4kos.img for a bootable SD card.
           This image can be directly copied onto an SD card using the dd utility,
           allowing the example to be run on Raspberry Pi.

OPTIONS:

    -h, --help
        Help text.
HELP
}

# Parse arguments.
while [ -n "${1}" ]; do
    case "${1}" in
    -h | --help) PrintHelp
        exit 0;;
    qemu) BUILD_TARGET=sim;;
    rpi) BUILD_TARGET=sd-image;;
    *) echo "Unknown option - '${1}'."
        PrintHelp
        exit 1;;
    esac
    shift
done

if [ -z "${SDK_PREFIX}" ]; then
    echo "Can't get path to the installed KasperskyOS SDK."
    echo "Please specify it via the SDK_PREFIX environment variable."
    exit 1
fi

if [ -z "${TARGET}" ]; then
    echo "Target platform is not specified. Try to autodetect..."
    TARGETS=($(ls -d "${SDK_PREFIX}"/sysroot-* | sed 's|.*sysroot-\(.*\)|\1|'))
    if [ ${#TARGETS[@]} -gt 1 ]; then
        echo More than one target platform found: ${TARGETS[*]}.
        echo Use the TARGET environment variable to specify exact platform.
        exit 1
    fi

    export TARGET=${TARGETS[0]}
    echo "Platform ${TARGET} will be used."
fi

export LANG=C
export PKG_CONFIG=""
export PATH="${SDK_PREFIX}/toolchain/bin:${PATH}"

export BUILD_WITH_CLANG=
export BUILD_WITH_GCC=

TOOLCHAIN_SUFFIX=""

if [ "${BUILD_WITH_CLANG}" == "y" ];then
    TOOLCHAIN_SUFFIX="-clang"
fi

if [ "${BUILD_WITH_GCC}" == "y" ];then
    TOOLCHAIN_SUFFIX="-gcc"
fi

# Build and install the host protoc and KasperskyOS protobuf libraries, then run the example.
${KOS_DIR}/host-build.sh && \
${KOS_DIR}/cross-build.sh && \
cmake -G "Unix Makefiles" -B "${BUILD}" \
      -D CMAKE_BUILD_TYPE:STRING=Debug \
      -D CMAKE_FIND_ROOT_PATH="${ROOT_DIR}/install/kos;${ROOT_DIR}/install/host;${PREFIX_DIR}/sysroot-${TARGET}" \
      -D CMAKE_TOOLCHAIN_FILE="${SDK_PREFIX}/toolchain/share/toolchain-${TARGET}${TOOLCHAIN_SUFFIX}.cmake" \
      "${ROOT_DIR}/examples/kos" &&  \
cmake --build "${BUILD}" --target ${BUILD_TARGET} -j`nproc` 
