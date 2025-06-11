@echo off
chcp 65001
setlocal enabledelayedexpansion

@REM ==========================================
@REM :: VScode 小助手
@REM :: 作者：kun2001github
@REM :: 日期：2025.06.12
@REM :: 版本：2.0.1
@REM :: 说明：格式化vscode数据，安装vscode客户端，下载vscode server服务端

@REM :: ==========================================

::-------------------------------------------------------------------------------------------------------------------
::获取管理员权限;
@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"
::-------------------------------------------------------------------------------------------------------------------
:: 设置bat标题;
title  vscode-scrpit 2.0
@echo off
::-------------------------------------------------------------------------------------------------------------------
echo ###《欢 迎 使 用 vscode-scrpit 2.0》###
:input_list
echo.
echo ************【菜单】****************
echo ***1. 格式化Vscode数据***
echo ***2. 安装Vscode客户端***
echo ***3. 下载vscode server服务端***
echo *********【结束输入0】*************
echo.
set /p num=【请输入对应的数字】:
if %num%==0 goto end
if %num%==1 goto formatted_data
if %num%==2 goto installVscode
if %num%==3 goto Offline-service-download
echo 输入有误，请重新输入！
goto input_list
::-------------------------------------------------------------------------------------------------------------------
REM 结束脚本并删除自身;
:end
del "%~f0"
::-------------------------------------------------------------------------------------------------------------------
REM 关闭Code.exe 相关的进程并 重命名 .vscode 文件夹 以及重命名 Code 文件夹cmd;
:formatted_data
echo.
echo 正在关闭Code.exe 相关的进程...
taskkill /im explorer.exe /f
echo 正在重命名.vscode 文件夹 以及重命名 Code 文件夹...
if exist "%USERPROFILE%\.vscode.bak" echo 注意：.vscode 已被备份为.vscode.bak
if exist "%USERPROFILE%\AppData\Roaming\Code.bak" echo 注意：Code 已被备份为Code.bak
rename "%USERPROFILE%\.vscode" ".vscode.bak"
rename "%USERPROFILE%\AppData\Roaming\Code" "Code.bak"
start explorer.exe
echo 操作完成... && pause "按下回车键放返回【菜单】..."
goto input_list
::----------------------------------------------------------------------------------------------------------------------
:installVscode
set /p download-now=回复：y:最新版(默认) , n:1.85.2版本([Y]/N):
:: 判断是否下载1.85.2之前的版本;
if /i "%download-now%"=="y" goto installVscode-download-new
else goto installVscode-download-old


:installVscode-download-old
REM 下载v1.85.2的便携版（绿色版）解压安装打开;
curl -O "https://vscode.download.prss.microsoft.com/dbazure/download/stable/8b3775030ed1a69b13e4f4c628c612102e30a681/VSCode-win32-x64-1.85.2.zip"
echo https://update.code.visualstudio.com/1.85.2/win32-x64-archive/stable
mkdir VScode
tar -xf  VSCode-win32-x64-1.85.2.zip -C ".\Vscode"
del VSCode-win32-x64-1.85.2.zip
.\Vscode\Code.exe
echo 下载并启动完成... && pause "按下回车键放返回【菜单】..."
goto input_list

:installVscode-download-new
:: 调用edge浏览器打开网址;
echo 启动浏览器，请自行下载...
start msedge.exe  https://code.visualstudio.com/Download
goto input_list

