//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 4 -- Dynamic Library Loader
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2025
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <cstring>
#include <dlfcn.h>
#include <iomanip>
#include <iostream>
#include <openssl/sha.h>
#include <stdexcept>

// This wrapper attempts to load libssl and expose some functions using GNU Dynamic Link Library
class LibSSL {
    void* m_pLibHandle = nullptr;

    LibSSL()
    {
        m_pLibHandle = dlopen("libssl.so", RTLD_LAZY);
        if (!m_pLibHandle)
            throw std::runtime_error("Failed to load libssl.so");

        RAND_poll = reinterpret_cast<int(*)()>(dlsym(m_pLibHandle, "RAND_poll"));
        if (!RAND_poll) {
            (void)dlclose(m_pLibHandle);
            throw std::runtime_error("Failed to load RAND_poll");
        }

        RAND_bytes = reinterpret_cast<int(*)(unsigned char*, int)>(dlsym(m_pLibHandle, "RAND_bytes"));
        if (!RAND_bytes) {
            (void)dlclose(m_pLibHandle);
            throw std::runtime_error("Failed to load RAND_bytes");
        }

        SHA256_Init = reinterpret_cast<int(*)(SHA256_CTX*)>(dlsym(m_pLibHandle, "SHA256_Init"));
        if (!SHA256_Init) {
            (void)dlclose(m_pLibHandle);
            throw std::runtime_error("Failed to load SHA256_Init");
        }

        SHA256_Update = reinterpret_cast<int(*)(SHA256_CTX*, const void*, size_t)>(dlsym(m_pLibHandle, "SHA256_Update"));
        if (!SHA256_Update) {
            (void)dlclose(m_pLibHandle);
            throw std::runtime_error("Failed to load SHA256_Update");
        }

        SHA256_Final = reinterpret_cast<int(*)(unsigned char*, SHA256_CTX*)>(dlsym(m_pLibHandle, "SHA256_Final"));
        if (!SHA256_Final) {
            (void)dlclose(m_pLibHandle);
            throw std::runtime_error("Failed to load SHA256_Final");
        }

        std::cout << "Created LibSSL wrapper\n";
    }

    ~LibSSL()
    {
        (void)dlclose(m_pLibHandle);
        std::cout << "Destroyed LibSSL wrapper\n";
    }

public:
    static LibSSL* getInstance()
    {
        try
        {
            static LibSSL instance;
            return &instance;
        } catch (const std::exception& e){
            std::cerr << "LibSSL constructor failed with --> " << e.what() << "\n";
            return nullptr;
        }
    }

    int(*RAND_poll)();
    int(*RAND_bytes)(unsigned char*, int);

    int(*SHA256_Init)(SHA256_CTX*);
    int(*SHA256_Update)(SHA256_CTX*, const void*, size_t);
    int(*SHA256_Final)(unsigned char*, SHA256_CTX*);
};

int main()
{
    unsigned int rand = 0;
    const LibSSL* pLibSSL = LibSSL::getInstance();

    if (!pLibSSL)
        return 1;

    pLibSSL->RAND_poll();
    pLibSSL->RAND_bytes(reinterpret_cast<unsigned char*>(&rand), sizeof(rand));

    std::cout << "\n";

    std::cout << "Random number\n";
    std::cout << "*****************************************************\n";
    std::cout << rand << "\n\n";

    const auto str1 = "Hello World!";
    unsigned char buff[SHA256_DIGEST_LENGTH];

    SHA256_CTX ctx;
    pLibSSL->SHA256_Init(&ctx);
    pLibSSL->SHA256_Update(&ctx, reinterpret_cast<const void*>(str1), strlen(str1));
    pLibSSL->SHA256_Final(buff, &ctx);

    std::cout << "SHA256 " << str1 << "\n";
    std::cout << "*****************************************************\n";
    std::cout << std::hex;
    for (const auto& i: buff)
    {
        std::cout << std::setw(2) << std::setfill('0');
        std::cout << static_cast<int>(i);
    }

    std::cout << "\n\n";

    return 0;
}