# Linux下彻底卸载MySQL

​    说起Linux下卸载MySQL最让人头疼，卸载不干净，会影响下一次的安装，本人最近就遇到了这个问题，下面就是我对这个问题的解决方法。

​    首先介绍一下本人的环境，本人使用的是CentOS6.5系统，MySQL使用的是5.5版本。

### 一、查看MySQL的安装情况

​    使用以下命令查看当前安装mysql情况，查找以前是否装有mysql。

```
rpm -qa|grep -i mysql

MySQL-client-5.5.25a-1.rhel5
MySQL-server-5.5.25a-1.rhel5
```

​    如果之前安装了MySQL，那么会出现如上的显示。

### 二、卸载MySQL

#### 1、停止服务

​    卸载MySQL之前，需要停止mysql服务。使用如下命令进行停止服务：

```
service mysql stop
```

#### 2、卸载MySQL

​    卸载之前安装的mysql，卸载命令如下：

```
rpm -ev MySQL-client-5.5.25a-1.rhel5
rpm -ev MySQL-server-5.5.25a-1.rhel5
```

​    如果提示依赖包错误，则使用以下命令尝试:

```
rpm -ev MySQL-client-5.5.25a-1.rhel5 --nodeps
```

​    如果提示错误：error: %preun(xxxxxx) scriptlet failed, exit status 1

​    则用以下命令尝试：

```
rpm -e --noscripts MySQL-client-5.5.25a-1.rhel5
```

### 三、删除MySQL目录

#### 1、查看目录

​    查找之前安装mysql使用的目录，命令及结果如下：

```
find / -name mysql

/var/lib/mysql
/var/lib/mysql/mysql
/usr/lib64/mysql
```

​    本人这里有三个目录为MySQL使用的目录。

#### 2、删除目录

​    删除对应的mysql目录，命令如下：

```
rm -rf /var/lib/mysql
rm -rf /var/lib/mysql
rm -rf /usr/lib64/mysql
```

​    这里删除的目录是上面查找到的目录，上面查找到的所有目录都要删除。

#### 3、删除文件

​    卸载后/etc/my.cnf不会删除，需要进行手工删除，命令如下：

```
rm -rf /etc/my.cnf
```

### 四、检查卸载

​    最后再次使用rpm命令进行查看是否安装mysql，命令如下。

```
rpm -qa|grep -i mysql
```

​    使用完次命令如果没有结果，说明已经卸载彻底，接下来直接安装mysql即可。

​    如果有，则按照上述步骤重复进行即可。