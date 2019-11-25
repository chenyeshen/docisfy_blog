# Spark的安装及配置（单机版）

## 1)用到的软件

```
**hadoop-3.2**

**jdk 1.8**

**scala-2.12.10**

**spark-3.0.0-preview-bin-hadoop3.2**
```

## 2) 安装Spark

### 2.1 解压到安装目录

```
tar -zxvf spark-3.0.0-preview-bin-hadoop3.2.tgz 
```

### 2.2 修改配置文件

配置文件位于`/usr/local/spark-3.0.0-preview-bin-hadoop3.2/conf`目录下。

#### (1) spark-env.sh

将`spark-env.sh.template`重命名为`spark-env.sh`。
添加如下内容：

```
export SCALA_HOME=/usr/local/scala
export JAVA_HOME=/usr/local/jdk1.8
export HADOOP_HOME=/usr/local/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
SPARK_MASTER_IP=Master
SPARK_LOCAL_DIRS=/usr/local/spark-3.0.0-preview-bin-hadoop3.2
SPARK_DRIVER_MEMORY=512M

```

#### (2)slaves

将`slaves.template`重命名为`slaves`
修改为如下内容：

```
Slave01
Slave02

```

### 2.3 配置环境变量

在`~/.bashrc`文件中添加如下内容，并执行`$ source ~/.bashrc`命令使其生效

```
export SPARK_HOME=/usr/local/spark-3.0.0-preview-bin-hadoop3.2
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin

```

## 3)运行Spark

##### 先启动hadoop

```
$ cd $HADOOP_HOME/sbin/
$ ./start-dfs.sh
$ ./start-yarn.sh
$ ./start-history-server.sh

```

##### 然后启动启动sapark

```
$ cd $SPARK_HOME/sbin/
$ ./start-all.sh
$ ./start-history-server.sh

```

**要注意的是：其实我们已经配置的环境变量，所以执行start-dfs.sh和start-yarn.sh可以不切换到当前目录下，但是start-all.sh、stop-all.sh和/start-history-server.sh这几个命令hadoop目录下和spark目录下都同时存在，所以为了避免错误，最好切换到绝对路径下。**



## 4)开放防火墙8080端口

```

firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

```



## 5)spark启动成功

可以在浏览器中查看相关资源情况：http://192.168.150.130:8080，这里`192.168.150.130`是`Master`节点的



![](https://i.loli.net/2019/11/25/qwoPyc8FWLOMad1.png)

