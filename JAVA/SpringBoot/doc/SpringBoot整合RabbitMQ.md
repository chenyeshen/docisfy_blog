RabbitMQ是开源消息队列系统，用erlang语言开发。如果不了解可以查看官网<http://www.rabbitmq.com/>

这篇文章介绍一个springboot简单整合RabbitMQ。

### 1.安装rabbitmq，自行百度即可，方法很多。

### 2.启动rabbitmq，成功如下图：

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528113701519.png)

可以访问<http://localhost:15672/>查看管理页面

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528113702393.png)

### pom文件加入依赖，完整pom如下：

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.dalaoyang</groupId>
    <artifactId>springboot_rabbitmq</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>springboot_rabbitmq</name>
    <description>springboot_rabbitmq</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.9.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-amqp</artifactId>
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

### 新建一个消息发送者Sender，使用AmqpTemplate将消息发送到消息队列message中去。

代码如下：

```
package com.dalaoyang.sender;

import org.apache.log4j.Logger;
import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Date;

/** * @author dalaoyang * @Description * @project springboot_learn * @package com.dalaoyang.send * @email yangyang@dalaoyang.cn * @date 2018/4/25 */
@Component
public class Sender {
    Logger logger = Logger.getLogger(Sender.class);

    @Autowired
    private AmqpTemplate amqpTemplate;

    public String send(){
        String context = "简单消息发送";
        logger.info("简单消息发送时间："+new Date());
        amqpTemplate.convertAndSend("message", context);
        return "发送成功";
    }
}
```

### 创建消息接收者Receiver，使用注解@RabbitListener(queues = “message”)来监听message的消息队列@RabbitHandler来实现具体消费。

```
package com.dalaoyang.receiver;

import org.apache.log4j.Logger;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

import java.util.Date;

/** * @author dalaoyang * @Description * @project springboot_learn * @package com.dalaoyang.receiver * @email yangyang@dalaoyang.cn * @date 2018/4/25 */
@Component
@RabbitListener(queues = "message")
public class Receiver {
    Logger logger = Logger.getLogger(Receiver.class);

    @RabbitHandler
    public void process(String Str) {
        logger.info("接收消息："+Str);
        logger.info("接收消息时间："+new Date());
    }
}
```

### 然后看一下配置信息，因为是简单整合，所以只配置了端口和rabbitmq的信息，如下：

```
##端口号
server.port=8888

##rabbitmq
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
```

### 创建一个controller，这里仅用来测试，代码如下：

```
package com.dalaoyang.controller;

import com.dalaoyang.sender.Sender;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** * @author dalaoyang * @Description * @project springboot_learn * @package com.dalaoyang.controller * @email yangyang@dalaoyang.cn * @date 2018/4/25 */
@RestController
public class TestController {

    @Autowired
    private Sender sender;

    @GetMapping("hello")
    public String helloTest(){
        sender.send();
        return "success";
    }

}
```

### 启动项目

访问<http://localhost:8888/hello>然后观看控制台可以看到消息已经发送成功。

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528113704079.png)

