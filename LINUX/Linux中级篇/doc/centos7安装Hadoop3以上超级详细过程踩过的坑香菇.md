# centos7.6安装Hadoop3.0以上超级详细过程踩过的坑香菇

## 修改hostname文件

```
[root@hadoophost sbin]# vi /etc/sysconfig/network
# Created by anaconda
NETWORKING=yes
HOSTNAME=hadoophost

```

## 修改hosts文件

```
[root@hadoophost sbin]# vi /etc/hosts
127.0.0.1  localhost localhost.localdomain localhost4 localhost4.localdomain4
::1  localhost localhost.localdomain localhost4 localhost6.localdomain6
192.168.150.130 hadoophost

```

### **重启系统hosts生效**

```
[root@hadoophost]# reboot
```



## 配置ssh免密码登陆配置

### 1.查看.ssh文件

```
[root@localhost ~]# cd ~
[root@localhost ~]# ls -al
总用量 40
dr-xr-x---.  4 root root  181 11月 12 09:59 .
dr-xr-xr-x. 17 root root  240 11月  2 01:43 ..
-rw-------.  1 root root 1241 11月  1 14:04 anaconda-ks.cfg
-rw-------.  1 root root 9348 11月 12 12:13 .bash_history
-rw-r--r--.  1 root root   18 12月 29 2013 .bash_logout
-rw-r--r--.  1 root root  176 12月 29 2013 .bash_profile
-rw-r--r--.  1 root root  176 12月 29 2013 .bashrc
-rw-r--r--.  1 root root  100 12月 29 2013 .cshrc
-rw-------.  1 root root 1050 11月 12 01:51 .mysql_history
drwxr-----.  3 root root   19 11月  1 16:57 .pki
drwx------.  2 root root   80 11月 12 12:29 .ssh
-rw-r--r--.  1 root root  129 12月 29 2013 .tcshrc
[root@localhost ~]# 
```



![](https://i.loli.net/2019/11/12/T3tO7rkpAUu6f9W.png)

### 2. 进入.ssh目录下

```
[root@localhost ~]# cd .ssh/
[root@localhost .ssh]# ls
known_hosts

```

![](https://i.loli.net/2019/11/12/BkZp9KYszOgAhxj.png)

### 3.ssh生成秘钥

```
[root@localhost .ssh]# ssh-keygen -t rsa
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): 
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /root/.ssh/id_rsa.
Your public key has been saved in /root/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:e2BG+ixGotwMDUdIHZX7TNGQ0nG8/v7eqJH/rRh2gOQ root@localhost
The key's randomart image is:
+---[RSA 2048]----+
| ..ooo.oo*.      |
|  ... o +.o      |
|  . .  o....     |
|   +  .o.o..     |
|  . o o+S.E .    |
| . = o =oo.  o   |
|  o o o + ..= .  |
|     . . . ..* o.|
|           .++*o+|
+----[SHA256]-----+
[root@localhost .ssh]# ^C
[root@localhost .ssh]# 

```

![](https://i.loli.net/2019/11/12/xwAquaDIRzQjHnC.png)

### 4.复制公钥

```
[root@localhost .ssh]# cp  id_rsa.pub  authorized_keys
```

![](https://i.loli.net/2019/11/12/KUuOpc1VWdMZBsf.png)

### 5.ssh登录本地测试成功

```
[root@localhost .ssh]# ssh localhost
Last login: Tue Nov 12 12:30:30 2019 from localhost
[root@localhost ~]# 

```

**搭建jdk1.8环境这里就不详细讲解**



## Hadoop详细步骤

- **下载地址：**<http://hadoop.apache.org/>
- **Hadoop 安装地址：**/usr/local/hadoop/hadoop-3.2.0

```
# 解压 Hadoop 到指定文件夹
tar -zxf hadoop-3.2.0.tar.gz -C /usr/local/hadoop

```

```
# 查看 Hadoop 版本信息
cd /usr/hadoop/local/hadoop-3.2.0 
./bin/hadoop version

```

###  1) 设置环境变量

```
vi /etc/profile
```

```
# set hadoop path
export HADOOP_HOME=/usr/hadoop/hadoop-3.2.0
export PATH=$PATH:$HADOOP_HOME/bin
export PATH
```

```
# 使环境变量生效
source /etc/profile

# CentOS版本用
source ~/.bash_profile

```

###  2) 修改目录hadoop/etc/hadoop下 Hadoop 配置文件

**配置以下 5 个文件：**

```
hadoop-3.2.0/etc/hadoop/hadoop-env.sh
hadoop-3.2.0/etc/hadoop/core-site.xml
hadoop-3.2.0/etc/hadoop/hdfs-site.xml
hadoop-3.2.0/etc/hadoop/mapred-site.xml
hadoop-3.2.0/etc/hadoop/yarn-site.xml

```

####  **hadoop-env.sh**

```
# The java implementation to use.

#export JAVA_HOME=${JAVA_HOME}
export JAVA_HOME=/usr/java/jdk1.8.0_152

```

####  **core-site.xml**

```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
<property>
    <name>fs.defaultFS</name>
    <value>hdfs://hadoophost:9000</value>
</property>

<property>
    <name>hadoop.tmp.dir</name>
    <value>/usr/local/hadoop/tmp</value>
</property>

</configuration>

```

#### **hdfs-site.xml**

```
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
 <property>
   <name>dfs.replication</name>
   <value>1</value>
   </property>
   
   <property>
  <name>dfs.http.address</name>
  <value>hadoophost:9870</value>
  </property>
  
</configuration>

```

####  **mapred-site.xml**

```
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
</configuration>

```

####  **yarn-site.xml**

```
<?xml version="1.0"?>

<configuration>
<property>
        <name>yarn.resourcemanager.hostname</name>
        <value>hadoophost</value>
    </property>
<property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
</property>
</configuration>

```



### 3)修改配置用户：

**目录hadoop/sbin下的start-dfs.sh、stop-dfs.sh开头添加下内容**

```
HDFS_DATANODE_USER=root  
HDFS_DATANODE_SECURE_USER=hdfs  
HDFS_NAMENODE_USER=root  
HDFS_SECONDARYNAMENODE_USER=root

```

**目录hadoop/sbin下的start-yarn.sh、stop-yarn.sh开头添加一下内容**

```
YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=yarn
YARN_NODEMANAGER_USER=root

```



###  4) 格式化 HDFS  在hadoop/bin/

```
[root@localhost]# hdfs namenode -format
```

   格式化是对 HDFS这个分布式文件系统中的 DataNode 进行分块，统计所有分块后的初始元数据的存储在namenode中。（如果服务器再次启动，也需要进行这步，否则启动可能会失败）

### 5) sbin下启动 HDFS

```
[root@localhost]#  ./start-all.sh
```



### 6) 查看hadoop文件系统的文件

```
[root@localhost]#  hadoop fs  -ls  /
```

![](https://i.loli.net/2019/11/13/UP3a91N5jDMqgEI.png)



### 8) 访问9870端口查看是否成功

![](https://i.loli.net/2019/11/13/Hdup4RWQMrGlJcU.png)