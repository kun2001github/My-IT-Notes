chcp 65001
@echo off
setlocal EnableDelayedExpansion

:: 获取所有已连接的网络适配器
for /f "tokens=2 delims=:" %%i in ('netsh interface show interface ^| findstr "已连接"') do (
    set "adapter=%%i"
    set "adapter=!adapter: =!"
    
    REM 关闭网络适配器
    netsh interface set interface "!adapter!" admin=disable
    echo 已关闭网络适配器: !adapter!
    
    REM 等待1秒
    timeout /t 1 /nobreak >nul
    
    REM 重新启动网络适配器
    netsh interface set interface "!adapter!" admin=enable
    echo 已重新启动网络适配器: !adapter!
)

echo 完成。
endlocal