::解决中文乱码的
chcp 65001


::获取管理员权限
@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"


:: 设置bat标题
title  坤坤工具20240829

@echo off
setlocal

:: 重命名 .vscode 文件夹
rename "%USERPROFILE%\.vscode" ".vscode.bak"

:: 重命名 Code 文件夹
rename "%USERPROFILE%\AppData\Roaming\Code" "Code.bak"

echo 操作完成 && pause

endlocal