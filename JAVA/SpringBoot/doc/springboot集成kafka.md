# SpringBoot集成kafka

## pom.xml添加maven依赖

```
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>2.0.2.RELEASE</version>
</parent>

<dependency>
    <groupId>org.springframework.kafka</groupId>
    <artifactId>spring-kafka</artifactId>
</dependency>
```

spring boot会自动配置kafka，接下来只要配置yml属性文件和主题名配置。

## application.yml配置kafka

```
spring:
  kafka:
    bootstrap-servers: 127.0.0.1:9092,127.0.0.2:9092,127.0.0.3:9092

    producer:
      retries: 0
      batch-size: 16384
      buffer-memory: 33554432
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
      properties:
        linger.ms: 1

    consumer:
      enable-auto-commit: false
      auto-commit-interval: 100ms
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      properties:
        session.timeout.ms: 15000
```

## application.yml配置主题和消费者组

```
kafka:
  topic:
    group-id: topicGroupId
    topic-name:
      - topic1
      - topic2
      - topic3
```

**新建KafkaTopicProperties**

```
@ConfigurationProperties("kafka.topic")
public class KafkaTopicProperties implements Serializable {

    private String groupId;
    private String[] topicName;

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String[] getTopicName() {
        return topicName;
    }

    public void setTopicName(String[] topicName) {
        this.topicName = topicName;
    }
```

**添加KafkaTopicConfiguration**

```
@Configuration
@EnableConfigurationProperties(KafkaTopicProperties.class)
public class KafkaTopicConfiguration {

    private final KafkaTopicProperties properties;

    public KafkaTopicConfiguration(KafkaTopicProperties properties) {
        this.properties = properties;
    }

    @Bean
    public String[] kafkaTopicName() {
        return properties.getTopicName();
    }

    @Bean
    public String topicGroupId() {
        return properties.getGroupId();
    }

}
```

## 添加自己的service

```
@Service
public class IndicatorService {

    private Logger LOG = LoggerFactory.getLogger(IndicatorService.class);

    private final KafkaTemplate<Integer, String> kafkaTemplate;

    /**
     * 注入KafkaTemplate
     * @param kafkaTemplate kafka模版类
     */
    @Autowired
    public IndicatorService(KafkaTemplate kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }


    @KafkaListener(topics = "#{kafkaTopicName}", groupId = "#{topicGroupId}")
    public void processMessage(ConsumerRecord<Integer, String> record) {
        LOG.info("kafka processMessage start");
        LOG.info("processMessage, topic = {}, msg = {}", record.topic(), record.value());

        // do something ...

        LOG.info("kafka processMessage end");
    }

    public void sendMessage(String topic, String data) {
        LOG.info("kafka sendMessage start");
        ListenableFuture<SendResult<Integer, String>> future = kafkaTemplate.send(topic, data);
        future.addCallback(new ListenableFutureCallback<SendResult<Integer, String>>() {
            @Override
            public void onFailure(Throwable ex) {
                LOG.error("kafka sendMessage error, ex = {}, topic = {}, data = {}", ex, topic, data);
            }

            @Override
            public void onSuccess(SendResult<Integer, String> result) {
                LOG.info("kafka sendMessage success topic = {}, data = {}",topic, data);
            }
        });
        LOG.info("kafka sendMessage end");
    }
}
```