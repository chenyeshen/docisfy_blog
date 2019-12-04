# Cluster模式搭建

## Cluster模式介绍

sentinel模式基本可以满足一般生产的需求，具备高可用性。但是当数据量过大到一台服务器存放不下的情况时，主从模式或sentinel模式就不能满足需求了，这个时候需要对存储的数据进行分片，将数据存储到多个Redis实例中。cluster模式的出现就是为了解决单机Redis容量有限的问题，将Redis的数据根据一定的规则分配到多台机器。

cluster可以说是sentinel和主从模式的结合体，通过cluster可以实现主从和master重选功能，所以如果配置两个副本三个分片的话，就需要六个Redis实例。因为Redis的数据是根据一定规则分配到cluster的不同机器的，当数据量过大时，可以新增机器进行扩容。

使用集群，只需要将redis配置文件中的`cluster-enable`配置打开即可。每个集群中至少需要三个主数据库才能正常运行，新增节点非常方便。

### cluster集群特点：

```
* 多个redis节点网络互联，数据共享

* 所有的节点都是一主一从（也可以是一主多从），其中从不提供服务，仅作为备用

* 不支持同时处理多个key（如MSET/MGET），因为redis需要把key均匀分布在各个节点上，
  并发量很高的情况下同时创建key-value会降低性能并导致不可预测的行为
  
* 支持在线增加、删除节点

* 客户端可以连接任何一个主节点进行读写
12345678910
```

### Cluster模式搭建

##### 环境准备：

```
三台机器，分别开启两个redis服务（端口）

192.168.30.128              端口：7001,7002

192.168.30.129              端口：7003,7004

192.168.30.130              端口：7005,7006
1234567
```

##### 修改配置文件：

192.168.30.128

```
# mkdir /usr/local/redis/cluster

# cp /usr/local/redis/redis.conf /usr/local/redis/cluster/redis_7001.conf

# cp /usr/local/redis/redis.conf /usr/local/redis/cluster/redis_7002.conf

# chown -R redis:redis /usr/local/redis

# mkdir -p /data/redis/cluster/{redis_7001,redis_7002} && chown -R redis:redis /data/redis
123456789
```

```
# vim /usr/local/redis/cluster/redis_7001.conf

bind 192.168.30.128
port 7001
daemonize yes
pidfile "/var/run/redis_7001.pid"
logfile "/usr/local/redis/cluster/redis_7001.log"
dir "/data/redis/cluster/redis_7001"
#replicaof 192.168.30.129 6379
masterauth 123456
requirepass 123456
appendonly yes
cluster-enabled yes
cluster-config-file nodes_7001.conf
cluster-node-timeout 15000
123456789101112131415
```

```
# vim /usr/local/redis/cluster/redis_7002.conf

bind 192.168.30.128
port 7002
daemonize yes
pidfile "/var/run/redis_7002.pid"
logfile "/usr/local/redis/cluster/redis_7002.log"
dir "/data/redis/cluster/redis_7002"
#replicaof 192.168.30.129 6379
masterauth "123456"
requirepass "123456"
appendonly yes
cluster-enabled yes
cluster-config-file nodes_7002.conf
cluster-node-timeout 15000
123456789101112131415
```

其它两台机器配置与192.168.30.128一致，此处省略

##### 启动redis服务：

```
# redis-server /usr/local/redis/cluster/redis_7001.conf

# tail -f /usr/local/redis/cluster/redis_7001.log

# redis-server /usr/local/redis/cluster/redis_7002.conf

# tail -f /usr/local/redis/cluster/redis_7002.log
1234567
```

其它两台机器启动与192.168.30.128一致，此处省略

##### 安装ruby并创建集群（低版本）：

如果redis版本比较低，则需要安装ruby。任选一台机器安装ruby即可

```
# yum -y groupinstall "Development Tools"

# yum install -y gdbm-devel libdb4-devel libffi-devel libyaml libyaml-devel ncurses-devel openssl-devel readline-devel tcl-devel

# mkdir -p ~/rpmbuild/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# wget http://cache.ruby-lang.org/pub/ruby/2.2/ruby-2.2.3.tar.gz -P ~/rpmbuild/SOURCES

# wget http://raw.githubusercontent.com/tjinjin/automate-ruby-rpm/master/ruby22x.spec -P ~/rpmbuild/SPECS

# rpmbuild -bb ~/rpmbuild/SPECS/ruby22x.spec

# rpm -ivh ~/rpmbuild/RPMS/x86_64/ruby-2.2.3-1.el7.x86_64.rpm

# gem install redis                 #目的是安装这个，用于配置集群
123456789101112131415
```

