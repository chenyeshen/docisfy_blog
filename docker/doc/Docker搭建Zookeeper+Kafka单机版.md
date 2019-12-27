# 使用Docker快速搭建Kafka开发环境

Docker在很多时候都可以帮助我们快速搭建想要的开发环境，免去了很多安装配置上的麻烦。在涉及到Apache Kafka的快速demo时，使用Docker Hub上提供的镜像也是一个很好的选择。

### Kafka & ZooKeeper Docker镜像

#### [spotify/kafka](https://link.jianshu.com?t=https%3A%2F%2Fhub.docker.com%2Fr%2Fspotify%2Fkafka%2F)

在demo时，很多情况下我们并不追求Kafka与ZooKeeper的区隔，来自spotify的kafka镜像同时包含了kafka与zookeeper，因此基本上可以“随装随用”。
但已经较长时间没有维护，Kafka版本仍然停留在0.10。对需要使用1.0版本的同仁已经不适合了。

#### [landoop/fast-data-dev](https://link.jianshu.com?t=https%3A%2F%2Fhub.docker.com%2Fr%2Flandoop%2Ffast-data-dev%2F)

提供了一整套包括Kafka，ZooKeeper，Schema Registry,，Kafka-Connect等在内的多种开发工具和Web UI监视系统。基本上是我见过的最强大的开发环境。尤其是对于Kafka Connect的支持，包含了MongoDB，ElasticSearch，Twitter等超过20种Connector，并且提供了通过REST API提交Connector配置的Web UI。
基本是我测试Kafka Connect的首选。

#### [wurstmeister/kafka](https://link.jianshu.com?t=https%3A%2F%2Fhub.docker.com%2Fr%2Fwurstmeister%2Fkafka%2F)

维护较为频繁的一个Kafka镜像。只包含了Kafka，因此需要另行提供ZooKeeper，推荐使用同一作者提交的[wurstmeister/zookeeper](https://link.jianshu.com?t=https%3A%2F%2Fhub.docker.com%2Fr%2Fwurstmeister%2Fzookeeper%2F)。
现在已经提供较新的1.1.0版本。

### 搭建开发环境

**1 ZooKeeper 1 Kafka**

这里以我自己最常用的[wurstmeister/kafka](https://link.jianshu.com?t=https%3A%2F%2Fhub.docker.com%2Fr%2Fwurstmeister%2Fkafka%2F)为例，使用docker-compose运行一个只有一个ZooKeeper node和一个Kafka broker的开发环境：

```
version: '2'

services:
  zoo1:
    image: wurstmeister/zookeeper
    restart: unless-stopped
    hostname: zoo1
    ports:
      - "2181:2181"
    container_name: zookeeper

  # kafka version: 1.1.0
  # scala version: 2.12
  kafka1:
    image: wurstmeister/kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: localhost
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_CREATE_TOPICS: "stream-in:1:1,stream-out:1:1"
    depends_on:
      - zoo1
    container_name: kafka

```

这里利用了wurstmeister/kafka提供的环境参数`KAFKA_CREATE_TOPICS`使Kafka运行后自动创建topics。

**1 ZooKeeper 2 Kafka**

ZooKeeper的部分与上个例子一样，需要调整的是Kafka部分。

这里将第一个Kafka broker命名为kafka1，`KAFKA_ADVERTISED_HOST_NAME`参数设为kafka1，`KAFKA_ADVERTISED_PORT`设为9092。

对于第二个broker，相较第一个broker所有kakfka1的部分改为kafka2，包括service name和coontainer name。同时`KAFKA_BROKER_ID`设为2，`KAFKA_ADVERTISED_PORT`设为9093。

需要注意的是，当有不止一个kafka broker时，这里的hostname不能再设为localhost。建议设为本机IP地址。以Mac为例，使用`ipconfig getifaddr en0`指令来获取。

具体的docker-compose.yml文件内容如下：

```
  # ZooKeeper部分不变

  kafka1:
    image: wurstmeister/kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: 192.168.1.2
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_CREATE_TOPICS: "stream-in:2:1,stream-out:2:1"
    depends_on:
      - zoo1
    container_name: kafka1


  kafka2:
    image: wurstmeister/kafka
    ports:
      - "9093:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: {ipconfig getifaddr en0指令的结果}
      KAFKA_ADVERTISED_PORT: 9093
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_BROKER_ID: 2
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zoo1
    container_name: kafka2

```

### 与容器内的开发环境交互

可以使用`docker exec`命令直接调用kafka容器内的脚本来进行创建/删除topic，启动console producer等等操作。

如果本地存有与容器内相同的Kafka版本文件，也可以直接使用本地脚本文件。如上述docker-compose.yml文件所示，kafka1的hostname即是kafka1，端口为9092，通过kafka1:9092就可以连接到容器内的Kafka服务。

**列出所有topics** (在本地kafka路径下)
`$ bin/kafka-topics.sh --zookeeper localhost:2181 --list`

**列出所有Kafka brokers**
`$ docker exec zookeeper bin/zkCli.sh ls /brokers/ids`