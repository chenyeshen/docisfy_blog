# Spring Boot整合Ehcache实现缓存功能

### 一、Maven依赖

主要依赖如下所示：

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>springboot.example</groupId>
    <artifactId>springboot-ehcache</artifactId>
    <version>1.0-SNAPSHOT</version>
    <packaging>jar</packaging>
    <description>Spring Boot整合EhCache实现缓存功能</description>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>1.5.8.RELEASE</version>
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

        <!-- caching -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-cache</artifactId>
        </dependency>
        <dependency>
            <groupId>net.sf.ehcache</groupId>
            <artifactId>ehcache</artifactId>
        </dependency>

        <!-- 数据库依赖 -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-jpa</artifactId>
        </dependency>
        <dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
            <scope>runtime</scope>
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

上面的依赖中包括了Spring Boot的核心依赖，Ehcache依赖还有数据库JPA和MySQL的依赖。

### 二、程序的主要代码实现

##### 1、Spring Boot程序的入口

```
package com.lemon.springboot.application;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.ComponentScan;

/**
 * @author lemon
 */
@SpringBootApplication
@ComponentScan({"com.lemon.springboot"})
// 启用缓存注解
@EnableCaching
public class MainApplication {

    public static void main(String[] args) {
        SpringApplication.run(MainApplication.class, args);
    }
}

```

上面的三个注解：
1）@SpringBootApplication表明是一个Spring Boot应用；
2）@ComponentScan({"com.lemon.springboot"})扫描指定包内的注解；
3）@EnableCaching启动缓存注解（也就是说使项目内部的缓存相关的注解生效）

##### 2、application.yml和ehcache.xml配置文件

配置文件中关于数据库配置这一块仅仅配置了开发模式，生产模式和特使模式没有配置。所以启用的也是开发者模式。

```
spring:
  profiles:
    active: dev
  # 缓存配置
  cache:
    type: ehcache
    ehcache:
      config: classpath:ehcache.xml

# 日志配置
logging:
  file: /Users/lemon/IdeaProjects/springboot/lemon.log
  level: info

---
spring:
  profiles: dev
  # 数据库配置
  datasource:
      driverClassName: com.mysql.jdbc.Driver
      url: jdbc:mysql://192.168.25.11:3306/ehcachetest?characterEncoding=utf8
      username: root
      password: 123456
  jpa:
    database: MYSQL
    show-sql: true
    hibernate:
      ddl-auto: update
      naming_strategy: org.hibernate.cfg.ImprovedNamingStrategy
      use_sql_comments: false
      format_sql: true
      hbm2ddl_auto: update
      generate_statistics: false
      validation_mode: none
      store_data_at_delete: true
      global_with_modified_flag: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL5Dialect
server:
  port: 8080

---
spring:
  profiles: pro
server:
  port: 8081

---
spring:
  profiles: test
server:
  port: 8082

```

ehcache.xml配置文件：

```
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="http://ehcache.org/ehcache.xsd">

    <cache name="lemonCache"
           eternal="false"
           maxEntriesLocalHeap="0"
           timeToIdleSeconds="200"/>

    <!-- eternal：true表示对象永不过期，此时会忽略timeToIdleSeconds和timeToLiveSeconds属性，默认为false -->
    <!-- maxEntriesLocalHeap：堆内存中最大缓存对象数，0没有限制 -->
    <!-- timeToIdleSeconds： 设定允许对象处于空闲状态的最长时间，以秒为单位。当对象自从最近一次被访问后，
    如果处于空闲状态的时间超过了timeToIdleSeconds属性值，这个对象就会过期，EHCache将把它从缓存中清空。
    只有当eternal属性为false，该属性才有效。如果该属性值为0，则表示对象可以无限期地处于空闲状态 -->
</ehcache>

```

##### 3、实体类

这里新建一个实体类，用来创造对象存入数据库和缓存。

```
package com.lemon.springboot.domain;

import javax.persistence.*;
import java.util.Date;

/**
 * @author lemon
 */
@Entity
@Table(name = "user")
public class User {

    @Id
    @GeneratedValue
    private Integer id;
    @Column
    private String name;
    @Column
    private Integer age;
    @Column
    private String address;
    @Column
    private Date createTime;

    public Date getCreateTime() {
        return createTime;
    }

    public void setCreateTime(Date createTime) {
        this.createTime = createTime;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getAge() {
        return age;
    }

    public void setAge(Integer age) {
        this.age = age;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", age=" + age +
                ", address='" + address + '\'' +
                ", createTime=" + createTime +
                '}';
    }
}

```

