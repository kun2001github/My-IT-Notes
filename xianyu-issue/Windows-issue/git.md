git官方文档：[Git - Book (git-scm.com)](https://git-scm.com/book/zh/v2)

菜鸟教程：[https://www.runoob.com/git/git-tutorial.html](https://www.runoob.com/git/git-tutorial.html)

git安装教程:[Git - 安装 Git (git-scm.com)](https://git-scm.com/book/zh/v2/%E8%B5%B7%E6%AD%A5-%E5%AE%89%E8%A3%85-Git)

### 基础

Git 自带一个 `git config` 的工具来帮助设置控制 Git 外观和行为的配置变量。 这些变量存储在三个不同的位置：

1. `/etc/gitconfig` 文件: 包含系统上每一个用户及他们仓库的通用配置。 如果在执行 `git config` 时带上 `--system` 选项，那么它就会读写该文件中的配置变量。 （由于它是系统配置文件，因此你需要管理员或超级用户权限来修改它。）
2. `~/.gitconfig` 或 `~/.config/git/config` 文件：只针对当前用户。 你可以传递 `--global` 选项让 Git 读写此文件，这会对你系统上 **所有** 的仓库生效。
3. 当前使用仓库的 Git 目录中的 `config` 文件（即 `.git/config`）：针对该仓库。 你可以传递 `--local` 选项让 Git 强制读写此文件，虽然默认情况下用的就是它。 （当然，你需要进入某个 Git 仓库中才能让该选项生效。）

每一个级别会覆盖上一级别的配置，所以 `.git/config` 的配置变量会覆盖 `/etc/gitconfig` 中的配置变量。

在 Windows 系统中，Git 会查找 `$HOME` 目录下（一般情况下是 `C:\Users\$USER` ）的 `.gitconfig` 文件。 Git 同样也会寻找 `/etc/gitconfig` 文件，但只限于 MSys 的根目录下，即安装 Git 时所选的目标位置。 如果你在 Windows 上使用 Git 2.x 以后的版本，那么还有一个系统级的配置文件，Windows XP 上在 `C:\Documents and Settings\All Users\Application Data\Git\config` ，Windows Vista 及其以后的版本在 `C:\ProgramData\Git\config` 。此文件只能以管理员权限通过 `git config -f <file>` 来修改。

你可以通过以下命令查看所有的配置以及它们所在的文件：

```console
$ git config --list --show-origin
```

### 用户信息

安装完 Git 之后，要做的第一件事就是设置你的用户名和邮件地址。 这一点很重要，因为每一个 Git 提交都会使用这些信息，它们会写入到你的每一次提交中，不可更改：

```console
$ git config --global user.name "John Doe"
$ git config --global user.email johndoe@example.com
```

再次强调，如果使用了 `--global` 选项，那么该命令只需要运行一次，因为之后无论你在该系统上做任何事情， Git 都会使用那些信息。 当你想针对特定项目使用不同的用户名称与邮件地址时，可以在那个项目目录下运行没有 `--global` 选项的命令来配置。

很多 GUI 工具都会在第一次运行时帮助你配置这些信息。

### 检查配置信息

如果想要检查你的配置，可以使用 `git config --list` 命令来列出所有 Git 当时能找到的配置：

你可能会看到重复的变量名，因为 Git 会从不同的文件中读取同一个配置（例如：`/etc/gitconfig` 与 `~/.gitconfig`）。 这种情况下，Git 会使用它找到的每一个变量的最后一个配置。

你可以通过输入 `git config <key>`： 来检查 Git 的某一项配置：例如：git config user.name

由于 Git 会从多个文件中读取同一配置变量的不同值，因此你可能会在其中看到意料之外的值而不知道为什么。 此时，你可以查询 Git 中该变量的 **原始** 值，它会告诉你哪一个配置文件最后设置了该值：--show-origin

```console
$ git config --show-origin rerere.autoUpdate
file:/home/johndoe/.gitconfig	false

$ git config --show-origin user.name 
file:C:/Users/MVGZ0040/.gitconfig       kun2001github
```

### 获取仓库

通常有两种获取 Git 项目仓库的方式：

1. 将尚未进行版本控制的本地目录转换为 Git 仓库；
2. 从其它服务器 **克隆** 一个已存在的 Git 仓库。

```
初始化仓库
$git init

添加到暂存区
$ git add *.c
$ git add LICENSE

提交到仓库，注意需要加-m 否则默认是使用vim打开提交的信息的编辑
$ git commit -m 'initial project version'
```

执行git init 命令后，则会在当前文件夹创建.git目录，该目录包含了几乎所有的Git存储和操作的东西，具体目录结构如下（新版本可能有点差异，但是基本都差不多）

| config      | 包含项目特有的配置选项
| ----------- | ---------------------- | 
| description | 仅供GitWeb程序使用
| info | 一个全局性排除（global exclude）文件，用以放置那些不希望被记录在 `.gitignore` 文件中的忽略模式（ignored patterns） |
|hooks|包含客户端或者服务端的钩子脚本（hook scripts）
|以下是Git的核心组成部分|
|objects目录|存储所有数据内容
|refs目录|存储指定数据（分支、远程仓库和标签等）的提交对象的指针
|HEAD文件|指向目前被检出的分支
|index文件| 保存暂存区信息

### 克隆远程仓库

```
git clone <url>
例如：
$ git clone https://github.com/libgit2/libgit2

如果你想在克隆远程仓库的时候，自定义本地仓库的名字，你可以通过额外的参数指定新的目录名：
例如：
$ git clone https:://github.com/libgit2/libgit2 mylibgit
```

Git 支持多种数据传输协议。 上面的例子使用的是 `https://` 协议，不过你也可以使用 `git://` 协议或者使用 SSH 传输协议，比如 `user@server:path/to/repo.git`



