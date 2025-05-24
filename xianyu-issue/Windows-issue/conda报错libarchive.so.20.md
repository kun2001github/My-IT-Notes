版本：conda 24.9.2

问题：

Error whileloading conda entry point:conda-libmamba-solver（libarchive.so.20:cannot open shared object file:No such file or directory)



解决方法：

查找是否有：libarchive.so.20，如果有的话，就创建链接到/usr/lib和/usr/lib64里面即可解决

```
sudo find / -name "libarchive.so.*" 2>/dev/null

sudo ln -s libarchive.so.*的路径 /usr/lib

sudo ln -s libarchive.so.*的路径 /usr/lib64


```



参考：[【Conda报错】(libarchive.so.20: cannot open shared object file: No such file or directory)-CSDN博客](https://blog.csdn.net/qq_44246618/article/details/142928837)

[解决Error while loading conda entry point: conda-libmamba-solver (libarchive.so.19: cannot open shared-CSDN博客](https://blog.csdn.net/May_myz/article/details/134611233)

