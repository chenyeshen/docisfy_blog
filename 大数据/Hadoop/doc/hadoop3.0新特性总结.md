## 1．hadoop-3.0要求JDK版本不低于1.8，对之前的Java版本不再提供支持.

所有Hadoop JAR现在都是针对Java 8的运行时版本编译的。

## 2．部分服务默认端口修改，不再绑定到Linux临时端口 (HDFS-9427,HADOOP-12811)

**Namenode ports**: 50470 --> 9871, 50070--> 9870, 8020 --> 9820

**Secondary NN ports**: 50091 --> 9869,50090 --> 9868

**Datanode ports: 50020** --> 9867, 50010--> 9866, 50475 --> 9865, 50075 --> 9864

**Kms server ports**: 16000 --> 9600 (原先的16000与HMaster端口冲突)

 ![img](https://images2017.cnblogs.com/blog/1320435/201801/1320435-20180118104928178-1935350547.png)

## 3. 精简了内核，剔除了过期的API和实现，废弃hftp转由webhdfs替代

将默认组件实现替换成最高效的实现（比如将FileOutputCommitter缺省实现换为v2版本，废除hftp转由webhdfs替代，移除Hadoop子实现序列化库org.apache.hadoop.Records

 

## 4.重写 client jars

2.x版本中的hadoop-client Maven工件将Hadoop的传递依赖关系拉到Hadoop应用程序的类路径上。如果这些传递性依赖的版本与应用程序使用的版本冲突，这可能会有问题。

 

添加了新的hadoop-client-api和hadoop-client-runtime构件，可以将Hadoop的依赖关系集中到一个jar中。这可以避免将Hadoop的依赖泄漏到应用程序的类路径中。

 

## **5. Classpath isolation**防止不同版本jar包冲突

防止不同版本jar包冲突，例如google guava在混合使用hadoop、hbase、spark时出现冲突。mapreduce有参数控制忽略hadoop环境中的jar，而使用用户提交的第三方jar，但提交spark任务却不能解决此问题，需要在自己的jar包中重写需要的第三方类或者整个spark环境升级。classpath isolation用户可以很方便的选择自己需要的第三方依赖包。

## 6.支持微软的Azure分布式文件系统和阿里的aliyun分布式文件系统

## 7. Shell脚本重写

（1）增加了参数冲突检测，避免重复定义和冗余参数

（2）CLASSPATH, JAVA_LIBRARY_PATH, and LD_LIBRARY_PATH等参数的去重，缩短环境变量

(3) 提供一份Hadoop环境变量列表  Shell脚本现在支持一个--debug选项，它将报告有关各种环境变量，java选项，classpath等构造的基本信息，以帮助进行配置调试。

(4) 增加了**distch**和**jnipath**子命令到hadoop命令。

(5) 触发ssh连接的操作现在可以使用**pdsh**（如果已安装）。$ {HADOOP \ _SSH \ _OPTS}仍然被应用。

(6) 一个名为**--buildpaths**的新选项将尝试将开发人员构建目录添加到类路径以允许在源代码树测试中。

(7) 守护进程已经通过--daemon选项从* -daemon.sh移动到了bin命令。只需使用--daemon启动一个守护进程

## 8. Hadoop守护进程和MapReduce任务的堆内存管理发生了一系列变化

主机内存大小可以自动调整，HADOOP_HEAPSIZE已弃用。
所需的堆大小不再需要通过任务配置和Java选项实现。已经指定的现有配置不受此更改影响。

## 9. 支持随机container和分布式调度

已经引入了**ExecutionType**的概念，从而应用程序现在可以请求执行类型为**Opportunistic**的容器。即使在调度时没有可用的资源，也可以调度此类型的容器在NM处执行。在这种情况下，这些容器将在NM处排队，等待资源启动。机会容器的优先级低于默认的保证容器，因此如果需要的话，为抢占保证容器而腾出空间。这应该会提高群集利用率。

机会容器默认由中央RM分配，但是也添加了支持以允许机会容器由分布式调度器分配，该分布式调度器被实现为**AMRMProtocol**拦截器。

## 10. S3Guard：S3A文件系统客户端的一致性和元数据缓存

为Amazon S3存储的S3A客户端添加了一个可选功能：能够将DynamoDB表用作文件和目录元数据的快速一致存储。

## 11. Capacity Scheduler队列配置的基于API的配置

容量调度程序的**OrgQueue**扩展提供了一种编程方式，通过提供用户可以调用的REST API来修改队列配置来更改配置。这使管理员可以在队列的**administrators_queue ACL**中自动执行队列配置管理。

## 12. HDFS新功能与特性

### (1)支持HDFS中的擦除编码Erasure Encoding

Erasure coding纠删码技术简称EC,是一种数据保护技术.最早用于通信行业中数据传输中的数据恢复,是一种编码容错技术.他通过在原始数据中加入新的校验数据,使得各个部分的数据产生关联性.在一定范围的数据出错情况下,通过纠删码技术都可以进行恢复.**EC****技术可以防止数据丢失，又可以解决****HDFS****存储空间翻倍的问题。**

 

创建文件时，将从最近的祖先目录继承EC策略，以确定其块如何存储。与3路复制相比，默认的EC策略可以节省50％的存储空间，同时还可以承受更多的存储故障。

 

建议EC存储用于冷数据，由于冷数据确实数量大，可以减少副本从而降低存储空间，另外冷数据稳定，一旦需要恢复数据，对业务不会有太大影响。

### (2) 基于HDFS路由器的联合

HDFS基于路由器的联合会添加一个RPC路由层，提供多个HDFS命名空间的联合视图。这与现有[ViewFs](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/ViewFs.html)和[HDFS联合](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/Federation.html)功能类似），不同之处在于安装表由服务器[端由](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/ViewFs.html)路由层而不是客户端进行管理。这简化了对现有HDFS客户端的联合集群的访问。与现有[ViewFs](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/ViewFs.html)和[HDFS联合](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/Federation.html)功能类似），不同之处在于安装表由服务器[端由](http://hadoop.apache.org/docs/r3.0.0/hadoop-project-dist/hadoop-hdfs/ViewFs.html)路由层而不是客户端进行管理。这简化了对现有HDFS客户端的联合集群的访问。

### (3)支持多个NameNode

允许用户运行多个备用NameNode。例如，通过配置三个NameNode和五个JournalNode，群集能够容忍两个节点的故障，而不是一个故障。

 

但是Active的NameNode始终只有1个，余下的都是Standby。 Standby NN会不断与JN同步，保证自己获取最新的editlog，并将edits同步到自己维护的image中去，这样便可以实现热备，在发生failover的时候，立马切换成active状态，对外提供服务。同时，JN只允许一个active状态的NN写入

### (4)**DataNode****内部添加了负载均衡  Disk Balancer**

支持单个Datanode上，不同硬盘间的数据balancer。老版本的hadoop只支持在Datanode之间进行balancer，每个节点内部不同硬盘之间若发生了数据不平衡，则没有一个好的办法进行处理。现在可以通过hdfs diskbalancer命令，进行节点内部硬盘间的数据平衡。该功能默认是关闭的，需要手动设置参数dfs.disk.balancer.enabled为true来开启。

 

## 13.MapReduce新功能与特性  

### （1）MapReduce任务级本地优化（引入Native Task加速计算）

为MapReduce增加了C/C++的map output collector实现（包括Spill，Sort和IFile等），通过作业级别参数调整就可切换到该实现上。

本地库将使用-**Pnative**自动生成。用户可以通过设置**mapreduce.job.map.output.collector.class = org.apache.hadoop.mapred**来选择新的收集器。
**nativetask.NativeMapOutputCollectorDelegator**的作业配置。对于shuffle密集型工作，这可能会提高30％以上的速度。

### （2）MapReduce内存参数自动推断

在Hadoop 2.0中，为MapReduce作业设置内存参数非常繁琐，涉及到两个参数：**mapreduce.{map,reduce}.memory.mb**和**mapreduce.{map,reduce}.java.opts**，一旦设置不合理，则会使得内存资源浪费严重，比如将前者设置为4096MB，但后者却是“-Xmx2g”，则剩余2g实际上无法让java heap使用到。

有了这个JIRA，我们建议根据可以调整的经验比例自动设置Xmx。如果用户提供，Xmx不会自动更改。

## 14.YARN新功能与特性

### （1）YARN资源类型

YARN资源模型已被推广为支持用户定义的可数资源类型，超越CPU和内存。例如，集群管理员可以定义诸如GPU，软件许可证或本地附加存储器之类的资源。YARN任务可以根据这些资源的可用性进行调度。

### （2）YARN Timeline Service v.2

提供YARN时间轴服务v.2 alpha 2，以便用户和开发人员可以对其进行测试，并提供反馈意见和建议，使其成为Timeline Service v.1.x的替代品。它只能用于测试能力。

 

Yarn Timeline Service V2提供一个通用的应用程序共享信息和共享存储模块。可以将**metrics**等信息保存。可以实现分布式**writer**实例和一个可伸缩的存储模块。同时，v2版本在稳定性和性能上面也做出了提升，原先版本不适用于大集群，v2版本使用hbase取代了原先的leveldb作为后台的存储工具。

 

### （3）基于cgroup的内存隔离和IO Disk隔离

### （4）用curator实现RM leader选举

### （5）支持更改分配容器的资源Container resizing

当前的YARN资源管理逻辑假定分配给容器的资源在其生命周期中是固定的。当用户想要更改分配的容器的资源时，唯一的办法就是释放它并分配一个具有预期大小的新容器。
允许运行时更改分配容器的资源将使我们更好地控制应用程序中的资源使用情况