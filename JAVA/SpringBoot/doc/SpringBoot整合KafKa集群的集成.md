# SpringBoot 整合KafKa集群的集成

### 简介

本文主要讲在springboot2中，如何通过自定义的配置来集成，并可以比较好的扩展性，同时集成多个kafka集群

### 引入依赖

引入kafka的依赖

```
        <!-- kafka -->
        <dependency>
            <groupId>org.springframework.kafka</groupId>
            <artifactId>spring-kafka</artifactId>
        </dependency>
```

### 配置文件

添加配置文件，默认添加一个kafka的集群，

```
topinfo:
     # kafka集群配置 ,bootstrap-servers 是必须的
   kafka:
      # 生产者的kafka集群地址
      bootstrap-servers:  192.168.90.225:9092,192.168.90.226:9092,192.168.90.227:9092 
      producer: 
         topic-name:  topinfo-01
         
      consumer:
         group-id:  ci-data
         
```

如果多个，则配置多个kafka的集群配置即可

### 添加属性配置类

添加对应的属性配置类，如果是多个kafka集群，则可以填多个即可，注意对应的@ConfigurationProperties。

```
package com.topinfo.ci.dataex.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import com.topinfo.ci.dataex.bean.Consumer;
import com.topinfo.ci.dataex.bean.Producer;

/**
 * @Description: kafka 属性配置
 * @Author:杨攀
 * @Since:2019年7月10日上午10:35:18
 */
@ConfigurationProperties(prefix = "topinfo.kafka")
@Component
public class KafKaConfiguration {

    /**
     * @Fields bootstrapServer : 集群的地址
     */
    private String bootstrapServers;

    private Producer producer;

    private Consumer consumer;

    public String getBootstrapServers() {
        return bootstrapServers;
    }

    public void setBootstrapServers(String bootstrapServers) {
        this.bootstrapServers = bootstrapServers;
    }

    public Producer getProducer() {
        return producer;
    }

    public void setProducer(Producer producer) {
        this.producer = producer;
    }

    public Consumer getConsumer() {
        return consumer;
    }

    public void setConsumer(Consumer consumer) {
        this.consumer = consumer;
    }

}

```

### 添加kafka配置类

kafka的配置类中， 主要注意的方法：

**生产者工厂方法**： producerFactory()
**生产者KafkaTemplate** ：kafkaTemplate()

**消费者的工厂方法**：consumerFactory()
**消费者的监听容器工厂方法**： kafkaListenerContainerFactory()

如果对应的是对个集群，需要多配置几个对应的这几个方法即可。

