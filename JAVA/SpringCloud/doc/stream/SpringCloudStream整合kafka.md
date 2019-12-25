# SpringCloudStream整合kafka

## **为什么需要SpringCloud Stream消息驱动呢？**

　　比方说我们用到了RabbitMQ和Kafka，由于这两个消息中间件的架构上的不同，像RabbitMQ有exchange，kafka有Topic，partitions分区，这些中间件的差异性导致我们实际项目开发给我们造成了一定的困扰，我们如果用了两个消息队列的其中一种，后面的业务需求，我想往另外一种消息队列进行迁移，这时候无疑就是一个灾难性的，一大堆东西都要重新推倒重新做，因为它跟我们的系统耦合了，这时候springcloud Stream给我们提供了一种解耦合的方式。

​       Spring Cloud Stream 是一个构建消息驱动微服务的框架。应用程序通过 inputs 或者 outputs 来与 Spring Cloud Stream 中binder 交互，通过我们配置来 binding ，而 Spring Cloud Stream 的 binder 负责与中间件交互。所以，我们只需要搞清楚如何与 Spring Cloud Stream 交互就可以方便使用消息驱动的方式。

​       Spring Cloud Stream由一个中间件中立的核组成。应用通过Spring Cloud Stream插入的input(相当于消费者consumer，它是从队列中接收消息的)和output(相当于生产者producer，它是从队列中发送消息的。)通道与外界交流。

通道通过指定中间件的Binder实现与外部代理连接。业务开发者不再关注具体消息中间件，只需关注Binder对应用程序提供的抽象概念来使用消息中间件实现业务即可。

