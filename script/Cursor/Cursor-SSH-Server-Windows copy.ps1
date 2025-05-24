<#
.SYNOPSIS
    Automated Cursor Server installation for Windows clients
#>

# 获取Cursor版本信息
$cursorInfo = cursor --version
$CURSOR_VERSION = $cursorInfo[0]
$CURSOR_COMMIT = $cursorInfo[1]
$LOCAL_ARCH = $cursorInfo[2]
$REMOTE_ARCH = "x64" # or arm64
$REMOTE_OS = "linux"

# 设置远程服务器信息
$REMOTE_USER = "your_username"
$REMOTE_HOST = "your_server_ip"
$REMOTE_PORT = "22"
$REMOTE_NAME = "your_ssh_alias" # 可选

# 创建临时目录
$TMP_DIR = Join-Path $env:TEMP "cursor-install-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $TMP_DIR | Out-Null

# 下载文件
$CLI_URL = "https://cursor.blob.core.windows.net/remote-releases/${CURSOR_COMMIT}/cli-alpine-${REMOTE_ARCH}.tar.gz"
$VSCODE_URL = "https://cursor.blob.core.windows.net/remote-releases/${CURSOR_VERSION}-${CURSOR_COMMIT}/vscode-reh-${REMOTE_OS}-${REMOTE_ARCH}.tar.gz"

Write-Host "Downloading Cursor server packages..."
Invoke-WebRequest -Uri $CLI_URL -OutFile "$TMP_DIR\cursor-cli.tar.gz"
Invoke-WebRequest -Uri $VSCODE_URL -OutFile "$TMP_DIR\cursor-vscode-server.tar.gz"

# 传输到远程服务器
Write-Host "Uploading packages to remote server..."
if ($REMOTE_NAME) {
    scp -P $REMOTE_PORT "$TMP_DIR\cursor-cli.tar.gz" "${REMOTE_NAME}:.cursor-server/cursor-cli.tar.gz"
    scp -P $REMOTE_PORT "$TMP_DIR\cursor-vscode-server.tar.gz" "${REMOTE_NAME}:.cursor-server/cursor-vscode-server.tar.gz"
} else {
    scp -P $REMOTE_PORT "$TMP_DIR\cursor-cli.tar.gz" "${REMOTE_USER}@${REMOTE_HOST}:.cursor-server/cursor-cli.tar.gz"
    scp -P $REMOTE_PORT "$TMP_DIR\cursor-vscode-server.tar.gz" "${REMOTE_USER}@${REMOTE_HOST}:.cursor-server/cursor-vscode-server.tar.gz"
}

# 在远程服务器上执行安装
Write-Host "Installing on remote server..."
$installCommands = @"
mkdir -p ~/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/ && 
tar -xzf ~/.cursor-server/cursor-cli.tar.gz -C ~/.cursor-server/ && 
mv ~/.cursor-server/cursor ~/.cursor-server/cursor-${CURSOR_COMMIT} && 
tar -xzf ~/.cursor-server/cursor-vscode-server.tar.gz -C ~/.cursor-server/cli/servers/Stable-${CURSOR_COMMIT}/server/ --strip-components=1
"@

if ($REMOTE_NAME) {
    ssh $REMOTE_NAME $installCommands
} else {
    ssh -p $REMOTE_PORT "${REMOTE_USER}@${REMOTE_HOST}" $installCommands
}

# 清理临时文件
Remove-Item -Recurse -Force $TMP_DIR
Write-Host "Cursor server installation completed!"
