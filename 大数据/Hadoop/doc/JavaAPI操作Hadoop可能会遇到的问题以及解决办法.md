# Java API操作Hadoop可能会遇到的问题以及解决办法

## 1、Could not locate Hadoop executable: xxx\bin\winutils.exe

解决办法：
下载WINUTILS.EXE，并放到Hadoop的bin目录，下载地址：https://github.com/steveloughran/winutils

## 2、Caused by: java.io.FileNotFoundException: HADOOP_HOME and hadoop.home.dir are unset

**HADOOP_HOME and hadoop.home.dir are unset**。
解决方法：

- 首先下载hadoop的解压包，然后解压。[apache的所有包下载地址](http://archive.apache.org/dist/)
- 配置hadoop的环境变量，也就是在系统变量中增加HADOOP_HOME,同时在path配置%HADOOP_HOME%\bin
- 打开win的cmd窗口，输入hadoop查看是否配置成功
- 然后在调用发现还是错误依旧，**重启电脑**之后，这个问题解决，返回下一个异常**Could not locate Hadoop executable: E:\program\hadoop-2.9.1\bin\winutils.exe**本文第一个问题解决思路

------

这个异常直接[下载](https://github.com/srccodes/hadoop-common-2.2.0-bin/archive/master.zip)这个包，解压之后复制winutils.exe和winutils.pdb到%HADOOP_HOME%\bin下就可以了。
**本来以为会报版本冲突等，但是没有。但是下载的文件会多出一个，比如我要下载到本地的文件名是111.txt，那么会同时多一个.111.txt.crc**



![](https://i.loli.net/2019/11/29/3azs4huJiIjQEDV.png)



![](https://i.loli.net/2019/11/29/kyEa5HiO2vATLSX.png)



## 3、Permission denied: user=administrator, access=WRITE,inode=”/”:root:supergroup:drwxr-xr-x

这个问题的原因是当前运行系统用户跟HDFS上面的文件系统的用户/用户组不同，因此没有权限执行创建、删除等操作。
解决办法：
通过添加环境变量，人为设置当前用户为HDFS的启动用户：
变量名：HADOOP_USER_NAME，值：启动hadoop的用户（例如：root）