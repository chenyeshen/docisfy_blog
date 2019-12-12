# SpringCloud容错保护Hystrix（一）



与Eureka和Ribbon一样，Hystrix也是Netfix开源的一个框架，中文名：容错保护系统。SpringCloudHystrix实现了断路器、线程隔离等一系列服务保护功能。在微服务架构中，每个单元都在不同的进程中运行，进程间通过远程调用的方式相互依赖，这样就可能因为网络的原因出现调用故障和延迟，如果调用请求不断增加，将会导致自身服务的瘫痪。为了解决这些问题，产生了断路器等一系列服务保护机制。断路器详细介绍：[断路器](https://martinfowler.com/bliki/CircuitBreaker.html)<!--more-->

# 简单使用

直接使用上一篇：[SpringCloud学习之Ribbon](http://www.wanqhblog.top/2018/01/11/springcloudribbon/)，在article-service中添加。
pom文件

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
```

在主类上添加`@EnableCircuitBreaker`或`@EnableHystrix`注解开启Hystrix的使用。

```
@SpringBootApplication
@EnableEurekaClient
@EnableCircuitBreaker
public class ArticleApplication {

    @Bean
    @LoadBalanced
    public RestTemplate restTemplate(){
        return new RestTemplate();
    }

    public static void main(String[] args) {
        SpringApplication.run(ArticleApplication.class, args);
    }
}
```

这里也可以使用`@SpringCloudApplication`注解，该注解已经包含了我们添加的三个注解，所以可以看出SpringCloud的标准应用应该包服务发现和断路器
![img](https://segmentfault.com/img/remote/1460000012845093?w=438&h=237)
然后在ArticleController添加方法，并添加`@HystrixCommand`定义服务降级，这里的`fallbackMethod`服务调用失败后调用的方法。

```
    /**
     * 使用Hystrix断路器
     * @param id
     * @return
     */
    @HystrixCommand(fallbackMethod = "fallback")
    @GetMapping("/hystrix/{id}")
    public String findUserHystrix(@PathVariable("id") Long id){
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id).toString();
    }

    private String fallback(Long id){
        return "Error:"+id;
    }

```

重启服务，如果没有出现故障，这里是可以正常访问并返回正确的数据。下面将服务接口sleep来模拟网络延迟：

```
@RestController
public class UserController {
    @Autowired
    private UserRepository userRepository;
    @GetMapping("/user/{id}")
    public User findById(@PathVariable("id") Long id) throws InterruptedException {
        Thread.sleep(5000);
        return userRepository.findOne(id);
    }
}
```

访问：[http://localhost](http://localhost/):30000/hystrix/3，这里会调用回调函数返回数据。

![img](https://segmentfault.com/img/remote/1460000012845094?w=299&h=102)

通过上面的使用，发现一个问题：使用这种方法配置服务降级的方式，回调函数的入参和返回值必须与接口函数的一直，不然会抛出异常。

# 自定义Hystrix命令

上面使用注解方式配置非常简单。在Hystrix中我们也可以通过继承`HystrixCommand`来实现自定义的`HystrixCommand`，而且还支持同步请求和异步请求两种方式。

创建UserCommand并继承HystrixCommand，实现run方法：

```
public class UserCommand extends HystrixCommand<User> {

    private final Logger logger =  LoggerFactory.getLogger(UserCommand.class);
    private RestTemplate restTemplate;
    private Long id;

    public UserCommand(Setter setter,RestTemplate restTemplate,Long id){
        super(setter);
        this.restTemplate = restTemplate;
        this.id = id;
    }

    @Override
    protected User run() throws Exception {
        logger.info(">>>>>>>>>>>>>自定义HystrixCommand请求>>>>>>>>>>>>>>>>>>>>>>>>>>");
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
    }
}
```

然后添加一个接口

```
 @GetMapping("/command/{id}")
    public User findUserCommand(@PathVariable("id") Long id) throws ExecutionException, InterruptedException {
        com.netflix.hystrix.HystrixCommand.Setter setter = com.netflix.hystrix.HystrixCommand.Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey(""));
        UserCommand userCommand = new UserCommand(setter,restTemplate,id);
        //同步调用
//        User user = userCommand.execute();
        //异步请求
        Future<User> queue = userCommand.queue();
        User user = queue.get();
        return user;
    }