```
package com.topinfo.ci.dataex.config;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.KafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaAdmin;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.listener.ConcurrentMessageListenerContainer;

/**
 * @Description: kafka配置类
 * @Author:杨攀
 * @Since:2019年7月10日下午3:06:58
 */
@Configuration
public class KafKaConfig {

    @Autowired
    private KafKaConfiguration configuration;

     
    
    /**
     * @Description: 生产者的配置
     * @Author:杨攀
     * @Since: 2019年7月10日下午1:41:06
     * @return
     */
    public Map<String, Object> producerConfigs() {

        Map<String, Object> props = new HashMap<String, Object>();
        // 集群的服务器地址
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, configuration.getBootstrapServers());
        //  消息缓存
        props.put(ProducerConfig.BUFFER_MEMORY_CONFIG, 40960);
        // 生产者空间不足时，send()被阻塞的时间，默认60s
        props.put(ProducerConfig.MAX_BLOCK_MS_CONFIG, 6000);
        // 生产者重试次数
        props.put(ProducerConfig.RETRIES_CONFIG, 0);
        // 指定ProducerBatch（消息累加器中BufferPool中的）可复用大小
        props.put(ProducerConfig.BATCH_SIZE_CONFIG,  4096);
        // 生产者会在ProducerBatch被填满或者等待超过LINGER_MS_CONFIG时发送
        props.put(ProducerConfig.LINGER_MS_CONFIG, 1);
        // key 和 value 的序列化
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, "org.apache.kafka.common.serialization.StringSerializer");
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringSerializer");
        // 客户端id
        props.put(ProducerConfig.CLIENT_ID_CONFIG, "producer.client.id.topinfo");

        return props;
    }

    /**
     * @Description: 生产者工厂
     * @Author:杨攀
     * @Since: 2019年7月10日下午2:10:04
     * @return
     */
    @Bean
    public ProducerFactory<String, String> producerFactory() {
        return new DefaultKafkaProducerFactory<String, String>(producerConfigs());
    }

    /**
     * @Description: KafkaTemplate
     * @Author:杨攀
     * @Since: 2019年7月10日下午2:10:47
     * @return
     */
    @Bean
    public KafkaTemplate<String, String> kafkaTemplate() {
        return new KafkaTemplate<String, String>(producerFactory());
    }


    // ------------------------------------------------------------------------------------------------------------

    /**
     * @Description: 消费者配置
     * @Author:杨攀
     * @Since: 2019年7月10日下午1:48:36
     * @return
     */
    public Map<String, Object> consumerConfigs() {

        Map<String, Object> props = new HashMap<String, Object>();

        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, configuration.getBootstrapServers());
        // 消费者组
        props.put(ConsumerConfig.GROUP_ID_CONFIG, configuration.getConsumer().getGroupId());
        // 自动位移提交
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, true);
        // 自动位移提交间隔时间
        props.put(ConsumerConfig.AUTO_COMMIT_INTERVAL_MS_CONFIG, 100);
        // 消费组失效超时时间
        props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, 10000);
        // 位移丢失和位移越界后的恢复起始位置
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "latest");
        // key 和 value 的反序列化
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG,
                "org.apache.kafka.common.serialization.StringDeserializer");

        return props;
    }

    /**
     * @Description: 消费者工厂
     * @Author:杨攀
     * @Since: 2019年7月10日下午2:14:13
     * @return
     */
    @Bean
    public ConsumerFactory<String, String> consumerFactory() {
        return new DefaultKafkaConsumerFactory<>(consumerConfigs());
    }

    /**
     * @Description: kafka 监听容器工厂
     * @Author:杨攀
     * @Since: 2019年7月10日下午2:50:44
     * @return
     */
    @Bean
    public KafkaListenerContainerFactory<ConcurrentMessageListenerContainer<String, String>> kafkaListenerContainerFactory() {

        ConcurrentKafkaListenerContainerFactory<String, String> factory = new ConcurrentKafkaListenerContainerFactory<>();
        // 设置消费者工厂
        factory.setConsumerFactory(consumerFactory());
        // 要创建的消费者数量(10 个线程并发处理)
        factory.setConcurrency(10);

        return factory;
    }

}

```

### 主题配置类

主要是可以对主题进行管理。新增，修改，删除等

