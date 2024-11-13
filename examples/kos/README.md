# Protobuf usage example

This solution is an example of using the previously built protobuf with KasperskyOS.
The example demonstrates sending a protobuf message from one program to another.

The protobuf libraries can be built and used as either static or dynamic libraries, but not both simultaneously.
In this solution a dynamically compiled version of the previously built protobuf libraries is used.
As a result, attempting to force static linking using the `initialize_platform(FORCE_STATIC)` command will trigger a linkage error.
For additional details regarding this command, please refer to the
[platform library](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_cmake_platform_lib).

## Table of contents
- [Protobuf usage example](#protobuf-usage-example)
  - [Table of contents](#table-of-contents)
  - [Solution overview](#solution-overview)
    - [List of programs](#list-of-programs)
    - [Initialization description](#initialization-description)
    - [Security policy description](#security-policy-description)
  - [Getting started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Building and running the example](#building-and-running-the-example)
      - [QEMU](#qemu)
      - [Raspberry Pi 4 B](#raspberry-pi-4-b)
      - [CMake input files](#cmake-input-files)
  - [Usage](#usage)
  - [Licensing](#licensing)

## Solution overview

### List of programs

* `Producer`—Program that reads the address book file on the SD card and converts it into a protobuf message,
which it then sends to the `Consumer` program
* `Consumer`—Program that prints the message received from the `Producer`
* `VfsSdCardFs`—Program that supports the SD card file system
* `BlobContainer`—Program that loads dynamic libraries used by other programs into shared memory
* `SDCard`—SD card driver
* `EntropyEntity`—Random number generator
* `BSP`—Driver for configuring pin multiplexing parameters (pinmux)

### Initialization description

 <details><summary>Statically created IPC channels</summary>

* `example.Consumer` → `kl.bc.BlobContainer`
* `example.Producer` → `kl.VfsSdCardFs`
* `example.Producer` → `example.Consumer`
* `example.Producer` → `kl.bc.BlobContainer`
* `kl.VfsSdCardFs` → `kl.drivers.SDCard`
* `kl.VfsSdCardFs` → `kl.EntropyEntity`
* `kl.VfsSdCardFs` → `kl.bc.BlobContainer`
* `kl.bc.BlobContainer` → `kl.VfsSdCardFs`
* `kl.drivers.SDCard` → `kl.drivers.BSP`
* `kl.drivers.SDCard` → `kl.bc.BlobContainer`
* `kl.EntropyEntity` → `kl.bc.BlobContainer`
* `kl.drivers.BSP` → `kl.bc.BlobContainer`

</details>

The [`./einit/src/init.yaml.in`](einit/src/init.yaml.in) template is used to automatically generate part of the solution initialization
description file `init.yaml`. For more information about the `init.yaml.in` template file, see the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_cmake_yaml_templates).

### Security policy description

The [`./einit/src/security.psl.in`](einit/src/security.psl.in) template is used to automatically generate part of the `security.psl` file
using CMake tools. The `security.psl` file contains part of a solution security policy description.
For more information about the `security.psl` file, see
[Describing a security policy for a KasperskyOS-based solution](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_ssp_descr).

[⬆ Back to Top](#Table-of-contents)

## Getting started

### Prerequisites

1. To install [KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/)
and run examples on the Raspberry Pi hardware platform, make sure you meet all the
[System requirements](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_system_requirements)
listed in the KasperskyOS Community Edition Developer's Guide.
1. Make sure that the environment variable `CMAKE_FIND_ROOT_PATH` specifies the installation path of the `protoc` compiler.

### Building and running the example

The example is built using the CMake build system, which is provided in the KasperskyOS Community Edition SDK.

To build the example, go to the `<root_directory>/kos` directory (where `root_directory` is the root directory with the project's source
files) and execute the `build-example.sh` script. Syntax for using the `build-example.sh` script:

`$ SDK_PREFIX=/opt/KasperskyOS-Community-Edition-<version> ./build-example.sh <platform> [--help]`,

where:

* `version`—Variable that specifies the latest version number of the
[KasperskyOS Community Edition SDK](https://os.kaspersky.com/development/).
* `SDK_PREFIX`—Environment variable that specifies the path to the installed version of the KasperskyOS Community Edition SDK.
The value of this environment variable must be set.
* `platform`—Variable that can take one of the following values: `qemu` for QEMU or `rpi` for Raspberry Pi 4 B. Default value: `qemu`.
* `-h, --help`—Parameter that displays help text when used.

#### QEMU

Running `build-example.sh` creates a KasperskyOS-based solution image that includes the example.
The `kos-qemu-image` solution image is located in the `<root_directory>/build/example_kos/einit` directory,
where `root_directory` is the root directory with the project's source files.
The `build-example.sh` script both builds the example on QEMU and runs it.

#### Raspberry Pi 4 B

Running `build-example.sh` creates a KasperskyOS-based solution image that includes the example and a bootable SD card image for
Raspberry Pi 4 B. The `kos-image` solution image is located in the `<root_directory>/build/example_kos/einit` directory,
where `root_directory` is the root directory with the project's source files.
The `rpi4kos.img` bootable SD card image is located in the `<root_directory>/build/example_kos` directory.

1. To copy the bootable SD card image to the SD card, connect the SD card to the computer and run the following command:

    `$ sudo dd bs=64k if=build/example_kos/rpi4kos.img of=/dev/sd[X] conv=fsync`,

    where `[X]` is the final character in the name of the SD card block device.

1. Connect the bootable SD card to the Raspberry Pi 4 B.
1. Supply power to the Raspberry Pi 4 B and wait for the example to run.

You can also use an alternative option to prepare and run the example:

1. Prepare Raspberry Pi 4 B and a bootable SD card to run the example by following the instructions in the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_preparing_sd_card_rpi).
1. Run the example by following the instructions in the
[KasperskyOS Community Edition Online Help](https://click.kaspersky.com/?hl=en-us&link=online_help&pid=kos&version=1.2&customization=KCE_running_sample_programs_rpi)

[⬆ Back to Top](#Table-of-contents)

#### CMake input files

[./consumer/CMakeLists.txt](consumer/CMakeLists.txt)—CMake commands for building the `Consumer` program.

[./producer/CMakeLists.txt](producer/CMakeLists.txt)—CMake commands for building the `Producer` program.

[./einit/CMakeLists.txt](einit/CMakeLists.txt)—CMake commands for building the `Einit` program and the solution image.

[./CMakeLists.txt](CMakeLists.txt)—CMake commands for building the solution.

## Usage

After running the example, the address book content and the results of any actions performed should be displayed in the standard output.
For example:
```
...

[example.Consumer] Started
[example.Producer] Started
[example.Consumer] Person ID:  0
[example.Consumer]   Name: White Rabbit
[example.Consumer]   E-mail address:  jump@rabbithole.com
[example.Consumer]   Mobile phone #: 8-801-587-5002
[example.Consumer]   Updated:  2024-04-21T21:38:32Z
[example.Consumer] Person ID:  1
[example.Consumer]   Name:  Santa Claus
[example.Consumer]   E-mail address:  ho-ho-ho@far-north.com
[example.Consumer]   Home phone #: 8-123-456-7890
[example.Consumer]   Updated:  2024-04-21T21:38:32Z
[example.Consumer] Person ID:  2
[example.Consumer]   Name: Boogie Man
[example.Consumer]   E-mail address:  me@your-fear.com
[example.Consumer]   Work phone #: 8-800-123-4567
[example.Consumer]   Mobile phone #: 8-001-987-5432
[example.Consumer]   Updated:  2024-04-21T21:38:32Z
```

## Licensing

This project is licensed under the terms of the 3-Clause BSD License. See [LICENSE](../../LICENSE) for more information.

[⬆ Back to Top](#Table-of-contents)

© 2024 AO Kaspersky Lab
