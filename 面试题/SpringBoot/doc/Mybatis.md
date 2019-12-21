# Mybatis

#### 1. mybatis如何获取自动生成的(主)键值?

答：对于支持自增主键的数据库：useGenerateKeys和keyProperty。示例:
<insert id="insertName" useGeneratedKeys="true" keyProperty="id">  
   insert into names (name) values (#{name})  
</insert>  

#### 2. Mybatis是如何进行分页的？分页插件的原理是什么？

答： (1)Mybatis使用RowBounds对象进行分页，也可以直接编写sql实现分页，也可以使用Mybatis的分页插件。

(2)分页插件的原理：实现Mybatis提供的接口，实现自定义插件，在插件的拦截方法内拦截待执行的sql，然后重写sql。

举例：select * from student，拦截sql后重写为：select t.* from （select * from student）t limit 0，10

#### 3. mybatis中如何实现自定义插件拦截器

答：(1)Mybatis配置文件中配置拦截器插件

<plugins> <plugin interceptor="com.github.pagehelper.PageInterceptor">  </plugin></plugins>

(2). 创建拦截器：

@Intercepts({@Signature(type=ResultSetHandler.class,method="handleResultSets",args=Statement.class)})

public class Myinterceptor1 implements Interceptor{

​	public Object intercept(Invocation invocation) throws Throwable {

​		return  invocation.proceed();

​	}

​	public Object plugin(Object target) {}

​	public void setProperties(Properties properties) {}

}

#### 4. 在mapper中如何传递多个参数？

答：(1).直接在方法中传递参数，xml文件用#{0} #{1}来获取

(2).使用 @param 注解:这样可以直接在xml文件中通过#{name}来获取

#### 5. 使用MyBatis的mapper接口调用有哪些要求

答：(1).Mapper接口方法名和mapper.xml中定义的每个sql的id相同

(2).Mapper接口中输入的参数类型和mapper.xml中定义的每个sql的ParameterType相同

(3).Mapper接口中输出的参数类型和mapper.xml中定义的每个sql的resultType相同

(4).Mapper.xml文件中的namespace即是接口的类路径

#### 6. Statement和PrepareStatement的区别

答： PreparedStatement：表示预编译的 SQL 语句的对象。

PrepareStatement可以使用占位符，是预编译的，批处理比Statement效率高

在对数据库只执行一次性存取的时侯，用 Statement 对象进行处理。

PreparedStatement的第一次执行消耗是很高的. 它的性能体现在后面的重复执行

#### 7. resultType resultMap的区别？

答：类的名字和数据库相同时，可以直接设置resultType参数为Pojo类

若不同，需要设置resultMap 将结果名字和Pojo名字进行转换

#### 8. Mybatis配置一对多？

<collection property="topicComment" column="id" ofType="com.tmf.bbs.pojo.Comment" select="selectComment" />

property：属性名

column：共同列

ofType：集合中元素的类型

select：要连接的查询

 

#### 9. Mybatis配置一对一？

```
<association property="topicType" select="selectType" column="topics_type_id" javaType="com.tmf.bbs.pojo.Type"/>
```

property：属性名

select：要连接的查询

column：共同列

javaType：集合中元素的类型

#### 10. ${} 和 #{}的区别？

${}：简单字符串替换，把${}直接替换成变量的值，不做任何转换，这种是取值以后再去编译SQL语句。

\#{}：预编译处理，sql中的#{}替换成？，补全预编译语句，有效的防止Sql语句注入，这种取值是编译好SQL语句再取值。
总结：一般用#{}来进行列的代替