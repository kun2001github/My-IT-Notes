# 背景

VMware卡顿，明明给了挺高的配置了，还是有点卡

## 通过配置（通用）提升

### 1.VMware配置

#### 1.1调整主机与虚拟机内存 `编辑 - 首选项 → 内存 - 调整所有虚拟机内存使其适应预留主机/内存调为本机的60%大小`

![img](./images/VMware Workstation卡顿问题(优化方案)/b5eb754eb6d21f4008e541892b817711.png)

#### 1.2调整进程优先级 `编辑 - 首选项 → 优先→级 → 抓取输入的内容：高 / 快照二者✔`

![在这里插入图片描述](./images/VMware Workstation卡顿问题(优化方案)/8d4cd19f6f5d1039724ab4d4b930a720.png)

### 2.虚拟机配置

#### 2.1设置处理器 `虚拟机 - 设置 - 硬件 - 处理器 - 处理器设置 - 虚拟化引擎✔`（如果用不上不要开，理论上有性能损耗）为什么，可以看评论：[Vmware Workstation 17 (Windows 11客户机)性能优化。 - 知乎](https://zhuanlan.zhihu.com/p/619395549)

![在这里插入图片描述](./images/VMware Workstation卡顿问题(优化方案)/a354f87db0b6e0d45f8c875f2d0beb70.png)

#### 2.2整理虚拟机 `虚拟机 - 设置 - 硬件 - 硬盘 - 碎片整理`

![在这里插入图片描述](./images/VMware Workstation卡顿问题(优化方案)/636a3cac6ad11423b7767529c6c3d962.png)

#### 2.3设置进程优先级 `虚拟机 - 设置 - 选项 - 高级 - 抓取的输入内容：高/禁用内存页面修整✔`

![20220314-15](./images/VMware Workstation卡顿问题(优化方案)/20220314-15.png)

### 3.其他

尽可能的移除用不到的对象，保留需要的对象。

移除对象：CD、声卡、打印机

保留对象：网络、硬盘、处理器、内存、USB、显示器

处理器设置：设置为本机的一半

### 4.显示器开启3D加速

加速3D图形：在“编辑虚拟机设置”->“硬件”中，勾选“加速3D图形”复选框，并根据需要调整图形内存大小

### 5.可选

安装VMware Tools可以提升虚拟机的性能和操作的便捷性，例如提升虚拟机的图形处理功能和使虚拟机与物理机之间的文件拷贝粘贴更方便

# 参考

[VMWare 卡顿优化详解_vmware虚拟机卡顿怎么解决-CSDN博客](https://blog.csdn.net/liferecords/article/details/123689770)

[优化 VMware 虚拟机性能，解决运行卡顿 - 小羿](https://xiaoyi.vc/vmware-optimization.html)

[vmware虚拟机运行速度卡慢原因分析及解决办法大全（一）_vmware虚拟机启动很慢-CSDN博客](https://blog.csdn.net/davidhzq/article/details/102461957)

[被中文翻译耽误的重要功能：VMWare 虚拟机优先级调整](https://www.weiran.ink/virtualization/vmware-workstation-accelerate-ui-response.html)
