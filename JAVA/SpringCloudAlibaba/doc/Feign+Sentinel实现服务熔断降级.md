# Feign+Sentinel实现服务熔断降级

# Sentine

## 1.背景

Sentinel 是阿里中间件团队开源的，面向分布式服务架构的轻量级高可用流量控制组件，主要以流量为切入点，从流量控制、熔断降级、系统负载保护等多个维度来帮助用户保护服务的稳定性。这里大家可能会问：Sentinel 和之前常用的熔断降级库 Netflix Hystrix 有什么异同呢？Sentinel官网有一个对比和Hystrix迁移到sentinel的文章，这里摘抄一个总结的表格，具体的对比可以点此 [链接 ](https://github.com/alibaba/Sentinel/wiki/Guideline:-%E4%BB%8E-Hystrix-%E8%BF%81%E7%A7%BB%E5%88%B0-Sentinel)查看。 

```
功能对比
```

![img](https://img2018.cnblogs.com/i-beta/1368530/201911/1368530-20191108140950345-206637597.png)

 从对比的表格可以明显看到，Sentinel比Hystrix在功能性上还要强大一些。

## 2.功能

 Sentinel 功能主要体现在三个方面

### 2.1 流量控制

​    对于系统来说，任意时间到来的请求往往是随机不可控的，而系统的处理能力是有限的。我们需要根据系统的处理能力对流量进行控制。 

控制角度如下：

- 资源的调用关系，例如资源的调用链路，资源和资源之间的关系
- 运行指标，例如 QPS、线程池、系统负载等
- 控制的效果，例如直接限流、冷启动、排队等

### 2.2 熔断降级

​        当检测到调用链路中某个资源出现不稳定的表现，例如请求响应时间长或异常比例升高的时候，则对这个资源的调用进行限制，让请求快速失败，避免影响到其它的资源而导致级联故障。手段如下

- 通过并发线程数进行限制 ：当线程数在特定资源上堆积到一定的数量之后，对该资源的新请求就会被拒绝。堆积的线程完成任务后才开始继续接收请求。
- 通过响应时间对资源进行降级：当依赖的资源出现响应时间过长后，所有对该资源的访问都会被直接拒绝，直到过了指定的时间窗口之后才重新恢复。

### 2.3 系统负载保护  

​          Sentinel 同时提供系统维度的自适应保护能力。防止雪崩，是系统防护中重要的一环。当系统负载较高的时候，如果还持续让请求进入，可能会导致系统崩溃，无法响应。在集群环境下，网络负载均衡会把本应这台机器承载的流量转发到其它的机器上去。如果 这个时候其它的机器也处在一个边缘状态的时候，这个增加的流量就会导致这台机器也崩溃，最后导致整个集群不可用。

​          针对这个情况，Sentinel 提供了对应的保护机制，让系统的入口流量和系统的负载达到一个平衡，保证系统在能力范围之内处理最多的请求。

## 3.使用

### 3.1 依赖

​    这里我使用sentinel 是基于gradle配置，兼容spring clould alibaba，所以添加如下依赖

### **3.2 注解**

​      Sentinel 提供了 @SentinelResource 注解用于定义资源，并提供了 AspectJ 的扩展用于自动定义资源、处理 BlockException等，当然也支持使用aop的方式，这里演示使用aop的方式，添加如下配置类



```
@Configuration
public class SentinelAspectConfiguration {
    @Bean
    public SentinelResourceAspect sentinelResourceAspect() {
        return new SentinelResourceAspect();
   }
}
```



** @SentinelResource** 用于定义资源，并提供可选的异常处理和 fallback 配置项 。@SentinelResource 注解包含以下属性

- value：资源名称，必需项（不能为空）
- entryType：entry 类型，可选项EntryType.OUT/EntryType.IN（默认为 EntryType.OUT）,对应入口控制/出口控制
- blockHandler / blockHandlerClass: blockHandler 对应处理 BlockException 的函数名称。
- fallback：fallback 函数名称，可选项，用于在抛出异常的时候提供 fallback 处理逻辑。fallback 函数可以针对所有类型的异常（除了 exceptionsToIgnore 里面排除掉的异常类型）进行处理
  - 返回值类型必须与原函数返回值类型一致
  - fllback 函数默认需要和原方法在同一个类中。若希望使用其他类的函数，则可以指定 fallbackClass 为对应的类的 Class 对象，注意对应的函数必需为 static 函数，否则无法解析。
- defaultFallback（since 1.6.0）：默认的 fallback 函数名称，可选项，通常用于通用的 fallback 逻辑（即可以用于很多服务或方法）。默认 fallback 函数可以针对所有类型的异常（除了 exceptionsToIgnore 里面排除掉的异常类型）进行处理。若同时配置了 fallback 和 defaultFallback，则只有 fallback 会生效。函数签名和fallback一致
- exceptionsToIgnore（since 1.6.0）：用于指定哪些异常被排除掉，不会计入异常统计中，也不会进入 fallback 逻辑中，而是会原样抛出。

### **3.3 示例  **

服务具体实现类



```
@Service
@Slf4j
public class HelloProviderServiceImpl implements HelloProviderService {

  @Autowired
  private ConfigurableEnvironment configurableEnvironment;

  // 对应的 `handleException` 函数需要位于 `ExceptionUtil` 类中，并且必须为 static 函数
  @Override
  @SentinelResource(value = "test", blockHandler = "handleException", blockHandlerClass = {
      ExceptionUtil.class})
  public void test() {
    log.info("Test");
  }

  @Override
  @SentinelResource(value = "sayHi", blockHandler = "exceptionHandler", fallback = "helloFallback")
  public String sayHi(long time) {
    if (time < 0) {
      throw new IllegalArgumentException("invalid arg");
    }
    try {
      Thread.sleep(time);
    } catch (InterruptedException e) {
      throw new IllegalArgumentException("inter arg");
    }
    return String.format("Hello time %d", time);
  }

  // 这里俗称资源埋点，在设置限流策略的时候会根据此埋点来控制
  @Override
  @SentinelResource(value = "helloAnother", defaultFallback = "defaultFallback",
      exceptionsToIgnore = {IllegalStateException.class})
  public String helloAnother(String name) {
    if (name == null || "bad".equals(name)) {
      throw new IllegalArgumentException("oops");
    }
    if ("foo".equals(name)) {
      throw new IllegalStateException("oops");
    }
    return "Hello, " + name;
  }

  // Fallback 函数，函数签名与原函数一致或加一个 Throwable 类型的参数.
  public String helloFallback(long s, Throwable ex) {
    log.error("fallbackHandler：" + s);
    return "Oops fallbackHandler, error occurred at " + s;
  }

  //默认的 fallback 函数名称
  public String defaultFallback() {
    log.info("Go to default fallback");
    return "default_fallback";
  }

  // Block 异常处理函数，参数最后多一个 BlockException，其余与原函数一致.
  public String exceptionHandler(long s, BlockException ex) {
    // Do some log here.
    return "Oops,exceptionHandler, error occurred at " + s;
  }
}
```



服务接口

```
public interface HelloProviderService {
    public String sayHi(long t) throws InterruptedException;
    String helloAnother(String name);
    void test();
}
```

```
ExceptionUtil类
```



```
@Slf4j
public final class ExceptionUtil {
  public static void handleException(BlockException ex) {
     log.info("Oops: " + ex.getClass().getCanonicalName());
  }
}
```



controller 类



```
@RestController
@Slf4j
public class HelloProviderController {

  @Autowired
  HelloProviderServiceImpl helloServiceProviderService;

  @GetMapping("/sayHi")
  public String sayHi(@RequestParam(required = false) Long time) throws Exception {
    if (time == null) {
      time = 300L;
    }
    helloServiceProviderService.test();
    
  return helloServiceProviderService.sayHi(time);
  }

  @GetMapping("baz/{name}")
  public String apiBaz(@PathVariable("name") String name) {
    return helloServiceProviderService.helloAnother(name);
  }
}
```



### 3.4 Sentinel 控制台

一个轻量级的开源控制台，它提供机器发现以及健康情况管理、监控（单机和集群），规则管理和推送的功能。主要可以通过该控制台对服务端设置的资源埋点进行动态的限流配置推送，这样可以灵活的设置限流策略而不用在代码里写死

- 提供web界面,可视化资源和流量监控、对资源埋点进行配置


- 具体安装比较简单，所以这里不再提及，可以参考[链接](https://github.com/alibaba/Sentinel/wiki/%E6%8E%A7%E5%88%B6%E5%8F%B0)[ ](https://github.com/alibaba/Sentinel/wiki/%E6%8E%A7%E5%88%B6%E5%8F%B0)

### 3.5 降级策略

- 平均响应时间 (DEGRADE_GRADE_RT)：当 1s 内持续进入 5 个请求，对应时刻的平均响应时间（秒级）均超过阈值（count，以 ms 为单位），那么在接下的时间窗口（DegradeRule 中的 timeWindow，以 s 为单位）之内，对这个方法的调用都会自动地熔断（抛出 DegradeException）。注意 Sentinel 默认统计的 RT 上限是 4900 ms，超出此阈值的都会算作 4900 ms，若需要变更此上限可以通过启动配置项 -Dcsp.sentinel.statistic.max.rt=xxx 来配置。
- 异常比例 (DEGRADE_GRADE_EXCEPTION_RATIO)：当资源的每秒请求量 >= 5，并且每秒异常总数占通过量的比值超过阈值（DegradeRule 中的 count）之后，资源进入降级状态，即在接下的时间窗口（DegradeRule 中的 timeWindow，以 s 为单位）之内，对这个方法的调用都会自动地返回。异常比率的阈值范围是 [0.0, 1.0]，代表 0% - 100%。
- 异常数 (DEGRADE_GRADE_EXCEPTION_COUNT)：当资源近 1 分钟的异常数目超过阈值之后会进行熔断。注意由于统计时间窗口是分钟级别的，若 timeWindow 小于 60s，则结束熔断状态后仍可能再进入熔断状态。
- 可以启用Sentinel 控制台，在控制台上直接配置熔断降级规则。
  - 打开控制台界面，点击簇点链路,选择程序里的资源埋点，点击降级
  - 配置降级规则![img](https://img2018.cnblogs.com/i-beta/1368530/201911/1368530-20191108145810019-1727318509.png)


- - 配置RT模式测试,控制台输入RT和窗口时间
    - url：ip:port/sayHi?time=delayTime, 当 1s 内持续进入 5 个请求 平均delayTime>RT 进入降级服务
  - 配置异常比例，控制台输入异常比例
    - url：ip:port/baz/bad, 当资源的每秒请求量 >= 5，并且每秒异常总数占通过量的比值设定的异常比例 将在接下来设置的窗口时间内进入降级服务

# Feign+Sentine

##   1. 背景 

```
    Feign是Netflix公司开源的轻量级的一种负载均衡的HTTP客户端,，使用Feign调用API就像调用本地方法一样，从避免了 调用目标微服务时，需要不断的解析/封装json 数据的繁琐。 Spring Cloud引入Feign并且集成了Ribbon实现客户端负载均衡调用。 通俗一点讲：可以像调用本地方法一样的调用远程服务的方法。
当然其中也有不少坑等踩。

```

##    2.使用

 Sentinel 适配了 Fegin组件。如果想使用，除了引入 `spring-cloud-starter-alibaba-sentinel` 的依赖外还需要 2 个步骤：

- 配置文件打开 Sentinel 对 Feign 的支持：`feign.sentinel.enabled=true`

- 加入 

  ```
  openfeign starter
  ```

   依赖使 

  ```
  sentinel starter
  ```

   中的自动化配置类生效：

  ​

  ```
        <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-starter-alibaba-sentinel</artifactId>
          </dependency>
          <dependency>
              <groupId>org.springframework.cloud</groupId>
              <artifactId>spring-cloud-starter-openfeign</artifactId>
          </dependency>
  ```

### 2.1示例

​    添加接口 EchoService类，该接口通过@FeignClient(name = "service-provider")注解来绑定该接口对应service01服务



```
@FeignClient(name = "nacos-provider-sentianel1", fallback = EchoServiceFallback.class, configuration = FeignConfiguration.class)
public interface EchoService {

  @GetMapping(value = "/sayHi")
  String sayHi(@RequestParam(value = "time", required = false) Long time);

  @RequestMapping("/api/{name}")
  String apiBaz(@PathVariable("name") String name);
}
```



​    其中 @FeignClient 中name 中的值作为 提供服务提供方的名称，该接口中配置当前服务需要调用nacos-provider-sentianel1服务提供的接口。nacos-provider-sentianel1注册到注册服务上，我这里使用的是Nacos.

   服务配置如下

![img](https://img2018.cnblogs.com/i-beta/1368530/201911/1368530-20191108180513108-1572653730.png)

  nacos-provider-sentianel1 中的controller是这个样子的，这里可以看到 和**EchoService中的方法签名都是一致的**



```
@RestController
public class HelloProviderController2 {

  @GetMapping("/echo")
  public String helloConsumer(@RequestParam(required = false) Long time) {
    return "echo";
  }

  @GetMapping("/api/{name}")
  public String apiBaz(@PathVariable("name") String name) {
    return "another provider " + name;
  }
}
```



添加 EchoServiceFallback，这里是fegin的Fallback机制，主要用来做容错处理。因为在网络请求时，可能会出现异常请求，如果还想再异常情况下使系统可用，那么就需要容错处理。`



```
@Component。
public class EchoServiceFallback implements EchoService {

  @Override
  public String sayHi(Long time) {
    return "sayHi fallback";
  }

  @Override
  public String apiBaz(String name) {
    return "apiBaz fallback";
  }
}
```



添加FeignConfiguration 

```
@Configuration
public class FeignConfiguration {
  @Bean
  public EchoServiceFallback echoServiceFallback() {
    return new EchoServiceFallback();
  }
}
```



  在上文HelloProviderServiceImpl的基础上添加EchoService调用



```
@Service
@Slf4j
public class HelloProviderServiceImpl implements HelloProviderService {

  @Autowired
  private ConfigurableEnvironment configurableEnvironment;

  @Autowired
  EchoService echoService;

  // 对应的 `handleException` 函数需要位于 `ExceptionUtil` 类中，并且必须为 static 函数
  @Override
  @SentinelResource(value = "test", blockHandler = "handleException", blockHandlerClass = {
      ExceptionUtil.class})
  public void test() {
    log.info("Test");
  }

  @Override
  @SentinelResource(value = "sayHi", blockHandler = "exceptionHandler", fallback = "helloFallback")
  public String sayHi(long time) {
    if (time < 0) {
      throw new IllegalArgumentException("invalid arg");
    }
    try {
      Thread.sleep(time);
    } catch (InterruptedException e) {
      throw new IllegalArgumentException("inter arg");
    }
    return String.format("Hello time %d", time);
  }

  @Override
  @SentinelResource(value = "helloAnother", defaultFallback = "defaultFallback",
      exceptionsToIgnore = {IllegalStateException.class})
  public String helloAnother(String name) {
    if (name == null || "bad".equals(name)) {
      throw new IllegalArgumentException("oops");
    }
    if ("foo".equals(name)) {
      throw new IllegalStateException("oops");
    }
    return "Hello, " + name;
  }

  // Fallback 函数，函数签名与原函数一致或加一个 Throwable 类型的参数.
  public String helloFallback(long s, Throwable ex) {
    log.error("fallbackHandler：" + s);

    return "Oops fallbackHandler, error occurred at " + s;
  }

  //默认的 fallback 函数名称
  public String defaultFallback() {
    log.info("Go to default fallback");
    return echoService.apiBaz("bad");
    //return "default_fallback";
  }

  // Block 异常处理函数，参数最后多一个 BlockException，其余与原函数一致.
  public String exceptionHandler(long s, BlockException ex) {
    // Do some log here.
    return "Oops,exceptionHandler, error occurred at " + s;
  }
}
```



  这里我们在defaultFallback中使用 echoService.apiBaz("bad") 来调用nacos-provider-sentianel1 的apiBaz方法

  在sentinel控制台中配置helloAnother的降级规则，当触发降级后，将会调用acos-provider-sentianel1服务的apiBaz方法，返回结果。

# 总结

​      使用sentinel控制系统流量，当系统流超出当前服务的接受范围的时候，可以通过Feign 调用降级服务，这样就可构成一个最基础的熔断降级模块，当然Feign中还集成了`Ribbon,可以通过配置实现客户端负载均衡调用。`