# 问题描述

在base环境中安装了某些包，或者是库，可能导致base的curl升级了，但是curl用的libmamba.so.2的版本不一样吧，高或者是低，就不清楚了，就是这个问题导致conda用不了，比如安装不了，等等，具体报错如下：

(base) [xurongjing@head01 ~]$ conda install orthofinder
Error while loading conda entry point: conda-libmamba-solver (/data/home/xurongjing/miniconda3/lib/python3.11/site-packages/libmambapy/../../../libmamba.so.2: undefined symbol: curl_url_cleanup)

CondaValueError: You have chosen a non-default solver backend (libsolv) but it was not recognized. Choose one of: classic



conda版本：

conda --version

conda 24.11.1



最后想到的解决方法是：通过升级conda来恢复base环境，因为这个是因为在base环境中升级/安装了某个包，导致的。（没想到成功了）

具体步骤：到清华源，下载最新的latest版本的conda，我这里下的是2024年10月份的最新latest，具体好像是：

(base）[xurongjing@head01 ]$./Miniconda3-latest-Linux-x86_64.sh -u
Welcome to Miniconda3 py312_24.9.2-0

In order to continue the installation process,please review the license agreement.
Please, press ENTER to continue