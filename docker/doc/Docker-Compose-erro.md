# Error response from daemon: Container is not running 

```
$ sudo docker run -d centos:last
　　8022826ebd567e2b1818e90ce33c3b68ea9aeac0286001154eb05fc2283e0238
$ sudo docker exec -it  8022826ebd56 bash
出现: Error response from daemon: Container 8022826ebd567e2b1818e90ce33c3b68ea9aeac0286001154eb05fc2283e0238 is not running

解决方法:
先进行
sudo docker start 8022826ebd56 
在试试 sudo docker exec -it  8022826ebd56 bash 看一下能不能进入容器
我在试了上面的方法还是进不了用了ping www.baidu.com重新运行一个容器后可以进入
$ sudo docker run -d centos:last ping www.baidu.com
　68f371f3c7c707698183c1a71a7662424cae417e5fc003635c19b19055a3ad32
$ sudo docker ps -l
　　CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
68f371f3c7c7        docker.io/centos    "ping www.baidu.com"         8 seconds ago       Up 7 seconds                            serene_dubinsky

$ sudo docker exec -it  68f371f3c7c7 bash

正常进入
$ sudo docker ps -a
　　CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                      PORTS               NAMES
68f371f3c7c7        docker.io/centos    "ping www.baidu.com"         10 minutes ago      Up 8 minutes                                    serene_dubinsky
8022826ebd56        docker.io/centos    "/bin/bash"         17 minutes ago      Exited (0) 13 minutes ago                       silly_kare

$ sudo docker rm 8022826ebd56
```