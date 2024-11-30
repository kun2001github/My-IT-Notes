# 切换WSL的存储路径 释放C盘空间

## 1.准备工作

打开CMD，输入`wsl -l -v`查看wsl虚拟机的名称与状态。

输入 `wsl --shutdown` 使其停止运行，再次使用`wsl -l -v`确保其处于stopped状态。

## 2.**导出/恢复备份**

在D盘创建一个目录用来存放新的WSL，比如我创建了一个 `D:\Ubuntu_WSL` 。

①导出它的备份（比如命名为Ubuntu.tar)

```text
wsl --export Ubuntu-20.04 D:\Ubuntu_WSL\Ubuntu.tar
```

②确定在此目录下可以看见备份Ubuntu.tar文件之后，注销原有的wsl

```text
wsl --unregister Ubuntu-20.04
```

③将备份文件恢复到`D:\Ubuntu_WSL`中去

```text
wsl --import Ubuntu-20.04 D:\Ubuntu_WSL D:\Ubuntu_WSL\Ubuntu.tar
```

这时候启动WSL，发现好像已经恢复正常了，但是用户变成了root，之前使用过的文件也看不见了。

## 3.**恢复默认用户**

在CMD中，输入 `Linux发行版名称 config --default-user 原本用户名`

例如：

```bash
Ubuntu2004 config --default-user cham
```

请注意，这里的发行版名称的版本号是纯数字，比如Ubuntu-22.04就是Ubuntu2204。

这时候再次打开WSL，你会发现一切都恢复正常了。



参考链接：[轻松搬迁！教你如何将WSL从C盘迁移到其他盘区，释放存储空间！ - 知乎](https://zhuanlan.zhihu.com/p/621873601)



# WSL中使用NVIDIA CUDA

对于这些功能，需要 5.10.43.3 或更高版本的内核版本。 可以通过在 PowerShell 中运行以下命令来检查版本号。

PowerShell

```powershell
wsl cat /proc/version
```

[在 WSL 2 上启用 NVIDIA CUDA | Microsoft Learn](https://learn.microsoft.com/zh-cn/windows/ai/directml/gpu-cuda-in-wsl)