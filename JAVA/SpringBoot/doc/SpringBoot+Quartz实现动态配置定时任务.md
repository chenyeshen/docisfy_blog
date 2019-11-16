### 一、Quartz简介

**了解 Quartz** 

- Quartz 是一个完全由 Java 编写的开源作业调度框架，为在 Java 应用程序中进行作业调度提供了简单却强大的机制。

- Quartz 可以与 J2EE 与 J2SE 应用程序相结合也可以单独使用。
- Quartz 允许程序开发人员根据时间的间隔来调度作业。
- Quartz 实现了作业和触发器的多对多的关系，还能把多个作业与不同的触发器关联。
- Quartz 核心概念


- Job 表示一个工作，要执行的具体内容。此接口中只有一个方法，如下：void execute(JobExecutionContext context)

- JobDetail 表示一个具体的可执行的调度程序，Job 是这个可执行程调度程序所要执行的内容，另外 JobDetail 还包含了这个任务调度的方案和策略。 
- Trigger 代表一个调度参数的配置，什么时候去调。 
- Scheduler 代表一个调度容器，一个调度容器中可以注册多个 JobDetail 和 Trigger。当 Trigger 与 JobDetail 组合，就可以被 Scheduler 容器调度了。
- 集群Quartz应用


- 伸缩性

- 高可用性

- 负载均衡

- Quartz可以借助关系数据库和JDBC作业存储支持集群。

- Terracotta扩展quartz提供集群功能而不需要数据库支持

  ### 二、代码测试

  ### **1、添加相关依赖pom.xml**


```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.7.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.security</groupId>
            <artifactId>spring-security-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper-spring-boot-starter</artifactId>
            <version>2.0.0</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-quartz</artifactId>
            <version>2.1.7.RELEASE</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid</artifactId>
            <version>1.1.16</version>
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

</project>
```

​	

### **2、创建配置实体类：**

```
package com.example.demo.quartz;

import lombok.Data;

import javax.persistence.Id;

@Data

public class Config {

    @Id
    private Integer id;

    private String cron;

}

```

### **3、创建任务类，添加注解@EnableScheduling（标注启动定时任务）**

```
package com.example.demo.quartz;


import com.example.demo.User;
import com.example.demo.UserMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.stereotype.Component;


@Slf4j
@Configuration
@Component
@EnableScheduling
public class ScheduledTask {

    @Autowired
    private UserMapper userMapper;

    public void sayHello() {

        log.info("tast被调用了");

        User user = new User();
        user.setUsername("haha");
        user.setPassword("hdhdh");
        userMapper.insertSelective(user);


    }
}

```



### **4、Quartz配置类**

```
package com.example.demo.quartz;

import lombok.extern.slf4j.Slf4j;
import org.quartz.Trigger;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.quartz.CronTriggerFactoryBean;
import org.springframework.scheduling.quartz.MethodInvokingJobDetailFactoryBean;
import org.springframework.scheduling.quartz.SchedulerFactoryBean;

@Slf4j
@Configuration
public class QuartzConfig {

    @Bean(name = "jobDetail")
    public MethodInvokingJobDetailFactoryBean detailFactoryBean(ScheduledTask task){
        MethodInvokingJobDetailFactoryBean jobDetail = new MethodInvokingJobDetailFactoryBean();
        /*
         * 是否并发执行
         * 例如每5s执行一次任务，但是当前任务还没有执行完，就已经过了5s了，
         * 如果此处为true，则下一个任务会执行，如果此处为false，则下一个任务会等待上一个任务执行完后，再开始执行
         */
        jobDetail.setConcurrent(false);
        //设置定时任务的名字
        jobDetail.setName("srd-demo");
        //设置任务的分组，这些属性都可以在数据库中，在多任务的时候使用
        jobDetail.setGroup("srd");

        //为需要执行的实体类对应的对象
        jobDetail.setTargetObject(task);

        /*
         * sayHello为需要执行的方法
         * 通过这几个配置，告诉JobDetailFactoryBean我们需要执行定时执行ScheduleTask类中的sayHello方法
         */
        jobDetail.setTargetMethod("sayHello");
        log.info("jobDetail 初始化成功！");
        return jobDetail;
    }


    @Bean(name = "jobTrigger")
    public CronTriggerFactoryBean cronTriggerFactoryBean(MethodInvokingJobDetailFactoryBean jobDetail){
        CronTriggerFactoryBean trigger = new CronTriggerFactoryBean();
        trigger.setJobDetail(jobDetail.getObject());
        //初始化的cron表达式(每天上午10:15触发)
        trigger.setCronExpression("0/5 10 * * * ?");
        //trigger的name
        trigger.setName("srd-demo");
        log.info("jobTrigger 初始化成功！");
        return trigger;
    }

   
    @Bean(name = "scheduler")
    public SchedulerFactoryBean schedulerFactoryBean(Trigger trigger){
        SchedulerFactoryBean factoryBean = new SchedulerFactoryBean();
        //用于quartz集群，QuartzScheduler启动时更新已存在的job
        factoryBean.setOverwriteExistingJobs(true);
        //延时启动，应用启动1秒后
        factoryBean.setStartupDelay(1);
        //注册触发器
        factoryBean.setTriggers(trigger);
        log.info("scheduler 初始化成功！");
        return factoryBean;
    }
}


```

