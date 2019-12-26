### Compose介绍

  Compose 项目是 Docker 官方的开源项目，负责实现对 Docker 容器集群的快速编排。Compose 是一个用户定义和运行多个容器的 Docker 应用程序。在 Compose 中你可以使用 YAML 文件来配置你的应用服务。然后，只需要一个简单的命令，就可以创建并启动你配置的所有服务。

### 为什么使用Compose

  在Docker镜像构成和定制介绍中，我们可以使用Dockerfile文件很方便定义一个单独的应用容器。然而，在日常工作中，经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个 Web 项目，除了 Web 服务容器本身，往往还需要再加上后端的数据库服务容器，甚至还包括负载均衡容器等。Compose 恰好满足了这样的需求。它允许用户通过一个单独的 docker-compose.yml 模板文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。

### 安装Compose

  Compose的安装十分容易，只需要以下命令即可：

```
pip install docker-compose

```

为了检测Compose是否安装成功，可以查看Compose的版本信息，如下：

```
$ docker-compose -version
docker-compose version 1.23.2, build 1110ad0

```

### Compose实战

  接下去我们将通过一个具体的项目来展示Compose的使用。项目的结构如下：

![img](http://upload-images.jianshu.io/upload_images/9419034-ec85927abb4027a2.png?imageMogr2/auto-orient/strip|imageView2/2/w/293/format/webp)

项目结构

  对于项目的Python代码，我们不再具体讲述，有兴趣的同学可移步：<https://github.com/percent4/Poem-Search/tree/v1.2> 。
  首先我们先打包一个poem_search镜像，用于前端运行，然后拉取镜像mongo，最后用Compose将两个镜像打包在一起，共同运行。
  打包poem_search镜像涉及到两个文件：poem_search.build及build_poem_search.sh 。其中Dockerfile文件poem_search.build如下：

```
FROM centos:7.5.1804

# 维护者
MAINTAINER jclian91@sina.com

# 安装基础环境
RUN yum clean all \
    && yum makecache \
    && yum update -y \
    && yum groupinstall -y "Development tools" \
    && yum install -y yum-utils \
    && yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel \
    && yum install -y sqlite-devel readline-devel tk-devel gdbm-devel \
    && yum install -y db4-devel libpcap-devel xz-devel \
    && yum install -y wget gcc gcc-c++ automake autoconf libtool make \
        && yum install -y wget gcc gcc-c++ python-devel mysql-devel bzip2 \
    && yum install -y https://centos7.iuscommunity.org/ius-release.rpm \
    && yum install -y python36u \
    && yum install -y python36u-pip \
    && yum install -y python36u-devel \
    && yum clean all

# 安装Python3.6
RUN cd /usr/bin \
    && mv python python_old \
    && ln -s /usr/bin/python3.6 /usr/bin/python \
    && ln -s /usr/bin/pip3.6 /usr/bin/pip \
    && pip install --upgrade pip

#环境变量硬编码及时区
ENV ENVIRONMENT production
RUN cd / && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#安装Python的第三方模块
RUN pip3 install pandas -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com \
    && pip3 install pymongo -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com \
    && pip3 install tornado -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com \
    && pip3 install urllib3 -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com \
    && pip3 install requests -i http://pypi.douban.com/simple/ --trusted-host pypi.douban.com \
    && pip3 install bs4

# 拷贝
COPY ./src /root/poem_search/src

# 工作目录
WORKDIR /root/poem_search/src

# 暴露端口
EXPOSE 8000

# 执行命令
CMD ["python","server.py"]

```

shell脚本build_poem_search.sh的代码如下：

```
tag=$1
# -f 指定文件 ， -t 指定生成镜像名称 ， 冒号后为版本号，最后的.表示docker_file的上下文环境
docker build -f poem_search.build -t hub.docker.com/poem_search:test.${tag} .

```

打包镜像，并将该镜像推送至自己的docker hub，命令如下：

```
./build_poem_search.sh 1111

```

镜像打包完后，将其推送至自己的docker hub,具体的命令可以参考文章：[Docker入门（一）用hello world入门docker](https://blog.csdn.net/jclian91/article/details/86715258) , 如下图：

![img](http://upload-images.jianshu.io/upload_images/9419034-5388b419c4de5c76.png?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

dockhub镜像

接着，拉取MongoDB镜像：

```
docker pull mongo

```

最后，用docker compose将两个镜像组合在一起，其中docker-compose.yml如下：

```
version: "3.3"

# 定义两个服务: poemSearch, mongo
services:
  poemSearch:
    depends_on:
      - mongo
    image: jclian91/poem_search:v1.0_2019.02.20.1745
    container_name: poemSearch
    ports:
      - "8000:8000"
    restart: always
    deploy:
      replicas: 1
    networks:
      - poemSearch

  mongo:
    image: mongo:latest
    container_name: mongo
    deploy:
      replicas: 1
    networks:
      - poemSearch
    ports:
      - "27017:27017"
    volumes:
      - $PWD/db:/data/db
    command: ["mongod"]

#Network
networks:
  poemSearch:

```

关于YAML文件的编写及说明，可以参考网址：<http://blog.51cto.com/wutengfei/2156792> 。
  切换至YAML所在文件夹，输入命令：

```
docker-compose up -d

```

输出的结果如下：

```
Creating mongo ... done
Creating poemSearch ... done

```

这时，在浏览器中输入“<http://localhost:8000/query>”即可运行我们的程序，界面如下：

![img](http://upload-images.jianshu.io/upload_images/9419034-71560d5387c656a4.png?imageMogr2/auto-orient/strip|imageView2/2/w/970/format/webp)

诗歌搜索界面

在其中输入搜索关键词，比如“白云”，则会显示一条随机的结果，如下：

![img](http://upload-images.jianshu.io/upload_images/9419034-6897deb5e02dfcc0.png?imageMogr2/auto-orient/strip|imageView2/2/w/976/format/webp)

诗歌搜索结果

点击“查询词高亮”，则查询词部分会高亮显示。

### 体验Compose

  如果需要体验该项目，则需要以下三个工具：

- git
- docker
- docker-compose

用git下载该项目，命令如下：

```
git init
git clone -b v1.2 https://github.com/percent4/Poem-Search.git

```

然后切换至docker-compose.yml所在路径，运行命令：

```
docker-compose up -d

```

即可运行该项目，然后在浏览器中输入“<http://localhost:8000/query>”即可。如需要停止该项目的运行，则运行命令：

```
docker-compose down
```