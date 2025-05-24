@echo off
chcp 65001
setlocal enabledelayedexpansion

:: ==========================================
:: SSH 免密登录自动配置脚本
:: 功能：检测服务器支持的密钥类型，生成以用户名命名的密钥并上传
:: ==========================================

:: 配置远程服务器信息;
echo 请输入远程服务器信息(用户名、IP地址、端口号)
set /p "REMOTE_USER=请输入远程用户名: ";
set /p "REMOTE_HOST=请输入远程服务器IP地址: ";
set /p "REMOTE_PORT=请输入SSH端口号 (默认22): ";
if "%REMOTE_PORT%"=="" set "REMOTE_PORT=22"
set "KEY_DIR=%USERPROFILE%\.ssh"
if not exist "%KEY_DIR%" mkdir "%KEY_DIR%"


::测试使用
@REM set REMOTE_USER=ubuntu
@REM set REMOTE_HOST=192.168.23.133
@REM set REMOTE_PORT=22


:: 验证必填参数;
if "%REMOTE_HOST%"=="" (
    echo 错误：远程服务器IP地址不能为空
    pause
    goto :eof
)
if "%REMOTE_USER%"=="" (
    echo 错误：远程用户名不能为空
    pause
    goto :eof
)

:: 检查 SSH 客户端是否存在;
where ssh >nul 2>nul
if errorlevel 1 (
    echo 错误：未找到 SSH 客户端。请安装 OpenSSH。
    pause
    goto :eof
)


:: 创建临时日志文件;
set "SSH_DEBUG_LOG=%KEY_DIR%\ssh_auth_check.txt"
echo 正在检测远程服务器 %REMOTE_HOST% 是否启用了公钥认证...
:: 使用 ssh -v (详细模式) 并尝试连接。我们主要关心认证阶段的输出。;
:: -o BatchMode=yes 避免交互式提示，例如密码输入。;
:: -o ConnectTimeout=10 设置连接超时。;
:: exit 命令使得连接在认证信息交换后尝试退出，我们不需要完整会话。;
@REM ssh -v -p %REMOTE_PORT% -o "BatchMode=yes" -o "ConnectTimeout=10" %REMOTE_USER%@%REMOTE_HOST% exit 2> "%KEY_DIR%\ssh_auth_check.txt" 
:: 使用更灵活的搜索模式，检测是否包含publickey或password;
for /f "tokens=*" %%a in ('findstr /i "authentications that can continue" "%SSH_DEBUG_LOG%"') do (
    set "auth_line=%%a"
    :: 检查是否支持publickey;
    echo !auth_line! | findstr /i "publickey" > nul
    if !errorlevel! equ 0 (
        echo √ 服务器支持公钥认证
    )else (
        echo 服务器未开启支持公钥认证
    )
    
    :: 检查是否支持password;
    echo !auth_line! | findstr /i "password" > nul
    if !errorlevel! equ 0 (
        echo √ 服务器支持密码认证 
    )else (
        echo 服务器未开启支持密码认证

    )
)


echo 正在检测远程服务器支持的密钥类型...
ssh -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST%  "ssh -Q key" > "%KEY_DIR%\server_keys.txt"
set "KEY_TYPE="
rem 定义密钥类型优先级（从高到低）;
set "PRIORITY=ed25519 rsa ecdsa dss" 
for /f "tokens=*" %%a in ('type "%KEY_DIR%\server_keys.txt%"') do (
    rem 遍历优先级列表;
    for %%t in (%PRIORITY%) do (  
        rem 检查是否已匹配;
        if not defined KEY_TYPE ( 
            rem 构建匹配模式（区分大小写，精确匹配密钥类型前缀）;
            if "%%a" == "ssh-%%t" (  
                set "KEY_TYPE=%%t"
            ) else if "%%a" == "sk-ssh-%%t@openssh.com" (  
                set "KEY_TYPE=%%t"
            )
        )
    )
    rem 已匹配时跳出循环;
    echo 检测到的密钥类型：!KEY_TYPE!
    if defined KEY_TYPE goto :END_LOOP 
)
:END_LOOP
if not defined KEY_TYPE (
    echo 未检测到支持的密钥类型。默认使用 rsa。
    set "KEY_TYPE=rsa"
)

set "KEY_FILE=%KEY_DIR%\id_!KEY_TYPE!_%REMOTE_USER%"
echo 正在生成 !KEY_TYPE! 密钥对（文件名：id_!KEY_TYPE!_%REMOTE_USER%）...

:: 检查密钥是否已存在;
if exist "!KEY_FILE!" (
    set /p "OVERWRITE=密钥文件已存在，是否覆盖？(y/n): "
    if /i not "!OVERWRITE!"=="y" (
        echo 操作已取消。
        pause
        goto :eof
    )
)

:: 根据密钥类型设置不同的参数;
if "!KEY_TYPE!"=="ed25519" (
    ssh-keygen -t !KEY_TYPE! -f "!KEY_FILE!" -N "" -q
) else (
    ssh-keygen -t !KEY_TYPE! -b 4096 -f "!KEY_FILE!" -N "" -q
)

if errorlevel 1 (
    echo 错误：密钥生成失败
    pause
    goto :cleanup
)

:: 上传公钥到服务器;
echo 正在上传公钥到服务器...

:: 方法一：使用 ssh-copy-id（如果可用）;
where ssh-copy-id >nul 2>nul
if not errorlevel 1 (
    echo 使用 ssh-copy-id 上传公钥...
    ssh-copy-id -i "!KEY_FILE!.pub" -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST%
    if not errorlevel 1 goto :verify
)

:: 方法二：手动上传;
echo 使用手动方式上传公钥...
echo 请输入 %REMOTE_USER%@%REMOTE_HOST% 的密码
type "!KEY_FILE!.pub" | ssh -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST% "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys"

if errorlevel 1 (
    echo 错误：公钥上传失败
    pause
    goto :cleanup
)

:verify
:: 验证免密登录是否成功;
echo 正在验证免密登录...
ssh -i "!KEY_FILE!" -o "StrictHostKeyChecking=no" -o "BatchMode=yes" -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST% "echo 免密登录成功！" 2>nul

if errorlevel 1 (
    echo 免密登录配置失败！请检查配置或手动验证。
    echo 您可以尝试手动连接：ssh -i "!KEY_FILE!" -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST%
) else (
    echo ========================================
    echo 免密登录配置成功！
    echo 私钥位置：!KEY_FILE!
    echo 公钥位置：!KEY_FILE!.pub
    echo 连接命令：ssh -i "!KEY_FILE!" -p %REMOTE_PORT% %REMOTE_USER%@%REMOTE_HOST%
    echo ========================================
)

:cleanup
:: 清理临时文件;
if exist "%KEY_DIR%\server_keys.txt" del "%KEY_DIR%\server_keys.txt" /q
if exist "%SSH_DEBUG_LOG%" del "%SSH_DEBUG_LOG%" /f /q
pause