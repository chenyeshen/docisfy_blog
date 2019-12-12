# SpringCloud声明式服务调用Feign

> 前面使用了Ribbon做客户端负载均衡，使用Hystrix做容错保护，这两者被作为基础工具类框架被广泛地应用在各个微服务的实现中。SpringCloudFeign是将两者做了更高层次的封装以简化开发。它基于Netfix Feign实现，整合了SpringCloudRibbon和SpringCloudHystrix，除了提供这两者的强大功能外，还提供了一种声明是的Web服务客户端定义的方式。SpringCloudFeign在NetFixFeign的基础上扩展了对SpringMVC注解的支持，在其实现下，我们只需创建一个接口并用注解的方式来配置它，即可完成对服务提供方的接口绑定。简化了SpringCloudRibbon自行封装服务调用客户端的开发量。

# 快速使用

接着之前的代码：[SpringCloud容错保护Hystrix（二）](http://www.wanqhblog.top/2018/01/15/SpringCloud%E5%AD%A6%E4%B9%A0%E4%B9%8BHystrix%EF%BC%88%E4%BA%8C%EF%BC%89/)
代码地址：[https://gitee.com/wqh3520](https://gitee.com/wqh3520/spring-cloud-1-9)
1.创建一个SpringBoot工程，这里命名为feign-consumer，然后在pom文件中添加依赖：

```
<dependencies>
    .....
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-eureka</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-feign</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
</dependencies>
```

2.在主类上使用`@EnableFeignClients`注解开启SpringCloudFeign的支持功能

```
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
public class FeignApplication {

    public static void main(String[] args) {
        SpringApplication.run(FeignApplication.class, args);
    }
}
```

3.接口定义：我们这里调用USER-SERVICE服务，在该服务中创建一个查询所有用户的接口，然后在feign-consumer中定义。
USER-SERVICE

```
@RestController
public class UserFeignController {
    
    @Autowired
    private UserRepository userRepository;
    
    @GetMapping("/feign/user/list")
    public List<User> findAllUser(){
        return  userRepository.findAll();
    }
}
```

feign-consumer

```
@FeignClient(value = "USER-SERVICE")
public interface UserService {

    @GetMapping("/feign/user/list")
    List<User> findAll();
}
```

使用`@FeignClient`注解指定服务名来绑定服务，如果不指定服务名，启动项目将会报错。然后创建一个接口与调用普通的service一样调用UserService。

```
@RestController
public class FeignConsumerController {

    @Autowired
    private UserService userService;

    @GetMapping(value = "/feign/find")
    public List<User> findAllUser(){
        return userService.findAll();
    }
}
```

1. 最后修改配置文件

```
spring:
  application:
    name: feign-consumer
server:
  port: 50000
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8888/eureka/
```

这里使用的User对象与前面ARTICLE-SERVICE的User对象一样。依次启动服务注册中心、服务提供方、服务消费方。然后调用`/feign/find`接口，可以正常返回数据。

# 参数绑定

在实际开发中，像上面那种不带参数的接口可能少之又少。Feign提供了多种参数绑定的方式。
在服务提供的`UserFeignController`中添加以下三个接口：

```
   /**
     * 根据id查询用户，将参数包含在Request参数
     */
    @GetMapping("/feign/userById")
    public User finUserById(@RequestParam Long id){
        logger.info(">>>>>>>>>>>id:{}<<<<<<<<<<<<<",id);
        return userRepository.findOne(id);
    }

       /**
     * 带有Header信息的请求,需要注意的是，使用请求头传递参数，如果参数是中文会出现乱码
     * 所以需要使用 URLEncoder.encode(name,"UTF-8") 先编码
     *       后解码  URLDecoder.decode(name,"UTF-8"); 
     */
    @GetMapping("/feign/header/user")
    public User findUserHeader(@RequestHeader String name,@RequestHeader Long id,@RequestHeader Integer age) throws UnsupportedEncodingException {
        User user = new User();
        user.setId(id);
        user.setUsername( URLDecoder.decode(name,"UTF-8"));
        user.setAge(age);
        logger.info(">>>>>>>>>>>findUserHeader{}<<<<<<<<<<<<<",user);
        return user;
    }
    /***
     * 带有RequestBody以及请求相应体是一个对象的请求
     */
    @PostMapping("/feign/insert")
    public User insertUser(@RequestBody User user){
        userRepository.save(user);
        return userRepository.findOne(user.getId());
    }
```

直接将上面添加的接口复制到消费方的Service接口中，删除方法体。需要注意的是：在SpringMVC中`@RequestParam`和@`RequestHeader`注解，如果我们不指定value，则默认采用参数的名字作为其value，但是在Feign中，这个value必须明确指定，否则会报错。

```
    /**
     * 根据id查询用户，将参数包含在Request参数
     */
    @GetMapping("/feign/userById")
    User finUserById(@RequestParam("id") Long id);

    /**
     * 带有Header信息的请求
     */
    @GetMapping("/feign/header/user")
    User findUserHeader(@RequestHeader("name") String name, @RequestHeader("id") Long id,@RequestHeader("age") Integer age);

    /**
     * 带有RequestBody以及请求相应体是一个对象的请求
     */
    @PostMapping("/feign/insert")
    User insertUser(@RequestBody User user);
```

测试接口：

```
    @GetMapping("/testFeign")
    public void testFeign() throws UnsupportedEncodingException {
        User user = userService.finUserById(2L);
        logger.info(">>>>>>>>>>>>Request参数：{}>>>>>>>>>>>>>",user);
        User user2 = userService.findUserHeader(URLEncoder.encode("呜呜呜呜","UTF-8"), 3L,1000);
        logger.info(">>>>>>>>>>>>Header:{}>>>>>>>>>>>>>",user2);
        User save_user = new User(5L,"嘻嘻嘻",56);
        User users = userService.insertUser(save_user);
        logger.info(">>>>>>>>>>>>RequestBody:{}>>>>>>>>>>>>>",users);
    }
```

![img](https://segmentfault.com/img/remote/1460000012860524?w=571&h=86)

# 继承特性

在上面的例子中，在服务消费方声明接口时都是将服务提供方的Controller复制过来。这么做会出现很多重复代码。在SpringCloudFeign中提供了继承特性来帮助我们解决这些复制操作。

1. 创建建一个基础的Maven工程，命名service-api，以复用DTO与接口定义。这里需要用到SpringMVC的注解，所以需要引入依赖：

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

1. 将上面的User对象复制到api中，并创建`UserService`

```
@Data
@AllArgsConstructor
@NoArgsConstructor
public class User implements Serializable {

    private Long id;
    private String username;
    private int age;
}

@RequestMapping("/rafactor")
public interface UserService {

    @GetMapping("/feign/user/list")
    List<User> findAll();


    /**
     * 根据id查询用户，将参数包含在Request参数
     */
    @GetMapping("/feign/userById")
    User finUserById(@RequestParam("id") Long id);

    /**
     * 带有Header信息的请求
     */
    @GetMapping("/feign/header/user")
    User findUserHeader(@RequestHeader("name") String name, @RequestHeader("id") Long id, @RequestHeader("age") Integer age);

    /**
     * 带有RequestBody以及请求相应体是一个对象的请求
     */
    @PostMapping("/feign/insert")
    User insertUser(@RequestBody User user);

}
```

1. 重构USER-SERVICE，在pom文件中新增service-api；并创建UserRafactorController类实现service-api的UserService类;

```
<dependency>
    <groupId>com.wqh</groupId>
    <artifactId>sevice-api</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

```
@RestController
public class UserRafactorController implements UserService{
    private final Logger logger = LoggerFactory.getLogger(UserRafactorController.class);
    @Autowired
    private UserRepository userRepository;
    @Override
    public List<User> findAll() {
        return null;
    }

    @Override
    public User finUserById(Long id) {
        logger.info(">>>>>>>>>>>Rafactor id:{}<<<<<<<<<<<<<",id);
        com.wqh.user.entity.User one = userRepository.findOne(id);
        User user = new User(one.getId(),one.getUsername(),one.getAge());
        return user;
    }

    @Override
    public User findUserHeader(@RequestHeader("name")String name, @RequestHeader("id")Long id,@RequestHeader("age") Integer age) {
        User user = new User();
        user.setId(id);
        try {
            user.setUsername( URLDecoder.decode(name,"UTF-8"));
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        user.setAge(age);
        logger.info(">>>>>>>>>>>Rafactor findUserHeader{}<<<<<<<<<<<<<",user);
        return user;
    }

    @Override
    public User insertUser(@RequestBody User user) {
        logger.info(">>>>>>>>>>>Rafactor RequestBody{}<<<<<<<<<<<<<",user);
        return user;
    }
}
```

该类不需要使用@RequestMapping注解来定义请求映射，参数注解需要添加，并且在类上添加@RestController注解。

1. 重构feign-consumer，添加service-api的依赖

```
<dependency>
    <groupId>com.wqh</groupId>
    <artifactId>sevice-api</artifactId>
    <version>0.0.1-SNAPSHOT</version>
</dependency>
```

创建UserRafactorService接口继承UserService接口

```
@FeignClient(value = "USER-SERVICE")
public interface UserRafactorService extends UserService {
}
```

1. 测试接口

```
    @GetMapping("/testRafactorService")
    public void testRafactorService() throws UnsupportedEncodingException {
        com.wqh.api.dto.User user = userRafactorService.finUserById(2L);
        logger.info(">>>>>>>>>>>>Rafactor Request参数：{}>>>>>>>>>>>>>",user);
        com.wqh.api.dto.User user2 = userRafactorService.findUserHeader(URLEncoder.encode("呜呜呜呜","UTF-8"), 3L,1000);
        logger.info(">>>>>>>>>>>>Rafactor Header:{}>>>>>>>>>>>>>",user2);
        com.wqh.api.dto.User save_user = new com.wqh.api.dto.User(5L,"嘻嘻嘻",56);
        com.wqh.api.dto.User users = userRafactorService.insertUser(save_user);
        logger.info(">>>>>>>>>>>>Rafactor RequestBody:{}>>>>>>>>>>>>>",users);
    }
```

![img](https://segmentfault.com/img/remote/1460000012860525?w=1010&h=83)
![img](https://segmentfault.com/img/remote/1460000012860526?w=1243&h=94)
注意：这里对于对象之间的处理是存在问题，就不详细的修改了，主要是为了Feign的继承特性。

# Feign配置详解

## Ribbon配置

在Feign中配置Ribbon非常简单，直接在application.properties中配置即可，如：

```
# 设置连接超时时间
ribbon.ConnectTimeout=500
# 设置读取超时时间
ribbon.ReadTimeout=5000
# 对所有操作请求都进行重试
ribbon.OkToRetryOnAllOperations=true
# 切换实例的重试次数
ribbon.MaxAutoRetriesNextServer=2
# 对当前实例的重试次数
ribbon.MaxAutoRetries=1
```

同样也可以指定服务配置，直接在application.properties中采用<client>.ribbon.key=value的格式进行配置，如下：

```
# 设置针对user-service服务的连接超时时间
user-service.ribbon.ConnectTimeout=600
# 设置针对user-service服务的读取超时时间
user-service.ribbon.ReadTimeout=6000
# 设置针对user-service服务所有操作请求都进行重试
user-service.ribbon.OkToRetryOnAllOperations=true
# 设置针对user-service服务切换实例的重试次数
user-service.ribbon.MaxAutoRetriesNextServer=2
# 设置针对user-service服务的当前实例的重试次数
user-service.ribbon.MaxAutoRetries=1
```

在SpringCloudFeign中是默认打开重试机制，从上面的配置信息也可以看出，我们可以设置重试的次数。对于重试机制的测试，可以让服务提供方的方法延迟随机毫秒数来测试。

## Hystrix配置

对于Hystrix的配置同样可以在application.properties中配置，全局配置直接使用默认前缀`hystrix.command.default`，如

```
# 设置熔断超时时间
hystrix.command.default.execution.isolation.thread.timeoutInMilliseconds=10000
# 关闭Hystrix功能（不要和上面的配置一起使用）
feign.hystrix.enabled=false
# 关闭熔断功能
hystrix.command.default.execution.timeout.enabled=false
```

也可以直接对指定的接口进行配置，采用`hystrix.command.default.<commandKey>`作为前缀，比如如`/findAllUser`：

```
# 设置熔断超时时间
hystrix.command.findAllUser.execution.isolation.thread.timeoutInMilliseconds=10000
# 关闭熔断功能
hystrix.command.findAllUser.execution.timeout.enabled=false
```

对于重复的接口名会共用这一条Hystrix配置；

## 禁用Hystrix

上面的配置信息中，可以通过配置文件全局禁用Hystrix也可以指定接口禁用。我们也可以注解属性的方式禁用Hystrix;

- 构建一个关闭Hystrix的配置类

```
@Configuration
public class DisableHystrixConfiguration {
    
    @Bean
    @Scope("prototype")
    public Feign.Builder feignBuilder(){
        return Feign.builder();
    }
}
```

- 在`@FeignClient`注解中，通过`configuration`参数引入上面实现的配置

```
@FeignClient(value = "USER-SERVICE",configuration = DisableHystrixConfiguration.class)
public interface UserRafactorService extends UserService {
}
```

## 服务降级配置

在Hystrix中我们可以直接通过@HystrixCommand注解的fallback参数进行配置降级处理方法，然而Feign对其进行封装，并提供了一种简单的定义方式：

1. 在之前的feign-consumer服务中创建一个UserServiceFallback类，该类实现UserService接口。这里对于哪个类接口的降级就实现哪个接口，

```
@Component
public class UserServiceFallback implements UserService {
    @Override
    public List<User> findAll() {
        return null;
    }

    @Override
    public User finUserById(Long id) {
        return new User(-1L,"error",0);
    }

    @Override
    public User findUserHeader(String name, Long id, Integer age) {
        return new User(-1L,"error",0);
    }

    @Override
    public User insertUser(User user) {
        return new User(-1L,"error",0);
    }
}
```

1. 然后再@FeignClient注解中指定服务降级处理类即可：

```
@FeignClient(value = "USER-SERVICE",fallback = UserServiceFallback.class)
```

1. 在配置文件中开启Hystrix：

```
feign:
  hystrix:
    enabled: true
```

然后在USER-SERVICE服务中将某个接口设置延迟测试：
![img](https://segmentfault.com/img/remote/1460000012860527?w=628&h=91)

## 请求压缩

> Spring Cloud Feign支持对请求和响应进行GZIP压缩，以提高通信效率，配置方式如下：

```
# 配置请求GZIP压缩
feign.compression.request.enabled=true
# 配置响应GZIP压缩
feign.compression.response.enabled=true
# 配置压缩支持的MIME TYPE
feign.compression.request.mime-types=text/xml,application/xml,application/json
# 配置压缩数据大小的下限
feign.compression.request.min-request-size=2048
```

## 日志配置

SpringCloudFeign为每一个FeignClient都提供了一个feign.Logger实例。可以根据`logging.level.<FeignClient>`参数配置格式来开启Feign客户端的DEBUG日志，其中`<FeignClient>`为Feign客户端定义接口的完整路径。如：

```
logging:
  level: 
    com.wqh.feign.service.UserService: debug
```

然后再主类中直接加入Looger.Level的Bean

```
@Bean
public Logger.Level feignLoggerLevel(){
    return  Logger.Level.FULL;
}
```

这里也可以通过配置，然后在具体的Feign客户端来指定配置类实现日志。
日志级别有下面4类：

- NONE：不记录任何信息；
- BASIC：仅记录请求方法、URL以及响应状态码和执行时间；
- HEADERS：除了记录BASIC级别的信息外，还记录请求和响应的头信息；
- FULL：记录所有请求与响应的明细，包括头信息、请求体、元数据等。

