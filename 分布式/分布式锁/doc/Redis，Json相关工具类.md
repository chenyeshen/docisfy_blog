# Redis，Json相关工具类

### Redis

1、快速安装

- [https://redis.io/download#installation](https://links.jianshu.com/go?to=https%3A%2F%2Fredis.io%2Fdownload%23installation)
- wget [http://download.redis.io/releases/redis-4.0.9.tar.gz](https://links.jianshu.com/go?to=http%3A%2F%2Fdownload.redis.io%2Freleases%2Fredis-4.0.9.tar.gz)
- tar xzf redis-4.0.9.tar.gz
- cd redis-4.0.9
- make
- 启动服务端：src/redis-server
- 启动客户端：src/redis-cli

2、默认是本地访问的，需要开放外网访问

> 打开redis.conf文件在NETWORK部分修改
> 注释掉bind 127.0.0.1
> 然后修改 protected-mode，值改为no;
> 则可以使所有的ip访问redis

> 所以可以指定bind多个IP,这样就只有指定IP才能连接redis了

### 整合redis

[官网](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.spring.io%2Fspring-boot%2Fdocs%2F2.1.0.BUILD-SNAPSHOT%2Freference%2Fhtmlsingle%2F%23boot-features-redis)

[集群文档](https://links.jianshu.com/go?to=https%3A%2F%2Fdocs.spring.io%2Fspring-data%2Fdata-redis%2Fdocs%2Fcurrent%2Freference%2Fhtml%2F%23cluster)

```
@Component
@ConfigurationProperties(prefix = "spring.redis.cluster")
public class ClusterConfigurationProperties {

    /*
     * spring.redis.cluster.nodes[0] = 127.0.0.1:7379
     * spring.redis.cluster.nodes[1] = 127.0.0.1:7380
     * ...
     */
    List<String> nodes;

    /**
     * Get initial collection of known cluster nodes in format {@code host:port}.
     *
     * @return
     */
    public List<String> getNodes() {
        return nodes;
    }

    public void setNodes(List<String> nodes) {
        this.nodes = nodes;
    }
}

@Configuration
public class AppConfig {

    /**
     * Type safe representation of application.properties
     */
    @Autowired ClusterConfigurationProperties clusterProperties;

    public @Bean RedisConnectionFactory connectionFactory() {

        return new JedisConnectionFactory(
            new RedisClusterConfiguration(clusterProperties.getNodes()));
    }
}

```

- 添加依赖

```
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>

```

- 配置文件

```
#=========redis基础配置=========
# redis其实默认有16个实例0-15，可以通过redis客户端可视化查看
# 基本写哪个都行
spring.redis.database=0
spring.redis.host=127.0.0.1
spring.redis.port=6390
# 连接超时时间 单位 ms（毫秒）
spring.redis.timeout=3000

#=========redis线程池设置=========
# 连接池中的最大空闲连接，默认值也是8。
spring.redis.pool.max-idle=200

#连接池中的最小空闲连接，默认值也是0。
spring.redis.pool.min-idle=200
            
# 如果赋值为-1，则表示不限制；pool已经分配了maxActive个jedis实例，则此时pool的状态为exhausted(耗尽)。
spring.redis.pool.max-active=2000

# 等待可用连接的最大时间，单位毫秒，默认值为-1，表示永不超时
spring.redis.pool.max-wait=1000


```

- redistemplate种类讲解和缓存(使用自动注入)

  - 注入模板

  ```
  @Autowired
  private StirngRedisTemplate strTplRedis

  ```

  - 类型String，List,Hash,Set,ZSet

  > 对应的方法分别是opsForValue()、opsForList()、opsForHash()、opsForSet()、opsForZSet()

### 基础代码

```
@RequestMapping("v1/redis")
@RestController
public class RedisController {
    @Autowired
    private StringRedisTemplate redisTemplate;

    @GetMapping("add")
    public Object add() {
        redisTemplate.opsForValue().set("name","zq");
        return "ok";
    }

    @GetMapping("get")
    public Object get() {
        redisTemplate.opsForValue().get("name");
        return "ok";
    }
}

```

### 工具类

### 对象字符串互转（依赖于默认的jackson）

```
public class JsonUtils {

    private static ObjectMapper objectMapper = new ObjectMapper();
    
    //对象转字符串
    public static <T> String obj2String(T obj){
        if (obj == null){
            return null;
        }
        try {
            return obj instanceof String ? (String) obj : objectMapper.writeValueAsString(obj);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    //字符串转对象
    public static <T> T string2Obj(String str,Class<T> clazz){
        if (StringUtils.isEmpty(str) || clazz == null){
            return null;
        }
        try {
            return clazz.equals(String.class)? (T) str :objectMapper.readValue(str,clazz);
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
}

```

### 返回的JSON对象的工具类(例如状态码封装)

```
public class JsonData implements Serializable {

    /**
     * 
     */
    private static final long serialVersionUID = 1L;

    private Integer code; // 状态码 0 表示成功，1表示处理中，-1表示失败
    private Object data; // 数据
    private String msg;// 描述

    public JsonData() {
    }

    public JsonData(Integer code, Object data, String msg) {
        this.code = code;
        this.data = data;
        this.msg = msg;
    }

    // 成功，传入数据
    public static JsonData buildSuccess() {
        return new JsonData(0, null, null);
    }

    // 成功，传入数据
    public static JsonData buildSuccess(Object data) {
        return new JsonData(0, data, null);
    }

    // 失败，传入描述信息
    public static JsonData buildError(String msg) {
        return new JsonData(-1, null, msg);
    }

    // 失败，传入描述信息,状态码
    public static JsonData buildError(String msg, Integer code) {
        return new JsonData(code, null, msg);
    }

    // 成功，传入数据,及描述信息
    public static JsonData buildSuccess(Object data, String msg) {
        return new JsonData(0, data, msg);
    }

    // 成功，传入数据,及状态码
    public static JsonData buildSuccess(Object data, int code) {
        return new JsonData(code, data, null);
    }

    public Integer getCode() {
        return code;
    }

    public void setCode(Integer code) {
        this.code = code;
    }

    public Object getData() {
        return data;
    }

    public void setData(Object data) {
        this.data = data;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    @Override
    public String toString() {
        return "JsonData [code=" + code + ", data=" + data + ", msg=" + msg
                + "]";
    }
}

```

### redis工具类(对StringRedisTemplate的封装)

```
@Component
public class RedisClient {
    @Autowired
    private StringRedisTemplate redisTpl; //jdbcTemplate
    /**
     * 功能描述：设置key-value到redis中
     * @param key
     * @param value
     * @return
     */
    public boolean set(String key ,String value){
        try{
            redisTpl.opsForValue().set(key, value);
            return true;
        }catch(Exception e){
            e.printStackTrace();
            return false;
        }
    }
    /**
     * 功能描述：通过key获取缓存里面的值
     * @param key
     * @return
     */
    public String get(String key){
        return redisTpl.opsForValue().get(key);
    }

    @Autowired
    private StringRedisTemplate redisTemplate;
    
    
     /** 
    * 通过字符串key获取值 
    * @param key 键 
    * @return 值 
    */  
   public String get(String key){  
       return key==null?null:redisTemplate.opsForValue().get(key);  
   } 
   
   
   /** 
    * 普通缓存放入 
    * @param key 键 
    * @param value 值 
    * @return true成功 false失败 
    */  
   public boolean set(String key,String value) {  
        try {  
           redisTemplate.opsForValue().set(key, value);  
           return true;  
       } catch (Exception e) {  
           e.printStackTrace();  
           return false;  
       }  
         
   }  
   
    
   
    /**
     * 功能描述：设置某个key过期时间
     * @param key
     * @param time
     * @return
     */
      public boolean expire(String key,long time){  
            try {  
                if(time>0){  
                    redisTemplate.expire(key, time, TimeUnit.SECONDS);  
                }  
                return true;  
            } catch (Exception e) {  
                e.printStackTrace();  
                return false;  
            }  
        }  

        
      
      
      /**
       * 功能描述：根据key 获取过期时间 
       * @param key
       * @return
       */
      public long getExpire(String key){  
            return redisTemplate.getExpire(key,TimeUnit.SECONDS);  
        }  
      
      
        /** 
         * 递增 
         * @param key 键 
         * @return 
         */  
        public long incr(String key, long delta){    
            return redisTemplate.opsForValue().increment(key, delta);  
        }  
        
        
        /** 
         * 递减 
         * @param key 键 
         * @param delta 要减少几
         * @return 
         */  
        public long decr(String key, long delta){    
            return redisTemplate.opsForValue().increment(key, -delta);    
        }    
        
        //==============Map结构=====================
        
        
        //==============List结构=====================     
}
```