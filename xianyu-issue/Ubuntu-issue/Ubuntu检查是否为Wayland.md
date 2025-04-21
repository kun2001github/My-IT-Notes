# 背景

在Ubuntu默认情况下，桌面为Wayland，就会有概率导致如下2个情况：

1. 导致了Todesk，向日葵，远程不了，一直卡在了正在远程100%
2. 可能(有概率)导致在使用virtualbox虚拟机软件中的拖放失效



# 解决方案

## 一、命令行检测方法

### 1.查看会话类型变量

   ```
echo $XDG_SESSION_TYPE 
   ```

   - 若输出 `wayland`，则当前为Wayland；

   - 若输出 `x11`，则为X11

### 2.检查Wayland专用变量

```
echo $WAYLAND_DISPLAY 
```

- 若返回类似 `wayland-0` 的路径，表示使用Wayland；
- 若无输出，则可能为X11
### 3.通过系统日志工具查询（使用 `loginctl` 命令查看当前会话属性）

```
loginctl show-session $(loginctl | grep $(whoami) | awk '{print $1}') -p Type 
```

- 输出 `Type=wayland` 或 `Type=x11` 直接标明当前窗口系统

## 二、图形界面检测方法

### 1. 登录界面检查
   - 在Ubuntu登录界面，点击用户名后方的齿轮图标（⚙️），查看选项：
     - 若包含 `Ubuntu on Xorg` 或 `Ubuntu (Wayland)`，当前选择的即为窗口系统类型[1](https://blog.csdn.net/sunyuhua_keyboard/article/details/145007430)[2](https://blog.csdn.net/hua_chi/article/details/139961070)。
### 2. 系统设置验证
   - 打开「设置」→「关于」→「窗口系统」：
     - 若显示 `Wayland` 或 `X11`，则为当前使用的窗口系统（部分Ubuntu版本可能不显示此信息）。

## 三、修改命令

- 若主机为Ubuntu且使用Wayland窗口系统，可能(有概率)导致拖放失效。

- 修改 `/etc/gdm3/custom.conf` ，取消注释 `WaylandEnable=false` → 重启主机切换为X11

  - #### 1使用 sed 取消注释 WaylandEnable=false

    - ```
      sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/custom.conf
      ```

  - #### 2检查修改是否成功

    - ```
      grep "WaylandEnable" /etc/gdm3/custom.conf
      ```

  - #### 3重启主机以应用更用

    - ```
      sudo reboot
      ```

  - #### 4检查是否生效

    - ```
      echo $XDG_SESSION_TYPE
      ```

      

  



