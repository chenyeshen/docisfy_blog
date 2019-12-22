# Spring整合Ehcache+Mapper管理缓存

## 前言

*Ehcache* 是一个成熟的缓存框架，你可以直接使用它来管理你的缓存。
*Spring* 提供了对缓存功能的抽象：即允许绑定不同的缓存解决方案（如Ehcache），但本身不直接提供缓存功能的实现。它支持注解方式使用缓存，非常方便。
本文先通过Ehcache独立应用的范例来介绍它的基本使用方法，然后再介绍与Spring整合的方法。

### 概述

**Ehcache是什么？**
EhCache 是一个纯Java的进程内缓存框架，具有快速、精干等特点。它是Hibernate中的默认缓存框架。
Ehcache已经发布了3.1版本。但是本文的讲解基于2.10.2版本。
为什么不使用最新版呢？因为Spring4还不能直接整合Ehcache 3.x。虽然可以通过JCache间接整合，Ehcache也支持JCache，但是个人觉得不是很方便。

### pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.2.1.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.yeshen</groupId>
    <artifactId>eshop</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>eshop</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.1.1</version>
        </dependency>

        <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.60</version>
        </dependency>

        <!-- caching -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        <dependency>
            <groupId>net.sf.ehcache</groupId>
            <artifactId>ehcache</artifactId>
        </dependency>

        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
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
            <exclusions>
                <exclusion>
                    <groupId>org.junit.vintage</groupId>
                    <artifactId>junit-vintage-engine</artifactId>
                </exclusion>
            </exclusions>
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



### application.yml

```
spring:
   ####################################数据源配置##########################################
       datasource:
               type: com.alibaba.druid.pool.DruidDataSource
               driver-class-name: com.mysql.cj.jdbc.Driver
               url: jdbc:mysql://localhost:3306/eshop?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
               username: root
               password: root

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

### ehcache.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="http://ehcache.org/ehcache.xsd">

    <!-- 磁盘缓存位置 -->
    <diskStore path="java.io.tmpdir/ehcache"/>

    <!-- 默认缓存 -->
    <defaultCache
            maxEntriesLocalHeap="10000"
            eternal="false"
            timeToIdleSeconds="120"
            timeToLiveSeconds="120"
            maxEntriesLocalDisk="10000000"
            diskExpiryThreadIntervalSeconds="120"
            memoryStoreEvictionPolicy="LRU"/>

    <!-- yeshen缓存 -->
    <cache name="yeshen"
           maxElementsInMemory="1000"
           eternal="false"
           timeToIdleSeconds="5"
           timeToLiveSeconds="5"
           overflowToDisk="false"
           memoryStoreEvictionPolicy="LRU"/>
</ehcache>
```

### EhcacheConfig

```
/**
 * 本地堆缓存配置类
 * @author asus
 */
@Configuration
@EnableCaching
public class EhcacheConfig {

	@Bean
	public EhCacheManagerFactoryBean ehCacheManagerFactoryBean() {
		EhCacheManagerFactoryBean cacheManagerFactoryBean = new EhCacheManagerFactoryBean();
		cacheManagerFactoryBean.setConfigLocation(new ClassPathResource("ehcache.xml"));
		cacheManagerFactoryBean.setShared(true);
		return cacheManagerFactoryBean;
	}

	@Bean
	public EhCacheCacheManager eCacheCacheManager(EhCacheManagerFactoryBean bean) {
		return new EhCacheCacheManager(bean.getObject());
	}
}
```



### ProductInventory

```
package com.yeshen.eshop.model;

import lombok.AllArgsConstructor;
import lombok.Data;

import javax.persistence.Id;
import java.io.Serializable;

@Data
@AllArgsConstructor
public class ProductInventory implements Serializable {
    /**
     * 商品id
     */
    @Id
    private Integer productId;
    /**
     * 库存数量
     */
    private Long inventoryCnt;

}

```

### BaseMapper

