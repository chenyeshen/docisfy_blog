### 安装中文语音包

能显示中文的前提条件是：系统已经安装了中文语音包。

如果未安装，只需要联网后，执行

【sudo yum groupinstall chinese-support】命令即可安装，本文重点是如何配置才能显示中文。

### 编辑“.bashrc”文件

你可以选择编辑“/etc/sysconfig/i18n”文件，但是这个文件是作用于所有用户的，这里我们只修改成自己登录时显示中文。

在终端中输入命令【vim ~/.bashrc】来编辑“.bashrc”文件

### 添加“export LANG="zh_CN.UTF-8"

在最后添加“export LANG="zh_CN.UTF-8"”

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191024004524.png)



### 重启系统

用【 shutdown -r now】命令重启系统

重启后界面变成了中文的啦！

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191024004834.png)



