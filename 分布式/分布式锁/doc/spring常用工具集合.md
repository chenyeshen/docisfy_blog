

jar包位置 spring-core.jar

### 1.访问文件资源

假设有一个文件地位于 Web 应用的类路径下，您可以通过以下方式对这个文件资源进行访问：

```
FileSystemResource 以文件系统绝对路径的方式进行访问；
ClassPathResource 以类路径的方式进行访问；
ServletContextResource 以相对于 Web 应用根目录的方式进行访问。
ResourceUtils 它支持“classpath:”和“file:”的地址前缀，它能够从指定的地址加载文件资源，常用方法：getFile()

```

### 2.本地化文件资源

```
LocalizedResourceHelper 允许通过文件资源基名和本地化实体获取匹配的本地化文件资源并以 Resource 对象返回

```

### 3.文件操作

```
FileCopyUtils，它提供了许多一步式的静态操作方法，能够将文件内容拷贝到一个目标 byte[]、String 甚至一个输出流或输出文件中。

```

### 4.属性文件操作

```
PropertiesLoaderUtils 允许您直接通过基于类路径的文件地址加载属性资源
```

### 5.特殊编码的资源

```
EncodedResource  当您使用 Resource 实现类加载文件资源时，它默认采用操作系统的编码格式。如果文件资源采用了特殊的编码格式（如 UTF-8），则在读取资源内容时必须事先通过 EncodedResource 指定编码格式，否则将会产生中文乱码的问题。
```

### 6.操作 Servlet API 的工具类

```
WebApplicationContextUtils 工具类获取 WebApplicationContext 对象
WebApplicationContext wac =WebApplicationContextUtils.getRequiredWebApplicationContext(ServletContext sc);
```

### 7.WebUtils

```
主要方法：

(1).getCookie(HttpServletRequest request, String name)	获取 HttpServletRequest 中特定名字的 Cookie 对象。如果您需要创建 Cookie， Spring 也提供了一个方便的 CookieGenerator 工具类；
(2).getSessionAttribute(HttpServletRequest request, String name)	获取 HttpSession 特定属性名的对象，否则您必须通过 request.getHttpSession.getAttribute(name) 完成相同的操作；
(3).getRequiredSessionAttribute(HttpServletRequest request, String name)	和上一个方法类似，只不过强制要求 HttpSession 中拥有指定的属性，否则抛出异常；
(4).getSessionId(HttpServletRequest request)	获取 Session ID 的值；
void exposeRequestAttributes(ServletRequest request, Map attributes)	将 Map 元素添加到 ServletRequest 的属性列表中，当请求被导向（forward）到下一个处理程序时，这些请求属性就可以被访问到了；
```

### 8.延迟加载过滤器

```
OpenSessionInViewFilter 过滤器将 Hibernate Session 绑定到请求线程中，它将自动被 Spring 的事务管理器探测到。所以 OpenSessionInViewFilter 适用于 Service 层使用 HibernateTransactionManager 或 JtaTransactionManager 进行事务管理的环境，也可以用于非事务只读的数据操作中。
```

### 9.中文乱码过滤器

```
CharacterEncodingFilter 当通过表单向服务器提交数据时，一个经典的问题就是中文乱码问题。虽然我们所有的 JSP 文件和页面编码格式都采用 UTF-8，但这个问题还是会出现。解决的办法很简单，我们只需要在 web.xml 中配置一个 Spring 的编码转换过滤器就可以了
```

### 10.请求跟踪日志过滤器

```
ServletContextRequestLoggingFilter 在日志级别为 DEBUG 时才会起作用
```

### 11.监听器配置

```
WebAppRootListener 
Log4J 监听器 Log4jConfigListener 
缓存清除监听器 IntrospectorCleanupListener 
```

### 12.特殊字符转义

```
HTML 特殊字符转义
HtmlUtils  常用方法 htmlEscape(),htmlUnescape()
JavaScript 特殊字符转义
JavaScriptUtils 常用方法：javaScriptEscape
SQL特殊字符转义 （引入 jakarta commons lang 类包）
StringEscapeUtils 常用方法： escapeSql
```

### 13.方法入参检测工具类

