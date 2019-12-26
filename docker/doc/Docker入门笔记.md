# Docker入门

### Docker的目标 - 一次构建，处处运行

1. 提供简单轻量的建模方式，项目docker化非常简单，性能优秀，一台宿主机中可运行更多的容器
2. 职责的逻辑分离，保证开发环境与生产环境一致性，开发人员只关心应用程序，运维人员只关心如何管理容器
3. 快速高效的开发生命周期，缩短代码开发、测试、部署的周期，使用相同的环境，避免环境带来的额外开销
4. 使用面向服务的架构，单个容器只运行一个程序，应用程序或服务都可以表示为一系列内部互联的容器，从而使分布式部署、扩展、调试更容易，高内聚，避免不同服务间的互相影响，方便定位问题

**Docker使用场景**

1. 使用Docker容器开发、测试、部署服务
2. 创建隔离的运行环境
3. 搭建测试环境
4. 构建 平台即服务PaaS基础设施
5. 提供软件即服务SaaS应用程序
6. 高性能、超大规模宿主机部署

## Docker的三要素

**Docker Image镜像**

- 容器的基石，容器基于镜像启动和运行，镜像-类，容器-对象

- 层叠的只读文件系统

- 联合加载（union mount）

- Docker 镜像（Image）就是一个只读的模板。镜像可以用来创建 Docker 容器，一个镜像可以创建很多容器。

  **Docker Container 容器**

- Docker 利用容器（Container）独立运行的一个或一组应用。容器是用镜像创建的运行实例。

- 它可以被启动、开始、停止、删除。每个容器都是相互隔离的、保证安全的平台。

- 可以把容器看做是一个简易版的 Linux 环境（包括root用户权限、进程空间、用户空间和网络空间等）和运行在其中的应用程序。

- 容器的定义和镜像几乎一模一样，也是一堆层的统一视角，唯一区别在于容器的最上面那一层是可读可写的。

**Docker Repository 仓库**

是集中存放镜像文件的场所。
仓库(Repository)和仓库注册服务器（Registry）是有区别的。仓库注册服务器上往往存放着多个仓库，每个仓库中又包含了多个镜像，每个镜像有不同的标签（tag）。

**Docker Registry 注册服务器**

类似于Maven的中央仓库，包含所有官方镜像

## Docker运行原理

Docker是一个Client-Server结构的系统，Docker守护进程运行在主机上， 然后通过Socket连接从客户端访问，守护进程从客户端接受命令并管理运行在主机上的容器。 容器，是一个运行时环境，就是我们前面说到的集装箱。

**为什么Docker比VM快?**

1. docker有着比虚拟机更少的抽象层。由亍docker不需要Hypervisor实现硬件资源虚拟化,运行在docker容器上的程序直接使用的都是实际物理机的硬件资源。因此在CPU、内存利用率上docker将会在效率上有明显优势。
2. docker利用的是宿主机的内核,而不需要Guest OS。因此,当新建一个容器时，docker不需要和虚拟机一样重新加载一个操作系统内核。故避免了**引寻、加载操作系统内核返个比较费时费资源的过程**，当新建一个虚拟机时，虚拟机软件需要加载Guest OS，返个新建过程是分钟级别的。而docker由于直接利用宿主机的操作系统,则省略了返个过程,因此新建一个docker容器只需要几秒钟。

## Docker的安装

