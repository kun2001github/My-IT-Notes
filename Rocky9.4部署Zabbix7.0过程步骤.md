# Rocky9.4部署Zabbix7.0过程步骤

## 环境确认

```
[root@localhost fonts]# cat /etc/os-release 
NAME="Rocky Linux"
VERSION="9.4 (Blue Onyx)"
ID="rocky"
ID_LIKE="rhel centos fedora"
VERSION_ID="9.4"
PLATFORM_ID="platform:el9"
PRETTY_NAME="Rocky Linux 9.4 (Blue Onyx)"
ANSI_COLOR="0;32"
LOGO="fedora-logo-icon"
CPE_NAME="cpe:/o:rocky:rocky:9::baseos"
HOME_URL="https://rockylinux.org/"
BUG_REPORT_URL="https://bugs.rockylinux.org/"
SUPPORT_END="2032-05-31"
ROCKY_SUPPORT_PRODUCT="Rocky-Linux-9"
ROCKY_SUPPORT_PRODUCT_VERSION="9.4"
REDHAT_SUPPORT_PRODUCT="Rocky Linux"
REDHAT_SUPPORT_PRODUCT_VERSION="9.4"
```

## 安装Rocky9.4

### 下载连接

https://rockylinux.org/zh-CN/download

![Clip_2024-10-24_17-41-43](C:\Users\MVGZ0040\AppData\Local\Programs\PixPin\Temp\Clip_2024-10-24_17-41-43.png)

### 安装Rocky9.4

安装VMware 然后穿件虚拟机安装就好了，省略。。。。

### 安装Zabbix7.0

#### 1.使用RPM安装对应版本的zabbix仓库

```
rpm -Uvh https://repo.zabbix.com/zabbix/7.0/rocky/9/x86_64/zabbix-release-7.0-2.el9.noarch.rpm
```

#### 2.安装Zabbix_Server,Web+agent

```
yum install zabbix-server-mysql zabbix-web-mysql zabbix-nginx-conf zabbix-sql-scripts zabbix-selinux-policy zabbix-agent -y
```

#### 3.安装数据库，初始化数据库

```
yum install -y mariadb mariadb-server

systemctl start mariadb

systemctl enable mariadb

mysql_secure_installation 
```

| 初始化选项：                                                 | 选择Y/n  |
| ------------------------------------------------------------ | -------- |
| Enter current password for root (enter for none):#：输入root的当前密码（输入表示无） | 直接回车 |
| Switch to unix_socket authentication [Y/n]#：切换到unix_socket身份验证[是/否] | y        |
| Change the root password? [Y/n]#：更改root密码？[是/否]      | y        |
| Remove anonymous users? [Y/n]#：删除匿名用户？[是/否]        | y        |
| Disallow root login remotely? [Y/n]#：不允许远程root登录？[是/否] | n        |
| Remove test database and access to it? [Y/n]#：删除测试数据库并访问它？[是/否] | y        |
| Reload privilege tables now? [Y/n]#：现在重新加载权限表吗？[是/否] | y        |

#### 4.登录数据库并导入初始架构和数据

登录数据库

```
mysql -uroot -p
```

导入前准备工作：先创建用户与数据库。

| create database zabbix character set utf8mb4 collate utf8mb4_bin; | 创建名为zabbix的数据库,并设置字符集为utf8mb4。 |
| ------------------------------------------------------------ | ---------------------------------------------- |
| create user zabbix@localhost identified by 'pwd123';         | 创建名为zabbix的用户，并设置其密码为pwd123。   |
| grant all privileges on zabbix.* to zabbix@localhost;        | 授予zabbix用户在zabbix数据库上的所有权限。     |

退出数据库

```
exit;
```

导入数据

```
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix 。
```

查看库大小

```
mysql -uroot -p

USE zabbix

SELECT table_schema AS "zabbix",
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.TABLES
GROUP BY table_schema;
```

#### 5.配置Zabbix和Nginx

Nginx配置

```
vim /etc/nginx/conf.d/zabbix.conf
```

![Nginx配置图片](images\Nginx配置图片.png)

Server配置

![zabbix-Server配置](images\zabbix-Server配置.png)

启动服务：Server、Nginx、Agents

```
systemctl start zabbix-server

systemctl start zabbix-agent

systemctl start nginx

systemctl start mariadb

####查看端口号
ss -lnt
```

![启动各个服务](images\启动各个服务.png)

#### 6. 安装中文语言包

如果没有安装的话，会选不了中文

```
#查看安装的中文语言包
localectl list-locales | grep zh

#安装中文语言包
yum install glibc-langpack-zh.x86_64

#如果需要设置系统默认语言为简体中文，可以使用如下命令设置，然后重启操作系统。
localectl set-locale LANG=zh_CN.utf8
```



#### 7.进入网页安装zabbix

访问页面：http://IP:8080，默认账密：Admin/zabbix



如果访问不了，可能是防火墙或者是selinux的问题

```
systemctl stop firewalld

setenforce 0

getenforce
```

 



#### 8.图形中文乱码解决

![zabbix图形中文乱码](images\zabbix图形中文乱码.png)

**1、替换字库文件（该方法最简单）**
**2、修改配置文件，指定字库文件**

**字库文件下载： [黑体字库](https://www.xxshell.com/download/sh/zabbix/ttf/msyh.ttf)   [楷体字库](https://www.xxshell.com/download/sh/zabbix/ttf/simkai.ttf)**

一、替换字库文件

```
cd /usr/share/zabbix/assets/fonts 
#切换到zabbix安装目录assets/fonts下，具体安装目录可能不一致，可以find / -name fonts

wget https://www.xxshell.com/download/sh/zabbix/ttf/msyh.ttf 
#下载字库文件

mv graphfont.ttf graphfont.ttf.bak
#备份默认字库文件

mv msyh.ttf graphfont.ttf
#替换字库文件

#替换完成刷新zabbix页面
```







参考链接：

[轻松上手 | RockyLinux 9.4安装及Zabbix 7.0部署教程详解](https://forum.lwops.cn/article/621)

[Zabbix之中文语言安装及配置_zabbix 中文语言包-CSDN博客](https://blog.csdn.net/carefree2005/article/details/114485268)

[Zabbix图形中文乱码问题（显示口口）解决办法_zabbix 图形乱码-CSDN博客](https://blog.csdn.net/jingxinguofeng/article/details/104695664)

复杂的：[如何在 Rocky Linux 9 上安装和配置 Zabbix 服务器和客户端](https://cn.linux-console.net/?p=30593)

