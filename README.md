# GitHub工具库批量构建系统

这是一个用于批量下载、编译和集成GitHub工具库的脚本系统。支持多种编译选项、并行构建和自动化测试。

## 🚀 功能特性

- ✅ **批量下载**: 支持多个GitHub仓库的批量下载
- ✅ **灵活编译**: 支持静态库、动态库或两者同时编译
- ✅ **并行构建**: 支持多线程并行编译，提高构建速度
- ✅ **配置管理**: 通过配置文件轻松添加新仓库
- ✅ **示例程序**: 提供完整的示例程序用于测试集成效果
- ✅ **依赖检查**: 自动检查构建依赖
- ✅ **详细日志**: 彩色输出和详细的状态信息

## 📁 目录结构

```
.
├── build_tools.sh          # 主构建脚本
├── config/
│   └── repositories.conf   # 仓库配置文件
├── examples/               # 示例程序
│   ├── CMakeLists.txt
│   ├── threadloop_example.cpp
│   └── dns_simple.cpp
├── build/                  # 构建目录（自动创建）
├── install/                # 安装目录（自动创建）
├── repos/                  # 下载的仓库（自动创建）
└── README.md
```

## 🛠️ 安装依赖

在Ubuntu/Debian系统上：

```bash
sudo apt update
sudo apt install git cmake build-essential pkg-config
```

在CentOS/RHEL系统上：

```bash
sudo yum install git cmake gcc-c++ pkgconfig
```

## 📖 使用方法

### 1. 基本使用

```bash
# 给脚本添加执行权限
chmod +x build_tools.sh

# 查看帮助信息
./build_tools.sh --help

# 列出所有可用仓库
./build_tools.sh --list
```

### 2. 下载和编译

```bash
# 下载所有仓库
./build_tools.sh --download

# 编译所有仓库（会自动下载）
./build_tools.sh --build

# 下载并编译指定仓库
./build_tools.sh --build ZJPThreadLoop ZJPDnsParser

# 编译静态库
./build_tools.sh --build --static

# 编译动态库
./build_tools.sh --build --shared

# 编译所有类型（静态库+动态库）
./build_tools.sh --build --all
```

### 3. 高级选项

```bash
# 使用8个线程并行编译，Debug模式
./build_tools.sh --build --type Debug --jobs 8

# 清理构建目录后重新编译
./build_tools.sh --clean --build

# 编译并安装到系统
./build_tools.sh --build --install

# 构建示例程序
./build_tools.sh --build --examples

# 完整流程：清理、下载、编译、安装、构建示例
./build_tools.sh --clean --build --install --examples
```

### 4. 自定义安装路径

```bash
# 安装到自定义路径
./build_tools.sh --build --install --prefix /opt/myapp
```

## 🔧 添加新仓库

### 方法1: 修改配置文件

编辑 `config/repositories.conf` 文件：

```bash
# 添加新仓库
MyNewLib=https://github.com/username/MyNewLib.git
```

### 方法2: 修改脚本

编辑 `build_tools.sh` 文件中的 `REPOSITORIES` 数组：

```bash
declare -A REPOSITORIES=(
    ["ZJPThreadLoop"]="https://github.com/mo-xiaoxiu/ZJPThreadLoop.git"
    ["ZJPDnsParser"]="https://github.com/mo-xiaoxiu/ZJPDnsParser.git"
    ["MyNewLib"]="https://github.com/username/MyNewLib.git"  # 新添加的仓库
)
```

## 📋 已集成的库

### ZJPThreadLoop
- **功能**: 高性能线程池库，支持优先级任务队列
- **特性**: PIMPL设计模式，线程安全，支持单例模式
- **编译**: 支持静态库和动态库

### ZJPDnsParser  
- **功能**: DNS解析器库，支持同步和异步解析
- **特性**: 支持多种DNS记录类型，可配置DNS服务器
- **编译**: 支持静态库和动态库

## 📝 示例程序

