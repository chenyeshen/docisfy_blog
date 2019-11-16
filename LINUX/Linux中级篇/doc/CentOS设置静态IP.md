# CentOS 设置静态IP

## 一、前言

### 本教程适用的系统版本

- CentOS 6
- CentOS 7

## 二、操作步骤

### 1、确认网卡配置文件

- 查看网络连接信息

```
[root@centos7 ~]# ifconfig -a
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 192.168.1.103  netmask 255.255.255.0  broadcast 192.168.1.255
        inet6 fe80::232f:3f29:c029:a253  prefixlen 64  scopeid 0x20<link>
        ether 00:0c:29:81:11:2b  txqueuelen 1000  (Ethernet)
        RX packets 91  bytes 9778 (9.5 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 84  bytes 11762 (11.4 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 0  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

```

输出的第一行信息说明，网卡设备名是：`eth0`
那么网卡配置文件就是：`/etc/sysconfig/network-scripts/ifcfg-eth0`

### 2、修改网卡配置文件

- 修改网卡配置文件

```
#修改配置文件
vi /etc/sysconfig/network-scripts/ifcfg-eth0

```

- 修改以下配置

```
#将BOOTPROTO由dhcp改为static
BOOTPROTO=static

```

- 增加以下配置

```
IPADDR=192.168.11.100 #静态IP  
GATEWAY=192.168.11.1 #默认网关  
NETMASK=255.255.255.0 #子网掩码  
DNS1=114.114.114.114 #DNS 配置

```

### 3、重启网络服务并验证

- 重启网络服务

```
#CentOS6
service network restart 

#CentOS7
systemctl restart network

```

- 查看IP

```
ifconfig
```