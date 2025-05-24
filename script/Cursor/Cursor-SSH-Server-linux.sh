#!/bin/bash

# 获取本地Cursor版本信息
export CURSOR_VERSION=$(cursor --version | sed -n '1p')
export CURSOR_COMMIT=$(cursor --version | sed -n '2p')
export LOCAL_ARCH=$(cursor --version | sed -n '3p')

#设置远程服务器的环境变量
export REMOTE_ARCH
export REMOTE_OS

# 设置远程服务器信息
# 交互式输入远程连接参数
read -p "请输入远程服务器用户名: " REMOTE_USER
read -p "请输入远程服务器IP地址: " REMOTE_HOST
read -p "请输入SSH端口号 (默认: 22): " REMOTE_PORT_INPUT

# 设置默认值
if [ -z "$REMOTE_PORT_INPUT" ]; then
    REMOTE_PORT="22"
else
    REMOTE_PORT="$REMOTE_PORT_INPUT"
fi

# 验证必填参数
if [ -z "$REMOTE_HOST" ]; then
    echo "错误: 远程服务器IP地址不能为空" >&2
    exit 1
fi

# 通过SSH获取远程服务器信息
REMOTE_ARCH="$(ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "uname -m")"
case "$REMOTE_ARCH" in
    "x86_64") REMOTE_ARCH="x64" ;;
    "aarch64") REMOTE_ARCH="arm64" ;;
    *) REMOTE_ARCH="x64" ;; # 默认x64
esac

REMOTE_OS="$(ssh -p $REMOTE_PORT $REMOTE_USER@$REMOTE_HOST "uname -s | tr '[:upper:]' '[:lower:]'")"


# 验证连接是否成功
if [ -z "$REMOTE_ARCH" ] || [ -z "$REMOTE_OS" ]; then
    echo "错误: 无法获取远程服务器信息，请检查SSH连接" >&2
    exit 1
fi

echo "检测到远程服务器架构: $REMOTE_ARCH"
echo "检测到远程操作系统: $REMOTE_OS"

# 下载文件到临时目录
TMP_DIR=$(mktemp -d)
CLI_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_COMMIT}/cli-alpine-${REMOTE_ARCH}.tar.gz"
VSCODE_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_VERSION}-${CURSOR_COMMIT}/vscode-reh-${REMOTE_OS}-${REMOTE_ARCH}.tar.gz"

echo "Downloading Cursor server packages..."
wget -O "${TMP_DIR}/cursor-cli.tar.gz" "${CLI_URL}" || curl -L "${CLI_URL}" -o "${TMP_DIR}/cursor-cli.tar.gz"
wget -O "${TMP_DIR}/cursor-vscode-server.tar.gz" "${VSCODE_URL}" || curl -L "${VSCODE_URL}" -o "${TMP_DIR}/cursor-vscode-server.tar.gz"

# 传输到远程服务器
echo "Uploading packages to remote server..."
scp -P ${REMOTE_PORT} "${TMP_DIR}/cursor-cli.tar.gz" "${REMOTE_USER}@${REMOTE_HOST}:.cursor-server/cursor-cli.tar.gz"
scp -P ${REMOTE_PORT} "${TMP_DIR}/cursor-vscode-server.tar.gz" "${REMOTE_USER}@${REMOTE_HOST}:.cursor-server/cursor-vscode-server.tar.gz"

# 在远程服务器上执行安装
echo "Installing on remote server..."
ssh -p ${REMOTE_PORT} "${REMOTE_USER}@${REMOTE_HOST}" "mkdir -p ~/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/ && \
                     tar -xzf ~/.cursor-server/cursor-cli.tar.gz -C ~/.cursor-server/ && \
                     mv ~/.cursor-server/cursor ~/.cursor-server/cursor-${CURSOR_COMMIT} && \
                     mkdir -p ~/.cursor-server/bin/${CURSOR_COMMIT}/ && \
                     tar -xzf ~/.cursor-server/cursor-vscode-server.tar.gz -C ~/.cursor-server/bin/${CURSOR_COMMIT}/ --strip-components=1"
echo "Cursor server installation completed!"


# 远程连接远程服务器看看是否安装成功
ssh -p ${REMOTE_PORT} "${REMOTE_USER}@${REMOTE_HOST}" "ls ~/.cursor-server"
ssh -p ${REMOTE_PORT} "${REMOTE_USER}@${REMOTE_HOST}" "ls ~/.cursor-server/bin/${CURSOR_COMMIT}"

# 提示用户手动启动
echo "Please start the Cursor server manually on the remote server."   
#提示是否需要清楚缓存
echo "Do you want to clear the cache?"
read -p "y/n: " CLEAR_CACHE
if [ "$CLEAR_CACHE" = "y" ]; then
    echo "Clearing cache..."
    rm -rf "$TMP_DIR"
fi