```

`Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey(""))`是设置自定义命令的参数。先调用`withGroupKye`来设置分组，然后通过asKey来设置命令名；因为在Setter的定义中，只有withGroupKye静态函数可以创建Setter实例，所以GroupKey是Setter必需的参数。深入介绍可以查看源码或者看DD大佬的《SpringCloud微服务实战》。查看`@HystrixCommand`注解源码，可以看到这里也有groupKey、commandKey等参数，这也就是说使用@HystrixCommand注解时是可以配置命令名称、命令分组和线程池划分等参数的。
![img](https://segmentfault.com/img/remote/1460000012845095?w=453&h=252)

# 注解实现异步请求

上面自定义命令中可以实现异步，同样也可以直接使用注解来实现异步请求；

1. 配置`HystrixCommandAspect`的Bean

```
@Bean
public HystrixCommandAspect hystrixCommandAspect(){
    return new HystrixCommandAspect();
}
```

1. 然后使用AsyncResult来执行调用

```
      @HystrixCommand
    @GetMapping("/async/{id}")
    public Future<User> findUserAsync(@PathVariable("id") Long id){
        return new AsyncResult<User>() {
            @Override
            public User invoke() {
                return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
            }
        };
    }
```

# 异常处理

## 异常传播

查看`@HystrixCommand`注解源码可以发现里面有个`ignoreExceptions`参数。该参数是定义忽略指定的异常功能。如下代码，当方法抛出`NullPointerException`时会将异常抛出，而不触发降级服务。

```
  @HystrixCommand(fallbackMethod = "fallback",ignoreExceptions = {NullPointerException.class})
    @GetMapping("/hystrix/{id}")
    public User findUserHystrix(@PathVariable("id") Long id){
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
    }
```

## 异常获取

1. 传统的继承方式，在继承了`HystrixCommand`类中重写`getFallback()`方法，这里在run方法中添加弄出一个异常

```
@Override
protected User getFallback() {
    Throwable e = getExecutionException();
    logger.info(">>>>>>>>>>>>>>>>>>>>>{}<<<<<<<<<<<<<<<<",e.getMessage());
    return new User(-1L,"",-1);
}

@Override
protected User run() throws Exception {
    logger.info(">>>>>>>>>>>>>自定义HystrixCommand请求>>>>>>>>>>>>>>>>>>>>>>>>>>");
    int i = 1/0;
    return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
}
```

![img](https://segmentfault.com/img/remote/1460000012845096?w=1199&h=124)

1. 使用注解，在自定义的服务降级方法中可以使用Throwable 获取异常信息，

```
@HystrixCommand(fallbackMethod = "fallback")
@GetMapping("/hystrix/{id}")
public User findUserHystrix(@PathVariable("id") Long id){
    int i = 1/0;
    return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
}

private User fallback(Long id,Throwable throwable){
    LoggerFactory.getLogger(ArticleController.class).info("========{}=============",throwable.getMessage());
    return new User();
}
```

![img](https://segmentfault.com/img/remote/1460000012845097?w=1253&h=68)

# 请求缓存

在高并发的场景下，Hystrix中提供了请求缓存的功能，可以方便的开启和使用请求缓存来优化系统，达到减轻高并发时的请求线程消耗、降低请求相应时间。

## 继承方式

在继承了`HystrixCommand`类中重写`getCacheKey()`方法

```
@Override
protected String getCacheKey() {
    return String.valueOf(id);
}
public UserCommand(RestTemplate restTemplate,Long id){
    super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("userGroup")));
    this.restTemplate = restTemplate;
    this.id = id;
}

