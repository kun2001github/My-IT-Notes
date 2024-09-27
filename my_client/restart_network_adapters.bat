@echo off
setlocal
REM 解决中文乱码的
chcp 65001

for /f "tokens=1,*" %%a in ('netsh interface show interface') do (
    echo 正在检查网卡：%%b
    echo 当前状态：%%a

    :: 检查网卡状态
    if "%%a"=="Connected" (
        echo 正在重启网卡：%%b
        netsh interface set interface name="%%b" admin=disable
        timeout /t 3 /nobreak >nul
        netsh interface set interface name="%%b" admin=enable
    )
)
echo 完成！
pause
