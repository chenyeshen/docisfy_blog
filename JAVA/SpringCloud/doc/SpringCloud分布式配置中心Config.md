# SpringCloud分布式配置中心Config



> SpringCloudConfig是SpringCloud创建的用来为分布式系统中的基础设施和微服务应用提供集中化的外部配置支持，它分为客户端和服务端两部分。服务端也称为分布式配置中心，是一个独立的微服务应用，用来连接配置仓库并为客户端提供获取配置信息，加密/解密信息等访问接口。而客户端则是微服务架构中各微服务应用或基础设施，通过指定的配置中心来管理应用资源与业务相关的配置内容，并在启动的时候从配置中心获取和加载配置信息。

# 使用

## 构建配置中心

新建一个SpringBoot项目，命名config-server；添加一下依赖：

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-config-server</artifactId>
</dependency>
```

在主类上使用`@EnableConfigServer`注解来开启配置中心服务端功能。

```
@SpringBootApplication
@EnableConfigServer
public class ConfigserverApplication {

    public static void main(String[] args) {
        SpringApplication.run(ConfigserverApplication.class, args);
    }
}
```

在application.properties文件中添加git仓库配置：

```
##端口号
server.port=9000

##服务名称
spring.application.name=config_server

##注册中心地址
eureka.client.service-url.defaultZone=http://eureka.yeshen.cn:8761/eureka/

##远程仓库配置

##git仓库地址
spring.cloud.config.server.git.uri=https://github.com/chenyeshen/SpringCloudConfig.git

##git仓库配置路径
spring.cloud.config.server.git.searchPaths=application

##git仓库分支
spring.cloud.config.label=master

##如果为公开仓库，用户名密码可不填
##git仓库用户名
#spring.cloud.config.server.git.username=

##git仓库密码
#spring.cloud.config.server.git.password=
```

然后启动项目，如果成功启动，继续下面步骤。

## 仓库配置

根据上面git配置信息指定的仓库位置创建一个config-client目录作为配置仓库，并新建一下3个文件：

![](https://i.loli.net/2019/12/21/lnwdZ146MHFBmEx.png)

**application.yml**

```
spring:
  profiles:
    active: dev
---
spring:
  profiles:
    active: test
```

**application-test.yml**

![](https://i.loli.net/2019/12/21/Fw73udmzRAgXcL4.png)

**application-dev.yml**

![](https://i.loli.net/2019/12/21/m8MphDVrzg1loTG.png)

**测试结果1：**

![](https://i.loli.net/2019/12/21/nLVvBG3YkhtZpyJ.png)

**测试结果2：**

![](https://i.loli.net/2019/12/21/mgjqEWYJwl2nOSB.png)

## 客户端配置

同样新建一个SpringBoot项目，命名config-client，映入依赖：

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-config</artifactId>
</dependency>
```

创建bootstrap.properties文件来获取配置文件的config-server位置。属性配置必须在bootstrap.properties文件中才正确加载config-server中的配置信息。

```
#配置服务名
spring.application.name=wqh
#服务id
server.port=60000
#配置对应文件规则中的{profile}部分
spring.cloud.config.profile=test
#配置对应文件规则中的{label}
spring.cloud.config.label=config-label
#配置中心的地址
spring.cloud.config.uri=http://localhost:9000/
```

创建一个接口来获取配置中心的name属性：

```
@RestController
@RefreshScope
public class HelloController {
    @Value("${form}")
    private String form;

    @Autowired
    private Environment environment;
    @GetMapping("/get_name")
    public String name(){
        return "form:"+form;
    }
    @GetMapping("/get_name_env")
    public String name_env(){
        return environment.getProperty("form","undefine");
    }
}
```

访问接口即可获取指定的信息。

# 配置介绍

