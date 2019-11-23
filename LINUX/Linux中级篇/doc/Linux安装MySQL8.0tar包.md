# Linux安装MySQL8.0.11

### 去官网下载安装包

下载链接：点击打开链接

https://dev.mysql.com/downloads/mysql/

**也可以用wget 下载**

```
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.11-linux-glibc2.12-i686.tar.gz
```

**解压文件**

```
tar -zxvf mysql-8.0.11-linux-glibc2.12-i686.tar.gz
```

#### 2  移动压缩包到usr/local目录下,并重命名文件

```
mv /root/mysql-8.0.11-linux-glibc2.12-i686  /usr/local/mysql
```

#### 3.在MySQL根目录下新建一个文件夹data,用于存放数据

```
mkdir data
```

#### 4.创建 mysql 用户组和 mysql 用户

```
groupadd mysql

useradd -g mysql mysql
```

#### 5.改变 mysql 目录权限

```
chown -R mysql.mysql /usr/local/mysql/
```

#### 6.初始化数据库

创建mysql_install_db安装文件

```
mkdir mysql_install_db
chmod 777 ./mysql_install_db
```

初始化 

```
bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data //初始化数据库
```

或者

```
/usr/local/mysql/bin/mysqld --initialize --user=mysql
```

```
bin/mysqld (mysqld 8.0.11) initializing of server in progress as process 5826

 [Server] A temporary password is generated for root@localhost: twi=Tlsi<0O!

/usr/local/mysql/bin/mysqld (mysqld 8.0.11) initializing of server has completed
```

记录好自己的临时密码：

```
   twi=Tlsi<0O!
```

### 安装文件

####  7.mysql配置

```
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysqld
```

**修改my.cnf文件**

```
vim  /etc/my.cnf
```

```
[mysqld]
basedir = /usr/local/mysql   
datadir = /usr/local/mysql/data
socket = /usr/local/mysql/mysql.sock
character-set-server=utf8
port = 3306
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
[client]
socket = /usr/local/mysql/mysql.sock
default-character-set=utf8
```

esc保存

:wq 退出

#### 8建立MySQL服务


添加到系统服务

```
chkconfig --add mysql
cp -a ./support-files/mysql.server /etc/init.d/mysqld

给/etc/rc.d/init.d/mysql赋权可执行权限
chmod +x /etc/rc.d/init.d/mysqld    
添加mysql服务
chkconfig --add mysqld
mysql服务开机自启
chkconfig --level 345 mysql on
```

检查服务是否生效  

```
chkconfig  --list mysqld
```

9. #### 配置全局环境变量

编辑 / etc/profile 文件

```
vi /etc/profile
```

在 profile 文件底部添加如下两行配置，保存后退出

```
export PATH=$PATH:/usr/local/mysql/bin:/usr/local/mysql/lib

export PATH
```

设置环境变量立即生效

```
 source /etc/profile
```

#### 10.启动MySQL服务

```
service mysql start
```

查看初始密码

```
cat /root/.mysql_secret
```

#### 11.登录MySQL

```
mysql -uroot -p密码
```

修改密码：

```
alter user 'root'@'localhost' identified by '123456';   #对应的换成你自己的密码即可了。
```

#### 12设置可以远程登录

```
 mysql>use mysql

mysql>update user set host='%' where user='root' limit 1;
刷新权限
mysql>flush privileges;
```

然后检查3306端口是否开放

```
netstat -nupl|grep 3306
```

开放3306端口

```
firewall-cmd --add-port=3306/tcp --permanent
```

重启防火墙

```
firewall -cmd --reload
```

#### 13.navicat 连接 mysql 出现Client does not support authentication protocol requested by server解决方案

```
USE mysql;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';

FLUSH PRIVILEGES;
```

#### 14.解决ERROR 1396 (HY000): Operation ALTER USER failed for 'root'@'localhost'

mysql连数据库的时候报错:

client does not support authentication protocol requested by server;consider upgrading Mysql client

ERROR 1396 (HY000): Operation ALTER USER failed for 'root'@'localhost'

先登录mysql

```
mysql -u root -p
```


输入密码

```
mysql> use mysql;
mysql> select user,host from user;
+------------------+-----------+
| user             | host      |
+------------------+-----------+
| root             | %         |
| admin            | localhost |
| mysql.infoschema | localhost |
| mysql.session    | localhost |
| mysql.sys        | localhost |
| zhangj           | localhost |
+------------------+-----------+
```


注意我的root，host是'%'

你可能执行的是:

```
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456';
```


改成:

```
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';
```