```
# cp /usr/local/redis/src/redis-trib.rb /usr/bin/

# redis-trib.rb create --replicas 1 192.168.30.128:7001 192.168.30.128:7002 192.168.30.129:7003 192.168.30.129:7004 192.168.30.130:7005 192.168.30.130:7006
123
```

##### 创建集群：

这里是redis5.0.4，所以不需要安装ruby，直接创建集群即可

```
# redis-cli -a 123456 --cluster create 192.168.30.128:7001 192.168.30.128:7002 192.168.30.129:7003 192.168.30.129:7004 192.168.30.130:7005 192.168.30.130:7006 --cluster-replicas 1

Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 192.168.30.129:7004 to 192.168.30.128:7001
Adding replica 192.168.30.130:7006 to 192.168.30.129:7003
Adding replica 192.168.30.128:7002 to 192.168.30.130:7005
M: 80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001
   slots:[0-5460] (5461 slots) master
S: b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002
   replicates 6788453ee9a8d7f72b1d45a9093838efd0e501f1
M: 4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003
   slots:[5461-10922] (5462 slots) master
S: b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004
   replicates 80c80a3f3e33872c047a8328ad579b9bea001ad8
M: 6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005
   slots:[10923-16383] (5461 slots) master
S: 277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006
   replicates 4d74ec66e898bf09006dac86d4928f9fad81f373
Can I set the above configuration? (type 'yes' to accept): yes   #输入yes，接受上面配置
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
1234567891011121314151617181920212223242526
```

可以看到，

```
192.168.30.128:7001是master，它的slave是192.168.30.129:7004；

192.168.30.129:7003是master，它的slave是192.168.30.130:7006；

192.168.30.130:7005是master，它的slave是192.168.30.128:7002
12345
```

##### 自动生成nodes.conf文件：

```
# ls /data/redis/cluster/redis_7001/
appendonly.aof  dump.rdb  nodes-7001.conf

# vim /data/redis/cluster/redis_7001/nodes-7001.conf 

6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557454406312 5 connected 10923-16383
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557454407000 6 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557454408371 5 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 myself,master - 0 1557454406000 1 connected 0-5460
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557454407366 4 connected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557454407000 3 connected 5461-10922
vars currentEpoch 6 lastVoteEpoch 0
123456789101112
```

### 集群操作

##### 登录集群：

```
# redis-cli -c -h 192.168.30.128 -p 7001 -a 123456                  # -c，使用集群方式登录
1
```

##### 查看集群信息：

```
192.168.30.128:7001> CLUSTER INFO                   #集群状态

cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:580
cluster_stats_messages_pong_sent:551
cluster_stats_messages_sent:1131
cluster_stats_messages_ping_received:546
cluster_stats_messages_pong_received:580
cluster_stats_messages_meet_received:5
cluster_stats_messages_received:1131
123456789101112131415161718
```

##### 列出节点信息：

```
192.168.30.128:7001> CLUSTER NODES                  #列出节点信息

6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557455176000 5 connected 10923-16383
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557455174000 6 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557455175000 5 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 myself,master - 0 1557455175000 1 connected 0-5460
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557455174989 4 connected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557455175995 3 connected 5461-10922
12345678
```

这里与nodes.conf文件内容相同

##### 写入数据：

```
192.168.30.128:7001> set key111 aaa
-> Redirected to slot [13680] located at 192.168.30.130:7005                #说明数据到了192.168.30.130:7005上
OK

192.168.30.130:7005> set key222 bbb
-> Redirected to slot [2320] located at 192.168.30.128:7001                 #说明数据到了192.168.30.128:7001上
OK

192.168.30.128:7001> set key333 ccc
-> Redirected to slot [7472] located at 192.168.30.129:7003                 #说明数据到了192.168.30.129:7003上
OK

192.168.30.129:7003> get key111
-> Redirected to slot [13680] located at 192.168.30.130:7005
"aaa"

192.168.30.130:7005> get key333
-> Redirected to slot [7472] located at 192.168.30.129:7003
"ccc"

192.168.30.129:7003> 
123456789101112131415161718192021
```

可以看出redis cluster集群是去中心化的，每个节点都是平等的，连接哪个节点都可以获取和设置数据。

当然，平等指的是master节点，因为slave节点根本不提供服务，只是作为对应master节点的一个备份。

##### 增加节点：

**192.168.30.129上增加一节点：**

