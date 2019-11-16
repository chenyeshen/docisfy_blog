

# SpringBoot+Quartz+PageHelper多任务 动态定时任务

[github源码](https://github.com/chenyeshen/SpringBootQuartz)

### quartz.sql数据

```
/*
Navicat MySQL Data Transfer

Source Server         : localhost
Source Server Version : 80016
Source Host           : localhost:3306
Source Database       : hello_quartz

Target Server Type    : MYSQL
Target Server Version : 80016
File Encoding         : 65001

Date: 2019-08-20 23:01:19
*/

SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_blob_triggers`;
CREATE TABLE `qrtz_blob_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `BLOB_DATA` blob,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  CONSTRAINT `qrtz_blob_triggers_ibfk_1` FOREIGN KEY (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`) REFERENCES `qrtz_triggers` (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_calendars`;
CREATE TABLE `qrtz_calendars` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `CALENDAR_NAME` varchar(200) NOT NULL,
  `CALENDAR` blob NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`CALENDAR_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_cron_triggers`;
CREATE TABLE `qrtz_cron_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `CRON_EXPRESSION` varchar(200) NOT NULL,
  `TIME_ZONE_ID` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  CONSTRAINT `qrtz_cron_triggers_ibfk_1` FOREIGN KEY (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`) REFERENCES `qrtz_triggers` (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------
INSERT INTO `qrtz_cron_triggers` VALUES ('SchedulerFactory', 'com.example.demo.job.HelloJob', '1', '0/40 * * * * ?', 'Asia/Shanghai');
INSERT INTO `qrtz_cron_triggers` VALUES ('SchedulerFactory', 'com.example.demo.job.NewJob', '1', '0/2 * * * * ?', 'Asia/Shanghai');

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_fired_triggers`;
CREATE TABLE `qrtz_fired_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `ENTRY_ID` varchar(95) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `INSTANCE_NAME` varchar(200) NOT NULL,
  `FIRED_TIME` bigint(13) NOT NULL,
  `SCHED_TIME` bigint(13) NOT NULL,
  `PRIORITY` int(11) NOT NULL,
  `STATE` varchar(16) NOT NULL,
  `JOB_NAME` varchar(200) DEFAULT NULL,
  `JOB_GROUP` varchar(200) DEFAULT NULL,
  `IS_NONCONCURRENT` varchar(1) DEFAULT NULL,
  `REQUESTS_RECOVERY` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`SCHED_NAME`,`ENTRY_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------
INSERT INTO `qrtz_fired_triggers` VALUES ('SchedulerFactory', 'NON_CLUSTERED1566312398701', 'com.example.demo.job.NewJob', '1', 'NON_CLUSTERED', '1566312906011', '1566312908000', '5', 'ACQUIRED', null, null, '0', '0');

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_job_details`;
CREATE TABLE `qrtz_job_details` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `JOB_NAME` varchar(200) NOT NULL,
  `JOB_GROUP` varchar(200) NOT NULL,
  `DESCRIPTION` varchar(250) DEFAULT NULL,
  `JOB_CLASS_NAME` varchar(250) NOT NULL,
  `IS_DURABLE` varchar(1) NOT NULL,
  `IS_NONCONCURRENT` varchar(1) NOT NULL,
  `IS_UPDATE_DATA` varchar(1) NOT NULL,
  `REQUESTS_RECOVERY` varchar(1) NOT NULL,
  `JOB_DATA` blob,
  PRIMARY KEY (`SCHED_NAME`,`JOB_NAME`,`JOB_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------
INSERT INTO `qrtz_job_details` VALUES ('SchedulerFactory', 'com.example.demo.job.HelloJob', '1', null, 'com.example.demo.job.HelloJob', '0', '0', '0', '0', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787000737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F40000000000010770800000010000000007800);
INSERT INTO `qrtz_job_details` VALUES ('SchedulerFactory', 'com.example.demo.job.NewJob', '1', null, 'com.example.demo.job.NewJob', '0', '0', '0', '0', 0xACED0005737200156F72672E71756172747A2E4A6F62446174614D61709FB083E8BFA9B0CB020000787200266F72672E71756172747A2E7574696C732E537472696E674B65794469727479466C61674D61708208E8C3FBC55D280200015A0013616C6C6F77735472616E7369656E74446174617872001D6F72672E71756172747A2E7574696C732E4469727479466C61674D617013E62EAD28760ACE0200025A000564697274794C00036D617074000F4C6A6176612F7574696C2F4D61703B787000737200116A6176612E7574696C2E486173684D61700507DAC1C31660D103000246000A6C6F6164466163746F724900097468726573686F6C6478703F40000000000010770800000010000000007800);

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_locks`;
CREATE TABLE `qrtz_locks` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `LOCK_NAME` varchar(40) NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`LOCK_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_paused_trigger_grps`;
CREATE TABLE `qrtz_paused_trigger_grps` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_scheduler_state`;
CREATE TABLE `qrtz_scheduler_state` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `INSTANCE_NAME` varchar(200) NOT NULL,
  `LAST_CHECKIN_TIME` bigint(13) NOT NULL,
  `CHECKIN_INTERVAL` bigint(13) NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`INSTANCE_NAME`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simple_triggers`;
CREATE TABLE `qrtz_simple_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `REPEAT_COUNT` bigint(7) NOT NULL,
  `REPEAT_INTERVAL` bigint(12) NOT NULL,
  `TIMES_TRIGGERED` bigint(10) NOT NULL,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  CONSTRAINT `qrtz_simple_triggers_ibfk_1` FOREIGN KEY (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`) REFERENCES `qrtz_triggers` (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_simprop_triggers`;
CREATE TABLE `qrtz_simprop_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `STR_PROP_1` varchar(512) DEFAULT NULL,
  `STR_PROP_2` varchar(512) DEFAULT NULL,
  `STR_PROP_3` varchar(512) DEFAULT NULL,
  `INT_PROP_1` int(11) DEFAULT NULL,
  `INT_PROP_2` int(11) DEFAULT NULL,
  `LONG_PROP_1` bigint(20) DEFAULT NULL,
  `LONG_PROP_2` bigint(20) DEFAULT NULL,
  `DEC_PROP_1` decimal(13,4) DEFAULT NULL,
  `DEC_PROP_2` decimal(13,4) DEFAULT NULL,
  `BOOL_PROP_1` varchar(1) DEFAULT NULL,
  `BOOL_PROP_2` varchar(1) DEFAULT NULL,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  CONSTRAINT `qrtz_simprop_triggers_ibfk_1` FOREIGN KEY (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`) REFERENCES `qrtz_triggers` (`SCHED_NAME`, `TRIGGER_NAME`, `TRIGGER_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS `qrtz_triggers`;
CREATE TABLE `qrtz_triggers` (
  `SCHED_NAME` varchar(120) NOT NULL,
  `TRIGGER_NAME` varchar(200) NOT NULL,
  `TRIGGER_GROUP` varchar(200) NOT NULL,
  `JOB_NAME` varchar(200) NOT NULL,
  `JOB_GROUP` varchar(200) NOT NULL,
  `DESCRIPTION` varchar(250) DEFAULT NULL,
  `NEXT_FIRE_TIME` bigint(13) DEFAULT NULL,
  `PREV_FIRE_TIME` bigint(13) DEFAULT NULL,
  `PRIORITY` int(11) DEFAULT NULL,
  `TRIGGER_STATE` varchar(16) NOT NULL,
  `TRIGGER_TYPE` varchar(8) NOT NULL,
  `START_TIME` bigint(13) NOT NULL,
  `END_TIME` bigint(13) DEFAULT NULL,
  `CALENDAR_NAME` varchar(200) DEFAULT NULL,
  `MISFIRE_INSTR` smallint(2) DEFAULT NULL,
  `JOB_DATA` blob,
  PRIMARY KEY (`SCHED_NAME`,`TRIGGER_NAME`,`TRIGGER_GROUP`),
  KEY `SCHED_NAME` (`SCHED_NAME`,`JOB_NAME`,`JOB_GROUP`),
  CONSTRAINT `qrtz_triggers_ibfk_1` FOREIGN KEY (`SCHED_NAME`, `JOB_NAME`, `JOB_GROUP`) REFERENCES `qrtz_job_details` (`SCHED_NAME`, `JOB_NAME`, `JOB_GROUP`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------
INSERT INTO `qrtz_triggers` VALUES ('SchedulerFactory', 'com.example.demo.job.HelloJob', '1', 'com.example.demo.job.HelloJob', '1', null, '1566312640000', '1566312600000', '5', 'PAUSED', 'CRON', '1566311917000', '0', null, '0', '');
INSERT INTO `qrtz_triggers` VALUES ('SchedulerFactory', 'com.example.demo.job.NewJob', '1', 'com.example.demo.job.NewJob', '1', null, '1566312908000', '1566312906000', '5', 'ACQUIRED', 'CRON', '1566289603000', '0', null, '0', '');

```

### 依赖pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
   <modelVersion>4.0.0</modelVersion>

   <groupId>com.example</groupId>
   <artifactId>demo</artifactId>
   <version>0.0.1-SNAPSHOT</version>
   <packaging>jar</packaging>

   <name>demo</name>
   <description>Demo project for Spring Boot</description>

   <parent>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-parent</artifactId>
      <version>2.0.0.M2</version>
      <relativePath/> <!-- lookup parent from repository -->
   </parent>

   <properties>
      <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
      <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
      <java.version>1.8</java.version>
   </properties>

   <dependencies>
      <dependency>
         <groupId>org.mybatis.spring.boot</groupId>
         <artifactId>mybatis-spring-boot-starter</artifactId>
         <version>2.1.0</version>
      </dependency>
      <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-quartz</artifactId>
      </dependency>
      <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-web</artifactId>
      </dependency>

      <!-- https://mvnrepository.com/artifact/mysql/mysql-connector-java -->
      <dependency>
         <groupId>mysql</groupId>
         <artifactId>mysql-connector-java</artifactId>
         <version>8.0.11</version>
      </dependency>

      <dependency>
         <groupId>org.springframework.boot</groupId>
         <artifactId>spring-boot-starter-test</artifactId>
         <scope>test</scope>
      </dependency>
      
       <dependency>
          <groupId>com.github.pagehelper</groupId>
             <artifactId>pagehelper</artifactId>
          <version>5.0.0</version>
      </dependency>

      <!-- https://mvnrepository.com/artifact/com.alibaba/druid-spring-boot-starter -->
      <dependency>
         <groupId>com.alibaba</groupId>
         <artifactId>druid-spring-boot-starter</artifactId>
         <version>1.1.10</version>
      </dependency>


   </dependencies>

   <build>
      <plugins>
         <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
         </plugin>
      </plugins>
   </build>

   <repositories>
      <repository>
         <id>spring-snapshots</id>
         <name>Spring Snapshots</name>
         <url>https://repo.spring.io/snapshot</url>
         <snapshots>
            <enabled>true</enabled>
         </snapshots>
      </repository>
      <repository>
         <id>spring-milestones</id>
         <name>Spring Milestones</name>
         <url>https://repo.spring.io/milestone</url>
         <snapshots>
            <enabled>false</enabled>
         </snapshots>
      </repository>
   </repositories>

   <pluginRepositories>
      <pluginRepository>
         <id>spring-snapshots</id>
         <name>Spring Snapshots</name>
         <url>https://repo.spring.io/snapshot</url>
         <snapshots>
            <enabled>true</enabled>
         </snapshots>
      </pluginRepository>
      <pluginRepository>
         <id>spring-milestones</id>
         <name>Spring Milestones</name>
         <url>https://repo.spring.io/milestone</url>
         <snapshots>
            <enabled>false</enabled>
         </snapshots>
      </pluginRepository>
   </pluginRepositories>


</project>

```



### 配置文件

- ##### application.yml

  ```
  spring:
    datasource:
      type: com.alibaba.druid.pool.DruidDataSource
      url: jdbc:mysql://127.0.0.1:3306/hello_quartz?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
      username: root
      password: root
      driver-class-name: com.mysql.cj.jdbc.Driver
      
  mybatis: 
    mapper-locations: classpath:mapper/*.xml
    type-aliases-package: com.example.demo.entity
      
  ```

  ##### 

- ##### quartz.properties

```
# 固定前缀org.quartz
# 主要分为scheduler、threadPool、jobStore、plugin等部分
#
#
org.quartz.scheduler.instanceName = DefaultQuartzScheduler
org.quartz.scheduler.rmi.export = false
org.quartz.scheduler.rmi.proxy = false
org.quartz.scheduler.wrapJobExecutionInUserTransaction = false

# 实例化ThreadPool时，使用的线程类为SimpleThreadPool
org.quartz.threadPool.class = org.quartz.simpl.SimpleThreadPool

# threadCount和threadPriority将以setter的形式注入ThreadPool实例
# 并发个数
org.quartz.threadPool.threadCount = 5
# 优先级
org.quartz.threadPool.threadPriority = 5
org.quartz.threadPool.threadsInheritContextClassLoaderOfInitializingThread = true

org.quartz.jobStore.misfireThreshold = 5000

# 默认存储在内存中
#org.quartz.jobStore.class = org.quartz.simpl.RAMJobStore

#持久化
org.quartz.jobStore.class = org.quartz.impl.jdbcjobstore.JobStoreTX

org.quartz.jobStore.tablePrefix = QRTZ_

org.quartz.jobStore.dataSource = qzDS

org.quartz.dataSource.qzDS.driver = com.mysql.cj.jdbc.Driver

org.quartz.dataSource.qzDS.URL = jdbc:mysql://127.0.0.1:3306/hello_quartz?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT

org.quartz.dataSource.qzDS.user = root

org.quartz.dataSource.qzDS.password = root

org.quartz.dataSource.qzDS.maxConnections = 10
```



- ##### JobMapper.xml

  ```
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >  
  <mapper namespace="com.example.demo.dao.JobAndTriggerMapper">  
      
      <select id="getJobAndTriggerDetails" resultType="com.example.demo.entity.JobAndTrigger">
           SELECT
              qrtz_job_details.JOB_NAME,
              qrtz_job_details.JOB_GROUP,
              qrtz_job_details.JOB_CLASS_NAME,
              qrtz_triggers.TRIGGER_NAME,
              qrtz_triggers.TRIGGER_GROUP,
              qrtz_cron_triggers.CRON_EXPRESSION,
              qrtz_cron_triggers.TIME_ZONE_ID
           FROM
              qrtz_job_details
           JOIN qrtz_triggers
           JOIN qrtz_cron_triggers ON qrtz_job_details.JOB_NAME = qrtz_triggers.JOB_NAME
           AND qrtz_triggers.TRIGGER_NAME = qrtz_cron_triggers.TRIGGER_NAME
           AND qrtz_triggers.TRIGGER_GROUP = qrtz_cron_triggers.TRIGGER_GROUP
      </select>
      
  </mapper>
  ```



### DemoApplication.java

```
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@ComponentScan("com.example.demo")
@MapperScan("com.example.demo.dao")
@SpringBootApplication
public class DemoApplication {

   public static void main(String[] args) {
      SpringApplication.run(DemoApplication.class, args);
   }
}

```



### SchedulerConfig.java

```
package com.example.demo.config;

import org.quartz.Scheduler;
import org.quartz.ee.servlet.QuartzInitializerListener;
import org.springframework.beans.factory.config.PropertiesFactoryBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

import java.io.IOException;
import java.util.Properties;

@Configuration
public class SchedulerConfig {

    @Bean(name="SchedulerFactory")
    public SchedulerFactoryBean schedulerFactoryBean() throws IOException {
        SchedulerFactoryBean factory = new SchedulerFactoryBean();
        factory.setQuartzProperties(quartzProperties());
        return factory;
    }

    @Bean
    public Properties quartzProperties() throws IOException {
        PropertiesFactoryBean propertiesFactoryBean = new PropertiesFactoryBean();
        propertiesFactoryBean.setLocation(new ClassPathResource("/quartz.properties"));
        //在quartz.properties中的属性被读取并注入后再初始化对象
        propertiesFactoryBean.afterPropertiesSet();
        return propertiesFactoryBean.getObject();
    }
  
    /*
     * quartz初始化监听器
     */
    @Bean
    public QuartzInitializerListener executorListener() {
       return new QuartzInitializerListener();
    }
    
    /*
     * 通过SchedulerFactoryBean获取Scheduler的实例
     */
    @Bean(name="Scheduler")
    public Scheduler scheduler() throws IOException {
        return schedulerFactoryBean().getScheduler();
    }

}

```

### JobAndTriggerMapper.java

```
public interface JobAndTriggerMapper {
   public List<JobAndTrigger> getJobAndTriggerDetails();
}

```



### JobAndTrigger.java

```
package com.example.demo.entity;

import java.math.BigInteger;

public class JobAndTrigger {
   private String JOB_NAME;
   private String JOB_GROUP;
   private String JOB_CLASS_NAME;
   private String TRIGGER_NAME;
   private String TRIGGER_GROUP;
   private BigInteger REPEAT_INTERVAL;
   private BigInteger TIMES_TRIGGERED;
   private String CRON_EXPRESSION;
   private String TIME_ZONE_ID;
   
   public String getJOB_NAME() {
      return JOB_NAME;
   }
   public void setJOB_NAME(String jOB_NAME) {
      JOB_NAME = jOB_NAME;
   }
   public String getJOB_GROUP() {
      return JOB_GROUP;
   }
   public void setJOB_GROUP(String jOB_GROUP) {
      JOB_GROUP = jOB_GROUP;
   }
   public String getJOB_CLASS_NAME() {
      return JOB_CLASS_NAME;
   }
   public void setJOB_CLASS_NAME(String jOB_CLASS_NAME) {
      JOB_CLASS_NAME = jOB_CLASS_NAME;
   }
   public String getTRIGGER_NAME() {
      return TRIGGER_NAME;
   }
   public void setTRIGGER_NAME(String tRIGGER_NAME) {
      TRIGGER_NAME = tRIGGER_NAME;
   }
   public String getTRIGGER_GROUP() {
      return TRIGGER_GROUP;
   }
   public void setTRIGGER_GROUP(String tRIGGER_GROUP) {
      TRIGGER_GROUP = tRIGGER_GROUP;
   }
   public BigInteger getREPEAT_INTERVAL() {
      return REPEAT_INTERVAL;
   }
   public void setREPEAT_INTERVAL(BigInteger rEPEAT_INTERVAL) {
      REPEAT_INTERVAL = rEPEAT_INTERVAL;
   }
   public BigInteger getTIMES_TRIGGERED() {
      return TIMES_TRIGGERED;
   }
   public void setTIMES_TRIGGERED(BigInteger tIMES_TRIGGERED) {
      TIMES_TRIGGERED = tIMES_TRIGGERED;
   }
   public String getCRON_EXPRESSION() {
      return CRON_EXPRESSION;
   }
   public void setCRON_EXPRESSION(String cRON_EXPRESSION) {
      CRON_EXPRESSION = cRON_EXPRESSION;
   }
   public String getTIME_ZONE_ID() {
      return TIME_ZONE_ID;
   }
   public void setTIME_ZONE_ID(String tIME_ZONE_ID) {
      TIME_ZONE_ID = tIME_ZONE_ID;
   }
   
}

```



### Job

- #####  BaseJob.java

```
package com.example.demo.job;

import org.quartz.Job;
import org.quartz.JobExecutionContext;
import org.quartz.JobExecutionException;

public interface BaseJob extends Job{
   @Override
   public void execute(JobExecutionContext context) throws JobExecutionException;
}


```

##### 

- ##### HelloJob.java

```
package com.example.demo.job;

import java.util.Date;  
import org.slf4j.Logger;  
import org.slf4j.LoggerFactory;   
import org.quartz.JobExecutionContext;  
import org.quartz.JobExecutionException;  
  
public class HelloJob implements BaseJob {  
  
    private static Logger _log = LoggerFactory.getLogger(HelloJob.class);  
     
    public HelloJob() {  
          
    }  
     
    @Override
    public void execute(JobExecutionContext context)
        throws JobExecutionException {  
        _log.error("Hello Job执行时间: " + new Date());  
          
    }  
}  

```

##### 

- ##### NewJob.java

```
package com.example.demo.job;

import java.util.Date;  
import org.slf4j.Logger;  
import org.slf4j.LoggerFactory;  
import org.quartz.JobExecutionContext;  
import org.quartz.JobExecutionException;  
  
public class NewJob implements BaseJob {  
  
    private static Logger _log = LoggerFactory.getLogger(NewJob.class);  
     
    public NewJob() {  
          
    }  
     
    @Override
    public void execute(JobExecutionContext context)
        throws JobExecutionException {  
        _log.error("New Job执行时间: " + new Date());  
          
    }  
}  
```



### IJobAndTriggerService.java

```
import com.example.demo.entity.JobAndTrigger;
import com.github.pagehelper.PageInfo;

public interface IJobAndTriggerService {
   public PageInfo<JobAndTrigger> getJobAndTriggerDetails(int pageNum, int pageSize);
}
```



### JobAndTriggerImpl.java

```
package com.example.demo.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.example.demo.dao.JobAndTriggerMapper;
import com.example.demo.entity.JobAndTrigger;
import com.example.demo.service.IJobAndTriggerService;
import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;


@Service
public class JobAndTriggerImpl implements IJobAndTriggerService{

   @Autowired
   private JobAndTriggerMapper jobAndTriggerMapper;
   
   @Override
   public PageInfo<JobAndTrigger> getJobAndTriggerDetails(int pageNum, int pageSize) {
      PageHelper.startPage(pageNum, pageSize);
      List<JobAndTrigger> list = jobAndTriggerMapper.getJobAndTriggerDetails();
      PageInfo<JobAndTrigger> page = new PageInfo<JobAndTrigger>(list);
      return page;
   }

}
```



### JobController.java

```
package com.example.demo.controller;

import java.util.HashMap;
import java.util.Map;

import org.quartz.CronScheduleBuilder;
import org.quartz.CronTrigger;
import org.quartz.JobBuilder;
import org.quartz.JobDetail;
import org.quartz.JobKey;
import org.quartz.Scheduler;
import org.quartz.SchedulerException;
import org.quartz.TriggerBuilder;
import org.quartz.TriggerKey;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.example.demo.entity.JobAndTrigger;
import com.example.demo.job.BaseJob;
import com.example.demo.service.IJobAndTriggerService;
import com.github.pagehelper.PageInfo;


@RestController
@RequestMapping(value="/job")
public class JobController 
{
   @Autowired
   private IJobAndTriggerService iJobAndTriggerService;
   
   //加入Qulifier注解，通过名称注入bean
   @Autowired @Qualifier("Scheduler")
   private Scheduler scheduler;
   
   private static Logger log = LoggerFactory.getLogger(JobController.class);  
   

   @PostMapping(value="/addjob")
   public void addjob(@RequestParam(value="jobClassName")String jobClassName, 
         @RequestParam(value="jobGroupName")String jobGroupName, 
         @RequestParam(value="cronExpression")String cronExpression) throws Exception
   {        
      addJob(jobClassName, jobGroupName, cronExpression);
   }
   
   public void addJob(String jobClassName, String jobGroupName, String cronExpression)throws Exception{
        
        // 启动调度器  
      scheduler.start(); 
      
      //构建job信息
      JobDetail jobDetail = JobBuilder.newJob(getClass(jobClassName).getClass()).withIdentity(jobClassName, jobGroupName).build();
      
      //表达式调度构建器(即任务执行的时间)
        CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);

        //按新的cronExpression表达式构建一个新的trigger
        CronTrigger trigger = TriggerBuilder.newTrigger().withIdentity(jobClassName, jobGroupName)
            .withSchedule(scheduleBuilder).build();
        
        try {
           scheduler.scheduleJob(jobDetail, trigger);
            
        } catch (SchedulerException e) {
            System.out.println("创建定时任务失败"+e);
            throw new Exception("创建定时任务失败");
        }
   }


   @PostMapping(value="/pausejob")
   public void pausejob(@RequestParam(value="jobClassName")String jobClassName, @RequestParam(value="jobGroupName")String jobGroupName) throws Exception
   {        
      jobPause(jobClassName, jobGroupName);
   }
   
   public void jobPause(String jobClassName, String jobGroupName) throws Exception
   {  
      scheduler.pauseJob(JobKey.jobKey(jobClassName, jobGroupName));
   }
   

   @PostMapping(value="/resumejob")
   public void resumejob(@RequestParam(value="jobClassName")String jobClassName, @RequestParam(value="jobGroupName")String jobGroupName) throws Exception
   {        
      jobresume(jobClassName, jobGroupName);
   }
   
   public void jobresume(String jobClassName, String jobGroupName) throws Exception
   {
      scheduler.resumeJob(JobKey.jobKey(jobClassName, jobGroupName));
   }
   
   
   @PostMapping(value="/reschedulejob")
   public void rescheduleJob(@RequestParam(value="jobClassName")String jobClassName, 
         @RequestParam(value="jobGroupName")String jobGroupName,
         @RequestParam(value="cronExpression")String cronExpression) throws Exception
   {        
      jobreschedule(jobClassName, jobGroupName, cronExpression);
   }
   
   public void jobreschedule(String jobClassName, String jobGroupName, String cronExpression) throws Exception
   {           
      try {
         TriggerKey triggerKey = TriggerKey.triggerKey(jobClassName, jobGroupName);
         // 表达式调度构建器
         CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(cronExpression);

         CronTrigger trigger = (CronTrigger) scheduler.getTrigger(triggerKey);

         // 按新的cronExpression表达式重新构建trigger
         trigger = trigger.getTriggerBuilder().withIdentity(triggerKey).withSchedule(scheduleBuilder).build();

         // 按新的trigger重新设置job执行
         scheduler.rescheduleJob(triggerKey, trigger);
      } catch (SchedulerException e) {
         System.out.println("更新定时任务失败"+e);
         throw new Exception("更新定时任务失败");
      }
   }
   
   
   @PostMapping(value="/deletejob")
   public void deletejob(@RequestParam(value="jobClassName")String jobClassName, @RequestParam(value="jobGroupName")String jobGroupName) throws Exception
   {        
      jobdelete(jobClassName, jobGroupName);
   }
   
   public void jobdelete(String jobClassName, String jobGroupName) throws Exception
   {     
      scheduler.pauseTrigger(TriggerKey.triggerKey(jobClassName, jobGroupName));
      scheduler.unscheduleJob(TriggerKey.triggerKey(jobClassName, jobGroupName));
      scheduler.deleteJob(JobKey.jobKey(jobClassName, jobGroupName));             
   }
   
   
   @GetMapping(value="/queryjob")
   public Map<String, Object> queryjob(@RequestParam(value="pageNum")Integer pageNum, @RequestParam(value="pageSize")Integer pageSize) 
   {        
      PageInfo<JobAndTrigger> jobAndTrigger = iJobAndTriggerService.getJobAndTriggerDetails(pageNum, pageSize);
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("JobAndTrigger", jobAndTrigger);
      map.put("number", jobAndTrigger.getTotal());
      return map;
   }
   
   public static BaseJob getClass(String classname) throws Exception 
   {
      Class<?> class1 = Class.forName(classname);
      return (BaseJob)class1.newInstance();
   }
   
   
}

```



### 运行结果：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191028174017.png)





