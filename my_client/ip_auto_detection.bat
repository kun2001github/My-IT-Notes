@REM 作者：MVGZ0040
@REM 日期：2023-05-09
@REM 版本：1.0
@REM 用途：测试某个IP地址是否可达，如果不可达则播放指定的视频。
@REM 环境：Windows 11 家庭版
@REM 你可以根据需要修改IP地址和视频路径。
echo. 

@echo off
setlocal
REM 解决中文乱码的
chcp 65001
set IP=8.8.8.8
@REM set AUDIO="C:\Users\MVGZ0040\Videos\950d6b9380ab631f06296fde80189b00.mp4"  

REM 循环检查IP地址是否可达
:LOOP
ping -n 1 -w 1000 %IP% > nul
if errorlevel 1 (
    echo %IP% 不可达，正在播放视频...
    mshta "vbscript:createobject("sapi.spvoice").speak("警告：ping不通了！")(window.close)"
    @REM start "" %VIDEO%  
)
goto LOOP