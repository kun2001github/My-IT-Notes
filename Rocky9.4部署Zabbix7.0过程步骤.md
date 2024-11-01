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

### 安装Rocky9.4

安装VMware 然后穿件虚拟机安装就好了，省略。。。。

```
yum update 
```



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
mysql -uroot -proot1122
```

导入前准备工作：先创建用户与数据库。

| create database zabbix character set utf8mb4 collate utf8mb4_bin; | 创建名为zabbix的数据库,并设置字符集为utf8mb4。   |
| ------------------------------------------------------------ | ------------------------------------------------ |
| create user zabbix@localhost identified by 'zabbix1122';     | 创建名为zabbix的用户，并设置其密码为zabbix1122。 |
| grant all privileges on zabbix.* to zabbix@localhost;        | 授予zabbix用户在zabbix数据库上的所有权限。       |

退出数据库

```
exit;
```

导入数据

```
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

#这里是输入设置的zabbix数据库的密码
也就是zabbix1122
```

查看库大小

```
mysql -uroot -proot1122

USE zabbix

SELECT table_schema AS "zabbix",
ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.TABLES
GROUP BY table_schema;

exit;
```

#### 5.配置Zabbix和Nginx

Nginx配置

```
vim /etc/nginx/conf.d/zabbix.conf
```

![Nginx配置图片](images\Nginx配置图片.png)

Server配置

```
vim /etc/zabbix/zabbix_server.conf
```

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



如果访问不了，可能是防火墙或者是selinux的问题(直接关闭，不安全，推荐)

```
systemctl stop firewalld

setenforce 0

getenforce
```



第一步是配置防火墙。 Rocky Linux 使用 Firewalld 防火墙。检查防火墙的状态。（有问题）

```sql
$ sudo firewall-cmd --state
running
```

防火墙适用于不同的区域，公共区域是我们将使用的默认区域。列出防火墙上所有活动的服务和端口。

```dos
$ sudo firewall-cmd --permanent --list-services
```

它应该显示以下输出。

```undefined
cockpit dhcpv6-client ssh
```

Zabbix 服务器需要开放端口 10050 和 10051 才能与代理连接。

```dos
$ sudo firewall-cmd --add-port={10051/tcp,10050/tcp} --permanent
```

允许 HTTP 和 HTTPS 端口。

```dos
$ sudo firewall-cmd --permanent --add-service=http
$ sudo firewall-cmd --permanent --add-service=https
```

重新检查防火墙的状态。

```dos
$ sudo firewall-cmd --permanent --list-all
```

您应该看到类似的输出。

```sql
public
  target: default
  icmp-block-inversion: no
  interfaces:
  sources:
  services: cockpit dhcpv6-client http https ssh
  ports: 10051/tcp 10050/tcp
  protocols:
  forward: yes
  masquerade: no
  forward-ports:
  source-ports:
  icmp-blocks:
  rich rules:
