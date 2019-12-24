# springboot 整合redisson

整合代码已经过测试

### 1、pom

```
<!-- redisson -->
 <dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson</artifactId>
    <version>3.5.7</version>
 </dependency>
```

### 2、properties

```
# redis
spring.redis.host=
spring.redis.port=
spring.redis.password=
spring.redis.jedis.pool.max-active=500
spring.redis.jedis.pool.max-idle=1000
spring.redis.jedis.pool.max-wait=6000ms
spring.redis.jedis.pool.min-idle=4
```

### 3、添加redisson配置类、这里是单机模式

```
 package com.example.common.config;

import org.redisson.Redisson;
import org.redisson.api.RedissonClient;
import org.redisson.config.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * redisson 配置类
 * Created on 2018/6/19
 */
@Configuration
public class RedissonConfig {

    @Value("${spring.redis.host}")
    private String host;

    @Value("${spring.redis.port}")
    private String port;

    @Value("${spring.redis.password}")
    private String password;

    @Bean
    public RedissonClient getRedisson(){

        Config config = new Config();
        config.useSingleServer().setAddress("redis://" + host + ":" + port).setPassword(password);
        //添加主从配置
//        config.useMasterSlaveServers().setMasterAddress("").setPassword("").addSlaveAddress(new String[]{"",""});

        return Redisson.create(config);
    }

}
```

### 4、加入redisson 操作类（redissonService）

```
package com.example.common.base;

import org.redisson.api.*;
import org.redisson.config.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * redisson操作类
 */
@Service("redissonService")
public class RedissonService {

    @Autowired
    private RedissonClient redissonClient;

    public void getRedissonClient() throws IOException {
        Config config = redissonClient.getConfig();
        System.out.println(config.toJSON().toString());
    }

    /**`
     * 获取字符串对象
     *
     * @param objectName
     * @return
     */
    public <T> RBucket<T> getRBucket(String objectName) {
        RBucket<T> bucket = redissonClient.getBucket(objectName);
        return bucket;
    }

    /**
     * 获取Map对象
     *
     * @param objectName
     * @return
     */
    public <K, V> RMap<K, V> getRMap(String objectName) {
        RMap<K, V> map = redissonClient.getMap(objectName);
        return map;
    }

    /**
     * 获取有序集合
     *
     * @param objectName
     * @return
     */
    public <V> RSortedSet<V> getRSortedSet(String objectName) {
        RSortedSet<V> sortedSet = redissonClient.getSortedSet(objectName);
        return sortedSet;
    }

    /**
     * 获取集合
     *
     * @param objectName
     * @return
     */
    public <V> RSet<V> getRSet(String objectName) {
        RSet<V> rSet = redissonClient.getSet(objectName);
        return rSet;
    }

    /**
     * 获取列表
     *
     * @param objectName
     * @return
     */
    public <V> RList<V> getRList(String objectName) {
        RList<V> rList = redissonClient.getList(objectName);
        return rList;
    }

    /**
     * 获取队列
     *
     * @param objectName
     * @return
     */
    public <V> RQueue<V> getRQueue(String objectName) {
        RQueue<V> rQueue = redissonClient.getQueue(objectName);
        return rQueue;
    }

    /**
     * 获取双端队列
     *
     * @param objectName
     * @return
     */
    public <V> RDeque<V> getRDeque(String objectName) {
        RDeque<V> rDeque = redissonClient.getDeque(objectName);
        return rDeque;
    }


    /**
     * 获取锁
     *
     * @param objectName
     * @return
     */
    public RLock getRLock(String objectName) {
        RLock rLock = redissonClient.getLock(objectName);
        return rLock;
    }

    /**
     * 获取读取锁
     *
     * @param objectName
     * @return
     */
    public RReadWriteLock getRWLock(String objectName) {
        RReadWriteLock rwlock = redissonClient.getReadWriteLock(objectName);
        return rwlock;
    }

    /**
     * 获取原子数
     *
     * @param objectName
     * @return
     */
    public RAtomicLong getRAtomicLong(String objectName) {
        RAtomicLong rAtomicLong = redissonClient.getAtomicLong(objectName);
        return rAtomicLong;
    }

    /**
     * 获取记数锁
     *
     * @param objectName
     * @return
     */
    public RCountDownLatch getRCountDownLatch(String objectName) {
        RCountDownLatch rCountDownLatch = redissonClient.getCountDownLatch(objectName);
        return rCountDownLatch;
    }

    /**
     * 获取消息的Topic
     *
     * @param objectName
     * @return
     */
    public <M> RTopic<M> getRTopic(String objectName) {
        RTopic<M> rTopic = redissonClient.getTopic(objectName);
        return rTopic;
    }
}
```



### 5.、测试代码

```
package com.example.test;

import com.example.common.base.RedissonService;
import org.redisson.api.RLock;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.concurrent.TimeUnit;

@Controller
@RequestMapping("test")
public class TestService {

    private static final Logger log = LoggerFactory.getLogger(TestService.class);

    @Autowired
    private RedissonService redissonService;

    @RequestMapping(value = "/test")
    @ResponseBody
    public void test(String recordId) {

        RLock lock = redissonService.getRLock(recordId);
        try {
            boolean bs = lock.tryLock(5, 6, TimeUnit.SECONDS);
            if (bs) {
                // 业务代码
                log.info("进入业务代码: " + recordId);

                lock.unlock();
            } else {
                Thread.sleep(300);
            }
        } catch (Exception e) {
            log.error("", e);
            lock.unlock();
        }
    }

}
```



## 库存减少的分布式锁的实现

### pom.xml

```
       <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
      
        <dependency>
            <groupId>org.redisson</groupId>
            <artifactId>redisson</artifactId>
            <version>3.5.7</version>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
