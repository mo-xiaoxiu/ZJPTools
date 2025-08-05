#!/bin/bash

# GitHub工具库批量构建脚本
# 支持批量下载、编译和集成

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/build"
INSTALL_DIR="${SCRIPT_DIR}/install"
REPOS_DIR="${SCRIPT_DIR}/repos"
EXAMPLES_DIR="${SCRIPT_DIR}/examples"

# 默认配置
DEFAULT_THREADS=4
DEFAULT_BUILD_TYPE="Release"
DEFAULT_INSTALL_PREFIX="/usr/local"

# 仓库配置
declare -A REPOSITORIES=(
    ["ZJPThreadLoop"]="https://github.com/mo-xiaoxiu/ZJPThreadLoop.git"
    ["ZJPDnsParser"]="https://github.com/mo-xiaoxiu/ZJPDnsParser.git"
    ["NMEAParse"]=https://github.com/mo-xiaoxiu/NMEAParse.git
)

# 编译配置
declare -A BUILD_CONFIGS=(
    ["ZJPThreadLoop"]="static,shared"
    ["ZJPDnsParser"]="static,shared"
)

# 显示帮助信息
show_help() {
    cat << EOF
GitHub Tools Library Batch Build Script

Usage: $0 [options] [repository names...]

Options:
    -h, --help              Show this help message
    -c, --clean             Clean build directory
    -d, --download          Download repositories only
    -b, --build             Build repositories only
    -i, --install           Install to system
    -t, --type TYPE         Build type (Debug/Release) [default: Release]
    -j, --jobs N            Parallel compilation threads [default: 4]
    -p, --prefix PATH       Installation path [default: /usr/local]
    -l, --list              List all available repositories
    -s, --static            Build static libraries only
    -S, --shared            Build shared libraries only
    -a, --all               Build all types (static + shared)
    -e, --examples          Build example programs
    -v, --verbose           Verbose output

Repository names:
    Specify repository names to process, or process all if not specified

Examples:
    $0 -b -t Release -j 8 ZJPThreadLoop ZJPDnsParser
    $0 -c -b -i -a -e
    $0 --list
EOF
}

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    local deps=("git" "cmake" "make" "g++")
    local missing_deps=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies and try again"
        exit 1
    fi
    
    log_success "Dependency check passed"
}

# 创建目录
create_directories() {
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$REPOS_DIR"
    mkdir -p "$EXAMPLES_DIR"
    log_info "Directory structure created"
}

# 清理构建目录
clean_build() {
    log_info "Cleaning build directory..."
    rm -rf "$BUILD_DIR"/
    rm -rf "$INSTALL_DIR"/
    log_success "Cleanup completed"
}

# 下载仓库
download_repo() {
    local repo_name="$1"
    local repo_url="${REPOSITORIES[$repo_name]}"
    local repo_dir="$REPOS_DIR/$repo_name"
    
    if [ -z "$repo_url" ]; then
        log_error "Unknown repository: $repo_name"
        return 1
    fi
    
    log_info "Downloading repository: $repo_name"
    
    if [ -d "$repo_dir" ]; then
        log_info "Repository exists, updating..."
        cd "$repo_dir"
        git fetch --all
        git reset --hard origin/main
    else
        log_info "Cloning repository: $repo_url"
        git clone "$repo_url" "$repo_dir"
    fi
    
    log_success "Repository $repo_name download completed"
}

# 编译仓库
build_repo() {
    local repo_name="$1"
    local build_type="$2"
    local jobs="$3"
    local build_config="$4"
    local repo_dir="$REPOS_DIR/$repo_name"
    local build_repo_dir="$BUILD_DIR/$repo_name"
    
    if [ ! -d "$repo_dir" ]; then
        log_error "Repository does not exist: $repo_name, please download first"
        return 1
    fi
    
    log_info "Building repository: $repo_name (type: $build_type, threads: $jobs)"
    
    # 创建构建目录
    mkdir -p "$build_repo_dir"
    cd "$build_repo_dir"
    
    # 配置CMake
    local cmake_options="-DCMAKE_BUILD_TYPE=$build_type"
    cmake_options="$cmake_options -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR"
    
    # 根据构建配置设置选项
    if [[ "$build_config" == *"static"* ]]; then
        cmake_options="$cmake_options -DBUILD_STATIC_LIBS=ON"
    fi
    if [[ "$build_config" == *"shared"* ]]; then
        cmake_options="$cmake_options -DBUILD_SHARED_LIBS=ON"
    fi
    
    # 运行CMake配置
    log_info "Configuring CMake: $cmake_options"
    cmake "$repo_dir" $cmake_options
    
    # 编译
    log_info "Starting compilation..."
    make -j"$jobs"
    
    # 安装
    log_info "Installing to: $INSTALL_DIR"
    make install
    
    log_success "Repository $repo_name build completed"
}

