rem::解决中文乱码的
chcp 65001

rem::获取管理员权限
@echo off
%1 mshta vbscript:CreateObject("Shell.Application").ShellExecute("cmd.exe","/c %~s0 ::","","runas",1)(window.close)&&exit
cd /d "%~dp0"


echo 清楚缓存数据...
rmdir /S /Q %TMP%
echo ******清除缓存数据完成******


echo 正在启动windows自带的磁盘清理...
rem::可增加/sagerun:1参数会自动执行
start C:\Windows\System32\cleanmgr.exe 


@REM echo 正在清空回收站...
@REM del /f /s /q C:\$Recycle.Bin\
@REM echo 回收站已清空。


echo 正在关闭系统休眠功能...
powercfg -h off
echo ******系统休眠功能已关闭，重启后生效******

echo 手动修改虚拟内存设置
systempropertiesadvanced

echo ******手动迁移微信以及QQ聊天记录******



echo 回车下载CCleaner& pause

rem:: 下载文件CCleaner-Pro-6.27.11214-x64-Plus.exe 并安装
echo 下载CCleaner并弹窗安装...
curl -O "https://116-142-255-134.pd1.cjjd19.com:30443/download-cdn.cjjd19.com/123-824/aa394069/1783234-0/aa3940699469b68de1853ce6b8b26738/c-m48?v=5&t=1725079766&s=17250797663160ac83462190ddd6f2c15e841008d8&r=P0XC22&bzc=2&bzs=313831373130333935313a35383131353138303a31363731303337313a31383137313033393531&filename=CCleaner-Pro-6.27.11214-x64-Plus.exe&x-mf-biz-cid=a1c6ddfd-c83a-43f4-aa31-996c79005dcc-c4937c&auto_redirect=0&cache_type=1&xmfcid=7df35939-3b6e-4782-9e65-8b96b3f8253a-0-50111d3b1"
rename c-m48 CCleaner-Pro-6.27.11214-x64-Plus.exe
CCleaner-Pro-6.27.11214-x64-Plus.exe

echo 回车下载WizTree磁盘空间分许工具& pause


rem::下载WizTree V4.19 并安装   （为什么选择他，应为他比 SpaceSniffer更加直观）
echo 正在下载WizTree V4.19 并安装...
curl -O "https://antibodysoftware-17031.kxcdn.com/files/20240729/wiztree_4_20_portable.zip" 
rem::备用连接，到123网盘的Windows/WinTree里面
rename wiztree_4_20_portable.zip WizTree.zip
mkdir WizTree
tar -xf WizTree.zip -C ".\WizTree"
del WizTree.zip
echo 下载WizTree V4.19 并安装完成。
status "" WizTree\WizTree64.exe



pause