```

通过getCacheKey()方法返回请求的Key值，Hystrix会根据getCacheKey返回的值来区分是否是重复请求，如果cacheKey相同，那么该依赖服务只会在第一个请求达到时被真实的调用，另一个请求则是直接从请求缓存中返回结果。
![img](https://segmentfault.com/img/remote/1460000012845098?w=898&h=430)
修改后的接口类，该方法第一句为初始化HystrixRequestContext，如果不初始化该对象会报错。这里是在测试环境，如果在真正项目中该初始化不应该在指定方法中。

```
 @GetMapping("/command/{id}")
    public User findUserCommand(@PathVariable("id") Long id) throws ExecutionException, InterruptedException {
        HystrixRequestContext.initializeContext();
        UserCommand u1 = new UserCommand(restTemplate,id);
        UserCommand u2 = new UserCommand(restTemplate,id);
        UserCommand u3 = new UserCommand(restTemplate,id);
        UserCommand u4 = new UserCommand(restTemplate,id);
        User user1 = u1.execute();
        System.out.println("第一次请求"+user1);
        User user2 = u2.execute();
        System.out.println("第二次请求"+user2);
        User user3 = u3.execute();
        System.out.println("第三次请求"+user3);
        User user4 = u4.execute();
        System.out.println("第四次请求"+user4);
        return user1;
    }
```

## 注解方式

在SpringCloudHystrix中与缓存有关的三个注解：

- @CacheResult：用来标记其你去命令的结果应该被缓存，必须与@HystrixCommand注解结合使用；
- @CacheRemove：该注解用来让请求命令的缓存失败，失效的缓存根据定义的Key决定；
- @CacheKey：该注解用来在请求命令的参数上标记，是其作文缓存的Key值，如果没有标注则会使用所有参数。如果同时使用了@CacheResult和 @CacheRemove注解的cacheKeyMethod方法指定缓存Key生成，那么该注解将不会起作用。

**设置请求缓存**，修改ArticleService方法，

```
@Service
public class ArticleService {

    @Autowired
    private RestTemplate restTemplate;

    @HystrixCommand
    @CacheResult
    public User getUserById(Long id){
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
    }

}
```

添加接口

```
    @GetMapping("/cache/{id}")
    public User findUserCache(@PathVariable("id") Long id){
        HystrixRequestContext.initializeContext();
        User user1  = articleService.getUserById(id);
        System.out.println("第一次请求"+user1);
        User user2 = articleService.getUserById(id);
        System.out.println("第二次请求"+user2);
        User user3 = articleService.getUserById(id);
        System.out.println("第三次请求"+user3);
        User user4 =articleService.getUserById(id);
        System.out.println("第四次请求"+user4);
       return articleService.getUserById(id);
    }
```

**定义缓存的Key**

1. 使用@CacheKey，该注解除了可以指定方法参数作为缓存key之外，还可以指定方法参数对象的内不属性作为Key

```
 @HystrixCommand
    @CacheResult
    public User getUserById(@CacheKey("id") Long id){
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
    }
```

1. 使用@CacheResult和@CacheRemove的cacheKeyMethod属性指定Key，如果与上面的CacheKey注解一起使用，则CacheKey将失效

```
@HystrixCommand
    @CacheResult(cacheKeyMethod = "getCacheKey")
    public User getUserById(Long id){
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}",User.class,id);
    }

    private Long getCacheKey(Long id){
        return id;
    }

```

## 缓存清理

上面说通过继承和注解方式都可以将请求保存到缓存，但是当我们更新了数据库的数据，缓存的数据已经是过期数据，这时候再次请求，数据已经失效。所以我们需要更新缓存。在Hystrix中继承和注解都可以实现清除缓存。
**1. 使用继承方式：**前面介绍使用继承是继承HystrixCommand，然后再run方法中触发请求操作，所以这里创建两个类进程HystrixCommand，一个实现查询，一个实现更新。

```
public class GetUserCommand  extends HystrixCommand<User> {
    private static final Logger logger = LoggerFactory.getLogger(GetUserCommand.class);

