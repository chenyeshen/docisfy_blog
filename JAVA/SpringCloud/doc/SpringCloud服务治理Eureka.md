# SpringCloud服务治理Eureka



## SpringCloud简介

直接应用官方文档的介绍：<https://springcloud.cc/spring-cloud-dalston.html>
![img](https://segmentfault.com/img/remote/1460000012832185?w=1010&h=660)

## SpringCloudEureka简介

<!--more-->
Eureka是Netfix开发的服务发现框架，SpringCloudEureka是SpringCloudNetfix下的一个子项目，它对Eureka进行了二次封装，通过为Eureka添加SpringBoot风格的自动化配置，我们主需要简单的引入依赖和注解就能在SpringBoot构建的微服务应用轻松地与Eureka服务治理体系进行整合。<!--附上[DD大佬](http://blog.didispace.com/)的Spring Cloud微服务实战。-->

## 创建服务注册中心

首先，使用maven创建一个父项目，这里就不详细介绍maven创建项目了。其pom文件如下：这里主要是处理相同依赖，以及添加SpringCloud的依赖，SpringCloud的版本为`Edgware.RELEASE`。

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.wqh</groupId>
    <artifactId>spring-cloud</artifactId>
    <version>1.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>spring-cloud</name>
    <description>Demo project for Spring Boot</description>

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

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>Edgware.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
</project>
```

然后创建一个基础的SpringBoot工程，这里命名为eureka-server，然后修改其pom文件，将父项目改为上面创建的项目

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>com.wqh</groupId>
        <artifactId>spring-cloud</artifactId>
        <version>1.0.0-SNAPSHOT</version>
    </parent>
    <artifactId>eureak-server</artifactId>
    <packaging>pom</packaging>
    <name>${project.artifactId}</name>
    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>
    <dependencies>
         <!--添加Eureka Server的依赖-->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-eureka-server</artifactId>
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

在父项目的pom文件中添加`eureak-server`的`module`

```
    <modules>
        <module>eureka-server</module>
    </modules>
```

修改配置文件，这里我将配置文件改为`yml`格式

```
#=========================================
#           配置项目名已经端口默认端口是8761
#=========================================
spring:
  application:
    name: eureak-server
server:
  port: 8888
#=========================================
#           配置eureka的基本信息
#=========================================
eureka:
  instance:
    hostname: localhost
  client:
    serviceUrl:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
    fetch-registry: false
    register-with-eureka: false
```

- eureka.client.fetch-registery：由于注册中心的职责是维护服务实例，不需要检索服务，所以设置为false；
- eureka.client.register-with-eureka：设置false，表示不向注册中心注册自己。

最后使用`@EnableEurekaServer`注解开启服务注册中心功能，

```
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {

    public static void main(String[] args) {
        SpringApplication.run(EurekaServerApplication.class, args);
    }
}
```

启动项目，在地址栏输入：[http://localhonst](http://localhonst/):8888
![img](https://segmentfault.com/img/remote/1460000012832186?w=1335&h=623)

## 添加身份验证

修改上面注册中心的配置文件，开启安全验证已经配置登录用户名和密码

```
#=========================================
#           添加安全验证
#=========================================
security:
  basic:
    enabled: true
  user:
    password: password1234
    name: user
```

因为SpringCloudEureka的安全是基于SpringSecurity，所以需要添加依赖

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-security</artifactId>
</dependency>
```

修改配置文件的`eureka.client.serviceUrl.defaultZone`

```
http://${security.user.name}:${security.user.password}@${eureka.instance.hostname}:${server.port}/eureka/
```

重启项目，再次访问。在浏览器会出现输入账号密码弹框，配置成功。

## 创建服务提供者

按照上面创建注册中心的方式创建一个`module`,这里名字为`service-article`。添加所需依赖：

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
```

在主类上使用`@EnableEurekaClient`注解激活Eureka的DiscoveryClient实现。这里也可以使用`@EnableDiscoveryClient`。两个注解基本相同，如果选用的注册中心是eureka，那么就推荐@EnableEurekaClient，如果是其他的注册中心，那么推荐使用@EnableDiscoveryClient。

```
@SpringBootApplication
@EnableEurekaClient
public class ArticleApplication {

    public static void main(String[] args) {
        SpringApplication.run(ArticleApplication.class, args);
    }
}
```

配置信息，
`eureka.client.serviceUrl.defaultZone`：属性对应服务注册中心的配置内容，指定服务注册中心的位置。

```
spring:
  application:
    name: article-service
server:
  port: 30000
eureka:
  client:
    serviceUrl:
      defaultZone: http://user:password1234@localhost:8888/eureka/
```

启动项目，再次刷新注册中心：
![img](https://segmentfault.com/img/remote/1460000012832187)
这里服务的id位主机电脑名：服务名：端口号，点击该Status，进入的地址也是主机名+端口号。通过修改配置文件信息，可以修改：

```
eureka:
  instance:
   #使用ip显示
    prefer-ip-address: true
     #设置服务在注册中显示的Status
    instance-id: ${spring.application.name}:${spring.application.instance_id:${server.port}}
```

![img](https://segmentfault.com/img/remote/1460000012832188?w=1197&h=361)

## 高可用的注册中心

分布式项目在生产环境中一般都会使用高可用部署方式，下面介绍关于高可用注册中心的配置，构建双节点的服务注册中心集群。
在eureka-server中创建application-peer1.yml文件，作为peer1服务中心的配置。将serviceUrl指向peer2

```
spring:
  application:
    name: eureka-server
server:
  port: 8888
eureka:
  instance:
    hostname: peer1
  client:
    serviceUrl:
      defaultZone: http://peer2:8889/eureka/
```

同样创建application-peer2.yml文件作为peer2服务中心的配置。将serviceUrl指向peer1

```
spring:
  application:
    name: eureka-server
server:
  port: 8889
eureka:
  instance:
    hostname: peer2
  client:
    serviceUrl:
      defaultZone: http://peer1:8888/eureka/
```

接下来运行项目，介绍两种方式

1. 修改`application.yml`文件的`spring.profiles.active`，首先设置为peer1启动项目，然后设置为peer2启动项目。当然这种方式部署不适合在生产环境。
2. 打包为jar，然后运行jar包：

```
java -jar eureak-server-1.0.0-SNAPSHOT.jar --spring.profiles.active=peer1


java -jar eureak-server-1.0.0-SNAPSHOT.jar --spring.profiles.active=peer2

```

这里还需要修改hosts文件，添加一下内容：

```
127.0.0.1 peer1
127.0.0.1 peer2
```

访问peer1，可以看到已经有peer2节点的`eureka-server`了。
![img](https://segmentfault.com/img/remote/1460000012832189?w=854&h=678)
设置多节点的服务注册中心之后，还需要修改微服务的`serveiceUrl`：

```
eureka:
  client:
    serviceUrl:
      defaultZone: http://peer1:8888/eureka/,http://peer2:8889/eureka/
```

重启服务提供者，可以在上面两个注册中心看到该服。