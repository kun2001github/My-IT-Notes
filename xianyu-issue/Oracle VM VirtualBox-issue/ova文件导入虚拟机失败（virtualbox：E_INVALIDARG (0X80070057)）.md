# 问题描述

在导入OVA格式的虚拟机时，报错，使用7zip检查过迁移过来的

virtualbox：E_INVALIDARG (0X80070057)

![image-20241219223917630](./images/ova文件导入虚拟机失败（virtualbox：E_INVALIDARG (0X80070057)）/image-20241219223917630.png)





解决方法：创建一个虚拟机，然后使用7zip解压这个ova文件，然后会发现有个xxx.vmdk这个就是虚拟机的磁盘主体，新创建的虚拟机使用这个虚拟机磁盘，就可以开机啦

更新详情，待更新