```
Assert  常用方法：notNull(Object object)/notNull(Object object, String message) 
isNull(Object object)/isNull(Object object, String message)，
isTrue(boolean expression) / isTrue(boolean expression, String message)	
notEmpty(Collection collection) / notEmpty(Collection collection, String message)	
notEmpty(Map map) / notEmpty(Map map, String message) 和 notEmpty(Object[] array, String message) / notEmpty(Object[] array, String message)；
hasLength(String text) / hasLength(String text, String message)；
hasText(String text) / hasText(String text, String message；
isInstanceOf(Class clazz, Object obj) / isInstanceOf(Class type, Object obj, String message)	如果 obj 不能被正确造型为 clazz 指定的类将抛出异常；
isAssignable(Class superType, Class subType) / isAssignable(Class superType, Class subType, String message)	subType 必须可以按类型匹配于 superType，否则将抛出异常；
```

### 14.请求工具类 ServletRequestUtils

```
//取请求参数的整数值：
public static Integer getIntParameter(ServletRequest request, String name)
public static int getIntParameter(ServletRequest request, String name, int defaultVal) -->单个值
public static int[] getIntParameters(ServletRequest request, String name) -->数组
还有譬如long、float、double、boolean、String的相关处理方法。
```

```
字符串工具类 org.springframework.util.StringUtils
首字母大写： public static String capitalize(String str)
首字母小写：public static String uncapitalize(String str)
判断字符串是否为null或empty： public static boolean hasLength(String str)
判断字符串是否为非空白字符串(即至少包含一个非空格的字符串)：public static boolean hasText(String str)
获取文件名：public static String getFilename(String path) 如e.g. "mypath/myfile.txt" -> "myfile.txt"
获取文件扩展名：public static String getFilenameExtension(String path) 如"mypath/myfile.txt" -> "txt"
还有譬如数组转集合、集合转数组、路径处理、字符串分离成数组、数组或集合合并为字符串、数组合并、向数组添加元素等。
```



### 15.集合工具类 CollectionUtils

```
判断集合是否为空 isEmpty
```

### 16.对象序列化与反序列化 SerializationUtils

```
public static byte[] serialize(Object object)
public static Object deserialize(byte[] bytes)
```

### 17.数字处理 org.springframework.util.NumberUtils

字符串转换为Number并格式化，包括具体的Number实现类，如Long、Integer、Double，字符串支持16进制字符串，并且会自动去除字符串中的空格：
    public static <T extends Number> T parseNumber(String text, Class<T> targetClass)
    public static <T extends Number> T parseNumber(String text, Class<T> targetClass, NumberFormat numberFormat)
各种Number中的转换，如Long专为Integer，自动处理数字溢出（抛出异常）：
public static <T extends Number> T convertNumberToTargetClass(Number number, Class<T> targetClass)


### 18.目录复制

```
org.springframework.util.FileSystemUtils 递归复制、删除一个目录
```



### 19.MD5加密DigestUtils

```
字节数组的MD5加密 public static String md5DigestAsHex(byte[] bytes)
```

### xml工具

```
org.springframework.util.xml.AbstractStaxContentHandler
org.springframework.util.xml.AbstractStaxXMLReader
org.springframework.util.xml.AbstractXMLReader
org.springframework.util.xml.AbstractXMLStreamReader
org.springframework.util.xml.DomUtils
org.springframework.util.xml.SimpleNamespaceContext
org.springframework.util.xml.SimpleSaxErrorHandler
org.springframework.util.xml.SimpleTransformErrorListener
org.springframework.util.xml.StaxUtils
org.springframework.util.xml.TransformerUtils
```

### 其它工具集

