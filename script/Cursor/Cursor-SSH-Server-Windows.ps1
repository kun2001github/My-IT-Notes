# 检查 Posh-SSH 模块是否已安装，如果未安装则提示安装
if (-not (Get-Module -ListAvailable -Name Posh-SSH)) {
    Write-Warning "Posh-SSH 模块未安装。请运行 'Install-Module Posh-SSH -Scope CurrentUser -Force' 进行安装，然后重新运行脚本。"
    exit 1
}
Import-Module Posh-SSH -ErrorAction SilentlyContinue

# 获取本地Cursor版本信息
$cursorPath = "cursor" # 默认在PATH中
if (-not (Get-Command $cursorPath -ErrorAction SilentlyContinue)) {
    $commonCursorPaths = @(
        "$env:LOCALAPPDATA\Programs\Cursor\cursor.exe",
        "$env:ProgramFiles\Cursor\cursor.exe",
        "$env:USERPROFILE\AppData\Local\Programs\Cursor\cursor.exe" # 新增可能的路径
    )
    foreach ($path in $commonCursorPaths) {
        if (Test-Path $path) {
            $cursorPath = $path
            Write-Host "找到 Cursor CLI 路径: $cursorPath"
            break
        }
    }
}

if (-not (Get-Command $cursorPath -ErrorAction SilentlyContinue)) {
    Write-Error "错误: 'cursor' 命令未找到。请确保 Cursor CLI 已正确安装并已添加到 PATH 环境变量，或者在脚本中指定的路径正确无误。"
    exit 1
}

Write-Host "正在执行: $cursorPath --version"
$cursorVersionOutput = & $cursorPath --version
if ($LASTEXITCODE -ne 0 -or !$cursorVersionOutput -or $cursorVersionOutput.Count -lt 3) {
    Write-Error "错误: 执行 '$cursorPath --version' 失败或输出格式不正确。请检查 Cursor CLI 是否正常工作。"
    Write-Host "Cursor CLI 输出:"
    $cursorVersionOutput | ForEach-Object { Write-Host $_ }
    exit 1
}

$env:CURSOR_VERSION = ($cursorVersionOutput | Select-Object -First 1).Trim()
$env:CURSOR_COMMIT = ($cursorVersionOutput | Select-Object -Index 1).Trim()
$env:LOCAL_ARCH = ($cursorVersionOutput | Select-Object -Index 2).Trim()

Write-Host "本地 Cursor 版本: $env:CURSOR_VERSION"
Write-Host "本地 Cursor Commit: $env:CURSOR_COMMIT"
Write-Host "本地架构: $env:LOCAL_ARCH"

# 检查关键环境变量是否在获取版本信息后就为空
if ([string]::IsNullOrWhiteSpace($env:CURSOR_VERSION) -or [string]::IsNullOrWhiteSpace($env:CURSOR_COMMIT) -or [string]::IsNullOrWhiteSpace($env:LOCAL_ARCH)) {
    Write-Error "错误: 从 'cursor --version' 获取到的一个或多个关键信息 (VERSION, COMMIT, ARCH) 为空。脚本无法继续。"
    exit 1
}

# 设置远程服务器信息
$REMOTE_USER = Read-Host "请输入远程服务器用户名"
$REMOTE_HOST = Read-Host "请输入远程服务器IP地址"
$REMOTE_PORT_INPUT = Read-Host "请输入SSH端口号 (默认: 22)"

if ([string]::IsNullOrWhiteSpace($REMOTE_PORT_INPUT)) {
    $REMOTE_PORT = 22
} else {
    if (-not ($REMOTE_PORT_INPUT -match '^\d+$')) { # 确保是纯数字
        Write-Error "错误: SSH端口号必须是有效的数字。"
        exit 1
    }
    $REMOTE_PORT = [int]$REMOTE_PORT_INPUT
}

if ([string]::IsNullOrWhiteSpace($REMOTE_HOST)) {
    Write-Error "错误: 远程服务器IP地址不能为空"
    exit 1
}
if ([string]::IsNullOrWhiteSpace($REMOTE_USER)) {
    Write-Error "错误: 远程服务器用户名不能为空"
    exit 1
}

# 获取一次凭据，后续重用
Write-Host "准备获取用户 '$REMOTE_USER' 连接到 '$REMOTE_HOST:$REMOTE_PORT' 的凭据..."
$credential = Get-Credential -UserName $REMOTE_USER -Message "请输入用户 '$REMOTE_USER' 连接到 '$REMOTE_HOST:$REMOTE_PORT' 的密码"
if (-not $credential) {
    Write-Error "错误: 未提供凭据。脚本已中止。"
    exit 1
}

