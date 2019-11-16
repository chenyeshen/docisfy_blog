### 开启Mybatis的二级缓存

在applcation.properties中

```
mybatis.configuration.cache-enabled=true
```

在Mapper接口上使用@CacheNamespace注解

在实体类需要序列化 

```
public class User implements Serializable {

    private static final long serialVersionUID = 1L;

    //实体略
}
```

Cache Hit Ratio也就是缓存命中率