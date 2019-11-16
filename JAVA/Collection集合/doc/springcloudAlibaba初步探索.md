# 什么是nacos

​     Nacos 致力于帮助您发现、配置和管理微服务。Nacos 提供了一组简单易用的特性集，帮助您实现动态服务发现、服务配置管理、服务及流量管理。

Nacos 帮助您更敏捷和容易地构建、交付和管理微服务平台。 Nacos 是构建以“服务”为中心的现代应用架构(例如微服务范式、云原生范式)的服务基础设施。

程序启动默认占用的端口是8848

 

# 将服务注入到nacos中管理

###   引入依赖 pom

```Java
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.6.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
        <spring-cloud.version>Greenwich.RELEASE</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>


        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.springframework.cloud/spring-cloud-starter-alibaba-nacos-discovery -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>0.2.1.RELEASE</version>
        </dependency>

    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>0.2.1.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

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



###   配置文件 application：

```
spring.cloud.nacos.discovery.server-addr=127.0.01:8848
spring.application.name=discoveryDemo
server.port=8001


```

### 主程序添加@EnableDiscoveryClient

```
@SpringBootApplication
@EnableDiscoveryClient
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

}

```

**下面这个配置管理项便是nacos的注册中心服务端了**

​    访问： http://127.0.0.1:8848/nacos/





### 消费者通过RestTemplate调入服务



 **config.java**

    @Configuration
    public class RestConfig {
    
    @Bean
    public RestTemplate restTemplate(){
       return new RestTemplate();
    }
}

**controller代码**

```
package com.example.demo.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.client.ServiceInstance;
import org.springframework.cloud.client.discovery.DiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalancerClient;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestTemplate;

import java.net.URI;

@RestController
public class ComsuerController {

    @Autowired
    private RestTemplate restTemplate;

    @Autowired
    private LoadBalancerClient loadBalancerClient;

    @RequestMapping("/list")
    public String test(String msg){
        ServiceInstance serviceInstance = loadBalancerClient.choose("discoveryDemo");
        URI uri = serviceInstance.getUri();
        return restTemplate.getForObject(uri+"/list?msg="+ msg,String.class);
    }
}

```

### 消费者通过负载均衡调入服务

 **config.java**

```
@Configuration
public class RestConfig {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate(){
       return new RestTemplate();
    }
}

```

**controller 代码**

```
@RestController
public class ComsuerController {

    @Autowired
    private RestTemplate restTemplate;

    @RequestMapping("/list")
    public String test(String msg){

        return restTemplate.getForObject("http://discoveryDemo/list?msg="+ msg,String.class);
    }
}

