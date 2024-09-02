::解决中文乱码的
chcp 65001

::获取管理员权限
@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"

:: 设置bat标题
title  坤坤工具20240829
@echo off
::-------------------------------------------------------------------------------------------------------------------
:input_list
echo.
echo ************【菜单】****************
echo ***1. 格式化Vscode数据***
echo ***2. 安装Vscode1.85.2***
echo ******* **【结束输入0】*************
echo.
set /p num=【请输入对应的数字】:
if %num%==0 goto end
if %num%==1 goto formatted_data
if %num%==2 goto installVscode
echo 输入有误，请重新输入！
goto input_list
::-------------------------------------------------------------------------------------------------------------------
REM 关闭Code.exe 相关的进程并 重命名 .vscode 文件夹 以及重命名 Code 文件夹cmd
:formatted_data
echo.
taskkill /im vscode.exe /f
if exist "%USERPROFILE%\.vscode.bak" echo 注意：.vscode 已被备份为.vscode.bak
if exist "%USERPROFILE%\AppData\Roaming\Code.bak" echo 注意：Code 已被备份为Code.bak
rename "%USERPROFILE%\.vscode" ".vscode.bak"
rename "%USERPROFILE%\AppData\Roaming\Code" "Code.bak"
echo 操作完成... && pause "按下回车键放返回【菜单】..."
goto input_list
::----------------------------------------------------------------------------------------------------------------------
rem 下载v1.85.2的便携版（绿色版）解压安装打开
:installVscode
echo.
curl -O "https://vscode.download.prss.microsoft.com/dbazure/download/stable/8b3775030ed1a69b13e4f4c628c612102e30a681/VSCode-win32-x64-1.85.2.zip"
echo https://update.code.visualstudio.com/1.85.2/win32-x64-archive/stable
mkdir VScode
tar -xf  VSCode-win32-x64-1.85.2.zip -C ".\Vscode"
del VSCode-win32-x64-1.85.2.zip
.\Vscode\Code.exe
echo 下载并启动完成... && pause pause "按下回车键放返回【菜单】..."
goto input_list
::----------------------------------------------------------------------------------------------------------------------
rem 结束脚本并删除自身
:end
del "%~f0"