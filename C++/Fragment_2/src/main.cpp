//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 2 -- DBus Example
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2024
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <giomm.h>
#include <iostream>

// Example to perform a synchronous call to get the hostname using DBus
int main()
{
    Gio::init();

    // Method to call and property to retrieve
    const Glib::ustring method              {"Get"};
    const Glib::ustring property            {"Hostname"};

    // BDus name owning the object
    const Glib::ustring name                {"org.freedesktop.hostname1"};

    // Path to the object exposing the interface
    const Glib::ustring path                {"/org/freedesktop/hostname1"};

    // Interface exposing the method to be called
    const Glib::ustring propertiesInterface {"org.freedesktop.DBus.Properties"};

    // Get a proxy fot the interface
    auto hostNameProxy = Gio::DBus::Proxy::create_for_bus_sync(Gio::DBus::BusType::SYSTEM,
    name, path, propertiesInterface);

    if (hostNameProxy.get() == nullptr) {
        std::cout << "Null pointer on hostname interface proxy\n";
        return 1;
    }

    // Method arguments are of type Glib::Variant<T>
    auto interfaceVariant = Glib::Variant<Glib::ustring>::create(name);
    auto propertyVariant  = Glib::Variant<Glib::ustring>::create(property);

    // Arguments are passed in a variant container
    auto args = Glib::VariantContainerBase::create_tuple({interfaceVariant, propertyVariant});

    try {
        // Perform a DBus sync call to the hostname interface
        auto hostName = hostNameProxy->call_sync(method, args);

        // Get the variant value. DBus result is of type Variant<Variant<T>>
        auto val = Glib::VariantBase::cast_dynamic<Glib::Variant<Glib::Variant<Glib::ustring>>>
        (hostName.get_child()).get().get();

        std::cout << "Value: " << val << "\n";
        std::cout << "Type: "  << hostName.get_child().get_type_string().data() << "\n";
    }
    catch (const Glib::Error& e) {
        std::cout << "Error calling method: " << e.what() << "\n";
    }
    catch (const std::bad_alloc& e) {
        std::cout << "Error casting returned value: " << e.what() << "\n";
    }

    // In case of asynchronous communication, a loop is required to get the events from the DBus
    // auto mainLoop = Glib::MainLoop::create();
    // mainLoop->run();

    return 0;
}