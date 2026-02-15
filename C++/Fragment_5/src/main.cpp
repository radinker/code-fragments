//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 5 -- Copy and Swap
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2026
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <iostream>
//#include <type_traits>
#include <utility>

class X {
    int* data;

public:
    static constexpr size_t MAX_DATA = 10;

    X() {
        std::cout << "Creating X\n";

        data = new int[MAX_DATA];
        for (size_t i = 0; i < MAX_DATA; i++) {
            data[i] = i;
        }
    }

    X(const X& obj) {
        data = new int[MAX_DATA];

        std::cout << "Copying X\n";

        for (size_t i = 0; i < MAX_DATA; i++) {
            data[i] = obj.data[i];
        }
    }

    X(X&&) noexcept = default;

    ~X() {
        std::cout << "Destroying X\n";
        delete[] data;
    }

    X& operator=(const X& obj) {
        // Explicit copy of obj. If an exception occurs in the copy constructor, this instance won't be modified
        return copyAndSwap(obj);
    }

    X& operator=(X&& obj) noexcept {
        std::cout << "Move assignment\n";
        std::swap(data, obj.data);
        return *this;
    }

    void print() const {
        for (size_t i = 0; i < MAX_DATA; i++) {
            std::cout << data[i] << " ";
        }
        std::cout << std::endl;
    }

    /*template<typename T>
    X& operator=(T&& obj) noexcept {
        using check_type = std::remove_reference_t<T>;
        static_assert(std::is_same_v<check_type, X> && !std::is_lvalue_reference_v<T>, "X::operator= is bounded to X, X&& only");

        std::swap(data, obj.data);
        return *this;
    }*/
private:
    X& copyAndSwap(X obj) noexcept {
        std::swap(data, obj.data);
        return *this;
    }
};

int main()
{
    X x;

    x = std::move(x);   // Explicit move assignment
    x = x;              // Copy and swap
    x.print();

    x = X{};            // Move assignment
    x.print();

    return 0;
}
