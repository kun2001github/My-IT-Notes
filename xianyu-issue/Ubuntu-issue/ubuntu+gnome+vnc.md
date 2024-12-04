## 实验环境是使用了docker ubuntu22.04.5

系统信息：

```
root@b3d85d76bf67:/# cat /etc/os-release           
PRETTY_NAME="Ubuntu 22.04.5 LTS"                   
NAME="Ubuntu"                                       
VERSION_ID="22.04"                                 
VERSION="22.04.5 LTS (Jammy Jellyfish)"             
VERSION_CODENAME=jammy                             
ID=ubuntu                                           
ID_LIKE=debian                                    
HOME_URL="https://www.ubuntu.com/"                 
SUPPORT_URL="https://help.ubuntu.com/"             
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/" 
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"  
```

安装docker

bash <(curl -sSL https://linuxmirrors.cn/docker.sh)



拉取镜像报错：

```
(base) [root@localhost ~]# docker pull ubuntu:22.04                       
Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp 31.13.96.195:443: i/o timeout (Client.Timeout exceeded wh
ile awaiting headers)                                                                         
(base) [root@localhost ~]# docker pull ubuntu:22.04                     
Error response from daemon: Get "https://registry-1.docker.io/v2/": dial tcp 31.13.96.195:443: i/o timeout      
```

解决方法：vim /etc/resolv.conf 注释原来的，新加一个nameserver 8.8.8.8 保存退出，重新拉取就解决了。



拉取镜像并启动

```
(base) [root@localhost ~]# docker pull ubuntu:22.04
(base) [root@localhost ~]# docker run -it --name demo -p 5901:5901 ubuntu:22.04 /bin/bash 
```



安装gnome桌面个相关的

```
root@b3d85d76bf67:/# apt update 
root@b3d85d76bf67:/# apt install ubuntu-gnome-desktop
跟apt install ubuntu-desktop一样的

不出意外需要你选择市区，6就是亚洲Asia，70就是上海shanghai
然后需要你选择键盘，19就是中国，32美国，1美国
```

`ubuntu-gnome-desktop` 是一个元包，它的目的是提供一个完整的 GNOME 桌面环境。当你安装这个包时，它会自动拉取并安装所有必要的 GNOME 组件，包括但不限于：

- `gnome-panel` - GNOME 面板，提供任务栏和系统托盘功能。
- `gnome-settings-daemon` - GNOME 设置守护进程，管理桌面环境的设置。
- `metacity` - GNOME 2.x 系列的窗口管理器，在 GNOME 3.x 中被 `mutter` 替代。
- `nautilus` - GNOME 的文件管理器。
- `gnome-terminal` - GNOME 的终端模拟器。
- `gnome-session` - GNOME 会话管理器，负责启动 GNOME 桌面环境。



安装xrdp和tightvncserver

```
root@b3d85d76bf67:~# apt install xrdp
root@b3d85d76bf67:~# apt install tightvncserver
root@b3d85d76bf67:~# apt install vim
apt install lightdm

选择lightdm
```

注意

```
root@b3d85d76bf67:~# systemctl                                                                                                        
System has not been booted with systemd as init system (PID 1). Can't operate.                                                        
Failed to connect to bus: Host is down

是没有systemctl这个使用的，需要使用service
```

启动

```
root@b3d85d76bf67:~# service xrdp start                                                                                               
 * Starting Remote Desktop Protocol server                                                                                            
xrdp-sesman[25734]: [INFO ] starting xrdp-sesman with pid 25734                [ OK ] 
```



配置文件

```
root@b3d85d76bf67:~# echo gnome-session > ~/.xsession 
```





 apt-get install dbus-x11

service dbus start 















```
root@b3d85d76bf67:~# exec gnome-session                                                                                               
                                                                                                                                      
** (process:9): WARNING **: 12:50:29.638: Could not make bus activated clients aware of XDG_CURRENT_DESKTOP=GNOME environment variable
: Cannot autolaunch D-Bus without X11 $DISPLAY                                                                                        
gnome-session-binary[9]: WARNING: Failed to upload environment to DBus: Cannot autolaunch D-Bus without X11 $DISPLAY                  
gnome-session-binary[9]: WARNING: Failed to upload environment to systemd: Cannot autolaunch D-Bus without X11 $DISPLAY               
gnome-session-binary[9]: WARNING: Failed to reset failed state of units: Cannot autolaunch D-Bus without X11 $DISPLAY                 
gnome-session-binary[9]: WARNING: Falling back to non-systemd startup procedure due to error: Cannot autolaunch D-Bus without X11 $DIS
PLAY                                                                                                                                  
gnome-session-binary[9]: WARNING: Could not make bus activated clients aware of QT_IM_MODULE=ibus environment variable: Cannot autolau
nch D-Bus without X11 $DISPLAY                                                                                                        
gnome-session-binary[9]: WARNING: Could not make bus activated clients aware of XMODIFIERS=@im=ibus environment variable: Cannot autol
aunch D-Bus without X11 $DISPLAY                                                                                                      
gnome-session-binary[9]: WARNING: Could not make bus activated clients aware of GNOME_DESKTOP_SESSION_ID=this-is-deprecated environmen
t variable: Cannot autolaunch D-Bus without X11 $DISPLAY                                                                              
gnome-session-binary[9]: WARNING: Could not make bus activated clients aware of XDG_MENU_PREFIX=gnome- environment variable: Cannot au
tolaunch D-Bus without X11 $DISPLAY                                                                                                   
gnome-session-binary[9]: ERROR: Failed to connect to system bus: Could not connect: No such file or directory                         
aborting... 
```







死活启动不了











其他

gnome-session-binary[571]: WARNING: Failed to upload environment to systemd: GDBus.Error:org.freedesktop.DBus.Error.NameHasNoOwner: Name "org.freedesktop.systemd1" does not exist gnome-session-binary[571]: WARNING: Failed to reset failed state of units: GDBus.Error:org.freedesktop.DBus.Error.NameHasNoOwner: Name "org.freedesktop.systemd1" does not exist gnome-session-binary[571]: WARNING: Falling back to non-systemd startup procedure due to error: GDBus.Error:org.freedesktop.DBus.Error.NameHasNoOwner: Name "org.freedesktop.systemd1" does not exist gnome-session-binary[571]: ERROR: Failed to connect to system bus: Could not connect: Connection refused aborting...



 System has not been booted with systemd as init system (PID 1). Can't operate.
    Failed to connect to bus: Host is down



```
(base) [root@localhost ~]# docker run -itd --name demo1 --privileged=true        -p5901:3389 ubuntu:22.04 /usr/sbin/init 
```

   创建完成后: 请使用以下命令进入容器

   docker exec -it myCentos **/bin/bash**

