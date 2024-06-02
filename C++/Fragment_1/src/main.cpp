//!/////////////////////////////////////////////////////////////////////////////
///  \brief      Fragment 1 -- Async Programming
//!  \file       main.cpp
//!  \author     Jose Arboleda
//!  \date       2024
//!  \copyright  MIT License
//!/////////////////////////////////////////////////////////////////////////////
#include <algorithm>
#include <future>
#include <iostream>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

// This causes the program to execute the tasks in async mode
#define PROG_MODEL_ASYNC

const size_t MAX_TASKS{10};
const std::chrono::seconds WORKER_TIMEOUT{1};

// Defines a callable entity to represent a dummy task
class Task {
public:
   int operator()() {
    std::this_thread::sleep_for(WORKER_TIMEOUT);
    return rand();
   }
};

std::mutex m;
std::queue<Task> q;
std::vector<int> r;
std::vector<std::future<int>>  rf;

// Push MAX_TASKS into the working queue
void sender() {
    auto tasks = MAX_TASKS;

    while(tasks--) {
        std::unique_lock lk{m};
        q.emplace(Task{});
    }
}

// Fetch and execute MAX_TASKS from the working queue
void receiver() {
    auto tasks = MAX_TASKS;

    while(tasks--) {
        std::unique_lock lk{m};

        if (!q.empty()) {
            auto& task = q.front();

#ifdef PROG_MODEL_ASYNC
            auto result = std::async(std::launch::async, task);
            rf.push_back(std::move(result));
#else
            r.push_back(task());
#endif
            q.pop();
        }
    }
}

int main()
{
    std::cout << "Available CPUs: " << std::thread::hardware_concurrency() << "\n";

    std::thread t1{sender};
    std::thread t2{receiver};

    t1.join();
    t2.join();

    std::cout << "Result: ";

    for (int i = 0; i < MAX_TASKS; i++) {
#ifdef PROG_MODEL_ASYNC
        std::cout << rf[i].get();
#else
        std::cout << r[i];
#endif
        std::cout << " ";
    }

    std::cout << "\n";
    
    return 0;
}