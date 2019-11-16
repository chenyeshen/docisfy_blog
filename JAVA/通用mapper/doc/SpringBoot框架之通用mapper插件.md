## **一.Tkmybatis的好处**

Tkmybatis是在mybatis框架的基础上提供了很多工具，让开发更加高效。这个插件里面封装好了我们需要用到的很多sql语句，不过这个插件是通过我们去调用它封装的各种方法来实现sql语句的效果。对于单表查询不需要写SQL语句，这样就不用像mybatis那样每次写一个接口就要写一条sql语句。这样大大减少了我们的工作量。

> 拓展：[IDEA中使用mybatis-generator自动生成mapper和pojo文件](https://blog.csdn.net/qq_38455201/article/details/79194792)
>
> 使用maven命令即可使用：mvn mybatis-generator:generate

## 二.**搭建与使用**

### 1、首先我们添加tk.mybatis的依赖包

```
<!--通用Mapper-->
<dependency>
    <groupId>tk.mybatis</groupId>
    <artifactId>mapper</artifactId>
    <version>3.3.9</version>
</dependency>
```

### 2、然后去添加一个UserInfo实体类

```
//注解声明数据库某表明
@Table(name = "USER")//如果实体类名字与数据库不一致又不使用注解会报错
public class UserInfo {
	@Id
      @GeneratedValue(strategy = GenerationType.IDENTITY, generator = "SELECT LAST_INSERT_ID()")
	@Column(name = "id")// 注解声明该表的字段名
	private Integer id;
	@Column(name = "code")//如果实体类变量与数据库列名不一致又不使用注解会报错
	private String code;

	//添加get，set方法
}
```

拓展：SpringBoot的@GeneratedValue的参数设置

默认是可以不加参数的，但是如果数据库控制主键自增(auto_increment), 不加参数就会报错。

@GeneratedValue(strategy=GenerationType.IDENINY)

PS：@GeneratedValue注解的strategy属性提供四种值：

> -AUTO主键由程序控制, 是默认选项 ,不设置就是这个
>
> -IDENTITY 主键由数据库生成, 采用数据库自增长, Oracle不支持这种方式
>
> -SEQUENCE 通过数据库的序列产生主键, MYSQL  不支持

### 3、有两种方式可以扫描文件

##### （1）新建配置扫描类文件

MyBatisConfig.class：

```
package com.lkt.Professional.mapper.mybatis;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import org.springframework.context.annotation.Bean;
public class MyBatisConfig {
	@Bean(name = "sqlSessionFactory")
	public SqlSessionFactory sqlSessionFactoryBean(){
		SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
	//  bean.setDataSource(dataSource());
		bean.setTypeAliasesPackage("com.lkt.Professional.entity");
		try {
		//基于注解扫描Mapper，不需配置xml路径
	        //bean.setMapperLocations(resolver.getResources("classpath:mappers/*.xml"));
			return bean.getObject();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			throw new RuntimeException(e);
		}
	}
}
```

MyBatisMapperScannerConfig.class：

```
package com.lkt.Professional.mapper.mybatis;
import java.util.Properties;
import org.springframework.boot.autoconfigure.AutoConfigureAfter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.lkt.Professional.MyMappers.MyMapper;
import tk.mybatis.spring.mapper.MapperScannerConfigurer;
@Configuration
//必须在MyBatisConfig注册后再加载MapperScannerConfigurer，否则会报错
@AutoConfigureAfter(MyBatisConfig.class)
public class MyBatisMapperScannerConfig {
	@Bean
	public MapperScannerConfigurer mapperScannerConfigurer(){
		MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
		mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactory");
		mapperScannerConfigurer.setBasePackage("com.lkt.Professional.mapper.mybatis");	
		Properties properties = new Properties();
	    properties.setProperty("mappers", MyMapper.class.getName());//MyMapper这个类接下来会创建
	    properties.setProperty("notEmpty", "false");
	    properties.setProperty("IDENTITY", "MYSQL");
	    //特别注意mapperScannerConfigurer的引入import tk.mybatis.spring.mapper.MapperScannerConfigurer;引入错误则没下面这个方法	
	    mapperScannerConfigurer.setProperties(properties);
	    return mapperScannerConfigurer;
	}
}
```

##### （2）在启动类中设置扫描

```
package com.java.aney;

import javax.sql.DataSource;

import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionFactoryBean;
import tk.mybatis.spring.annotation.MapperScan;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.web.servlet.ServletComponentScan;
import org.springframework.context.annotation.Bean;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;


@SpringBootApplication
@ServletComponentScan //使用注解注册Servlet
@MapperScan("com.java.aney.mapper") //通过使用@MapperScan可以指定要扫描的Mapper类的包的路径
public class Application {
	private static Logger logger = LoggerFactory.getLogger(Application.class);

	protected SpringApplicationBuilder configure(
			SpringApplicationBuilder application) {
		return application.sources(Application.class);
	}

	@Bean
	@ConfigurationProperties(prefix = "spring.datasource")
	public DataSource dataSource() {
		return new org.apache.tomcat.jdbc.pool.DataSource();
	}

	@Bean
	public SqlSessionFactory sqlSessionFactoryBean() throws Exception {
		SqlSessionFactoryBean sqlSessionFactoryBean = new SqlSessionFactoryBean();
		sqlSessionFactoryBean.setDataSource(dataSource());
		PathMatchingResourcePatternResolver resolver = new PathMatchingResourcePatternResolver();
		sqlSessionFactoryBean.setMapperLocations(resolver
				.getResources("classpath:/mybatis/*.xml"));
		// 加载全局的配置文件
		sqlSessionFactoryBean.setConfigLocation(
                new DefaultResourceLoader().getResource("classpath:mybatis-config.xml"));
		return sqlSessionFactoryBean.getObject();
	}

	public static void main(String[] args) {
		SpringApplication.run(Application.class);
		logger.info("服务成功启动");
	}
}
```

### 4、新建公共父类BaseService

BaseService：（把BaseService文件存放在mapper文件夹的同级目录或者上级目录，如果扫描到了BaseService会出现报错）

```
package com.java.aney.service;

import java.util.List;

import com.github.pagehelper.PageInfo;
import com.java.aney.model.QueryExample;

import tk.mybatis.mapper.entity.Example;

public interface BaseServices<T, ID> {

    /**
     * 保存一个实体，null的属性不会保存，会使用数据库默认值
     *
     * @param t
     * @return
     */
    Integer add(T t);

    /**
     * 保存一个list实体，null的属性不会保存，会使用数据库默认值
     *
     * @param list
     * @return
     */
    Integer batchAdd(List<T> list);

    /**
     * 根据id删除
     *
     * @param id
     * @return
     */
    Integer deleteById(ID id);

    /**
     * 根据实体属性作为条件进行删除，查询条件使用等号
     *
     * @param t
     * @return
     */
    Integer delete(T t);

    /**
     * 根据主键更新属性不为null的值
     *
     * @param t
     * @return
     */
    Integer updateByPrimaryKey(T t);

    /**
     * 根据主键更新属性不为null的值
     *
     * @param list
     * @return
     */
    Integer batchUpdateByPrimaryKey(List<T> list);

    /**
     * 根据实体中的属性进行查询，只能有一个返回值，有多个结果是抛出异常，查询条件使用等号
     *
     * @param t
     * @return
     */
    T findOne(T t);

    /**
     * 查询全部结果
     *
     * @return
     */
    List<T> findAll();

    /**
     * 根据主键查询
     *
     * @param id
     * @return
     */
    T findById(ID id);

    /**
     * 根据实体中的属性值进行查询，查询条件使用等号
     *
     * @param t
     * @return
     */
    List<T> find(T t);

    /**
     * 根据Example条件更新实体`record`包含的不是null的属性值
     *
     * @return
     */
    Integer updateByExampleSelective(QueryExample<T> queryExample);

    /**
     * 根据实体中的属性值进行分页查询，查询条件使用等号
     *
     * @param t
     * @param pageNum
     * @param pageSize
     * @return
     */
    PageInfo<T> findPage(T t, Integer pageNum, Integer pageSize);

    List<T> findByExample(Example example);

    /**
     * 根据query条件更新record数据
     *
     * @param record 要更新的数据
     * @param query  查询条件
     * @return
     */
    Integer updateByExampleSelective(T record, Example query);

    /**
     * 根据query条件更新record数据
     *
     * @param record 要更新的数据
     * @param query  查询条件
     * @return
     */
    Integer updateByExampleSelective(T record, T query);

    /**
     * 查询数量
     *
     * @param record
     * @return
     */
    Integer findCount(T record);

    /**
     * 查询数量
     *
     * @param query
     * @return
     */
    Integer findCountByExample(Example query);
}
```

### 5、新建公共封装SQL语句条件类

```
package com.java.aney.model;

public class QueryExample<T> {

    //    @ApiModelProperty(value = "将查询到的数据更新成实体非null属性")
    private T record;
    //    @ApiModelProperty(value = "example查询条件")
    private Object example;

    public T getRecord() {
        return record;
    }

    public void setRecord(T record) {
        this.record = record;
    }

    public Object getExample() {
        return example;
    }

    public void setExample(Object example) {
        this.example = example;
    }
}
```

### 6、新建BaseServicesImpl实现父类BaseService

```
package com.java.aney.service;

public abstract class BaseServicesImpl<T, ID> implements BaseServices<T, ID> {

    protected final Logger logger = LoggerFactory.getLogger(getClass());

    public abstract Mapper<T> getMapper();

    @Override
    @Transactional(rollbackFor = Exception.class) //事务回滚
    public Integer add(T t) {
        return getMapper().insertSelective(t); //封装单表操作方法
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public Integer deleteById(ID id) {
        return getMapper().deleteByPrimaryKey(id);
    }
    。。。
}
```

拓展：tk.mybatis单表条件拼装SQL

> 链接：[mybatis Example条件查询](https://www.cnblogs.com/grey-wolf/p/8435723.html)
>
> [tk mybatis update 各种类型](https://blog.csdn.net/tengdazhang770960436/article/details/80889370)

demo见方法如下：

```
//分页查询1
        @RequestMapping(value="bootgridpage",produces="application/json;charset=UTF-8")
        @ResponseBody
        public BootgridPageInfoSet fenye(int current,int rowCount,String sort,String nane,String ph ){          
            PageHelper.startPage(current,rowCount);//分页
            Example example = new Example(CcompareccicModel.class); //定义对象CcompareccicModel
            String by=Jsonutil.getsortby(sort);//解析字段
            example.setOrderByClause(by);   //排序那个字段
            Example.Criteria criteria = example.createCriteria();//拼接SQL条件语句
                 if (StringUtil.isNotEmpty(nane)) {
                     criteria.andLike("xm", "%" + nane + "%");
                 }
        // criteria.andEqualTo("xm", "崔颖");//条件相等
        // criteria.andGreaterThan("xb", "1");//大于
        // criteria.andLessThan("xb", "2");//小于
        // criteria.andIsNotNull("xm");//is not null
        // criteria.andCondition("xzdqh=","110104");//加各种条件都可以 = like <,可以代替全部的
        // List<String> values=new ArrayList<String>();
        // values.add("110104");
        // criteria.andIn("xzdqh", values);//in()
        // criteria.andBetween("csrq", "1956/01/08", "1966/10/21");//时间相隔
        // Example.Criteria criteria2 = example.createCriteria();
        // criteria2.andCondition("xzdqh=","220104");
        // example.or().andCondition("xzdqh=","220104");//or
        // example.or(criteria2);//or
            List<CcompareccicModel> list=service.selectByExample(example);  
            new BootgridPageInfoSet<CcompareccicModel>(list);
            return new BootgridPageInfoSet<CcompareccicModel>(list);
        }
```

### 7、新建子类UserService继承BaseServicesImpl<AccountUser, Integer>，并重写方法

```
@Service("userService")
public class UserService extends BaseServicesImpl<User, Integer> {

    @Resource
	private UserMapper userMapper;
    
    @Override
	public Mapper<AccountUser> getMapper() {
		return userMapper;
	}

    public AccountUser queryUserName(String userName) {
		AccountUser user = userMapper.selectUserName(userName);
		return user;
	}
    。。。
}

```

### 8、新建mapper接口继承父接口Mapper<T>

```
@Repository
public interface UserMapper extends Mapper<User> {

    /**
	 * 通过用户昵称查询用户信息
	 * @param userName
	 * @return
	 */
	public User selectUserName(String userName);
}
```

**拓展：Mapper接口的声明如下，可以看到Mapper接口实现了所有常用的方法：**

```
public interface Mapper<T> extends
        BaseMapper<T>,
        ExampleMapper<T>,
        RowBoundsMapper<T>,
        Marker {

}
```

### 9、新建mapper.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.lkt.Professional.UserMapper">
    <resultMap id="BaseResultMap" type="com.model.User">
        <id column="id" jdbcType="VARCHAR" property="id"/>
        <result column="code" jdbcType="VARCHAR" property="code"/>
        <result column="user_name" jdbcType="INTEGER" property="UserName"/>
        <result column="initime" jdbcType="TIMESTAMP" property="initime"/>
        <association property="userIdMap" column="user_id" foreignColumn="id" notNullColumn="user_name" javaType="map">
            <id column="id" property="id"/>
            <result column="user_name" property="name"/>
        </association>
    </resultMap>

    <select id="getUserDetail" resultMap="BaseResultMap" parameterType="String">
        
    </select>
</mapper>
```

**注意：右击application跑起来，如果报出有关mysql或者sql语句的错误**

（1）检查application.properties文件数据库配置是否正确；

（2）检查bean（实体类）的类名是否与数据库表名一致，不一致是否添加@Table(name = "表名")注解声明；

（3）检查bean的变量名是否与该表名的列名一致，不一致是否添加@Column(name = "列名")注解声明。