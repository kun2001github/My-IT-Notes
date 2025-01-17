# 背景

在autodl购买的服务器无法直接访问到huggingface.co

通过在autodl中的服务器安装clash，让python可以访问huggingface.co下载模型



## 选择clash

[Elegycloud/clash-for-linux-backup: 基于Clash Core 制作的Clash For Linux备份仓库 A Clash For Linux Backup Warehouse Based on Clash Core](https://github.com/Elegycloud/clash-for-linux-backup)

其他的：（缺点是需要systemd，但是autodl中的服务器用的是容器吧，用的是service）

[nelvko/clash-for-linux-install: 😼 优雅地部署基于 Clash 的代理环境](https://github.com/nelvko/clash-for-linux-install)



## 具体步骤

```
#下载项目
 
#进入到项目目录，编辑.env文件，修改变量CLASH_URL的值。（你的订阅地址）
$ cd clash-for-linux
$ vim .env
```

