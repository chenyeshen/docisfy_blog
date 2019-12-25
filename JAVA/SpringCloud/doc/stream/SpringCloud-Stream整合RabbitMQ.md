# SpringCloud-Stream整合RabbitMQ

我们知道，当微服务越来越来多的时候，仅仅是feign的http调用方式已经满足不了我们的使用场景了。这个时候系统就需要接入消息中间件了。相比较于传统的Spring项目、SpringBoot项目使用消息中间件的很多配置不同，SpringCloud Stream抽象了中间件产品的不同，在SpringCloud中你仅仅需要修改几行配置文件就可以灵活的切换中间件产品而不需要修改任何代码。

现在我们以SpringCloud Stream整合RabbitMQ为例来学习一下



Bindings — 声明输入和输出通道的接口集合。
Binder — 消息中间件的实现，如Kafka或RabbitMQ
Channel — 表示消息中间件和应用程序之间的通信管道
StreamListeners — bean中的消息处理方法，在中间件的MessageConverter特定事件中进行对象序列化/反序列化之后，将在信道上的消息上自动调用消息处理方法。
Message Schemas — 用于消息的序列化和反序列化，这些模式可以静态读取或者动态加载，支持对象类型的演变。
将消息发布到指定目的地是由发布订阅消息模式传递。发布者将消息分类为主题，每个主题由名称标识。订阅方对一个或多个主题表示兴趣。中间件过滤消息，将感兴趣的主题传递给订阅服务器。订阅方可以分组，消费者组是由组ID标识的一组订户或消费者，其中从主题或主题的分区中的消息以负载均衡的方式递送。


## 创建生产者

#### 1. 引入依赖

```
<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
        </dependency>
```



#### 2. 定义配置文件

```
spring:
  cloud:
    stream:
      binders:
        test:
          type: rabbit
          environment:
            spring:
              rabbitmq:
                addresses: 10.0.20.132
                port: 5672
                username: root
                password: root
                virtual-host: /unicode-pay
      bindings:
        testOutPut:
          destination: testRabbit
          content-type: application/json
          default-binder: test
```

现在来解释一下这些配置的含义

1. binders： 这是一组binder的集合，这里配置了一个名为test的binder，这个binder中是包含了一个rabbit的连接信息
2. bindings：这是一组binding的集合，这里配置了一个名为testOutPut的binding，这个binding中配置了指向名test的binder下的一个交换机testRabbit。
3. 扩展： 如果我们项目中不仅集成了rabbit还集成了kafka那么就可以新增一个类型为kafka的binder、如果项目中会使用多个交换机那么就使用多个binding，

#### 3.创建通道

```
public interface  MqMessageSource {

    String TEST_OUT_PUT = "testOutPut";

    @Output(TEST_OUT_PUT)
    MessageChannel testOutPut();

}
```

这个通道的名字就是上方binding的名字

#### 4. 发送消息

```
@EnableBinding(MqMessageSource.class)
public class MqMessageProducer {
    @Autowired
    @Output(MqMessageSource.TEST_OUT_PUT)
    private MessageChannel channel;


    public void sendMsg(String msg) {
        channel.send(MessageBuilder.withPayload(msg).build());
        System.err.println("消息发送成功："+msg);
    }
}
```

这里就是使用上方的通道来发送到指定的交换机了。需要注意的是withPayload方法你可以传入任何类型的对象，但是需要实现序列化接口

#### 5. 创建测试接口

EnableBinding注解绑定的类默认是被Spring管理的，我们可以在controller中注入它

```
@Autowired
private MqMessageProducer mqMessageProducer;

@GetMapping(value = "/testMq")
public String testMq(@RequestParam("msg")String msg){
    mqMessageProducer.sendMsg(msg);
    return "发送成功";
}
```

生产者的代码到此已经完成了。



## 创建消费者

#### 1. 引入依赖

```
<dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-stream-rabbit</artifactId>
        </dependency>
```



#### 2. 定义配置文件

```
spring:
  cloud:
    stream:
      binders:
        test:
          type: rabbit
          environment:
            spring:
              rabbitmq:
                addresses: 10.0.20.132
                port: 5672
                username: root
                password: root
                virtual-host: /unicode-pay
      bindings:
        testInPut:
          destination: testRabbit
          content-type: application/json
          default-binder: test
```

这里与生产者唯一不同的地方就是testIntPut了，相信你已经明白了，它是binding的名字，也是通道与交换机绑定的关键

#### 3.创建通道

```
public interface  MqMessageSource {

    String TEST_IN_PUT = "testInPut";

    @Input(TEST_IN_PUT)
    SubscribableChannel testInPut();

}
```



#### 4. 接受消息

```
@EnableBinding(MqMessageSource.class)
public class MqMessageConsumer {
    @StreamListener(MqMessageSource.TEST_IN_PUT)
    public void messageInPut(Message<String> message) {
        System.err.println(" 消息接收成功：" + message.getPayload());
    }

}
```

这个时候启动Eureka、消息生产者和消费者，然后调用生产者的接口应该就可以接受到来自mq的消息了。