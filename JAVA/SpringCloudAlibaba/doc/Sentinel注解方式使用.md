# Sentinel注解方式使用

### Sentinel 注解支持

@SentinelResource 用于定义资源，并提供可选的异常处理和 fallback 配置项。 @SentinelResource 注解包含以下属性：

- value：资源名称，必需项（不能为空）
- entryType：entry 类型，可选项（默认为 EntryType.OUT）
- blockHandler / blockHandlerClass: blockHandler 对应处理 BlockException 的函数名称，可选项。blockHandler 函数访问范围需要是 public，返回类型需要与原方法相匹配，参数类型需要和原方法相匹配并且最后加一个额外的参数，类型为 BlockException。blockHandler 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 blockHandlerClass 为对应的类的 Class 对象，注意对应的函数必需为 static 函数，否则无法解析。
- fallback：fallback 函数名称，可选项，用于在抛出异常的时候提供 fallback 处理逻辑。fallback 函数可以针对所有类型的异常（除了 - exceptionsToIgnore 里面排除掉的异常类型）进行处理。fallback 函数签名和位置要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要和原函数一致，或者可以额外多一个 Throwable 类型的参数用于接收对应的异常。
  - fallback 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 fallbackClass 为对应的类的 Class 对象，注意对应的函数必需为 static 函数，否则无法解析。
- defaultFallback（since 1.6.0）：默认的 fallback 函数名称，可选项，通常用于通用的 fallback 逻辑（即可以用于很多服务或方法）。默认 fallback 函数可以针对所有类型的异常（除了 exceptionsToIgnore 里面排除掉的异常类型）进行处理。若同时配置了 fallback 和 defaultFallback，则只有 fallback 会生效。defaultFallback 函数签名要求：
  - 返回值类型必须与原函数返回值类型一致；
  - 方法参数列表需要为空，或者可以额外多一个 Throwable 类型的参数用于接收对应的异常。
  - defaultFallback 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 fallbackClass 为对应的类的 Class 对象，注意对应的函数必需为 static 函数，否则无法解析。
- exceptionsToIgnore（since 1.6.0）：用于指定哪些异常被排除掉，不会计入异常统计中，也不会进入 fallback 逻辑中，而是会原样抛出。

注：1.6.0 之前的版本 fallback 函数只针对降级异常（DegradeException）进行处理，不能针对业务异常进行处理。

特别地，若 blockHandler 和 fallback 都进行了配置，则被限流降级而抛出 BlockException 时只会进入 blockHandler 处理逻辑。若未配置 blockHandler、fallback 和 defaultFallback，则被限流降级时会将 BlockException 直接抛出。

### 使用注意点采坑日记

@SentinelResource 注解不单单用于controller的接口流控。同时也可以用于方法上面。如果看过实现方式代码。可以知道他底层是基于cglib动态代理实现的。进行切面处理。注意点：

- 不能修饰在接口上面。只能修饰在实现类的方法上
- 不能修饰在静态的方法上面。
- 同一个bean方法A调用方法B,假设方法A和B都进行了注解。B方法注解失效,请参考@Transactional 失效。
  - @Transactional 加于private方法, 无效
  - @Transactional 加于未加入接口的public方法, 再通过普通接口方法调用, 无效
  - @Transactional 加于接口方法, 无论下面调用的是private或public方法, 都有效
  - @Transactional 加于接口方法后, 被本类普通接口方法直接调用, 无效
  - @Transactional 加于接口方法后, 被本类普通接口方法通过接口调用, 有效
  - @Transactional 加于接口方法后, 被它类的接口方法调用, 有效
  - @Transactional 加于接口方法后, 被它类的私有方法调用后, 有效

blockHandler 和 blockHandlerClass 的使用

blockHandler 是可选的。如果使用blockHandlerClass，必须搭配blockHandler使用， blockHandler指定blockHandlerClass类中对应的方法名称。方法名称、参数、返回值、static 必须按照上述文档描述一样。官方文档没有强调要必须要搭配使用。

同理 fallback 和 fallbackClass也是上面讲述的注意点。

### 改造client 服务

```
       <dependency>
            <groupId>com.alibaba.cloud</groupId>
            <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
        </dependency>
```

bootstrap.yml 配置文件

```
spring:
    cloud:
        sentinel:
                filter:
                    # sentienl 默认生效，本地调试false
                    enabled: true
                transport:
                    dashboard: localhost:8890
                    port: 8719
                # 饥饿加载
                eager: true
                datasource:
                    # Sentinel基于nacos存储获取配置信息
                    na:
                        nacos:
                            server-addr: 47.99.209.72:8848
                            groupId: DEFAULT_GROUP
                            dataId: ${spring.application.name}-${spring.profiles.active}-sentinel
                            # 类型
    #            FLOW("flow", FlowRule.class),
    #            DEGRADE("degrade", DegradeRule.class),
    #            PARAM_FLOW("param-flow", ParamFlowRule.class),
    #            SYSTEM("system", SystemRule.class),
    #            AUTHORITY("authority", AuthorityRule.class),
    #            GW_FLOW("gw-flow", "com.alibaba.csp.sentinel.adapter.gateway.common.rule.GatewayFlowRule"),
    #            GW_API_GROUP("gw-api-group", "com.alibaba.csp.sentinel.adapter.gateway.common.api.ApiDefinition");
                            rule-type: flow
```

nacos 创建 cloud-discovery-client-dev-sentinel 配置文件

