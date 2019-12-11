# Zookeeper+Kafka集群搭建

## Zookeeper集群搭建

Kafka集群是把状态保存在Zookeeper中的，首先要搭建Zookeeper集群。

#### **1、软件环境**

（3台服务器-我的测试）
192.168.30.204 server1
192.168.30.205 server2
192.168.30.206 server3
1-1、Linux服务器一台、三台、五台、（2*n+1），Zookeeper集群的工作是超过半数才能对外提供服务，3台中超过两台超过半数，允许1台挂掉 ，是否可以用偶数，其实没必要。
如果有四台那么挂掉一台还剩下三台服务器，如果在挂掉一个就不行了，这里记住是超过半数。
1-2、zookeeper是用java写的所以他的需要JAVA环境，java是运行在java虚拟机上的
1-3、Zookeeper的稳定版本Zookeeper 3.4.6版本

#### **2、配置&安装Zookeeper**

下面的操作是：3台服务器统一操作

##### 2-1、安装Java

(可选) 卸载已有的open jdk，安装最新版本的java jdk

```
# rpm -qa | grep jdk
       java-1.6.0-openjdk-1.6.0.0-1.45.1.11.1.el6.i686
# yum -y remove java-1.6.0-openjdk-1.6.0.0-1.45.1.11.1.el6.i686
       remove java-1.6.0-openjdk-1.6.0.0-1.45.1.11.1.el6.i686

```

安装JAVA， 请见 <http://qiangsh.blog.51cto.com/3510397/1771748>

##### 2-2、下载Zookeeper

首先要注意在生产环境中目录结构要定义好，防止在项目过多的时候找不到所需的项目

\#首先创建Zookeeper项目目录

```
mkdir /data/zookeeper     #项目目录
mkdir  /data/zookeeper/zkdata          #存放快照日志
mkdir  /data/zookeeper/zkdatalog     #存放事物日志
```

\#下载,解压软件

```
cd /data/zookeeper
wget https://mirrors.cnnic.cn/apache/zookeeper/zookeeper-3.4.12/zookeeper-3.4.12.tar.gz
tar -zxvf zookeeper-3.4.12.tar.gz
mv zookeeper-3.4.12 /usr/local/zookeeper
```

#### **3、修改配置文件**

进入到解压好的目录里面的conf目录中，查看

```
ll /usr/local/zookeeper/conf
#查看
-rw-rw-r-- 1 1000 1000  535 Mar 27 12:32 configuration.xsl
-rw-rw-r-- 1 1000 1000 2161 Mar 27 12:32 log4j.properties
-rw-rw-r-- 1 1000 1000  922 Mar 27 12:32 zoo_sample.cfg
```

\#zoo_sample.cfg 这个文件是官方给我们的zookeeper的样板文件，给他复制一份命名为zoo.cfg，zoo.cfg是官方指定的文件命名规则。

```
cd /usr/local/zookeeper/conf
cp zoo_sample.cfg zoo.cfg
```

3台服务器的配置文件

```
# vim zoo.cfg

tickTime=2000
initLimit=10
syncLimit=5
dataDir=/data/zookeeper/zkdata
dataLogDir=/data/zookeeper/zkdatalog
clientPort=12181
server.1=192.168.30.204:12888:13888
server.2=192.168.30.205:12888:13888
server.3=192.168.30.206:12888:13888
```

### Zookeeper配置文件解释

```
#tickTime：
这个时间是作为 Zookeeper 服务器之间或客户端与服务器之间维持心跳的时间间隔，也就是每个 tickTime 时间就会发送一个心跳。
#initLimit：
这个配置项是用来配置 Zookeeper 接受客户端（这里所说的客户端不是用户连接 Zookeeper 服务器的客户端，而是 Zookeeper 服务器集群中连接到 Leader 的 Follower 服务器）初始化连接时最长能忍受多少个心跳时间间隔数。当已经超过 5个心跳的时间（也就是 tickTime）长度后 Zookeeper 服务器还没有收到客户端的返回信息，那么表明这个客户端连接失败。总的时间长度就是 5*2000=10 秒
#syncLimit：
这个配置项标识 Leader 与Follower 之间发送消息，请求和应答时间长度，最长不能超过多少个 tickTime 的时间长度，总的时间长度就是5*2000=10秒
#dataDir：
快照日志的存储路径
#dataLogDir：
事物日志的存储路径，如果不配置这个那么事物日志会默认存储到dataDir制定的目录，这样会严重影响zk的性能，当zk吞吐量较大的时候，产生的事物日志、快照日志太多
#clientPort：
这个端口就是客户端连接 Zookeeper 服务器的端口，Zookeeper 会监听这个端口，接受客户端的访问请求。修改他的端口改大点
#server.1 这个1是服务器的标识也可以是其他的数字， 表示这个是第几号服务器，用来标识服务器，这个标识要写到快照目录下面myid文件里
#192.168.7.107为集群里的IP地址，第一个端口是master和slave之间的通信端口，默认是2888，第二个端口是leader选举的端口，集群刚启动的时候选举或者leader挂掉之后进行新的选举的端口默认是3888
```