::----------------------------------------------------------------------------------------------------------------------
REM 获取下载vscode server服务端的下载地址;
:Offline-service-download
REM 获取 VS Code 版本信息并提取 Commit ID;
echo 正在获取 VS Code 版本信息...
:: 启用延迟变量扩展;（必须，否则会出现%%a不该出现，以及会使用不了）;
setlocal enabledelayedexpansion
:: 检查 code 命令是否可用;
where code >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误：未找到 'code' 命令。请确保 VS Code 已安装并添加到系统 PATH。
    goto :ERROR
)
:: 获取 VS Code 版本信息;
set "LINE_COUNT=0"
set "COMMIT_ID="
set "VSCODE_VERSION="
set "VSCODE_BUILD="
:: 使用 code 命令获取版本信息;
for /f "tokens=*" %%a in ('code --version 2^>nul') do (
    set /a "LINE_COUNT+=1"
    if !LINE_COUNT! equ 1 (
        set "VSCODE_VERSION=%%a"
    ) else if !LINE_COUNT! equ 2 (
        set "COMMIT_ID=%%a"
    ) else if !LINE_COUNT! equ 3 (
        set "VSCODE_BUILD=%%a"
        goto :SHOW_INFO
    )
)

:SHOW_INFO
if not defined COMMIT_ID (
    echo 错误：无法获取 VS Code 版本信息
    goto :ERROR
)
echo VS Code 版本: !VSCODE_VERSION!
echo Commit ID: !COMMIT_ID!
echo Build 类型: !VSCODE_BUILD!
echo.

:: 输入服务器信息;
echo 请输入服务器用户名IP地址端口号，准备传输到服务器中...
set /p REMOTE_USER=请输入服务器的用户名(默认值：ubuntu): 
if not defined REMOTE_USER set "REMOTE_USER=ubuntu"
set /p REMOTE_HOST=请输入服务器的主机名默认IP(192.168.23.133): 
if not defined REMOTE_HOST set "REMOTE_HOST=192.168.23.133"
set /p REMOTE_PORT=请输入服务器的端口号(默认 22): 
if not defined REMOTE_PORT set "REMOTE_PORT=22"

:: 选择架构;
set "ARCH=x64"
set /p ARCH_CHOICE=服务器：是否使用 ARM64 架构？(回车默认是x86_64)(Y/[N]):
if /i "!ARCH_CHOICE!"=="Y" set "ARCH=arm64"
echo 当前选择的架构: !ARCH!
:: 版本比较和下载链接生成;
for /f "tokens=1-3 delims=." %%a in ("!VSCODE_VERSION!") do (
    set "VER_MAJOR=%%a"
    set "VER_MINOR=%%b"
    set "VER_PATCH=%%c"
)
:: 比较版本号并生成下载链接;
for /f "tokens=1-3 delims=." %%a in ("1.85.2") do (
    set "TARGET_MAJOR=%%a"
    set "TARGET_MINOR=%%b"
    set "TARGET_PATCH=%%c"
)
:: 比较版本号并设置 USE_OLD_URL 变量;
set "USE_OLD_URL=0"
if !VER_MAJOR! LSS !TARGET_MAJOR! set "USE_OLD_URL=1"
if !VER_MAJOR! EQU !TARGET_MAJOR! if !VER_MINOR! LSS !TARGET_MINOR! set "USE_OLD_URL=1"
if !VER_MAJOR! EQU !TARGET_MAJOR! if !VER_MINOR! EQU !TARGET_MINOR! if !VER_PATCH! LEQ !TARGET_PATCH! set "USE_OLD_URL=1"
:: 根据 USE_OLD_URL 变量选择下载链接;
if !USE_OLD_URL! EQU 1 (
    if "!ARCH!"=="x64" (
        echo 使用旧版下载链接（版本 ^<= 1.85.2） ： 架构为：%ARCH%
        goto :vscode-server-download-old
    ) else (
        echo 使用旧版下载链接（版本 ^<= 1.85.2） ： 架构为：%ARCH%
        goto :vscode-server-download-old
    )
) else (
    if "!ARCH!"=="x64" (
        echo 使用新版下载链接（版本 ^> 1.85.2）：： 架构为：%ARCH%
        goto :vscode-server-download-new
    ) else (
        echo 使用新版下载链接（版本 ^> 1.85.2）：： 架构为：%ARCH%
        goto :vscode-server-download-new
    )
)