MethodInvokingJobDetailFactoryBean：此工厂主要用来制作一个jobDetail，即制作一个任务。由于我们所做的定时任务根本上讲其实就是执行一个方法。所以用这个工厂比较方便。

注意：其setTargetObject所设置的是一个对象而不是一个类。

CronTriggerFactoryBean：定义一个触发器。

注意：setCronExpression：是一个表达式，如果此表达式不合规范，即会抛出异常。

SchedulerFactoryBean：主要的管理的工厂，这是最主要的一个bean。quartz通过这个工厂来进行对各触发器的管理。

### **5、定时查询数据库，并更新任务**

```
package com.example.demo.quartz;

import lombok.extern.slf4j.Slf4j;
import org.quartz.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;

@Slf4j
@Configuration
@EnableScheduling
@Component
public class ScheduleRefreshService {

    @Autowired
    private QuartzMapper configMapper;

    @Resource(name = "jobDetail")
    private JobDetail jobDetail;

    @Resource(name = "jobTrigger")
    private CronTrigger cronTrigger;

    @Resource(name = "scheduler")
    private Scheduler scheduler;

    /**
     * 方法名：
     * 功能：每隔10s查库，并根据查询结果决定是否重新设置定时任务
     * 描述：
     * 创建人：typ
     * 创建时间：2018/10/10 14:19
     * 修改人：
     * 修改描述：
     * 修改时间：
     */
    @Scheduled(fixedRate = 10000)
    public void scheduleUpdateCronTrigger() throws SchedulerException {
        CronTrigger trigger = (CronTrigger) scheduler.getTrigger(cronTrigger.getKey());
        //当前Trigger使用的
        String currentCron = trigger.getCronExpression();
        log.info("currentCron Trigger:{}", currentCron);
        //从数据库查询出来的
        String searchCron = configMapper.selectByPrimaryKey(1).getCron();
        log.info("searchCron  Trigger:{}", searchCron);

        if (currentCron.equals(searchCron)) {
            // 如果当前使用的cron表达式和从数据库中查询出来的cron表达式一致，则不刷新任务
        } else {
            //表达式调度构建器
            CronScheduleBuilder scheduleBuilder = CronScheduleBuilder.cronSchedule(searchCron);
            //按新的cronExpression表达式重新构建trigger
            trigger = (CronTrigger) scheduler.getTrigger(cronTrigger.getKey());
            trigger = trigger.getTriggerBuilder().withIdentity(cronTrigger.getKey()).withSchedule(scheduleBuilder).build();
            // 按新的trigger重新设置job执行
            scheduler.rescheduleJob(cronTrigger.getKey(), trigger);
            currentCron = searchCron;
        }
    }

}

```

### **6、配置数据库连接application.yml**


    quartz:
      enabled: true
    server:
      port: 8080
    spring:
      datasource:
        url: jdbc:mysql://localhost:3306/security_demo?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
        username: root
        password: root
        driver-class-name: com.mysql.cj.jdbc.Driver

