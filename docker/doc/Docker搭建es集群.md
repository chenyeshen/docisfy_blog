# Docker搭建es集群

## why use docker

1. 学习docker
2. 快，配置和宿主机环境无关，很方便的迁移，也就是说，看我这篇文章的人，能在几分钟内启动一个es集群

## requirement

1. 需要对docker有一定的了解，看这篇文章的人，肯定满足这个要求
2. 对es有一定的了解

## start

首先我们要明确一点的是，我们使用docker来启动es，我们需要将es的配置以及存储路径映射到宿主机上，不然我们无法修改es配置或容器关闭后会丢失存储的内容。

所以，我们第一步做的事是，建立每个es节点的配置文件以及存储路径。就像以下的文件目录结构。

![img](http://upload-images.jianshu.io/upload_images/9919411-e39f2a029d0b8351.png?imageMogr2/auto-orient/strip|imageView2/2/w/638/format/webp)

es1.yml内容如下

```
cluster.name: elasticsearch-cluster
node.name: es-node1
network.bind_host: 0.0.0.0
network.publish_host: _eth0_
http.port: 9200
transport.tcp.port: 9300
http.cors.enabled: true
http.cors.allow-origin: "*"
node.master: true
node.data: true
discovery.seed_hosts: ["ES01:9300","ES02:9301","ES03:9302"]
cluster.initial_master_nodes: ["es-node1","es-node2","es-node3"]
discovery.zen.minimum_master_nodes: 1

```

对应的es2.yml和es3.yml只需要修改node.name为`es-node2`和`es-node3`即可。

接下来就是本文最核心的部分了，使用docker-compose启动es集群。

在任意目录下，新建一个docker-compose.yml或docker-compose.yaml文件。(必须为这个名字)

文件内容如下

```
version: '3.7'
services:
  es1:
    image: es:4.0
    container_name: ES01
    environment:
      - ES_JAVA_OPTS=-Xms256m -Xmx256m
    ports:
      - "9200:9200"
      - "9300:9300"
    volumes:
      - /Users/chengchaojie/docker/es/config/es1.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /Users/chengchaojie/docker/es/data1:/usr/share/elasticsearch/data
    networks:
      - es-net
  es2:
    image: es:4.0
    container_name: ES02
    environment:
      - ES_JAVA_OPTS=-Xms256m -Xmx256m
    ports:
      - "9201:9200"
      - "9301:9300"
    volumes:
      - /Users/chengchaojie/docker/es/config/es2.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /Users/chengchaojie/docker/es/data2:/usr/share/elasticsearch/data
    networks:
      - es-net
  es3:
    image: es:4.0
    container_name: ES03
    environment:
      - ES_JAVA_OPTS=-Xms256m -Xmx256m
    ports:
      - "9202:9200"
      - "9302:9300"
    volumes:
      - /Users/chengchaojie/docker/es/config/es3.yml:/usr/share/elasticsearch/config/elasticsearch.yml
      - /Users/chengchaojie/docker/es/data3:/usr/share/elasticsearch/data
    networks:
      - es-net
  es-head:
    image: tobias74/elasticsearch-head
    ports:
      - "9100:9100"

networks:
  es-net:
    driver: bridge

```

把`es:4.0`替换为你本地所拥有的的es镜像，把`Users/chengchaojie/docker`替换为你配置所在的路径

然后运行`docker-compose up -d`就运行了一个es集群以及es-head应用,可以看到以下输出

```
Creating network "es_compose_es-net" with driver "bridge"
Creating network "es_compose_default" with the default driver
Creating ES01                 ... done
Creating ES03                 ... done
Creating ES02                 ... done
Creating es_compose_es-head_1 ... done

```

相对的,关闭只需要在同一个目录下运行`docker-compose down`即可

最后打开`http://localhost:9100/`查看你的es集群状态

![img](http://upload-images.jianshu.io/upload_images/9919411-c15aa4351d01d6b2.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

看到上面的图，其实我还真不确认是不是集群部署成功，那么创建一个索引试试

```
curl -X PUT "localhost:9200/twitter?pretty" -H 'Content-Type: application/json' -d'
{
    "settings" : {
        "index" : {
            "number_of_shards" : 3,
            "number_of_replicas" : 2
        }
    }
}
'

```

可以看到es-head界面变为

![img](http://upload-images.jianshu.io/upload_images/9919411-e495cec131e75a20.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

就代表成功了。

文章到此还没结束，我们学习es最主要的是想用到它的全文索引功能，默认的es不支持中文分词，所以我们需要安装一个中文的分词器-ik分词器。

我们可以有两种方式来实现它。

第一种，通过`docker exec -it <container> bash` 进入容器，然后使用安装命令安装分词器，然后使用`docker commit <container> [repo:tag]`把该容器固化为一个新的镜像。

第二种，我们通过Dockerfile来构建这个安装了ik的es镜像。这也是我选择的方式，感觉专业一点。

首先创建一个目录，在这个目录下建立一个Dockerfile文件。内容如下

```
FROM docker.elastic.co/elasticsearch/elasticsearch:7.3.1
COPY ik/ /usr/share/elasticsearch/plugins/ik/

```

从上面的代码可以看出给es安装插件的原理很简单，其实就是把插件的内容拷贝到plugins目录下即可。

接下来我们在Dockerfile同级目录下新建ik目录，然后在ik目录中通过`wget https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.3.0/elasticsearch-analysis-ik-6.3.0.zip`下载ik插件。

> 注意，把6.3.0替换为你es镜像的版本

然后`unzip elasticsearch-analysis-ik-6.3.0.zip && rm elasticsearch-analysis-ik-6.3.0.zip`

最后通过`docker build -t es:4.0 .`构建新的镜像，使用该镜像的名字替换到上面的docker-compose.yml中的镜像名。

## conclusion

我相信这种方式比传统搭建并且重复启动一个es集群方便多了，不过前提是你得稍微了解一下docker。不过docker或者云原生是未来大势所趋，大家还是需要掌握的。
我相信未来的开发是`配置即代码`的。在云的环境下，以后这些中间件或者我们自己项目的配置部署运行我们开发工作的一部分，运维系统只需要执行`docker-compose up`这些类似的指令即可。