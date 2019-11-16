# SpringBoot+SpringBatch+Quartz+Tk.Mapper实现动态配置定时任务及批处理数据库读取导入多个文件

[github源码](https://github.com/chenyeshen/springbatch_demo)

## 依赖及配置

### pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.2.0.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.yeshen</groupId>
    <artifactId>springbatch_demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>springbatch_demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-batch</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-quartz</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
            <exclusions>
                <exclusion>
                    <groupId>org.junit.vintage</groupId>
                    <artifactId>junit-vintage-engine</artifactId>
                </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.springframework.batch</groupId>
            <artifactId>spring-batch-test</artifactId>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.springframework/spring-oxm -->
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-oxm</artifactId>
            <version>5.1.4.RELEASE</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/com.thoughtworks.xstream/xstream -->
        <dependency>
            <groupId>com.thoughtworks.xstream</groupId>
            <artifactId>xstream</artifactId>
            <version>1.4.11.1</version>
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
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper-spring-boot-starter</artifactId>
            <version>2.0.0</version>
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

### application.properties

```
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/springbatch?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.schema=classpath:/org/springframework/batch/core/schema-mysql.sql
spring.batch.initialize-schema=always
spring.batch.job.enabled=false


```

## 创建springbatch数据库

###  新建config表和user表  

```
DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `id` int(11) NOT NULL,
  `cron` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of config
-- ----------------------------
INSERT INTO `config` VALUES ('1', '0 8 12 27 10 ? ');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `passwd` varchar(255) DEFAULT '',
  `name` varchar(255) DEFAULT NULL,
  `id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1234', 'yeshen1', '1');
INSERT INTO `user` VALUES ('2345', 'yeda2', '2');
INSERT INTO `user` VALUES ('3456', 'yeshe3', '3');
INSERT INTO `user` VALUES ('1234', 'yeshen1', '5');
INSERT INTO `user` VALUES ('2345', 'yeshen2', '6');
INSERT INTO `user` VALUES ('3456', 'yeshen3', '7');
INSERT INTO `user` VALUES ('4567', 'yeshen4', '8');
INSERT INTO `user` VALUES ('1234', 'yeshen1', '9');
INSERT INTO `user` VALUES ('2345', 'yeshen2', '10');
INSERT INTO `user` VALUES ('3456', 'yeshen3', '11');
INSERT INTO `user` VALUES ('4567', 'yeshen4', '12');

```



## quartz定时任务

### config.java

```
package com.yeshen.springbatch_demo.quartz;

import lombok.Data;

import javax.persistence.Id;

@Data

public class Config {

    @Id
    private Integer id;

    private String cron;

}
```

### QuartzConfig.java

```
package com.yeshen.springbatch_demo.quartz;

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

### QuartzMapper.java

```
package com.yeshen.springbatch_demo.quartz;

import org.springframework.stereotype.Component;
import tk.mybatis.mapper.common.Mapper;


@org.apache.ibatis.annotations.Mapper
@Component
public interface QuartzMapper extends Mapper<Config> {

}

```

### ScheduledTask.java

```
package com.yeshen.springbatch_demo.quartz;

import lombok.extern.slf4j.Slf4j;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.JobParameters;
import org.springframework.batch.core.JobParametersBuilder;
import org.springframework.batch.core.JobParametersInvalidException;
import org.springframework.batch.core.launch.JobLauncher;
import org.springframework.batch.core.repository.JobExecutionAlreadyRunningException;
import org.springframework.batch.core.repository.JobInstanceAlreadyCompleteException;
import org.springframework.batch.core.repository.JobRestartException;
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
    private JobLauncher jobLauncher;

    @Autowired
    private Job dbWriteToMultFileJobLaucherQuartz;
    public void sayHello() {

        JobParameters jobParameters = new JobParametersBuilder()
                //.addString("msg", "yeshen的消息")
                .toJobParameters();
        try {
            jobLauncher.run(dbWriteToMultFileJobLaucherQuartz,jobParameters);

            log.info("任务执行成功  写入数据啦");
        } catch (JobExecutionAlreadyRunningException e) {
            e.printStackTrace();
        } catch (JobRestartException e) {
            e.printStackTrace();
        } catch (JobInstanceAlreadyCompleteException e) {
            e.printStackTrace();
        } catch (JobParametersInvalidException e) {
            e.printStackTrace();
        }


    }
}
```

### ScheduleRefreshService.java

```
package com.yeshen.springbatch_demo.quartz;

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
    private QuartzMapper quartzMapper;

    @Resource(name = "jobDetail")
    private JobDetail jobDetail;

    @Resource(name = "jobTrigger")
    private CronTrigger cronTrigger;

    @Resource(name = "scheduler")
    private Scheduler scheduler;

    /**
     * 功能：每隔10s查库，并根据查询结果决定是否重新设置定时任务
     */
    @Scheduled(fixedRate = 10000)
    public void scheduleUpdateCronTrigger() throws SchedulerException {
        CronTrigger trigger = (CronTrigger) scheduler.getTrigger(cronTrigger.getKey());
        //当前Trigger使用的
        String currentCron = trigger.getCronExpression();
        log.info("currentCron Trigger:{}", currentCron);
        //从数据库查询出来的
        String searchCron = quartzMapper.selectByPrimaryKey(1).getCron();
        log.info("searchCron Trigger:{}", searchCron);

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



## SpringBatch批处理 从数据库读取 导入多个文件

### User.java

```
package com.yeshen.springbatch_demo.bean;

public class User {

    private  int id;

    private  String name;

    private  String passwd;

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", passwd='" + passwd + '\'' +
                '}';
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPasswd() {
        return passwd;
    }

    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
}

```

### DbWriterToMultFileDemo.java

```
package com.yeshen.springbatch_demo.DbWriterToFile;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.core.*;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.database.BeanPropertyItemSqlParameterSourceProvider;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.JdbcPagingItemReader;
import org.springframework.batch.item.database.Order;
import org.springframework.batch.item.database.support.MySqlPagingQueryProvider;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.mapping.FieldSetMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.batch.item.file.transform.FieldSet;
import org.springframework.batch.item.file.transform.LineAggregator;
import org.springframework.batch.item.support.CompositeItemWriter;
import org.springframework.batch.item.xml.StaxEventItemWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.oxm.xstream.XStreamMarshaller;
import org.springframework.validation.BindException;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class DbWriterToMultFileDemo  implements StepExecutionListener {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Bean
    public Job dbWriteToMultFileJobLaucherQuartz(){

        return  jobBuilderFactory.get("dbWriteToMultFileJobLaucherQuartz")
                .start(DbWriteToMultFileStep())
                .build();
    }

    @Bean
    public Step DbWriteToMultFileStep(){
        return  stepBuilderFactory.get("DbWriteToMultFileStep")
                .listener(this)
                .<User,User>chunk(2)
                .reader(multDbItemRead())
                .writer(multFileCompositeItemWriter())
                .build();
    }

    @Bean
    public FlatFileItemWriter<User> multFileItemWrite() {
        FlatFileItemWriter<User> userFlatFileItemWriter = new FlatFileItemWriter<>();
        String path="d:\\user.txt";
        userFlatFileItemWriter.setResource(new FileSystemResource(path));
        userFlatFileItemWriter.setLineAggregator(new LineAggregator<User>() {
            @Override
            public String aggregate(User user) {
                String str=null;
                ObjectMapper mapper=new ObjectMapper();
                try {
                    str= mapper.writeValueAsString(user);
                } catch (JsonProcessingException e) {
                    e.printStackTrace();
                }
                return str;
            }
        });
        try {
            userFlatFileItemWriter.afterPropertiesSet();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return  userFlatFileItemWriter;
    }
    @Bean
    public StaxEventItemWriter<User> xmlMultFileItemWrite() {
        StaxEventItemWriter<User> userStaxEventItemWriter = new StaxEventItemWriter<>();
        userStaxEventItemWriter.setRootTagName("Users");
        XStreamMarshaller marshaller=new XStreamMarshaller();
        Map<String,Class> aliasesMap=new HashMap<>();
        aliasesMap.put("User",User.class);
        marshaller.setAliases(aliasesMap);
        userStaxEventItemWriter.setMarshaller(marshaller);
        try {
            userStaxEventItemWriter.afterPropertiesSet();
        } catch (Exception e) {
            e.printStackTrace();
        }

        String path="d:\\user.xml";
        userStaxEventItemWriter.setResource(new FileSystemResource(path));

        return userStaxEventItemWriter;
    }

    @Bean
    @StepScope
    public JdbcPagingItemReader<User> multDbItemRead() {
        JdbcPagingItemReader<User> reader = new JdbcPagingItemReader<>();
        reader.setDataSource(dataSource);
        reader.setRowMapper(new RowMapper<User>() {
            @Override
            public User mapRow(ResultSet resultSet, int i) throws SQLException {
                User user = new User();
                user.setId(resultSet.getInt(1));
                user.setName(resultSet.getString(2));
                user.setPasswd(resultSet.getString(3));
                return user;
            }
        });
        MySqlPagingQueryProvider mySqlPagingQueryProvider=new MySqlPagingQueryProvider();
        mySqlPagingQueryProvider.setSelectClause("id,name,passwd");
        mySqlPagingQueryProvider.setFromClause("from user");

        Map<String, Order> orderHashMap = new HashMap<>(1);
        orderHashMap.put("id",Order.ASCENDING);

        mySqlPagingQueryProvider.setSortKeys(orderHashMap);
        reader.setQueryProvider(mySqlPagingQueryProvider);

        return reader;

    }
    //输出数据到多个文件
    @Bean
    public CompositeItemWriter<User> multFileCompositeItemWriter(){
        CompositeItemWriter<User> userCompositeItemWriter = new CompositeItemWriter<>();
        userCompositeItemWriter.setDelegates(Arrays.asList(xmlMultFileItemWrite(),multFileItemWrite()));
        try {
            userCompositeItemWriter.afterPropertiesSet();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return userCompositeItemWriter;
    }

    @Override
    public void beforeStep(StepExecution stepExecution) {
       // Map<String, JobParameter> parameters = stepExecution.getJobParameters().getParameters();
        //System.out.println("任务来了jobParameter"+parameters.get("msg").getValue());
        System.out.println("任务来了jobParameter");
    }

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        return null;
    }
}

```

## D盘新建两个文件 user.txt和user.xml

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191027123302.png)



## 运行结果为：10月27日12时8分0秒定时任务 

### 控制台

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191027123718.png)



### 查看user.xml

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191027123808.png)

### 查看user.txt

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191027123926.png)