```
org.springframework.util.AntPathMatcherant 风格的处理
org.springframework.util.AntPathStringMatcher
org.springframework.util.Assert 断言,在我们的参数判断时应该经常用
org.springframework.util.CachingMapDecorator
org.springframework.util.ClassUtils 用于Class的处理
org.springframework.util.CollectionUtils 用于处理集合的工具
org.springframework.util.CommonsLogWriter
org.springframework.util.CompositeIterator
org.springframework.util.ConcurrencyThrottleSupport
org.springframework.util.CustomizableThreadCreator
org.springframework.util.DefaultPropertiesPersister
org.springframework.util.DigestUtils 摘要处理, 这里有用于md5处理信息的
org.springframework.util.FileCopyUtils 文件的拷贝处理, 结合Resource的概念一起来处理, 真的是很方便
org.springframework.util.FileSystemUtils
org.springframework.util.LinkedCaseInsensitiveMap key值不区分大小写的LinkedMap
org.springframework.util.LinkedMultiValueMap 一个key可以存放多个值的LinkedMap
org.springframework.util.Log4jConfigurer 一个log4j的启动加载指定配制文件的工具类
org.springframework.util.NumberUtils 处理数字的工具类, 有parseNumber 可以把字符串处理成我们指定的数字格式, 还支持format格式, convertNumberToTargetClass 可以实现Number类型的转化. 
org.springframework.util.ObjectUtils 有很多处理null object的方法. 如nullSafeHashCode, nullSafeEquals, isArray, containsElement, addObjectToArray, 等有用的方法
org.springframework.util.PatternMatchUtils spring里用于处理简单的匹配. 如 Spring's typical &quot;xxx*&quot;, &quot;*xxx&quot; and &quot;*xxx*&quot; pattern styles
org.springframework.util.PropertyPlaceholderHelper 用于处理占位符的替换
org.springframework.util.ReflectionUtils 反映常用工具方法. 有 findField, setField, getField, findMethod, invokeMethod等有用的方法
org.springframework.util.SerializationUtils 用于java的序列化与反序列化. serialize与deserialize方法
org.springframework.util.StopWatch 一个很好的用于记录执行时间的工具类, 且可以用于任务分阶段的测试时间. 最后支持一个很好看的打印格式. 这个类应该经常用
org.springframework.util.xSystemPropertyUtils
org.springframework.util.TypeUtils 用于类型相容的判断. isAssignable
org.springframework.util.WeakReferenceMonitor 弱引用的监控 
```

### web相关的工具

```
org.springframework.web.util.CookieGenerator
org.springframework.web.util.HtmlCharacterEntityDecoder
org.springframework.web.util.HtmlCharacterEntityReferences
org.springframework.web.util.HtmlUtils
org.springframework.web.util.HttpUrlTemplate 这个类用于用字符串模板构建url, 它会自动处理url里的汉字及其它相关的编码. 在读取别人提供的url资源时, 应该经常用 String url = &quot;http://localhost/myapp/{name}/{id}&quot;
org.springframework.web.util.JavaScriptUtils
org.springframework.web.util.Log4jConfigListener 用listener的方式来配制log4j在web环境下的初始化
org.springframework.web.util.UriTemplate
org.springframework.web.util.UriUtils 处理uri里特殊字符的编码
org.springframework.web.util.WebUtils
```

### SpringUtil工具类

```
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.context.ApplicationEvent;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import java.util.Map;

/**

- Spring工具类
  */
  @Slf4j
  @Component
  public class SpringUtil implements ApplicationContextAware {

  /**

  - spring全局配置项
    */
    private static ApplicationContext applicationContext;

  @Override
  public void setApplicationContext(ApplicationContext context) throws BeansException {

  ```
  if (applicationContext == null) {
      applicationContext = context;
      log.info("ApplicationContext init success,you can invoke by SpringUtil.getApplicationContext() to get ApplicationContext,init bean count="
              + applicationContext.getBeanDefinitionCount() + ",bean=" + JSONObject.toJSONString(applicationContext.getBeanDefinitionNames()));
  }
  ```

  }

  /**

  - @return spring全局配置项
    */
    public static ApplicationContext getApplicationContext() {
    return applicationContext;
    }

  /**

  - 通过name获取 Bean.
    *
  - @param name
  - @return
    */
    public static <T> T getBean(String name) {
    return (T) applicationContext.getBean(name);
    }

  /**

  - 通过class获取Bean.
    *
  - @param clazz
  - @return
    */
    public static <T> T getBean(Class<T> clazz) {
    return applicationContext.getBean(clazz);
    }

  /**

  - 通过name,以及Clazz返回指定的Bean
    *
  - @param name
  - @param clazz
  - @return
    */
    public static <T> T getBean(String name, Class<T> clazz) {
    return applicationContext.getBean(name, clazz);
    }

  /**

  - 获取实现相关接口的类关系
    *
  - @param clazz
  - @return
    */
    public static <T> Map<String, T> getBeansOfType(Class<T> clazz) {
    return applicationContext.getBeansOfType(clazz);
    }

  /**

  - 发布事件
    *
  - @param event
    */
    public static void publishEvent(ApplicationEvent event) {
    applicationContext.publishEvent(event);
    }

  /**

  - 获取环境信息
    */
    public static Environment getEnvironment() {
    return applicationContext.getEnvironment();
    }

}


```



### 