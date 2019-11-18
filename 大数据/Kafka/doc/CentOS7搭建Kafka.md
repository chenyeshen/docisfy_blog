# CentOS7 搭建Kafka

### 安装

官方的下载页有source和binary两个版本，这里下载的binary，source版本你得自己编译后才能用。

```
wget -c http://mirror.bit.edu.cn/apache/kafka/1.1.0/kafka_2.11-1.1.0.tgz
tar -zxvf kafka_2.11-1.1.0.tgz
mv kafka_2.11-1.1.0 /opt/kafka_1.1
cd /opt/kafka_1.1
```

### 配置

kafak的配置文件在/opt/kafka_1.1/config下叫server.propertie，释义如下：

```
broker.id=0  #当前机器在集群中的唯一标识，和zookeeper的myid性质一样，但是不管你怎么配，别配0就是，不然创建Topic的时候回报错。
port=19092 #当前kafka对外提供服务的端口默认是9092
host.name=192.168.7.100 #这个参数默认是关闭的，在0.8.1有个bug，DNS解析问题，失败率的问题。
num.network.threads=3 #这个是borker进行网络处理的线程数
num.io.threads=8 #这个是borker进行I/O处理的线程数
log.dirs=/opt/kafka/kafkalogs/ #消息存放的目录，这个目录可以配置为“，”逗号分割的表达式，上面的num.io.threads要大于这个目录的个数这个目录，如果配置多个目录，新创建的topic他把消息持久化的地方是，当前以逗号分割的目录中，那个分区数最少就放那一个
socket.send.buffer.bytes=102400 #发送缓冲区buffer大小，数据不是一下子就发送的，先回存储到缓冲区了到达一定的大小后在发送，能提高性能
socket.receive.buffer.bytes=102400 #kafka接收缓冲区大小，当数据到达一定大小后在序列化到磁盘
socket.request.max.bytes=104857600 #这个参数是向kafka请求消息或者向kafka发送消息的请请求的最大数，这个值不能超过java的堆栈大小
num.partitions=1 #默认的分区数，一个topic默认1个分区数
log.retention.hours=168 #默认消息的最大持久化时间，168小时，7天
message.max.byte=5242880  #消息保存的最大值5M
default.replication.factor=2  #kafka保存消息的副本数，如果一个副本失效了，另一个还可以继续提供服务
replica.fetch.max.bytes=5242880  #取消息的最大直接数
log.segment.bytes=1073741824 #这个参数是：因为kafka的消息是以追加的形式落地到文件，当超过这个值的时候，kafka会新起一个文件
log.retention.check.interval.ms=300000 #每隔300000毫秒去检查上面配置的log失效时间（log.retention.hours=168 ），到目录查看是否有过期的消息如果有，删除
log.cleaner.enable=false #是否启用log压缩，一般不用启用，启用的话可以提高性能
zookeeper.connect=192.168.7.100:12181,192.168.7.101:12181,192.168.7.107:1218 #设置zookeeper的连接端口
```

实际上需要修改的就几个：

```
broker.id=133  #每台服务器的broker.id都不能相同
host.name=192-168-253-133 #主机名
listeners=PLAINTEXT://192.168.253.133:9092 #监听地址

#在log.retention.hours=168 下追加
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880

#设置zookeeper的连接端口
zookeeper.connect=192.168.253.133:12181
```

启动命令：

```
/opt/kafka_1.1/bin/kafka-server-start.sh -daemon /opt/kafka_1.1/config/server.properties
```

当kafka启动成功后，在终端上输入“jps”，会得到相应如下：

```
7253 Jps
5850 ZooKeeperMain
6076 QuorumPeerMain
6093 Kafka
```

QuorumPeerMain是zookeeper的守护进程，kafka是kafka的守护进程。

### 常用命令

- 创建主题

```
bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic MyTopic
```

- 列出主题

```
bin/kafka-topics.sh --list --zookeeper localhost:2181
```

- 运行producer

```
bin/kafka-console-producer.sh --broker-list localhost:9092 --topic MyTopic
```

- 运行consumer

```
bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic MyTopic --from-beginning 
```