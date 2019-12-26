通过docker可以很方便的搭建kafka集群作为本地测试环境使用
使用docker-compose进行搭建，包含zookpper服务、kafka broker、kafka-manager。

### 创建目录

```
mkdir -p /data/program/kafka
cd /data/program/kafka
nano docker-compose.yml

```

### docker-compose.yml文件内容：

```
version: '2'

services:
  zoo1:
    image: wurstmeister/zookeeper
    restart: unless-stopped
    hostname: zoo1
    ports:
      - "12181:2181"
    container_name: zookeeper

  # kafka version: 1.1.0
  # scala version: 2.12
  kafka1:
    image: wurstmeister/kafka
    ports:
      - "9092:9092"
    environment:
      KAFKA_ADVERTISED_HOST_NAME: xxx # 这里为宿主机host name
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_BROKER_ID: 1
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    depends_on:
      - zoo1
    container_name: kafka
  kafka-manager:
    image: hlebalbau/kafka-manager
    restart: unless-stopped
    ports:
      - "10085:9000"
    environment:
      ZK_HOSTS: "zoo1:2181"
      APPLICATION_SECRET: "random-secret"
      KAFKA_MANAGER_AUTH_ENABLED: "true"
      KAFKA_MANAGER_USERNAME: "admin"
      KAFKA_MANAGER_PASSWORD: "TL2oo8tl2oo8"
    depends_on:
      - zoo1
    container_name: kafka-manager  
    command: -Dpidfile.path=/dev/null

```

### 启动kakfa集群

```
docker-compose up -d
```