### **7、相关表及测试数据**

create table config(

	id int(10),
	cron varchar(40),
	primary key(id)
	);
	
	insert into config(id,cron) values(1,'0 0/2 * * * ?'); //每隔2分钟执行一次

**cronExpression表达式：　**

| 字段    | 允许值             | 允许的特殊字符         |
| ----- | --------------- | --------------- |
| 秒     | 0-59            | , - * /         |
| 分     | 0-59            | , - * /         |
| 时     | 0-23            | , - * /         |
| 日期    | 1-31            | , - *   / L W C |
| 月份    | 1-12 或者 JAN-DEC | , - * /         |
| 星期    | 1-7 或者 SUN-SAT  | , - *   / L C # |
| 年（可选） | 留空, 1970-2099   | , - * /         |

- “*”字符被用来指定所有的值。如：”*“在分钟的字段域里表示“每分钟”。 

- “-”字符被用来指定一个范围。如：“10-12”在小时域意味着“10点、11点、12点”。
- “,”字符被用来指定另外的值。如：“MON,WED,FRI”在星期域里表示”星期一、星期三、星期五”。
- “?”字符只在日期域和星期域中使用。它被用来指定“非明确的值”。当你需要通过在这两个域中的一个来指定一些东西的时候，它是有用的。看下面的例子你就会明白。
- “L”字符指定在月或者星期中的某天（最后一天）。即“Last ”的缩写。但是在星期和月中“Ｌ”表示不同的意思，如：在月子段中“L”指月份的最后一天-1月31日，2月28日，如果在星期字段中则简单的表示为“7”或者“SAT”。如果在星期字段中在某个value值得后面，则表示“某月的最后一个星期value”,如“6L”表示某月的最后一个星期五。
- “W”字符只能用在月份字段中，该字段指定了离指定日期最近的那个星期日。
- “#”字符只能用在星期字段，该字段指定了第几个星期value在某月中。
- 每一个元素都可以显式地规定一个值（如6），一个区间（如9-12），一个列表（如9，11，13）或一个通配符（如*）。“月份中的日期”和“星期中的日期”这两个元素是互斥的，因此应该通过设置一个问号（？）来表明你不想设置的那个字段。 

cron表达式：

### **表达式**

- "0 0 12 * * ?"	 	每天中午12点触发

  - "0 15 10 ? * *" 	每天上午10:15触发

    - "0 15 10 * * ?" 每天上午10:15触发

    - "0 15 10 * * ? *" 每天上午10:15触发

    - "0 15 10 * * ? 2005" 2005年的每天上午10:15触发

    - "0 * 14 * * ?" 在每天下午2点到下午2:59期间的每1分钟触发

    - "0 0/5 14 * * ?" 在每天下午2点到下午2:55期间的每5分钟触发

    - "0 0/5 14,18 * * ?" 在每天下午2点到2:55期间和下午6点到6:55期间的每5分钟触发

    - "0 0-5 14 * * ?" 在每天下午2点到下午2:05期间的每1分钟触发

    - "0 10,44 14 ? 3 WED" 每年三月的星期三的下午2:10和2:44触发

    - "0 15 10 ? * MON-FRI" 周一至周五的上午10:15触发

    - "0 15 10 15 * ?" 每月15日上午10:15触发

    - "0 15 10 L * ?" 每月最后一日的上午10:15触发

    - "0 15 10 ? * 6L" 每月的最后一个星期五上午10:15触发 

    - "0 15 10 ? * 6L 2002-2005" 2002年至2005年的每月的最后一个星期五上午10:15触发

    - "0 15 10 ? * 6#3" 每月的第三个星期五上午10:15触发

- 每天早上6点： 0 6 * * * 

- 每两个小时： 0 */2 * * * 

- 晚上11点到早上8点之间每两个小时，早上八点 ：0 23-7/2，8 * * * 

- 每个月的4号和每个礼拜的礼拜一到礼拜三的早上11点 ：0 11 4 * 1-3 

- 月1日早上4点 ：0 4 1 1 *

  ​