# 使用root配置的hadoop并启动会出现报错



### 1、使用root配置的hadoop并启动会出现报错

错误：

​        Starting namenodes on [master]

​        ERROR: Attempting to operate on hdfs namenode as root
​        ERROR: but there is no HDFS_NAMENODE_USER defined. Aborting operation.
​        Starting datanodes

​        ERROR: Attempting to operate on hdfs datanode as root
​        ERROR: but there is no HDFS_DATANODE_USER defined. Aborting operation.

​        Starting secondary namenodes [slave1]

​        ERROR: Attempting to operate on hdfs secondarynamenode as root

​        ERROR: but there is no HDFS_SECONDARYNAMENODE_USER defined. Aborting operation.

解决方法：

​         **在/hadoop/sbin路径下：**
​         将start-dfs.sh，stop-dfs.sh两个文件顶部添加以下参数

```
HDFS_DATANODE_USER=root
HADOOP_SECURE_DN_USER=hdfs
HDFS_NAMENODE_USER=root
HDFS_SECONDARYNAMENODE_USER=root

```

​          
​         start-yarn.sh，stop-yarn.sh顶部也需添加以下
​        

```
YARN_RESOURCEMANAGER_USER=root
HADOOP_SECURE_DN_USER=yarn
YARN_NODEMANAGER_USER=root

```

​    

### 2、添加1后出现以下错误

WARNING: HADOOP_SECURE_DN_USER has been replaced by HDFS_DATANODE_SECURE_USER. Using value of HADOOP_SECURE_DN_USER.
Starting namenodes on [mylinux_1]
mylinux_1: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
Starting datanodes
localhost: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
Starting secondary namenodes [mylinux_1]
mylinux_1: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).
2018-11-26 09:32:18,082 WARN util.NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Starting resourcemanager
Starting nodemanagers
localhost: Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).

### 解决办法：配置免密登录（注意：对本机也需要配置）

```
ssh-keygen -t rsa

ssh-copy-id -i ~/.ssh/id_rsa.pub root@MyLinux_1
```

