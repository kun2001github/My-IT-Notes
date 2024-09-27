REM 要求：1，注册表键值复制到注册表另一个路径

REM      2，读取注册表值，值为路径，把文件复制到这个指定路径

REM 解决中文乱码的
chcp 65001
@echo off
setlocal

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请以管理员身份运行此脚本。
    exit /b
)

:: 读取的注册表路径
set "regKey=HKEY_CURRENT_USER\Software\Adobe\Photoshop\180.0"

:: 设置值名称和源文件路径
set "valueName=SettingsFilePath"

:: 复制的内容路径
set "sourceFile=C:\path\to\your\file.ext"

:: 读取路径值
for /f "tokens=2*" %%A in ('reg query "%regKey%" /v "%valueName%" 2^>nul') do set "targetPath=%%B"

:: 复制文件到指定路径
if exist "%targetPath%" (
    xcopy "%sourceFile%" "%targetPath%" /Y
) else (
    echo 目标路径不存在。
)

endlocal




