

Kafka已经发布了1.0版，为了紧跟时代的步伐，最近学习了《[Kafka权威指南](http://www.ituring.com.cn/book/2067)》。书如其名，这本 Definitive Guide 内容很全面，从Kafka的设计原理和架构细节到开发的代码实例进行了全方位的覆盖。正如本书的前言所述，不管你作为开发工程师围绕Kafka API来写应用还是作为运维工程师（SRE）来安装、配置、调优、监控，本书都提供了足够的细节。

![img](http://upload-images.jianshu.io/upload_images/4209319-1b2c3874dd890cc2.jpg?imageMogr2/auto-orient/strip|imageView2/2/w/380/format/webp)

kafka权威指南

------

### 为何用Docker

我读本书主要还是从开发的角度来看的，所以对我而言，以最快的速度搭建起一个可以运行的环境最为重要。这个时候首先想到的当然是Docker（不熟悉Docker的可以参见拙作 [离不开的工具之《Docker开发指南》](https://www.jianshu.com/p/4bcb1daa7d33)）了。

本书第2章的安装环境是Linux，在附录中介绍了在Windows和Mac OS上的安装过程。我之所以选择用Docker进行安装，主要是出于以下的考虑：

（1）实现开发环境和生产环境的一致性，这点本书附录中也提到了：

> 在桌面操作系统上进行 Kafka 开发或测试时，最好能够让它运行在虚拟机里，这个虚拟机最好能与生产环境的配置相匹配。

（2）使用Docker便于模拟多节点集群，使用docker-compose 工具，我们可以轻松的在单台开发机上启动多个Kafka容器、zookeeper容器，非常方便的实现了对分布式环境的模拟。

（3）安装、启动非常迅速。从安装上讲，在国内如果使用国内的Docker Registry Mirror，下载一个配置好的Kafka镜像可能要比直接下载安装Kafka还要快得多。熟悉Docker的都比较清楚，容器的快速启动本身就是Docker的一大特色。

------

### Docker镜像选型

对比起[RabbitMQ有不断更新的官方Docker镜像](https://hub.docker.com/_/rabbitmq/)，Kafka是没有官方 Docker镜像的，所以要么自己写一个Dockerfile，要么用第三方已经构建好的。首先，自己写一个Dockerfile不是不可以，但不符合我要“最快”的目标，所以用第三方已经构建好的镜像那是最快的。其次，镜像最好是1.x的最新版本，有新版本就要用上嘛。最后，由于是第三方镜像，希望已经用过的人越多越好，这样坑相对会比较少一些。

带着上面三个要求，开始寻找合适的第三方镜像，比较出名的有以下几个：

1. [wurstmeister/kafka](https://github.com/wurstmeister/kafka-docker/)  特点：star数最多，版本更新到 Kafka 1.0 ，zookeeper与kafka分开于不同镜像。
2. [spotify/kafka](https://github.com/spotify/docker-kafka)  特点：star数较多，有很多文章或教程推荐，zookeeper与kafka置于同一镜像中；但kafka版本较老（还停留在0.10.1.0）。
3. [confluent/kafka](https://github.com/confluentinc/cp-docker-images) 背景：Confluent是书中提到的那位开发Kafka的Jay Kreps 从LinkedIn离职后创立的新公司，Confluent Platform 是一个流数据平台，围绕着Kafka打造了一系列产品。特点：大咖操刀，文档详尽，但是也和Confluent Platform进行了捆绑。

上述三个项目中，最简单的是spotify/kafka，但是版本较老。confluent/kafka 资料最为详尽，但是因为与Confluent Platform做了捆绑，所以略显麻烦。最终选定使用wurstmeister/kafka，star最多，版本一直保持更新，用起来应该比较放心。

------

### 安装过程

此处假定读者已经熟练使用docker、docker-compose等工具，所以关于docker的知识就不再赘述。

1. 下载zookeeper镜像:

> docker pull wurstmeister/zookeeper

1. 下载kafka镜像:

> docker pull wurstmeister/kafka

1. 在自己选的目录下创建一个docker-compose.yml文件，

   ​

   内容如下: 

   ​

   docker-compose.yml

**⚠️ 注意**上述内容与
<https://github.com/wurstmeister/kafka-docker/blob/master/docker-compose.yml>
中有一处区别，即倒数第4行中的 **KAFKA_ADVERTISED_HOST_NAME** 改为
**KAFKA_ADVERTISED_LISTENERS** ，其后的ip地址使用宿主机上的 docker-machine ip 地址。

1. 启动docker-compose

> docker-compose up -d

1. 启动多个kafka 节点，比如3个

> docker-compose scale kafka=3

------

### 可用性测试

自此，如果没有出现什么错误，通过docker ps 应该可以看到已经成功启动了一个zookeeper容器，三个Kafka容器。

1. 通过指定容器名（假设容器名为 wurkafka_kafka_1）进入一个Kafka容器:

> docker exec -it wurkafka_kafka_1 /bin/bash

1. 创建一个topic（其中假设zookeeper容器名为 wurkafka_zookeeper_1，topic名为test），输入：

> $KAFKA_HOME/bin/kafka-topics.sh --create --topic test \
>
> --zookeeper wurkafka_zookeeper_1:2181 --replication-factor 1
> --partitions 1

1. 查看新创建的topic:

> $KAFKA_HOME/bin/kafka-topics.sh --zookeeper wurkafka_zookeeper_1:2181 \
>
> --describe --topic test

1. 发布消息:  （输入若干条消息后 按^C 退出发布）

> $KAFKA_HOME/bin/kafka-console-producer.sh --topic=test \
>
> --broker-list wurkafka_kafka_1:9092

1. 接收消息:

> $KAFKA_HOME/bin/kafka-console-consumer.sh  \
>
> --bootstrap-server wurkafka_kafka_1:9092 \
>
> --from-beginning --topic test

如果接收到了发布的消息，证明整个部署正常，就可以正式开始开发工作了。