cmake_minimum_required(VERSION 3.10)
project(GitHubToolsExamples)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找依赖库
find_package(PkgConfig REQUIRED)

# 查找ThreadLoop库
find_library(THREADLOOP_LIBRARY NAMES zjpThreadloop)
find_path(THREADLOOP_INCLUDE_DIR NAMES ThreadLoop.h PATH_SUFFIXES threadloop)

# 查找DnsParser库
find_library(DNSPARSER_LIBRARY NAMES zjpdns)
find_path(DNSPARSER_INCLUDE_DIR NAMES dns_resolver.h PATH_SUFFIXES zjpdns)

# 设置包含目录
include_directories(${CMAKE_SOURCE_DIR}/../install/include)

# 检查是否找到库
if(NOT THREADLOOP_LIBRARY)
    message(FATAL_ERROR "ThreadLoop library not found")
endif()

if(NOT DNSPARSER_LIBRARY)
    message(FATAL_ERROR "DnsParser library not found")
endif()

# 包含目录
include_directories(${THREADLOOP_INCLUDE_DIR} ${DNSPARSER_INCLUDE_DIR})

# 示例程序1: ThreadLoop示例
add_executable(threadloop_example threadloop_example.cpp)
target_link_libraries(threadloop_example ${THREADLOOP_LIBRARY})

# 示例程序2: DNS简单测试
add_executable(dns_simple dns_simple.cpp)
target_link_libraries(dns_simple ${DNSPARSER_LIBRARY})

# 安装目标
install(TARGETS threadloop_example dns_simple
        RUNTIME DESTINATION bin) 