[Docker安装-菜鸟教程](https://links.jianshu.com/go?to=https%3A%2F%2Fwww.runoob.com%2Fdocker%2Fubuntu-docker-install.html)

docker 客户端非常简单 ,我们可以直接输入 docker 命令来查看到 Docker 客户端的所有命令选项。

```
runoob@runoob:~# docker

```

可以通过命令 **docker command --help** 更深入的了解指定的 Docker 命令使用方法。

例如我们要查看 **docker stats** 指令的具体使用方法：

```
runoob@runoob:~# docker stats --help

```

[配置阿里云镜像仓库加速服务](https://links.jianshu.com/go?to=https%3A%2F%2Fblog.csdn.net%2Fwohaqiyi%2Farticle%2Fdetails%2F89335932)

## 容器的基本操作

**启动容器**

- docker run IMAGE [COMMAND] [ARG...]

  run 在新容器中执行命令，IMAGE表示启动容器所使用的操作系统镜像，COMMAND表示容器启动后使用的命令，ARG表示参数

  `docker run ubuntu echo "hi tracer"`表示使用最近的ubuntu 系统启动容器，执行echo命令，参数为“hi tracer”。等价于在ubuntu 系统的命令行中输入echo "hi tracer"

  ```
  C:\Users\mao>docker run ubuntu:15.10 echo "hi tracer"
  hi tracer

  ```

  - **docker:** Docker 的二进制执行文件。
  - **run:**与前面的 docker 组合来运行一个容器。
  - **ubuntu:**指定要运行的镜像，Docker首先从本地主机上查找镜像是否存在，如果不存在，Docker 就会从镜像仓库 Docker Hub 下载公共镜像。
  - **/bin/echo "Hello world":** 在启动的容器里执行的命令

**启动交互式容器**

- $ docker run -i -t IMAGE /bin/bash

  -i --interactive==true|false  默认是false，启动交互式容器，允许你对容器内的标准输入 (STDIN) 进行交互。

  -t --tty==true|false 默认是false  在新容器内指定一个伪终端或终端。

  `docker run -i -t ubuntu /bin/bash`   启动ubuntu 系统的命令行窗口

**查看容器**

- $ docker ps 查看正在运行的docker容器   -a表示显示所有容器

  ```
  C:\Users\mao>docker ps
  CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
  11511ff96b4e        ubuntu:15.10        "/bin/sh -c 'while t…"   14 seconds ago      Up 13 seconds                           con1

  ```


- $ docker inspect [CONTAINER-ID|NAME] 查看容器详细信息，参数是容器ID或NAME

  **重启容器**

- docker start -i [CONTAINER-ID|NAME]  启动已经停止的容器，参数是容器ID或NAME

  **删除停止的容器**

- $docker rm [CONTAINER-ID|NAME]  删除已经停止的容器，参数是容器ID或NAME，无法删除运行中的容器

## 守护式容器

**什么是守护式（后台）容器：**

- 能够长期运行
- 没有交互式会话
- 适合运行应用程序和服务

**启动守护式容器：**

- $ docker run -i -t ubuntu /bin/bash
- Ctrl+Q+P  退出不使用exit，就能使容器后台运行


- $ docker run -d IMAGE [COMMAND] [ARG...]  直接启动守护式容器，-d 表示以守护式启动容器

  `docker run --name con1 -d ubuntu /bin/sh -c "while true; do echo hello world; sleep 1; done;"` 启动名称为con1 的ubuntu 镜像，执行shell脚本，内容为死循环输出helloworld，模拟脚本后台一直运行。

**进入守护式容器**

- $ docker attach  [CONTAINER-ID|NAME]  进入守护式容器

  ```
  C:\Users\mao>docker attach 86dae4c6b492
  root@86dae4c6b492:/# exit

  ```

**查看容器日志**

- $ docker logs -f -t --tail n 容器ID/NAME

  -f --follows 跟踪log的变化并返回

  -t --timestamp 日志加上时间戳

  --tail n  返回n行日志，默认为all

`docker logs -ft --tail 10 11511ff96b4e`  查看容器11511ff96b4e的最新的10行日志

```
C:\Users\mao>docker logs -ft --tail 10 11511ff96b4e
2019-09-04T15:22:55.638537200Z hello world
2019-09-04T15:22:56.639011600Z hello world
2019-09-04T15:22:57.639758900Z hello world

```

**查看容器内进程**

- $ docker top 容器ID/NAME

  ```
  C:\Users\mao>docker top 11511ff96b4e
  PID                 USER                TIME                COMMAND
  3288                root                0:00                /bin/sh -c while tru...
  3593                root                0:00                sleep 1

  ```

**在运行容器内启动新进程**

- $ docker exec -d -i -t 容器名 [COMMAND] [ARG...]

  ```
  // 在运行容器11511ff96b4e中启动bash进程
  C:\Users\mao>docker exec -i -t  11511ff96b4e /bin/bash
  root@11511ff96b4e:/#
  // Ctrl+Q退出
  C:\Users\mao>docker top 11511ff96b4e
  PID                 USER                TIME                COMMAND
  3288                root                0:00                /bin/sh -c while t...
  4545                root                0:00                sleep 1
  4450                root                0:00                /bin/bash // 新启动的进程

  ```

**停止守护式容器**

- $ docker stop 容器名，发送一个信号给容器，等待容器停止
- $ docker kill 容器名，直接停止容器

## 镜像

### 什么是镜像？

镜像是一种轻量级、可执行的独立软件包，用来打包软件运行环境和基于运行环境开发的软件，它包含运行某个软件所需的所有内容，包括代码、运行时、库、环境变量和配置文件。

**查看镜像**

- $ docker images [OPTIONS] [REPOSITORY]

  -a --all=false 显示所有镜像

  -f --filter=[]

  -q --quiet=false

```
// 查看所有仓库镜像
C:\Users\mao>docker images
  仓库名            标签名                镜像截断ID          创建时间                大小
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              a2a15febcdf3        3 weeks ago         64.2MB
hello-world         latest              fce289e99eb9        8 months ago        1.84kB
ubuntu              15.10               9b9cb95443b5        3 years ago         137MB
// 查看指定仓库ubuntu镜像
C:\Users\mao>docker images ubuntu
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
ubuntu              latest              a2a15febcdf3        3 weeks ago         64.2MB
ubuntu              15.10               9b9cb95443b5        3 years ago         137MB

```

- REPOSITORY    仓库，一系列类似镜像（IMAGES）的集合，比如ubuntu仓库，包含了很多版本的ubuntu镜像
- REGISTRY    注册表，Docker镜像的存储服务
- TAG    仓库名+标签名唯一指定一个镜像，如ubuntu:15.10。不指定标签默认使用latest

**删除镜像**

- $ docker rmi [OPTIONS] IMAGE [IMAGE...]    删除指定的镜像，尽量使用镜像ID删除，而非仓库名+标签，因为同一个镜像ID会有多个文件

**查找镜像**

- Docker Hub [https://hub.docker.com](https://links.jianshu.com/go?to=https%3A%2F%2Fhub.docker.com%2F)  DockerHub官方仓库查找镜像

- $ docker search [OPTIONS] TERM   使用命令行查找镜像

  --automated=false 是否为自动构建的

  -s  --stars=0  用来限制显示结果的星级

**拉取镜像**

- $ docker pull 镜像名

  `docker pull ubuntu:14.04` 拉取ubuntu:14.04镜像

**构建镜像**

构建镜像有以下作用

- 保存对容器的修改，方便下次使用
- 自定义镜像的能力
- 以软件的形式打包并分发服务及其运行环境


- $ docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]    通过容器构建镜像

​        -a  --author  添加作者信息

​        -m  --messgae  添加镜像信息

- $ docker build  通过Dockerfile文件构建镜像

**推送镜像**

将自己构建的镜像上传到仓库

- $ docker push

## 问题

1. docker直接利用宿主机操作系统的内核，那为什么windows上安装的docker可以启动 ubuntu容器？

答：docker-win其实是安装在虚拟机中的，而虚拟机使用的linux内核。win7 win8操作系统中 docker安装在Oracle virtualBox虚拟机中，win10 docker装在Hyper-V生成的虚拟机中。

1. 为什么Docker容器比虚拟机(VM)快那么多？

答：docker有着比虚拟机更少的抽象层。由亍docker不需要Hypervisor实现硬件资源虚拟化,运行在docker容器上的程序直接使用的都是实际物理机的硬件资源。因此在CPU、内存利用率上docker将会在效率上有明显优势。

​       docker利用的是宿主机的内核,而不需要Guest OS。因此,当新建一个容器时，docker不需要和虚拟机一样重新加载一个操作系统内核。故避免了**引寻、加载操作系统内核返个比较费时费资源的过程**，当新建一个虚拟机时，虚拟机软件需要加载Guest OS，返个新建过程是分钟级别的。而docker由于直接利用宿主机的操作系统,则省略了返个过程,因此新建一个docker容器只需要几秒钟。

## 总计

1. 做笔记还是尽量做原理性，概念性的笔记，多记自己的理解，把**原理**搞清楚，抓住最主要的。这类知识特点是难懂，需要自己去理解体会，重难点，同样是考点。
2. 操作型笔记还是少记，具体使用时可以上网查(如菜鸟教程)，这类知识特点是上手快，容易忘，需要**勤加练习**，记笔记意义不大。
3. 该篇笔记结构不清晰，后面需要根据《尚硅谷_Docker核心技术》继续完善修改。
4. 编程和高中文化课一样，以为自己听懂了，做题时（**上手编程**）才发现没学会，所以一定要多做练习（**多敲代码**），才能查缺补漏，深入理解；做笔记，要记重难点（原理）、考点（面试点），笔记是自己复习用，不是查询手册，所以要精简。
5. 记了笔记一定要利用起来，**勤加复习**，不要想着一劳永逸，温故而知新，对于笔记也要**完善补充**。