#### **1、三台服务器上分别创建myid文件**

```
#server1（192.168.30.204）
echo "1" > /data/zookeeper/zkdata/myid
#server2（192.168.30.205）
echo "2" > /data/zookeeper/zkdata/myid
#server3（192.168.30.206）
echo "3" > /data/zookeeper/zkdata/myid
```

#### **2、重要配置说明**

2-1、myid文件和server.myid 在快照目录下存放的标识本台服务器的文件，他是整个zk集群用来发现彼此的一个重要标识。
2-2、zoo.cfg 文件是zookeeper配置文件 在conf目录里。
2-3、log4j.properties文件是zk的日志输出文件 在conf目录里用java写的程序基本上有个共同点日志都用log4j，来进行管理。

```
# cat /usr/local/zookeeper/conf/log4j.properties
------------------------------------------------------------------------------------------------------------------------------------------------------
# Define some default values that can be overridden by system properties
zookeeper.root.logger=INFO, CONSOLE  #日志级别
zookeeper.console.threshold=INFO  #使用下面的console来打印日志
zookeeper.log.dir=.    #日志打印到那里，是咱们启动zookeeper的目录 （建议设置统一的日志目录路径）
zookeeper.log.file=zookeeper.log
zookeeper.log.threshold=DEBUG
zookeeper.tracelog.dir=.
zookeeper.tracelog.file=zookeeper_trace.log

#
# ZooKeeper Logging Configuration
#

# Format is "<default threshold> (, <appender>)+

# DEFAULT: console appender only
log4j.rootLogger=${zookeeper.root.logger}

# Example with rolling log file
#log4j.rootLogger=DEBUG, CONSOLE, ROLLINGFILE

# Example with rolling log file and tracing
#log4j.rootLogger=TRACE, CONSOLE, ROLLINGFILE, TRACEFILE

#
# Log INFO level and above messages to the console
#
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender
log4j.appender.CONSOLE.Threshold=${zookeeper.console.threshold}
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout
log4j.appender.CONSOLE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n

# Add ROLLINGFILE to rootLogger to get log file output
#    Log DEBUG level and above messages to a log file
log4j.appender.ROLLINGFILE=org.apache.log4j.RollingFileAppender
log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}

# Max log file size of 10MB
log4j.appender.ROLLINGFILE.MaxFileSize=10MB
# uncomment the next line to limit number of backup files
#log4j.appender.ROLLINGFILE.MaxBackupIndex=10

log4j.appender.ROLLINGFILE.layout=org.apache.log4j.PatternLayout
log4j.appender.ROLLINGFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L] - %m%n

#
# Add TRACEFILE to rootLogger to get log file output
#    Log DEBUG level and above messages to a log file
log4j.appender.TRACEFILE=org.apache.log4j.FileAppender
log4j.appender.TRACEFILE.Threshold=TRACE
log4j.appender.TRACEFILE.File=${zookeeper.tracelog.dir}/${zookeeper.tracelog.file}

log4j.appender.TRACEFILE.layout=org.apache.log4j.PatternLayout
### Notice we are including log4j's NDC here (%x)
log4j.appender.TRACEFILE.layout.ConversionPattern=%d{ISO8601} [myid:%X{myid}] - %-5p [%t:%C{1}@%L][%x] - %m%n
```

2-4、zkEnv.sh和zkServer.sh文件

```
# ll /usr/local/zookeeper/bin/
zkServer.sh 主的管理程序文件
zkEnv.sh 是主要配置，zookeeper集群启动时配置环境变量的文件
```

#### **3、zookeeper定期清理快照和日志文件**

ZooKeeper server will not remove old snapshots and log files when using the default configuration (see autopurge below), this is the responsibility of the operator
\#zookeeper不会主动的清除旧的快照和日志文件，这个是操作者的责任。但是可以通过命令去定期的清理。