:vscode-server-download-old
echo 正在获取VS Code Server的下载链接...
echo https://update.code.visualstudio.com/commit:!COMMIT_ID!/server-linux-!ARCH!/stable
echo 开始下载中...
curl -L "https://update.code.visualstudio.com/commit:%COMMIT_ID%/server-linux-%ARCH%/stable" -o "vscode-server-linux-%ARCH%.tar.gz"
echo 下载完成...
echo 正在创建必要文件中...
ssh "%REMOTE_USER%@%REMOTE_HOST%" -p "%REMOTE_PORT%" "mv /home/%REMOTE_USER%/.vscode-server /home/%REMOTE_USER%/.vscode-server.bak && mkdir -p ~/.vscode-server/bin/%COMMIT_ID%/"
echo 正在进行复制到服务器中...
scp -P %REMOTE_PORT% "vscode-server-linux-%ARCH%.tar.gz" "%REMOTE_USER%@%REMOTE_HOST%:/home/%REMOTE_USER%/.vscode-server/bin/%COMMIT_ID%/"
echo 正在解压到服务器中...
ssh "%REMOTE_USER%@%REMOTE_HOST%" -p "%REMOTE_PORT%" "cd .vscode-server/bin/%COMMIT_ID%/ && tar -xf vscode-server-linux-%ARCH%.tar.gz --strip-components=1"
echo 操作完成；请打开vscode重新连接...

:vscode-server-download-new
echo 正在获取VS Code Server的下载链接...
echo https://vscode.download.prss.microsoft.com/dbazure/download/stable/!COMMIT_ID!/vscode-server-linux-%ARCH%.tar.gz
echo 开始vscode server下载中...
curl -L "https://vscode.download.prss.microsoft.com/dbazure/download/stable/!COMMIT_ID!/vscode-server-linux-%ARCH%.tar.gz" -o "vscode-server-linux-%ARCH%.tar.gz"
echo https://vscode.download.prss.microsoft.com/dbazure/download/stable/!COMMIT_ID!/vscode_cli_alpine_%ARCH%_cli.tar.gz
echo 开始vscode cli下载中...
curl -L "https://vscode.download.prss.microsoft.com/dbazure/download/stable/!COMMIT_ID!/vscode_cli_alpine_%ARCH%_cli.tar.gz" -o "vscode_cli_alpine_%ARCH%_cli.tar.gz"
echo 正在创建必要文件中...
ssh "%REMOTE_USER%@%REMOTE_HOST%" -p "%REMOTE_PORT%" "mv /home/%REMOTE_USER%/.vscode-server /home/%REMOTE_USER%/.vscode-server.bak && mkdir -p ~/.vscode-server/cli/servers/Stable-%COMMIT_ID%/server/"
echo 正在进行复制到服务器中...
scp -P %REMOTE_PORT% "vscode-server-linux-%ARCH%.tar.gz" "%REMOTE_USER%@%REMOTE_HOST%:/home/%REMOTE_USER%/.vscode-server/cli/servers/Stable-%COMMIT_ID%/server/"
scp -P %REMOTE_PORT% "vscode_cli_alpine_%ARCH%_cli.tar.gz" "%REMOTE_USER%@%REMOTE_HOST%:/home/%REMOTE_USER%/.vscode-server/"
echo 正在解压到服务器中...
ssh "%REMOTE_USER%@%REMOTE_HOST%" -p "%REMOTE_PORT%" "cd /home/%REMOTE_USER%/.vscode-server/cli/servers/Stable-%COMMIT_ID%/server/ && tar -xf vscode-server-linux-%ARCH%.tar.gz --strip-components=1 && cd /home/%REMOTE_USER%/.vscode-server/ && tar -xf vscode_cli_alpine_%ARCH%_cli.tar.gz && mv code code-%COMMIT_ID%  && echo Stable-%COMMIT_ID% > /home/%REMOTE_USER%/.vscode-server/cli/iru.json "
echo 操作完成；请打开vscode重新连接...

pause "按下回车键放返回【菜单】..."
goto input_list