    private static final HystrixCommandKey GETTER_KEY = HystrixCommandKey.Factory.asKey("CommandKey");
    private RestTemplate restTemplate;
    private Long id;

    public GetUserCommand(RestTemplate restTemplate, Long id) {
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("userGroup")));
        this.restTemplate = restTemplate;
        this.id = id;
    }
    @Override
    protected User run() throws Exception {
        logger.info(">>>>>>>>>>>>>查询操作>>>>>>>>>>>>>>>>>>>>>>>>>>");
        return restTemplate.getForObject("http://USER-SERVICE/user/{1}", User.class, id);
    }
    @Override
    protected String getCacheKey() {
        //根据id保存缓存
        return String.valueOf(id);
    }
    /**
     * 根据id清理缓存
     * @param id
     */
    public static void flushCache(Long id){
        logger.info(" >>>>>>>>>>>>>GETTER_KEY:{}>>>>>>>>>>>>>>>>",GETTER_KEY);
        HystrixRequestCache.getInstance(GETTER_KEY,
                HystrixConcurrencyStrategyDefault.getInstance()).clear(String.valueOf(id));
    }
}
```

```
public class PostUserCommand extends HystrixCommand<User> {
    private final Logger logger =  LoggerFactory.getLogger(UserCommand.class);
    private RestTemplate restTemplate;
    private User user;

    public PostUserCommand(RestTemplate restTemplate,User user){
        super(Setter.withGroupKey(HystrixCommandGroupKey.Factory.asKey("userGroup")));
        this.restTemplate = restTemplate;
        this.user = user;
    }
    @Override
    protected User run() throws Exception {
        logger.info(">>>>>>>>>>>>>更新操作>>>>>>>>>>>>>>>>>>>>>>>>>>");
        User user1 = restTemplate.postForEntity("http://USER-SERVICE/u/update", user, User.class).getBody();
        //刷新缓存，清理失效的缓存
        GetUserCommand.flushCache(user1.getId());
        return user1;
    }
}
```

添加接口：

```
 @GetMapping("/getcommand/{id}")
    public User testGetCommand(@PathVariable("id") Long id){
        GetUserCommand u1 = new GetUserCommand(restTemplate,id);
        GetUserCommand u2 = new GetUserCommand(restTemplate,id);
        GetUserCommand u3 = new GetUserCommand(restTemplate,id);
        GetUserCommand u4 = new GetUserCommand(restTemplate,id);
        User user1 = u1.execute();
        System.out.println("第一次请求"+user1);
        User user2 = u2.execute();
        System.out.println("第二次请求"+user2);
        User user3 = u3.execute();
        System.out.println("第三次请求"+user3);
        User user4 = u4.execute();
        System.out.println("第四次请求"+user4);
        return user1;
    }

    @PostMapping("/postcommand")
    public User testPostCommand(User user){
        HystrixRequestContext.initializeContext();
        PostUserCommand u1 = new PostUserCommand(restTemplate,user);
        User execute = u1.execute();
        return execute;
    }
```

在上面GetUserCommand方法中添加flushCache的静态方法，该方法通过`HystrixRequestCache.getInstance(GETTER_KEY, HystrixConcurrencyStrategyDefault.getInstance());`方法从默认的Hystrix并发策略中根据`GETTER_KEY`获取到该命令的请求缓存对象HystrixRequestCache，然后再调用clear方法清理key为id的缓存。
**2. 使用注解方式：**上面提到了`@CacheRemove`注解是使缓存失效

```
@CacheRemove(commandKey = "getUserById")
public User update(@CacheKey("id")User user){
    return  restTemplate.postForEntity("http://USER-SERVICE/u/update", user, User.class).getBody();
}
```

`@CacheRemove`的commandKey属性是必须指定的，它用来指明需要使用请求缓存的请求命令，只有通过该属性的配置，Hystrix才能找到正确的请求命令缓存位置。

使用请求缓存的时候需要注意的是，必须先使用 `HystrixRequestContext.initializeContext();`，该方法的调用可以放到拦截器中执行，这里因为是测试，所以直接在接口中调用。