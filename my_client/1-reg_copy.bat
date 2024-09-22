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

:: 源键值路径
set "sourceKey=HKEY_CURRENT_USER\Software\Adobe\Photoshop\180.0"

:: 设置值名称和源文件路径
set "valueName=SettingsFilePath"

:: 目标键值路径
set "destKey=HKEY_CURRENT_USER\Software\Adobe\Photoshop\190.0"

:: 读取值
for /f "tokens=1,2*" %%A in ('reg query "%sourceKey%" /v  "%valueName%" 2^>nul') do (
    set "valueName=%%A"
    set "valueType=%%B"
    set "valueData=%%C"
)
echo 值名称: %valueName%
echo 值类型: %valueType%
echo 值数据: %valueData%

:: 如果值存在，则复制到目标键
if defined valueData (
    reg add  "%destKey%" /v "%valueName%" /t "%valueType%" /d "%valueData%
) else (
    echo 值不存在。
)

endlocal

pause

@REM 读取注册表
@REM reg query "HKEY_CURRENT_USER\Software\Adobe\Photoshop\180.0" /v "SettingsFilePath"




