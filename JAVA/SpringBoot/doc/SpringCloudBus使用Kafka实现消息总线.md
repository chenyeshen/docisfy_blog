# SpringCloudBus使用Kafka实现消息总线

> Kafka**是分布式发布-订阅消息系统，最初由LinkedIn公司开发，之后成为之后成为Apache基金会的一部分，由[Scala](https://baike.baidu.com/item/Scala)和[Java](https://baike.baidu.com/item/Java/85979)编写。Kafka是一种快速、可扩展的、设计内在就是分布式的，分区的和可复制的提交日志服务。

在开始本文前，需要搭建kafka的环境，如果是在CentOS环境下，可以看看我前面的文章：[CentOS7下Kafka的安装介绍](http://www.wanqhblog.top/2018/01/25/CentOS-Kafka/) 。其他平台下可以自行百度或Google。

在之前的环境中，需要修改server.properties文件，开启9092端口的监听：

```
listeners=PLAINTEXT://your.host.name:9092
```

# SpringBoot简单整合Kafka

因为SpringCloud是基于SpringBoot的，所以在使用SpringCloudBus整合之前先用SpringBoot整合并记录下来。

## 创建项目

这里创建一个名为kafka-hello的SpringBoot项目，并添加以下依赖：

```
<dependencies>
  <dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
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
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
    <version>1.1.1.RELEASE</version>
  </dependency>

  <dependency>
    <groupId>com.google.code.gson</groupId>
    <artifactId>gson</artifactId>
    <version>2.8.2</version>
  </dependency>
</dependencies>
```

## 消息实体类

```
@Data
public class Message {
    private Long id;//id
    private String msg; //消息
    private Date sendTime; //发送时间
}

```

## 消息产生者

在该类中创建一个消息发送的方法，使用KafkaTemplate.send()发送消息，`wqh`是Kafka里的Topic。

```
@Component
@Slf4j
public class KafkaSender {

    @Autowired
    private KafkaTemplate<String,String> kafkaTemplate;

    private Gson gson = new GsonBuilder().create();

    public void send(Long i){
        Message message = new Message();
        message.setId(i);
        message.setMsg(UUID.randomUUID().toString());
        message.setSendTime(new Date());
        log.info("========发送消息  "+i+" >>>>{}<<<<<==========",gson.toJson(message));
        kafkaTemplate.send("wqh",gson.toJson(message));
    }
}
```

## 消息接收类，

在这个类中，创建consumer方法，并使用@KafkaListener注解监听指定的topic，如这里是监听wanqh和wqh两个topic。

```
@Component
@Slf4j
public class KafkaConsumer {

    @KafkaListener(topics = {"wanqh","wqh"})
    public void consumer(ConsumerRecord<?,?> consumerRecord){
        //判断是否为null
        Optional<?> kafkaMessage = Optional.ofNullable(consumerRecord.value());
        log.info(">>>>>>>>>> record =" + kafkaMessage);
        if(kafkaMessage.isPresent()){
            //得到Optional实例中的值
            Object message = kafkaMessage.get();
            log.info(">>>>>>>>接收消息message =" + message);
        }
    }
}
```

## 修改启动类

```
@SpringBootApplication
public class KafkaApplication {

    @Autowired
    private KafkaSender kafkaSender;

    @PostConstruct
    public void init(){
      for (int i = 0; i < 10; i++) {
        //调用消息发送类中的消息发送方法
        kafkaSender.send((long) i);
      }
    }
    public static void main(String[] args) {
       SpringApplication.run(KafkaApplication.class, args);
    }
}
```

## 配置文件

```
spring.application.name=kafka-hello
server.port=8080
#============== kafka ===================
# 指定kafka 代理地址，可以多个
spring.kafka.bootstrap-servers=192.168.18.136:9092

#=============== provider  =======================
spring.kafka.producer.retries=0
# 每次批量发送消息的数量
spring.kafka.producer.batch-size=16384
spring.kafka.producer.buffer-memory=33554432

# 指定消息key和消息体的编解码方式
spring.kafka.producer.key-serializer=org.apache.kafka.common.serialization.StringSerializer
spring.kafka.producer.value-serializer=org.apache.kafka.common.serialization.StringSerializer

#=============== consumer  =======================
# 指定默认消费者group id
spring.kafka.consumer.group-id=test-consumer-group

spring.kafka.consumer.auto-offset-reset=earliest
spring.kafka.consumer.enable-auto-commit=true
spring.kafka.consumer.auto-commit-interval=100

# 指定消息key和消息体的编解码方式
spring.kafka.consumer.key-deserializer=org.apache.kafka.common.serialization.StringDeserializer
spring.kafka.consumer.value-deserializer=org.apache.kafka.common.serialization.StringDeserializer
```

## 测试

直接启动该项目:

![img](https://segmentfault.com/img/remote/1460000013031493?w=1196&h=460)

# SpringCloudBus整合Kafka

前面介绍使用RabbitMQ整合SpringCloudBus实现了消息总线，并且测试了动态刷新配置文件。RabbitMQ是通过引入`spring-cloud-starter-bus-amqp`模块来实现消息总线。若使用Kafka实现消息总线，我们可以直接将之前添加的`spring-cloud-starter-bus-amqp`替换成`spring-cloud-starter-bus-kafka` 。

这里我将前面的config-client复制一份，改名config-client-kafka。传送门：[SpingCloudBus整合RabbitMQ](http://www.wanqhblog.top/2018/01/25/SpingCLoudBusRabbitMQ/)

- 所添加的依赖：

```
<dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-config</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.retry</groupId>
            <artifactId>spring-retry</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-bus-kafka</artifactId>
        </dependency>
    </dependencies>
```

- 添加kafka的配置信息

```
#Kafka的服务端列表，默认localhost
spring.cloud.stream.kafka.binder.brokers=192.168.18.136:9092
#Kafka服务端的默认端口，当brokers属性中没有配置端口信息时，就会使用这个默认端口，默认9092
spring.cloud.stream.kafka.binder.defaultBrokerPort=9092
#Kafka服务端连接的ZooKeeper节点列表，默认localhost
spring.cloud.stream.kafka.binder.zkNodes=192.168.18.136:2181
#ZooKeeper节点的默认端口，当zkNodes属性中没有配置端口信息时，就会使用这个默认端口，默认2181
spring.cloud.stream.kafka.binder.defaultZkPort=2181
```