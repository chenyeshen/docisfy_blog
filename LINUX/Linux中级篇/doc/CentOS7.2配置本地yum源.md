# CentOS7.2配置本地yum源

## 1、检查是否有本地yum源

### 1)检查是否能连网

```
ping www.baidu.com
```

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163609493.png)

### 2)检查是否有本地yum源

```
yum list
```

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163606096.png)

 

##  2、挂载镜像文件

以上检查，说明确实是内网，也确实没有本地yum源，那我们就需要配置一个本地yum源，去解决某些软件的依赖安装

### 1）查看操作系统

```
cat /etc/redhat-release
```

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163607305.png)

### 2）上传相应的镜像文件至服务器

 ![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163610963.png)

### 3)挂载镜像文件

将刚刚上传的镜像文件挂载到/home/iso/目录下（你可以挂载到自己的目录下，如果是挂载到镜像文件的路径，之前的镜像文件会被删除）

```
cd /home/iso/ 
mount -o loop CentOS-7-x86_64-DVD-1511.iso /home/iso/
```

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163610179.png)

 

 

## 3、配置本地yum源

### 1）备份原yum源配置

```
mv /etc/yum.repos.d /etc/yum.repos.d.bak 
```

### 2）创建本地yum源配置文件

```
mkdir /etc/yum.repos.d
```

```
vi /etc/yum.repos.d/CentOS-local.repo
```

 里面添加内容：

```
#本源的名字（不能和其他重复）
[base-local]
name=CentOS7.2-local


#步骤2中挂载镜像创建的目录
baseurl=file:///home/iso

#启动yum源： 1-启用 0-不启用
enabled=1 

#安全检测：  1-开启 0-不开启
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
```

 

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163611806.png)

 

 

### 3）更新yum源配置

```
yum clean all
yum makecache
```

 

 ![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163612442.png)

 

### 4)测试yum

 

```
yum list
#或者
yum repolis
```

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163607993.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20191113163604800.png)

以上，本地yum源就配置好了