# Docker入门（镜像、容器、仓库）

> 本文主要整理了Docker的三个重要概念以及对应的操作：镜像、容器、仓库。

## 镜像

> 镜像是Docker运行容器的前提

### 获取镜像

```
docker pull NAME[:TAG] // 不指定TAG，默认选择latest标签

```

### 运行镜像

```
docekr run -t -i ubuntu /bin/bash

```

### 查看镜像信息

```
docker images

```

- 添加镜像标签

```
docker tag ubuntu:latest my/ubuntu:latest

```

- 查看镜像详细信息

```
docker inspect 镜像id
docker inspect -f {{".Architecture"}} id  // 查询某一项内容

```

### 搜寻镜像

```
docker search TERM
--automated=false 仅展示自动创建的镜像
--no-trunc=false 输出信息不截断显示
-s=0 仅显示评价为指定星级以上的镜像

```

### 删除镜像

```
docker rmi IMAGE[IMAGE...]  其中IMAGE可以为标签或者id


```

- 删除正在运行的镜像

```
docker rmi -f ubuntu 强制删除（不建议）
推荐：1. 删除容器；2. 再用id删除镜像
docker rm id  
docker rmi ubuntu 

```

### 创建镜像

- 基于已有镜像创建

```
docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
选项包括：
-a,--author="" 作者信息
-m,--message="" 提交信息
-p,--pause=true 提交时暂停容器运行

```

下面是一个展示：

```
$ winpty docker run -ti ubuntu bash
root@39b31ce63c14:/# touch test
root@39b31ce63c14:/# exit
# 查看容器id
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
39b31ce63c14        ubuntu              "bash"              12 minutes ago      Exited (0) 11 minutes ago                       friendly_chebyshev

$ docker commit -m "added a new file" -a "coderluo" 39b test:coderluo
sha256:489150941c65c552268ddacd10d9fe05c01e30c8c3bd111e4217d727e8f724c4



```

- 基于本地模板导入

可以直接从一个操作系统模板文件导入一个镜像，推荐使用OpenVZ提供的模板来创建。下载地址为：

