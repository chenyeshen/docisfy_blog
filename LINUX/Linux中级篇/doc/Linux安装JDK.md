# Linux安装JDK

### 1、检查一下系统中的jdk版本

```
[root@localhost software]# java -version
```

显示：

```
openjdk version "1.8.0_102"
OpenJDK Runtime Environment (build 1.8.0_102-b14)
OpenJDK 64-Bit Server VM (build 25.102-b14, mixed mode)
```

### 2、检测jdk安装包

```
[root@localhost software]# rpm -qa | grep java
```

显示：

```
java-1.7.0-openjdk-1.7.0.111-2.6.7.8.el7.x86_64
python-javapackages-3.4.1-11.el7.noarch
tzdata-java-2016g-2.el7.noarch
javapackages-tools-3.4.1-11.el7.noarch
java-1.8.0-openjdk-1.8.0.102-4.b14.el7.x86_64
java-1.8.0-openjdk-headless-1.8.0.102-4.b14.el7.x86_64
java-1.7.0-openjdk-headless-1.7.0.111-2.6.7.8.el7.x86_64
```

### 3、卸载openjdk

```
[root@localhost software]# rpm -e --nodeps tzdata-java-2016g-2.el7.noarch
[root@localhost software]# rpm -e --nodeps java-1.7.0-openjdk-1.7.0.111-2.6.7.8.el7.x86_64
[root@localhost software]# rpm -e --nodeps java-1.7.0-openjdk-headless-1.7.0.111-2.6.7.8.el7.x86_64
[root@localhost software]# rpm -e --nodeps java-1.8.0-openjdk-1.8.0.102-4.b14.el7.x86_64
[root@localhost software]# rpm -e --nodeps java-1.8.0-openjdk-headless-1.8.0.102-4.b14.el7.x86_64
```

或者使用

```
[root@localhost jvm]# yum remove *openjdk*
```

之后再次输入rpm -qa | grep java 查看卸载情况：

```
[root@localhost software]# rpm -qa | grep java
python-javapackages-3.4.1-11.el7.noarch
javapackages-tools-3.4.1-11.el7.noarch
```

### 4、安装新的jdk

首先到jdk官网上下载你想要的jdk版本，下载完成之后将需要安装的jdk安装包放到Linux系统指定的文件夹下，并且命令进入该文件夹下：

```
[root@localhost software]# ll
total 252664
-rw-r--r--. 1 root root  11830603 Jun  9 06:43 alibaba-rocketmq-3.2.6.tar.gz
-rw-r--r--. 1 root root  43399561 Jun  9 06:42 apache-activemq-5.11.1-bin.tar.gz
-rwxrw-rw-. 1 root root 185540433 Apr 21 09:06 jdk-8u131-linux-x64.tar.gz
-rw-r--r--. 1 root root   1547695 Jun  9 06:44 redis-3.2.9.tar.gz
-rw-r--r--. 1 root root  16402010 Jun  9 06:40 zookeeper-3.4.5.tar.gz
```

解压 jdk-8u131-linux-x64.tar.gz安装包

```
[root@localhost software]# mkdir -p /usr/lib/jvm
[root@localhost software]# tar -zxvf jdk-8u131-linux-x64.tar.gz -C /usr/lib/jvm
```

### 5、设置环境变量

```
[root@localhost software]# vim /etc/profile
```

在最前面添加：

```
export JAVA_HOME=/usr/local/jdk1.8.0_131
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$JAVA_HOME/bin:$PATH
```

### 6、执行profile文件

```
[root@localhost software]# source /etc/profile
```

这样可以使配置不用重启即可立即生效。

### 7、检查新安装的jdk

```
[root@localhost software]# java -version
```

显示：

```
java version "1.8.0_131"
Java(TM) SE Runtime Environment (build 1.8.0_131-b11)
Java HotSpot(TM) 64-Bit Server VM (build 25.131-b11, mixed mode)
```

到此为止，整个安装过程结束。

 

