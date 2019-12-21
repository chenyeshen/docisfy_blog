# Spring Cloud Gateway入门

## 简介

Spring Cloud Gateway是Spring Cloud大家族的一个新进成员，在Spring Cloud 2.0之后用于取代非官方的Zuul。Getaway基于Spring 5.0与Spring WebFlux开发，采用Reactor响应式设计。

为什么需要网关
微服务架构的系统由各个相互独立的程序组成，对于服务之间的调用可以通过Consul等注册中心提供的服务注册与发现实现。但是对外暴露给客户端的接口不能要求客户端通过Consul等注册中心发现服务。网关的常见作用为隐藏后端服务、路由转发、限流(黑名单)控制、权限校验、也可以作为链路跟踪的起点。

## 原理

必读的官方文档：[https://cloud.spring.io/spring-cloud-static/spring-cloud-gateway/2.1.0.RELEASE/single/spring-cloud-gateway.html](https://links.jianshu.com/go?to=https%3A%2F%2Fcloud.spring.io%2Fspring-cloud-static%2Fspring-cloud-gateway%2F2.1.0.RELEASE%2Fsingle%2Fspring-cloud-gateway.html)

![img](http://upload-images.jianshu.io/upload_images/17766088-4cc575a37c36e59c.png?imageMogr2/auto-orient/strip|imageView2/2/w/542/format/webp)

逻辑图

术语
路由(Route)：路由为一组断言与一组过滤器的集合，他是网关的一个基本组件。
断言(Predicate)：匹配路由的判断条件，例如Path=/demo，匹配后应用路由。
过滤器(Filter)：过滤器可以对请求和返回进行修改，比如增加头信息等。
地址(Uri)：匹配路由后转发的地址。

官方提供了许多默认的断言与过滤器，基本能覆盖常用到的操作，更多详细的内容参考官方文档。

## 使用

快速搭建Spring系列的应用可以使用官方的工具生成项目代码：[https://start.spring.io/](https://links.jianshu.com/go?to=https%3A%2F%2Fstart.spring.io%2F)

idea中也集成了该方式的使用

![img](http://upload-images.jianshu.io/upload_images/17766088-9e50f98be740d719.png?imageMogr2/auto-orient/strip|imageView2/2/w/758/format/webp)

新建项目示例图

基于代码方式的路由配置：

```
 @Bean
    public RouteLocator customRouteLocator(RouteLocatorBuilder builder) {
        return builder.routes()
                      .route("baidu_route", r -> r.path("/baidu")
                                                  .filters(f -> f.addResponseHeader("hello", "Gateway"))
                                                  .uri("http://baidu.com")
                                                  .order(1))

                      .build();
    }

```

基于配置文件的路由配置

```
spring:
  cloud:
    gateway:
      routes:
        - id: qq_route
          uri: http://qq.com
          order: 2
          predicates:
            - Path=/qq
          filters:
            - AddResponseHeader=hello, Gateway

```

测试
请求[http://127.0.0.1/baidu](https://links.jianshu.com/go?to=http%3A%2F%2F127.0.0.1%2Fbaidu)跳转到[baidu.com](https://links.jianshu.com/go?to=http%3A%2F%2Fbaidu.com)
使用命令请求得到增加的返回头

![img](http://upload-images.jianshu.io/upload_images/17766088-96a3c5d4d2b1fd0b.png?imageMogr2/auto-orient/strip|imageView2/2/w/418/format/webp)