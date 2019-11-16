# CentOS7 下 Redis4 安装与配置教程（Redis开机启动）

## 一、前言

### 1、本教程主要内容

- Redis安装与测试
- Redis远程访问配置
- Redis开机启动配置

### 2、本教程环境信息

- CentOS 7
- Redis 4.0.2

## 二、安装步骤

### 1、Redis安装

- 安装基础依赖

```
#安装基础依赖包
sudo yum install -y gcc gcc-c++ make jemalloc-devel epel-release

```

- 下载Redis（ <https://redis.io/download> ）

```
#从官网获取最新版本的下载链接，然后通过wget命令下载
wget http://download.redis.io/releases/redis-4.0.2.tar.gz

```

- 解压到指定目录

```
#创建目录
sudo mkdir /usr/redis
#解压
sudo tar -zvxf redis-4.0.2.tar.gz -C /usr/redis

```

- 编译&安装

```
#进入目录
cd /usr/redis/redis-4.0.2
#编译&安装
sudo make & make install

```

### 2、Redis启动与测试

- 启动redis-server

```
#进入src目录
cd /usr/redis/redis-4.0.2/src
#启动服务端
sudo ./redis-server

```

- 启动redis客户端测试

```
#进入src目录
cd /usr/redis/redis-4.0.2/src
#启动客户端
sudo ./redis-cli

```

> 设置：set key1 value1
> 获取：get key1

## 三、Redis配置

### 1、 配置本机外访问

- 修改配置：绑定本机IP&关闭保护模式

```
#修改配置文件
sudo vi /usr/redis/redis-4.0.2/redis.conf

#更换绑定
#将bind 127.0.0.1 更换为本机IP，例如：192.168.11.11
bind 192.168.11.11

#关闭保护模式
protected-mode no

```

- 开放端口

```
#增加redis端口：6379
sudo firewall-cmd --add-port=6379/tcp --permanent
#重新加载防火墙设置
sudo firewall-cmd --reload

```

- Redis指定配置文件启动

```
#进入目录
cd /usr/redis/redis-4.0.2
#指定配置文件启动
sudo ./src/redis-server redis.conf

```

- Redis客户端连接指定Redis Server

```
#进入目录
cd /usr/redis/redis-4.0.2
#连接指定Redis Server
sudo ./src/redis-cli -h 192.168.11.11

```

### 2、配置Redis开机启动

将Redis配置成为系统服务，以支持开机启动

**创建Redis服务**

**创建服务文件**

```
sudo vi /usr/lib/systemd/system/redis.service
```

**文件内容**

```
[Unit]
Description=Redis Server
After=network.target

[Service]
ExecStart=/usr/redis/redis-4.0.2/src/redis-server /usr/redis/redis-4.0.2/redis.conf --daemonize no
ExecStop=/usr/redis/redis-4.0.2/src/redis-cli -p 6379 shutdown
Restart=always

[Install]
WantedBy=multi-user.target

```

- 设置Redis服务开机启动&开启服务

```
#设置Redis服务开机启动
sudo systemctl enable redis
#启动Redis服务
sudo systemctl start redis
```