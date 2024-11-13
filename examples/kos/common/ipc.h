/*
 * © 2024 AO Kaspersky Lab
 * Licensed under the 3-Clause BSD License
 */

#ifndef COMMON_IPC_H
#define COMMON_IPC_H

#include <example/IConsumer.idl.cpp.h>

namespace consumer {

namespace ipc =  kosipc::stdcpp::example;

constexpr auto ServiceId = "message_consumer";
constexpr auto Endpoint  = "consumer";

} // namespace consumer
#endif // COMMON_IPC_H

