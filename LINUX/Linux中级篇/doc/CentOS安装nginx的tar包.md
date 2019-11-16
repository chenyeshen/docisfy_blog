# CentOS安装nginx的tar包

### **1.依赖项和必要组件**

```
yum install -y make cmake gcc gcc-c++  

yum install -y pcre pcre-devel

yum install -y zlib zlib-devel

yum install -y openssl openssl-devel
```

### **2.下载安装nginx**

```
wget http://nginx.org/download/nginx-1.12.2.tar.gz
```

  * 可以根据需要下载不同版本。官网：<http://nginx.org/en/download.html>



### **3.解压**

```
tar zxvf nginx-1.12.2.tar.gz && cd nginx-1.12.2
```

 

### **4.nginx-1.12.2目录下编译配置**  

```
./configure && make && make install
```

　执行完本命令将会在 /usr/local/nginx 生成相应的可执行文件、配置、默认站点等文件

 ![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191031224625.png)

### **5.创建全局命令**

```
ln -s /usr/local/nginx/sbin/nginx /usr/bin/nginx   
```

### 6.常用命令：

启动：nginx

重载加载配置：nginx -s reload

关闭nginx：nginx  -s  stop

### 7.检测防火墙状态

```
service  iptables status
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191031230603.png)

### 8.关闭防火墙

```
service iptables stop
```

### 9.访问nginx

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191031230802.png)

