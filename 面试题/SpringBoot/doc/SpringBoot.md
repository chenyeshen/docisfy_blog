# Spring boot

#### 1. 如何在不重启服务器的情况下在Spring引导时重新加载我的更改?

答:这可以通过开发工具来实现。有了这个依赖项，您保存的任何更改都将重新启动嵌入的tomcat。Spring Boot有一个开发人员工具(DevTools)模块

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>*true*</optional>
</dependency>
```

#### 2. 什么是Spring boot actuator?

答:Spring boot actuator是Spring boot framework的重要特性之一。Spring boot actuator帮助您访问生产环境中正在运行的应用程序的当前状态，在生产环境中必须检查和监视几个指标。甚至一些外部应用程序也可能使用这些服务来触发对相关人员的警报消息。actuator模块公开一组REST端点，这些端点可以作为HTTP URL直接访问，以检查状态。

#### 3. 如何禁用执行器端点安全在Spring启动?

答:默认情况下，所有敏感的HTTP端点都是安全的，只有具有ACTUATOR角色的用户才能访问它们。安全性是使用标准HttpServletRequest.isUserInRole方法实现的。
我们可以使用-禁用安全性
management.security.enabled = false
建议仅当在防火墙后访问ACTUATOR端点时禁用安全性。

#### 4. 如何将Spring引导应用程序运行到自定义端口?

要在自定义端口上运行spring引导应用程序，可以在application.properties中指定端口。
server.port = 8090

#### 5. 怎么用Spring Boot编写测试用例?

答:SpringBoot为编写单元测试用例提供了@SpringBootTest

@RunWith(SpringRunner.*class*)
@SpringBootTest
*public class *SpringBootHelloWorldTests {
​    @Test
​    *public void *contextLoads() {}
}

#### 6. Spring Boot 的配置文件有哪几种格式？它们有什么区别？

答：pring Boot 的核心配置文件是 application 和 bootstrap 配置文件。

application 配置文件这个容易理解，主要用于 Spring Boot 项目的自动化配置。

bootstrap 配置文件有以下几个应用场景。

使用 Spring Cloud Config 配置中心时，这时需要在 bootstrap 配置文件中添加连接到配置中心的配置属性来加载外部配置中心的配置信息；

一些固定的不能被覆盖的属性；

一些加密/解密的场景；

#### 7. Spring Boot 有哪几种读取配置的方式？

答：Spring Boot 可以通过 @PropertySource,@Value,@Environment, @ConfigurationProperties 来绑定变量

#### 8. 如何理解 Spring Boot 配置加载顺序？

答：在 Spring Boot 里面，可以使用以下几种方式来加载配置。

1） properties文件；

2） YAML文件；

3） 系统环境变量；

4） 命令行参数；

#### 9. Spring Boot是如何实现异常处理？

答：Spring提供了一种使用ControllerAdvice处理异常的非常有用的方法。 我们通过实现一个ControlerAdvice类，来处理控制器类抛出的所有异常。

#### 10. 如何用Spring Boot实现拦截器?

1.OneInterceptor类必须实现接口 HandlerInterceptor，然后重写里面需要的三个比较常用的方法：

(1)preHandle  方法会在请求处理之前进行调用（Controller方法调用之前）

(2)postHandle  请求处理之后进行调用，但是在视图被渲染之前（Controller方法调用之后）

(3)afterCompletion  在整个请求结束之后被调用，也就是在DispatcherServlet 渲染了对应的视图之后执行（主要是用于进行资源清理工作）

2.编写拦截器配置文件主类 WebMvcConfigurer  此类必须继承  WebMvcConfigurerAdapter 类，并重写其中的方法  addInterceptors   并且在主类上加上注解  @Configuration  

@Configuration
*public class *WebMvcConfig *extends *WebMvcConfigurerAdapter {
​    @Override
​    *public void *addInterceptors(InterceptorRegistry registry) {
​        registry.addInterceptor(permissionInterceptor).addPathPatterns("/");
​        *super*.addInterceptors(registry);
​    }
}

10、@responsebody有什么作用？
@responsebody后返回结果不会被解析为跳转路径，而是直接写入HTTP response body中。比如异步获取json数据，加上@responsebody后，会直接返回json数据。该注解一般会配合@RequestMapping一起使用。

11、@Controller 和 @RestController有什么区别？
@RestController 是Spring4之后加入的注解，原来在@Controller中返回json需要@ResponseBody来配合，如果直接用@RestController替代@Controller就不需要再配置@ResponseBody，默认返回json格式。而@Controller是用来创建处理http请求的对象，一般结合@RequestMapping使用。

12、@Component和@Bean有什么区别？ （答案还不是特别确信）
@Component被用在要被自动扫描和装配的类上。@Component类中使用方法或字段时不会使用CGLIB增强(及不使用代理类：调用任何方法，使用任何变量，拿到的是原始对象)Spring 注解@Component等效于@Service,@Controller,@Repository
@Bean主要被用在方法上，来显式声明要用生成的类;用@Configuration注解该类，用@Bean标注方法等价于XML中配置bean。

现在项目上，本工程中的类，一般都使用@Component来生成bean。在把通过web service取得的类，生成Bean时，使用@Bean和getter方法来生成bean

13、有什么springboot的安全方面的实践？
见
https://mp.weixin.qq.com/s/HG4_StZyNCoWx02mUVCs1g

14、如何使用@Async？
现在启动类@SpringBootApplication后面加入@EnableAsync，定义@Component类中的异步任务方法，其中注解@Async，方法返回void或者Future<T>，调用方法即平常的@Autowired实例化即可。

15、springboot如何开启定时任务？
定义启动类@EnableScheduling，然后在任务类使用cron表达式来定义任务时间，比如@Scheduled(cron="/6 * * * * ?")代表每6秒一次，再如：“0 0 12 * * ?” 每天中午12点触发。