# 通过SSH获取远程服务器信息
Write-Host "正在连接到远程服务器 ($($credential.UserName)@$REMOTE_HOST:$REMOTE_PORT) 以获取系统信息..."
$sshCommandArch = "uname -m"
$sshCommandOS = "uname -s | tr '[:upper:]' '[:lower:]'"

try {
    # 确保 Invoke-SshCommand 使用正确的 ComputerName
    $REMOTE_ARCH_RAW_OBJ = Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command $sshCommandArch -ErrorAction Stop
    $REMOTE_OS_RAW_OBJ = Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command $sshCommandOS -ErrorAction Stop

    $REMOTE_ARCH_RAW = $REMOTE_ARCH_RAW_OBJ.Output.Trim()
    $REMOTE_OS_RAW = $REMOTE_OS_RAW_OBJ.Output.Trim()

    if ([string]::IsNullOrWhiteSpace($REMOTE_ARCH_RAW)) {
        Write-Error "错误: 未能从远程服务器获取架构信息 (uname -m 返回为空)。"
        exit 1
    }
    if ([string]::IsNullOrWhiteSpace($REMOTE_OS_RAW)) {
        Write-Error "错误: 未能从远程服务器获取操作系统信息 (uname -s 返回为空)。"
        exit 1
    }

    $REMOTE_ARCH = switch ($REMOTE_ARCH_RAW) {
        "x86_64" { "x64" }
        "aarch64" { "arm64" }
        default { Write-Warning "未知的远程架构 '$REMOTE_ARCH_RAW'，将默认为 'x64'。"; "x64" } 
    }
    $env:REMOTE_ARCH = $REMOTE_ARCH
    $env:REMOTE_OS = $REMOTE_OS_RAW
} catch {
    Write-Error "错误: 无法获取远程服务器信息。请检查SSH连接、凭据 ($($credential.UserName)@$REMOTE_HOST:$REMOTE_PORT) 以及远程服务器上的 'uname' 命令是否可用。 PowerShell 错误: $($_.Exception.Message)"
    exit 1
}

Write-Host "检测到远程服务器架构: $env:REMOTE_ARCH"
Write-Host "检测到远程操作系统: $env:REMOTE_OS"

# 再次检查关键环境变量是否为空
if ([string]::IsNullOrWhiteSpace($env:CURSOR_COMMIT) -or [string]::IsNullOrWhiteSpace($env:REMOTE_ARCH) -or [string]::IsNullOrWhiteSpace($env:CURSOR_VERSION) -or [string]::IsNullOrWhiteSpace($env:REMOTE_OS)) {
    Write-Error "错误: 一个或多个必要的环境变量 (CURSOR_COMMIT, REMOTE_ARCH, CURSOR_VERSION, REMOTE_OS) 未能正确设置或在获取远程信息后变为空。无法继续下载。"
    exit 1
}

# 下载文件到临时目录
$TMP_DIR = Join-Path $env:TEMP "cursor-install-$($PID)-$(Get-Date -Format 'yyyyMMddHHmmss')"
New-Item -ItemType Directory -Path $TMP_DIR -Force | Out-Null
Write-Host "临时目录创建于: $TMP_DIR"

$CLI_URL = "https://cursor.blob.core.windows.net/remote-releases/$($env:CURSOR_COMMIT)/cli-alpine-$($env:REMOTE_ARCH).tar.gz"
$VSCODE_URL = "https://cursor.blob.core.windows.net/remote-releases/$($env:CURSOR_VERSION)-$($env:CURSOR_COMMIT)/vscode-reh-$($env:REMOTE_OS)-$($env:REMOTE_ARCH).tar.gz"

$cliTargetPath = Join-Path $TMP_DIR "cursor-cli.tar.gz"
$vscodeServerTargetPath = Join-Path $TMP_DIR "cursor-vscode-server.tar.gz"

Write-Host "正在下载 Cursor CLI from $CLI_URL ..."
Write-Host "正在下载 VSCode Server from $VSCODE_URL ..."

try {
    Invoke-WebRequest -Uri $CLI_URL -OutFile $cliTargetPath -ErrorAction Stop
    Write-Host "Cursor CLI 下载完成: $cliTargetPath"
    Invoke-WebRequest -Uri $VSCODE_URL -OutFile $vscodeServerTargetPath -ErrorAction Stop
    Write-Host "VSCode Server 下载完成: $vscodeServerTargetPath"
} catch {
    Write-Warning "Invoke-WebRequest 下载失败，尝试使用 Start-BitsTransfer... PowerShell 错误: $($_.Exception.Message)"
    try {
        Start-BitsTransfer -Source $CLI_URL -Destination $cliTargetPath -ErrorAction Stop
        Write-Host "Cursor CLI (BITS) 下载完成: $cliTargetPath"
        Start-BitsTransfer -Source $VSCODE_URL -Destination $vscodeServerTargetPath -ErrorAction Stop
        Write-Host "VSCode Server (BITS) 下载完成: $vscodeServerTargetPath"
    } catch {
        Write-Error "下载失败: $($_.Exception.Message)"
        Write-Host "请检查以下URL是否可以访问以及网络连接："
        Write-Host "CLI URL: $CLI_URL"
        Write-Host "VSCode Server URL: $VSCODE_URL"
        if (Test-Path $TMP_DIR) { Remove-Item -Path $TMP_DIR -Recurse -Force -ErrorAction SilentlyContinue }
        exit 1
    }
}