# 安装到系统
install_to_system() {
    local prefix="$1"
    
    log_info "Installing to system: $prefix"
    
    if [ ! -d "$INSTALL_DIR" ]; then
        log_error "Install directory does not exist, please build first"
        return 1
    fi
    
    # 创建目标目录
    sudo mkdir -p "$prefix"
    
    # 复制文件
    sudo cp -r "$INSTALL_DIR"/. "$prefix/"
    
    # 更新动态链接库缓存
    if command -v ldconfig &> /dev/null; then
        sudo ldconfig
    fi
    
    log_success "Installation to system completed"
}

# 构建示例程序
build_examples() {
    log_info "Building example programs..."
    
    local example_dir="$EXAMPLES_DIR"
    local build_example_dir="$BUILD_DIR/examples"
    
    mkdir -p "$build_example_dir"
    cd "$build_example_dir"
    
    # 配置CMake
    cmake "$example_dir" \
        -DCMAKE_BUILD_TYPE="$BUILD_TYPE" \
        -DCMAKE_PREFIX_PATH="$INSTALL_DIR"
    
    # 编译
    make -j"$JOBS"
    
    log_success "Example programs build completed"
}

# 列出所有仓库
list_repositories() {
    log_info "Available repositories:"
    for repo in "${!REPOSITORIES[@]}"; do
        echo "  - $repo: ${REPOSITORIES[$repo]}"
    done
}

# 主函数
main() {
    # 解析命令行参数
    local clean=false
    local download=false
    local build=false
    local install=false
    local examples=false
    local list_repos=false
    local verbose=false
    local build_type="$DEFAULT_BUILD_TYPE"
    local jobs="$DEFAULT_THREADS"
    local install_prefix="$DEFAULT_INSTALL_PREFIX"
    local build_config="static,shared"
    local target_repos=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--clean)
                clean=true
                shift
                ;;
            -d|--download)
                download=true
                shift
                ;;
            -b|--build)
                build=true
                shift
                ;;
            -i|--install)
                install=true
                shift
                ;;
            -e|--examples)
                examples=true
                shift
                ;;
            -l|--list)
                list_repos=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -t|--type)
                build_type="$2"
                shift 2
                ;;
            -j|--jobs)
                jobs="$2"
                shift 2
                ;;
            -p|--prefix)
                install_prefix="$2"
                shift 2
                ;;
            -s|--static)
                build_config="static"
                shift
                ;;
            -S|--shared)
                build_config="shared"
                shift
                ;;
            -a|--all)
                build_config="static,shared"
                shift
                ;;
            -*)
                log_error "未知选项: $1"
                show_help
                exit 1
                ;;
            *)
                target_repos+=("$1")
                shift
                ;;
        esac
    done
    
    # 设置详细输出
    if [ "$verbose" = true ]; then
        set -x
    fi
    
    # 检查依赖
    check_dependencies
    
    # 创建目录
    create_directories
    
    # 列出仓库
    if [ "$list_repos" = true ]; then
        list_repositories
        exit 0
    fi
    
    # 清理
    if [ "$clean" = true ]; then
        clean_build
    fi
    
    # 确定要处理的仓库
    local repos_to_process=()
    if [ ${#target_repos[@]} -eq 0 ]; then
        repos_to_process=("${!REPOSITORIES[@]}")
    else
        for repo in "${target_repos[@]}"; do
            if [[ -n "${REPOSITORIES[$repo]}" ]]; then
                repos_to_process+=("$repo")
            else
                log_warning "Skipping unknown repository: $repo"
            fi
        done
    fi
    
    # 下载仓库
    if [ "$download" = true ] || [ "$build" = true ]; then
        for repo in "${repos_to_process[@]}"; do
            download_repo "$repo"
        done
    fi
    
    # 编译仓库
    if [ "$build" = true ]; then
        for repo in "${repos_to_process[@]}"; do
            build_repo "$repo" "$build_type" "$jobs" "$build_config"
        done
    fi
    
    # 安装到系统
    if [ "$install" = true ]; then
        install_to_system "$install_prefix"
    fi
    
    # 构建示例程序
    if [ "$examples" = true ]; then
        build_examples
    fi
    
    log_success "All operations completed"
}

# 运行主函数
main "$@" 