/*
 * © 2024 AO Kaspersky Lab
 * Licensed under the 3-Clause BSD License
 */

#include <iostream>
#include <map>
#include <sstream>
#include <vector>

#include <kosipc/application.h>
#include <kosipc/event_loop.h>
#include <kosipc/make_application.h>
#include <kosipc/serve_static_channel.h>

#include <common/print.h>
#include <common/ipc.h>

#include <google/protobuf/text_format.h>
#include <google/protobuf/util/time_util.h>
#include <addressbook.pb.h>

#include <example/Consumer.edl.cpp.h>

using namespace kosipc;
using namespace consumer;
using namespace util;

using google::protobuf::util::TimeUtil;

const std::map<tutorial::Person_PhoneType, std::string_view> phoneTypes
{
    {tutorial::Person::HOME,   "Home"},
    {tutorial::Person::WORK,   "Work"},
    {tutorial::Person::MOBILE, "Mobile"}
};

void PrintAddressBook(const tutorial::AddressBook& address_book)
{
    for (int i = 0; i < address_book.people_size(); i++)
    {
        const tutorial::Person& person = address_book.people(i);
        Print("Person ID: ", person.id());
        Print("  Name:",     person.name());

        if (person.email() != "")
        {
            Print("  E-mail address: ", person.email());
        }

        for (int j = 0; j < person.phones_size(); j++)
        {
            const tutorial::Person::PhoneNumber& phone_number = person.phones(j);
            auto type = phoneTypes.find(phone_number.type());
            Print(" ", type != phoneTypes.end() ? type->second : "Unknown", "phone #:", phone_number.number());
        }

        if (person.has_last_updated())
        {
            Print("  Updated: ", TimeUtil::ToString(person.last_updated()));
        }
    }
}

class MsgConsumer : public ipc::IConsumer
{
public:

    void Consume(const ipc::Message& message) override
    {
        std::stringstream is{std::string(message.begin(), message.end())};
        tutorial::AddressBook addressBook;
        if (addressBook.ParseFromIstream(&is))
        {
            PrintAddressBook(addressBook);
        }
        else
        {
            Print("Failed to parse address book.");
        }
    }
};

int main(void)
{
    // Verify that the version of the library that we linked against is
    // compatible with the version of the headers we compiled against.
    GOOGLE_PROTOBUF_VERIFY_VERSION;

    Print("Started");

    try
    {
        auto             app{MakeApplicationAutodetect()};
        MsgConsumer      msgConsumer;
        components::Root root;
        root.consumer = &msgConsumer;
        auto loop     = app.MakeEventLoop(ServeStaticChannel(consumer::ServiceId, root));
        loop.Run();
    }
    catch (const std::exception& exc)
    {
        Print("Error occurred:", exc.what());
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
