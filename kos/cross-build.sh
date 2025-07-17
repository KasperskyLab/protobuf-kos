#!/usr/bin/env bash
#
# © 2025 AO Kaspersky Lab
# Licensed under the 3-Clause BSD License

set -e

PROJECT_NAME=Protobuf
KOS_DIR="$(dirname "$(realpath "${0}")")"
ROOT_DIR="$(dirname "${KOS_DIR}")"
BUILD="${ROOT_DIR}/build/kos"
DEFAULT_INSTALL_PREFIX="${ROOT_DIR}/install/kos"
JOBS=1
DEFAULT_BUILD_TYPE=Debug

function PrintHelp() {
cat<<HELP

Build and install ${PROJECT_NAME} for KasperskyOS.

USAGE:

    ${0} [OPTIONS]

OPTIONS:

    -h, --help
        Help text.

    -s, --sdk PATH
        Path to the installed version of the KasperskyOS Community Edition SDK.
        The path must be set using either the value of the SDK_PREFIX environment variable or the -s option.
        The value specified in the -s option takes precedence over the value of the SDK_PREFIX environment variable.

    -i, --install PATH
        Path to the directory where ${PROJECT_NAME} for KasperskyOS will be installed.
        If not specified, the default path ${DEFAULT_INSTALL_PREFIX} will be used.
        The value specified in the -i option takes precedence over the value of the INSTALL_PREFIX environment variable.

    -j, --jobs N
        Number of jobs for parallel build.
        If not specified, the default value ${JOBS} will be used.

    --build-type TYPE
        Set build type: release or debug.
        Default build type is $(echo -n ${DEFAULT_BUILD_TYPE} | tr '[:upper:]' '[:lower:]').
HELP
}

# Parse command line options.
while [ -n "${1}" ]; do
    case "${1}" in
    -h | --help) PrintHelp
        exit 0;;
    -s | --sdk) SDK_PREFIX="${2}"
        shift;;
    -i | --install) INSTALL_PREFIX="${2}"
        shift;;
    -j | --jobs) JOBS="${2}"
        shift;;
    --build-type)
        case "${2}" in
        release) BUILD_TYPE=Release
            shift;;
        debug) BUILD_TYPE=Debug
            shift;;
        *) echo "Unknown build type - '${2}'."
            PrintHelp
            exit 1;;
        esac;;
    *) echo "Unknown option - '${1}'."
        PrintHelp
        exit 1;;
    esac
    shift
done

if [ -z "${SDK_PREFIX}" ]; then
    echo "Path to the installed KasperskyOS SDK is not specified."
    PrintHelp
    exit 1
fi

if [ -z "${TARGET_PLATFORM}" ]; then
    echo "Target platform is not specified. Try to autodetect..."
    TARGET_PLATFORMS=($(ls -d "${SDK_PREFIX}"/sysroot-* | sed 's|.*sysroot-\(.*\)|\1|'))
    if [ ${#TARGET_PLATFORMS[@]} -gt 1 ]; then
        echo "More than one target platform found: ${TARGET_PLATFORMS[*]}."
        echo "Reinstall SDK or remove extra sysroot-* directories."
        exit 1
    fi

    export TARGET_PLATFORM=${TARGET_PLATFORMS[0]}
    echo "Platform ${TARGET_PLATFORM} will be used."
fi

if [ -z "${INSTALL_PREFIX}" ]; then
    export INSTALL_PREFIX="${DEFAULT_INSTALL_PREFIX}"
    echo "Install path is not specified."
    echo "Use default install path - ${INSTALL_PREFIX}."
fi

if [ -z "${BUILD_TYPE}" ]; then
    export BUILD_TYPE=${DEFAULT_BUILD_TYPE}
    echo "Use default build type - ${BUILD_TYPE}."
fi

export LANG=C
export PKG_CONFIG=""
export PATH="${SDK_PREFIX}/toolchain/bin:${PATH}"

TOOLCHAIN_SUFFIX="-clang"

"${SDK_PREFIX}/toolchain/bin/cmake" -G "Unix Makefiles" -B "${BUILD}" \
      -D protobuf_BUILD_TESTS=OFF \
      -D protobuf_INSTALL_EXAMPLES=OFF \
      -D protobuf_BUILD_PROTOC_BINARIES=OFF \
      -D BUILD_SHARED_LIBS=OFF \
      -D CMAKE_BUILD_TYPE:STRING=${BUILD_TYPE} \
      -D CMAKE_INSTALL_PREFIX:STRING="${INSTALL_PREFIX}" \
      -D CMAKE_FIND_ROOT_PATH="${PREFIX_DIR}/sysroot-${TARGET_PLATFORM}" \
      -D CMAKE_TOOLCHAIN_FILE="${SDK_PREFIX}/toolchain/share/toolchain-${TARGET_PLATFORM}${TOOLCHAIN_SUFFIX}.cmake" \
      "${ROOT_DIR}/cmake" && "$SDK_PREFIX/toolchain/bin/cmake" --build "${BUILD}" -j${JOBS} --target install
