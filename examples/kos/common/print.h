/*
 * © 2024 AO Kaspersky Lab
 * Licensed under the 3-Clause BSD License
 */

#ifndef PRINT_UTIL_H
#define PRINT_UTIL_H

#include <iostream>
#include <sstream>
#include <string>

#include <coresrv/task/task_api.h>

namespace util    {

class TaskName
{
    static constexpr int  MaxNameLen  = 64;
    static constexpr auto DefaultName = "Task";
    std::string m_name;

public:

    TaskName() : m_name(MaxNameLen, 0)
    {
        if (KnTaskGetName(m_name.data(), MaxNameLen) != rcOk)
        {
            std::cerr << "Failed to get task name, default name - " << DefaultName << " will be used\n";
            m_name = DefaultName;
        }
    }
    
    const std::string& Get() const
    {
        return m_name;
    }
};

template <typename... Args>
void Print(Args&&... args)
{
    static TaskName name;
    std::stringstream ss;
    ss << '[' << name.Get() << "]";
    ((ss << ' ' << args), ...) << '\n';
    std::cerr << ss.str();
}

} // namespace util
#endif // PRINT_UTIL_H
