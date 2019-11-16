### Centos 7 firewall 命令：

##### 查看已经开放的端口：

```
firewall-cmd --list-ports
```

##### 开启端口

```
firewall-cmd --zone=public --add-port=80/tcp --permanent
```

##### 命令含义：

–zone #作用域

–add-port=80/tcp #添加端口，格式为：端口/通讯协议

–permanent #永久生效，没有此参数重启后失效

##### 重启防火墙

```
firewall-cmd --reload #重启firewall systemctl stop firewalld.service #停止firewall systemctl disable firewalld.service #禁止firewall开机启动
firewall-cmd --state #查看默认防火墙状态（关闭后显示notrunning，开启后显示running）
```



### 设置Redis服务开机启动&开启服

```
设置Redis服务开机启动

sudo systemctl enable redis

启动Redis服务

sudo systemctl start redis
```

### 创建全局命令

```
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx   
```

### 安装基础依赖

```
#安装基础依赖包
sudo yum install -y gcc gcc-c++ make jemalloc-devel epel-release

```

- 下载Redis（ <https://redis.io/download> ）

```
#从官网获取最新版本的下载链接，然后通过wget命令下载
wget http://download.redis.io/releases/redis-4.0.2.tar.gz

```

- 编译&安装

```
#进入目录
cd /usr/redis/redis-4.0.2
#编译&安装
sudo make & make install

```

