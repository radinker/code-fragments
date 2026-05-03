//!/////////////////////////////////////////////////////////////////////////////
///  Fragment 6 -- C++ Modules
//!  \file       dummy.cpp
//!  \author     Jose Arboleda
//!  \date       2026
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
// Make the module visible
export module dummy;

// System modules
// Export to make them visible wherever the dummy module is imported
export import <iostream>;
export import <string>;

export void foo() {
    std::cout << "foo from dummy module\n";
}

export namespace dummy {
    void bar() {
        std::cout << "dummy::bar from dummy module!\n";
    }
}

export namespace custom {
    std::string foo() {
        return std::string("custom::foo from dummy module!\n");
    }
}