系统提供了两个示例程序来测试集成效果：

### 1. ThreadLoop示例 (`threadloop_example`)

演示ThreadLoop库的基本用法：
- 线程池创建和配置
- 任务提交和优先级管理
- 并发任务处理
- 多种任务类型演示（简单任务、网络请求、批量计算）

### 2. DNS解析示例 (`dns_simple`)

演示DnsParser库的功能：
- 使用工厂函数创建解析器
- 同步DNS解析
- 获取IP地址结果
- 错误处理机制

## 🏃‍♂️ 运行示例

```bash
# 构建示例程序
./build_tools.sh --build --examples

# 运行示例程序
cd build/examples

# 运行ThreadLoop示例
./threadloop_example

# 运行DNS解析示例
./dns_simple
```

## 📊 测试结果

所有示例程序都已通过测试：

```bash
# 运行所有测试
cd build/examples
./threadloop_example
./dns_simple
```

测试结果：
- ✅ ThreadLoop测试：线程池工作正常，任务并发执行，支持多种任务类型
- ✅ DNS解析测试：成功解析域名，获取IP地址，错误处理正常

## 🔍 故障排除

### 常见问题

1. **依赖缺失**
   ```bash
   # 检查依赖
   ./build_tools.sh --help
   ```

2. **编译失败**
   ```bash
   # 清理后重新编译
   ./build_tools.sh --clean --build
   ```

3. **权限问题**
   ```bash
   # 确保脚本有执行权限
   chmod +x build_tools.sh
    ```

### 调试模式

```bash
# 启用详细输出
./build_tools.sh --build --verbose
```

## 📋 命令行选项

| 选项 | 长选项 | 描述 |
|------|--------|------|
| `-h` | `--help` | 显示帮助信息 |
| `-c` | `--clean` | 清理构建目录 |
| `-d` | `--download` | 只下载仓库 |
| `-b` | `--build` | 只编译仓库 |
| `-i` | `--install` | 安装到系统 |
| `-e` | `--examples` | 构建示例程序 |
| `-l` | `--list` | 列出所有可用仓库 |
| `-v` | `--verbose` | 详细输出 |
| `-t TYPE` | `--type TYPE` | 编译类型 (Debug/Release) |
| `-j N` | `--jobs N` | 并行编译线程数 |
| `-p PATH` | `--prefix PATH` | 安装路径 |
| `-s` | `--static` | 只编译静态库 |
| `-S` | `--shared` | 只编译动态库 |
| `-a` | `--all` | 编译所有类型 |

## 🤝 贡献

欢迎提交Issue和Pull Request！

### 开发指南

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 推送到分支
5. 创建Pull Request

## 📄 许可证

本项目采用MIT许可证。

## 📞 支持

如果您遇到问题或有建议，请：

1. 查看本文档的故障排除部分
2. 搜索现有的Issue
3. 创建新的Issue

---

**注意**: 确保您的系统满足所有依赖要求，并且有足够的磁盘空间用于下载和编译。

## 🚀 快速开始

```bash
# 1. 克隆或下载此项目
git clone <your-repo-url>
cd Tools

# 2. 给脚本添加执行权限
chmod +x build_tools.sh

# 3. 下载并编译所有库
./build_tools.sh --clean --build --all

# 4. 构建示例程序
./build_tools.sh --examples

# 5. 运行测试
cd build/examples
./threadloop_example
./dns_simple
```

## 📈 扩展性

系统设计具有良好的扩展性：

1. **添加新仓库**: 只需在配置文件中添加一行
2. **自定义编译选项**: 支持Debug/Release、静态/动态库
3. **并行构建**: 支持多线程编译加速
4. **示例程序**: 可以轻松添加新的测试程序

## 🎯 使用场景

- **开发环境搭建**: 快速构建开发环境
- **持续集成**: 自动化构建和测试
- **库管理**: 统一管理多个GitHub工具库
- **教学演示**: 展示库的集成和使用方法 