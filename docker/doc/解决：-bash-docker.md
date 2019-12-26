# 解决： -bash: docker-compose: command not found、linux 安装 docker-compose

方式1：<https://blog.csdn.net/qq_32447321/article/details/76512137>

方式2：

```
curl -L https://get.daocloud.io/docker/compose/releases/download/1.22.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

方式3：

\1. 运行docker-compose 命令报错：

-bash: docker-compose: command not found
2.安装：

1）先安装 pip ，检查是否已有： pip -V 

报错：

-bash: pip: command not found
安装  pip ：

yum -y install epel-release
yum -y install python-pip
\#升级
pip install --upgrade pip
2) 安装Docker-Compose：

pip install docker-compose
检查是是否成功：

docker-compose -version

OK 了。

1. 运行docker-compose 命令报错：

-bash: docker-compose: command not found
2.安装：

1）先安装 pip ，检查是否已有：

```
 pip -V 
```

报错：

```
-bash: pip: command not found
```



### 安装  pip ：

```
yum -y install epel-release
```

```
yum -y install python-pip
```



###升级
```
pip install --upgrade pip
```


2) 安装Docker-Compose：

pip install docker-compose

检查是是否成功：

docker-compose -version

