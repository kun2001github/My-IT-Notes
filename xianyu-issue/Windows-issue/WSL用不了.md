# 问题描述

Win10，死活使用不了WSL，但是明明已经在bios中启动了虚拟化，系统里里面也安装了windows功能里面也启动了"适用于Linux的Windows子系统"，"Windows虚拟机监控程序平台","Hyper-v"都开起来，以及cmd的bcdedit检查了是否开启了虚拟化，是auto就是开启了。

```
开启：bcdedit /set hypervisorlaunchtype auto 然后重启
关闭：bcdedit /set hypervisorlaunchtype off 然后重启
```





# 解决方法

重启电脑，进入bios把虚拟化关闭并重开即可解决