##### 4、与数据库交互的Repository

创建一个与数据库交互的Repository，这个Repository只需要继承JpaRepository即可，对于简单的增删改查，就不需要额外扩展功能了。

```
package com.lemon.springboot.repository;

import com.lemon.springboot.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * @author lemon
 */
public interface UserRepository extends JpaRepository<User, Integer> {

}

```

对于Spring Boot应用，需要创建JPA的配置类：

```
package com.lemon.springboot.configuration;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.domain.EntityScan;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.Database;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.transaction.support.TransactionTemplate;

import javax.sql.DataSource;
import java.util.Properties;

/**
 * JPA配置类
 *
 * @author lemon
 */
@Order(Ordered.HIGHEST_PRECEDENCE)
@Configuration
@EnableTransactionManagement(proxyTargetClass = true)
@EnableJpaRepositories(basePackages = "com.lemon.springboot.repository")
@EntityScan(basePackages = "com.lemon.springboot.domain")
public class JpaConfiguration {

    @Value("${spring.datasource.driverClassName}")
    private String driverClassName;
    @Value("${spring.datasource.url}")
    private String url;
    @Value("${spring.datasource.username}")
    private String username;
    @Value("${spring.datasource.password}")
    private String password;
    @Value("${spring.jpa.properties.hibernate.dialect}")
    private String dialect;
    @Value("${spring.jpa.show-sql}")
    private String showSql;
    @Value("${spring.jpa.hibernate.use_sql_comments}")
    private String useSqlComments;
    @Value("${spring.jpa.hibernate.format_sql}")
    private String formatSql;
    @Value("${spring.jpa.hibernate.hbm2ddl_auto}")
    private String hbm2ddlAuto;
    @Value("${spring.jpa.hibernate.generate_statistics}")
    private String generateStatistics;
    @Value("${spring.jpa.hibernate.validation_mode}")
    private String validationMode;
    @Value("${spring.jpa.hibernate.store_data_at_delete}")
    private String storeDataAtDelete;
    @Value("${spring.jpa.hibernate.global_with_modified_flag}")
    private String globalWithModifiedFlag;

    @Bean
    PersistenceExceptionTranslationPostProcessor persistenceExceptionTranslationPostProcessor() {
        return new PersistenceExceptionTranslationPostProcessor();
    }

    @Bean
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName(driverClassName);
        dataSource.setUrl(url);
        dataSource.setUsername(username);
        dataSource.setPassword(password);
        return dataSource;
    }

    @Bean
    public LocalContainerEntityManagerFactoryBean entityManagerFactory() {
        LocalContainerEntityManagerFactoryBean entityManagerFactoryBean = new LocalContainerEntityManagerFactoryBean();
        entityManagerFactoryBean.setDataSource(dataSource());
        entityManagerFactoryBean.setPackagesToScan("com.lemon.springboot.domain");
        entityManagerFactoryBean.setJpaProperties(buildHibernateProperties());
        entityManagerFactoryBean.setJpaVendorAdapter(new HibernateJpaVendorAdapter() {{
            setDatabase(Database.MYSQL);
        }});
        return entityManagerFactoryBean;
    }

    protected Properties buildHibernateProperties() {
        Properties hibernateProperties = new Properties();
        hibernateProperties.setProperty("hibernate.dialect", dialect);
        hibernateProperties.setProperty("hibernate.show_sql", showSql);
        hibernateProperties.setProperty("hibernate.use_sql_comments", useSqlComments);
        hibernateProperties.setProperty("hibernate.format_sql", formatSql);
        hibernateProperties.setProperty("hibernate.hbm2ddl.auto", hbm2ddlAuto);
        hibernateProperties.setProperty("hibernate.generate_statistics", generateStatistics);
        hibernateProperties.setProperty("javax.persistence.validation.mode", validationMode);

        //Audit History flags
        hibernateProperties.setProperty("org.hibernate.envers.store_data_at_delete", storeDataAtDelete);
        hibernateProperties.setProperty("org.hibernate.envers.global_with_modified_flag", globalWithModifiedFlag);

        return hibernateProperties;
    }

    @Bean
    public PlatformTransactionManager transactionManager() {
        return new JpaTransactionManager();
    }

    @Bean
    public TransactionTemplate transactionTemplate() {
        return new TransactionTemplate(transactionManager());
    }
}

```

##### 5、与缓存相关的代码

EhcacheRepository：

