# KasperskyOS adaptation patch for Protocol Buffers

This project provides an adaptation patch for
[Protocol Buffers (Protobuf™)](https://github.com/protocolbuffers/protobuf), enabling its use in
KasperskyOS-based solutions. The project is based on the
[30.0](https://github.com/protocolbuffers/protobuf/tree/v30.0) version of Protocol Buffers.

Protocol Buffers are Google's language-neutral, platform-neutral, extensible mechanism for
serializing structured data. For more information, see the
[Protocol Buffers Documentation](https://developers.google.com/protocol-buffers/).

For additional details on KasperskyOS, including its limitations and known issues, please refer to
the [KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=community_edition).

## Table of contents
- [KasperskyOS adaptation patch for Protocol Buffers](#kasperskyos-adaptation-patch-for-protocol-buffers)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and installing](#building-and-installing)
      - [Protobuf compiler](#protobuf-compiler)
      - [Protobuf C++ runtime](#protobuf-c-runtime)
  - [Usage](#usage)
  - [Trademarks](#trademarks)
  - [Contributing](#contributing)
  - [Licensing](#licensing)

## Getting started

### Prerequisites

1. Confirm that your host system meets all the
[System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=system_requirements)
listed in the KasperskyOS Community Edition Developer's Guide.
1. [Install](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=sdk_install_and_remove)
the KasperskyOS Community Edition SDK version 1.4. You can download it for free from
[os.kaspersky.com](https://os.kaspersky.com/development/).
1. Copy the source files of this adaptation patch to your local project directory.
1. Source the SDK setup script to configure the build environment. This exports the `KOSCEDIR`
  environment variable, which points to the SDK installation directory:
   ```sh
   source /opt/KasperskyOS-Community-Edition-<platform>-<version>/common/set_env.sh
   ```

### Building and installing

The build of protobuf for KasperskyOS is implemented through a cross-compilation process. Protobuf
for KasperskyOS is built using the CMake build system, which is provided in the KasperskyOS
Community Edition SDK. When you develop a KasperskyOS-based solution, use the
[recommended structure of project directories](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.4&customization=KCE&helpid=cmake_using_sdk_cmake)
to simplify the use of CMake scripts.

To build and install protobuf for KasperskyOS, you need to install the protobuf compiler (`protoc`)
and the protobuf C++ runtime. There are two methods for doing this. The recommended method is to use
the commands described in the [Protobuf compiler](#protobuf-compiler) and the
[Protobuf C++ runtime](#protobuf-c-runtime) sections. As an alternative, please refer to the
[C++ Installation Instructions](https://github.com/protocolbuffers/protobuf/blob/v30.0/src/README.md).

#### Protobuf compiler

The Protocol Buffer compiler, `protoc` (used to compile `*.proto` files), must be built with the
host toolchain, as it runs on the host when building solutions for KasperskyOS.

To build and install `protoc` for the host, execute the following commands:
```sh
cmake -B build/host \
      -D CMAKE_INSTALL_PREFIX=~/.local/share/kos/$(basename $KOSCEDIR)/toolchain
cmake --build build/host -j`nproc` --target install
```

Set `CMAKE_INSTALL_PREFIX` to your preferred installation path. For compatibility with the
[protobuf example](https://github.com/KasperskyLab/kos-ce-extra/tree/master/examples/protobuf), we
recommend setting the `CMAKE_INSTALL_PREFIX` to
`~/.local/share/kos/$(basename $KOSCEDIR)/toolchain`.

#### Protobuf C++ runtime

To build and install the protobuf libraries for KasperskyOS, execute the following commands:
```sh
cmake -B build/kos \
      -D CMAKE_TOOLCHAIN_FILE=$KOSCEDIR/toolchain/share/toolchain-aarch64-kos.cmake \
      -D CMAKE_INSTALL_PREFIX=~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos
cmake --build build/kos -j`nproc` --target install
```

Set `CMAKE_INSTALL_PREFIX` to your preferred installation path. For compatibility with the
[protobuf example](https://github.com/KasperskyLab/kos-ce-extra/tree/master/examples/protobuf), we
recommend setting the `CMAKE_INSTALL_PREFIX` to
`~/.local/share/kos/$(basename $KOSCEDIR)/sysroot-aarch64-kos`.

[⬆ Back to Top](#table-of-contents)

## Usage

To generate source files from `*.proto` files, you must use the host `protoc`. You can locate it
using the `find_program()` CMake function. For example:

```cmake
find_program(protoc NAMES protoc REQUIRED)
```

To integrate the KasperskyOS-adapted protobuf into your solution, first build and install both the
[protobuf compiler](#protobuf-compiler) and the [protobuf C++ runtime](#protobuf-c-runtime) into the
directory defined by the `CMAKE_INSTALL_PREFIX` variable. For a practical implementation, refer to
the [protobuf example](https://github.com/KasperskyLab/kos-ce-extra/tree/master/examples/protobuf)
in the `KasperskyLab/kos-ce-extra` repository, which demonstrates this exact workflow.

## Trademarks

Registered trademarks and endpoint marks are the property of their respective owners.

Apple, macOS are trademarks of Apple Inc.

Docker and the Docker logo are trademarks or registered trademarks of Docker, Inc. in the United
States and/or other countries. Docker, Inc. and other parties may also have trademark rights in
other terms used herein.

GITHUB is a trademark of GitHub, Inc., registered in the United States and other countries.

Google, PROTOBUF are trademarks of Google LLC.

Win32 is a trademark of the Microsoft group of companies.

## Contributing

Only KasperskyOS-specific changes can be approved. See [CONTRIBUTING.md](CONTRIBUTING.md) for
detailed instructions on code contribution.

## Licensing

This project is licensed under the terms of the MIT license. See [LICENSE](LICENSE) for more information.

This project comprises publication(s) intended to be used with [Protocol Buffers](https://github.com/protocolbuffers/protobuf/tree/v30.0) ( “Upstream Project”).
The Upstream Project is licensed and distributed under its own license terms, which are separate from the terms of this project.
Nothing in this repository is intended to modify, replace, supersede, or relicense the Upstream Project or any of its components.

[⬆ Back to Top](#table-of-contents)

© 2026 AO Kaspersky Lab