```



### application.yml

```
       ################################### 日志log配置 ###################################
#logging:
#      level:
#            com.yeshen.eshop: debug
  #日志配置文件位置
#      config: classpath:log/logback.xml
  #日志打印位置，这里是默认在项目根路径下
#      path: log/eshop-log

spring:

       #################################### Redis集群配置 ##########################################
       redis:
            host: localhost
           # cluster:
               #nodes:
                   # - 192.168.150.137:7001
                   # - 192.168.150.137:7002
                    #- 192.168.150.138:7003
                   # - 192.168.150.138:7004
                    # - 127.0.0.1:6379

                  ## Redis数据库索引(默认为0)
            database: 0
                  # 连接超时时间（毫秒）
            timeout: 5000ms
            jedis:
                  pool:
                     ## 连接池最大连接数（使用负值表示没有限制）
                      max-active: 300
                      ## 连接池中的最大空闲连接
                      max-idle: 100
                      ## 连接池最大阻塞等待时间（使用负值表示没有限制）
                      max-wait: -1ms
                      ## 连接池中的最小空闲连接
                      min-idle: 20
            password: 123456
            port: 6379


```

### RedisConfig

```
package com.yeshen.distributedlockdemo.config;

import org.redisson.Redisson;
import org.redisson.config.Config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class RedisConfig {

    @Bean
    public Redisson redisson(){
        Config config=new Config();
        config.useSingleServer().setAddress("redis://127.0.0.1:6379").setPassword("123456").setDatabase(0);
        return (Redisson) Redisson.create(config);
    }
}

```



### LockController

```
package com.yeshen.distributedlockdemo.controller;

import org.redisson.Redisson;
import org.redisson.api.RLock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class LockController {

    @Autowired
    private Redisson redisson;

    @Autowired
    private StringRedisTemplate stringRedisTemplate;
   @RequestMapping("/stock")
    public String reduceStock(){

        String lock_key="lock";
        RLock lock = redisson.getLock(lock_key);
        lock.lock();
        try {
            int stock=Integer.parseInt(stringRedisTemplate.opsForValue().get("stock"));
            if (stock >0) {
                stock=stock-1;
                stringRedisTemplate.opsForValue().set("stock",stock+"");
                System.out.println("减少库存，库存为"+stock);

            }else {
                System.out.println("库存不足");
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
       return "end";
    }
}

```



### 结果：

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v2.2.1.RELEASE)

2019-12-22 18:42:09.125  INFO 2924 --- [nio-8080-exec-1] io.lettuce.core.KqueueProvider           : Starting without optional kqueue library
减少库存，库存为99
减少库存，库存为98
减少库存，库存为97
减少库存，库存为96
减少库存，库存为95
减少库存，库存为94
减少库存，库存为93
减少库存，库存为92
减少库存，库存为91
减少库存，库存为90
减少库存，库存为89
减少库存，库存为88
减少库存，库存为87
减少库存，库存为86
减少库存，库存为85
减少库存，库存为84
减少库存，库存为83
减少库存，库存为82
减少库存，库存为81
减少库存，库存为80
减少库存，库存为79
减少库存，库存为78
减少库存，库存为77
减少库存，库存为76
减少库存，库存为75
减少库存，库存为74
减少库存，库存为73
减少库存，库存为72
减少库存，库存为71
减少库存，库存为70
减少库存，库存为69
减少库存，库存为68
减少库存，库存为67
减少库存，库存为66
减少库存，库存为65
减少库存，库存为64
减少库存，库存为63
减少库存，库存为62
减少库存，库存为61
减少库存，库存为60
减少库存，库存为59
减少库存，库存为58
减少库存，库存为57
减少库存，库存为56
减少库存，库存为55
减少库存，库存为54
减少库存，库存为53
减少库存，库存为52
减少库存，库存为51
减少库存，库存为50
减少库存，库存为49
减少库存，库存为48
减少库存，库存为47
减少库存，库存为46
减少库存，库存为45
减少库存，库存为44
减少库存，库存为43
减少库存，库存为42
减少库存，库存为41
减少库存，库存为40
减少库存，库存为39
减少库存，库存为38
减少库存，库存为37
减少库存，库存为36
减少库存，库存为35
减少库存，库存为34
减少库存，库存为33
减少库存，库存为32
减少库存，库存为31
减少库存，库存为30
减少库存，库存为29
减少库存，库存为28
减少库存，库存为27
减少库存，库存为26
减少库存，库存为25
减少库存，库存为24
减少库存，库存为23
减少库存，库存为22
减少库存，库存为21
减少库存，库存为20
减少库存，库存为19
减少库存，库存为18
减少库存，库存为17
减少库存，库存为16
减少库存，库存为15
减少库存，库存为14
减少库存，库存为13
减少库存，库存为12
减少库存，库存为11
减少库存，库存为10
减少库存，库存为9
减少库存，库存为8
减少库存，库存为7
减少库存，库存为6
减少库存，库存为5
减少库存，库存为4
减少库存，库存为3
减少库存，库存为2
减少库存，库存为1
减少库存，库存为0
库存不足

Process finished with exit code -1

```

