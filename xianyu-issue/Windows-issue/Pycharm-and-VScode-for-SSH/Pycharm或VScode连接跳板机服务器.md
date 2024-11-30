# 说明

本教程适用于Pycharm和VScode使用

编写时间：2024.11.28

## 建议

对于pycharm来说，直接使用ssh的转发(隧道)功能实现（方便-推荐）如果是JumpServer堡垒机，推荐使用对应的教程

对于VScode来说，使用.ssh/config配置文件来实现（推荐）

## 可选

```
Host *
    ControlPersist yes
    ControlMaster auto
    ControlPath ~/.ssh/master-%r@%h:%p
```

```
解释：
Host *		#使用了*表示适用于所有的主机配置，如果需要指定可以在后面输入指定的IP地址
    ControlPersist yes   # ssh连接执行命令后不会马上关闭，会保持开放一段时间（对于频繁连接同一个服务器用户非常有用，因为会保留一段时间，从而你可以进行多次连接而无需重新进行身份验证）
    ControlMaster auto   # 启动自动一个控制主连接，可以长期存在的ssh连接，管理多个ssh会话，减少重复验证的过程
    ControlPath ~/.ssh/master-%r@%h:%p   # 控制主连接的本地套接字文件的路径	
    									%r是远程主机的用户名称	
    									%h是远程主机的主机名
										%p是远程主机的端口号
										这样，每个用户和主机组合都会有一个唯一的控制路径，避免了不同会话之间的冲突。
```

### 本地端口转发(隧道)：

```
ssh -f -N -L 本地端口号:内网服务器IP(目标服务器):内网服务器端口号(目标服务器端口号) 跳板机用户名@跳板机服务器IP


其他附带选项（可选）
-o TCPKeepAlive=yes
# 用于启用TCP层的保活功能。这个功能会定期发送保活消息来检查连接是否仍然有效，特别是在连接可能会因为网络问题或中间设备的超时设置而被关闭的情况下
-i /ptah/to/sshkey 
# 用于指定公钥的位置

例如：
目标服务器（堡垒机中的服务器）：192.168.0.100 端口号是：223
服务器的用户名：root
堡垒机（跳板机）：130.130.130.13 端口号是：600
堡垒机用户名：demo

要求：把本地端口888转发到目标服务器
sh -f -N -L 888:192.168.0.100:223 demo@130.130.130.13 -o TCPKeepAlive=yes
连接：
ssh -p 888 root@127.0.0.1
```

### 可以通过第三方软件实现一样的效果例如：xhell，Mobaxterm，tabby等等工具都可以用实现



### 通过配置文件config实现（理论pycharm也可以，试过有有问题）

**注意，Pycharm并不支持ProxyJumpe命令，必须使用ProxyCommand**

```
Host jump-server
    HostName 跳板机IP地址
    User user1
    Port 22
    ForwardAgent yes
    IdentityFile ~/.ssh/id_rsa
 
Host target-server
    HostName 目标服务器IP地址
    User user2
    Port 22
    ProxyJump jump-server
    # ProxyCommand ssh -W %h:%p jump-server
    IdentityFile ~/.ssh/id_rsa
```

```
ProxyJump 是 OpenSSH 7.3 引入的功能，语法更加简洁，推荐在较新版本的 OpenSSH 中使用

ForwardAgent yes  # 用于启用 SSH 代理转发（也称为 SSH 代理连接）。这个功能允许您在远程主机上使用本地机器上的 SSH 密钥进行认证，而不是在远程主机上保存密钥。
IdentityFile ~/.ssh/id_rsa   # 用于指定私钥的路径
```



## Pycharm连接堡垒机服务器 适用于JumpServer堡垒机的方法

[【V2/V3】JumpServer 如何通过 PyCharm 连接 - FIT2CLOUD 知识库](https://kb.fit2cloud.com/?p=d85d8229-151a-42f4-b746-b0e65ab097fa#heading-1)



### 官方文档

注意：**您不能在配置 SSH 解释器时使用 Windows 机器作为远程主机。**

[配置使用 SSH 的解释器 | PyCharm 文档 --- Configure an interpreter using SSH | PyCharm Documentation](https://www.jetbrains.com/help/pycharm/configuring-remote-interpreters-via-ssh.html#ssh)



### 跳板机

[跳板机技术ProxyJump 和 ProxyCommand-CSDN博客](https://blog.csdn.net/m0_49448331/article/details/143897010)

[利用 ProxyJump 来安全访问内网主机ProxyJump 是 SSH 配置中的选项，允许你通过中间服务器（也称为跳 - 掘金](https://juejin.cn/post/7426765897326002202)



#### 多跳板机跳转参考

[windows下pycharm配置跳板机和多个跳板机连接服务器，全流程（用于python debug） - 知乎](https://zhuanlan.zhihu.com/p/587084175)



#### 参考

#### [SSH隧道技术----端口转发，socket代理 - 登高行远 - 博客园](https://www.cnblogs.com/fbwfbi/p/3702896.html)

[pycharm+mobaxterm通过跳板机连接实验室服务器_mobaxterm 跳板机-CSDN博客](https://blog.csdn.net/qq_40636486/article/details/129843631)

[使用xshell 设置pycharm>跳板机>服务器的远程开发环境 - 阳光少年部落格](https://www.coder.rs/实用工具/设置pycharm>跳板机>服务器的远程开发环境/)

[Pycharm通过跳板机（堡垒机）连接内网服务器教程 - 知乎](https://zhuanlan.zhihu.com/p/661802126)





