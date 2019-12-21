# SpringCloud之网关服务Zuul

### 前言

网关服务在SpringCloud中有很重要的作用。
![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/9a4f87a1fd272813b131313302b8fb08.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)

可以将服务跟外网进行隔离起到一定的保护作用，同时服务间局域网通信更加快捷。而且在网关中可以做限流、权限校验，使得服务更加专注自身业务。比如说下订单需要登录权限，限流，我们在本篇将介绍如何使用。

### 搭建网关项目

![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/02464b8aac28a99638eace2f2a62cdc8.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)
注意：需要添加Eureka Discovery，Zuul路由组件。

1.入口添加@EnableZuulProxy注解

![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/743b7f3d9c8b85eaf0bef7999c824217.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)
2.配置文件

```
server:
  port: 9000

#指定注册中心地址
eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/

#服务的名称
spring:
  application:
    name: api-gateway

#自定义路由映射
zuul:
  routes:
    order-service: /apigateway/order/**
    product-service: /apigateway/product/**
  #统一入口为上面的配置，其他入口忽略
  ignored-patterns: /*-service/**
  #处理http请求头为空的问题
  sensitive-headers:
```

我们启动EurekaServer、productService、OrderService、apigateway，通过访问：
![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/dd1a2bd03ac55958901e635a16c27507.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)
![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/cb1949f8e420e4a6af6ca1543aa67043.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)
统一对外只允许apigateway/product/，apigateway/order/形式访问接口，这样就对外做了一次屏蔽，隐藏了真实的服务api。

### 网关上做权限校验

权限校验需要通过实现ZuulFilter进行拦截。

```
package com.ckmike.api_gateway.filter;

import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import org.apache.commons.lang.StringUtils;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

/**
 * LoginFilter 简要描述
 * <p> TODO:描述该类职责 </p>
 *
 * @author ckmike
 * @version 1.0
 * @date 18-11-24 下午3:53
 * @copyright ckmike
 **/
@Component
public class LoginFilter extends ZuulFilter {

    public static final String PRE_TYPE = "pre";

    // 前置过滤器
    @Override
    public String filterType() {
        return PRE_TYPE;
    }

    // 过滤顺序
    @Override
    public int filterOrder() {
        return 4;
    }

    @Override
    public boolean shouldFilter() {

        RequestContext requestContext = RequestContext.getCurrentContext();
        HttpServletRequest request = requestContext.getRequest();

        System.out.println("address:" + request.getRemoteAddr());
        System.out.println("uri:" + request.getRequestURI());
        System.out.println("url:" + request.getRequestURL());
        // 这里可以结合ACL进行本地化或者放入到redis
        if ("/apigateway/order/api/v1/order/saveforribbon".equalsIgnoreCase(request.getRequestURI())) {
            return true;
        }
        return false;
    }

    @Override
    public Object run() throws ZuulException {
        RequestContext requestContext = RequestContext.getCurrentContext();
        HttpServletRequest request = requestContext.getRequest();
        String token = request.getHeader("token");
        if (StringUtils.isBlank(token)) {
            token = request.getParameter("token");
        }
        if (StringUtils.isBlank(token)) {
            requestContext.setSendZuulResponse(false);
            requestContext.setResponseStatusCode(HttpStatus.UNAUTHORIZED.value());
        }
        return null;
    }
}

```

启动之后访问对应的接口
![SpringCloud之网关服务(gateway)](https://s1.51cto.com/images/blog/201811/25/15519781f66ac060e2416183677cebd3.png?x-oss-process=image/watermark,size_16,text_QDUxQ1RP5Y2a5a6i,color_FFFFFF,t_100,g_se,x_10,y_10,shadow_90,type_ZmFuZ3poZW5naGVpdGk=)
到此说明我们以及做好网关的权限校验，通常我们都会结合redis+ACL方式进行，但这里因为简单我直接通过字符串进行校验，有兴趣可自行扩展redis+ACl做。

### 网关限流

通常系统都有一个承受极限，我们通常可以nginx做一限流，我们也可以通过网关进行限流，网关限流是通过每秒生成令牌作为访问通行标识，这里使用了guava做令牌生成。代码如下：

```
package com.ckmike.api_gateway.filter;

import com.google.common.util.concurrent.RateLimiter;
import com.netflix.zuul.ZuulFilter;
import com.netflix.zuul.context.RequestContext;
import com.netflix.zuul.exception.ZuulException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;

/**
 * OrderRateLimiteFilter 简要描述
 * <p> TODO:描述该类职责 </p>
 *
 * @author ckmike
 * @version 1.0
 * @date 18-11-24 下午5:33
 * @copyright ckmike
 **/
@Component
public class OrderRateLimiteFilter extends ZuulFilter {

    public static final String PRE_TYPE = "pre";
    //每秒钟产生1000个令牌，guava
    private static final RateLimiter rateLimiter = RateLimiter.create(1000);

    @Override
    public String filterType() {
        return PRE_TYPE;
    }

    @Override
    public int filterOrder() {
        return -4;
    }

    @Override
    public boolean shouldFilter() {

        RequestContext requestContext = RequestContext.getCurrentContext();
        HttpServletRequest request = requestContext.getRequest();
        if ("/apigateway/order/api/v1/order/saveforribbon".equalsIgnoreCase(request.getRequestURI())) {
            return true;
        }
        return false;
    }

    @Override
    public Object run() throws ZuulException {
        RequestContext requestContext = RequestContext.getCurrentContext();
        if (!rateLimiter.tryAcquire()) {
            requestContext.setSendZuulResponse(false);
            requestContext.setResponseStatusCode(HttpStatus.TOO_MANY_REQUESTS.value());
        }
        return null;
    }
}

```

我们可以通过jmeter进行压力测试，对/apigateway/order/api/v1/order/saveforribbon接口进行压力测试，这样我们就可以很好的测试上面的内容。