```
package com.topinfo.ci.dataex.config;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.AdminClientConfig;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.annotation.EnableKafka;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.KafkaListenerContainerFactory;
import org.springframework.kafka.core.ConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaConsumerFactory;
import org.springframework.kafka.core.DefaultKafkaProducerFactory;
import org.springframework.kafka.core.KafkaAdmin;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.core.ProducerFactory;
import org.springframework.kafka.listener.ConcurrentMessageListenerContainer;

/**
 * @Description: kafka 主题 配置类
 * @Author:杨攀
 * @Since:2019年7月10日下午3:06:58
 */
@Configuration
public class KafKaTopicConfig {

    @Autowired
    private KafKaConfiguration configuration;

    /**
     *@Description: kafka管理员，委派给AdminClient以创建在应用程序上下文中定义的主题的管理员。
     *@Author:杨攀
     *@Since: 2019年7月10日下午3:14:23
     *@return
     */
    @Bean
    public KafkaAdmin kafkaAdmin() {
        
        Map<String, Object> props = new HashMap<>();
        
        // 配置Kafka实例的连接地址
        props.put(AdminClientConfig.BOOTSTRAP_SERVERS_CONFIG, configuration.getBootstrapServers());
        KafkaAdmin admin = new KafkaAdmin(props);
        return admin;
    }

    /**
     *@Description: kafka的管理客户端，用于创建、修改、删除主题等
     *@Author:杨攀
     *@Since: 2019年7月10日下午3:15:01
     *@return
     */
    @Bean
    public AdminClient adminClient() {
        return AdminClient.create(kafkaAdmin().getConfig());
    }
    
    /**
     * @Description: 创建一个新的 topinfo 的Topic，如果kafka中topinfo 的topic已经存在，则忽略。
     * @Author:杨攀
     * @Since: 2019年7月10日上午11:13:28
     * @return
     */
    @Bean
    public NewTopic topinfo() {

        // 主题名称
        String topicName = configuration.getProducer().getTopicName();
        // 第二个参数是分区数， 第三个参数是副本数量，确保集群中配置的数目大于等于副本数量
        return new NewTopic(topicName, 2, (short) 2);
    }

}

```

### 生产者测试

生产者在发送消息的时候，使用对应的kafkaTemplate即可，如果是多个，需要注意导入的是对应的kafkaTemplate。

```
package com.topinfo.ci.dataex.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.SendResult;
import org.springframework.util.concurrent.ListenableFuture;
import org.springframework.util.concurrent.ListenableFutureCallback;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.topinfo.ci.dataex.config.KafKaConfig;

@RestController
@RequestMapping("kafka")
public class TestKafKaProducerController {

    @Autowired
    private KafkaTemplate<String, String> kafkaTemplate;
    
    @RequestMapping("send")
    public String send(String name) {
        
        ListenableFuture<SendResult<String, String>>  future = kafkaTemplate.send("topinfo", name);
        
        future.addCallback(new ListenableFutureCallback<SendResult<String, String>>() {

            @Override
            public void onSuccess(SendResult<String, String> result) {
                System.out.println("生产者-发送消息成功：" + result.toString());
            }

            @Override
            public void onFailure(Throwable ex) {
                System.out.println("生产者-发送消息失败：" + ex.getMessage());
            }
        });
        
        
        return "test-ok";
    }
    
}

```

### 消费者测试

消费者需要在接收的方法上添加@KafkaListener，用于监听对应的topic,可以配置topic多个。

```
package com.topinfo.ci.dataex.consumer;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

import com.topinfo.ci.dataex.config.KafKaConfig;

/**
 * @Description: kafka消费者
 * @Author:杨攀
 * @Since:2019年7月10日上午11:24:31
 */
@Component
public class KafKaConsumer {

    private final Logger logger = LoggerFactory.getLogger(KafKaConsumer.class);

    
    /**
     * @Description: 可以同时订阅多主题，只需按数组格式即可，也就是用“，”隔开
     * @Author:杨攀
     * @Since: 2019年7月10日上午11:26:16
     * @param record
     */
    @KafkaListener(topics = { "topinfo" })
    public void receive(ConsumerRecord<?, ?> record) {

        logger.info("消费得到的消息---key: " + record.key());
        logger.info("消费得到的消息---value: " + record.value().toString());
        
    }

}

```

如果多个集群的情况下，需要在KafkaListener监听注解上添加containerFactory，对应配置中的监听容器工厂。

```
/**
     * @Description: 可以同时订阅多主题，只需按数组格式即可，也就是用“，”隔开
     * @Author:杨攀
     * @Since: 2019年7月10日上午11:26:16
     * @param record
     */
    @KafkaListener(topics = { "topinfo" }, containerFactory = "kafkaListenerContainerFactory")
    public void receive(ConsumerRecord<?, ?> record) {

        logger.info("消费得到的消息---key: " + record.key());
        logger.info("消费得到的消息---value: " + record.value().toString());
        
    }
```

好了， 至此所有的配置就差不多了。