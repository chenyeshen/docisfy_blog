# 使用Docker构建RabbitMQ高可用负载均衡集群

本文使用Docker搭建RabbitMQ集群，然后使用HAProxy做负载均衡，最后使用KeepAlived实现集群高可用，从而搭建起来一个完成了RabbitMQ高可用负载均衡集群。受限于自身条件，本文使用VMware虚拟机的克隆功能克隆了两台服务器进行操作，仅作为一个demo，开发中可根据实际情况进行调整。

首先看下RabbitMQ高可用负载均衡集群长什么样子：

![img](http://upload-images.jianshu.io/upload_images/6842240-a3ac38408a50c51f.png?imageMogr2/auto-orient/strip|imageView2/2/w/859/format/webp)

image

使用Docker构建RabbitMQ高可用负载均衡集群大概分为三个步骤：

1. 启动多个（3个为例）RabbitMQ，构建RabbitMQ集群，并配置为镜像模式。
2. 使用HAProxy做负载均衡。
3. 使用KeepAlived实现高可用。

## 一、构建RabbitMQ集群

### 1. 启动多个RabbitMQ节点

使用Docker启动3个RabbitMQ节点，目标如下表所示：

| 服务器ip          | 端口   | hostname   | 管理界面地址               |
| -------------- | ---- | ---------- | -------------------- |
| 192.168.16.128 | 5672 | my-rabbit1 | 192.168.16.128:15672 |
| 192.168.16.128 | 5673 | my-rabbit2 | 192.168.16.128:15673 |
| 192.168.16.128 | 5674 | my-rabbit3 | 192.168.16.128:15674 |

命令：

```
docker run -d --hostname my-rabbit1 --name rabbit1 -p 5672:5672 -p 15672:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' rabbitmq:3.8.0-beta.4-management

docker run -d --hostname my-rabbit2 --name rabbit2 -p 5673:5672 -p 15673:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' --link rabbit1:my-rabbit1 rabbitmq:3.8.0-beta.4-management

docker run -d --hostname my-rabbit3 --name rabbit3 -p 5674:5672 -p 15674:15672 -e RABBITMQ_ERLANG_COOKIE='rabbitcookie' --link rabbit1:my-rabbit1 --link rabbit2:my-rabbit2 rabbitmq:3.8.0-beta.4-management

```

注意：由于Erlang节点间通过认证Erlang cookie的方式来允许互相通信，所以RABBITMQ_ERLANG_COOKIE必须设置为相同的。

启动完成之后，使用docker ps命令查看运行情况，确保RabbitMQ都已经启动。

```
CONTAINER ID        IMAGE                              COMMAND                  CREATED             STATUS              PORTS                                                                                        NAMES
2d6f612fdc8e        rabbitmq:3.8.0-beta.4-management   "docker-entrypoint..."   5 seconds ago       Up 4 seconds        4369/tcp, 5671/tcp, 15671/tcp, 25672/tcp, 0.0.0.0:5674->5672/tcp, 0.0.0.0:15674->15672/tcp   rabbit3
c410aa73ce68        rabbitmq:3.8.0-beta.4-management   "docker-entrypoint..."   14 seconds ago      Up 14 seconds       4369/tcp, 5671/tcp, 15671/tcp, 25672/tcp, 0.0.0.0:5673->5672/tcp, 0.0.0.0:15673->15672/tcp   rabbit2
ceb28620d7b1        rabbitmq:3.8.0-beta.4-management   "docker-entrypoint..."   24 seconds ago      Up 23 seconds       4369/tcp, 5671/tcp, 0.0.0.0:5672->5672/tcp, 15671/tcp, 25672/tcp, 0.0.0.0:15672->15672/tcp   rabbit1

```

### 2. 加入集群

内存节点和磁盘节点的选择：

每个RabbitMQ节点，要么是内存节点，要么是磁盘节点。内存节点将所有的队列、交换器、绑定、用户等元数据定义都存储在内存中；而磁盘节点将元数据存储在磁盘中。单节点系统只允许磁盘类型的节点，否则当节点重启以后，所有的配置信息都会丢失。如果采用集群的方式，可以选择至少配置一个节点为磁盘节点，其余部分配置为内存节点，，这样可以获得更快的响应。所以本集群中配置节点1位磁盘节点，节点2和节点3位内存节点。

集群中的第一个节点将初始元数据代入集群中，并且无须被告知加入。而第2个和之后加入的节点将加入它并获取它的元数据。要加入节点，需要进入Docker容器，重启RabbitMQ。

设置节点1：

```
docker exec -it rabbit1 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl start_app
exit

```

设置节点2：

```
docker exec -it rabbit2 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster --ram rabbit@my-rabbit1
rabbitmqctl start_app
exit

```

设置节点3：

```
docker exec -it rabbit3 bash
rabbitmqctl stop_app
rabbitmqctl reset
rabbitmqctl join_cluster --ram rabbit@my-rabbit1
rabbitmqctl start_app
exit

```

节点设置完成之后，在浏览器访问192.168.16.128:15672、192.168.16.128:15673和192.168.16.128:15674中任意一个，都会看到RabbitMQ集群已经创建成功。

![img](http://upload-images.jianshu.io/upload_images/6842240-2cf2f5927371fcbe.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image

### 3. 配置镜像队列

镜像队列工作原理：在非镜像队列的集群中，消息会路由到指定的队列。当配置为镜像队列之后，消息除了按照路由规则投递到相应的队列外，还会投递到镜像队列的拷贝。也可以想象在镜像队列中隐藏着一个fanout交换器，将消息发送到镜像的队列的拷贝。

进入任意一个RabbitMQ节点，执行如下命令：

```
rabbitmqctl set_policy ha-all "^" '{"ha-mode":"all"}'

```

可以设置镜像队列，"^"表示匹配所有队列，即所有队列在各个节点上都会有备份。在集群中，只需要在一个节点上设置镜像队列，设置操作会同步到其他节点。

查看集群的状态:

```
rabbitmqctl cluster_status

```

## 二、HAProxy负载均衡

第一步构建RabbitMQ集群只是构建高可用负载均衡集群的基础，下面将使用HAProxy为RabbitMQ集群做负载均衡。

Haproxy 是目前比较流行的一种群集调度工具，是使用C语言编写的自由及开放源代码软件，其提供高可用性、负载均衡，以及基于TCP和HTTP的应用程序代理。同类群集调度工具有很多，如LVS 和 Nginx 。相比较而言，LVS 性能最好，但是搭建相对复杂，Nginx的upstream模块支持群集功能，但是对群集节点的健康检查功能不强，性能没有HAProxy 好。

对于调度算法本文采用最简单最常用的轮询算法。

本来想采用Docker的方式拉取并运行HAProxy镜像，折腾了好几天搞不定，HAProxy启动不了，故采用源码安装的方式安装HAProxy。

配置两个HAProxy节点实现负载均衡：

| 服务器ip          | 端口号  | 管理界面地址                                   |
| -------------- | ---- | ---------------------------------------- |
| 192.168.16.128 | 8888 | [http://192.168.16.128:8888/haproxy](https://links.jianshu.com/go?to=http%3A%2F%2F192.168.16.128%3A8888%2Fhaproxy) |
| 192.168.16.129 | 8888 | [http://192.168.16.129:8888/haproxy](https://links.jianshu.com/go?to=http%3A%2F%2F192.168.16.129%3A8888%2Fhaproxy) |

### 1. 安装HAProxy

1. 下载

由于到官网下载需要kexue上网，这里提供百度云链接。

链接: [https://pan.baidu.com/s/1uaSJa3NHFiE1E6dk7iHMwQ](https://links.jianshu.com/go?to=https%3A%2F%2Fpan.baidu.com%2Fs%2F1uaSJa3NHFiE1E6dk7iHMwQ) 提取码: irz6

1. 将haproxy-1.7.8.tar.gz拷贝至/opt目录下，解压缩：

```
tar zxvf haproxy-1.7.8.tar.gz

```

1. 进入目录，编译成可执行文件。

将源代码解压之后，需要运行make来将HAProxy编译成为可执行文件。如果是在Linux2.6系统上面进行编译的话，需要设置TARGET=linux26以开启epoll支持，这也是为什么网上许多博客里面都是这么写的。对于其他的UNIX系统来说，直接采用TARGET=generic方式，本文进行安装的系统为CentOS7 ，内核3.10版本。

```
cd haproxy-1.7.8
make TARGET=generic

```

执行完毕之后，目录下出现haproxy的可执行文件。

### 2. 配置HAProxy

HAProxy配置文件说明

HAProxy配置文件通常分为三个部分，即global、defaults和listen。global为全局配置，defaults为默认配置，listen为应用组件配置。

global为全局配置部分，属于进程级别的配置，通常和使用的操作系统配置相关。

defaults配置项配置默认参数，会被应用组件继承，如果在应用组件中没有特别声明，将使用默认配置参数。

以配置RabbitMQ集群的负载均衡为例，在安装目录下面新建一个haproxy.cfg，输入下面配置信息：

```
global
  #日志输出配置，所有日志都记录在本机，通过local0输出
  log 127.0.0.1 local0 info
  #最大连接数
  maxconn 10240
  #以守护进程方式运行
  daemon

defaults
  #应用全局的日志配置
  log global
  mode http
  #超时配置
  timeout connect 5000
  timeout client 5000
  timeout server 5000
  timeout check 2000

listen http_front #haproxy的客户页面
  bind 192.168.16.128:8888
  mode http
  option httplog
  stats uri /haproxy
  stats auth admin:123456
  stats refresh 5s
  stats enable

listen haproxy #负载均衡的名字
  bind 0.0.0.0:5666 #对外提供的虚拟的端口
  option tcplog
  mode tcp
  #轮询算法
  balance roundrobin
  server rabbit1 192.168.16.128:5672 check inter 5000 rise 2 fall 2
  server rabbit2 192.168.16.128:5673 check inter 5000 rise 2 fall 2
  server rabbit3 192.168.16.128:5674 check inter 5000 rise 2 fall 2

```

### 3. 启动

启动命令：

```
/opt/haproxy-1.7.8/haproxy -f /opt/haproxy-1.7.8/haproxy.cfg

```

验证一下是否启动成功：

```
[root@localhost haproxy-1.7.8]# lsof -i:8888
COMMAND   PID USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
haproxy 45031 root    3u  IPv4 228341      0t0  TCP localhost.localdomain:ddi-tcp-1 (LISTEN)

```

在浏览器上访问[http://192.168.16.128:8888/haproxy](https://links.jianshu.com/go?to=http%3A%2F%2F192.168.16.128%3A8888%2Fhaproxy)，输入配置的用户名和密码登录以后，可以看到如下画面：

![img](http://upload-images.jianshu.io/upload_images/6842240-ba02ef377378044f.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

image

再以相同的方式在192.168.16.129服务器上面启动一个HAProxy。

到此，负载均衡配置完成。

## 三、KeepAlived配置高可用

Keepalived，它是一个高性能的服务器高可用或热备解决方案，Keepalived主要来防止服务器单点故障的发生问题，可以通过其与Nginx、Haproxy等反向代理的负载均衡服务器配合实现web服务端的高可用。Keepalived以VRRP协议为实现基础，用VRRP协议来实现高可用性（HA）。

### 1. KeepAlived安装

Keepalived的官网下载Keepalived的安装文件，目前最新的版本为：keepalived-2.0.17.tar.gz，下载地址为[http://www.keepalived.org/download.html](https://links.jianshu.com/go?to=http%3A%2F%2Fwww.keepalived.org%2Fdownload.html)。

下载之后进行解压和编译安装。

```
tar zxvf keepalived-2.0.17.tar.gz
cd keepalived-2.0.17
./configure --prefix=/opt/keepalived --with-init=SYSV
#注：(upstart|systemd|SYSV|SUSE|openrc) #根据你的系统选择对应的启动方式
make
make install

```

### 2. KeepAlived配置

之后将安装过后的Keepalived加入系统服务中，详细步骤如下：

```
cp /opt/keepalived/etc/rc.d/init.d/keepalived /etc/init.d/
cp /opt/keepalived/etc/sysconfig/keepalived /etc/sysconfig
cp /opt/keepalived/sbin/keepalived /usr/sbin/
chmod +x /etc/init.d/keepalived
chkconfig --add keepalived
chkconfig keepalived on
#Keepalived默认会读取/etc/keepalived/keepalived.conf配置文件
mkdir /etc/keepalived
cp /opt/keepalived/etc/keepalived/keepalived.conf /etc/keepalived/

```

接下来修改/etc/keepalived/keepalived.conf文件，在Keepalived的Master上配置详情如下：

```
#Keepalived配置文件
global_defs {
        router_id NodeA                 #路由ID, 主备的ID不能相同
}

#自定义监控脚本
vrrp_script chk_haproxy {
        script "/etc/keepalived/check_haproxy.sh"
        interval 5
        weight 2
}

vrrp_instance VI_1 {
        state MASTER #Keepalived的角色。Master表示主服务器，从服务器设置为BACKUP
        interface eth0          #指定监测网卡
        virtual_router_id 1
        priority 100            #优先级，BACKUP机器上的优先级要小于这个值
        advert_int 1            #设置主备之间的检查时间，单位为s
        authentication {        #定义验证类型和密码
                auth_type PASS
                auth_pass root123
        }
        track_script {
                chk_haproxy
        }
        virtual_ipaddress {     #VIP地址，可以设置多个：
                192.168.16.130
        }
}


```

Backup中的配置大致和Master中的相同，不过需要修改global_defs{}的router_id，比如置为NodeB；其次要修改vrrp_instance VI_1{}中的state为BACKUP；最后要将priority设置为小于100的值。注意Master和Backup中的virtual_router_id要保持一致。下面简要的展示下Backup的配置：

```
#Keepalived配置文件
global_defs {
        router_id NodeB                 #路由ID, 主备的ID不能相同
}

#自定义监控脚本
vrrp_script chk_haproxy {
        script "/etc/keepalived/check_haproxy.sh"
        interval 5
        weight 2
}

vrrp_instance VI_1 {
        state BACKUP
        interface eth0          #指定监测网卡
        virtual_router_id 1
        priority 80            #优先级，BACKUP机器上的优先级要小于这个值
        advert_int 1            #设置主备之间的检查时间，单位为s
        authentication {        #定义验证类型和密码
                auth_type PASS
                auth_pass root123
        }
        track_script {
                chk_haproxy
        }
        virtual_ipaddress {     #VIP地址，可以设置多个：
                192.168.16.130
        }
}

```

为了防止HAProxy服务挂了，但是Keepalived却还在正常工作而没有切换到Backup上，所以这里需要编写一个脚本来检测HAProxy服务的状态。当HAProxy服务挂掉之后该脚本会自动重启HAProxy的服务，如果不成功则关闭Keepalived服务，如此便可以切换到Backup继续工作。这个脚本就对应了上面配置中vrrp_script chk_haproxy{}的script对应的值，/etc/keepalived/check_haproxy.sh的内容如代码清单所示。

```
#!/bin/bash
if [ $(ps -C haproxy --no-header | wc -l) -eq 0 ];then
        haproxy -f /opt/haproxy-1.7.8/haproxy.cfg
fi
sleep 2
if [ $(ps -C haproxy --no-header | wc -l) -eq 0 ];then
        service keepalived stop
fi

```

如此配置好之后，使用service keepalived start命令启动192.168.16.128和192.168.16.129中的Keepalived服务即可。之后客户端的应用可以通过192.168.16.130这个IP地址来接通RabbitMQ服务。

