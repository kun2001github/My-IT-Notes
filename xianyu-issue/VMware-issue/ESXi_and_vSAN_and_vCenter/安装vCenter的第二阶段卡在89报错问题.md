# 问题背景

ESXi版本：8.0.0

客户端版本：2.10.1

具体问题是：在vCenter Server的时候，第一阶段没问题，第二阶段就卡在了89，然后就报错，报错如下

```
错误
遇到内部错误。 see /var/log/firstboot/vsphere_ui_firstboot_wait.py_10740_stderr.log
解决方案
这是一个不可恢复的错误，请重试安装。如果再次遇到此错误，请在 VMware 知识库中搜索这些症状，以了解任何已知问题和可能的解决方案。如果找不到任何内容，请收集支持包并提交支持请求。
```

根据提示中的错误，打开ESXi，并开启SSH的连接，连接到ESXi的控制台中，执行如下操作

```
root@localhost [ / ]# cat /var/log/firstboot/vsphere_ui_firstboot_wait.py_10740_stderr.log
Traceback (most recent call last):
  File "/usr/lib/vmware-vsphere-ui/firstboot/vsphere_ui_firstboot_wait.py", line 42, in main
    h5Fb.wait_to_start()
  File "/usr/lib/vmware-vsphere-ui/firstboot/vsphere_ui_firstboot_wait.py", line 104, in wait_to_start
    raise Exception('Timed out waiting for vsphere-ui to start')
Exception: Timed out waiting for vsphere-ui to start
2006-01-23T08:22:22.346Z  H5 firstboot wait failed


root@localhost [ / ]# time
```

可以得知ESXi的时间是不准确的，也就说因为这个时间的原因导致安装失败了。（安装的时候是配置与ESXI主机时间同步）

解决方法：就是在安装vCenter的时候，在配置时间同步的时候，使用NTP时间同步，以及配置ESXi主机的时间。

```
适配于ESXi8.0，其他版本应该也是可以的

设置esxi主机时间 例如：2024 年12月07日21:27:  
 						    	天    时    分    月     年
~ #  esxcli system time set -d 07 -H 21 -m 27 -M 12 -y 2024
获取当前系统时间：
~ # esxcli system time get

 
更改esxi主机主板上的时间：
~ # esxcli hardware clock set -d 07 -H 21 -m 27 -M 12 -y 2024

获取当前系统时间：
~ # esxcli system time get

获取当前硬件时间
[root@localhost:~] esxcli hardware clock get

修改后，要使重启服务器不失效，请参考：https://www.cnblogs.com/dh17/articles/13926579.html
```

启动ESXi8.0的NTP服务，实现使用NTP服务同步时间

待更新中



参考地址:

[用命令设置esxi主机时间 - da0h1 - 博客园](https://www.cnblogs.com/dh17/articles/13926370.html)

[ESXi8.0安装NTP服务实现时间同步 – 六安创世纪网络工程](https://www.hao0564.com/4408.html)