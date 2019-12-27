# Docker搭建Zookeeper集群

## 起因

由于最近在学习zookeeper的原理，所以需要在安装一个集群来实验一些特性加深理解。

但是问题来了，我们作为个人学习者，要搭建集群又没有那么多机器，要么就是搭建伪集群，或者就是需要安装一个虚拟机软件（比如vmWare），装多个虚拟机。 这两种方法我之前都试过，都不太理想，一个需要改端口，一种需要安装很多虚拟机，而且换了电脑也不好迁移。每次都得搞重复的配置，实现是太令人烦恼了；

## 目标

综上，上述的痛点，都不是我们愿意做的。接下来，就要介绍今天我用的神器：`Docker` 。

> 使用Docker 基本上不用我们装环境之类的配置，比如安装 jdk。现在我们直接可以从镜像仓库拉别人制作好的镜像，简直不要太方便，直接运行即可。

**今天我要搭建的是一个由四台 zk 构成的 zk 集群，其中一台为 Leader，两台 Follower，一台 Observer。**

`talk is cheap,show me your code`, 接着往下看吧！

------

## 实战

不管你现在用的windows 还是linux 系统，首先你需要安装好Docker环境。 这里就不在叙述了，官网下载安装即可。

如果对Docker 基本操作不熟悉的话，可以看我之前写的 [Docker入门（镜像、容器、仓库）](https://www.jianshu.com/p/251e55d9f9b3)

PS: 本次所制作的镜像，可以直接保存到自己的私服，以后随时随地直接拉取运行即可。**一次制作，到处运行**。

私服的搭建也可以看我之前写的Docker入门。

### 获取镜像

`docker pull zookeeper:3.4.11` 这里我选择了3.4.11 版本。

### 设置docker固定ip

因为我们要搭建的是集群环境，所以ip地址必须固定，因此需要自定义一种网络类型。

#### 创建自定义网络类型，并且指定网段

`sudo docker network create --subnet=192.168.0.0/24 staticnet`

通过`docker network ls`可以查看到网络类型中多了一个 staticnet

### 使用新的网络类型创建并启动容器

```
chong@L MINGW64 ~
$ docker run --name zookeeper-1 --restart always --net staticnet --ip 192.168.0.10 -d zookeeper:3.4.11
61a331b2584b6ef949e2183892c5a73a2e214b7071d4879993f7cbba41c836ed


```

通过`docker inspect`可以查看容器 ip为`192.168.0.10`，关闭容器并重启，发现容器ip并未发生改变。

### 进入容器进行配置

由于容器在后台运行，因此我们需要进入容器，有三种方式，有兴趣的可以看我之前写的 [Docker入门（镜像、容器、仓库）](https://www.jianshu.com/p/251e55d9f9b3)

```
$ docker exec -ti 61a bash   # 61a为容器id

```

登入后，我们只需要做2件事：

1. **修改zoo.cfg**

在 zoo.cfg 文件中添加 zk 集群节点列表

```
bash-4.4# vi /conf/zoo.cfg
clientPort=2181
dataDir=/data
dataLogDir=/datalog
tickTime=2000
initLimit=5
syncLimit=2
maxClientCnxns=60
server.1=192.168.0.10:2888:3888
server.2=192.168.0.11:2888:3888
server.3=192.168.0.12:2888:3888
server.4=192.168.0.13:2888:3888:observer


```

1. **创建** **myid** **文件**

在一步的zoo.cfg文件中我们可以看到dataDir的路径，在/data 目录中创建表示当前主机编号的 myid 文件。该主机编号要与 zoo.cfg 文件中设置的编号一致。

```
bash-4.4# echo 1 > /data/myid

```

### 保存修改后的镜像

因为我们上面对正在运行的容器做了三点修改，这也正是我们需要的集群配置，所以我们要将这个容器制作成镜像,如下操作：

```
$ docker commit -m "create zk1" -a "coderluo" 61a zookeeper-1:3.4.11
sha256:455b27d32c83365790b7b6eff7d58021556858390d28d27b07aca206e83c507c

chong@L MINGW64 ~
$ docker images
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
zookeeper-1                  3.4.11              455b27d32c83        8 seconds ago       146MB
39.108.186.135:5000/ubuntu   v1                  a2a15febcdf3        13 days ago         64.2MB
zookeeper                    3.4.11              56d414270ae3        19 months ago       146MB


```

使用`docekr commit` 进行基于已有的镜像进行创建，我的上一篇Docker入门中也有写。然后通过`docker images` 查看到zookeeper-1 这个镜像已经存在了。

到这里一台镜像已经制作好了，接下来就是一样的事情重复干几遍:

- 进入容器
- 修改myid
- 保存修改制作为新镜像

**查询容器id**

```
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                          NAMES
61a331b2584b        zookeeper:3.4.11    "/docker-entrypoint.…"   About an hour ago   Up 12 minutes       2181/tcp, 2888/tcp, 3888/tcp   zookeeper-1


```

**进入容器执行修改(第2,3台都执行此操作)：**

```
$ docker exec -ti 61a bash
bash-4.4# echo 2 > /data/myid
bash-4.4# cat /data/myid
2
bash-4.4# exit
exit


```

**创建新的镜像(第2,3台都执行此操作)：**

```
$ docker commit -m "create zookeeper-2" -a "coderluo" 61a zookeeper-2:3.4.11
sha256:c775aff13fd3b2fc30066f6fc5f8a5ee429be3052b790c8e02cf74b5e4bf71e9

```

完成后，这里要注意，第四台主机因为我们要让他作为Observer，所以他需要在zoo.cfg中增加一行配置：

`peerType=observer`

![img](http://upload-images.jianshu.io/upload_images/2438927-6619805f82ad029a.png?imageMogr2/auto-orient/strip|imageView2/2/w/449/format/webp)

1.png

然后在执行上面和第2,3台机器一样的操作。

最后我们查看当前所有的镜像，不出意外的话下图展示的你也都有了：

![img](http://upload-images.jianshu.io/upload_images/2438927-0518d9442dbc9b56.png?imageMogr2/auto-orient/strip|imageView2/2/w/888/format/webp)

2.png

到这里，今天的学习就要接近尾声了，最后一步

### 依次启动4台zookeeper实例

直接按照我下面的命令一次执行即可：

```
chong@L MINGW64 ~
$  docker run --name zookeeper-1 --restart always --net staticnet --ip 192.168.0.10 -d zookeeper-1:3.4.11 #第一台
35acd4f798c8154047f30af184145d8b4124ec8a4e8e4a549db0d333a1c33785
chong@L MINGW64 ~
$  docker run --name zookeeper-2 --restart always --net staticnet --ip 192.168.0.11 -d zookeeper-2:3.4.11 #第二台
7ef30c809183dc223e42e891880ad8c85381fac11d15da5c0455400b915c77bb

chong@L MINGW64 ~
$  docker run --name zookeeper-3 --restart always --net staticnet --ip 192.168.0.12 -d zookeeper-3:3.4.11 #第三台
f138451dd21ce5217eb6e4472116b3ffa32e9ea2afbcaae44ee4d633040299f9
chong@L MINGW64 ~
$  docker run --name zookeeper-4 --restart always --net staticnet --ip 192.168.0.13 -d zookeeper-4:3.4.11 #第四台
c662d3438db74414c9b0178bc756b6cf96cd0458cbc226e8854da4a06337d656


```

查看运行状态：

```
$ docker ps -a
CONTAINER ID        IMAGE                COMMAND                  CREATED              STATUS              PORTS                          NAMES
c662d3438db7        zookeeper-4:3.4.11   "/docker-entrypoint.…"   6 seconds ago        Up 4 seconds        2181/tcp, 2888/tcp, 3888/tcp   zookeeper-4
f138451dd21c        zookeeper-3:3.4.11   "/docker-entrypoint.…"   24 seconds ago       Up 23 seconds       2181/tcp, 2888/tcp, 3888/tcp   zookeeper-3
7ef30c809183        zookeeper-2:3.4.11   "/docker-entrypoint.…"   41 seconds ago       Up 39 seconds       2181/tcp, 2888/tcp, 3888/tcp   zookeeper-2
35acd4f798c8        zookeeper-1:3.4.11   "/docker-entrypoint.…"   About a minute ago   Up About a minute   2181/tcp, 2888/tcp, 3888/tcp   zookeeper-1


```





## 一台机器搭建集群



```
version: '3'
services:
    zoo1:
        image: wurstmeister/zookeeper   
        container_name: zoo1
        restart: always
        hostname: zoo1            
        ports:
            - 2181:2181 
        environment:       
            ZOO_MY_ID: 1   
            ZOO_SERVERS: server.1=0.0.0.0:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=zoo3:2888:3888;2181  
        
    zoo2:
        image: wurstmeister/zookeeper
        container_name: zoo2
        restart: always
        hostname: zoo2        
        ports:
            - 2182:2181
        environment:
            ZOO_MY_ID: 2
            ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=0.0.0.0:2888:3888;2181 server.3=zoo3:2888:3888;2181
       
 
    zoo3:
        image: wurstmeister/zookeeper
        container_name: zoo3
        restart: always
        hostname: zoo3     
        ports:
            - 2183:2181
        environment:
            ZOO_MY_ID: 3
            ZOO_SERVERS: server.1=zoo1:2888:3888;2181 server.2=zoo2:2888:3888;2181 server.3=0.0.0.0:2888:3888;2181
       
```