```

重新加载防火墙以启用更改。

```dos
$ sudo firewall-cmd --reload
```





## 第 2 步 - 将 SELinux 设置为宽容模式

<iframe id="aswift_8" name="aswift_8" browsingtopics="true" sandbox="allow-forms allow-popups allow-popups-to-escape-sandbox allow-same-origin allow-scripts allow-top-navigation-by-user-activation" width="918" height="0" frameborder="0" marginwidth="0" marginheight="0" vspace="0" hspace="0" allowtransparency="true" scrolling="no" allow="attribution-reporting; run-ad-auction" src="https://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-6366716774018597&amp;output=html&amp;h=280&amp;adk=1546778790&amp;adf=779416678&amp;w=918&amp;abgtt=6&amp;fwrn=4&amp;fwrnh=100&amp;lmt=1729828637&amp;num_ads=1&amp;rafmt=1&amp;armr=3&amp;sem=mc&amp;pwprc=1213353581&amp;ad_type=text_image&amp;format=918x280&amp;url=https%3A%2F%2Fcn.linux-console.net%2F%3Fp%3D30593&amp;fwr=0&amp;pra=3&amp;rh=200&amp;rw=918&amp;rpe=1&amp;resp_fmts=3&amp;wgl=1&amp;fa=27&amp;uach=WyJXaW5kb3dzIiwiMTkuMC4wIiwieDg2IiwiIiwiMTMwLjAuNjcyMy41OSIsbnVsbCwwLG51bGwsIjY0IixbWyJDaHJvbWl1bSIsIjEzMC4wLjY3MjMuNTkiXSxbIkdvb2dsZSBDaHJvbWUiLCIxMzAuMC42NzIzLjU5Il0sWyJOb3Q_QV9CcmFuZCIsIjk5LjAuMC4wIl1dLDBd&amp;dt=1729828637210&amp;bpp=2&amp;bdt=5210&amp;idt=2&amp;shv=r20241023&amp;mjsv=m202410220101&amp;ptt=9&amp;saldr=aa&amp;abxe=1&amp;cookie=ID%3Da90b141c7967f653%3AT%3D1729828636%3ART%3D1729828636%3AS%3DALNI_MaTLcvAIhSatGXhw0TdNp1rEUiXWA&amp;gpic=UID%3D00000f53a400dd1e%3AT%3D1729828636%3ART%3D1729828636%3AS%3DALNI_MY13FN1VUaiB0b2uDen4_f1bBKVpw&amp;eo_id_str=ID%3D5fb40194735c36bc%3AT%3D1729828636%3ART%3D1729828636%3AS%3DAA-AfjbguOnkWJEMrBSF6eWbxxeb&amp;prev_fmts=0x0%2C570x280%2C918x200%2C878x200%2C918x280&amp;nras=2&amp;correlator=8112868233246&amp;frm=20&amp;pv=1&amp;u_tz=480&amp;u_his=1&amp;u_h=1080&amp;u_w=1920&amp;u_ah=1032&amp;u_aw=1920&amp;u_cd=24&amp;u_sd=1&amp;dmc=8&amp;adx=127&amp;ady=3186&amp;biw=943&amp;bih=629&amp;scr_x=0&amp;scr_y=1308&amp;eid=44759875%2C44759926%2C31088261%2C95344187%2C95345271%2C95345281%2C31088343%2C95344979&amp;oid=2&amp;pvsid=4386778947479130&amp;tmod=1289034428&amp;uas=0&amp;nvt=1&amp;fc=1408&amp;brdim=39%2C44%2C39%2C44%2C1920%2C0%2C976%2C775%2C960%2C646&amp;vis=1&amp;rsz=%7C%7Cs%7C&amp;abl=NS&amp;fu=1152&amp;bc=31&amp;bz=1.02&amp;td=1&amp;tdf=0&amp;psd=W251bGwsbnVsbCxudWxsLDFd&amp;nt=1&amp;ifi=9&amp;uci=a!9&amp;btvi=3&amp;fsb=1&amp;dtd=33" data-google-container-id="a!9" tabindex="0" title="Advertisement" aria-label="Advertisement" data-google-query-id="CJ_x4uvRqIkDFZxjDwId5rE60g" data-load-complete="true" style="box-sizing: border-box; left: 0px; top: 0px; border: 0px; width: 918px; height: 0px;"></iframe>

配置 SELinux 以在宽容模式下工作。在此模式下，SELinux 不会阻止任何进程，但会将所有内容记录到审核日志文件中。稍后我们将使用它来设置 SELinux 规则。

```powershell
$ sudo setenforce 0 && sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
```

检查 SELinux 状态。

```dos
$ sestatus
SELinux status:                 enabled
SELinuxfs mount:                /sys/fs/selinux
SELinux root directory:         /etc/selinux
Loaded policy name:             targeted
Current mode:                   permissive
Mode from config file:          permissive
Policy MLS status:              enabled
Policy deny_unknown status:     allowed
Memory protection checking:     actual (secure)
Max kernel policy version:      33
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

