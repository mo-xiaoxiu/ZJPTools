#include <iostream>
#include <chrono>
#include <thread>
#include <vector>
#include <string>

// 包含ThreadLoop头文件
#include "ThreadLoop.h"

using namespace std::chrono_literals;

// 简单的任务函数
void simpleTask(int id) {
    std::cout << "Task " << id << " started" << std::endl;
    std::this_thread::sleep_for(100ms);
    std::cout << "Task " << id << " completed" << std::endl;
}

// 带返回值的任务
int calculateTask(int a, int b) {
    std::cout << "Calculation task: " << a << " + " << b << std::endl;
    std::this_thread::sleep_for(50ms);
    return a + b;
}

// 模拟网络请求任务
void networkTask(const std::string& url) {
    std::cout << "Simulating network request: " << url << std::endl;
    std::this_thread::sleep_for(200ms);
    std::cout << "Network request completed: " << url << std::endl;
}

int main() {
    std::cout << "=== ThreadLoop Usage Example ===" << std::endl;
    
    try {
        // 获取ThreadLoop单例实例
        auto& threadLoop = zjpThreadloop::ThreadLoop::getThreadLoopInstance();
        
        // 设置线程数量
        threadLoop.setThreadNum(4);
        std::cout << "Set thread pool size to: 4" << std::endl;
        
        // 启动线程池
        threadLoop.start();
        std::cout << "Thread pool started" << std::endl;
        
        // 示例1: 添加简单任务
        std::cout << "\n--- Example 1: Simple Tasks ---" << std::endl;
        for (int i = 1; i <= 5; ++i) {
            threadLoop.addTask([i]() {
                simpleTask(i);
            }, i); // 优先级为任务ID
        }
        
        // 等待一段时间让任务执行
        std::this_thread::sleep_for(1s);
        
        // 示例2: 添加网络请求任务
        std::cout << "\n--- Example 2: Network Request Tasks ---" << std::endl;
        std::vector<std::string> urls = {
            "https://api.example.com/users",
            "https://api.example.com/posts",
            "https://api.example.com/comments"
        };
        
        for (const auto& url : urls) {
            threadLoop.addTask([url]() {
                networkTask(url);
            }, 10); // 高优先级
        }
        
        // 等待任务执行
        std::this_thread::sleep_for(1s);
        
        // 示例3: 批量任务处理
        std::cout << "\n--- Example 3: Batch Calculation Tasks ---" << std::endl;
        std::vector<std::pair<int, int>> calculations = {
            {1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}
        };
        
        for (const auto& calc : calculations) {
            threadLoop.addTask([calc]() {
                int result = calculateTask(calc.first, calc.second);
                std::cout << "Calculation result: " << calc.first << " + " << calc.second 
                          << " = " << result << std::endl;
            }, 5);
        }
        
        // 等待所有任务完成
        std::this_thread::sleep_for(2s);
        
        // 停止线程池
        std::cout << "\nStopping thread pool..." << std::endl;
        threadLoop.join();
        
        std::cout << "All tasks completed, thread pool stopped" << std::endl;
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
} 