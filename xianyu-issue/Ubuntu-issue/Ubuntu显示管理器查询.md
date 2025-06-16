# 定义

显示器管理（Display Manager）负责用户登录界面的管理和图形环境启动

# 一、Ubuntu的常见显示管理器

| 显示管理器  | 适用场景                      | 默认支持的 Ubuntu 版本      |
| ----------- | ----------------------------- | --------------------------- |
| **GDM3**    | GNOME 桌面环境（Ubuntu 默认） | Ubuntu 18.04+               |
| **LightDM** | 轻量级桌面（XFCE、LXDE 等）   | Ubuntu 12.04-17.10          |
| **SDDM**    | KDE 桌面环境（kubuntu）       | Ubuntu 14.04+（需手动安装） |
| **MDM**     | MATE 桌面环境                 | Ubuntu MATE 版本            |
| **SLiM**    | 极简显示管理器                | 需手动安装                  |

# 二、查询当前显示管理器的命令

以下命令适用于**所有 Ubuntu 版本（12.04 及以上）**：

#### **1. 通过 systemctl 命令（推荐）**

```bash
systemctl status display-manager
```

- 输出示例

  ```plaintext
  ● gdm3.service - GNOME Display Manager
     Loaded: loaded (/lib/systemd/system/gdm3.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-06-17 08:00:00 CST; 1h ago
  ```

  - 显示`gdm3` → GNOME 桌面使用的 GDM3
  - 显示`lightdm` → 轻量级桌面使用的 LightDM
  - 显示`mdm` → MATE 桌面使用的 MDM

#### **2. 通过环境变量查询**

```bash
echo $XDG_SESSION_MANAGER
```

- 输出示例

  ```plaintext
  /usr/bin/gnome-session-binary --session=ubuntu
  ```

  - 包含`gdm` → GDM3
  - 包含`lightdm` → LightDM

#### **3. 通过进程列表查询**

```bash
ps -ef | grep -i display
```

或直接检查特定显示管理器进程：

```bash
ps -ef | grep -i [g]dm3      # GDM3
ps -ef | grep -i [l]ightdm   # LightDM
ps -ef | grep -i [s]ddm      # SDDM
```

#### **4. 通过配置文件查询**

```bash
cat /etc/X11/default-display-manager
```

- 输出示例

  ```plaintext
  /usr/sbin/gdm3
  ```

### **三、不同 Ubuntu 版本的默认显示管理器**

| Ubuntu 版本   | 默认显示管理器 |
| ------------- | -------------- |
| **23.10**     | GDM3           |
| **22.04 LTS** | GDM3           |
| **20.04 LTS** | GDM3           |
| **18.04 LTS** | GDM3           |
| **16.04 LTS** | LightDM        |
| **14.04 LTS** | LightDM        |
| **12.04 LTS** | LightDM        |

### **四、切换显示管理器的方法**

若需更换显示管理器（例如从 GDM3 切换到 LightDM），可通过以下命令：

```bash
sudo apt install lightdm  # 安装LightDM
sudo dpkg-reconfigure lightdm  # 选择默认显示管理器
```

重启后生效。