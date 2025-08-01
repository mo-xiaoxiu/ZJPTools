#include <iostream>
#include <chrono>
#include <thread>

// 包含DnsParser头文件
#include "dns_resolver.h"
#include "async_resolver.h"

using namespace std::chrono_literals;

int main() {
    std::cout << "=== DNS Resolver Simple Test ===" << std::endl;
    
    try {
        // 使用工厂函数创建DNS解析器
        auto resolver = zjpdns::createDnsResolver();
        
        if (!resolver) {
            std::cerr << "Failed to create DNS resolver" << std::endl;
            return 1;
        }
        
        // 设置DNS服务器
        resolver->setDnsServer("8.8.8.8", 53);
        resolver->setTimeout(5000);
        
        std::cout << "Starting domain resolution..." << std::endl;
        
        // 解析一个域名
        auto result = resolver->resolve("www.google.com", zjpdns::DnsRecordType::A);
        
        if (result.success) {
            std::cout << "Resolution successful!" << std::endl;
            std::cout << "IP addresses:" << std::endl;
            for (const auto& address : result.addresses) {
                std::cout << "  " << address << std::endl;
            }
        } else {
            std::cout << "Resolution failed: " << result.error_message << std::endl;
        }
        
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        return 1;
    }
    
    return 0;
} 