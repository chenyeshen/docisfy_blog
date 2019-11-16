# SpringBoot 整合RabbitMq 学习初探

### pom.xml

```
dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

### application.properties

```
spring.rabbitmq.host=localhost
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest

```



## 发送对象

首先我们创建一个实体类对象 User,注意必须**实现 Serializable 接口**.

```
package com.yeshen.rabbitmq_demo.test2;

import java.io.Serializable;

public class User   {
    private  String name;
    private  String passwd;

    @Override
    public String toString() {
        return "User{" +
                "name='" + name + '\'' +
                ", passwd='" + passwd + '\'' +
                '}';
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



### 队列 TestQueueConfig.java

```
package com.yeshen.rabbitmq_demo.test2;

import org.springframework.amqp.core.Queue;
import org.springframework.context.annotation.Bean;
import org.springframework.stereotype.Component;

@Component
public class TestQueueConfig {

    @Bean
    public Queue queue(){
        return new Queue("zhu");
    }
}

```



### 发送者 UserSender.java

```
package com.yeshen.rabbitmq_demo.test2;

import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class UserSender {

    @Autowired
    RabbitTemplate rabbitTemplate;
    
    public void send(User user){
        rabbitTemplate.convertAndSend("zhu",user); // 发送user到zhu消息队列
    }
}

```



### 接收者 UserReciever.java

```
package com.yeshen.rabbitmq_demo.test2;

import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

@Component
@RabbitListener(queues ="zhu")
public class UserReciever {
    //消息处理器
    @RabbitHandler
    //发送方发送user数据类型   这里必须以user数据类型接收
    public void getMsg(User msg){
        System.out.println("拿到消息为"+msg);
    }
}

```

### 单元测试

```
package com.yeshen.rabbitmq_demo;

import com.yeshen.rabbitmq_demo.sender.YeshenSender;
import com.yeshen.rabbitmq_demo.test2.User;
import com.yeshen.rabbitmq_demo.test2.UserSender;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class RabbitmqDemoApplicationTests {

    @Autowired
    UserSender userSender;

    @Test
    void contextLoads() {
        User user = new User();
        user.setName("haha");
        user.setPasswd("haoki");

        userSender.send(user);

    }

}

```
## Topic Exchange

**topic 是RabbitMQ中最灵活的一种方式，可以根据routing_key自由的绑定不同的队列**

首先对topic规则配置，这里使用两个队列来测试

```
package com.example.rabbitmqdemo.config;

import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author itguang
 * @create 2018-04-21 16:10
 **/
@Configuration
public class TopicRabbitConfig {


    final static String message = "topic.message";
    final static String messages = "topic.messages";


    //创建两个 Queue
    @Bean
    public Queue queueMessage(){
        return new Queue(TopicRabbitConfig.message);
    }

    @Bean
    public Queue queueMessages(){
        return new Queue(TopicRabbitConfig.messages);
    }

    //配置 TopicExchange,指定名称为 topicExchange
    @Bean
    public TopicExchange exchange(){
        return new TopicExchange("topicExchange");
    }

    //给队列绑定 exchange 和 routing_key

    @Bean
    public Binding bindingExchangeMessage(Queue queueMessage, TopicExchange exchange){
        return BindingBuilder.bind(queueMessage).to(exchange).with("topic.message");
    }

    @Bean
    public Binding bingingExchangeMessages(Queue queueMessages,TopicExchange exchange){
        return BindingBuilder.bind(queueMessages).to(exchange).with("topic.#");
    }


}


```

**消息发送者:都是用topicExchange,并且绑定到不同的 routing_key**

```
package com.example.rabbitmqdemo.topic;

import org.springframework.amqp.core.AmqpTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * @author itguang
 * @create 2018-04-21 16:26
 **/
@Component
public class TopicSender {

    @Autowired
    AmqpTemplate amqpTemplate;

    public void send1(){
        String context = "hi, i am message 1";
        System.out.println("Sender : " + context);
        amqpTemplate.convertAndSend("topicExchange","topic.message",context);
    }

    public void send2() {
        String context = "hi, i am messages 2";
        System.out.println("Sender : " + context);
        amqpTemplate.convertAndSend("topicExchange", "topic.messages", context);
    }
}

```

**两个消息接受者,分别指定不同的 queue**

```
package com.example.rabbitmqdemo.topic;

import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;


@Component
@RabbitListener(queues = "topic.message")
public class TopicReceiver1 {

    @RabbitHandler
    public void process(String message){

        System.out.println("Receiver topic.message :"+ message);

    }

}

```

```
package com.example.rabbitmqdemo.topic;

import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.stereotype.Component;

/**
 * @author itguang
 * @create 2018-04-21 16:34
 **/
@Component
@RabbitListener(queues = "topic.messages")
public class TopicReceiver2 {

    @RabbitHandler
    public void process(String message){

        System.out.println("Receiver topic.messages: "+ message);

    }

}

```

测试:

**发送send1会匹配到topic.#和topic.message 两个Receiver都可以收到消息，发送send2只有topic.#可以匹配所有只有Receiver2监听到消息**