```
package com.lemon.springboot.repository;

import com.lemon.springboot.domain.User;

/**
 * @author lemon
 */
public interface EhcacheRepository {

    /**
     * 增加用户
     * @param user 用户
     * @return 增加后的用户
     */
    User save(User user);

    /**
     * 查询用户
     * @param id 主键
     * @return 用户
     */
    User selectById(Integer id);

    /**
     * 更新用户
     * @param user 更新的用户
     * @return 用户
     */
    User updateById(User user);

    /**
     * 删除用户
     * @param id 主键
     * @return 删除状态
     */
    String deleteById(Integer id);

}

```

它的实现类：

```
package com.lemon.springboot.repository.impl;

import com.lemon.springboot.domain.User;
import com.lemon.springboot.repository.EhcacheRepository;
import com.lemon.springboot.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.CacheConfig;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Repository;

/**
 * @author lemon
 */
// cacheNames为ehcache.xml配置文件内的配置名称
@CacheConfig(cacheNames = {"lemonCache"})
@Repository
public class EhcacheRepositoryImpl implements EhcacheRepository {

    private static final Logger logger = LoggerFactory.getLogger(EhcacheRepository.class);

    @Autowired
    private UserRepository userRepository;

    @CachePut(key = "#user.getId")
    @Override
    public User save(User user) {
        User savedUser = userRepository.save(user);
        logger.info("新增功能，同步到缓存，直接写入数据库，ID为：" + savedUser.getId());
        return savedUser;
    }

    @Cacheable(key = "#id")
    @Override
    public User selectById(Integer id) {
        logger.info("查询功能，缓存未找到，直接读取数据库，ID为：" + id);
        return userRepository.findOne(id);
    }

    @CachePut(key = "#user.getId")
    @Override
    public User updateById(User user) {
        logger.info("更新功能，更新缓存，直接更新数据库，ID为：" + user.getId());
        return userRepository.save(user);
    }

    @CacheEvict(key = "#id")
    @Override
    public String deleteById(Integer id) {
        logger.info("删除功能，删除缓存，直接删除数据库数据，ID为：" + id);
        userRepository.delete(id);
        return "删除成功";
    }
}

```

注意：
1）@CacheConfig(cacheNames = {"lemonCache"})设置了ehcache的名称，这个名称就是ehcache.xml内的名称；
2）@Cacheable：应用到读取数据的方法上，即可缓存的方法，如查找方法：先从缓存中读取，如果没有再调 用方法获取数据，然后把数据添加到缓存中，适用于查找；
3）@CachePut：主要针对方法配置，能够根据方法的请求参数对其结果进行缓存，和 @Cacheable 不同的是，它每次都会触发真实方法的调用。适用于更新和插入；
4）@CacheEvict：主要针对方法配置，能够根据一定的条件对缓存进行清空。适用于删除。

### 三、测试的Controller

```
package com.lemon.springboot.controller;

import com.lemon.springboot.domain.User;
import com.lemon.springboot.repository.EhcacheRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.Date;

/**
 * @author lemon
 */
@Controller
@RequestMapping("/ehcache")
public class EhcacheController {

    @Autowired
    private EhcacheRepository ehcacheRepository;

    @RequestMapping("/save")
    @ResponseBody
    public User save() {
        User user = new User();
        user.setName("lemon");
        user.setAge(20);
        user.setAddress("Wuhan");
        user.setCreateTime(new Date());
        return ehcacheRepository.save(user);
    }

    @RequestMapping("/select")
    @ResponseBody
    public User get(@RequestParam(defaultValue = "1") Integer id) {
        return ehcacheRepository.selectById(id);
    }

    @RequestMapping("/update")
    @ResponseBody
    public User update(@RequestParam(defaultValue = "1") Integer id) {
        User user = ehcacheRepository.selectById(id);
        user.setName("TestName");
        user.setCreateTime(new Date());
        return ehcacheRepository.updateById(user);
    }

    @RequestMapping("/delete")
    @ResponseBody
    public String delete(@RequestParam(defaultValue = "1") Integer id) {
        return ehcacheRepository.deleteById(id);
    }

}

```

启动项目，打开浏览器，输入地址：[http://localhost:8080/ehcache/save](https://link.jianshu.com?t=http://localhost:8080/ehcache/save)就可以实现插入数据，再输入[http://localhost:8080/ehcache/select?id=1](https://link.jianshu.com?t=http://localhost:8080/ehcache/select?id=1)就可以查询到数据，这时候观察控制台或者日志就可以发现，查询的时候并没有去访问数据库，而是直接在缓存中查询了，至于更新和删除，道理是一样的。