```
#!/bin/bash 

#snapshot file dir 
dataDir= /data/zookeeper/zkdata/version-2
#tran log dir 
dataLogDir= /data/zookeeper/zkdatalog/version-2

#Leave 66 files 
count=66 
count=$[$count+1] 
ls -t $dataLogDir/log.* | tail -n +$count | xargs rm -f 
ls -t $dataDir/snapshot.* | tail -n +$count | xargs rm -f 

#以上这个脚本定义了删除对应两个目录中的文件，保留最新的66个文件，可以将他写到crontab中，设置为每天凌晨2点执行一次就可以了。

#zk log dir   del the zookeeper log
#logDir=
#ls -t $logDir/zookeeper.log.* | tail -n +$count | xargs rm -f
```

其他方法：

> 第二种：使用ZK的工具类PurgeTxnLog，它的实现了一种简单的历史文件清理策略，可以在这里看一下他的使用方法 <http://zookeeper.apache.org/doc/r3.4.6/zookeeperAdmin.html>
>
> 第三种：对于上面这个执行，ZK自己已经写好了脚本，在bin/zkCleanup.sh中，所以直接使用这个脚本也是可以执行清理工作的。
>
> 第四种：从3.4.0开始，zookeeper提供了自动清理snapshot和事务日志的功能，通过配置 autopurge.snapRetainCount 和 autopurge.purgeInterval 这两个参数能够实现定时清理了。这两个参数都是在zoo.cfg中配置的：
>
> autopurge.purgeInterval 这个参数指定了清理频率，单位是小时，需要填写一个1或更大的整数，默认是0，表示不开启自己清理功能。
> autopurge.snapRetainCount 这个参数和上面的参数搭配使用，这个参数指定了需要保留的文件数目。默认是保留3个。
>
> 推荐使用第一种方法，对于运维人员来说，将日志清理工作独立出来，便于统一管理也更可控。毕竟zk自带的一些工具并不怎么给力。

#### **4、配置zookeeper的环境变量**

```
# vim /etc/profile
export ZOOKEEPER_HOME=/usr/local/zookeeper
export PATH=$PATH:$ZOOKEEPER_HOME/bin

# source /etc/profile
```

### 启动Zookeeper服务并查看

```
#进入bin目录
cd /usr/local/zookeeper/bin/

#启动服务（3台都需要操作）
zkServer.sh start

#检查服务器状态
zkServer.sh status
----------------------------------------------------------------------------------------------------------
ZooKeeper JMX enabled by default
Using config: /data/zookeeper/zookeeper-3.4.12/bin/../conf/zoo.cfg   #配置文件
Mode: leader    #他是否为领导

#zk集群一般只有一个leader，多个follower，主一般是相应客户端的读写请求，而从主同步数据，当主挂掉之后就会从follower里投票选举一个leader出来。
```

可以用“jps”查看zk的进程， QuorumPeerMain 是 zookeeper 进程

```
#执行命令jps
1744 Jps
1674 QuorumPeerMain
```

\#连接客户端,使用 ls 命令来查看当前 ZooKeeper 中所包含的内容
运行Java版本的客户端使用bash zkCli.sh -server IP:port ，运行C语言版本的使用./cli_mt IP:port，下面介绍Java版本的，C语言版差不多。

```
./zkCli.sh -server 127.0.0.1:12181

-----

................................................
[zk: 127.0.0.1:12181(CONNECTED) 0] ls /
[zookeeper]
[zk: 127.0.0.1:12181(CONNECTED) 1] quit

```

\#配置 zookeeper 开机启动

```
echo '/usr/local/zookeeper/bin/zkServer.sh start' >>/etc/rc.local 
```

## Kafka集群搭建

#### **1、软件环境**

1-1、linux一台或多台，大于等于2
1-2、已经搭建好的zookeeper集群
1-3、软件版本kafka_2.11-0.9.0.1.tgz

#### **2、创建目录并下载安装软件**

准备好kafka安装包，官网下载地址：
<http://kafka.apache.org/downloads.html>

```
#创建项目目录
mkdir /data/kafka -p
#创建kafka消息目录，主要存放kafka消息
mkdir  /data/kafka/kafkalogs 
#下载解压软件
cd /data/kafka
wget http://mirrors.shu.edu.cn/apache/kafka/1.0.1/kafka_2.11-1.0.1.tgz
tar -zxvf kafka_2.11-1.0.1.tgz
mv kafka_2.11-1.0.1 /usr/local/kafka
```

#### **3、修改配置文件**

进入到config目录
`ll /usr/local/kafka/config/`
主要关注：server.properties 这个文件即可，我们可以发现在目录下：

有很多文件，这里可以发现有Zookeeper文件，我们可以根据Kafka内带的zk集群来启动，但是建议使用独立的zk集群