架构
![img](https://segmentfault.com/img/remote/1460000012908859?w=672&h=387)
客户端从配置管理中获取配置流程：

> 1. 应用启动，根据bootstrap.properties中配置的应用名{application}、环境名{profile}、分支名{label}，行配置中心获取配置信息。
> 2. ConfigServer根据自己维护的Git仓库信息和客户端传递过来的配置定位信息去查找配置信息。
> 3. 通过git clone命令将找到的配置信息下载到ConfigServer的文件系统中。
> 4. ConfigServer创建Spring的ApplicationContext实例，并从git本地仓库中加载配置文件，最后将这些配置文件内容读取出来返回给客户端
> 5. 客户端应用在获得外部配置文件后加载到客户端ApplicationContext实例，该配置内容的优先级高于客户端Jar包内部的配置内容，所以在Jar包中重复的内容将不再被加载。

## 服务端配置

- **URL占位符配置**

前面用到了三种占位符：

> 1. {application}：映射到客户端的spring.application.name
> 2. {profile}：映射到客户端的spring.profiles.active或者是application-{profile}.yml
> 3. {label}：映射到版本库的分支

这些占位符除了用于表示配置文件的规则外，还可以用于ConfigServer中对git仓库的URI配置。如：

```
spring.cloud.config.server.git.uri=https://github.com/wqh8522/spring-cloud-config/{application}
```

使用{label}占位符需要注意，如果git仓库分支和标签包含“/”，那么{label}参数在HTTP的URL中应该使用“(_)”来替代。

## 客户端配置

- **失败快速响应**

在客户端的bootstrap.properties文件中添加配置即可：

```
spring.cloud.config.fail-fast=true
```

- **重试机制**

客户端需要使用spring-retry和spring-boot-starter-aop依赖：

```
<dependency>
    <groupId>org.springframework.retry</groupId>
    <artifactId>spring-retry</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-aop</artifactId>
</dependency>
```

重试机制的配置：

> \# 配置重试次数，默认为6
> spring.cloud.config.retry.max-attempts=6
> \# 间隔乘数，默认1.1
> spring.cloud.config.retry.multiplier=1.1
> \# 初始重试间隔时间，默认1000ms
> spring.cloud.config.retry.initial-interval=1000
> \# 最大间隔时间，默认2000ms
> spring.cloud.config.retry.max-interval=2000

- **动态刷新**

添加`spring-boot-starter-actuator`依赖

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

重启客户端，查看控制台可以看有/refresh接口，通过post请求发送到该接口就能刷新配置。
![img](https://segmentfault.com/img/remote/1460000012908860?w=926&h=109)

## 加密解密

在jdk自带了限制长度的JCE，所以从Oracle官网下载不限制长度版本：[点击下载jce8](http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip)，解压之后得到三个文件
![img](https://segmentfault.com/img/remote/1460000012908861?w=279&h=93)
将上面两个jar包复制到jrelibsecurity中将原来的覆盖

- **对称加密**

对称加密简单，只需要设置密钥即可，但是这个密钥必须配置在**bootstrap.properties**中，否则无法获取到密钥信息。如下：

```
encrypt.key=wqh3520
```

访问`/encrypt/status`接口：
![img](https://segmentfault.com/img/remote/1460000012908862?w=450&h=137)
加密相关接口：

1. /encrypt/status：查看加密状态；
2. /key：查看密钥端点；
3. /encrpt：对请求的body内容进行加密的端点；
4. /decrypt：对请求的body内容解密的端点。

接着使用postman等工具来加密解密数据：
![img](https://segmentfault.com/img/remote/1460000012908863?w=1119&h=484)
这里加密数据之后，拿到加密后的字符在配置文件中使用需要以{cipher}开头，如：

```
form={cipher}0fa7c3c11e5625fe3d90f03ac8820aaaa90336a4245b5d90cea61547ef94b8f7
```

- **非对称加密**

对称只要配置一个密钥即可，而非对称加密是密钥对，所以安全性比对称加密要搞。生成密钥对可以使用jdk自带的keytool工具，使用命令：

```
keytool -genkeypair -alias config-server -keyalg RSA -keystore config-server.keystore
```

![img](https://segmentfault.com/img/remote/1460000012908864?w=644&h=347)
然后再命令执行的文件夹下会生成一个名为：`config-server.keystore`的文件，将其拷贝到配置中心的`src\main\resources`目录下。然后在配置文件中添加加密配置：

```
encrypt.key-store.location=config-server.keystore
encrypt.key-store.alias=config-server
#在命令行第一次输入的密钥库口令
encrypt.key-store.password=123456
#最后输入的口令
encrypt.key-store.secret=654321
```

后面的操作与对称加密一样。

# 配置高可用配置中心

## 改造config-server

在微服务架构中，基本每一个服务都会配置成高可用的，配置中心也一样。对上面的config-server进行改造，添加eureka的依赖，是其作为服务在服务注册中心注册。

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
```

在主类上使用`@EnableEurekaClient`或`@EnableDiscoveryClient`开启服务发现功能，使其成为eureka的一个客户端。然后添加eureka的相关配置：

```
eureka.client.service-url.defaultZone=http://localhost:8888/eureka
```

## 改造config-client

与前面一样需要添加依赖，使用注解开启功能和配注册中心。另外还需要修改`spring.cloud.config.*`的配置，最终配置如下：

```
#配置服务名
spring.application.name=wqh
#服务id
server.port=60000
eureka.client.service-url.defaultZone=http://localhost:8888/eureka
#开启通过服务来访问config-server
spring.cloud.config.discovery.enabled=true
#指定配置中心注册的服务名
spring.cloud.config.discovery.service-id=config-server
spring.cloud.config.profile=dev
```

------

参考：《SpringCloud微服务实战》