## HBASE安装与配置

备注：

1：本文在hadoop的完全分布式基础上部署hbase

2：本文使用的是搭建的zookpeer服务，未使用hbase本身的zookpeer服务



```
本文内容在以下前提下进行配置：
1：master为s100,其他为regionserver（s1,s2,s3）
2：linux主机名需要修改
3：配置主机之间的解析名
例：vim /etc/hosts
master  192.168.1.1
slave_1 192.168.1.2
slave_2 192.168.1.3
4：所有主机之间的免密登陆
```



### 一：下载文件

地址：<http://www.apache.org/dyn/closer.lua/hbase/1.2.6/hbase-1.2.6-bin.tar.gz>

![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524105941987-110315283.png)

### 二：解压

将文件解压到/usr/local下面

```
[root@s100 ~]# tar -zxvf hbase-1.2.6-bin.tar.gz -C /usr/local/
```

为了后续操作，将hbase-1.2.6 改名为hbase

```
[root@s100 local]# pwd
/usr/local
[root@s100 local]# mv hbase-1.2.6 hbase
[root@s100 local]# ls
bin  games   hbase  hive.bak  java  lib64    sbin   src
etc  hadoop  hive   include   lib   libexec  share

```

###  三：配置hbase的环境变量

```
[root@s100 local]# vim /etc/profile
```

```
 #hbase
 export HBASE_HOME=/usr/local/hbase
 export PATH=$PATH:$HBASE_HOME/bin
```

更新环境变量

```
[root@s100 local]# source /etc/profile
```

### 四：配置hbase

编辑hbase-site.xml文件

```
[root@s100 conf]# pwd
/usr/local/hbase/conf
[root@s100 conf]# ls
hadoop-metrics2-hbase.properties  hbase-env.sh      hbase-site.xml    regionservers
hbase-env.cmd                     hbase-policy.xml  log4j.properties

```

配置内容如下：（Apache官方文档）

![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524112234374-1514350240.png)

 

 根据上面信息：

![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524112835344-138119528.png)



```
<configuration>
  <property>
    <name>hbase.rootdir</name>
    <value>hdfs://s100:8020/hbase</value>
  </property>
  <property>
    <name>hbase.cluster.distributed</name>
    <value>true</value>
  </property>
   <property>
       <name>dfs.replication</name>
       <value>3</value>
   </property>
  <property>
    <name>hbase.zookeeper.quorum</name><!-- 选用自己的zookpeer地址 --!>
    <value>s1:2181,s2:2181,s3:2181</value>
  </property>
</configuration>
```



 

备注：这里没有配置name:hbase.zookpeer.property.dataDir value:/home/centos/hbase/zk（hbase本身的zookpeer）

### 五：关闭hbase本身的zookpeer

在本文中，我们采用了自己的zookpeer，所以我们要关闭hbase本身zookpeer管理文件

修改hbase的evn.sh文件

```
[root@s100 conf]# vim hbase-env.sh 
export JAVA_HOME=/usr/local/java
export HBASE_MANAGES_ZK=false
```

 

### 六：配置区域服务器（regionserver）

```
[root@s100 conf]# cat regionservers 
s1
s2
s3
```

 

### 最后将hbase分发到s1,s2,s3上面，注意环境变量/etc/profile

将s100上的hbase拷贝到s1上

```
[root@s100 local]# pwd
/usr/local
[root@s100 local]# scp -r hbase root@s1:/usr/local/
```

 

将s100上的环境变量拷贝到s1上

```
[root@s100 local]# scp /etc/profile root@s1:/etc/profile
profile                                                  100% 2215     2.2KB/s   00:00 
```

 

s2和s3：重复上面步骤

### 启动hbase

启动zookpeer集群（zookpeer位于s1:s2:s3上，[zookpeer安装与配置](https://www.cnblogs.com/dxxblog/p/8664126.html)）

```
[root@s1 bin]# pwd
/usr/local/zookeeper/bin
[root@s1 bin]# ./zkServer.sh start
```

 启动hadoop的hdfs



```
[root@s100 local]# start-dfs.sh 
18/04/08 20:15:44 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Starting namenodes on [s100]
s100: starting namenode, logging to //usr/local/hadoop/logs/hadoop-root-namenode-s100.out
s1: starting datanode, logging to //usr/local/hadoop/logs/hadoop-root-datanode-s1.out
s3: starting datanode, logging to //usr/local/hadoop/logs/hadoop-root-datanode-s3.out
s2: starting datanode, logging to //usr/local/hadoop/logs/hadoop-root-datanode-s2.out
Starting secondary namenodes [s10]
s10: ssh: connect to host s10 port 22: No route to host
18/04/08 20:16:42 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
```



 启动hbase



```
[root@s100 logs]# start-hbase.sh 
starting master, logging to /usr/local/hbase/logs/hbase-root-master-s100.out
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
s2: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-s2.out
s2: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
s2: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
s3: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-s3.out
s1: starting regionserver, logging to /usr/local/hbase/bin/../logs/hbase-root-regionserver-s1.out
s3: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
s3: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
s1: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option PermSize=128m; support was removed in 8.0
s1: Java HotSpot(TM) 64-Bit Server VM warning: ignoring option MaxPermSize=128m; support was removed in 8.0
```



 hbase对应进程名称：

s100（master）：HMaster

s1,s2,s3：HRegionServer



```
[root@s1 bin]# jps
29605 DataNode               　 hdfs的数据节点进程
20904 QuorumPeerMain     　　　　zookpeer进程       
29833 Jps
29801 HRegionServer        　　 hbase的regionserver进程
[root@s100 ~]# jps
53574 Jps
52938 NameNode              　　 hdfs的名称节点进程
53357 HMaster                   　　　hbase的master节点进程     
```



 

------

 

web的ui界面 ：

s100:16010

![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524150918489-1482323491.png)

master为s100

regionserver服务器s1,s2,s3都存在

hbase配置成功

备注：如果regionserver不存在或者不完全存在（如果没有s1），大多数情况下是linux服务器的时间不一样导致的。

如果在s1上启动s1为master服务器：



```
[root@s1 bin]# hbase-daemon.sh start master
starting master, logging to /usr/local/hbase/logs/hbase-root-master-s1.out
[root@s1 bin]# jps
29605 DataNode
30533 HMaster
30311 HRegionServer
20904 QuorumPeerMain
30687 Jps
```

 

s1：存在Hmaster和Hregionserver

此时的web ui界面：

![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524151812596-1485891158.png)

s1在backup master上存在，s1成为备份节点

在zookpeer中查询hbase：

```
[root@s100 bin]# ./zkCli.sh
```

```
WatchedEvent state:SyncConnected type:None path:null

[zk: localhost:2181(CONNECTED) 0] ls /
[zookeeper, hbase]
```

 

 既然zookpeer存在，也就说明hbase实现了容灾过程

所以，如果s100挂掉，那么s1作为backup-master会成为master服务器



```
[root@s100 local]# jps
52938 NameNode
54522 HMaster
54894 Jps
[root@s100 local]# kill 54522
[root@s100 local]# jps
55014 Jps
52938 NameNode
```



![img](https://images2018.cnblogs.com/blog/1293848/201805/1293848-20180524153043071-1191546149.png)

master成为s1，并且无备份的master服务器

剩下的就不一一细讲了，本篇文章就到这里呢O(∩_∩)O~