```


### spring cloud gateway网关服务转发

**pom文件：**

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.6.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
        <spring-cloud.version>Greenwich.RELEASE</spring-cloud.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>


        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.springframework.cloud/spring-cloud-starter-alibaba-nacos-discovery -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-nacos-discovery</artifactId>
            <version>0.2.1.RELEASE</version>
        </dependency>

    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>

            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-alibaba-dependencies</artifactId>
                <version>0.2.1.RELEASE</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

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



**注入到nacos服务中 yml文件**

```
spring:
  cloud:
    nacos:
      discovery:
        server-addr: 127.0.01:8848
    gateway:
      routes:
      - id: discoveryDemo
        uri: lb://discoveryDemo
        predicates:
        - Path=/provide/**
  application:
    name: consumer
server:
  port: 8080


```



### spring cloud gateway遇到个启动错误：

```
Parameter 0 of method modifyRequestBodyGatewayFilterFactory in org.springframework.cloud.gateway.config.GatewayAutoConfiguration required a bean of type 'org.springframework.http.codec.ServerCodecConfigurer' that could not be found.
```

**错误解决方法：**

  将pom.xml中关于spring-boot-start-web模块的jar依赖去掉。

 错误分析：

 根据上面（Description）中信息了解到GatewayAutoConfiguration这个配置中找不到ServerCodecConfig这个Bean。

 spring cloud gateway server项目是一个spring boot项目，在启动的时候会去加载它的配置，其中有一个叫做GatewayClassPathWarningAutoConfiguration的配置类*。



因为spring cloud gateway是基于webflux的，如果非要web支持的话需要导入spring-boot-starter-webflux而不是spring-boot-start-web。



# Windows启动nginx

1） 直接双击该目录下的nginx.exe，即可启动nginx服务器

2） 命令行计入该文件夹，执行nginx命令，也会直接启动nginx服务器



### 访问nginx

打开浏览器，输入地址：[http://localhost，访问页面，出现如下页面表示访问]()成功![6152595-460164169e163b9f](C:\Users\Administrator\Desktop\6152595-460164169e163b9f.png)



### 停止nginx

命令行进入nginx根目录，执行如下命令，停止服务器：

```
# 强制停止nginx服务器，如果有未处理的数据，丢弃
D:/resp_application/nginx-1.13.5> nginx -s stop

# 优雅的停止nginx服务器，如果有未处理的数据，等待处理完成之后停止
D:/resp_application/nginx-1.13.5> nginx -s quit
```

## nginx配置

nginx是一个功能非常强大的web服务器加反向代理服务器，同时又是邮件服务器等等

在项目使用中，使用最多的三个核心功能是反向代理、负载均衡和静态服务器

这三个不同的功能的使用，都跟nginx的配置密切相关，nginx服务器的配置信息主要集中在nginx.conf这个配置文件中，并且所有的可配置选项大致分为以下几个部分



```
main                                # 全局配置

events {                            # nginx工作模式配置

}

http {                                # http设置
    ....

    server {                        # 服务器主机配置
        ....
        location {                    # 路由配置
            ....
        }

        location path {
            ....
        }

        location otherpath {
            ....
        }
    }

    server {
        ....

        location {
            ....
        }
    }

    upstream name {                    # 负载均衡配置
        ....
    }
}
```

如上述配置文件所示，主要由6个部分组成：

1. main：用于进行nginx全局信息的配置
2. events：用于nginx工作模式的配置
3. http：用于进行http协议信息的一些配置
4. server：用于进行服务器访问信息的配置
5. location：用于进行访问路由的配置
6. upstream：用于进行负载均衡的配置

### main模块

观察下面的配置代码



```
# user nobody nobody;
worker_processes 2;
# error_log logs/error.log
# error_log logs/error.log notice
# error_log logs/error.log info
# pid logs/nginx.pid
worker_rlimit_nofile 1024;
```

[![复制代码](https://common.cnblogs.com/images/copycode.gif)]()

[![复制代码](https://common.cnblogs.com/images/copycode.gif)](javascript:void(0);)

上述配置都是存放在main全局配置模块中的配置项

- user用来指定nginx worker进程运行用户以及用户组，默认nobody账号运行
- worker_processes指定nginx要开启的子进程数量，运行过程中监控每个进程消耗内存(一般几M~几十M不等)根据实际情况进行调整，通常数量是CPU内核数量的整数倍
- error_log定义错误日志文件的位置及输出级别【debug / info / notice / warn / error / crit】
- pid用来指定进程id的存储文件的位置
- worker_rlimit_nofile用于指定一个进程可以打开最多文件数量的描述

### event 模块

上干货

```
event {
    worker_connections 1024;
    multi_accept on;
    use epoll;
}
```

上述配置是针对nginx服务器的工作模式的一些操作配置

- worker_connections 指定最大可以同时接收的连接数量，这里一定要注意，最大连接数量是和worker processes共同决定的。
- multi_accept 配置指定nginx在收到一个新连接通知后尽可能多的接受更多的连接
- use epoll 配置指定了线程轮询的方法，如果是linux2.6+，使用epoll，如果是BSD如Mac请使用Kqueue

### http模块

作为web服务器，http模块是nginx最核心的一个模块，配置项也是比较多的，项目中会设置到很多的实际业务场景，需要根据硬件信息进行适当的配置，常规情况下，使用默认配置即可！



```
http {
    ##
    # 基础配置
    ##

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    # server_tokens off;

    # server_names_hash_bucket_size 64;
    # server_name_in_redirect off;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    ##
    # SSL证书配置
    ##

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    ##
    # 日志配置
    ##

    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;

    ##
    # Gzip 压缩配置
    ##

    gzip on;
    gzip_disable "msie6";

    # gzip_vary on;
    # gzip_proxied any;
    # gzip_comp_level 6;
    # gzip_buffers 16 8k;
    # gzip_http_version 1.1;
    # gzip_types text/plain text/css application/json application/javascript
 text/xml application/xml application/xml+rss text/javascript;

    ##
    # 虚拟主机配置
    ##

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
```



**1) 基础配置**



```
sendfile on：配置on让sendfile发挥作用，将文件的回写过程交给数据缓冲去去完成，而不是放在应用中完成，这样的话在性能提升有有好处
tc_nopush on：让nginx在一个数据包中发送所有的头文件，而不是一个一个单独发
tcp_nodelay on：让nginx不要缓存数据，而是一段一段发送，如果数据的传输有实时性的要求的话可以配置它，发送完一小段数据就立刻能得到返回值，但是不要滥用哦

keepalive_timeout 10：给客户端分配连接超时时间，服务器会在这个时间过后关闭连接。一般设置时间较短，可以让nginx工作持续性更好
client_header_timeout 10：设置请求头的超时时间
client_body_timeout 10:设置请求体的超时时间
send_timeout 10：指定客户端响应超时时间，如果客户端两次操作间隔超过这个时间，服务器就会关闭这个链接

limit_conn_zone $binary_remote_addr zone=addr:5m ：设置用于保存各种key的共享内存的参数，
limit_conn addr 100: 给定的key设置最大连接数

server_tokens：虽然不会让nginx执行速度更快，但是可以在错误页面关闭nginx版本提示，对于网站安全性的提升有好处哦
include /etc/nginx/mime.types：指定在当前文件中包含另一个文件的指令
default_type application/octet-stream：指定默认处理的文件类型可以是二进制
type_hash_max_size 2048：混淆数据，影响三列冲突率，值越大消耗内存越多，散列key冲突率会降低，检索速度更快；值越小key，占用内存较少，冲突率越高，检索速度变慢
```

**2) 日志配置**

```
access_log logs/access.log：设置存储访问记录的日志
error_log logs/error.log：设置存储记录错误发生的日志
```

**3) SSL证书加密**

```
ssl_protocols：指令用于启动特定的加密协议，nginx在1.1.13和1.0.12版本后默认是ssl_protocols SSLv3 TLSv1 TLSv1.1 TLSv1.2，TLSv1.1与TLSv1.2要确保OpenSSL >= 1.0.1 ，SSLv3 现在还有很多地方在用但有不少被攻击的漏洞。
ssl prefer server ciphers：设置协商加密算法时，优先使用我们服务端的加密套件，而不是客户端浏览器的加密套件
```

**4) 压缩配置**

```
gzip 是告诉nginx采用gzip压缩的形式发送数据。这将会减少我们发送的数据量。
gzip_disable 为指定的客户端禁用gzip功能。我们设置成IE6或者更低版本以使我们的方案能够广泛兼容。
gzip_static 告诉nginx在压缩资源之前，先查找是否有预先gzip处理过的资源。这要求你预先压缩你的文件（在这个例子中被注释掉了），从而允许你使用最高压缩比，这样nginx就不用再压缩这些文件了（想要更详尽的gzip_static的信息，请点击这里）。
gzip_proxied 允许或者禁止压缩基于请求和响应的响应流。我们设置为any，意味着将会压缩所有的请求。
gzip_min_length 设置对数据启用压缩的最少字节数。如果一个请求小于1000字节，我们最好不要压缩它，因为压缩这些小的数据会降低处理此请求的所有进程的速度。
gzip_comp_level 设置数据的压缩等级。这个等级可以是1-9之间的任意数值，9是最慢但是压缩比最大的。我们设置为4，这是一个比较折中的设置。
gzip_type 设置需要压缩的数据格式。上面例子中已经有一些了，你也可以再添加更多的格式。
```

**5) 文件缓存配置**



```
open_file_cache 打开缓存的同时也指定了缓存最大数目，以及缓存的时间。我们可以设置一个相对高的最大时间，这样我们可以在它们不活动超过20秒后清除掉。
open_file_cache_valid 在open_file_cache中指定检测正确信息的间隔时间。
open_file_cache_min_uses 定义了open_file_cache中指令参数不活动时间期间里最小的文件数。
open_file_cache_errors 指定了当搜索一个文件时是否缓存错误信息，也包括再次给配置中添加文件。我们也包括了服务器模块，这些是在不同文件中定义的。如果你的服务器模块不在这些位置，你就得修改这一行来指定正确的位置。
```



### server模块

srever模块配置是http模块中的一个子模块，用来定义一个虚拟访问主机，也就是一个虚拟服务器的配置信息



```
server {
    listen        80;
    server_name localhost    192.168.1.100;
    root        /nginx/www;
    index        index.php index.html index.html;
    charset        utf-8;
    access_log    logs/access.log;
    error_log    logs/error.log;
    ......
}
```



**核心配置信息如下：**

- server：一个虚拟主机的配置，一个http中可以配置多个server
- server_name：用力啊指定ip地址或者域名，多个配置之间用空格分隔
- root：表示整个server虚拟主机内的根目录，所有当前主机中web项目的根目录
- index：用户访问web网站时的全局首页
- charset：用于设置www/路径中配置的网页的默认编码格式
- access_log：用于指定该虚拟主机服务器中的访问记录日志存放路径
- error_log：用于指定该虚拟主机服务器中访问错误日志的存放路径

### location模块

location模块是nginx配置中出现最多的一个配置，主要用于配置路由访问信息

在路由访问信息配置中关联到反向代理、负载均衡等等各项功能，所以location模块也是一个非常重要的配置模块

**基本配置**

```
location / {
    root    /nginx/www;
    index    index.php index.html index.htm;
}
```

location /：表示匹配访问根目录

root：用于指定访问根目录时，访问虚拟主机的web目录

index：在不指定访问具体资源时，默认展示的资源文件列表

反向代理配置方式

通过反向代理代理服务器访问模式，通过proxy_set配置让客户端访问透明化

```
location / {
    proxy_pass http://localhost:8888;
    proxy_set_header X-real-ip $remote_addr;
    proxy_set_header Host $http_host;
}
```

**uwsgi配置**

wsgi模式下的服务器配置访问方式

```
location / {
    include uwsgi_params;
    uwsgi_pass localhost:8888
}
```

### upstream模块

upstream模块主要负责负载均衡的配置，通过默认的轮询调度方式来分发请求到后端服务器

简单的配置方式如下



```
upstream name {
    ip_hash;
    server 192.168.1.100:8000;
    server 192.168.1.100:8001 down;
    server 192.168.1.100:8002 max_fails=3;
    server 192.168.1.100:8003 fail_timeout=20s;
    server 192.168.1.100:8004 max_fails=3 fail_timeout=20s;
}
```



**核心配置信息如下**

- ip_hash：指定请求调度算法，默认是weight权重轮询调度，可以指定
- server host:port：分发服务器的列表配置
- -- down：表示该主机暂停服务
- -- max_fails：表示失败最大次数，超过失败最大次数暂停服务
- -- fail_timeout：表示如果请求受理失败，暂停指定的时间之后重新发起请求



# Windows下nginx搭建 nacos集群

### 

### nacos配置中心连接mysql8.0

nacos连接mysql5.7正常，但是连接mysql8.0(mysql5.8)就提示错误。

org.springframework.jdbc.CannotGetJdbcConnectionException: Failed to obtain JDBC Connection; nested exception is org.apache.commons.dbcp.SQLNestedException: Cannot create PoolableConnectionFactory (Could not create connection to database server. Attempted reconnect 3 times. Giving up.)

连接mysql5.7没问题。说明连接驱动版本有问题（为什么直接这么说呢，因为之前项目中mysql升级遇见过相同问题）。

把Nacos 自带mysql-connector-java 版本升级以下就可以了，从5.1.34升级到5.1.47。

###  修改Nacos下的pom.xml为

 <!-- JDBC libs -->

            <dependency>
                <groupId>mysql</groupId>
                <artifactId>mysql-connector-java</artifactId>
                <version>5.1.47</version>
            </dependency>


**然后执行打包命令**

cd nacos/ mvn -Prelease-nacos clean install -U



### *接着建nacos数据库*

**执行Nacos\distribution\target\nacos-server-1.1.0\nacos\conf下的nacos-mysql.sql脚本**

![55](C:\Users\Administrator\Desktop\55.png)



![33](C:\Users\Administrator\Desktop\33.png)

新建一个文件目录NacosCluster，将Nacos Server解压三份到该目录下，分别命名为`nasosSlave0、nasosSlave1、nasosSlave2`，分配端口：`8841、8842、8843`

![8888](C:\Users\Administrator\Desktop\8888.png)

修改nasosSlave0/conf/application.properties，server.port=8841，并添加



```
spring.datasource.platform=mysql 

db.num=1

db.url.0=jdbc:mysql://127.0.0.1:3306/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true

db.user=root

db.password=123456

```

拷贝nasosSlave0/conf/cluster.conf.example为`cluster.conf`，修改内容如下：

```
127.0.0.1:8845
127.0.0.1:8846
127.0.0.1:8847
```

nasosSlave1、nasosSlave2 和 nasosSlave0 除了端口不同外，其它配置保持一致。

分别启动每台 Nacos Server

```
startup.cmd -m cluster
```

观察控制台，启动成功后，在控制台可以看到如下信息：



在浏览器分别访问如下路径
`http://localhost:8841/nacos`
`http://localhost:8842/nacos`
`http://localhost:8843/nacos`

如果都能访问成功，证明集群模式部署成功。



### 配置nginx

```

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;


    upstream cluster{

     server 127.0.0.1:8841;
     server 127.0.0.1:8842;
     server 127.0.0.1:8843;

   }

   server{

    listen 10000;
    server_name loaclhost;

    location / {
     proxy_pass http://cluster;
}

}
	

}

```



在浏览器访问如下路径 localhost:10000/nacos 如果都能访问成功，证明集群模式部署成功。