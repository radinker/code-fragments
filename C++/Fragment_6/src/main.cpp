//!/////////////////////////////////////////////////////////////////////////////
///  Fragment 6 -- C++ Modules
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2026
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
import dummy;

int main()
{
    foo(); // foo from dummy module
    dummy::bar(); // bar from dummy namespace in dummy module

    const auto msg = custom::foo(); // foo from custom namespace in dummy module
    std::cout << msg;

    return 0;
}
