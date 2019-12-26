

#### 镜像选择

> Zookeeper和Kafka集群分别运行在不同的容器中
> zookeeper官方镜像，版本3.4
> kafka采用wurstmeister/kafka镜像

#### 集群规划

| hostname    | Ip addr                    | port      | listener |
| ----------- | -------------------------- | --------- | -------- |
| zoo1        | 172.19.0.11                | 2184:2181 |          |
| zoo2        | 172.19.0.12                | 2185:2181 |          |
| zoo3        | 172.19.0.13                | 2186:2181 |          |
| kafka1      | 172.19.0.14                | 9092:9092 | kafka1   |
| kafka2      | 172.19.0.15                | 9093:9093 | kafka2   |
| Kafka3      | 172.19.0.16                | 9094:9094 | Kafka3   |
| 宿主机root OSX | 192.168.21.139【DHCP获取，会变动】 |           |          |

#### 实现目标

> kafka集群在docker网络中可用，和zookeeper处于同一网络
> 宿主机可以访问zookeeper集群和kafka的broker list
> docker重启时集群自动重启
> 集群的数据文件映射到宿主机器目录中
> 使用yml文件和$ docker-compose up -d命令创建或重建集群

#### zk集群的docker-compose.yml

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
version: '3.4'

services:
  zoo1:
    image: zookeeper
    restart: always
    hostname: zoo1
    container_name: zoo1
    ports:
    - 2184:2181
    volumes:
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo1/data:/data"
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo1/datalog:/datalog"
    environment:
      ZOO_MY_ID: 1
      ZOO_SERVERS: server.1=0.0.0.0:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
    networks:
      br17219:
        ipv4_address: 172.19.0.11

  zoo2:
    image: zookeeper
    restart: always
    hostname: zoo2
    container_name: zoo2
    ports:
    - 2185:2181
    volumes:
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo2/data:/data"
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo2/datalog:/datalog"
    environment:
      ZOO_MY_ID: 2
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=0.0.0.0:2888:3888 server.3=zoo3:2888:3888
    networks:
      br17219:
        ipv4_address: 172.19.0.12

  zoo3:
    image: zookeeper
    restart: always
    hostname: zoo3
    container_name: zoo3
    ports:
    - 2186:2181
    volumes:
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo3/data:/data"
    - "/Users/shaozhipeng/Development/volume/zkcluster/zoo3/datalog:/datalog"
    environment:
      ZOO_MY_ID: 3
      ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=0.0.0.0:2888:3888
    networks:
      br17219:
        ipv4_address: 172.19.0.13

networks:
  br17219:
    external:
      name: br17219
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

#### kafka集群的docker-compose.yml

> kfkluster少拼了个c…

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

```
version: '2'

services:
  kafka1:
    image: wurstmeister/kafka
    restart: always
    hostname: kafka1
    container_name: kafka1
    ports:
    - 9092:9092
    environment:
      KAFKA_ADVERTISED_HOST_NAME: kafka1
      KAFKA_ADVERTISED_PORT: 9092
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
    volumes:
    - /Users/shaozhipeng/Development/volume/kfkluster/kafka1/logs:/kafka
    external_links:
    - zoo1
    - zoo2
    - zoo3
    networks:
      br17219:
        ipv4_address: 172.19.0.14

  kafka2:
    image: wurstmeister/kafka
    restart: always
    hostname: kafka2
    container_name: kafka2
    ports:
    - 9093:9093
    environment:
      KAFKA_ADVERTISED_HOST_NAME: kafka2
      KAFKA_ADVERTISED_PORT: 9093
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
    volumes:
    - /Users/shaozhipeng/Development/volume/kfkluster/kafka2/logs:/kafka
    external_links:
    - zoo1
    - zoo2
    - zoo3
    networks:
      br17219:
        ipv4_address: 172.19.0.15

  kafka3:
    image: wurstmeister/kafka
    restart: always
    hostname: kafka3
    container_name: kafka3
    ports:
    - 9094:9094
    environment:
      KAFKA_ADVERTISED_HOST_NAME: kafka3
      KAFKA_ADVERTISED_PORT: 9094
      KAFKA_ZOOKEEPER_CONNECT: zoo1:2181,zoo2:2181,zoo3:2181
    volumes:
    - /Users/shaozhipeng/Development/volume/kfkluster/kafka3/logs:/kafka
    external_links:
    - zoo1
    - zoo2
    - zoo3
    networks:
      br17219:
        ipv4_address: 172.19.0.16

networks:
  br17219:
    external:
      name: br17219
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

### 结果查看和测试

#### 宿主机命令行创建topic

```
$ pwd
/Users/shaozhipeng/Development/kafka_2.11-2.0.0/bin
$ ./kafka-topics.sh --create --zookeeper localhost:2184,localhost:2185,localhost:2186 --replication-factor 1 --partitions 1 --topic test1
```

#### Kafka Tool查看

![img](http://images.icocoro.me/images/new/2018121701.png)

#### docker ps查看正在运行的容器

![img](http://images.icocoro.me/images/new/2018121702.png)

#### 查看宿主机IP地址，并设置Host

> 这样宿主机就可以访问kafka集群了

[ ](http://images.icocoro.me/images/new/2018121703.png)![img](http://images.icocoro.me/images/new/2018121704.png)