# 传输到远程服务器
Write-Host "正在上传文件包到远程服务器 $($credential.UserName)@$REMOTE_HOST:~/.cursor-server/ ..."
$remoteBaseDir = "~/.cursor-server"
$remoteCliPath = "$remoteBaseDir/cursor-cli.tar.gz"
$remoteVscodeServerPath = "$remoteBaseDir/cursor-vscode-server.tar.gz"

try {
    Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command "mkdir -p $remoteBaseDir" -ErrorAction Stop
    Copy-SshFile -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -LocalFile $cliTargetPath -RemoteFile $remoteCliPath -ErrorAction Stop
    Write-Host "CLI 文件上传成功。"
    Copy-SshFile -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -LocalFile $vscodeServerTargetPath -RemoteFile $remoteVscodeServerPath -ErrorAction Stop
    Write-Host "VSCode Server 文件上传成功。"
} catch {
    Write-Error "SCP 传输失败: $($_.Exception.Message)"
    if (Test-Path $TMP_DIR) { Remove-Item -Path $TMP_DIR -Recurse -Force -ErrorAction SilentlyContinue }
    exit 1
}

# 在远程服务器上执行安装
Write-Host "正在远程服务器上执行安装脚本..."
$installCommand = @"
mkdir -p ~/.cursor-server/cli/servers/Stable-$($env:CURSOR_COMMIT)/server/
tar -xzf $remoteCliPath -C $remoteBaseDir/
mv $remoteBaseDir/cursor $remoteBaseDir/cursor-$($env:CURSOR_COMMIT)
mkdir -p $remoteBaseDir/bin/$($env:CURSOR_COMMIT)/
tar -xzf $remoteVscodeServerPath -C $remoteBaseDir/bin/$($env:CURSOR_COMMIT)/ --strip-components=1
rm -f $remoteCliPath $remoteVscodeServerPath # 安装完成后删除远程的压缩包, 使用 -f 避免不存在文件时报错
"@

try {
    $installOutput = Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command $installCommand -ErrorAction Stop
    if ($installOutput.ExitStatus -ne 0) {
        Write-Error "远程安装命令执行失败。退出码: $($installOutput.ExitStatus)"
        Write-Host "远程服务器输出:"
        $installOutput.Output | ForEach-Object { Write-Host $_ }
        $installOutput.Error | ForEach-Object { Write-Error $_ }
    } else {
        Write-Host "远程安装命令执行成功。"
        $installOutput.Output | ForEach-Object { Write-Host $_ }
    }
} catch {
    Write-Error "远程安装失败: $($_.Exception.Message)"
    if (Test-Path $TMP_DIR) { Remove-Item -Path $TMP_DIR -Recurse -Force -ErrorAction SilentlyContinue }
    exit 1
}

# 远程连接远程服务器看看是否安装成功
Write-Host "验证安装 (列出远程目录内容)..."
$verifyCommand1 = "ls -la $remoteBaseDir"
$verifyCommand2 = "ls -la $remoteBaseDir/bin/$($env:CURSOR_COMMIT)"
try {
    Write-Host "$verifyCommand1 :"
    Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command $verifyCommand1 | ForEach-Object { $_.Output }
    Write-Host "$verifyCommand2 :"
    Invoke-SshCommand -ComputerName $REMOTE_HOST -Port $REMOTE_PORT -Credential $credential -Command $verifyCommand2 | ForEach-Object { $_.Output }
} catch {
    Write-Warning "验证命令执行失败: $($_.Exception.Message)"
}

Write-Host "Cursor server installation completed!"

Write-Host "Please start the Cursor server manually on the remote server using a command like: '$remoteBaseDir/cursor-$($env:CURSOR_COMMIT) server'"

$CLEAR_CACHE_INPUT = Read-Host "Do you want to clear the local temporary cache at '$TMP_DIR'? (y/n)"
if ($CLEAR_CACHE_INPUT -eq "y") {
    Write-Host "Clearing local temporary cache..."
    if (Test-Path $TMP_DIR) { Remove-Item -Path $TMP_DIR -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host "Local temporary cache cleared."
}
