# springbatch 入门开课了

​        Spring Batch根植于Spring Framework大家庭，是一个轻量级的批处理框架，在企业级应用中，我们常见一些批处理业务场景，借助Spring Batch我们可以很方便的开发出健壮、易用的批处理应用。因为，Spring Framework框架可以说满足了开发人员对于理想框架的所有期望：高效的开发效率、基于POJO的开发方法、简单易用。另外，与市面上我们常见的调度框架： Quartz, Tivoli, Control-M等等不同，Spring Batch并不是一个调度框架，Spring Batch设计的初衷是与调度框架完美协作，而非作为一个潜在的调度框架选项。

基于代码简洁性与管理便捷性的考虑，在日常大数据处理业务场景中，我们应尽可能的发挥功能重用的优势。作为一个设计优良的批处理框架，SpringBatch提供了许多可重用的功能：日志跟踪、事务管理、任务处理统计、任务重启、跳过与资源管理等。此外，通过更为高级的优化及分区技术，Spring Batch提供支持大容量、高性能的批处理特性。Spring Batch可谓是“老少咸宜”，即可用作简单的文件读取或执行存储过程，也可用作复杂的、大容量的数据库与数据库之间的数据迁移、转换等场景。大容量批处理作业可以充分利用框架的可扩展特性来处理重要的业务信息。

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025173641.png)

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025173714.png)

## springboot项目引入依赖 pom.xml

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

## application.propertes

```
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.url=jdbc:mysql://localhost:3306/springbatch?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
spring.datasource.username=root
spring.datasource.password=root
spring.datasource.schema=classpath:/org/springframework/batch/core/schema-mysql.sql
spring.batch.initialize-schema=always

```



## Job和flow的创建和使用及其split实现并发执行

```
package com.yeshen.springbatch_demo.config;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.job.builder.FlowBuilder;
import org.springframework.batch.core.job.flow.Flow;
import org.springframework.batch.core.job.flow.JobExecutionDecider;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;

@Configuration
@EnableBatchProcessing
public class JobConfiguration {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Bean
    public Job  hellJob(){
        return jobBuilderFactory.get("hellJob")
                .start(step11())
                .split(new SimpleAsyncTaskExecutor()).add(flow()).end()
                .build();
    }

    @Bean
    public Step step11() {

        return stepBuilderFactory.get("step11")
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("step1  helloword666");
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }
    @Bean
    public Step step7() {

        return stepBuilderFactory.get("step7")
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("step2  helloword777");
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }
    @Bean
    public Flow flow() {
        return new FlowBuilder<Flow>("flow").start(step7()).build();
    }


}

```



## 决策器 JobExecutionDecider使用

```Java
package com.yeshen.springbatch_demo.config;

import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.StepContribution;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.job.builder.FlowBuilder;
import org.springframework.batch.core.job.flow.Flow;
import org.springframework.batch.core.job.flow.JobExecutionDecider;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.task.SimpleAsyncTaskExecutor;

@Configuration
@EnableBatchProcessing
public class JobDeciderConfiguration {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Bean
    public Job JobDecider(){
        return jobBuilderFactory.get("JobDecider")
                .start(yeshen01()).next(myDecider())
                .from(myDecider()).on("ou shu").to(yeshen02())
                .from(myDecider()).on("ji shu").to(yeshen03())
                .on("*").to(myDecider())
                .end()
                .build();
    }

    @Bean
    public Step yeshen01() {

        return stepBuilderFactory.get("yeshen01")
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("yeshen01  helloword666");
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }
    @Bean
    public Step yeshen02() {

        return stepBuilderFactory.get("yeshen02")
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("yeshen02  helloword666");
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }
    @Bean
    public Step yeshen03() {

        return stepBuilderFactory.get("yeshen03")
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("yeshen03  helloword666");
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }

    @Bean
    public JobExecutionDecider myDecider(){
        return  new MyDecider();
    }

}
```

### MyDecider.java

```
package com.yeshen.springbatch_demo.config;

import org.springframework.batch.core.JobExecution;
import org.springframework.batch.core.StepExecution;
import org.springframework.batch.core.job.flow.FlowExecutionStatus;
import org.springframework.batch.core.job.flow.JobExecutionDecider;

public class MyDecider implements JobExecutionDecider {
    private  int count;
    @Override
    public FlowExecutionStatus decide(JobExecution jobExecution, StepExecution stepExecution) {

       count++;
       if (count%2==0){
           return new FlowExecutionStatus("ou shu"); // 偶数
       }
       else {
           return new FlowExecutionStatus("ji shu"); // 奇数
       }

    }
}

```

**效果如图**

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025171306.png)



## Job参数

```
package com.yeshen.springbatch_demo.config;

import org.springframework.batch.core.*;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Map;

@Configuration
@EnableBatchProcessing
public class ParametersDemo implements StepExecutionListener {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    private Map<String,JobParameter> parameters;
    @Bean
    public Job  parametersJob(){
        return jobBuilderFactory.get("parametersJob")
                .start(parameterStep())
                .build();
    }

    @Bean
    public Step parameterStep() {

        return stepBuilderFactory.get("parameterStep")
                .listener(this)
                .tasklet(new Tasklet() {
                    @Override
                    public RepeatStatus execute(StepContribution stepContribution, ChunkContext chunkContext) throws Exception {
                        System.out.println("传递的参数"+parameters.get("info"));
                        return RepeatStatus.FINISHED;
                    }
                }).build();
    }


    @Override
    public void beforeStep(StepExecution stepExecution) {

        parameters=stepExecution.getJobParameters().getParameters();

    }

    @Override
    public ExitStatus afterStep(StepExecution stepExecution) {
        return null;
    }
}

```

**特别说明 参数info通过Program arguments传递**

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025214503.png)



**运行如图**

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025214337.png)





