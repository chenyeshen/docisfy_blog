# **Feign使用Hystrix开发步骤**

1、导入依赖spring-cloud-starter-hystrix

2、消费启动类开启@EnableCircuitBreaker

3、配置yml文件feign.hystrix.enabled=true

4、实现FeignClient接口或FallbackFactory接口
4.1、实现FeignClient接口
4.2、实现FallbackFactory接口
5、@FeignClient注解配置fallback参数

 

### **1、导入依赖spring-cloud-starter-hystrix**

```
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-hystrix</artifactId>
</dependency>
```

 

### **2、消费启动类开启@EnableCircuitBreaker**

```
@SpringBootApplication
@EnableDiscoveryClient
@EnableFeignClients
@EnableHystrix //开启Hystrix支持
public class RibbonConsumerApplication {

    public static void main(String[] args) {
        SpringApplication.run(RibbonConsumerApplication.class, args);
    }
    
}
```

 

### **3、配置yml文件feign.hystrix.enabled=true**

```
server:
  port: 8808
feign: 
  hystrix:
    #开启feign的hystrix支持,默认是false 
    enabled: true
```

 

### **4、实现FeignClient接口或FallbackFactory接口**

#### 4.1、实现FeignClient接口

**TestClient1.java**

```
//fallback 指定一个回退类，这个类必须实现@FeignClient声明的接口,并且在spring context中
@FeignClient(value="cloud-producer",
    configuration=FeignClientsConfiguration.class,
    fallback=TestClient1FallBack.class)
public interface TestClient1 {
    
        @GetMapping(value = "/get/{id}")
        public String get(@PathVariable("id") String id);

        @RequestMapping(value = "/getuser/{id}")
        public User getUser(@PathVariable("id") String id);
        
        @RequestMapping(value = "/getuser2", method = RequestMethod.GET)
        public User getUser2(User user);

        @RequestMapping(value = "/postuser")
        public User postUser(@RequestBody User user);

        @RequestMapping(value = "/postuser")
        public User postUser2(User user);

        @RequestMapping(value = "/postuser", method = RequestMethod.GET)
        public User postUser3(User user);

        @GetMapping(value = "/listAll")
        List<User> listAll();
    
}
```



**TestClient1FallBack.java**

```
@Component
public class TestClient1FallBack implements TestClient1 {
    @Override
    public String get(String id) {
        return "feign hystrix fallback for get method";
    }

    @Override
    public User getUser(String id) {
        User errorUser = new User();
        errorUser.setId("getUser.errorId");
        errorUser.setName("getUser.errorName");
        return errorUser;
    }

    @Override
    public User getUser2(User user) {
        User errorUser = new User();
        errorUser.setId("getUser2.errorId");
        errorUser.setName("getUser2.errorName");
        return errorUser;
    }

    @Override
    public User postUser(User user) {
        User errorUser = new User();
        errorUser.setId("postUser.errorId");
        errorUser.setName("postUser.errorName");
        return errorUser;
    }

    @Override
    public User postUser2(User user) {
        User errorUser = new User();
        errorUser.setId("postUser2.errorId");
        errorUser.setName("postUser2.errorName");
        return errorUser;
    }

    @Override
    public User postUser3(User user) {
        User errorUser = new User();
        errorUser.setId("postUser3.errorId");
        errorUser.setName("postUser3.errorName");
        return errorUser;
    }

    @Override
    public List<User> listAll() {
        User errorUser = new User();
        errorUser.setId("listAll.errorId");
        errorUser.setName("listAll.errorName");
        ArrayList<User> list = new ArrayList<User>();
        list.add(errorUser);
        return list;
    }
}
```



**Test1Controller.java**

```
@RestController
public class Test1Controller {
    
    @Autowired
    private TestClient1 testClient1;
    
    @GetMapping("/feign1/get/{id}")
    public String get(@PathVariable String id) {
        String result = testClient1.get(id);
        return result;
    }
    
    @GetMapping("/feign1/getuser/{id}")
    public User getUser(@PathVariable String id) {
        User result = testClient1.getUser(id);
        return result;
    }
    
    @GetMapping("/feign1/getuser2")
    public User getUser2(User user) {
        User result = testClient1.getUser2(new User());
        return result;
    }
    
    @GetMapping("/feign1/listAll")
    public List<User> listAll() {
        return testClient1.listAll();
    }
    
    @PostMapping("/feign1/postuser")
    public User postUser(@RequestBody User user) {
        User result = testClient1.postUser(user);
        return result;
    }
    
    @PostMapping("/feign1/postuser2")
    public User postUser2(@RequestBody User user) {
        User result = testClient1.postUser2(user);
        return result;
    }
    
    @PostMapping("/feign1/postuser3")
    public User postUser3(@RequestBody User user) {
        User result = testClient1.postUser3(user);
        return result;
    }
    
}
```



#### 4.2、实现FallbackFactory接口

**TestClient3.java**

```
//fallbackFactory 指定一个fallback工厂,与指定fallback不同, 此工厂可以用来获取到触发断路器的异常信息,TestClientFallbackFactory需要实现FallbackFactory类
@FeignClient(value="mima-cloud-producer",configuration=FeignClientsConfiguration.class,fallbackFactory=TestClien3tFallbackFactory.class)
public interface TestClient3 {
    
    @RequestMapping(value="/get/{id}",method=RequestMethod.GET)
    public String get(@PathVariable("id") String id);
    
    @RequestMapping(value = "/getuser/{id}")
    public User getUser(@PathVariable("id") String id);
    
}
```



**TestClien3tFallbackFactory.java——优点是可以获取到异常信息**

```
//FallbackFactory的优点是可以获取到异常信息
@Component
public class TestClien3tFallbackFactory implements FallbackFactory<TestClient3> {

    @Override
    public TestClient3 create(Throwable cause) {
        return new TestClient3() {
            @Override
            public String get(String id) {
                return "get trigger hystrix open! reason:"+cause.getMessage();
            }

            @Override
            public User getUser(String id) {
                User errorUser = new User();
                errorUser.setId("getUser.errorId");
                errorUser.setName("getUser.errorName");
                return errorUser;
            }
        };
    }
    
}
```



**Test3Controller.java**

```
@RestController
public class Test3Controller {
    
    @Autowired
    private TestClient3 testClient3;
    
    @GetMapping("/feign3/get/{id}")
    public String get(@PathVariable String id) {
        String result = testClient3.get(id);
        return result;
    }
    
    @GetMapping("/feign3/getuser/{id}")
    public User getuser(@PathVariable String id) {
        User result = testClient3.getUser(id);
        return result;
    }
    
}
```



### 5、@FeignClient注解配置fallback参数