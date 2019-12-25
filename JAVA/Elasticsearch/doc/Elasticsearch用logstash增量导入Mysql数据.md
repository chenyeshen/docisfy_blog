# Elasticsearch用logstash增量导入Mysql数据

## 前言

logstash是什么？为什么需要logstash？援引[官网](https://link.zhihu.com/?target=https%3A//www.elastic.co/cn/products/logstash)的介绍：*Logstash 是开源的服务器端数据处理管道，能够同时从多个来源采集数据，转换数据，然后将数据发送到您最喜欢的 “存储库” 中。（我们的存储库当然是 Elasticsearch。）*

简单来说，logstash就是用于将不同来源的数据(如JDBC、http网络、kafka、log4j日志等)统一管理，输入到Elasticsearch中，以作为整个搜索引擎的数据源。例如：存储在Mysql中 的数据，可以用JDBC来导入到Elasticsearch中(需要安装logstash-input-jdbc插件)，还可以设置定时任务，支持增量导入等。

本文主要介绍logstash-input-jdbc插件的安装，以及简单的.conf配置文件，实现执行定时任务，从Mysql增量导入数据到Elasticsearch的简单效果。

## **1.安装logstash-input-jdbc**

首先，在安装好Elasticsearch的环境中，装logstash，下载按照官网的步骤来就可以。logstash是一个数据导入工具，支持多种数据源导入到Elasticsearch中，导入不同的数据源需要用到不同的插件，要想导入Mysql的数据到Elasticsearch，需要安装插件——logstash-input-jdbc。

> Elasticsearch、logstash下载地址：[https://www.elastic.co/downloads](https://link.zhihu.com/?target=https%3A//www.elastic.co/downloads)
> **插件github地址：**[logstash-plugins/logstash-input-jdbc](https://link.zhihu.com/?target=https%3A//github.com/logstash-plugins/logstash-input-jdbc)

安装此插件以及依赖需要在ruby环境下，ruby默认的镜像在国外，所以很慢，需要手动将镜像网站[https://rubygems.org/](https://link.zhihu.com/?target=https%3A//rubygems.org/)替换为国内的[https://gems.ruby-china.com/](https://link.zhihu.com/?target=https%3A//gems.ruby-china.com/)



**安装logstash-input-jdbc插件**

执行完上面3步后，终于可以安装插件了，启动logstash的bin目录下的logstash-plugin命令，执行安装。

```
bin/logstash-plugin  install logstash-input-jdbc
```

安装完成不报错就应该是成功了，可用*bin/logstash-plugin list*查看所有已安装插件，加上--verbose参数可以显示插件版本号。

```
bin/logstash-plugin list 
bin/logstash-plugin list --verbose
```

## **2.配置logstash的conf文件**

logstash-input-jdbc插件安装完成后，就可以配置.conf文件导入mysql的数据了，详细请戳**[官方文档](https://link.zhihu.com/?target=https%3A//www.elastic.co/guide/en/logstash/current/plugins-inputs-jdbc.html),**此处以我的配置文件为例：

### logstash-mysql.conf

```
input {
  jdbc {
    #jar包可以存放在任意路径  
    jdbc_driver_library => "D:/logstash-6.2.3/config/mysql-connector-java-8.0.17.jar"
    #因为使用mysql8.0 故为com.mysql.cj.jdbc.Driver  mysql8.0以下为： com.mysql.jdbc.Driver
    jdbc_driver_class => "com.mysql.cj.jdbc.Driver"
     #因为使用mysql8.0 需要设置时区 
    jdbc_connection_string => "jdbc:mysql://localhost:3306/xdvideo?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT"
    jdbc_user => "root"
    jdbc_password => "root"
    statement => "SELECT * FROM video WHERE create_time >= :sql_last_value"
    jdbc_paging_enabled => "true"
    jdbc_page_size => "50000"
	 #schedule设置每分钟执行
    schedule => "* * * * *" 
	record_last_run => true
	last_run_metadata_path => "D:/logstash-6.2.3/config/loginfo"
  }
}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
    index => "video_el"
    #index表示存入elasticsearch中的索引名字
	document_id => "%{id}"
	document_type => "doc"
	template => "D:/logstash-6.2.3/config/video_template.json"
	template_name => "video"
	template_overwrite => "true"
  }
  stdout { codec => json_lines }
}
```

### video_template.json

```
{  
    "mappings" :{
	   "properties":{
	      
		   "id":{
		      "type": "keyword"
	   
	           }
	        "title":{
			  "type": "text",
			  "analyzer":" ik_max_word",
			  "search_analyzer": "ik_smart"
			  
			},
			"summary":{
			   "type": "text"
			},
			"cover_img":{
			   "type":  "keyword",
			   "index": "false"
			  
			},
			"create_time":{
			    "type": "date",
			    "format": "yyyy-MM-dd HH:mm:ss"
			},
			"price":{
			    "type": "Interge"
			},
			"online":{
			   "type": "Interge"
			},
			"poin":{
			   "type": "float"
			}
			
	   }
	
	
	
	},
	"template": "video"

}
```

### 新建一个loginfo空文件

![](https://i.loli.net/2019/11/10/D731Gz2HdgAKP4i.png)



### video.sql

```
/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 80016
Source Host           : localhost:3306
Source Database       : xdvideo

Target Server Type    : MYSQL
Target Server Version : 80016
File Encoding         : 65001

Date: 2019-11-10 17:59:43
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for video
-- ----------------------------
DROP TABLE IF EXISTS `video`;
CREATE TABLE `video` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(524) DEFAULT NULL COMMENT '视频标题',
  `summary` varchar(1026) DEFAULT NULL COMMENT '概述',
  `cover_img` varchar(255) DEFAULT NULL COMMENT '封面图',
  `price` int(11) DEFAULT NULL COMMENT '价格，分',
  `create_time` datetime DEFAULT NULL COMMENT '创建时间',
  `online` int(5) DEFAULT NULL COMMENT '0表示未登录，1表示登录',
  `point` double(11,2) DEFAULT '8.70' COMMENT '默认8.7',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of video
-- ----------------------------
INSERT INTO `video` VALUES ('1', '测试更新啦新版本RocketMQ4.X教程消息队列教程', '', 'http://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/1903/rocketmq.png', '1', '2019-11-10 14:49:12', '1', '8.70');
INSERT INTO `video` VALUES ('2', '车上有吃的Redis高并发高可用集群百万级秒杀实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/1903/redis2.png', '1', '2019-11-10 13:14:00', '1', '8.70');
INSERT INTO `video` VALUES ('3', 'Mysql零基础入门到实战 数据库教程', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_backend/mysql.png', '1002', '2019-08-28 21:39:56', '1', '8.70');
INSERT INTO `video` VALUES ('4', '互联网架构之JAVA虚拟机JVM零基础到高级实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_backend/jvm.jpeg', '80', '2019-08-31 11:38:35', '1', '8.70');
INSERT INTO `video` VALUES ('5', 'HTML5+CSS3电商项目综合实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_frontend/pc%E5%AE%9E%E6%88%98/pc.png', '800', '2019-08-31 11:39:13', '1', '8.70');
INSERT INTO `video` VALUES ('6', '19年录制ES6教程ES7ES8实战应用', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_frontend/es67/es.png', '520', '2019-08-31 11:40:06', '1', '8.70');
INSERT INTO `video` VALUES ('7', '19年微服务Dubbo+SpringBoot2.X优惠券项目实战教程', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_backend/dubbo_project.png', '89', '2019-08-31 11:40:10', '1', '8.70');
INSERT INTO `video` VALUES ('8', '9年Linux/Centos7视频教程零基础入门到高实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/2019_backend/linux_base.png', '100', '2019-08-31 11:42:40', '1', '8.70');
INSERT INTO `video` VALUES ('9', '19年全新React零基础到单页面项目实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/video/react.png', '618', '2019-08-31 11:42:43', null, '8.70');
INSERT INTO `video` VALUES ('10', '9年录制互联网架构之分布式缓存Redis从入门到高级实战', null, 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/1901/netty/netty.png', '720', '2019-08-31 11:42:46', null, '8.70');
INSERT INTO `video` VALUES ('11', '高级实战', '爱你时间', 'https://xd-video-pc-img.oss-cn-beijing.aliyuncs.com/xdclass_pro/video/1901/netty/netty.png', '888', '2019-11-10 17:24:46', '2', '8.70');

```

mysql-connector-java这个jar包下载： [https://download.jar-download.com/cache_jars/org.wisdom-framework/mysql-connector-java/5.1.34_1/jar_files.zip](https://download.jar-download.com/cache_jars/org.wisdom-framework/mysql-connector-java/5.1.34_1/jar_files.zip)

可以看到，在logstash的conf文件中可以配置schedule，即定时任务；配置statement，即定时执行的SQL语句，此处：

```
statement => "SELECT * FROM TABLE_NAME WHERE TABLE_NAME.edit_date >= :sql_last_value"
```

例中，blog_article表中edit_date列记录了数据编辑时间，当有新增的文章或者有修改的文章时，这些记录的edit_date时间>上次sql执行的时间sql_last_value，于是这些内容就是要导入到Es中的所谓【增量】。

## **3.启动Logstash导入Mysql中的数据**

配置好.conf文件后，启动logstash时即可直接根据conf文件启动，从而实现数据的导入。启动命令如下：

```
D:\logstash-6.2.3\bin>logstash.bat -f D:\logstash-6.2.3\config\logstash-mysql.conf
```

![](https://i.loli.net/2019/11/10/EODHNuFG385JPga.png)



## 4.成功导入数据到elasticsearch

![](https://i.loli.net/2019/11/10/lwL47GUAY6ciPQM.png)



![](https://i.loli.net/2019/11/10/WQ6NTStKxqXE3eR.png)





### 配置能够实现从 SQL Server 数据库中查询数据，并增量式的把数据库记录导入到 ES 中。

1. 查询的 SQL 语句在 statement_filepath => "/etc/logstash/statement_file.d/my_info.sql" 参数指定的文件中给出。
2. 字段的转换由 add_field 参数完成。



```
input {
    jdbc {
            jdbc_driver_library => "/etc/logstash/driver.d/sqljdbc_2.0/enu/sqljdbc4.jar"
            jdbc_driver_class => "com.microsoft.sqlserver.jdbc.SQLServerDriver"
            jdbc_connection_string => "jdbc:sqlserver://localhost:1433;databaseName=test_db"
            jdbc_user => "sa"
            jdbc_password => "123"
                        # schedule => 分 时 天 月 年  
                        # schedule => * 22  *  *  *     //will execute at 22:00 every day
            schedule => "* * * * *"
            clean_run => false
            use_column_value => true
            tracking_column => BUG_ID
            record_last_run => true
            last_run_metadata_path => "/etc/logstash/run_metadata.d/my_info"
            lowercase_column_names => false
            statement_filepath => "/etc/logstash/statement_file.d/my_info.sql"
            type => "my_info"
            add_field => {"[基本信息][客户名称]" => "%{客户名称}"
                          "[基本信息][BUG_ID]" => "%{BUG_ID}"
                          "[基本信息][责任部门]" => "%{责任部门}"
                          "[基本信息][发现版本]" => "%{发现版本}"
                          "[基本信息][发现日期]" => "%{发现日期}"
                          "[基本信息][关闭日期]" => "%{关闭日期}"
            }
}
```



其中，数据库查询操作 SQL 如下（my_info.sql）：



```
SELECT
   客户名称,
   BUG_ID,
   ISNULL(VIP_Level,'') AS VIP_Level,
   ISNULL(责任部门,'') AS 责任部门,
   ISNULL(发现版本,'') AS 发现版本,
   ISNULL(发现日期,'') AS 发现日期,
   ISNULL(关闭日期,发现日期) AS 关闭日期,
   ISNULL(
       CASE TD记录人备注
       WHEN 'NULL' THEN ''
       ELSE TD记录人备注
       END,'' ) AS TD记录人备注,
 From test_bug_db.dbo.BugInfor WHERE BUG_ID > :sql_last_value
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

 

## 重要参数说明

JDBC（[Java](http://www.bing.com/knows/search?q=java_%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80&mkt=zh-cn&mkt=zh-cn&form=BKACAI) Data Base Connectivity，[Java](http://www.bing.com/knows/search?q=java_%E8%AE%A1%E7%AE%97%E6%9C%BA%E7%BC%96%E7%A8%8B%E8%AF%AD%E8%A8%80&mkt=zh-cn&mkt=zh-cn&form=BKACAI)[java数据库连接](http://www.bing.com/knows/search?q=Java%E6%95%B0%E6%8D%AE%E5%BA%93%E8%BF%9E%E6%8E%A5&mkt=zh-cn&mkt=zh-cn&form=BKACAI)）参数

如果要了解其它数据库，可以参考我的 <http://www.cnblogs.com/licongyu/p/5535833.html>

```
jdbc_driver_library => "/etc/logstash/driver.d/sqljdbc_2.0/enu/sqljdbc4.jar"         //jdbc sql server 驱动,各个数据库都有对应的驱动，需自己下载
jdbc_driver_class => "com.microsoft.sqlserver.jdbc.SQLServerDriver"                  //jdbc class 不同数据库有不同的 class 配置
jdbc_connection_string => "jdbc:sqlserver://200.200.0.18:1433;databaseName=test_db"  //配置数据库连接 ip 和端口，以及数据库
jdbc_user =>          //配置数据库用户名
jdbc_password =>      //配置数据库密码
```

### Schedule设置

```
# schedule => 分 时 天 月 年  
# schedule => *  22  *  *  *     //will execute at 22:00 every day
schedule => "* * * * *"
```



### 重要参数设置

```
//是否记录上次执行结果, 如果为真,将会把上次执行到的 tracking_column 字段的值记录下来,保存到 last_run_metadata_path 指定的文件中
record_last_run => true

//是否需要记录某个column 的值,如果 record_last_run 为真,可以自定义我们需要 track 的 column 名称，此时该参数就要为 true. 否则默认 track 的是 timestamp 的值.
use_column_value => true

//如果 use_column_value 为真,需配置此参数. track 的数据库 column 名,该 column 必须是递增的.比如：ID.
tracking_column => MY_ID

//指定文件,来记录上次执行到的 tracking_column 字段的值
//比如上次数据库有 10000 条记录,查询完后该文件中就会有数字 10000 这样的记录,下次执行 SQL 查询可以从 10001 条处开始.
//我们只需要在 SQL 语句中 WHERE MY_ID > :last_sql_value 即可. 其中 :last_sql_value 取得就是该文件中的值(10000).
last_run_metadata_path => "/etc/logstash/run_metadata.d/my_info"

//是否清除 last_run_metadata_path 的记录,如果为真那么每次都相当于从头开始查询所有的数据库记录
clean_run => false

//是否将 column 名称转小写
lowercase_column_names => false

//存放需要执行的 SQL 语句的文件位置
statement_filepath => "/etc/logstash/statement_file.d/my_info.sql"
```



 