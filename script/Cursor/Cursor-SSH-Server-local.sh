#!/bin/bash
###
 # @Author: kun2001github 1175553187@qq.com
 # @Date: 2025-05-19 23:52:54
 # @LastEditors: kun2001github 1175553187@qq.com
 # @LastEditTime: 2025-05-20 00:36:39
 # @FilePath: \My-IT-Notes\Cursor-SSH-Server-linux.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 

# 适用于 cursor 0.48.9 版本-0.50.5版本

# 确保脚本在出错时停止
# set -e
# 显示执行的命令
# set -x

# 交互式输入服务器版本和提交ID
read -p "请输入Cursor服务器版本 (例如: 2.0.0): " CURSOR_VERSION
read -p "请输入Cursor服务器提交ID (例如: abc123def456): " CURSOR_COMMIT
read -p "请输入架构类型 [x64/arm64] (默认x64): " REMOTE_ARCH_INPUT
read -p "请输入操作系统类型 [linux] (默认linux): " REMOTE_OS_INPUT

# 设置环境变量
export CURSOR_VERSION
export CURSOR_COMMIT
export REMOTE_ARCH="${REMOTE_ARCH_INPUT:-x64}" # or arm64
export REMOTE_OS="${REMOTE_OS_INPUT:-linux}"

# 验证输入
if [[ -z "$CURSOR_VERSION" || -z "$CURSOR_COMMIT" ]]; then
    echo "错误: 服务器版本和提交ID不能为空" >&2
    exit 1
fi

# 创建目录结构
mkdir -p "${HOME}/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/"

# 下载并解压第一个压缩包 (cli-alpine)
CLI_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_COMMIT}/cli-alpine-${REMOTE_ARCH}.tar.gz"
echo "正在下载CLI工具: $CLI_URL"
curl -L "$CLI_URL" -o "${HOME}/.cursor-server/cursor-cli.tar.gz"

echo "正在解压CLI工具..."
tar -xzf "${HOME}/.cursor-server/cursor-cli.tar.gz" -C "${HOME}/.cursor-server/"
mv "${HOME}/.cursor-server/cursor" "${HOME}/.cursor-server/cursor-$CURSOR_COMMIT"

# 下载并解压第二个压缩包 (vscode-reh)
VSCODE_URL="https://cursor.blob.core.windows.net/remote-releases/${CURSOR_VERSION}-${CURSOR_COMMIT}/vscode-reh-${REMOTE_OS}-${REMOTE_ARCH}.tar.gz"
echo "正在下载VSCode服务器: $VSCODE_URL"
curl -L "$VSCODE_URL" -o "${HOME}/.cursor-server/cursor-vscode-server.tar.gz"

echo "正在解压VSCode服务器..."
tar -xzf "${HOME}/.cursor-server/cursor-vscode-server.tar.gz" -C "${HOME}/.cursor-server/bin/${CURSOR_COMMIT}/" --strip-components=1

echo "Cursor服务器安装完成!"
echo "版本: $CURSOR_VERSION"
echo "提交ID: $CURSOR_COMMIT"
echo "安装路径: ${HOME}/.cursor-server"
ls ${HOME}/.cursor-server
ls ${HOME}/.cursor-server/bin/${CURSOR_COMMIT}
