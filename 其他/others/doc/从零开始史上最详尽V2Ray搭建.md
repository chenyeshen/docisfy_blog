# 从零开始：centos7上V2Ray搭建

## **1.安装wget**

digitalocean默认没有安装wget，我们需要自己安装，执行如下命令进行安装：

```
yum -y install wget
```

## **2.下载脚本**

安装完wget之后就可以进行下载操作了，如下：

```
wget https://install.direct/go.sh
```

## **3.安装unzip**

因为centos不支持apt-get，我们需要安装unzip，详见[官方说明](https://www.v2ray.com/chapter_00/install.html)：

```
yum install -y zip unzip  
```

## **4.执行安装**

```
bash go.sh
```

## **5.相关命令**

在首次安装完成之后，V2Ray不会自动启动，需要手动运行上述启动命令。而在已经运行V2Ray的VPS上再次执行安装脚本，安装脚本会自动停止V2Ray 进程，升级V2Ray程序，然后自动运行V2Ray。在升级过程中，配置文件不会被修改。

```
## 启动
systemctl start v2ray

## 停止
systemctl stop v2ray

## 重启
systemctl restart v2ray

## 开机自启
systemctl enable v2ray
```

关于软件更新：更新 V2Ray 的方法是再次执行安装脚本！再次执行安装脚本！再次执行安装脚本！

## **6.配置**

如果你按照上面的命令执行安装完成之后，服务端其实是不需要再进行任何配置的，配置文件位于`/etc/v2ray/config.json`，使用`cat /etc/v2ray/config.json`查看配置信息。接下来进行客户端配置就行了。

![](https://i.loli.net/2019/11/14/QoctYwDBdUXpZzk.png)





**说明：**

- 配置文件中的id、端口、alterId需要和客户端的配置保持一致；
- 服务端使用脚本安装成功之后默认就是vmess协议；

配置完成之后重启v2ray。

## **7.防火墙开放端口**

有的vps端口默认不开放，可能导致连接不成功，如果有这种情况，详细配置，见[CentOs开放端口的方法—二、firewalld](https://www.4spaces.org/centos-open-porter/)。

```
## 查看已开放端口
firewall-cmd --zone=public --list-ports

## 添加开放端口
firewall-cmd --zone=public --add-port=80/tcp --permanent

```

## 8.Windows 客户端

**1.下载**

1)下载【[v2ray-windows-64.zip Github Release](https://github.com/v2ray/v2ray-core/releases)】;
2)下载【[v2rayN-v2rayN.exe-Github Release](https://github.com/2dust/v2rayN/releases)】；

对`v2ray-windows-64.zip`进行解压，然后将下载的`V2RayN.exe`复制到解压后的目录，即两个下载好的文件需要在同一目录。



**2.配置**

运行V2RayN.exe，然后进行配置。

客户端的配置需要根据你的服务端进行相应的配置，因为你的服务端协议可能是vmess,shadowsocks等。

如果你的服务端配置是协议vmess

![](https://i.loli.net/2019/11/14/g9EWh8BblOQqRyD.png)



## 9.测试

打开浏览器，访问`www.google.com`，