# SpringCloud容错保护Hystrix（二）



# 请求合并

上一篇写到可以使用请求缓存来减轻高并发时的请求线程消耗、降低请求相应时间。请求合并又是什么东西呢？在微服务架构中，我们将项目拆分成多个模块，每个模块间通过远程调用进行通信。远程调用最常见的问题是通信消耗与连接数占用。在高并发情况下。随着通信次数的增加，通信时间会增加；因为依赖服务的线程池资源有限，将出现排队等待与响应延迟的情况。请求合并正是Hystrix为解决这两个问题而开发的，以减少通信消耗和线程数的占用。<!--more-->

> Hystrix提供HystrixCollapser来实现请求转发，在HystrixCommand之前放置一个合并处理器，将处于一个很短的时间窗（默认为10毫秒）内对同一个依赖服务的多个请求进行整合并以批量方式发起请求，
> ![img](https://segmentfault.com/img/remote/1460000012845115?w=1123&h=88)
> HystrixCollapser是一个抽象类，进入源码可以看到，它指定了三个不同的类。

- BatchReturnType: 合并后批量请求的返回类型；
- ResponseType: 单个请求返回的类型；
- RequestArgumentType: 请求参数类型。

对于这三个类型的使用：

```
    //用来定义获取请求参数的方法
    public abstract RequestArgumentType getRequestArgument();

    //合并请求产生批量命令的具体实现
    protected abstract HystrixCommand<BatchReturnType> createCommand(Collection<com.netflix.hystrix.HystrixCollapser.CollapsedRequest<ResponseType, RequestArgumentType>> requests);
    
    //批量命令结果返回后的处理，这里需要实现将批量命令结果拆分并传递给合并前各个原子请求命令的逻辑
    protected abstract void mapResponseToRequests(BatchReturnType batchResponse, Collection<com.netflix.hystrix.HystrixCollapser.CollapsedRequest<ResponseType, RequestArgumentType>> requests);
```

## 继承方式

**修改服务提供者**
在之前的代码基础上，在USER-SERVICE中添加一个接口，这里使用到的两个接口：

- /user/{id}：根据id查询用户
- /users/ids?ids={ids}：查询多个用户，这里id以逗号隔开。

```
@GetMapping("/user/{id}")
public User findById(@PathVariable("id") Long id){
    return userRepository.findOne(id);
}

@GetMapping("/users/ids")
public List<User> findUserByIds(String ids){
     System.out.println(">>>>>>>>>>"+ids);
    String[] split = ids.split(",");
    List<User> result = new ArrayList<>();
    for (String s : split){
        Long id = Long.valueOf(s);
        User  user = userRepository.findOne(id);
        result.add(user);
    }
    return result;
}
```

**服务消费者**

1. 这里我是通过ArticleService调用USER-SERVICE服务，在ArticleService中添加方法

```
public User getUserById(@CacheKey("id") Long id) {
    return restTemplate.getForObject("http://USER-SERVICE/user/{1}", User.class, id);
}
public List<User> findUserByIds(List<Long> ids){
    System.out.println("findUserByIds---------"+ids+"Thread.currentThread().getName():" + Thread.currentThread().getName());
    String str = StringUtils.join(ids,",");
    User[] users =  restTemplate.getForObject("http://USER-SERVICE/users/ids?ids={1}", User[].class,str);
    return Arrays.asList(users);
}
```

1. 实现一个批量请求命令

```
public class UserBatchCommand extends HystrixCommand<List<User>> {
    private final Logger logger =  LoggerFactory.getLogger(UserCommand.class);
    private List<Long> ids;
    private ArticleService articleService;

    public UserBatchCommand(ArticleService articleService,List<Long> ids){
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("userGroup")));
        this.ids = ids;
        this.articleService = articleService;
    }
    @Override
    protected List<User> run() throws Exception {
        return articleService.findUserByIds(ids);
    }
}
```

1. 通过继承HystrixCollapser实现请求合并器

```
public class UserCollapdeCommand extends HystrixCollapser<List<User>,User,Long> {
    private ArticleService articleService;
    private Long id;

    public UserCollapdeCommand(ArticleService articleService,Long id){
        //设置时间延迟属性，延迟时间窗为100毫秒
        super(Setter.withCollapserKey(HystrixCollapserKey.Factory.asKey("userCollapdeCommand")).andCollapserPropertiesDefaults(
                HystrixCollapserProperties.Setter().withTimerDelayInMilliseconds(100)
        ));
        this.articleService = articleService;
        this.id = id;
    }

    /**
     * 返回单个请求参数id
     * @return
     */
    @Override
    public Long getRequestArgument() {
        return id;
    }

    /**
     * 这里通过获取单个请求的参数来组织批量请求命令UserBatchCommand的实例
     * @param collapsedRequests 保存了延迟时间窗中收集到的所有获取单个User的请求。
     * @return
     */
    @Override
    protected HystrixCommand<List<User>> createCommand(Collection<CollapsedRequest<User, Long>> collapsedRequests) {
        ArrayList<Long> userIds = new ArrayList<>(collapsedRequests.size());
        userIds.addAll(collapsedRequests.stream().map(CollapsedRequest::getArgument).collect(Collectors.toList()));
        return new UserBatchCommand(articleService,userIds);
    }

    /**
     * 该方法在批量请求命令UserBatchCommand执行完成之后执行
     * 通过遍历batchResponse来为collapsedRequests设置请求结果。
     * @param batchResponse 保存了createCommand中组织的批量请求返回结果
     * @param collapsedRequests 每个被合并的请求，
     */
    @Override
    protected void mapResponseToRequests(List<User> batchResponse, Collection<CollapsedRequest<User, Long>> collapsedRequests) {
        int count = 0;
        for (CollapsedRequest<User,Long> collapsedRequest : collapsedRequests){
            User user = batchResponse.get(count++);
            collapsedRequest.setResponse(user);
        }
    }
}

```

1. 测试接口，因为要将请求合并是合并100毫秒时间窗的请求，所以这里使用异步请求的方式。

```
@GetMapping("/testBathCommand")
public List<User> testBathCommand() throws ExecutionException, InterruptedException {
    HystrixRequestContext context = HystrixRequestContext.initializeContext();
    UserCollapdeCommand u1 = new UserCollapdeCommand(articleService, 1L);
    UserCollapdeCommand u2 = new UserCollapdeCommand(articleService, 2L);
    UserCollapdeCommand u3 = new UserCollapdeCommand(articleService, 3L);
    UserCollapdeCommand u4 = new UserCollapdeCommand(articleService, 4L);
    Future<User> q1 = u1.queue();
    Future<User> q2 = u2.queue();
    Future<User> q3 = u3.queue();
    Future<User> q4 = u4.queue();
    User e1 = q1.get();
    User e2 = q2.get();
    User e3 = q3.get();
    User e4 = q4.get();
    List<User> res = new ArrayList<>();
    res.add(e1);
    res.add(e2);
    res.add(e3);
    res.add(e4);
    System.out.println(res);
    return res;
}
```

![img](https://segmentfault.com/img/remote/1460000012845116?w=960&h=116)
![img](https://segmentfault.com/img/remote/1460000012845117?w=1094&h=281)

## 注解方式

上面使用继承类的方式可能会有些繁琐，在Hystrix中同样提供了注解来优雅的实现请求合并。

```
    @HystrixCollapser(batchMethod = "findAll",collapserProperties = {
            @HystrixProperty(name = "DelayInMilliseconds",value = "100")
    })
    public User findOne(Long id){
        return null;
    }
    @HystrixCommand
    public List<User> findAll(List<Long> ids){
        System.out.println("findUserByIds---------"+ids+"Thread.currentThread().getName():" + Thread.currentThread().getName());
        String str = StringUtils.join(ids,",");
        User[] users =  restTemplate.getForObject("http://USER-SERVICE/users/ids?ids={1}", User[].class,str);
        return Arrays.asList(users);
    }
```

这里通过@HystrixCollapser注解创建合并请求器，通过batchMethod属性指定实现批量请求的findAll方法，通过HystrixProperty属性为合并请求器设置相关属性。 `@HystrixProperty(name = "DelayInMilliseconds",value = "100")`设置时间窗为100毫秒。这里直接调用findOne方法即可，使用注解确实是简单。
测试接口

```
  @GetMapping("/testBathCommandAnn")
    public List<User> testBathCommandAnn() throws ExecutionException, InterruptedException {
        HystrixRequestContext context = HystrixRequestContext.initializeContext();
        Future<User> q1 = articleService.findOne(1L);
        Future<User> q2 = articleService.findOne(2L);
        Future<User> q3 = articleService.findOne(3L);
        Future<User> q4 = articleService.findOne(4L);
        User e1 = q1.get();
        User e2 = q2.get();
        User e3 = q3.get();
        User e4 = q4.get();
        List<User> res = new ArrayList<>();
        res.add(e1);
        res.add(e2);
        res.add(e3);
        res.add(e4);
        System.out.println(res);
        return res;
    }
```

# Hystrix属性

Hystrix提供了非常灵活的配置方式，所有属性存在下面四个优先级的配置（优先级由低到高）：

- 全局默认配置：如果没有下面三个级别的属性，那么该属性就是默认的；
- 全局配置属性：通过配置文件中定义；
- 实例默认值：通过代码为实例定义默认值；
- 实例配置属性：通过配置文件来指定的实例进行属性配置。

Hystrix中主要的三个属性：

- Command属性：主要用来控制HystrixCommand命令行为；
- Collapser属性：主要用来控制命令合并相关的行为；
- ThreadPool属性：用来控制Hystrix命令所属线程池的配置。

关于属性参数的更多详解可以查看《SpringCloud微服务实战》

# Hystrix仪表盘

## 单机监控

仪表盘是Hystrix Dashboard提供的用来实时监控Hystrix的指标信息的组件。通过该组件反馈的实时信息，可以帮助我们快速的发现系统存在的问题。项目结构图
![img](https://segmentfault.com/img/remote/1460000012845118?w=770&h=311)

1. 创建一个名为hystrix-dashborad的SpringBoot项目，然后修改pom文件，添加一下依赖：

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix-dashboard</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

1. 然后再主类上使用注解`@EnableHystrixDashboard`开启HystrixDashboard功能。
2. 修改配置文件：

```
spring:
  application:
    name: hystrix-dashboard
server:
  port: 9999
```

1. 启动项目，这里的监控方式是根据指定的url开启。前两个是对集群的监控，需要整合Turbin才能实现
   ![img](https://segmentfault.com/img/remote/1460000012845119?w=1046&h=543)
2. 修改需要监控的服务实例，这里监控ARTICLE-SERVICE。添加`spring-boot-starter-actuator`监控模块的以开启监控相关的端点。还有hystrix依赖是一定要的。并且确保服务以及使用`@EnableCircuitBreaker`开启了断路器功能。

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

1. 重启服务实例

![img](https://segmentfault.com/img/remote/1460000012845120?w=1272&h=133)

1. 将需要监控的服务地址输入上面的输入框，这里是：[http://localhost](http://localhost/):30000/hystrix.stream。然后点击Monitor Stream按钮。说明：这里要访问/hystrix.stream，需要先访问被监控服务的任意其他接口，否则将不会无法获取到相应的数据。

![img](https://segmentfault.com/img/remote/1460000012845121?w=908&h=440)

## 集群监控

可以使用Turbine实现集群监控，该端点为/trubine.stream。和上面一样，新建一个SpringBoot项目，这里命名为hystrix-turbine。添加以下依赖：

```
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-turbine</artifactId>
        </dependency>

    </dependencies>
```

在主类使用`@EnableTurbine`注解开启Trubine

```
@SpringBootApplication
@EnableDiscoveryClient
@EnableTurbine
public class TurbineApplication {

    public static void main(String[] args) {
        SpringApplication.run(TurbineApplication.class, args);
    }
}
```

修改配置文件

```
spring.application.name=hystrix-turbine
server.port=9998
management.port=9000
eureka.client.service-url.defaultZone=http://localhost:8888/eureka/
turbine.app-config=article-service
turbine.cluster-name-expression="default"
turbine.combine-host-port=true
```

> 1. turbine.app-config=ribbon-consumer指定了要监控的应用名字为ribbon-consumer
> 2. turbine.cluster-name-expression=”default”,表示集群的名字为default
> 3. turbine.combine-host-port=true表示同一主机上的服务通过host和port的组合来进行区分，默认情况下是使用host来区分，这样会使本地调试有问题

最后启动项目，并启动两个article-service，然后添加对 [http://localhost](http://localhost/):9998/turbine.stream的监控。
![img](https://segmentfault.com/img/remote/1460000012845122?w=678&h=391)