```
-rw-r--r-- 1 root root  906 Feb 22 06:26 connect-console-sink.properties
-rw-r--r-- 1 root root  909 Feb 22 06:26 connect-console-source.properties
-rw-r--r-- 1 root root 5807 Feb 22 06:26 connect-distributed.properties
-rw-r--r-- 1 root root  883 Feb 22 06:26 connect-file-sink.properties
-rw-r--r-- 1 root root  881 Feb 22 06:26 connect-file-source.properties
-rw-r--r-- 1 root root 1111 Feb 22 06:26 connect-log4j.properties
-rw-r--r-- 1 root root 2730 Feb 22 06:26 connect-standalone.properties
-rw-r--r-- 1 root root 1221 Feb 22 06:26 consumer.properties
-rw-r--r-- 1 root root 4727 Feb 22 06:26 log4j.properties
-rw-r--r-- 1 root root 1919 Feb 22 06:26 producer.properties
-rw-r--r-- 1 root root 6852 Feb 22 06:26 server.properties
-rw-r--r-- 1 root root 1032 Feb 22 06:26 tools-log4j.properties
-rw-r--r-- 1 root root 1023 Feb 22 06:26 zookeeper.properties
```

### Kafka配置参数解释

```
# cat /usr/local/kafka/config/server.properties
----------------------------------------------------------------------------------------------------------------------------------
broker.id=0  #当前机器在集群中的唯一标识，和zookeeper的myid性质一样,每台服务器的broker.id都不能相同
port=19092 #当前kafka对外提供服务的端口默认是9092
host.name=192.168.30.204 #这个参数默认是关闭的，在0.8.1有个bug，DNS解析问题，失败率的问题。
num.network.threads=3 #这个是borker进行网络处理的线程数
num.io.threads=8 #这个是borker进行I/O处理的线程数
log.dirs=/data/kafka/kafkalogs/ #消息存放的目录，这个目录可以配置为“，”逗号分割的表达式，上面的num.io.threads要大于这个目录的个数，如果配置多个目录，新创建的topic将消息持久化的地方是，当前以逗号分割的目录中，哪个分区数最少就放那一个
socket.send.buffer.bytes=102400 #发送缓冲区buffer大小，数据不是一下子就发送的，会先存储到缓冲区，到达一定的大小后在发送，能提高性能
socket.receive.buffer.bytes=102400 #kafka接收缓冲区大小，当数据到达一定大小后在序列化到磁盘
socket.request.max.bytes=104857600 #这个参数是向kafka请求消息或者向kafka发送消息的请求的最大数，这个值不能超过java的堆栈大小
num.partitions=1 #默认的分区数，一个topic默认1个分区数
log.retention.hours=168 #默认消息的最大持久化时间，168小时，7天
message.max.byte=5242880  #消息保存的最大值5M
default.replication.factor=2  #kafka保存消息的副本数，如果一个副本失效了，另一个还可以继续提供服务
replica.fetch.max.bytes=5242880  #取消息的最大直接数
log.segment.bytes=1073741824 #这个参数是：因为kafka的消息是以追加的形式落地到文件，当超过这个值的时候，kafka会新起一个文件
log.retention.check.interval.ms=300000 #每隔300000毫秒去检查上面配置的log失效时间（log.retention.hours=168 ），到目录查看是否有过期的消息如果有，删除
log.cleaner.enable=false #是否启用log压缩，一般不用启用，启用的话可以提高性能
zookeeper.connect=192.168.30.204:12181,192.168.30.205:12181,192.168.30.206:12181 #设置zookeeper的连接端口
```

上面是参数的解释，实际的修改项为：

```
#broker.id=0  每台服务器的broker.id都不能相同

#hostname
host.name=192.168.30.204

#在log.retention.hours=168 下面新增下面三项
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880

#设置zookeeper的连接端口
zookeeper.connect=192.168.30.204:12181,192.168.30.205:12181,192.168.30.206:12181
```

### 启动Kafka集群并测试

#### **1、配置Kafka的环境变量**

```
# vim /etc/profile
export KAFKA_HOME=/usr/local/kafka
export PATH=$PATH:$KAFKA_HOME/bin

# source /etc/profile
```

#### **2、启动Kafka服务**

```
#从后台启动Kafka集群（3台都需要启动）
kafka-server-start.sh -daemon ../config/server.properties

# 官方推荐启动方式：
/usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
```

#### **3、验证服务是否启动**

```
#执行命令jps
4289 Jps
4216 Kafka
1674 QuorumPeerMain

#看到Kafka的进程，说明Kafka已经启动
```

