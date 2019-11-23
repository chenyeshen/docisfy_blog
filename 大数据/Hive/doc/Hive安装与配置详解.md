# Hive安装与配置详解

### 将hive解压到/usr/local下：

```
[root@s100 local]# tar -zxvf apache-hive-2.1.1-bin.tar.gz -C /usr/local/
```

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180103161658049-344238859.png)

### 将文件重命名为hive文件：

```
[root@s100 local]# mv apache-hive-2.1.1-bin hive
```

 

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180103161800174-1475619201.png)

### 修改环境变量/etc/profile：

```
[root@s100 local]# vim /etc/profile
```

 

```
1 #hive
2 export HIVE_HOME=/usr/local/hive
3 export PATH=$PATH:$HIVE_HOME/bin
```

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180103162157878-412145690.png)

### 环境生效：

```
source  /etc/profile
```

执行hive --version

```
[root@s100 local]# hive --version
```

 

 有hive的版本显现，安装成功！

### 若hive环境搭建提示: java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument

提示的错误信息:

```
SLF4J: Actual binding is of type [org.apache.logging.slf4j.Log4jLoggerFactory]

Exception in thread "main" java.lang.NoSuchMethodError: com.google.common.base.Preconditions.checkArgument(ZLjava/lang/String;Ljava/lang/Object;)V
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1357)
        at org.apache.hadoop.conf.Configuration.set(Configuration.java:1338)
        at org.apache.hadoop.mapred.JobConf.setJar(JobConf.java:536)
        at org.apache.hadoop.mapred.JobConf.setJarByClass(JobConf.java:554)
        at org.apache.hadoop.mapred.JobConf.<init>(JobConf.java:448)
        at org.apache.hadoop.hive.conf.HiveConf.initialize(HiveConf.java:5141)
        at org.apache.hadoop.hive.conf.HiveConf.<init>(HiveConf.java:5099)
        at org.apache.hadoop.hive.common.LogUtils.initHiveLog4jCommon(LogUtils.java:97)
        at org.apache.hadoop.hive.common.LogUtils.initHiveLog4j(LogUtils.java:81)
        at org.apache.hadoop.hive.cli.CliDriver.run(CliDriver.java:699)
        at org.apache.hadoop.hive.cli.CliDriver.main(CliDriver.java:683)
        at sunreflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at sun.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:62)
        at sun.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at org.aache.hadoop.util.RunJar.run(RunJar.java:323)
        at org.apache.hadoop.util.RunJar.main(RunJar.java:236)
```

关键在： com.google.common.base.Preconditions.checkArgument 这是因为hive内依赖的**guava.jar**和hadoop内的**版本不一致**造成的。 检验方法：

1. 查看hadoop安装目录下share/hadoop/common/lib内guava.jar版本
2. 查看hive安装目录下lib内guava.jar的版本 如果两者不一致，删除版本低的，并拷贝高版本的 问题解决！

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191123110341.png)



### 配置

```
[root@s100 conf]# cd /usr/local/hive/conf/
```

修改hive-site.xml：

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180103163259659-857534362.png)

这里没有，我们就以模板复制一个：

```
[root@s100 conf]# cp hive-default.xml.template hive-site.xml
```

```
[root@s100 conf]# vim hive-site.xml 
```

 

##### 1.配置hive-site.xml（第5点的后面有一个单独的hive-site.xml配置文件，这个如果有疑问可以用后面的配置文件，更容易明白）

主要是mysql的连接信息（在文本的最开始位置）

```
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
        <property>
                <name>javax.jdo.option.ConnectionURL</name>
                <value>jdbc:mysql://localhost:3306/hive?createDatabaseIfNotExist=true</value>先自己mysql创建 hive库
        </property>

        <property>
                <name>javax.jdo.option.ConnectionDriverName</name>（mysql的驱动）
                <value>com.mysql.jdbc.Driver</value>
        </property>

        <property>
                <name>javax.jdo.option.ConnectionUserName</name>（用户名）
                <value>root</value>
        </property>

        <property>
                <name>javax.jdo.option.ConnectionPassword</name>（密码）
                <value>123456</value>
        </property>

        <property>
                <name>hive.metastore.schema.verification</name>
                <value>false</value>
        </property>
</configuration>
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191123123402.png)



##### 2.复制mysql的驱动程序到hive/lib下面（这里已经拷贝好了）

```
[root@s100 lib]# ll mysql-connector-java-5.1.18-bin.jar 
-rw-r--r-- 1 root root 789885 1月   4 01:43 mysql-connector-java-5.1.18-bin.jar
```

 

##### 3.在mysql中hive的schema（在此之前需要创建mysql下的hive数据库）

```
1 [root@s100 bin]# pwd
2 /usr/local/hive/bin
3 [root@s100 bin]# schematool -dbType mysql -initSchema
```

##### 4.执行hive命令

```
[root@localhost hive]# hive
```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191123122447.png)



成功进入hive界面，hive配置完成

##### 5.查询mysql（hive这个库是在 schematool -dbType mysql -initSchema 之前创建的！）

```
 1 [root@localhost ~]# mysql -uroot -p123456
 2 Welcome to the MySQL monitor.  Commands end with ; or \g.
 3 Your MySQL connection id is 10
 4 Server version: 5.1.73 Source distribution
 5 
 6 Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.
 7 
 8 Oracle is a registered trademark of Oracle Corporation and/or its
 9 affiliates. Other names may be trademarks of their respective
10 owners.
11 
12 Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
13 
14 mysql> use hive
15 Reading table information for completion of table and column names
16 You can turn off this feature to get a quicker startup with -A
17 
18 Database changed
19 mysql> show tables;
20 +---------------------------+
21 | Tables_in_hive            |
22 +---------------------------+
23 | AUX_TABLE                 |
24 | BUCKETING_COLS            |
25 | CDS                       |
26 | COLUMNS_V2                |
27 | COMPACTION_QUEUE          |
28 | COMPLETED_COMPACTIONS     |
```



那我们做这些事干什么的呢，下面小段测试大家感受一下

## hive测试：

备注：这里是第二个配置文件的演示：所以数据库名称是hahive数据库！

#### 1.需要知道现在的hadoop中的HDFS存了什么

```
[root@localhost conf]# hadoop fs -lsr /
```

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180104154803378-1656575784.png)

#### 2.进入hive并创建一个测试库和测试表

```
[root@localhost conf]# hive
```

 创建库：

```
1 hive> create database hive_1;
2 OK
3 Time taken: 1.432 seconds
```

 显示库：

```
1 hive> show databases;
2 OK
3 default
4 hive_1
5 Time taken: 1.25 seconds, Fetched: 2 row(s)
```

 创建库成功！

#### 3.查询一下HDFS有什么变化

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180104155909518-650334171.png)

多了一个库hive_1

娜莫喔们的mysql下的hahive库有什么变化

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180104160449549-1778967140.png)

#### 4.在hive_1下创建一个表hive_01

HDFS下的情况：

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180104161141846-1204195709.png)

mysql下：

娜莫在web端是什么样子的呢！

![img](https://images2017.cnblogs.com/blog/1293848/201801/1293848-20180104163446471-1206878871.png)