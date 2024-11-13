# Protocol Buffers for KasperskyOS

This project is an adaptation of the [Protocol Buffers (Protobuf™)](https://github.com/protocolbuffers/protobuf) for KasperskyOS.
It is based on the [3.19.4](https://github.com/protocolbuffers/protobuf/tree/v3.19.4) version of the Protocol Buffers
and includes an example that demonstrates its use in KasperskyOS.

Protocol Buffers are Google's language-neutral, platform-neutral, extensible mechanism for serializing structured data.
For more information, see the [Protocol Buffers Documentation](https://developers.google.com/protocol-buffers/).

For additional details on KasperskyOS, including its limitations and known issues, please refer to the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_community_edition).

## Table of contents
- [Protocol Buffers for KasperskyOS](#protocol-buffers-for-kasperskyos)
  - [Table of contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and installing](#building-and-installing)
      - [Protobuf compiler](#protobuf-compiler)
      - [Protobuf C++ runtime](#protobuf-c-runtime)
      - [Tests](#tests)
  - [Usage](#usage)
  - [Trademarks](#trademarks)
  - [Contributing](#contributing)
  - [Licensing](#licensing)

## Getting started

### Prerequisites

1. [Install](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_sdk_install_and_remove)
KasperskyOS Community Edition SDK. You can download the latest version of the KasperskyOS Community Edition for free from
[os.kaspersky.com](https://os.kaspersky.com/development/). The minimum required version of KasperskyOS Community Edition SDK is 1.2.
For more information, see [System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_system_requirements).
1. Copy source files to your project directory.

### Building and installing

The build of the protobuf for KasperskyOS is implemented through a cross-compilation process.
The protobuf for KasperskyOS is built using the CMake build system, which is provided in the KasperskyOS Community Edition SDK.

To build and install the protobuf for KasperskyOS, you need to install the protobuf compiler (`protoc`) and the protobuf C++ runtime.
There are two methods for doing this. The recommended method is to use the scripts described in the [Protobuf compiler](#protobuf-compiler)
and the [Protobuf C++ runtime](#protobuf-c-runtime) sections. As an alternative, please refer to the
[C++ Installation Instructions](src/README.md).

#### Protobuf compiler

The `protoc` (used to compile `*.proto` files) must be built with the host toolchain.
This is because the `protoc` will be run on the host when building solutions for KasperskyOS.

To build and install the `protoc` for the host, go to the `./kos` directory and execute the [`host-build.sh`](./kos/host-build.sh) script.
The environment variable `INSTALL_PREFIX` specifies the installation path of the `protoc`.
If not specified, the `protoc` will be installed in the `./install/host` directory.

Syntax for using the `host-build.sh` script:
```sh
$ host-build.sh [-i INSTALL_PREFIX]
```
The parameter `-i, --install-prefix INSTALL_PREFIX` specifies the installation path of the `protoc`.
The value specified in this parameter takes precedence over the value of the `INSTALL_PREFIX` environment variable.

By default, the build type is set to `Debug`, the build libraries are static (`BUILD_SHARED_LIBS=OFF`),
and the build path is set to `./build/host`. To change this, edit the `host-build.sh` script as needed.

For example:
```sh
$ ./host-build.sh
```

[⬆ Back to Top](#Table-of-contents)

#### Protobuf C++ runtime

To build and install the protobuf libraries, go to the `./kos` directory and execute the [`cross-build.sh`](./kos/cross-build.sh) script.
There are environment variables that affect the build and installation of the libraries:

* `SDK_PREFIX` specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `INSTALL_PREFIX` specifies the installation path of the protobuf libraries.
If not specified, the libraries will be installed in the `./install/kos` directory.
* `TARGET` specifies the target platform. If not specified, the platform will be determined automatically.

Syntax for using the `cross-build.sh` script:

`$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> [TARGET="aarch64-kos"] ./cross-build.sh`,

where `version` specifies the latest version number of the [KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/).

By default, the build type is set to `Debug`, the build libraries are dynamic (`BUILD_SHARED_LIBS=ON`),
and the build path is set to `./build/kos`. To change this, edit the `cross-build.sh` script as needed.

For CMake build system to find the protobuf libraries, make sure that the directory where the libraries were installed
is listed in the environment variable `CMAKE_FIND_ROOT_PATH`.

[⬆ Back to Top](#Table-of-contents)

#### Tests

The protobuf's [tests](./third_party/googletest) have been adapted to run on KasperskyOS. The tests have the following limitations:

* Unit tests for KasperskyOS are currently available only for QEMU.
* Only IPv4 tests are compatible with KasperskyOS.
* Some tests are skipped:
  * `CommandLineInterfaceTest` since KasperskyOS does not have a protobuf command-line interface (CLI).
  * `RubyGeneratorTest` since KasperskyOS only supports C++ programming language.
  * `AnyTest.TestPackFromSerializationExceedsSizeLimit`, `MessageTest.2G`, and `IoTest.LargeOutput`
since they require more than 2GB of memory.

Tests use an out-of-source build. The build tree is located in the generated `./build/tests_kos` directory.
For each test suite, a separate image will be created. As it can be taxing on disk space, the tests will be run sequentially.

To build and run the tests, go to the `./kos` directory and execute the [`build-tests.sh`](./kos/build-tests.sh) script.
There are environment variables that affect the build and installation of the tests:

* `SDK_PREFIX` specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `PROTOC_EXEC` specifies the path to the previously installed `protoc`.
If not specified, the path `./install/host/bin/protoc` will be used.
(If the `protoc` was not previously installed, the script `build-tests.sh` will install it.)
* `TARGET` specifies the target platform. (Currently only the `aarch64-kos` platform is supported.)

Syntax for using the `build-tests.sh` script:

`$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> [TARGET="aarch64-kos"] [PROTOC_EXEC=./install/host/bin/protoc] ./build-tests.sh [--help] [--list] [-n TEST_NAME_1] ... [-n TEST_NAME_N] [-t TIMEOUT] [-o OUT_PATH] [-j N_JOBS]`,

where:

* `version`

  Latest version number of the [KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/).
* `-h, --help`

  Help text.
* `-l, --list`

  List of tests that can be run.
* `-n, --name TEST_NAME`

  Test name to execute. The parameter can be repeated multiple times.
If not specified, all tests will be executed.
* `-t, --timeout TIMEOUT`

  Time, in seconds, allotted to start and execute a single test case. Default value is 300 seconds.
* `-o, --out OUT_PATH`

  Path where the results of the test run will be stored. If not specified, the results will be stored in the `./build/tests-kos/logs` directory.
* `-j, --jobs N_JOBS`

  Number of jobs for parallel build. If not specified, the default value obtained from the `nproc` command is used.

The CMake files for building the tests are located in the `./cmake/kos` directory.

[⬆ Back to Top](#Table-of-contents)

## Usage

When you develop a KasperskyOS-based solution, use the
[recommended structure of project directories](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_cmake_using_sdk_cmake)
to simplify usage of CMake scripts.

The `cross-build.sh` script builds only runtime libraries.
To generate source files from `*.proto` files your must use the host `protoc`.
To get it you can use the `find_program` function. For example:

`find_program(protoc NAMES protoc REQUIRED)`

For more on using the previously built protobuf on KasperskyOS, see the [README.md](./examples/kos) file for the project's example.

## Trademarks

Registered trademarks and endpoint marks are the property of their respective owners.

GoogleTest, Protobuf are a trademark of Google LLC.

Raspberry Pi is a trademark of the Raspberry Pi Foundation.

## Contributing

Only KasperskyOS-specific changes can be approved. See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed instructions on code contribution.

## Licensing

This project is licensed under the terms of the 3-Clause BSD License. See [LICENSE](LICENSE) for more information.

[⬆ Back to Top](#Table-of-contents)

© 2024 AO Kaspersky Lab
