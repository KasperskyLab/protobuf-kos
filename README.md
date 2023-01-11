# Protocol Buffers adaptation for KasperskyOS - Google's data interchange format

This is a fork of [Protocol Buffers](https://github.com/protocolbuffers/protobuf) project adapted to be used with KasperskyOS. For more information about the target OS, please refer to [KaspeksyOS Community Edition](https://support.kaspersky.com/help/KCE/1.1/en-US/community_edition.htm).

For general information on using Protocol Buffers, its features and so on, please see the [Protocol Buffers website](https://developers.google.com/protocol-buffers/).

## About Protocol Buffers

Protocol Buffers (a.k.a., protobuf) are Google's language-neutral,
platform-neutral, extensible mechanism for serializing structured data. You
can find [protobuf's documentation on the Google Developers site](https://developers.google.com/protocol-buffers/).

This README file contains protobuf installation instructions. To install
protobuf, you need to install the protocol compiler (used to compile .proto
files) and the protobuf runtime for your chosen programming language.

## Building and Installation

### KasperskyOS

For a default build and use, you need to install the KasperskyOS Community Edition SDK on your system. The latest version of the SDK can be downloaded from this [link](https://os.kaspersky.com/development/). The Abseil source code has been checked on the KasperskyOS Community Edition SDK version 1.1.0.

### Protocol Compiler Installation

The protocol compiler is written in C++. If you are using C++, please follow
the [C++ Installation Instructions](src/README.md) to install protoc along
with the C++ runtime.

### Protobuf Runtime Installation

Only C++ language is adopted for KasperskyOS. You can find instructions about
how to install protobuf runtime for C++ in [src](src).

### Quick Start

The best way to learn how to use protobuf is to follow the tutorials in [developer guide](https://developers.google.com/protocol-buffers/docs/tutorials).

If you want to learn from code examples, take a look at the examples in the
[examples](examples) directory.

## Contributing

Please see the [Contributing](CONTRIBUTING.md) page for generic info.

We'll follow the parent project contributing rules but would consider to accept only KasperskyOS-specific changes, so for that it is advised to use pull-requests.

## License

The c-ares library is licensed under the terms of the 3-Clause BSD License. See [LICENSE](LICENSE) for more information.
