

# 一、zookeeper集群

docker-compose文件:

```
    version: '3.1'
    services:
      zoo1:
        image: zookeeper
        hostname: zoo1
        container_name: zoo1
        ports:
          - 2181:2181
        environment:
          ZOO_MY_ID: 1
          ZOO_SERVERS: server.1=0.0.0.0:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
      zoo2:
        image: zookeeper
        restart: always
        hostname: zoo2
        container_name: zoo2
        ports:
          - 2182:2181
        environment:
          ZOO_MY_ID: 2
          ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=0.0.0.0:2888:3888 server.3=zoo3:2888:3888
      zoo3:
        image: zookeeper
        restart: always
        hostname: zoo3
        container_name: zoo3
        ports:
          - 2183:2181
        environment:
          ZOO_MY_ID: 3
          ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=0.0.0.0:2888:3888
```

- 在这里ZOO_MY_ID必须唯一
- ZOO_SERVERS用来配置服务的broker

# 二、redis cluster

## 1、创建redis文件夹

在对应的文件夹下分别创建`7001-7006`的文件夹与`docker-compose.yml`，这里名字文件夹代表当前redis节点的端口号,如图所示：

![img](https://img2018.cnblogs.com/blog/1158242/201812/1158242-20181230170355278-2137681865.png)

## 2、创建redis.conf文件

具体redis-cluster示例大家可以参考官网，那么分别配置redis.conf文件

```
    port 7001
    cluster-enabled yes
    cluster-config-file nodes.conf
    cluster-node-timeout 5000
    appendonly yes
```

port与文件夹名对应

## 3、docker-compose.yml文件

```
    version: '3.1'
    services:
      redis-node1:
        image: redis
        hostname: redis-node1
        network_mode: host
        container_name: redis-node1
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7001:7001
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7001/redis.conf:/usr/local/etc/redis/redis.conf"
      redis-node2:
        image: redis
        hostname: redis-node2
        network_mode: host
        container_name: redis-node2
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7002:7002
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7002/redis.conf:/usr/local/etc/redis/redis.conf"
      redis-node3:
        image: redis
        hostname: redis-node3
        network_mode: host
        container_name: redis-node3
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7003:7003
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7003/redis.conf:/usr/local/etc/redis/redis.conf"
      redis-node4:
        image: redis
        hostname: redis-node4
        network_mode: host
        container_name: redis-node4
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7004:7004
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7004/redis.conf:/usr/local/etc/redis/redis.conf"
      redis-node5:
        image: redis
        hostname: redis-node5
        network_mode: host
        container_name: redis-node5
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7005:7005
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7005/redis.conf:/usr/local/etc/redis/redis.conf"
      redis-node6:
        image: redis
        hostname: redis-node6
        network_mode: host
        container_name: redis-node6
        entrypoint: redis-server /usr/local/etc/redis/redis.conf
        ports:
          - 7006:7006
        env_file:
          - .env
        volumes:
          - "${PROJECT_HOME}/7006/redis.conf:/usr/local/etc/redis/redis.conf"
```

这里注意以下几点：

1. network_mode设置为host，否则在创建集群时，会一直等待而不会创建成功
2. volumes挂载点必须覆盖容器内部配置，大家也可以考虑挂载redis持久化的数据文件夹

配置好后分别运行：

```
    $ docker-compose create
    $ docker-compose start
```

## 4、启动集群

在这里部署在阿里云服务器上
运行命令如下：

```
    $ docker run -it  inem0o/redis-trib create --replicas 1  公网IP:7001 公网IP:7002 公网IP:7003  公网IP:7004 公网IP:7005 公网IP:7006 
```

运行后如图所示：

![img](https://img2018.cnblogs.com/blog/1158242/201812/1158242-20181230170400662-1644913588.png)
即可说明成功，然后你就访问主节点试试数据是否同步吧！