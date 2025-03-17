//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 3 -- Custom Memory Allocator
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2025
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <cerrno>
#include <iostream>
#include <map>
#include <new>
#include <stdexcept>
#include <vector>

//Linux headers
#include <sys/mman.h>

// A custom memory allocator using the Linux mmap system call
template<typename T>
class CustomAllocator {
public:
    using value_type = T;

    static T* allocate(size_t n) {
        void* ptr = mmap(nullptr, n, PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);

        if (ptr == reinterpret_cast<void*>(-1)) {
            std::cerr << "Memory allocation failed with code: " << errno << "\n";
            throw std::bad_alloc();
        }

        std::cout << "Allocated memory\n";
        return static_cast<T*>(ptr);
    }

    static void deallocate(T* ptr, size_t n) {
        if (munmap(ptr, n) == -1) {
            std::cerr << "Memory deallocation failed with code: " << errno << "\n";
            return;
        }
        std::cout << "Deallocated memory\n";
    }
};


int main()
{
    try
    {
        //Example using std::vector
        std::vector<int, CustomAllocator<int>> v{1, 2, 3, 4, 5};

        v.push_back(6);
        v.push_back(7);
        v.push_back(8);

        for (auto i: v) {
            std::cout << i << " ";
        }

        std::cout << "\n";

        //Example using std::map
        std::map<int, std::string, std::less<>, CustomAllocator<std::pair<const int, std::string>>> m;

        m.insert(std::make_pair(1, "Hello "));
        m.insert(std::make_pair(2, "World!"));

        for (const auto& i: m) {
            std::cout << i.second << " ";
        }

        std::cout << "\n";

    } catch (const std::exception& e) {
        std::cout << "Oops, something went wrong: " << e.what() << "\n";
    }

    return 0;
}
