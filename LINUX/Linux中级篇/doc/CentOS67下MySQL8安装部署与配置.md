# CentOS 6/7 下MySQL 8.0 安装部署与配置

## 一、前言

### 1、本教程主要内容

- MySQL 8.0安装(yum)
- MySQL 8.0 基础适用于配置
- MySQL shell管理常用语法示例（用户、权限等）
- MySQL字符编码配置

### 2、本教程环境信息与适用范围

- 环境信息

| 软件     | 版本          |
| ------ | ----------- |
| CentOS | 7.4 Release |
| MySQL  | 8.0.11      |

- 适用范围

| 软件     | 版本                  |
| ------ | ------------------- |
| CentOS | CentOS 6 & CentOS 7 |
| MySQL  | 8.0.x               |

## 二、安装

### 1、添加包

```
#CentOS 7
cd /home/downloads
wget https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
sudo rpm -ivh mysql80-community-release-el7-1.noarch.rpm

#CentOS 6
cd /home/downloads
wget https://dev.mysql.com/get/mysql80-community-release-el6-1.noarch.rpm
sudo rpm -ivh mysql80-community-release-el6-1.noarch.rpm

```

### 2、安装

```
#安装
sudo yum install -y  mysql-community-server

#启动服务
sudo systemctl start mysqld

#查看版本信息
mysql -V

```

### 3、root账号密码修改

```
#1、查看MySQL为Root账号生成的临时密码
grep "A temporary password" /var/log/mysqld.log

#2、进入MySQL shell
mysql -u root -p

#3、修改密码
ALTER USER 'root'@'localhost' IDENTIFIED BY 'Mypwd123!';

```

### 4、开放端口

```
#CentOS 7
#开放端口
firewall-cmd --add-port=3306/tcp --permanent

#重新加载防火墙设置
firewall-cmd --reload

#CentOS 6
iptables -I INPUT -p tcp --dport 3306 -j ACCEPT

iptables save

```

## 三、MySQL安全设置

### 1、MySQL 8 安全设置介绍

MySQL 8 新增了安全设置向导，这对于在服务器部署MySQL来说，简化了安全设置的操作，非常棒。

安全设置大致分为以下几个步骤/选项

1. 密码强度验证插件
2. 修改root账号密码
3. 移除匿名用户
4. 禁用root账户远程登录
5. 移除测试数据库（test）
6. 重新加载授权表

以上几个步骤/选项根据自己需要来即可。

### 2、MySQL 8 安全设置示例

- 进入安全设置

```
mysql_secure_installation

```

-设置示例

```
Securing the MySQL server deployment.

Enter password for user root: 

The existing password for the user account root has expired. Please set a new password.

New password: 

Re-enter new password: 

VALIDATE PASSWORD PLUGIN can be used to test passwords
and improve security. It checks the strength of password
and allows the users to set only those passwords which are
secure enough. Would you like to setup VALIDATE PASSWORD plugin?

Press y|Y for Yes, any other key for No: N
Using existing password for root.
Change the password for root ? ((Press y|Y for Yes, any other key for No) : Y

New password: 

Re-enter new password: 
By default, a MySQL installation has an anonymous user,
allowing anyone to log into MySQL without having to have
a user account created for them. This is intended only for
testing, and to make the installation go a bit smoother.
You should remove them before moving into a production
environment.

Remove anonymous users? (Press y|Y for Yes, any other key for No) : 

 ... skipping.


Normally, root should only be allowed to connect from
'localhost'. This ensures that someone cannot guess at
the root password from the network.

Disallow root login remotely? (Press y|Y for Yes, any other key for No) : N

 ... skipping.
By default, MySQL comes with a database named 'test' that
anyone can access. This is also intended only for testing,
and should be removed before moving into a production
environment.


Remove test database and access to it? (Press y|Y for Yes, any other key for No) : N

 ... skipping.
Reloading the privilege tables will ensure that all changes
made so far will take effect immediately.

Reload privilege tables now? (Press y|Y for Yes, any other key for No) : Y
Success.

All done!

```

## 四、MySQL shell管理语法示例

### 1、数据库相关语法示例

```
#创建数据库
mysql> CREATE DATABASE mydb;

#查看所有数据库
mysql> SHOW DATABASES;

#使用数据并创建表
mysql> USE mydb;
mysql> CREATE TABLE test(id int,body varchar(100));

#查看表
mysql> SHOW TABLES;

```

### 2、用户与访问授权语法示例

```
#新建本地用户
mysql> CREATE USER 'test'@'localhost' IDENTIFIED BY '123456';

#新建远程用户
mysql> CREATE USER 'test'@'%' IDENTIFIED BY '123456';

#赋予指定账户指定数据库远程访问权限
mysql> GRANT ALL PRIVILEGES ON mydb.* TO 'test'@'%';

#赋予指定账户对所有数据库远程访问权限
mysql> GRANT ALL PRIVILEGES ON *.* TO 'test'@'%';

#赋予指定账户对所有数据库本地访问权限
mysql> GRANT ALL PRIVILEGES ON *.* TO 'test'@'localhost';

#刷新权限
mysql> FLUSH PRIVILEGES;

```

### 3、授权相关语法示例

```
#1、查看权限
SHOW GRANTS FOR 'test'@'%';

#2、赋予权限
GRANT ALL PRIVILEGES ON *.* TO 'test'@'%';

#3、收回权限
REVOKE ALL PRIVILEGES ON *.* FROM 'test'@'%';

#4、刷新权限
FLUSH PRIVILEGES;

#5、删除用户
DROP USER 'test'@'localhost';

## 五、修改字符编码


### 1、 查找配置文件位置

​```bash
[root@centos7 download]# whereis my.cnf
my: /etc/my.cnf

```

### 2、 修改配置文件

```
#修改配置文件
vi /etc/my.cnf

#修改1：增加client配置（文件开头）
[client]
default-character-set=utf8mb4

#修改2：增加mysqld配置（文件结尾）
#charset
character-set-server=utf8mb4
collation-server=utf8mb4_general_ci

```

### 3、 重启mysql服务

```
#重启后配置即可生效
systemctl restart mysqld
```