### 依赖pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.7.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.yeshen</groupId>
    <artifactId>xdvideo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>xdvideo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-thymeleaf</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>2.1.0</version>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
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
        </dependency>

        <dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper-spring-boot-starter</artifactId>
            <version>2.1.0</version>

        </dependency>

        <!--pagehelper-->
        <dependency>
            <groupId>com.github.pagehelper</groupId>
            <artifactId>pagehelper-spring-boot-starter</artifactId>
            <version>1.2.3</version>
        </dependency>

        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>druid-spring-boot-starter</artifactId>
            <version>1.1.10</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/io.jsonwebtoken/jjwt -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt</artifactId>
            <version>0.9.0</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.apache.httpcomponents/httpclient -->
        <dependency>
            <groupId>org.apache.httpcomponents</groupId>
            <artifactId>httpclient</artifactId>
            <version>4.5.3</version>
        </dependency>

        <!-- https://mvnrepository.com/artifact/cn.hutool/hutool-all -->
        <dependency>
            <groupId>cn.hutool</groupId>
            <artifactId>hutool-all</artifactId>
            <version>4.5.10</version>
        </dependency>

        <!--swagger2-->
        <dependency>
            <groupId>io.springfox</groupId>
            <artifactId>springfox-swagger2</artifactId>
            <version>2.9.2</version>
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
# log
logging.level.com.yeshen.xdvideo.mapper=debug


# Server settings
server:
    port: 8080

################################### 数据源配置 ###################################
# SPRING PROFILES
spring:
    datasource:
        type: com.alibaba.druid.pool.DruidDataSource
        driver-class-name: com.mysql.jdbc.Driver
        url: jdbc:mysql://localhost:3306/xdvideo?useUnicode=true&characterEncoding=utf-8&autoReconnect=true&zeroDateTimeBehavior=convertToNull&allowMultiQueries=true&useSSL=false
        username: root
        password: root
    application:
        name: xdvideo
    # HTTP ENCODING

    # redis缓存服务配置
    session:
        store-type: redis
    # Redis数据库索引（默认为0）
#    redis:
#        database: 1
#        # Redis服务器地址
#        host: 127.0.0.1
#        # Redis服务器连接端口
#        port: 6379
#        # Redis服务器连接密码（默认为空）
#        password: 123456
#        # 连接池最大连接数（使用负值表示没有限制）
#        pool:
#            maxActive: 8
#            # 连接池最大阻塞等待时间（使用负值表示没有限制）
#            maxWait: -1
#            # 连接池中的最大空闲连接
#            maxIdle: 8
#            # 连接池中的最小空闲连接
#            minIdle: 0
#        # 连接超时时间（毫秒）
#        timeout: 0
#        # 默认的数据过期时间，主要用于shiro权限管理
#        expire: 2592000

# MyBatis
mybatis:

  configuration:
    map-underscore-to-camel-case: true
    cache-enabled: true
#    type-aliases-package: com.yeshen.xdvideo.domain
#    mapper-locations: classpath:/mapper/*.xml

# pagehelper
pagehelper:
    helper-dialect: mysql
    reasonable: true
    support-methods-arguments: true
    params: count=countSql

################################### 程序自定义配置 ###################################
yeshen:
    druid:
        # druid访问用户名（默认：yeshen）
        username: yeshen
        # druid访问密码（默认：123456）
        password: 123456
        # druid访问地址（默认：/druid/*）
        servletPath: /druid/*
        # 启用重置功能（默认false）
        resetEnable: false
        # 白名单(非必填)， list
        allowIps[0]:
        # 黑名单(非必填)， list
        denyIps[0]:


```

### 新建目录  

![file](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190824111425933.png)

### config目录 :

####  **DruidConfig.java**

```
package com.yeshen.xdvideo.config;

import com.alibaba.druid.support.http.StatViewServlet;
import com.alibaba.druid.support.http.WebStatFilter;
import com.yeshen.xdvideo.property.DruidProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * Druid Monitor 配置
 *
 */