![img](https://img-blog.csdnimg.cn/20190605101928377.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L0ppblhZYW4=,size_16,color_FFFFFF,t_70)

## Binder

​       Binder 是 Spring Cloud Stream 的一个抽象概念，是应用与消息中间件之间的粘合剂。目前 Spring Cloud Stream 实现了 Kafka 和 Rabbit MQ 的binder。

​       通过 binder ，可以很方便的连接中间件，可以动态的改变消息的destinations（对应于 Kafka 的topic，Rabbit MQ 的 exchanges），这些都可以通过外部配置项来做到。甚至可以任意的改变中间件的类型而不需要修改一行代码。

## Publish-Subscribe

​        消息的发布（Publish）和订阅（Subscribe）是事件驱动的经典模式。Spring Cloud Stream 的数据交互也是基于这个思想。生产者把消息通过某个 topic 广播出去（Spring Cloud Stream 中的 destinations）。其他的微服务，通过订阅特定 topic 来获取广播出来的消息来触发业务的进行。

​        这种模式，极大的降低了生产者与消费者之间的耦合。即使有新的应用的引入，也不需要破坏当前系统的整体结构。

## Consumer Groups

​       “Group”，如果使用过 Kafka 的童鞋并不会陌生。Spring Cloud Stream 的这个分组概念的意思基本和 Kafka 一致。

​       微服务中动态的缩放同一个应用的数量以此来达到更高的处理能力是非常必须的。对于这种情况，同一个事件防止被重复消费，只要把这些应用放置于同一个 “group” 中，就能够保证消息只会被其中一个应用消费一次。

## Bindings

​        bindings 是我们通过配置把应用和spring cloud stream 的 binder 绑定在一起，之后我们只需要修改 binding 的配置来达到动态修改topic、exchange、type等一系列信息而不需要修改一行代码。

## 一、关于Spring-Cloud-Stream

　　Spring Cloud Stream本质上就是整合了Spring Boot和Spring Integration，实现了一套轻量级的消息驱动的微服务框架。通过使用Spring Cloud Stream，可以有效地简化开发人员对消息中间件的使用复杂度，让系统开发人员可以有更多的精力关注于核心业务逻辑的处理。

　　在这里我先放一张官网的图：

![SCSt与粘合剂](https://springcloud.cc/images/SCSt-with-binder.png)

　　应用程序通过Spring Cloud Stream注入到输入和输出通道与外界进行通信。根据此规则我们很容易的实现消息传递，订阅消息与消息中转。并且当需要切换消息中间件时，几乎不需要修改代码，只需要变更配置就行了。

　　在用例图中 Inputs代表了应用程序监听消息 、outputs代表发送消息、binder的话大家可以理解为将应用程序与消息中间件隔离的抽象，类似于三层架构下利用dao屏蔽service与数据库的实现的原理。

　　springcloud默认提供了rabbitmq与kafka的实现。

 

## 二、springcloud集成kafka

### 1、添加gradle依赖：

```
dependencies{
    compile('org.springframework.cloud:spring-cloud-stream')
    compile('org.springframework.cloud:spring-cloud-stream-binder-kafka')
    compile('org.springframework.kafka:spring-kafka')
}
```

### 2、定义一个接口：

　　spring-cloud-stream已经给我们定义了最基本的输入与输出接口，他们分别是 Source,Sink, Processor

　　Sink接口：



```
package org.springframework.cloud.stream.messaging;

import org.springframework.cloud.stream.annotation.Input;
import org.springframework.messaging.SubscribableChannel;

public interface Sink {
    String INPUT = "input";

    @Input("input")
    SubscribableChannel input();
}
```



　　Source接口:



```
package org.springframework.cloud.stream.messaging;

import org.springframework.cloud.stream.annotation.Output;
import org.springframework.messaging.MessageChannel;

public interface Source {
    String OUTPUT = "output";

    @Output("output")
    MessageChannel output();
}
```



　　Processor接口：

```
package org.springframework.cloud.stream.messaging;

public interface Processor extends Source, Sink {
}
```

　　这里面Processor这个接口既定义输入通道又定义了输出通道。同时我们也可以自己定义通道接口，代码如下：



```
package com.bdqn.lyrk.shop.channel;

import org.springframework.cloud.stream.annotation.Input;
import org.springframework.cloud.stream.annotation.Output;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.SubscribableChannel;

public interface ShopChannel {

    /**
     * 发消息的通道名称
     */
    String SHOP_OUTPUT = "shop_output";

    /**
     * 消息的订阅通道名称
     */
    String SHOP_INPUT = "shop_input";

    /**
     * 发消息的通道
     *
     * @return
     */
    @Output(SHOP_OUTPUT)
    MessageChannel sendShopMessage();

    /**
     * 收消息的通道
     *
     * @return
     */
    @Input(SHOP_INPUT)
    SubscribableChannel recieveShopMessage();


}
```



 

### 3、定义服务类



```
package com.bdqn.lyrk.shop.server;

import com.bdqn.lyrk.shop.channel.ShopChannel;
import org.springframework.cloud.stream.annotation.StreamListener;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.annotation.Resource;

@RestController
public class ShopService {

    @Resource(name = ShopChannel.SHOP_OUTPUT)
    private MessageChannel sendShopMessageChannel;

    @GetMapping("/sendMsg")
    public String sendShopMessage(String content) {
        boolean isSendSuccess = sendShopMessageChannel.
                send(MessageBuilder.withPayload(content).build());
        return isSendSuccess ? "发送成功" : "发送失败";
    }

    @StreamListener(ShopChannel.SHOP_INPUT)
    public void receive(Message<String> message) {
        System.out.println(message.getPayload());
    }
}
```



　　这里面大家注意 @StreamListener。这个注解可以监听输入通道里的消息内容，注解里面的属性指定我们刚才定义的输入通道名称，而MessageChannel则可以通过

输出通道发送消息。使用@Resource注入时需要指定我们刚才定义的输出通道名称

 

### 4、定义启动类



```
package com.bdqn.lyrk.shop;

import com.bdqn.lyrk.shop.channel.ShopChannel;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.stream.annotation.EnableBinding;

@SpringBootApplication
@EnableBinding(ShopChannel.class)
public class ShopServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShopServerApplication.class, args);
    }
}
```



　　注意@EnableBinding注解，这个注解指定刚才我们定义消息通道的接口名称，当然这里也可以传多个相关的接口

### 5、定义application.yml文件



```
spring:
  application:
    name: shop-server
  cloud:
    stream:
      bindings:
        #配置自己定义的通道与哪个中间件交互
        shop_input: #ShopChannel里Input和Output的值
          destination: zhibo #目标主题
        shop_output:
          destination: zhibo
      default-binder: kafka #默认的binder是kafka
  kafka:
    bootstrap-servers: localhost:9092 #kafka服务地址
    consumer:
      group-id: consumer1
    producer:
      key-serializer: org.apache.kafka.common.serialization.ByteArraySerializer
      value-serializer: org.apache.kafka.common.serialization.ByteArraySerializer
      client-id: producer1
server:
  port: 8100
```



　　这里是重头戏，我们必须指定所有通道对应的消息主题，同时指定默认的binder为kafka，紧接着定义Spring-kafka的外部化配置，在这里指定producer的序列化类为ByteArraySerializer

 

启动程序成功后，我们访问 http://localhost:8100/sendMsg?content=2 即可得到如下结果![img](https://images2018.cnblogs.com/blog/1158242/201804/1158242-20180401170915619-1871032251.png)