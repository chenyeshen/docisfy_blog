# SpringCloudAPI网关服务Zuul



> SpringCloud微服务就是把一个大的项目拆分成多个小的模块，然后模块之间通过远程调用、服务治理的技术互相配合工作，随着业务的增加，项目也将会越来越庞大，接口数量也随之增加，对外提供服务的接口也会增加，运维人员对于这些接口的管理也会变得越来越难。另一方面对于一个系统来说，权限管理也是一个不可少的模块，在微服务架构中，系统被拆分，不可能每个模块都去添加一个个权限管理，这样系统代码重复、工作量大、后期维护也难。为了解决这些常见的架构问题，API网关应运而生。SpringCloudZuul是基于Netflix Zuul实现的API网关组件，它实现了请求路由、负载均衡、校验过滤、与服务治理框架的结合、请求转发是的熔断机制和服务的聚合等功能。

# 快速使用

- 新建一个SpringBoot项目，这里命名api-gateway，然后导入相关依赖：

```
 <dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-zuul</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-eureka</artifactId>
</dependency>
```

- 在主类上使用`@EnableZuulProxy`注解开启API网关服务功能

```
@SpringBootApplication
@EnableZuulProxy
public class ApigatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApigatewayApplication.class, args);
    }
}

```

- 在配置文件中添加路由的规则配置

```
spring:
  application:
    name: api-gateway
server:
  port: 8500
zuul:
  routes:
    # 面向服务的路由
    api-a:
      path: /api-a/**
      serviceId: FEIGN-CONSUMER
    # 传统的路由
    api-b-url:
      path: /api-b-url/**
      url: http://localhost:30000/
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8888/eureka/
```