```
# cp /usr/local/redis/cluster/redis_7003.conf /usr/local/redis/cluster/redis_7007.conf

# vim /usr/local/redis/cluster/redis_7007.conf

bind 192.168.30.129
port 7007
daemonize yes
pidfile "/var/run/redis_7007.pid"
logfile "/usr/local/redis/cluster/redis_7007.log"
dir "/data/redis/cluster/redis_7007"
#replicaof 192.168.30.129 6379
masterauth "123456"
requirepass "123456"
appendonly yes
cluster-enabled yes
cluster-config-file nodes_7007.conf
cluster-node-timeout 15000

# mkdir /data/redis/cluster/redis_7007

# chown -R redis:redis /usr/local/redis && chown -R redis:redis /data/redis

# redis-server /usr/local/redis/cluster/redis_7007.conf 
1234567891011121314151617181920212223
```

**192.168.30.130上增加一节点：**

```
# cp /usr/local/redis/cluster/redis_7005.conf /usr/local/redis/cluster/redis_7008.conf

# vim /usr/local/redis/cluster/redis_7007.conf

bind 192.168.30.130
port 7008
daemonize yes
pidfile "/var/run/redis_7008.pid"
logfile "/usr/local/redis/cluster/redis_7008.log"
dir "/data/redis/cluster/redis_7008"
#replicaof 192.168.30.130 6379
masterauth "123456"
requirepass "123456"
appendonly yes
cluster-enabled yes
cluster-config-file nodes_7008.conf
cluster-node-timeout 15000

# mkdir /data/redis/cluster/redis_7008

# chown -R redis:redis /usr/local/redis && chown -R redis:redis /data/redis

# redis-server /usr/local/redis/cluster/redis_7008.conf 
1234567891011121314151617181920212223
```

##### **集群中增加节点：**

```
192.168.30.129:7003> CLUSTER MEET 192.168.30.129 7007
OK

192.168.30.129:7003> CLUSTER NODES

4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 myself,master - 0 1557457361000 3 connected 5461-10922
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557457364746 1 connected 0-5460
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557457362000 6 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557457363000 4 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557457362000 5 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557457362729 0 connected
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557457363739 5 connected 10923-16383
123456789101112
```

```
192.168.30.129:7003> CLUSTER MEET 192.168.30.130 7008
OK

192.168.30.129:7003> CLUSTER NODES

4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 myself,master - 0 1557457489000 3 connected 5461-10922
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557457489000 1 connected 0-5460
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557457489000 6 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557457488000 4 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557457489472 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 master - 0 1557457489259 0 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557457489000 0 connected
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557457490475 5 connected 10923-16383
12345678910111213
```

可以看到，新增的节点都是以master身份加入集群的

##### **更换节点身份：**

将新增的192.168.30.130:7008节点身份改为192.168.30.129:7007的slave

```
# redis-cli -c -h 192.168.30.130 -p 7008 -a 123456 cluster replicate e51ab166bc0f33026887bcf8eba0dff3d5b0bf14
1
```

`cluster replicate`后面跟node_id，更改对应节点身份。也可以登入集群更改

```
# redis-cli -c -h 192.168.30.130 -p 7008 -a 123456

192.168.30.130:7008> CLUSTER REPLICATE e51ab166bc0f33026887bcf8eba0dff3d5b0bf14
OK

192.168.30.130:7008> CLUSTER NODES

277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557458316881 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557458314864 1 connected 0-5460
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557458316000 3 connected 5461-10922
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557458315872 5 connected 10923-16383
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557458317890 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557458315000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557458315000 1 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557458314000 0 connected
123456789101112131415
```

查看相应的nodes.conf文件，可以发现有更改，它记录当前集群的节点信息

```
# cat /data/redis/cluster/redis_7001/nodes-7001.conf

1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557458236169 7 connected
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557458235000 5 connected 10923-16383
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557458234103 6 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557458235129 5 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 myself,master - 0 1557458234000 1 connected 0-5460
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557458236000 4 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557458236000 0 connected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557458233089 3 connected 5461-10922
vars currentEpoch 7 lastVoteEpoch 0
1234567891011
```

##### 删除节点：

```
192.168.30.130:7008> CLUSTER FORGET 1a1c7f02fce87530bd5abdfc98df1cffce4f1767
(error) ERR I tried hard but I can't forget myself...               #无法删除登录节点

192.168.30.130:7008> CLUSTER FORGET e51ab166bc0f33026887bcf8eba0dff3d5b0bf14
(error) ERR Can't forget my master!                 #不能删除自己的master节点

192.168.30.130:7008> CLUSTER FORGET 6788453ee9a8d7f72b1d45a9093838efd0e501f1
OK              #可以删除其它的master节点

192.168.30.130:7008> CLUSTER NODES

277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557458887328 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557458887000 1 connected 0-5460
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557458886000 3 connected 5461-10922
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave - 0 1557458888351 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557458885000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557458883289 1 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557458885310 0 connected

192.168.30.130:7008> CLUSTER FORGET b4d3eb411a7355d4767c6c23b4df69fa183ef8bc
OK              #可以删除其它的slave节点

192.168.30.130:7008> CLUSTER NODES

277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557459031397 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557459032407 1 connected 0-5460
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557459035434 3 connected 5461-10922
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557459034000 5 connected 10923-16383
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557459032000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557459034000 1 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557459034427 0 connected
12345678910111213141516171819202122232425262728293031
```

