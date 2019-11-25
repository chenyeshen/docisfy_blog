# Scala 安装

### Java 设置

确保你本地已经安装了 JDK 1.5 以上版本，并且设置了 JAVA_HOME 环境变量及 JDK 的 bin 目录。

我们可以使用以下命令查看是否安装了 Java：

```
$ java -version
java version "1.8.0_31"
Java(TM) SE Runtime Environment (build 1.8.0_31-b13)
Java HotSpot(TM) 64-Bit Server VM (build 25.31-b07, mixed mode)
$
```

接下来，我们可以从 Scala 官网地址 <http://www.scala-lang.org/downloads> 下载 Scala 二进制包。

### 解压缩文件包

```
tar -zxvf scala-2.12.10.tgz 
```

可将其移动至/usr/local/下：

```
mv scala-2.12.10 scala                   # 重命名 Scala 目录
mv /download/scalapath /usr/local/  # 下载目录需要按你实际的下载路径
```

### 修改环境变量

如果不是管理员可使用 sudo 进入管理员权限，修改配置文件profile:

```
vim /etc/profile

或

sudo vim /etc/profile
```

在文件的末尾加入:

```
export SCALA_HOME=/usr/local/scala
export PATH=$PATH:$SCALA_HOME/bin
```

![](https://i.loli.net/2019/11/25/h1pdtLQo7sqFYPV.png)



:wq!保存退出，

### 重启终端，执行 scala 命令

输出以下信息，表示安装成功：

```
$ scala
Welcome to Scala 2.12.10 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_231).
Type in expressions for evaluation. Or try :help.
scala> 
```

![](https://i.loli.net/2019/11/25/GvJKYZIq6rmWwj7.png)