@Configuration
public class DruidConfig {

    @Autowired
    private DruidProperties druidProperties;

    @Bean
    public ServletRegistrationBean druidStatViewServlet() {
        ServletRegistrationBean bean = new ServletRegistrationBean(new StatViewServlet(), druidProperties.getServletPath());

        // IP黑名单 (存在共同时，deny优先于allow) : 如果满足deny的话提示:Sorry, you are not permitted to view this page.
        List<String> denyIps = druidProperties.getDenyIps();
        if(!CollectionUtils.isEmpty(denyIps)){
            bean.addInitParameter("deny", StringUtils.collectionToDelimitedString(denyIps, ","));
        }

        // IP白名单
        List<String> allowIps = druidProperties.getAllowIps();
        if(!CollectionUtils.isEmpty(allowIps)){
            bean.addInitParameter("allow", StringUtils.collectionToDelimitedString(allowIps, ","));
        }

        // 登录查看信息的账号密码.
        bean.addInitParameter("loginUsername", druidProperties.getUsername());
        bean.addInitParameter("loginPassword", druidProperties.getPassword());
        // 禁用HTML页面上的"Reset All"功能（默认false）
        bean.addInitParameter("resetEnable", String.valueOf(druidProperties.getResetEnable()));
        return bean;
    }

    /**
     * Druid的StatFilter
     * @return
     */
    @Bean
    public FilterRegistrationBean druidStatFilter() {
        FilterRegistrationBean bean = new FilterRegistrationBean(new WebStatFilter());
        // 添加过滤规则
        bean.addUrlPatterns("/*");
        // 排除的url
        bean.addInitParameter("exclusions","*.js,*.gif,*.jpg,*.png,*.css,*.ico,/druid/*");
        return bean;
    }
}

```

  

#### **SwaggerConfig.java**

```
package com.yeshen.xdvideo.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.service.Contact;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@Configuration
@EnableSwagger2
public class SwaggerConfig {

    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.any())
                .paths(PathSelectors.any())
                .build();
    }

    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("后端接口标题")
                .description("后端接口描述")
                .contact(
                        new Contact("yeshen", "chenyeshen.cf", "mukeyeshen@gmail.com")
                )
                .version("1.0.0-SNAPSHOT")
                .build();
    }
}

```



### plugin目录 :

#### BaseMapper.java

```
package com.yeshen.xdvideo.plugin;

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

### property目录  :

#### DruidProperties.java

```
package com.yeshen.xdvideo.property;

import lombok.Data;
import lombok.EqualsAndHashCode;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;

import java.util.List;

/**
 * druid属性
 *
 */
@Configuration
@ConfigurationProperties(prefix = "yeshen.druid")
@Data
@EqualsAndHashCode(callSuper = false)
@Order(-1)
public class DruidProperties {
    private String username;
    private String password;
    private String servletPath = "/druid/*";
    private Boolean resetEnable = false;
    private List<String> allowIps;
    private List<String> denyIps;
}

```



### runner目录 :

#### XdvideoApplicationRunner.java

```
package com.yeshen.xdvideo.runner;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * 程序启动后通过ApplicationRunner处理一些事务
 *
 */
@Slf4j
@Component
public class XdvideoApplicationRunner implements ApplicationRunner {

    @Value("${server.port}")
    private int port;

    @Override
    public void run(ApplicationArguments applicationArguments) {
        log.info("程序部署完成，访问地址：http://localhost:" + port);
    }
}

```

### 主运行application

#### XdvideoApplication.java

```
package com.yeshen.xdvideo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import springfox.documentation.swagger2.annotations.EnableSwagger2;

@SpringBootApplication
@EnableSwagger2
public class XdvideoApplication {

    public static void main(String[] args) {
        SpringApplication.run(XdvideoApplication.class, args);
    }

}

```