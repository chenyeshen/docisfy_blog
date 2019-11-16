## tk.mybatis通用工具pom

```
 <!--mybatis依赖-->
<dependency>
    <groupId>org.mybatis.spring.boot</groupId>
    <artifactId>mybatis-spring-boot-starter</artifactId>
    <version>1.3.1</version>
</dependency>

<!--通用mapper-->
<dependency>
    <groupId>tk.mybatis</groupId>
    <artifactId>mapper-spring-boot-starter</artifactId>
    <version>1.1.5</version>
</dependency>
```

## 采坑点

### 批量插入数据，默认主键只支持id

1. 继承此工具MySqlMapper方法后

```
/**
 * 通用Mapper接口,MySql独有的通用方法
 *
 * @param <T> 不能为空
 * @author liuzh
 */
public interface MySqlMapper<T> extends
        InsertListMapper<T>,
        InsertUseGeneratedKeysMapper<T> {

}
```

- 可以看到存在可以批量插入类到数据库的方法
- 如果项目中途加入了此工具，那么恭喜，估计要踩很多坑~
- 数据库表主键不为id时，可以继续看源码

```
public interface InsertListMapper<T> {

    /**
     * 批量插入，支持批量插入的数据库可以使用，例如MySQL,H2等，另外该接口限制实体包含`id`属性并且必须为自增列
     *
     * @param recordList
     * @return
     */
    @Options(useGeneratedKeys = true, keyProperty = "id")
    @InsertProvider(type = SpecialProvider.class, method = "dynamicSQL")
    int insertList(List<T> recordList);

    /**
     * ======如果主键不是id怎么用？==========
     * 假设主键的属性名是uid,那么新建一个Mapper接口如下
     * <pre>
        public interface InsertUidListMapper<T> {
            @Options(useGeneratedKeys = true, keyProperty = "uid")
            @InsertProvider(type = SpecialProvider.class, method = "dynamicSQL")
            int insertList(List<T> recordList);
        }
     * 只要修改keyProperty = "uid"就可以
     *
     * 然后让你自己的Mapper继承InsertUidListMapper<T>即可
     *
     * </pre>
     */
}
```

- 他留着坑还是很负责的把解决办法留下了~~
- 我是按网上通用的搭建方式搭建的目录结构，也就是如下结构

```
/**
 * 继承自己的MyMapper
 *
 */
public interface MyMapper<T> extends Mapper<T>, MySqlMapper<T> {
    //FIXME 特别注意，该接口不能被扫描到，否则会出错
    //FIXME 最后在启动类中通过MapperScan注解指定扫描的mapper路径：
}
```

- 因为InsertUidListMapper这种特殊写的mapper和MyMapper是同一类，如果不同样配置下会报如下错误

```
org.mybatis.spring.MyBatisSystemException: nested exception is org.apache.ibatis.builder.BuilderException: Error invoking SqlProvider method (tk.mybatis.mapper.provider.SpecialProvider.dynamicSQL).  Cause: java.lang.InstantiationException: tk.mybatis.mapper.provider.SpecialProvider
```

- 这时候你要，在application.properties中，把InsertUidListMapper路径配上去

```
mapper.mappers=com.tzxylao.manager.utils.MyMapper,com.tzxylao.manager.mapper_ext.InsertUidListMapper
```

- 还有一点，光这样匹配后还不够，自己写的类DpageConfigMapper，继承InsertUidListMapper 这个类后，把DpageConfigMapper类放在Mapper目录下，那么又会很纠结。系统启动会扫描不到DpageConfigMapper这个类。。我竟然找不到默认扫描Mapper包的地方。。但是经验告诉我，继承了MyMapper的类都能被扫描到~~
- 可是自己的类继承的是InsertUidListMapper ，想要它被扫描，启动类就要加上扫描包的地方。。我扫描了整个Mapper包

```
@EnableTransactionManagement  // 启注解事务管理，等同于xml配置方式的
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@EnableAutoConfiguration
@MapperScan("com.tzxylao.manager.mapper")
public class Application extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class);
    }
}
```

- 但这样要注意，继承类InsertUidListMapper ，不能再这个包里，否则会报该类不能被扫描错误~~
- 就算把这个类移到了其他包，系统也可以正常运行了。。其实还是有点问题。。启动的时候会出现类似的警告

```
Skipping MapperFactoryBean with name 'sysMenuMapper' and 'com.telchina.framework.sys.mapper.SysMenuMapper' mapperInterface. Bean already defined with the same name!
```

虽然不影响使用，但还是看着烦~，他的意思就是这个类被扫了两遍~~我就说哪里MyMapper类继承的类都被莫名其妙扫了一遍。。自己再配置扫一遍就重复了~

- 解决办法就是再建个子包，不继承MyMapper的自定义Mapper都放子包，再单独配置子包扫描

```
@EnableTransactionManagement  // 启注解事务管理，等同于xml配置方式的
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@EnableAutoConfiguration
@MapperScan("com.tzxylao.manager.mapper.ext")
public class Application extends SpringBootServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(Application.class);
    }
}
```

把DpageConfigMapper类放ext子包里就行了。。

- 上面步骤都解决了，插入还是不成功的，插入语句没有主键，自己生成的主键插不进去？
- 看源码

```
 /**
 * 批量插入
 *
 * @param ms
 */
public String insertList(MappedStatement ms) {
    final Class<?> entityClass = getEntityClass(ms);
    //开始拼sql
    StringBuilder sql = new StringBuilder();
    sql.append(SqlHelper.insertIntoTable(entityClass, tableName(entityClass)));
    sql.append(SqlHelper.insertColumns(entityClass, true, false, false));
    sql.append(" VALUES ");
    sql.append("<foreach collection=\"list\" item=\"record\" separator=\",\" >");
    sql.append("<trim prefix=\"(\" suffix=\")\" suffixOverrides=\",\">");
    //获取全部列
    Set<EntityColumn> columnList = EntityHelper.getColumns(entityClass);
    //当某个列有主键策略时，不需要考虑他的属性是否为空，因为如果为空，一定会根据主键策略给他生成一个值
    for (EntityColumn column : columnList) {
        if (!column.isId() && column.isInsertable()) {
            sql.append(column.getColumnHolder("record") + ",");
        }
    }
    sql.append("</trim>");
    sql.append("</foreach>");
    return sql.toString();
}
```

- 可以看到，主键插入的地方，他有这样的判断!column.isId() && column.isInsertable()，所以，Bean类主键属性上@Id去掉，就可以自己添加主键值了