```
[
    {
        "resource": "client:log:save",
        "limitApp": "default",
        "grade": 1,
        "count": 1,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    },
    {
        "resource": "client:fegin:test",
        "limitApp": "default",
        "grade": 1,
        "count": 1,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    },
     {
        "resource": "user:service:saveTx",
        "limitApp": "default",
        "grade": 1,
        "count": 1,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    },
    {
        "resource": "user:service:save:test",
        "limitApp": "default",
        "grade": 1,
        "count": 1,
        "strategy": 0,
        "controlBehavior": 0,
        "clusterMode": false
    }
]
```

创建 BackHandlerClass DiscoveryClientControllerBackHandler

```
package com.xian.cloud.common.handler;
import com.alibaba.csp.sentinel.slots.block.BlockException;
import com.xian.cloud.entity.UserEntity;
import lombok.extern.slf4j.Slf4j;
/**
 *  对应处理 BlockException 的函数名称 服务限流
 * @Author: xlr
 * @Date: Created in 9:08 PM 2019/11/16
 */
@Slf4j
public class DiscoveryClientControllerBackHandler {
    public static String defaultMessage(BlockException e){
        log.warn( "DiscoveryClientControllerBackHandler  defaultMessage BlockException : {}",e );
        return "defaultMessage 服务限流，请稍后尝试";
    }
    public static String saveTx(UserEntity entity,BlockException e) {
        log.warn( "DiscoveryClientControllerBackHandler  saveTx BlockException : {}",e );
        return "saveTx 服务限流，请稍后尝试";
    }
}
```

创建 FallBackHandlerClass

```
package com.xian.cloud.common.handler;
import com.xian.cloud.entity.UserEntity;
import lombok.extern.slf4j.Slf4j;
/**
 * 仅针对降级功能生效（DegradeException）
 * @Author: xlr
 * @Date: Created in 9:13 PM 2019/11/16
 */
@Slf4j
public class DiscoveryClientControllerFallBackHandler {
    public static String defaultMessage(Throwable t){
        log.warn( "DiscoveryClientControllerFallBackHandler defaultMessage Throwable : {}",t );
        return "defaultMessage 服务降级，请稍后尝试";
    }
    public static String saveTx(UserEntity entity,Throwable t) {
        log.warn( "DiscoveryClientControllerFallBackHandler saveTx Throwable : {}",t );
        return "saveTx 服务降级，请稍后尝试";
    }
}package com.xian.cloud.common.handler;import com.xian.cloud.entity.UserEntity;import lombok.extern.slf4j.Slf4j;/** * 仅针对降级功能生效（DegradeException） * @Author: xlr * @Date: Created in 9:13 PM 2019/11/16 */@Slf4jpublic class DiscoveryClientControllerFallBackHandler {    public static String defaultMessage(Throwable t){        log.warn( "DiscoveryClientControllerFallBackHandler defaultMessage Throwable : {}",t );        return "defaultMessage 服务降级，请稍后尝试";    }    public static String saveTx(UserEntity entity,Throwable t) {        log.warn( "DiscoveryClientControllerFallBackHandler saveTx Throwable : {}",t );        return "saveTx 服务降级，请稍后尝试";    }}
```

对外接口DiscoveryClientController 添加接口

```
@SentinelResource(
            value = "client:fegin:test",
            blockHandler = "defaultMessage",
            fallback = "defaultMessage",
            blockHandlerClass = DiscoveryClientControllerBackHandler.class,
            fallbackClass = DiscoveryClientControllerFallBackHandler.class
    )
    @RequestMapping(value = "fegin/test",method = RequestMethod.GET)
    public String feginTest() {
        String result = serverService.hello( "fegin" );
        return  " 返回 : " + result;
    }
 @GetMapping("/log/save")
    @SentinelResource(
            value = "client/log/save",
            blockHandler = "defaultMessage",
            fallback = "defaultMessage",
            blockHandlerClass = DiscoveryClientControllerBackHandler.class,
            fallbackClass = DiscoveryClientControllerFallBackHandler.class
    )
    public String save(){
        UserEntity entity = new UserEntity();
        entity.setUsername("tom");
        entity.setPassWord("1232131");
        entity.setEmail("222@qq.com");
        userService.saveTx(entity);
        return "success";
    }
    @GetMapping("user/service/save")
    public String userServiceSaveTx(){
        UserEntity entity = new UserEntity();
        String result = userService.saveTx( entity );
        return result;
    }
```

UserServiceImpl 方法

```
 @Override
    @Transactional
    @SentinelResource(
            value = "user:service:saveTx",
            blockHandler = "saveTx",
            fallback = "saveTx",
            blockHandlerClass = DiscoveryClientControllerBackHandler.class,
            fallbackClass = DiscoveryClientControllerFallBackHandler.class
    )
    public String saveTx(UserEntity entity) {
        return "success";
    }
```

以上就配置完毕。然后进行测试在页面疯狂刷新

http://localhost:9011/client/user/service/save

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xODQ4MTg3LzIwMTkxMS8xODQ4MTg3LTIwMTkxMTE4MjMxNTU0MTU4LTExMjkxNDA0NTYucG5n.jpg)

http://localhost:9011/client/fegin/test

![img](https://bbsmax.ikafan.com/static/L3Byb3h5L2h0dHBzL2ltZzIwMTguY25ibG9ncy5jb20vYmxvZy8xODQ4MTg3LzIwMTkxMS8xODQ4MTg3LTIwMTkxMTE4MjMxNTU0NDIwLTEyODI0OTE0OC5wbmc=.jpg)

停止 server服务 再次调用 fegin、test

服务降级和服务限流来回切换提示在前端页面。blockHandlerClass、fallbackClass。