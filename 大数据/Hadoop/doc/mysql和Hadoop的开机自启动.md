# mysql和Hadoop的开机自启动

### 配置MySQL服务自启动

```
[root@hadoop000 ~]# cd /usr/local/mysql
```

\#将服务文件拷贝到init.d下，并重命名为
mysql

[root@hadoop000 mysql]# cp support-files/mysql.server /etc/rc.d/init.d/mysql 

\#赋予可执行权限

```
[root@hadoop000 mysql]# chmod +x /etc/rc.d/init.d/mysql
```

\#删除服务

```
[root@hadoop000 mysql]# chkconfig --del mysql
```

\#添加服务

[root@hadoop000 mysql]# chkconfig --add mysql

[root@hadoop000 mysql]# chkconfig --level 345 mysql on

[root@sht-sgmhadoopnn-01 mysql]# vi /etc/rc.local
\#!/bin/sh

\#
\# This script will be executed *after* all the other init scripts.

\# You can put your own initialization stuff in here if you don't

\# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

su - mysqladmin -c "/etc/init.d/mysql start --federated"

"/etc/rc.local" 9L, 278C written

### 配置 Hadoop 服务自启动

##### 1、进入到/etc/init.d目录下，编辑一个新的脚本文件

hadoop
\# cd /etc/init.d
\# vi hadoop

##### 2、编辑脚本文件

hadoop

\#！/bin/bash

\#chkconfig:345

\#description:script to start/stop hadoop

su - hadoop <<!

case $1 in

start)

sh /home/hadoop/app/hadoop-2.6.0-cdh5.7.0/sbin/start-all.sh

;;

stop)

sh /home/hadoop/app/hadoop-2.6.0-cdh5.7.0/sbin/stop-all.sh

;;

*)

echo "Usage:$0(start|stop)"

;;

esac

exit

!

##### 3、保存退出，用chmod修改该文件权限

\# chmod -R 775 hadoop

4、设置hadoop为开机自启动

\# chkconfig --add hadoop 

\# chkconfig --level 345 hadoop on