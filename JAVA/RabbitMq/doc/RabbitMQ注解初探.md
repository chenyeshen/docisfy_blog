# **RabbitMQ注解初探**



这里有详细的教程：[RabbitMQ](https://blog.csdn.net/vbirdbest/article/category/7296570)

## 1. pom.xml

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```

## 2. application.properties

```
spring.application.name=spirng-boot-rabbitmq

spring.rabbitmq.host=127.0.0.1
spring.rabbitmq.port=5672
spring.rabbitmq.username=guest
spring.rabbitmq.password=guest
```

## 3. config

```
@Configuration
public class RabbitMQConfig {
    @Bean
    public Queue testQueue() {
        return new Queue("test-queue");
    }
}
```

## 4. 生产者

```
@Component
public class Producer {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        String msg = "msg " + new Date();
        System.out.println("Producer : " + msg);
        this.rabbitTemplate.convertAndSend("test-queue", msg);
    }
}
```

## 5. 消费者

```
@Component
@RabbitListener(queues = "test-queue")
public class Consumer {
    @RabbitHandler
    public void process(String msg) {
        System.out.println("Receiver : " + msg );
    }
}
```

## 6. 启动rabbitmq并test

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121757556.png)

```
@RunWith(SpringRunner.class)
@SpringBootTest
public class RabbitmqApplicationTests {

    @Test
    public void contextLoads() {
    }

    @Autowired
    private Producer producer;

    @Test
    public void sendMsg() throws Exception{
        producer.send();
        Thread.sleep(2000);
    }

}

```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121758987.png)

------

## 发现对象消息

```
public class User {
    private Long id;
    private String username;

    // Getter & Setter
}
```

```
@Component
public class Producer {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        User user = new User(1L, "mengday");
        this.rabbitTemplate.convertAndSend("test-queue", "msg: " + user);
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121756059.png)

------

## 一个生产者多个消费者

新增一个消费者

```
@Component
@RabbitListener(queues = "test-queue")
public class Consumer2 {
    @RabbitHandler
    public void process(String msg) {
        System.out.println("Receiver2 : " + msg);
    }
}
```

改造生产者，发送多个消息

```
@Component
public class Producer {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        for (int i = 0; i < 10; i++){
            this.rabbitTemplate.convertAndSend("test-queue", "msg: " +i);
        }
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121754157.png)

一个生产者多个消费者属于队列模式，多个消费者瓜分消息

------

## 多个生产者多个消费者

新增一个生产者

```
@Component
public class Producer2 {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        for (int i = 0; i < 10; i++){
            this.rabbitTemplate.convertAndSend("test-queue", "Producer2 - msg: " +i);
        }
    }
}
```

```
@RunWith(SpringRunner.class)
@SpringBootTest
public class RabbitmqApplicationTests {
    @Autowired
    @Qualifier("producer")
    private Producer producer;

    @Autowired
    @Qualifier("producer2")
    private Producer2 producer2;

    @Test
    public void sendMsg() throws Exception{
        producer.send();
        producer2.send();
        Thread.sleep(2000);
    }

}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121754887.png)

------

## 一个交换机绑定多个路由键

## TopicRabbitConfig

```
@Configuration
public class TopicRabbitConfig {
    final static String QUEUE_NAME = "test2_queue";

    @Bean
    public Queue test2Queue() {
        return new Queue(QUEUE_NAME);
    }

    @Bean
    TopicExchange exchange() {
        return new TopicExchange("my_exchange");
    }

    @Bean
    Binding bindingExchangeMessage(Queue queueMessage, TopicExchange exchange) {
        return BindingBuilder.bind(queueMessage).to(exchange).with("my_routingkey");
    }

    @Bean
    Binding bindingExchangeMessages(Queue queueMessages, TopicExchange exchange) {
        return BindingBuilder.bind(queueMessages).to(exchange).with("test2.#");
    }

}
```

## Producer

生产者发送消息需要指定交换机和路由键

```
@Component
public class Producer {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
        this.rabbitTemplate.convertAndSend("my_exchange","my_routingkey", "my_exchange, my_routingkey, hello world!");
        this.rabbitTemplate.convertAndSend("my_exchange","test2.xxx", "my_exchange, test2.xxx, hello world!");
    }
}
```

## Consumer

消费者要订阅对应的队列test2-queue

```
@Component
@RabbitListener(queues = "test2-queue")
public class Consumer {
    @RabbitHandler
    public void process(String msg) {
        System.out.println("Receiver : " + msg);
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121756848.png)

------

## 扇形交换机，广播模式，发布订阅模式

所有绑定扇形交换机的队列都会收到消息

```
@Configuration
public class FanoutRabbitConfig {
    @Bean
    public Queue queueA() {
        return new Queue("queue_a");
    }

    @Bean
    public Queue queueB() {
        return new Queue("queue_b");
    }

    @Bean
    FanoutExchange fanoutExchange() {
        return new FanoutExchange("fanout_exchange");
    }

    @Bean
    Binding bindingExchangeA(Queue queueA, FanoutExchange fanoutExchange) {
        return BindingBuilder.bind(queueA).to(fanoutExchange);
    }

    @Bean
    Binding bindingExchangeB(Queue queueB, FanoutExchange fanoutExchange) {
        return BindingBuilder.bind(queueB).to(fanoutExchange);
    }
}
```

生产者发送消息针对于扇形交换机不需要路由键

```
@Component
public class Producer {

    @Autowired
    private AmqpTemplate rabbitTemplate;

    public void send() {
         this.rabbitTemplate.convertAndSend("fanout_exchange","", "fanout_exchange, , hello world!");
    }
}
```

```
@Component
@RabbitListener(queues = "queue_a")
public class Consumer {
    @RabbitHandler
    public void process(String msg) {
        System.out.println("Receiver : " + msg);
    }
}
```

```
@Component
@RabbitListener(queues = "queue_b")
public class Consumer2 {
    @RabbitHandler
    public void process(String msg) {
        System.out.println("Receiver2 : " + msg);
    }
}
@RunWith(SpringRunner.class)
@SpringBootTest
public class RabbitmqApplicationTests {

    @Autowired
    @Qualifier("producer")
    private Producer producer;

    @Test
    public void sendMsg() throws Exception{
        producer.send();
        Thread.sleep(2000);
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528121758270.png)