```
package com.yeshen.eshop.plugin;

import tk.mybatis.mapper.common.Mapper;
import tk.mybatis.mapper.common.MySqlMapper;

/**
 * 公有Mapper
 *
 */
public interface BaseMapper<T> extends Mapper<T>, MySqlMapper<T> {
    // 特别注意，该接口不能被扫描到，否则会出错
}

```



### ProductInventoryMapper

```
package com.yeshen.eshop.mapper;

import com.yeshen.eshop.plugin.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import com.yeshen.eshop.model.ProductInventory;
import org.springframework.stereotype.Component;

@Component
@Mapper
public interface ProductInventoryMapper extends BaseMapper<ProductInventory> {


}

```



### CacheService

```
package com.yeshen.eshop.service;

import com.yeshen.eshop.model.ProductInventory;

public interface CacheService {

    
   public ProductInventory selectByPrimaryKey(Integer id) ;

   
    public int updateByPrimaryKeySelective(ProductInventory productInventory) ;



    public void deleteCache(Integer id);
    /**
     * 添加库存的缓存
     * @param productInventory
     */
    public void setCache(ProductInventory productInventory);
}

```



### CacheServiceImpl

```
package com.yeshen.eshop.service.impl;

import com.yeshen.eshop.mapper.ProductInventoryMapper;
import com.yeshen.eshop.model.ProductInventory;
import com.yeshen.eshop.service.CacheService;
import com.yeshen.eshop.service.ProductInventoryService;
import com.yeshen.eshop.service.RedisService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Repository;
import org.springframework.stereotype.Service;

@Service
@CacheConfig(cacheNames = {"yeshen"})
@Repository
public class CacheServiceImpl implements CacheService {

    @Autowired
    private ProductInventoryMapper productInventoryMapper;

    @Cacheable("productId")
    @Override
    public ProductInventory selectByPrimaryKey(Integer id) {
        System.out.println("查询功能，缓存未找到，直接读取数据库，ID为：" + id);

        return productInventoryMapper.selectByPrimaryKey(id);
    }
    @CachePut("productId")
    @Override
    public int updateByPrimaryKeySelective(ProductInventory productInventory) {
        return productInventoryMapper.updateByPrimaryKeySelective(productInventory);
    }
    @CacheEvict("productId")
    @Override
    public void deleteCache(Integer id) {
        productInventoryMapper.deleteByPrimaryKey(id);
    }

    @CachePut( "productId")
    @Override
    public void setCache(ProductInventory productInventory) {

        productInventoryMapper.insertSelective(productInventory);
    }
}
```



### EhcacheController

```
package com.yeshen.eshop.controller;


import com.yeshen.eshop.model.ProductInventory;
import com.yeshen.eshop.service.CacheService;
import net.sf.ehcache.Ehcache;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Date;

/**
 */
@Controller
@RequestMapping("/ehcache")
public class EhcacheController {

    @Autowired
    private CacheService cacheService;

    @RequestMapping("/save")
    public String save(@RequestParam int id,@RequestParam long cout) {
        ProductInventory productInventory = new ProductInventory(id,cout);
        cacheService.setCache(productInventory);
        return "success";
    }

    @RequestMapping("/select")
    @ResponseBody
    public String get(@RequestParam(defaultValue = "1") Integer id) {

      // ProductInventory productInventory= (ProductInventory)cacheService.selectByPrimaryKey(id);
       ProductInventory productInventory= cacheService.selectByPrimaryKey(id);
        System.out.println("ID"+productInventory.getProductId());
        return "ID"+productInventory.getProductId()+"库存"+productInventory.getInventoryCnt();
    }

    @RequestMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam(defaultValue = "1") Integer id) {
        ProductInventory productInventory = new ProductInventory(3,5000L);
        cacheService.deleteCache(productInventory.getProductId());
        return "成功";
    }

}


```

### EshopApplication

```
package com.yeshen.eshop;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class EshopApplication {

    public static void main(String[] args) {
        SpringApplication.run(EshopApplication.class, args);
    }

}

```

 

### 控制台

![](https://i.loli.net/2019/12/12/zrN587DdiKteEZV.png)