##### 保存配置：

```
192.168.30.130:7008> CLUSTER SAVECONFIG                 #将节点配置信息保存到硬盘
OK
 
# cat /data/redis/cluster/redis_7001/nodes-7001.conf

1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557458236169 7 connected
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557458235000 5 connected 10923-16383
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557458234103 6 connected
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557458235129 5 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 myself,master - 0 1557458234000 1 connected 0-5460
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557458236000 4 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557458236000 0 connected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557458233089 3 connected 5461-10922
vars currentEpoch 7 lastVoteEpoch 0

# redis-cli -c -h 192.168.30.130 -p 7008 -a 123456
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.

192.168.30.130:7008> CLUSTER NODES
277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557459500741 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master - 0 1557459500000 1 connected 0-5460
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557459501000 3 connected 5461-10922
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557459500000 5 connected 10923-16383
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557459499737 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557459499000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 slave 80c80a3f3e33872c047a8328ad579b9bea001ad8 0 1557459501750 1 connected
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557459498000 0 connected
123456789101112131415161718192021222324252627
```

可以看到，之前删除的节点又恢复了，这是因为对应的配置文件没有删除，执行`CLUSTER SAVECONFIG`恢复。

##### 模拟master节点挂掉：

192.168.30.128

```
# netstat -lntp |grep 7001
tcp        0      0 192.168.30.128:17001    0.0.0.0:*               LISTEN      6701/redis-server 1 
tcp        0      0 192.168.30.128:7001     0.0.0.0:*               LISTEN      6701/redis-server 1 

# kill 6701
12345
```

```
192.168.30.130:7008> CLUSTER NODES

277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557461178000 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 master,fail - 1557460950483 1557460947145 1 disconnected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557461174922 3 connected 5461-10922
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557461181003 5 connected 10923-16383
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557461179993 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557461176000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 master - 0 1557461178981 8 connected 0-5460
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557461179000 0 connected
12345678910
```

对应7001的一行可以看到，master fail，状态为disconnected；而对应7004的一行，slave已经变成master。

##### 重新启动7001节点：

```
# redis-server /usr/local/redis/cluster/redis_7001.conf

192.168.30.130:7008> CLUSTER NODES

277daeb8660d5273b7c3e05c263f861ed5f17b92 192.168.30.130:7006@17006 slave 4d74ec66e898bf09006dac86d4928f9fad81f373 0 1557461307000 3 connected
80c80a3f3e33872c047a8328ad579b9bea001ad8 192.168.30.128:7001@17001 slave b6331cbc986794237c83ed2d5c30777c1551546e 0 1557461305441 8 connected
4d74ec66e898bf09006dac86d4928f9fad81f373 192.168.30.129:7003@17003 master - 0 1557461307962 3 connected 5461-10922
6788453ee9a8d7f72b1d45a9093838efd0e501f1 192.168.30.130:7005@17005 master - 0 1557461304935 5 connected 10923-16383
b4d3eb411a7355d4767c6c23b4df69fa183ef8bc 192.168.30.128:7002@17002 slave 6788453ee9a8d7f72b1d45a9093838efd0e501f1 0 1557461306000 5 connected
1a1c7f02fce87530bd5abdfc98df1cffce4f1767 192.168.30.130:7008@17008 myself,slave e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 0 1557461305000 7 connected
b6331cbc986794237c83ed2d5c30777c1551546e 192.168.30.129:7004@17004 master - 0 1557461308972 8 connected 0-5460
e51ab166bc0f33026887bcf8eba0dff3d5b0bf14 192.168.30.129:7007@17007 master - 0 1557461307000 0 connected
123456789101112
```

可以看到，7001节点启动后为slave节点，并且是7004的slave节点。即master节点如果挂掉，它的slave节点变为新master节点继续对外提供服务，而原来的master节点如果重启，则变为新master节点的slave节点。

另外，如果这里是拿7007节点做测试的话，会发现7008节点并不会切换，这是因为7007节点上根本没数据。集群数据被分为三份，采用哈希槽 (hash slot)的方式来分配16384个slot的话，它们三个节点分别承担的slot 区间是：

```
节点7004覆盖0－5460
节点7003覆盖5461－10922
节点7005覆盖10923－16383

```