### 验证Kafka

#### **1、创建topic**

```
#创建Topic
kafka-topics.sh --create --zookeeper 192.168.30.204:12181,192.168.30.205:12181,192.168.30.206:12181 --partitions 3 --replication-factor 3 --topic qsh
#解释
--partitions 3   #创建3个分区
--replication-factor 3     #复制3份
--topic     #主题为qsh

#查看topic状态
kafka-topics.sh --describe --zookeeper localhost:12181 --topic qsh

#下面是显示信息
Topic:qsh   PartitionCount:3    ReplicationFactor:3 Configs:
       Topic: qsh   Partition: 0    Leader: 1   Replicas: 1,2,3 Isr: 1,2,3
         Topic: qsh Partition: 1    Leader: 2   Replicas: 2,3,1 Isr: 2,3,1
       Topic: qsh   Partition: 2    Leader: 3   Replicas: 3,1,2 Isr: 3,1,2

状态说明：
#qsh有三个分区分别为1、2、3;
#分区0的leader是1（broker.id），分区0有三个副本，并且状态都为lsr（ln-sync，表示可以参加选举成为leader）。

#删除topic
    在config/server.properties中加入delete.topic.enable=true并重启服务，在执行如下命令
# kafka-topics.sh --delete --zookeeper localhost:12181 --topic qsh
```

#### **2、测试使用Kafka**

```
#在一台服务器上创建一个发布者-发送消息
kafka-console-producer.sh --broker-list 192.168.30.204:19092 --topic qsh
输入以下信息：
　　This is a message
　　This is another message

#在另一台服务器上创建一个订阅者接收消息
kafka-console-consumer.sh --zookeeper 192.168.30.206:12181 --topic qsh --from-beginning

#--from-beginning 表示从开始第一个消息开始接收
#测试（订阅者那里能正常收到发布者发布的消息，则说明已经搭建成功）
```

#### **3、其他命令**

更多请看官方文档：<http://kafka.apache.org/documentation.html>

```
#查看topic
kafka-topics.sh --list --zookeeper localhost:12181

#就会显示我们创建的所有topic
```

#### **4、日志说明**

默认kafka的日志是保存在/usr/local/kafka/logs/目录下的，这里说几个需要注意的日志

```
server.log     #kafka的运行日志
state-change.log    #kafka是用zookeeper来保存状态，所以他可能会进行切换，切换的日志就保存在这里
controller.log     #kafka选择一个节点作为“controller”,当发现有节点down掉的时候它负责在有用分区的所有节点中选择新的leader,这使得Kafka可以批量的高效的管理所有分区节点的主从关系。如果controller down掉了，活着的节点中的一个会备切换为新的controller.
```

#### **5、登录zk查看目录情况**

```
#使用客户端进入zk
zkCli.sh -server 127.0.0.1:12181    #默认是不用加’-server‘参数的因为我们修改了他的端口

#查看目录情况 执行“ls /”
[zk: 127.0.0.1:12181(CONNECTED) 0] ls /
---------------------------------------------------------------------------------------------------------------------------------------
#显示结果：
[cluster, controller, controller_epoch, brokers, zookeeper, admin, isr_change_notification, consumers, log_dir_event_notification, latest_producer_id_block, config]
'''
上面的显示结果中：只有zookeeper是zookeeper原生的，其他都是Kafka创建的
'''

#标注一个重要的
[zk: 127.0.0.1:12181(CONNECTED) 1] get /brokers/ids/1
---------------------------------------------------------------------------------------------------------------------------------------
{"listener_security_protocol_map":{"PLAINTEXT":"PLAINTEXT"},"endpoints":["PLAINTEXT://192.168.30.204:19092"],"jmx_port":-1,"host":"192.168.30.204","timestamp":"1525489051752","port":19092,"version":4}
cZxid = 0x10000001d
ctime = Sat May 05 10:57:31 CST 2018
mZxid = 0x10000001d
mtime = Sat May 05 10:57:31 CST 2018
pZxid = 0x10000001d
cversion = 0
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x10000261cf40000
dataLength = 200
numChildren = 0

#还有一个是查看partion
[zk: 127.0.0.1:12181(CONNECTED) 7] get /brokers/topics/qsh/partitions/1
null
cZxid = 0x10000003e
ctime = Sat May 05 11:22:00 CST 2018
mZxid = 0x10000003e
mtime = Sat May 05 11:22:00 CST 2018
pZxid = 0x10000003f
cversion = 1
dataVersion = 0
aclVersion = 0
ephemeralOwner = 0x0
dataLength = 0
numChildren = 1
```