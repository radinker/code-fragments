//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 0 -- Static Polymorphism
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2024
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <array>
#include <iostream>
#include <tuple>
#include <variant>

template <typename T>
class Character {
public:
    void print() {
        static_cast<T*>(this)->print();
    }
};

class A: public Character<A> {
public:
    static void print() {
        std::cout << "A";
    }
};

class B: public Character<B> {
public:
    static void print() {
        std::cout << "B";
    }
};

template<typename... Args>
using CharTuple = std::tuple<Character<Args>...>;

using CharVariant = std::variant<A, B>;

int main()
{
    A a;
    B b;

    std::cout << "Variant ***************************************\n";
    std::array<CharVariant, 2> chars{CharVariant{a}, CharVariant {b}};

    for (auto& c: chars) {
         std::visit([]<typename T>(Character<T>& c_){
             c_.print();
         }, c);
    }

    std::cout << "\n";

    std::cout << "Tuple *****************************************\n";
    CharTuple<A, B> chars_ = std::make_tuple(a, b);

    std::apply([]<typename... T>(Character<T>&... c){
        (c.print(),...);
    }, chars_);

    std::cout << "\n";

    return 0;
}