这里的代码是接着前面的，启动eureka-server、user-server、feign-consumer、article-server和api-gateway。我没添加了eureka的依赖，所以api-gateway也是服务提供方在注册中心注册：
![img](https://segmentfault.com/img/remote/1460000012888021?w=1279&h=196)
然后访问`http://localhost:8500/api-a/feign_consumer/find`和`http://localhost:8500/api-b-url/a/u/1`

![img](https://segmentfault.com/img/remote/1460000012888022?w=562&h=448)
在上面的配置文件文件中，使用两种路由规则的配置方法，一种是面向服务的，一种是使用传统的url。所有符合`/api-a/**`的请求都将转发到feign-consumer，同样所有符合`/api-b-url/**`的请求都将转发到`http://localhost:30000/`，也就是前面使用的article-service。两种规则的配置很明显：面向服务的使用serviceId配置服务实例，而传统的直接使用服务的地址。

# 请求过滤

前面也提到网关可以处理微服务的权限问题，在单体架构的时候我们通常会使用拦截器或过滤器对请求进行权限的校验，同样在SpringCloudZuul中也提供了过滤器来进行请求的过滤与拦截，实现方法只要我们继承抽象类`ZuulFilter`并实现它定义的4个抽象方法。下面定义个拦截器来检查HttpServletRequest中是否带有accessToken参数

- 创建`AccessFilter`

```
@Component
public class AccessFilter extends ZuulFilter{
    private static final Logger logger = LoggerFactory.getLogger(AccessFilter.class);

    @Override
    public String filterType() {
        return "pre";
    }
    @Override
    public int filterOrder() {
        return 0;
    }

    @Override
    public boolean shouldFilter() {
        return true;
    }
    @Override
    public Object run() {
        RequestContext currentContext = RequestContext.getCurrentContext();
        HttpServletRequest request = currentContext.getRequest();
        logger.info("send{} request to {}",request.getMethod(),request.getRequestURI().toCharArray());
        String accessToken = request.getParameter("accessToken");
        if(StringUtils.isBlank(accessToken)){
            logger.warn("accessToken is empty");
            currentContext.setSendZuulResponse(false);
            currentContext.setResponseStatusCode(401);
            return null;
        }
        logger.info("accessToken {}" ,accessToken);
        return null;
    }
}
```

- 然后启动相应的服务，访问相应的链接，当不添加accessToken是会抛出401错误。

> 上面说到我们需要实现抽象类的ZuulFilter的四个抽象方法；
>
> 1. filterType：过滤器类型，他决定过滤器在请求的哪个生命周期执行。在Zuul中有四种不同的生命周期过滤器：

```
- pre：可以在请求被路由之前调用；
- routing：在路由请求是调用；
- post：在routing和error过滤器之后被调用；
- error：处理请求是发生错误是被调用
```

> 1. filterOrder：过滤器的执行顺序，数值越小优先级越高
> 2. shouldFilter：判断过滤器是否需要执行
> 3. run： 过滤器的具体逻辑。上面的run方法中判断请求是否带有accessToken参数，如果没有则是非法请求，使用 `currentContext.setSendZuulResponse(false);`表示该请求不进行路由。然后设置响应码。

请求的生命周期具体详解可以参考《SpringCloud微服务实战》

# 路由的配置

## 传统路由

在上面的配置中使用了`zuul.toutes.<route>.path`和`zuul.toutes.<route>.url`参数的方式配置单实例的路由，而在微服务架构中，为了服务的高可用，一般会将一个服务部署多个。传统的多实例的路由配置，Zuul提供了以下方法：

> 通过`zuul.toutes.<route>.path`与`zuul.toutes.<route>.serviceId`配置，如下：
> `zuul.routes.feign-consumer.path=/feign/**`
> `zuul.routes.feign-consumer.serviceId=feign-consumer`
> `robbin.eureka.enable=false`
> `feign-consumer.ribbon.listOfServers=http://localhost:50000/,http://localhost:50001/`

该配置实现了对符合`/feign/**`规则的请求转发到`http://localhost:50000/,http://localhost:50001/`两个实例地址的路由规则。这里的serviceId是有程序员手动命名的服务名称。`robbin.eureka.enable=false`设置Ribbon不根据服务发现机制来获取配置服务对应的实例清单。

## 服务路由

```
zuul:
  routes:
    api-a:
      path: /api-a/**
      serviceId: feign-consumer
```

该配置实现了对符合`/api-a/**`规则的请求路径转发到名为`feign-consumer`的服务实例上去的路由规则。` api-a`是任意的路由名称。还可以使用一种更加简洁的方法`zuul.routes.<serviceId>=<path>`,这里serviceId指定具体的服务名，path配置匹配的请求表达式。

## 路径匹配规则

| 通配符  | 含义               | url       | 说明                                       |
| ---- | ---------------- | --------- | ---------------------------------------- |
| ？    | 匹配任意单个字符         | /feign/?  | 匹配/feign/之后拼接一个任意字符的路径，如/feign/a         |
| *    | 匹配任意数量的字符        | /feign/*  | 匹配/feign/之后拼接任意字符的路径，如/feign/aaa         |
| **   | 匹配任意数量的字符，支持多级目录 | /feign/** | 可以匹配/feign/*包含的内容之外，还可匹配形如/feign/a/b的多级目录 |

## 其他配置

- `zuul.ignored-services=hello-service：`忽略掉一个服务；
- `zuul.ignored-patterns=/**/feign/**:` 忽略/feign接口路由；
- `zuul.prefix：`为路由添加统一前缀；
- `zuul.add-host-header: true：`在请求路由转发前为请求设置Host头信息；
- `zuul.sensitiveHeaders=`：设置全局参数为空来覆盖默认敏感头信息
- `zuul.routes.<route>.customSensitiveHeaders=true`：对指定路由开启自定义敏感头
- `zuul.routes.<route>.sentiviteHeaders=`：将指定路由的敏感头设置为空。
- `zuul.retryable=false`：关闭重试机制
- `zuul.routes.<route>.retryable=false`：指定路由关闭重试机制
- `zuul.<SimpleClassName>.<fileterType>.disable=true`：禁用指定的过滤器，`<SimpleClassName>`代表过滤器的类名，`<fileterType>`代表过滤器的类型。

在Zuul中Hystrix和Ribbon的配置与传统的Hystrix和Ribbon服务的配置一样。

