/*
 * © 2024 AO Kaspersky Lab
 * Licensed under the 3-Clause BSD License
 */

#include <fstream>
#include <map>
#include <sstream>
#include <string>
#include <string_view>
#include <utility>
#include <vector>

#include <google/protobuf/util/time_util.h>
#include <google/protobuf/text_format.h>

#include <kosipc/application.h>
#include <kosipc/make_application.h>
#include <kosipc/connect_static_channel.h>
#include <example/Producer.edl.cpp.h>

#include <common/ipc.h>
#include <common/print.h>

#include <nlohmann/json.hpp>
#include <addressbook.pb.h>

using namespace kosipc;
using namespace consumer;
using namespace util;

using google::protobuf::util::TimeUtil;
using json = nlohmann::json;

const std::map<std::string_view, tutorial::Person_PhoneType> phoneTypes
{
    {"Home",   tutorial::Person::HOME},
    {"Work",   tutorial::Person::WORK},
    {"Mobile", tutorial::Person::MOBILE}
};

// This function fills in a Person message based on user input.
tutorial::AddressBook ReadAddressBook(std::istream& is)
{
    static int id = 0;
    json content;
    is >> content;
    tutorial::AddressBook addressBook;

    for (const auto& personInfo : content["addressBook"])
    {
        auto person = addressBook.add_people();
        person->set_id(id++);
        person->set_name(personInfo.value("name", ""));
        person->set_email(personInfo.value("email", ""));
        *person->mutable_last_updated() = TimeUtil::SecondsToTimestamp(time(NULL));
        if (personInfo.contains("phones"))
        {
            for (const auto& phoneInfo : personInfo["phones"])
            {
                auto phone = person->add_phones();
                phone->set_number(phoneInfo.value("number", ""));
                auto it = phoneTypes.find(phoneInfo.value("type", ""));
                phone->set_type(it != phoneTypes.end() ? it->second : tutorial::Person::MOBILE);
            }
        }
    }
    return addressBook;
}

int main(int argc, const char *argv[])
{
    // Verify that the version of the library that we linked against is
    // compatible with the version of the headers we compiled against.
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    Print("Started");

    if (argc == 1)
    {
        Print("No address book file passed - nothing to do.");
        return EXIT_SUCCESS;
    }

    try
    {
        auto app{MakeApplicationAutodetect()};
        auto consumer{app.MakeProxy<ipc::IConsumer>(ConnectStaticChannel(consumer::ServiceId, consumer::Endpoint))};
        for (auto file = argv + 1; *file != nullptr; ++file)
        {
            std::ifstream ifs{*file};
            if (!ifs)
            {
                Print("Address book file", *file, "not found.");
                continue;
            }

            auto addressBook = ReadAddressBook(ifs);
            std::stringstream os;
            if (addressBook.SerializeToOstream(&os))
            {
                auto message = std::move(os).str();
                if (message.empty())
                {
                    Print("Address book from file", *file, "is empty.");
                }
                else if (message.size() > ipc::MaxMessageSize)
                {
                    Print("Address book from file", *file, "is too big");
                }
                else
                {
                    consumer->Consume(ipc::Message(message.begin(), message.end()));
                }
            }
            else
            {
                Print("Failed to serialize address book from file: ", file);
            }
        }
    }
    catch (const std::exception& exc)
    {
        Print("Error occurred:", exc.what());
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