[https://wiki.openvz.org/Download/template/precreated](https://links.jianshu.com/go?to=https%3A%2F%2Fwiki.openvz.org%2FDownload%2Ftemplate%2Fprecreated)

比如我下载了一个ubuntu，可以使用如下命令导入：

```
[root@izwz909ewdz83smewux7a7z ~]# cat ubuntu-14.04-x86_64-minimal.tar.gz |docker import - ubuntu:14.04
sha256:57a7c0bb864c4185d5d9d6eb6af24820595482b9df956adec5fde8d16aa9cb7c
[root@izwz909ewdz83smewux7a7z ~]# docker images

```

- 基于Dockerfile创建

### 存出和载入镜像

> 可以使用 docker save 和 docker load 命令来存出和载入镜像

#### 存出镜像

```
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
myubuntu            coderluo            489150941c65        About an hour ago   64.2MB
ubuntu              latest              a2a15febcdf3        43 hours ago        64.2MB
ubuntu              14.04               271ca7812183        3 months ago        188MB
chong@L MINGW64 ~
$ docker save -o myubuntu_14.04.tar myubuntu:coderluo


```

#### 载入镜像

```
chong@L MINGW64 ~
$ docker load < myubuntu_14.04.tar

```

### 上传镜像

```
docker push NAME[:TAG]

```

------

## 容器

> 容器就是镜像的一个运行实例,它带有额外的可写文件层

### 创建容器

#### 新建容器

使用 docker create 创建容器后市处于停止状态,可以使用 docker start 启动

```
docker create -it ubuntu:latest

```

#### 新建并启动容器

```
root@ubuntu_server:/home/coderluo# docker run ubuntu /bin/echo 'i am coderluo'
i am coderluo

```

等价于先 docker create 然后 docker start命令

docker run 需要执行的动作:

1. 检查本地是否有对应的镜像,不存在就从共有仓库下载;
2. 利用镜像创建并启动一个容器;
3. 分配一个文件系统,并在只读的镜像层外面挂载一层可读写层;
4. 从宿主机配置的网桥接口中桥接一个虚拟接口到容器中；
5. 分配一个ip给容器；
6. 执行用户指定的应用程序；
7. 执行完毕后容器关闭；

接下来，我们打开一个bash终端，允许用户交互：

```
docker run -ti ubuntu bash

```

**-t ：** 选项让Docker分配一个伪终端并绑定到容器的标准输入

**-i ：** 让容器的标准输入保持打开

**使用 exit 可以退出容器，退出后该容器就处于终止状态，因为对应Docker容器来说，当运行的应用退出后，容器也就没有运行的必要了；**

#### 守护态运行

比较常见的是需要Docker容器在后台以守护态 形式运行。 可以通过添加 **-d** 参数来实现：

```
$ docker run -d ubuntu sh -c "while true; do echo hello world; sleep 1; done"
caedc06b26723ec1aff794a053835d2b0b603702bea8a5bb3a39e97b0adf5654

$ docker logs cae
hello world
hello world
hello world
hello world
hello world
hello world

```

### 终止容器

```
docker stop [-t|--time[=10]]

```

它首先会向容器发送SIGTERM信号，等待一段时间后（默认10s）。再发送SIGKILL信号终止容器。

注意： docker kill 会直接发送SIGKILL 来强行终止容器。

```
$ docker stop cae
cae


```

当Docker容器中运行的应用终结时，容器也自动终止。例如上面开启的终端容器，通过exit退出终端后，创建的容器也会终止。

可以使用 `docekr ps -a -q` 所有状态的容器ID信息。

```
$ docker ps -a -q
90bcf718ad13
caedc06b2672
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
caedc06b2672        ubuntu              "sh -c 'while true; …"   17 minutes ago      Up About a minute                       epic_swartz
$ docker restart cae
cae
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
caedc06b2672        ubuntu              "sh -c 'while true; …"   18 minutes ago      Up 8 seconds                            epic_swartz


```

### 进入容器

当容器后台启动，用户无法进入容器中，如果需要进入容器进行操作，则可以使用下面方法：

#### attach命令

```
$ docker run -idt ubuntu
b9953944f4cc4a17d09bba846d40eea25523098d188d44484f814132e3a04ae7
$ docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
b9953944f4cc        ubuntu              "/bin/bash"         7 seconds ago       Up 5 seconds                            laughing_chatterjee
$ docker attach laughing_chatterjee
root@b9953944f4cc:/# 

```

缺点：当多个窗口同时attach到同一个容器中，所有窗口同步显示，一个阻塞则全部阻塞。

#### exec

Docker 1.3 版本起引入一个可以直接在容器内执行命令的工具 exec。

进入之前创建的容器，并启动一个bash：

```
$ docker exec -ti b99 bash
root@b9953944f4cc:/#


```

#### nsenter

第三方支持，感兴趣可以自己google，个人感觉和exec差不多

### 删除容器

`docker rm [OPTIONS] CONTAINER [CONTAINER...]`

- -f，--force=false 强行终止并删除一个运行中的容器
- -l，--link=false 删除容器的连接，但保留容器
- -v，--volumes=false 删除容器挂载的数据卷

```
$ docker rm 90b
90b

$ docker rm b99
Error response from daemon: You cannot remove a running container b9953944f4cc4a17d09bba846d40eea25523098d188d44484f814132e3a04ae7. Stop the container before attemptin
g removal or force remove

chong@L MINGW64 ~
$ docker rm -f b99
b99



```

### 导入和导出容器

#### 导出容器

```
docker export CONTAINER

```

```
docker export cae > test_for_run.tar

```

可以将导出的文件传输到其他机器上，直接通过导入命令实现容器迁移。

#### 导入容器

导出的文件可以使用 docker import 命令导入，成为镜像。

```
$ cat Desktop/test_for_run.tar | docker import - test/ubuntu:v1.0                                                       sha256:aa9dd6a88eb02d192c0574e1e2df171d0ec686a21048cba9a70fcd9ce3ba7d76
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
test/ubuntu         v1.0                aa9dd6a88eb0        11 seconds ago      64.2MB

```

这里和前面镜像模块的 docker load 载入镜像的区别是：

docker import 用来导入一个容器快照到本地镜像库，会丢弃所有的历史记录和元数据信息（即仅保存容器当时的快照状态），而 docker load 命令载入镜像文件会保存完成的记录，体积也要大。而且容器快照导入可以重新制定标签等元数据信息。

## 仓库

> 仓库是集中存放镜像的地方

很多人容易搞混仓库和注册服务器。这里说明下，注册服务器和仓库的区别。

注册服务器是存放仓库的地方，每个服务器上可以有多个仓库，而每个仓库下面有多个镜像，比如ubuntu是一个仓库，下面有很多不同版本的镜像。他所在的服务器就是注册服务器。

### 创建和使用私有仓库

#### 使用registry镜像创建私有仓库

可以使用官方提供的registry 镜像 简单搭建一套本地私有仓库环境：

```
docker run -d -p 5000:5000 -v /opt/data/registry:/var/lib/registry registry

```

参数说明：

- -d，后台运行
- -p，端口映射
- -v，将宿主机的/opt/data/registry 绑定到 /var/lib/registry, 来实现数据存放到本地路径，默认registry容器中存放镜像文件的目录/var/lib/registry

运行后测试下我们私有仓库中的所有镜像：

```
$ curl http://仓库宿主机ip:5000/v2/_catalog
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    20  100    20    0     0     20      0  0:00:01 --:--:--  0:00:01   160{"repositories":[]}


```

现在是空的，因为才刚运行，里面没有任何镜像内容。

#### 管理私有仓库镜像

在一台测试机上（非仓库机）查看已有镜像，如果当前没有镜像 使用 docker pull 下载即可；

1. 为镜像打标签

   格式为： `docker tag IMAGE[:TAG] [REGISTRYHOST/] [USERNAME/] NAME[:TAG]`

```
docker tag ubuntu:latest 192.168.137.200:5000/ubuntu:v1
$ docker images
REPOSITORY                    TAG                 IMAGE ID            CREATED             SIZE
192.168.137.200:5000/ubuntu   v1                  a2a15febcdf3        3 days ago          64.2MB


```

192.168.137.200:5000 为私有镜像注册服务器的地址和端口

1. 上传到镜像服务器

```
$ docker push 192.168.137.200:5000/ubuntu
The push refers to repository [192.168.137.200:5000/ubuntu]
122be11ab4a2: Pushed
7beb13bce073: Pushed
f7eae43028b3: Pushed
6cebf3abed5f: Pushed
v1: digest: sha256:ca013ac5c09f9a9f6db8370c1b759a29fe997d64d6591e9a75b71748858f7da0 size: 1152
$ curl http://192.168.137.200:5000/v2/_catalog
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    28  100    28    0     0     28      0  0:00:01 --:--:--  0:00:01   198{"repositories":["ubuntu"]}



```

如上curl命令发现已经可以看到仓库中的镜像了。

1. 测试下载镜像

```
$ docker rmi -f 镜像id  # 删除本地镜像
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE

$ docker pull 192.168.137.200:5000/ubuntu:v1 #下载私有仓库镜像
v1: Pulling from ubuntu
35c102085707: Pull complete
251f5509d51d: Pull complete
8e829fe70a46: Pull complete
6001e1789921: Pull complete
Digest: sha256:ca013ac5c09f9a9f6db8370c1b759a29fe997d64d6591e9a75b71748858f7da0
Status: Downloaded newer image for 39.108.186.135:5000/ubuntu:v1
$ docker images # 查看本地镜像
REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
192.168.137.200:5000/ubuntu   v1                  a2a15febcdf3        3 days ago          64.2MB



```

列出所有镜像：

```
$ curl 39.108.186.135:5000/v2/_catalog
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    28  100    28    0     0     28      0  0:00:01 --:--:--  0:00:01   254{"repositories":["ubuntu"]}


```

某个镜像仓库中的所有tag：

```
$ curl http://39.108.186.135:5000/v2/ubuntu/tags/list
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100    32  100    32    0     0     32      0  0:00:01 --:--:--  0:00:01   128{"name":"ubuntu","tags":["v1"]}


```

> 至此,Docker入门主要讲解了镜像,容器,仓库这三个最基本的概念以及相关操作,这是学习Docker的基础,后续我们会进行更深入的学习。