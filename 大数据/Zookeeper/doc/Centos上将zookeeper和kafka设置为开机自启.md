# Centos上将zookeeper和kafka设置为开机自启

### 一、首先kafka的安装

### 二、配置服务文件

#### 　　1、进入服务配置文件下　　　

```
cd /lib/systemd/system
```

#### 　　2、生成 zookeeper的配置文件,并添加内容

　　　　

```
vim zookeeper.service


```

[Unit]
Description=Zookeeper service
After=network.target

[Service]
Type=simple
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/java/jdk/bin"
User=root
Group=root
ExecStart=/usr/local/services/kafka/kafka/bin/zookeeper-server-start.sh /usr/local/services/kafka/kafka/config/zookeeper.properties
ExecStop=/usr/local/services/kafka/kafka/bin/zookeeper-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

#### 　　3、生成kafka.service配置文件，并添加内容

```
vim kafka.service

[Unit]
Description=Apache Kafka server (broker)
After=network.target  zookeeper.service

[Service]
Type=simple
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/java/jdk/bin"
User=root
Group=root
ExecStart=/usr/local/services/kafka/kafka/bin/kafka-server-start.sh /usr/local/services/kafka/kafka/config/server.properties
ExecStop=/usr/local/services/kafka/kafka/bin/kafka-server-stop.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target

```

#### 　　4、刷新配置文件

```
systemctl daemon-reload

```

#### 　　5、将zookeeper和kafka加入开机服务

```
systemctl enable zookeeper

systemctl enable kafka 

```

　　![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191117201555355.png)

#### 　　6、开启zookeeper服务并查看状态

```
systemctl start zookeeper

systemctl status zookeeper

```

　　![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191117201559587.png)

#### 　　7、开启kafka服务并查看状态

```
systemctl start kafka

systemctl status kafka

```

　　![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191117201635563.png)

　　

 

注意：kafka服务一定要放在zookeeper服务之后启动

 