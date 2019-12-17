---
layout:     post
title:      Spring 学习笔记
subtitle:   学习笔记
date:       2017-11-16
author:     chenyeshen
header-img: img/bg8.jpg
catalog: true
tags:
    - Java
    - Spring
    - 学习笔记
---

#  Spring_day01总结

### **今日内容**

l Spring框架的概述

l Spring的快速入门

l Spring 工厂接口

l 在MyEclipse 配置Spring的xml文件提示

l IoC容器装配Bean（xml配置方式）

l Ioc容器装配Bean（注解方式）

l 在web项目中集成Spring

l Spring 整合 junit4 测试 

## 1.1 **Spring框架学习路线:**

Spring的Ioc

Spring的AOP , AspectJ

Spring的事务管理 , 三大框架的整合.

## 1.2 **Spring框架的概述:**

### 1.2.1 **什么是Spring:**

Spring是分层的JavaSE/EE full-stack(一站式) 轻量级开源框架

\* 分层:

\* SUN提供的EE的三层结构:web层、业务层、数据访问层（持久层，集成层）

\* Struts2是web层基于MVC设计模式框架.

\* Hibernate是持久的一个ORM的框架.

\* 一站式:

\* Spring框架有对三层的每层解决方案:

\* web层:Spring MVC.

\* 持久层:JDBC Template 

\* 业务层:Spring的Bean管理.

 

### 1.2.2 **Spring的核心:**

IOC:（Inverse of Control 反转控制）

\* 控制反转:将对象的创建权,交由Spring完成.

AOP:Aspect Oriented Programming 是 面向对象的功能延伸.不是替换面向对象,是用来解决OO中一些问题.

 

IOC:控制反转.

### 1.2.3 **Spring的版本:**

Spring3.x和Spring4.x  Spring4需要整合hibernate4.

### 1.2.4 **EJB:企业级JavaBean**

EJB:SUN公司提出EE解决方案.

 

2002 : Expert One-to-One J2EE Design and Development 

2004 : Expert One-to-One J2EE Development without EJB (EE开发真正需要使用的内容.)

### 1.2.5 **Spring优点:**

方便解耦，简化开发

\* Spring就是一个大工厂，可以将所有对象创建和依赖关系维护，交给Spring管理

AOP编程的支持

\* Spring提供面向切面编程，可以方便的实现对程序进行权限拦截、运行监控等功能

声明式事务的支持

\* 只需要通过配置就可以完成对事务的管理，而无需手动编程

方便程序的测试

\* Spring对Junit4支持，可以通过注解方便的测试Spring程序

方便集成各种优秀框架

\* Spring不排斥各种优秀的开源框架，其内部提供了对各种优秀框架（如：Struts、Hibernate、MyBatis、Quartz等）的直接支持

降低JavaEE API的使用难度

\* Spring 对JavaEE开发中非常难用的一些API（JDBC、JavaMail、远程调用等），都提供了封装，使这些API应用难度大大降低

## 1.3 **Spring的入门的程序:**

### 1.3.1 **下载Spring的开发包:**

spring-framework-3.2.0.RELEASE-dist.zip				---Spring开发包

\* docs		:spring框架api和规范

\* libs		:spring开发的jar包

\* schema		:XML的约束文档.

spring-framework-3.0.2.RELEASE-dependencies.zip		---Spring开发中的依赖包

### 1.3.2 **创建web工程引入相应jar包:**

spring-beans-3.2.0.RELEASE.jar

spring-context-3.2.0.RELEASE.jar

spring-core-3.2.0.RELEASE.jar

spring-expression-3.2.0.RELEASE.jar

开发的日志记录的包:

com.springsource.org.apache.commons.logging-1.1.1.jar		--- 用于整合其他的日志的包(类似Hibernate中slf4j)

com.springsource.org.apache.log4j-1.2.15.jar

### 1.3.3 **创建Spring的配置文件:**

在src下创建一个applicationContext.xml

引入XML的约束:

\* 找到xsd-config.html.引入beans约束:

<beans xmlns="http://www.springframework.org/schema/beans"

​       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

​       xsi:schemaLocation="

http://www.springframework.org/schema/beans [" >http://www.springframework.org/schema/beans/spring-beans.xsd">](http://www.springframework.org/schema/beans/spring-beans.xsd\)

 

### 1.3.4 **在配置中配置类:**

<bean id="userService" class="cn.itcast.spring3.demo1.HelloServiceImpl"></bean>

### 1.3.5 **创建测试类****:**

​	@Test

​	// Spring开发

​	public void demo2() {

​		// 创建一个工厂类.

​		ApplicationContext applicationContext = new ClassPathXmlApplicationContext(

​				"applicationContext.xml");

​		HelloService helloService = (HelloService) applicationContext.getBean("userService");

​		helloService.sayHello();

​	}

### 1.3.6 **IOC和DI(\*****)区别?**

IOC:控制反转:将对象的创建权,由Spring管理.

DI:依赖注入:在Spring创建对象的过程中,把对象依赖的属性注入到类中.

\* 面向对象中对象之间的关系;

\* 依赖:

public class A{

private B b;

}

\* 继承:is a

\* 聚合:

\* 聚集:

\* 组合:

### 1.3.7 **Spring框架加载配置文件:**

ApplicationContext 应用上下文，加载Spring 框架配置文件

加载classpath：

​     new ClassPathXmlApplicationContext("applicationContext.xml");		:加载classpath下面配置文件.

加载磁盘路径：

​     new FileSystemXmlApplicationContext("applicationContext.xml");		:加载磁盘下配置文件.

### 1.3.8 **BeanFactory与ApplicationContext区别?**

ApplicationContext类继承了BeanFactory.

BeanFactory在使用到这个类的时候,getBean()方法的时候才会加载这个类.

ApplicationContext类加载配置文件的时候,创建所有的类.

ApplicationContext对BeanFactory提供了扩展:

\* 国际化处理

\* 事件传递

\* Bean自动装配

\* 各种不同应用层的Context实现

***** 早期开发使用BeanFactory.

### 1.3.9 **MyEclipse配置XML提示:**

Window--->xml catalog--->add 找到schema的位置 ,将复制的路径 copy指定位置,选择schema location.

## 1.4 **IOC装配Bean:**

### 1.4.1 **Spring框架Bean实例化的方式:**

提供了三种方式实例化Bean.

*** 构造方法实例化:(默认无参数)**

\* 静态工厂实例化:

\* 实例工厂实例化:

#### **无参数构造方法的实例化:**

​	<!-- 默认情况下使用的就是无参数的构造方法. -->

​	<bean id="bean1" class="cn.itcast.spring3.demo2.Bean1"></bean>

 

#### **静态工厂实例化:**

​	<!-- 第二种使用静态工厂实例化 -->

​	<bean id="bean2" class="cn.itcast.spring3.demo2.Bean2Factory" factory-method="getBean2"></bean>

#### **实例工厂实例化****:**

​	<!-- 第三种使用实例工厂实例化 -->

​	<bean id="bean3" factory-bean="bean3Factory" factory-method="getBean3"></bean>

​	<bean id="bean3Factory" class="cn.itcast.spring3.demo2.Bean3Factory"/>

 

### 1.4.2 **Bean的其他配置:**

#### **id和name的区别:**

id遵守XML约束的id的约束.id约束保证这个属性的值是唯一的,而且必须以字母开始，可以使用字母、数字、连字符、下划线、句话、冒号

name没有这些要求

***** 如果bean标签上没有配置id,那么name可以作为id.

***** 开发中Spring和Struts1整合的时候, /login.

<bean name=”/login” class=””>

 

现在的开发中都使用id属性即可.

#### **类的作用范围:**

scope属性 :

*** singleton**		**:单例的.(默认的值.)**

*** prototype**		**:多例的.**

\* request		:web开发中.创建了一个对象,将这个对象存入request范围,request.setAttribute();

\* session		:web开发中.创建了一个对象,将这个对象存入session范围,session.setAttribute();

\* globalSession	:一般用于Porlet应用环境.指的是分布式开发.不是porlet环境,globalSession等同于session;

 

实际开发中主要使用singleton,prototype

 

#### **Bean的生命周期:**

配置Bean的初始化和销毁的方法:

配置初始化和销毁的方法:

\* init-method=”setup”

\* destroy-method=”teardown”

执行销毁的时候,必须手动关闭工厂,而且只对scope=”**singleton**”有效.

 

Bean的生命周期的11个步骤:

1.instantiate bean对象实例化

2.populate properties 封装属性

3.如果Bean实现BeanNameAware 执行 setBeanName

4.如果Bean实现BeanFactoryAware 或者 ApplicationContextAware 设置工厂 setBeanFactory 或者上下文对象 setApplicationContext

**5.如果存在类实现 BeanPostProcessor（后处理Bean） ，执行postProcessBeforeInitialization**

6.如果Bean实现InitializingBean 执行 afterPropertiesSet 

7.调用<bean init-method="init"> 指定初始化方法 init

**8.如果存在类实现 BeanPostProcessor（处理Bean） ，执行postProcessAfterInitialization**

9.执行业务处理

10.如果Bean实现 DisposableBean 执行 destroy

11.调用<bean destroy-method="customerDestroy"> 指定销毁方法 customerDestroy

 

在CustomerService类的add方法之前进行权限校验?

### 1.4.3 **Bean中属性注入:**

Spring支持构造方法注入和setter方法注入:

#### **构造器注入:**

​	<bean id="car" class="cn.itcast.spring3.demo5.Car">

​		<!-- <constructor-arg name="name" value="宝马"/>

​		<constructor-arg name="price" value="1000000"/> -->

​		<constructor-arg index="0" type="java.lang.String" value="奔驰"/>

​		<constructor-arg index="1" type="java.lang.Double" value="2000000"/>

​	</bean>

 

#### **setter方法注入:**

<bean id="car2" class="cn.itcast.spring3.demo5.Car2">

​		<!-- <property>标签中name就是属性名称,value是普通属性的值,ref:引用其他的对象 -->

​		<property name="name" value="保时捷"/>

​		<property name="price" value="5000000"/>

​	</bean>

#### **setter方法注入对象属性:**

<property name="car2" ref="car2"/>

#### **名称空间****p:注入属性:**

Spring2.5版本引入了名称空间p.

p:<属性名>="xxx" 引入常量值

p:<属性名>-ref="xxx" 引用其它Bean对象

 

引入名称空间:

<beans xmlns="http://www.springframework.org/schema/beans"

​	   **xmlns:p="http://www.springframework.org/schema/p"**

​       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"

​       xsi:schemaLocation="

http://www.springframework.org/schema/beans [" >http://www.springframework.org/schema/beans/spring-beans.xsd">](http://www.springframework.org/schema/beans/spring-beans.xsd\)

 

<bean id="car2" class="cn.itcast.spring3.demo5.Car2" p:name="宝马" p:price="400000"/>

<bean id="person" class="cn.itcast.spring3.demo5.Person" p:name="童童" p:car2-ref="car2"/>

 

#### **SpEL:属性的注入:**

Spring3.0提供注入属性方式:

语法：#{表达式}

<bean id="" value="#{表达式}">

 

<bean id="car2" class="cn.itcast.spring3.demo5.Car2">

​		<property name="name" value="#{'大众'}"></property>

​		<property name="price" value="#{'120000'}"></property>

​	</bean>

 

​	<bean id="person" class="cn.itcast.spring3.demo5.Person">

​		<!--<property name="name" value="#{personInfo.name}"/>-->

<property name="name" value="#{personInfo.showName()}"/>

​		<property name="car2" value="#{car2}"/>

​	</bean>

​	

​	<bean id="personInfo" class="cn.itcast.spring3.demo5.PersonInfo">

​		<property name="name" value="张三"/>

​	</bean>

 

### 1.4.4 **集合属性的注入:**

​	<bean id="collectionBean" class="cn.itcast.spring3.demo6.CollectionBean">

​		<!-- 注入List集合 -->

​		<property name="list">

​			<list>

​				<value>童童</value>

​				<value>小凤</value>

​			</list>

​		</property>

​		

​		<!-- 注入set集合 -->

​		<property name="set">

​			<set>

​				<value>杜宏</value>

​				<value>如花</value>

​			</set>

​		</property>

​		

​		<!-- 注入map集合 -->

​		<property name="map">

​			<map>

​				<entry key="刚刚" value="111"/>

​				<entry key="娇娇" value="333"/>

​			</map>

​		</property>

​		

​		<property name="properties">

​			<props>

​				<prop key="username">root</prop>

​				<prop key="password">123</prop>

​			</props>

​		</property>

​	</bean>

 

### 1.4.5 **加载配置文件:**

一种写法:

ApplicationContext applicationContext = new ClassPathXmlApplicationContext("bean1.xml",”bean2.xml”);

二种方法:

​	<import resource="applicationContext2.xml"/>

## 1.5 **IOC装配Bean(注解方式)**

### 1.5.1 **Spring的注解装配Bean**

Spring2.5 引入使用注解去定义Bean

@Component  描述Spring框架中Bean 

 

Spring的框架中提供了与@Component注解等效的三个注解:

@Repository 用于对DAO实现类进行标注

@Service 用于对Service实现类进行标注

@Controller 用于对Controller实现类进行标注

***** 三个注解为了后续版本进行增强的.

 

### 1.5.2 **Bean的属性注入:**

普通属性;

@Value(value="itcast")

​	private String info;

 

对象属性:

@Autowired:自动装配默认使用类型注入.

@Autowired

​	    @Qualifier("userDao")		--- 按名称进行注入.

 

@Autowired

​	    @Qualifier("userDao")		

private UserDao userDao;

等价于

@Resource(name="userDao")

​	private UserDao userDao;

### 1.5.3 **Bean其他的属性的配置:**

配置Bean初始化方法和销毁方法:

\* init-method 和 destroy-method.

@PostConstruct 初始化

@PreDestroy  销毁

 

配置Bean的作用范围:

@Scope

### 1.5.4 **Spring3.0提供使用Java类定义Bean信息的方法**

@Configuration

public class BeanConfig {

 

​	@Bean(name="car")

​	public Car showCar(){

​		Car car = new Car();

​		car.setName("长安");

​		car.setPrice(40000d);

​		return car;

​	}

​	

​	@Bean(name="product")

​	public Product initProduct(){

​		Product product = new Product();

​		product.setName("空调");

​		product.setPrice(3000d);

​		return product;

​	}

}

### 1.5.5 **实际开发中使用****XML还是注解?**

XML:

\* bean管理

注解;

\* 注入属性的时候比较方便.

 

两种方式结合;一般使用XML注册Bean,使用注解进行属性的注入.

 

<context:annotation-config/>

s

@Autowired

​	@Qualifier("orderDao")

​	private OrderDao orderDao;

 

## 1.6 **Spring整合web开发:**

正常整合Servlet和Spring没有问题的

但是每次执行Servlet的时候加载Spring配置,加载Spring环境.

\* 解决办法:在Servlet的init方法中加载Spring配置文件?

\* 当前这个Servlet可以使用,但是其他的Servlet的用不了了!!!

\* 将加载的信息内容放到ServletContext中.ServletContext对象时全局的对象.服务器启动的时候创建的.在创建ServletContext的时候就加载Spring的环境.

\* ServletContextListener:用于监听ServletContext对象的创建和销毁的.

 

导入;spring-web-3.2.0.RELEASE.jar

在web.xml中配置:

 <listener>

 	<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>

 </listener>

 

 <context-param>

 	<param-name>contextConfigLocation</param-name>

 	<param-value>classpath:applicationContext.xml</param-value>

 </context-param>

修改程序的代码:

WebApplicationContext applicationContext = WebApplicationContextUtils.getWebApplicationContext(getServletContext());

WebApplicationContext applicationContext = (WebApplicationContext) getServletContext().getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE);

## 1.7 **Spring集成JUnit测试:**

1.程序中有Junit环境.

2.导入一个jar包.spring与junit整合jar包.

\* spring-test-3.2.0.RELEASE.jar

3.测试代码:

@RunWith(SpringJUnit4ClassRunner.class)

@ContextConfiguration(locations="classpath:applicationContext.xml")

public class SpringTest {

​	@Autowired

​	private UserService userService;

​	

​	@Test

​	public void demo1(){

​		userService.sayHello();

​	}

}

**今天的内容总结****:**

Struts2:

Hibernate:知识点比较多.

Spring:AOP. 面向切面的思想.

Spring框架 IOC. AOP . 数据访问 . 集成 . Web

\* IOC:控制反转.将对象的创建权交给Spring.

\* DI:依赖注入.DI需要有IOC环境的,DI在创建对象的时候,将对象的依赖的属性,一并注入到类中.

**IOC装配Bean:(XML)**

*** <bean id=****””** **class=****””****/>**

*** 配置Bean其他的属性:**

*** init-method destroy-method scope**

 

*** DI注入属性:**

*** 普通属性:**

*** <property name=****”****属性名****”** **value=****”****属性值****”****>**

*** 对象属性:**

*** <property name=****”****属性名****”** **ref=****”****其他类的id或name****”****>**

 

*** 集合属性的注入:**

**IOC装配Bean:(注解)**

**@Component  描述Spring框架中Bean** 

**@Repository 用于对DAO实现类进行标注**

**@Service 用于对Service实现类进行标注**

**@Controller 用于对Controller实现类进行标注**

 

**DI属性注入**

*** 普通属性:**

*** @Value**

*** 对象属性:**

*** AutoWired**

*** Resource**

 

Bean的生命周期:

*** 后处理Bean.BeanPostProcessor类.**

 

**Spring整合Web项目:**

**Spring整合Junit测试:**







**Spring_day02总结**

**今日内容**

l AOP的概述

l AOP 的底层实现

l Spring 的AOP

l 使用AspectJ 实现AOP

l Spring JdbcTemplate 使用

## 1.1 **上次课的内容回顾:**

第一天:Spring的IOC.Spring就是一个大的工厂,通过工厂对Bean进行管理.

\* Spring的概述:

\* Spring的环境搭建:

\* Spring中的IOC:

\* IOC:控制反转.将对象的创建权交给Spring管理.

\* DI:依赖注入.在由Spring创建的对象的时候,将对象依赖的对象注入进来.

\* IOC的Bean装配(XML):

\* 定义类:

\* <bean id=”标识” class=”类的全路径”>

\* 其他的属性:

\* id和name:

\* id:满足XMLid约束语法,里面不能出现特殊的字符.

\* name:可以出现特殊的字符.

***** 如果配置<bean>标签的时候,如果只配置了name,就可以将这个name的值作为id.

\* scope:类的作用范围.

\* Bean的生命周期:

\* init-method:

\* destroy-method:

*** Bean的完整生命周期:**

*** 后处理Bean.增强**

\* 注入属性:

\* <property name=”” value=””>

\* <property name=”” ref=””>

\* IOC的Bean装配(注解):

\* 定义类:

\* 注入属性:

 

\* Spring框架与web整合.

\* Spring整合JUnit单元测试.

 

#   第二天Spring的AOP.JdbcTemplate.

## 1.2 **AOP的概述:**

### 1.2.1 **什么是AOP:**

 AOP Aspect Oriented Programing 面向切面编程

 AOP采取横向抽取机制，取代了传统纵向继承体系重复性代码（性能监视、事务管理、安全检查、缓存）

 Spring AOP使用纯Java实现，不需要专门的编译过程和类加载器，在运行期通过代理方式向目标类织入增强代码

 AspecJ是一个基于Java语言的AOP框架，Spring2.0开始，Spring AOP引入对Aspect的支持，AspectJ扩展了Java语言，提供了一个专门的编译器，在编译时提供横向代码的织入

### 1.2.2 **AOP底层原理;**

就是代理机制:

\* 动态代理:(JDK中使用)

\* JDK的动态代理,对实现了接口的类生成代理.

### 1.2.3 **Spring的AOP代理:**

JDK动态代理:对实现了接口的类生成代理

CGLib代理机制:对类生成代理

### 1.2.4 **AOP的术语:**

Joinpoint(连接点):所谓连接点是指那些被拦截到的点。在spring中,这些点指的是方法,因为spring只支持方法类型的连接点.

Pointcut(切入点):所谓切入点是指我们要对哪些Joinpoint进行拦截的定义.

Advice(通知/增强):所谓通知是指拦截到Joinpoint之后所要做的事情就是通知.通知分为前置通知,后置通知,异常通知,最终通知,环绕通知(切面要完成的功能)

Introduction(引介):引介是一种特殊的通知在不修改类代码的前提下, Introduction可以在运行期为类动态地添加一些方法或Field.

Target(目标对象):代理的目标对象

Weaving(织入):是指把增强应用到目标对象来创建新的代理对象的过程.

​	spring采用动态代理织入，而AspectJ采用编译期织入和类装在期织入

Proxy（代理）:一个类被AOP织入增强后，就产生一个结果代理类

Aspect(切面): 是切入点和通知（引介）的结合

## 1.3 **AOP的底层实现**

### 1.3.1 **JDK动态代理:**

public class JDKProxy implements InvocationHandler{

​	private UserDao userDao;

 

​	public JDKProxy(UserDao userDao) {

​		super();

​		this.userDao = userDao;

​	}

 

​	public UserDao createProxy() {

​		UserDao proxy = (UserDao) Proxy.newProxyInstance(userDao.getClass()

​				.getClassLoader(), userDao.getClass().getInterfaces(), this);

​		return proxy;

​	}

 

​	// 调用目标对象的任何一个方法 都相当于调用invoke();

​	public Object invoke(Object proxy, Method method, Object[] args)

​			throws Throwable {

​		if("add".equals(method.getName())){

​			// 记录日志:

​			System.out.println("日志记录=================");

​			Object result = method.invoke(userDao, args);

​			return result;

​		}

​		return method.invoke(userDao, args);

​	}

}

### 1.3.2 **CGLIB动态代理:**

CGLIB(Code Generation Library)是一个开源项目！是一个强大的，高性能，高质量的Code生成类库，它可以在运行期扩展Java类与实现Java接口。 Hibernate支持它来实现PO(Persistent Object 持久化对象)字节码的动态生成

Hibernate生成持久化类的javassist.

CGLIB生成代理机制:其实生成了一个真实对象的子类.

 

下载cglib的jar包.

\* 现在做cglib的开发,可以不用直接引入cglib的包.已经在spring的核心中集成cglib.

 

public class CGLibProxy implements MethodInterceptor{

​	private ProductDao productDao;

 

​	public CGLibProxy(ProductDao productDao) {

​		super();

​		this.productDao = productDao;

​	}

​	

​	public ProductDao createProxy(){

​		// 使用CGLIB生成代理:

​		// 1.创建核心类:

​		Enhancer enhancer = new Enhancer();

​		// 2.为其设置父类:

​		enhancer.setSuperclass(productDao.getClass());

​		// 3.设置回调:

​		enhancer.setCallback(this);

​		// 4.创建代理:

​		return (ProductDao) enhancer.create();

​	}

 

​	

​	public Object intercept(Object proxy, Method method, Object[] args,

​			MethodProxy methodProxy) throws Throwable {

​		if("add".equals(method.getName())){

​			System.out.println("日志记录==============");

​			Object obj = methodProxy.invokeSuper(proxy, args);

​			return obj;

​		}

​		return methodProxy.invokeSuper(proxy, args);

​	}

}

 

**结论:Spring框架,如果类实现了接口,就使用JDK的动态代理生成代理对象,如果这个类没有实现任何接口,使用CGLIB生成代理对象.**

## 1.4 **Spring中的AOP**

### 1.4.1 **Spring的传统AOP :**

AOP:不是由Spring定义.AOP联盟的组织定义.

Spring中的通知:(增强代码)

前置通知 org.springframework.aop.MethodBeforeAdvice

\* 在目标方法执行前实施增强

后置通知 org.springframework.aop.AfterReturningAdvice

\* 在目标方法执行后实施增强

环绕通知 org.aopalliance.intercept.MethodInterceptor

\* 在目标方法执行前后实施增强

异常抛出通知 org.springframework.aop.ThrowsAdvice

\* 在方法抛出异常后实施增强

引介通知 org.springframework.aop.IntroductionInterceptor(课程不讲.)

\* 在目标类中添加一些新的方法和属性

### 1.4.2 **Spring中的切面类型:**

Advisor : Spring中传统切面.

\* Advisor:都是有一个切点和一个通知组合.

\* Aspect:多个切点和多个通知组合.

 

Advisor : 代表一般切面，Advice本身就是一个切面，对目标类所有方法进行拦截(* 不带有切点的切面.针对所有方法进行拦截)

PointcutAdvisor : 代表具有切点的切面，可以指定拦截目标类哪些方法(带有切点的切面,针对某个方法进行拦截)

IntroductionAdvisor : 代表引介切面，针对引介通知而使用切面（不要求掌握）

 

### 1.4.3 **Spring的AOP的开发:**

#### **针对所有方法的增强:(不带有切点的切面)**

第一步:导入相应jar包.

\* spring-aop-3.2.0.RELEASE.jar

\* com.springsource.org.aopalliance-1.0.0.jar

 

第二步:编写被代理对象:

\* CustomerDao接口

\* CustoemrDaoImpl实现类

 

第三步:编写增强的代码:

public class MyBeforeAdvice implements MethodBeforeAdvice{

 

​	/**

​	 * method:执行的方法

​	 * args:参数

​	 * target:目标对象

​	 */

​	public void before(Method method, Object[] args, Object target)

​			throws Throwable {

​		System.out.println("前置增强...");

​	}

}

 

第四步:生成代理:(配置生成代理:)

\* 生成代理Spring基于ProxyFactoryBean类.底层自动选择使用JDK的动态代理还是CGLIB的代理.

\* 属性:

target : 代理的目标对象

proxyInterfaces : 代理要实现的接口

如果多个接口可以使用以下格式赋值

<list>

​    <value></value>

​    ....

</list>

proxyTargetClass : 是否对类代理而不是接口，设置为true时，使用CGLib代理

interceptorNames : 需要织入目标的Advice

singleton : 返回代理是否为单实例，默认为单例

optimize : 当设置为true时，强制使用CGLib

 

​	<!-- 定义目标对象 -->

​	<bean id="customerDao" class="cn.itcast.spring3.demo3.CustomerDaoImpl"></bean>

​	

​	<!-- 定义增强 -->

​	<bean id="beforeAdvice" class="cn.itcast.spring3.demo3.MyBeforeAdvice"></bean>

 

​	<!-- Spring支持配置生成代理: -->

​	<bean id="customerDaoProxy" class="org.springframework.aop.framework.ProxyFactoryBean">

​		<!-- 设置目标对象 -->

​		<property name="target" ref="customerDao"/>

​		<!-- 设置实现的接口 ,value中写接口的全路径 -->

​		<property name="proxyInterfaces" value="cn.itcast.spring3.demo3.CustomerDao"/>

​		<!-- 需要使用value:要的名称 -->

​		<property name="interceptorNames" value="beforeAdvice"/>

​	</bean>

 

***\****** **注入的时候要注入代理对象****:**

@Autowired

​	// @Qualifier("customerDao")// 注入是真实的对象,必须注入代理对象.

​	@Qualifier("**customerDaoProxy**")

​	private CustomerDao customerDao;

 

#### **带有切点的切面:(针对目标对象的某些方法进行增强)**

PointcutAdvisor 接口:

DefaultPointcutAdvisor 最常用的切面类型，它可以通过任意Pointcut和Advice 组合定义切面

**RegexpMethodPointcutAdvisor** 构造正则表达式切点切面

 

第一步:创建被代理对象.

\* OrderDao

 

第二步:编写增强的类:

public class MyAroundAdvice implements MethodInterceptor{

​	

​	public Object invoke(MethodInvocation methodInvocation) throws Throwable {

​		System.out.println("环绕前增强...");

​		Object result = methodInvocation.proceed();// 执行目标对象的方法

​		System.out.println("环绕后增强...");

​		return result;

​	}

 

}

 

第三步:生成代理:

​	<!-- 带有切点的切面 -->

​	<!-- 定义目标对象 -->

​	<bean id="orderDao" class="cn.itcast.spring3.demo4.OrderDao"></bean>

​	

​	<!-- 定义增强 -->

​	<bean id="aroundAdvice" class="cn.itcast.spring3.demo4.MyAroundAdvice"></bean>

 

​	<!-- 定义切点切面: -->

​	<bean id="myPointcutAdvisor" class="org.springframework.aop.support.RegexpMethodPointcutAdvisor">

​		<!-- 定义表达式,规定哪些方法执行拦截 -->

​		<!-- . 任意字符  * 任意个 -->

​		<!-- <property name="pattern" value=".*"/> -->

​		<!-- <property name="pattern" value="cn\.itcast\.spring3\.demo4\.OrderDao\.add.*"/> -->

​		<!-- <property name="pattern" value=".*add.*"></property> -->

​		<property name="patterns" value=".*add.*,.*find.*"></property>

​		<!-- 应用增强 -->

​		<property name="advice" ref="aroundAdvice"/>

​	</bean>

 

​	<!-- 定义生成代理对象 -->

​	<bean id="orderDaoProxy" class="org.springframework.aop.framework.ProxyFactoryBean">

​		<!-- 配置目标 -->

​		<property name="target" ref="orderDao"></property>

​		<!-- 针对类的代理 -->

​		<property name="proxyTargetClass" value="true"></property>

​		<!-- 在目标上应用增强 -->

​		<property name="interceptorNames" value="myPointcutAdvisor"></property>

​	</bean>

 

### 1.4.4 **自动代理****:**

前面的案例中，每个代理都是通过ProxyFactoryBean织入切面代理，在实际开发中，非常多的Bean每个都配置ProxyFactoryBean开发维护量巨大

 

自动创建代理(*****基于后处理Bean.在Bean创建的过程中完成的增强.生成Bean就是代理.)

BeanNameAutoProxyCreator 根据Bean名称创建代理 

DefaultAdvisorAutoProxyCreator 根据Advisor本身包含信息创建代理

\* AnnotationAwareAspectJAutoProxyCreator 基于Bean中的AspectJ 注解进行自动代理

 

#### **BeanNameAutoProxyCreator :按名称生成代理**

​	<!-- 定义目标对象 -->

​	<bean id="customerDao" class="cn.itcast.spring3.demo3.CustomerDaoImpl"></bean>

​	<bean id="orderDao" class="cn.itcast.spring3.demo4.OrderDao"></bean>

​	

​	<!-- 定义增强 -->

​	<bean id="beforeAdvice" class="cn.itcast.spring3.demo3.MyBeforeAdvice"></bean>

​	<bean id="aroundAdvice" class="cn.itcast.spring3.demo4.MyAroundAdvice"></bean>

 

​	<!-- 自动代理:按名称的代理 基于后处理Bean,后处理Bean不需要配置ID-->

​	**<bean class="org.springframework.aop.framework.autoproxy.BeanNameAutoProxyCreator">**

​		**<property name="beanNames" value="\*Dao"/>**

​		**<property name="interceptorNames" value="beforeAdvice"/>**

​	**</bean>**

 

#### **DefaultAdvisorAutoProxyCreator :根据切面中定义的信息生成代理**

​	<!-- 定义目标对象 -->

​	<bean id="customerDao" class="cn.itcast.spring3.demo3.CustomerDaoImpl"></bean>

​	<bean id="orderDao" class="cn.itcast.spring3.demo4.OrderDao"></bean>

​	

​	<!-- 定义增强 -->

​	<bean id="beforeAdvice" class="cn.itcast.spring3.demo3.MyBeforeAdvice"></bean>

​	<bean id="aroundAdvice" class="cn.itcast.spring3.demo4.MyAroundAdvice"></bean>

 

​	**<!-- 定义一个带有切点的切面 -->**

​	**<bean id="myPointcutAdvisor" class="org.springframework.aop.support.RegexpMethodPointcutAdvisor">**

​		**<property name="pattern" value=".\*add.*"/>**

​		**<property name="advice" ref="aroundAdvice"/>**

​	**</bean>**

​	

​	**<!-- 自动生成代理 -->**

​	**<bean class="org.springframework.aop.framework.autoproxy.DefaultAdvisorAutoProxyCreator"></bean>**

 

**区分基于****ProxyFattoryBean的代理与自动代理区别?**

***\**** ProxyFactoryBean:先有被代理对象,将被代理对象传入到代理类中生成代理.**

   **自动代理基于后处理Bean.在Bean的生成过程中,就产生了代理对象,把代理对象返回.生成Bean已经是代理对象.**

## 1.5 **Spring的AspectJ的AOP(\*****)**

AspectJ是一个面向切面的框架，它扩展了Java语言。AspectJ定义了AOP语法所以它有一个专门的[编译器](http://baike.baidu.com/view/487018.htm)用来生成遵守Java字节编码规范的Class文件。

AspectJ是一个基于Java语言的AOP框架

Spring2.0以后新增了对AspectJ切点表达式支持

@AspectJ 是AspectJ1.5新增功能，通过JDK5注解技术，允许直接在Bean类中定义切面

新版本Spring框架，建议使用AspectJ方式来开发AOP

 

AspectJ表达式:

\* 语法:execution(表达式)

execution(<访问修饰符>?<返回类型><方法名>(<参数>)<异常>)

 

\* execution(“* cn.itcast.spring3.demo1.dao.*(..)”)		---只检索当前包

\* execution(“* cn.itcast.spring3.demo1.dao..*(..)”)		---检索包及当前包的子包.

\* execution(* cn.itcast.dao.GenericDAO+.*(..))			---检索GenericDAO及子类

 

AspectJ增强:

@Before 前置通知，相当于BeforeAdvice

@AfterReturning 后置通知，相当于AfterReturningAdvice

@Around 环绕通知，相当于MethodInterceptor

@AfterThrowing抛出通知，相当于ThrowAdvice

@After 最终final通知，不管是否异常，该通知都会执行

@DeclareParents 引介通知，相当于IntroductionInterceptor (不要求掌握)

 

### 1.5.1 **基于注解:**

第一步:引入相应jar包.

\* aspectj依赖aop环境.

\* spring-aspects-3.2.0.RELEASE.jar

\* com.springsource.org.aspectj.weaver-1.6.8.RELEASE.jar

 

第二步:编写被增强的类:

\* UserDao

 

第三步:使用AspectJ注解形式:

@Aspect

public class MyAspect {

​	

​	@Before("execution(* cn.itcast.spring3.demo1.UserDao.add(..))")

​	public void before(){

​		System.out.println("前置增强....");

​	}

​	

}

 

第四步:创建applicationContext.xml

\* 引入aop的约束:

\* <aop:aspectj-autoproxy /> --- 自动生成代理:

\* 底层就是AnnotationAwareAspectJAutoProxyCreator

 

​	<aop:aspectj-autoproxy />

​	<bean id="userDao" class="cn.itcast.spring3.demo1.UserDao"></bean>

​	<bean id="myAspect" class="cn.itcast.spring3.demo1.MyAspect"></bean>

 

#### **AspectJ的通知类型:**

@Before 前置通知，相当于BeforeAdvice

\* 就在方法之前执行.没有办法阻止目标方法执行的.

@AfterReturning 后置通知，相当于AfterReturningAdvice

\* 后置通知,获得方法返回值.

@Around 环绕通知，相当于MethodInterceptor

\* 在可以方法之前和之后来执行的,而且可以阻止目标方法的执行.

@AfterThrowing抛出通知，相当于ThrowAdvice

@After 最终final通知，不管是否异常，该通知都会执行

@DeclareParents 引介通知，相当于IntroductionInterceptor (不要求掌握)

 

#### **切点的定义:**

@Pointcut("execution(* cn.itcast.spring3.demo1.UserDao.find(..))")

​	private void myPointcut(){}

 

面试:

\* Advisor和Aspect的区别?

\* Advisor:Spring传统意义上的切面:支持一个切点和一个通知的组合.

\* Aspect:可以支持多个切点和多个通知的组合.

### 1.5.2 **基于XML:**

第一步:编写被增强的类:

\* ProductDao

 

第二步:定义切面

 

第三步:配置applicationContext.xmll

 

前置通知:

\* 代码:

​	public void before(){

​		System.out.println("前置通知...");

​	}

 

\* 配置:

<aop:config>

​		<!-- 定义切点: -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo2.ProductDao.add(..))" id="mypointcut"/>

​		<aop:aspect ref="myAspectXML">

​			<!-- 前置通知 -->

​			<aop:before method="before" pointcut-ref="mypointcut"/>

​		</aop:aspect>

​	</aop:config>

 

后置通知:

\* 代码:

​	public void afterReturing(Object returnVal){

​		System.out.println("后置通知...返回值:"+returnVal);

​	}

 

\* 配置:

​	<aop:config>

​		<!-- 定义切点: -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo2.ProductDao.add(..))" id="mypointcut"/>

​		<aop:aspect ref="myAspectXML">

​			<!-- 后置通知 -->

​			<aop:after-returning method="afterReturing" pointcut-ref="mypointcut" returning="returnVal"/>

​		</aop:aspect>

​	</aop:config>

 

环绕通知:

\* 代码:

​	public Object around(ProceedingJoinPoint proceedingJoinPoint) throws Throwable{

​		System.out.println("环绕前增强....");

​		Object result = proceedingJoinPoint.proceed();

​		System.out.println("环绕后增强....");

​		return result;

​	}

 

\* 配置:

​	<aop:config>

​		<!-- 定义切点: -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo2.ProductDao.add(..))" id="mypointcut"/>

​		<aop:aspect ref="myAspectXML">

​			<!-- 前置通知 -->

​			<!-- <aop:before method="before" pointcut-ref="mypointcut"/> -->

​			<!-- 后置通知 -->

​			<!-- <aop:after-returning method="afterReturing" pointcut-ref="mypointcut" returning="returnVal"/> -->

​			<!-- 环绕通知 -->

​			**<aop:around method="around" pointcut-ref="mypointcut"/>**

​		</aop:aspect>

​	</aop:config>

 

异常通知:

\* 代码;

​	public void afterThrowing(Throwable e){

​		System.out.println("异常通知..."+e.getMessage());

​	}

 

\* 配置;

​	<aop:config>

​		<!-- 定义切点: -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo2.ProductDao.add(..))" id="mypointcut"/>

​		<aop:aspect ref="myAspectXML">

​			<!-- 异常通知 -->

​			<aop:after-throwing method="afterThrowing" pointcut-ref="mypointcut" throwing="e"/>

​		</aop:aspect>

​	</aop:config>

 

最终通知:

\* 代码:

​	public void after(){

​		System.out.println("最终通知....");

​	}

 

\* 配置:

​	<aop:config>

​		<!-- 定义切点: -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo2.ProductDao.add(..))" id="mypointcut"/>

​		<aop:aspect ref="myAspectXML">

​			<!-- 最终通知 -->

​			<aop:after method="after" pointcut-ref="mypointcut"/>

​		</aop:aspect>

​	</aop:config>

## 1.6 **Spring的JdbcTemplate**

JdbcTemplate模板与DbUtils工具类比较类似.

### 1.6.1 **Spring对持久层技术支持:**

JDBC		:	org.springframework.jdbc.core.JdbcTemplate

Hibernate3.0		:	org.springframework.orm.hibernate3.HibernateTemplate

IBatis(MyBatis)	:	org.springframework.orm.ibatis.SqlMapClientTemplate

JPA		:	org.springframework.orm.jpa.JpaTemplate

### 1.6.2 **开发JDBCTemplate入门:**

第一步:引入相应jar包:

\* spring-tx-3.2.0.RELEASE.jar

\* spring-jdbc-3.2.0.RELEASE.jar

\* mysql驱动.

 

第二步:创建applicationContext.xml

 

第三步:编写一个测试类:

 

### 1.6.3 **配置连接池:**

#### **Spring默认的连接池:**

​	<!-- 配置Spring默认的连接池 -->

​	<bean id="dataSource" class="org.springframework.jdbc.datasource.DriverManagerDataSource">

​		<property name="driverClassName" value="com.mysql.jdbc.Driver"/>

​		<property name="url" value="jdbc:mysql:///spring3_day02"/>

​		<property name="username" value="root"/>

​		<property name="password" value="123"/>

​	</bean>

 

#### **DBCP连接池:**

导入jar包:

\* com.springsource.org.apache.commons.dbcp-1.2.2.osgi.jar

\* com.springsource.org.apache.commons.pool-1.5.3.jar

 

​	<!-- 配置DBCP连接池 -->

​	<bean id="dataSource" class="org.apache.commons.dbcp.BasicDataSource">

​		<property name="driverClassName" value="com.mysql.jdbc.Driver"/>

​		<property name="url" value="jdbc:mysql:///spring3_day02"/>

​		<property name="username" value="root"/>

​		<property name="password" value="123"/>

​	</bean>

 

#### **C3P0连接池:**

导入jar包:

\* com.springsource.com.mchange.v2.c3p0-0.9.1.2.jar

​	<!-- 配置c3p0连接池 -->

​	<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">

​		<property name="driverClass" value="com.mysql.jdbc.Driver"/>

​		<property name="jdbcUrl" value="jdbc:mysql:///spring3_day02"/>

​		<property name="user" value="root"/>

​		<property name="password" value="123"/>

​	</bean>

 

### 1.6.4 **参数设置到属性文件中****:**

在src下创建jdbc.properties

jdbc.driver = com.mysql.jdbc.Driver

jdbc.url = jdbc:mysql:///spring3_day02

jdbc.user = root

jdbc.password = 123

 

需要在applicationContext.xml 中使用属性文件配置的内容.

\* 第一种写法:

<bean class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">

​          <property name="location" value="classpath:jdbc.properties"></property>

</bean>

 

\* 第二种写法:

<context:property-placeholder location="classpath:jdbc.properties"/>

 

### 1.6.5 **JdbcTemplate的CRUD的操作:**

Spring框架中提供了对持久层技术支持的类:

JDBC			:	org.springframework.jdbc.core.support.JdbcDaoSupport

Hibernate 3.0	:	org.springframework.orm.hibernate3.support.HibernateDaoSupport

iBatis		:	org.springframework.orm.ibatis.support.SqlMapClientDaoSupport

 

编写DAO的时候:

Public class UserDao extends **JdbcDaoSupport**{

 

}

 

进行CRUD的操作;

\* 保存:update(String sql,Object... args)

\* 修改:update(String sql,Object... args)

\* 删除:update(String sql,Object... args)

 

查询:

\* 简单查询:

\* select count(*) from user;			--- queryForInt(String sql);

\* select name from user where id = ?;	--- queryForObject(String sql,Class clazz,Object... args);

 

\* 复杂查询:(返回对象,和对象集合)

\* select * from user where id = ?		--- queryForObjectString sql,RowMapper<T> rowMapper,Object... args);

\* select * from user;					--- query(String sql,RowMapper<T> rowMapper,Object... args);

**今天的内容总结:**

Spring AOP

\* AOP:面向切面编程.不是替代面向对象,对面向对象扩展,延伸.

\* AOP的思想:

\* 代理机制.(横向抽取).

\* Spring使用AOP的时候,根据类的情况,自动选择代理机制:

\* JDK	:针对实现了接口的类生成代理.

\* CGLIB	:针对没有实现接口的类生成代理.生成某个类的子类.

 

\* Spring的AOP的开发中:

\* 术语 :

\* JoinPoint:连接点.可以被增强的方法.

\* PointCut:切入点.真正被增强的方法.

\* Advice:通知.增强的代码.

\* Target:目标对象.被增强的类.

\* Weaving:

\* Aspect:切面.在切入点应用增强.

 

\* 传统的Spring AOP.

\* 不带切点的切面:

 

\* 带有切点的切面:

 

\* 生成代理:基于ProxyFactoryBean.

*** 缺点;每个类都需要配置ProxyFactroyBean**.

 

\* 自动代理:(基于后处理Bean)

\* Bean名称自动代理:

\* 切面信息自动代理:

 

*** Spring中AspectJ的支持.**

\* 为了简便开发引入AspectJ的支持.

 

\* 注解:

\* @Aspect:

 

\* @Before

\* @Around

\* @AfterReturing

\* @AfterThrowing

\* @After

 

\* PointCut

 

\* XML:

\* 引入aop约束:

<aop-config>

<aop:pointcut id=”” expression=””/>

<aop:aspect ref=””>

<aop:before />

</aop:aspect>

</aop-config>

 

Spring JDBCTemplate:

\* 配置连接池:

\* 默认的:

\* DBCP:

\* C3P0:(*****)

\* 提取了properties

\* JdbcTemplate的CRUD的操作.





# **Spring_day03总结** 三大框架整合

**今日内容**

l Spring的事务管理

l 

## **上次课的内容回顾:**

Spring的AOP开发:

\* AOP:面向切面编程,是对OO思想延伸.

\* AOP底层实现原理:动态代理.

\* JDK动态代理:针对实现了接口的类生产代理.

\* CGLIB代理:针对没有实现接口的类，产生一个子类.

\* AOP术语:

\* JoinPoint:可以被拦截点.

\* Ponitcut:真正被拦截.

\* Advice:通知，增强的代码.

\* 引介:特殊通知，类级别上添加属性或方法.

\* Target:目标对象.

\* Proxy:代理对象.

\* Weaving:

\* Aspect:

 

\* Spring的AOP的开发:

\* 配置applicationContext.xml生成代理对象.

\* 使用ProxyFactoryBean类生产代理:

\* 根据目标对象是否实现了接口，选择使用JDK还是CGLIB.

\* 缺点:需要为每个类都去配置一个ProxyFactoryBean.

 

\* 采用Spring自动代理:

\* 基于类名称的自动代理:(采用后处理Bean)

\* 基于切面信息的自动代理:(采用后处理Bean)

 

\* Spring的AspectJ的切面开发.

\* AspectJ:本身第三方切面框架.

\* AspectJ基于注解开发:

\* 定义切面:

@Aspect

 

\* 定义增强:

@Before:前置通知.

@AfterReturing:后置通知.

@Around:环绕通知.

@AfterThrowing:异常抛出通知.

@After:最终通知.

 

\* 定义切点:

@Pointcut

\* AspectJ基于XML开发:

\* 引入aop名称空间.

<aop:config>

<aop:pointcut expression=”” id=””/>

<aop:aspect ref=””>

<aop:before...>

</aop:aspect>

</aop:config>

 

Spring的JDBCTemplate:

\* 配置连接池:

\* 默认

\* DBCP

\* C3P0(*****)

\* 引入外部属性文件.

\* 在DAO中注入JdbcTemplate.

\* 在DAO中不直接注入模板.Dao集成JdbcDaoSupport.

\* CRUD的操作.

## 1.1 **Spring的事务管理:**

### 1.1.1 **事务:**

事务:是逻辑上一组操作，要么全都成功，要么全都失败.

事务特性:

ACID:

原子性:事务不可分割

一致性:事务执行的前后，数据完整性保持一致.

隔离性:一个事务执行的时候，不应该受到其他事务的打扰

持久性:一旦结束，数据就永久的保存到数据库.

 

如果不考虑隔离性:

脏读:一个事务读到另一个事务未提交数据

不可重复读:一个事务读到另一个事务已经提交数据（update）导致一个事务多次查询结果不一致

虚读:一个事务读到另一个事务已经提交数据（insert）导致一个事务多次查询结果不一致

 

事务的隔离级别:

未提交读:以上情况都有可能发生。

已提交读:避免脏读，但不可重复读，虚读是有可能发生。

可重复读:避免脏读，不可重复读，但是虚读有可能发生。

串行的:避免以上所有情况.

 

### 1.1.2 **Spring中事务管理:**

分层开发：事务处在Service层.

#### **Spring提供事务管理API:**

PlatformTransactionManager:平台事务管理器.

| [commit](#commit(org.springframework.transaction.TransactionStatus))([TransactionStatus](mk:@MSITStore:D:\itcast\20141110\spring\spring_day01\Spring3.0.2-RELEASE-API.chm::/org/springframework/transaction/../../../org/springframework/transaction/TransactionStatus.html) status) [getTransaction](#getTransaction(org.springframework.transaction.TransactionDefinition))([TransactionDefinition](mk:@MSITStore:D:\itcast\20141110\spring\spring_day01\Spring3.0.2-RELEASE-API.chm::/org/springframework/transaction/../../../org/springframework/transaction/TransactionDefinition.html) definition) |
| ------------------------------------------------------------ |
| [rollback](#rollback(org.springframework.transaction.TransactionStatus))([TransactionStatus](mk:@MSITStore:D:\itcast\20141110\spring\spring_day01\Spring3.0.2-RELEASE-API.chm::/org/springframework/transaction/../../../org/springframework/transaction/TransactionStatus.html) status) |

 

TransactionDefinition:事务定义

ISOLation_XXX:事务隔离级别.

PROPAGATION_XXX:事务的传播行为.(不是JDBC中有的，为了解决实际开发问题.)

过期时间:

 

TransactionStatus:事务状态

是否有保存点

是否一个新的事务

事务是否已经提交

 

关系:PlatformTransactionManager通过TransactionDefinition设置事务相关信息管理事务，管理事务过程中，产生一些事务状态:状态由TransactionStatus记录.

 

API详解:

PlatformTransactionManager:接口.

Spring为不同的持久化框架提供了不同PlatformTransactionManager接口实现

 

**org.springframework.jdbc.datasource.DataSourceTransactionManager**	**:**	**使用Spring JDBC或iBatis 进行持久化数据时使用**

**org.springframework.orm.hibernate3.HibernateTransactionManager**		**:** 	**使用Hibernate3.0版本进行持久化数据时使用**

org.springframework.orm.jpa.JpaTransactionManager	使用JPA进行持久化时使用

org.springframework.jdo.JdoTransactionManager	当持久化机制是Jdo时使用

org.springframework.transaction.jta.JtaTransactionManager	使用一个JTA实现来管理事务，在一个事务跨越多个资源时必须使用

 

TransactionDefinition:

\* [ISOLATION_DEFAULT](#ISOLATION_DEFAULT):默认级别. Mysql  repeatable_read		oracle read_commited

| [ISOLATION_READ_UNCOMMITTED](#ISOLATION_READ_UNCOMMITTED) |
| --------------------------------------------------------- |
| [ISOLATION_READ_COMMITTED](#ISOLATION_READ_COMMITTED)     |
| [ISOLATION_REPEATABLE_READ](#ISOLATION_REPEATABLE_READ)   |
| [ISOLATION_SERIALIZABLE](#ISOLATION_SERIALIZABLE)         |

 

\* 事务的传播行为:(不是JDBC事务管理，用来解决实际开发的问题.)传播行为：解决业务层之间的调用的事务的关系.

PROPAGATION_REQUIRED		:支持当前事务，如果不存在 就新建一个

\* A,B	如果A有事务，B使用A的事务，如果A没有事务，B就开启一个新的事务.(A,B是在一个事务中。)

PROPAGATION_SUPPORTS		:支持当前事务，如果不存在，就不使用事务

\* A,B	如果A有事务，B使用A的事务，如果A没有事务，B就不使用事务.

PROPAGATION_MANDATORY	:支持当前事务，如果不存在，抛出异常

\* A,B	如果A有事务，B使用A的事务，如果A没有事务，抛出异常.

PROPAGATION_REQUIRES_NEW	如果有事务存在，挂起当前事务，创建一个新的事务

\* A,B	如果A有事务，B将A的事务挂起，重新创建一个新的事务.(A,B不在一个事务中.事务互不影响.)

PROPAGATION_NOT_SUPPORTED	以非事务方式运行，如果有事务存在，挂起当前事务

\* A,B	非事务的方式运行，A有事务，就会挂起当前的事务.

PROPAGATION_NEVER 	以非事务方式运行，如果有事务存在，抛出异常

PROPAGATION_NESTED	如果当前事务存在，则嵌套事务执行

\* 基于SavePoint技术.

\* A,B	A有事务，A执行之后，将A事务执行之后的内容保存到SavePoint.B事务有异常的话，用户需要自己设置事务提交还是回滚.

 

\* 常用:(重点)

PROPAGATION_REQUIRED	

PROPAGATION_REQUIRES_NEW

PROPAGATION_NESTED

### 1.1.3 **Spring的事务管理:**

Spring的事务管理分成两类:

\* 编程式事务管理:

\* 手动编写代码完成事务管理.

\* 声明式事务管理:

\* 不需要手动编写代码,配置.

### 1.1.4 **事务操作的环境搭建:**

CREATE TABLE `account` (

  `id` int(11) NOT NULL AUTO_INCREMENT,

  `name` varchar(20) NOT NULL,

  `money` double DEFAULT NULL,

  PRIMARY KEY (`id`)

) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8;

INSERT INTO `account` VALUES ('1', 'aaa', '1000');

INSERT INTO `account` VALUES ('2', 'bbb', '1000');

INSERT INTO `account` VALUES ('3', 'ccc', '1000');

 

创建一个web项目:	

\* 导入相应jar包

\* 引入配置文件:

\* applicationContext.xml、log4j.properties、jdbc.properties

 

创建类:

\* AccountService

\* AccountDao

 

在Spring中注册:

​	<!-- 业务层类 -->

​	<bean id="accountService" class="cn.itcast.spring3.demo1.AccountServiceImpl">

​		<!-- 在业务层注入Dao -->

​		<property name="accountDao" ref="accountDao"/>

​	</bean>

​	

​	<!-- 持久层类 -->

​	<bean id="accountDao" class="cn.itcast.spring3.demo1.AccountDaoImpl">

​		<!-- 注入连接池的对象,通过连接池对象创建模板. -->

​		**<property name="dataSource" ref="dataSource"/>**

​	</bean>

 

编写一个测试类:

### 1.1.5 **Spring的事务管理:**

#### **手动编码的方式完成事务管理:**

需要事务管理器:**真正管理事务对象.**

*** Spring提供了事务管理的模板(工具类.)**

 

**第一步:注册事务管理器:**

<!-- 配置事务管理器 -->

​	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">

​		<!-- 需要注入连接池,通过连接池获得连接 -->

​		<property name="dataSource" ref="dataSource"/>

​	</bean>

 

第二步:注册事务模板类:

​	<!-- 事务管理的模板 -->

​	<bean id="transactionTemplate" class="org.springframework.transaction.support.TransactionTemplate">

​		<property name="transactionManager" ref="transactionManager"/>

​	</bean>

 

第三步:在业务层注入模板类:(模板类管理事务)

​	<!-- 业务层类 -->

​	<bean id="accountService" class="cn.itcast.spring3.demo1.AccountServiceImpl">

​		<!-- 在业务层注入Dao -->

​		<property name="accountDao" ref="accountDao"/>

​		<!-- 在业务层注入事务的管理模板 -->

​		**<property name="transactionTemplate" ref="transactionTemplate"/>**

​	</bean>

 

第四步:在业务层代码上使用模板:

​	public void transfer(final String from, final String to, final Double money) {

​		**transactionTemplate.execute(new TransactionCallbackWithoutResult() {**

​			**@Override**

​			**protected void doInTransactionWithoutResult(TransactionStatus status) {**

​				**accountDao.out(from, money);**

​				**int d = 1 / 0;**

​				**accountDao.in(to, money);**

​			**}**

​		**});**

​	}

 

手动编码方式缺点:

\* 代码量增加,代码有侵入性.

#### **声明式事务管理:(原始方式)**

基于TransactionProxyFactoryBean.

导入:aop相应jar包.

 

第一步:注册平台事务管理器:

​	<!-- 事务管理器 -->

​	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">

​		<!-- 注入连接池 -->

​		<property name="dataSource" ref="dataSource"/>

​	</bean>

 

第二步:创建业务层代理对象:

​	<!-- 配置生成代理对象 -->

​	<bean id="accountServiceProxy" class="org.springframework.transaction.interceptor.TransactionProxyFactoryBean">

​		<!-- 目标对象 -->

​		<property name="target" ref="accountService"/>

​		**<!-- 注入事务管理器 -->**

​		**<property name="transactionManager" ref="transactionManager"/>**

​		**<!-- 事务的属性设置 -->**

​		**<property name="transactionAttributes">**

​			**<props>**

​				**<prop key="transfer">PROPAGATION_REQUIRED</prop>**

​			**</props>**

​		**</property>**

​	</bean>

 

第三步:编写测试类:

***\**** 千万注意:注入代理对象**

@Autowired

@Qualifier("**accountServiceProxy**")

private AccountService accountService;

 

**prop格式：PROPAGATION,ISOLATION,readOnly,-Exception,+Exception**

*** 顺序:传播行为、隔离级别、事务是否只读、发生哪些异常可以回滚事务（所有的异常都回滚）、发生了哪些异常不回滚.**

 

***\**** 缺点:就是需要为每一个管理事务的类生成代理.需要为每个类都需要进行配置.**

#### **声明式事务管理:(自动代理.基于切面 \******)**

**第一步:导入相应jar包.**

*** aspectj**

 

**第二步:引入相应约束:**

*** aop、tx约束.**

**<beans xmlns="http://www.springframework.org/schema/beans"**

​	**xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"**

​	**xmlns:context="http://www.springframework.org/schema/context"**

​	**xmlns:aop="http://www.springframework.org/schema/aop"**

​	**xmlns:tx="http://www.springframework.org/schema/tx"**

​	**xsi:schemaLocation="http://www.springframework.org/schema/beans** 

​	**http://www.springframework.org/schema/beans/spring-beans.xsd**

​	**http://www.springframework.org/schema/context**

​	**http://www.springframework.org/schema/context/spring-context.xsd**

​	**http://www.springframework.org/schema/aop**

​	**http://www.springframework.org/schema/aop/spring-aop.xsd**

​	**http://www.springframework.org/schema/tx** 

​	[" >**http://www.springframework.org/schema/tx/spring-tx.xsd">**](http://www.springframework.org/schema/tx/spring-tx.xsd\)

 

**第三步:注册事务管理器;**

​	<!-- 事务管理器 -->

​	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">

​		<property name="dataSource" ref="dataSource"/>

​	</bean>

 

第四步:定义增强(事务管理)

​	<!-- 定义一个增强 -->

​	<tx:advice id="**txAdvice**" transaction-manager="transactionManager">

​		<!-- 增强(事务)的属性的配置 -->

​		<tx:attributes>

​			<!-- 

​				isolation:DEFAULT	:事务的隔离级别.

​				propagation			:事务的传播行为.

​				read-only			:false.不是只读

​				timeout				:-1

​				no-rollback-for		:发生哪些异常不回滚

​				rollback-for		:发生哪些异常回滚事务

​			 -->

​			<tx:method name="transfer"/>

​		</tx:attributes>

​	</tx:advice>

 

**第五步:定义aop的配置(切点和通知的组合)**

​	<!-- aop配置定义切面和切点的信息 -->

​	<aop:config>

​		<!-- 定义切点:哪些类的哪些方法应用增强 -->

​		<aop:pointcut expression="execution(* cn.itcast.spring3.demo3.AccountService+.*(..))" id="mypointcut"/>

​		<!-- 定义切面: -->

​		<aop:advisor advice-ref="**txAdvice**" pointcut-ref="mypointcut"/>

​	</aop:config>

 

第六步:编写测试类:

\* 注入Service对象,不需要注入代理对象(生成这个类的时候,已经是代理对象.)

#### **基于注解的事务管理:**

第一步:事务管理器:

​	<!-- 事务管理器 -->

​	<bean id="transactionManager" class="org.springframework.jdbc.datasource.DataSourceTransactionManager">

​		<property name="dataSource" ref="dataSource"/>

​	</bean>

 

第二步:注解事务:

​	<!-- 开启注解的事务管理 -->

​	<tx:annotation-driven transaction-manager="transactionManager"/>

 

第三步:在Service上使用注解

@Transactional

\* 注解中有属性值:

\* isolation

\* propagation

\* readOnly

...

## 1.2 **SSH框架整合:**

### 1.2.1 **Struts2+Spring+Hibernate导包**

Struts2导入jar包:

\* struts2/apps/struts2-blank.war/WEB-INF/lib/*.jar

\* 导入与spring整合的jar

\* struts2/lib/struts2-spring-plugin-2.3.15.3.jar		--- 整合Spring框架

\* struts2/lib/struts2-json-plugin-2.3.15.3.jar			--- 整合AJAX

\* struts2/lib/struts2-convention-plugin-2.3.15.3.jar	--- 使用Struts2注解开发.

 

\* 配置

web.xml

<filter>

  <filter-name>struts2</filter-name> 

  <filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class> 

</filter>

<filter-mapping>

  <filter-name>struts2</filter-name> 

  <url-pattern>/*</url-pattern> 

</filter-mapping>

 

struts.xml

<struts>

 

​    <constant name="struts.devMode" value="true" />

 

​    <package name="default" namespace="/" extends="struts-default">

​    	

​    </package>

 

</struts>

 

 

Spring导入jar包:

Spring3.2 开发最基本jar包

spring-beans-3.2.0.RELEASE.jar

spring-context-3.2.0.RELEASE.jar

spring-core-3.2.0.RELEASE.jar

spring-expression-3.2.0.RELEASE.jar

com.springsource.org.apache.commons.logging-1.1.1.jar

com.springsource.org.apache.log4j-1.2.15.jar

AOP开发

spring-aop-3.2.0.RELEASE.jar

spring-aspects-3.2.0.RELEASE.jar

com.springsource.org.aopalliance-1.0.0.jar

com.springsource.org.aspectj.weaver-1.6.8.RELEASE.jar

Spring Jdbc开发

spring-jdbc-3.2.0.RELEASE.jar

spring-tx-3.2.0.RELEASE.jar

Spring事务管理

spring-tx-3.2.0.RELEASE.jar

Spring整合其他ORM框架

spring-orm-3.2.0.RELEASE.jar

Spring在web中使用

spring-web-3.2.0.RELEASE.jar

Spring整合Junit测试

spring-test-3.2.0.RELEASE.jar

 

(Spring没有引入c3p0和数据库驱动)

 

\* 配置:

applicationContext.xml

Log4j.properties

 

在web.xml中配置监听器;

<!-- 配置Spring的监听器 -->

<listener>

​	<!-- 监听器默认加载的是WEB-INF/applicationContext.xml -->

​	<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>

</listener>

 

<!-- 指定Spring框架的配置文件所在的位置 -->

<context-param>

​	<param-name>contextConfigLocation</param-name>

​	<param-value>classpath:applicationContext.xml</param-value>

</context-param>

 

Hibernate的jar包导入:

\* 核心包:hibernate3.jar

\* lib/required/*.jar

\* lib/jpa/*.jar

\* 引入hibernate整合日志系统的jar包:

\* 数据连接池:

\* 数据库驱动:

 

\* 二级缓存:(可选的.)

\* backport-util-concurrent.jar

\* commons-logging.jar

\* ehcache-1.5.0.jar

 

\* Hibernate的配置:

\* hibernate.cfg.xml

\* 映射:

\* 格式:类名.hbm.xml

### 1.2.2 **Struts2和Spring的整合:**

1.新建包结构:

\* cn.itcast.action

\* cn.itcast.service

\* cn.itcast.dao

\* cn.itcast.vo

 

2.创建实体类:

\* Book

 

3.新建一个jsp页面:

\* addBook.jsp

​        <s:form action="book_add" namespace="/" method="post" theme="simple">

​	图书名称:<s:textfield name="name"/><br/>

​	图书价格:<s:textfield name="price"/><br/>

​	<s:submit value="添加图书"/>

</s:form>

 

4.编写Action:

public class BookAction extends ActionSupport implements ModelDriven<Book>{

​	// 模型驱动类

​	private Book book = new Book();

​	public Book getModel() {

​		return book;

​	}

 

​	// 处理请求的方法:

​	public String add(){

​		System.out.println("web层的添加执行了...");

​		return NONE;

​	}

}

 

5.配置struts.xml

<action name="book_*" class="cn.itcast.action.BookAction" method="{1}">

​    		

​    	</action>

 

### 1.2.3 **Struts2和Spring的整合两种方式:**

#### **Struts2自己管理Action:(方式一)**

<action name="book_*" class="cn.itcast.action.BookAction" method="{1}">

\* Struts2框架自动创建Action的类.

#### **Action交给Spring管理:(方式二)**

可以在<action>标签上通过一个伪类名方式进行配置:

<action name="book_*" class="**bookAction**" method="{1}"></action>

 

在spring的配置文件中:

<!-- 配置Action -->

​	<bean id="**bookAction**" class="cn.itcast.action.BookAction"></bean>

(*****)注意:Action交给Spring管理一定要配置scope=”**prototype**”

 

推荐使用二:

\* 在Spring中管理的类,可以对其进行AOP开发.统一的管理.

 

#### **Web层获得Service:**

传统方式:

\* 获得WebApplicationContext对象.

\* 通过WebAppolicationContext中getBean(“”);

 

实际开发中:

\* 引入了struts2-spring-plugin-2.3.15.3.jar

\* 有一个配置文件 : struts-plugin.xml

开启常量 :

<constant name="struts.objectFactory" value="spring" />

引发另一个常量的执行:(Spring的工厂类按照名称自动注入)

struts.objectFactory.spring.autoWire = name

 

### 1.2.4 **Spring整合Hibernate:**

Spring整合Hibernate框架的时候有两种方式:

#### **零障碍整合:(一)**

可以在Spring中引入Hibernate的配置文件.

1.通过LocalSessionFactoryBean在spring中直接引用hibernate配置文件

​	<!-- 零障碍整合 在spring配置文件中引入hibernate的配置文件 -->

​	<bean id="sessionFactory" class="org.springframework.orm.hibernate3.LocalSessionFactoryBean">

​		<property name="configLocation" value="classpath:hibernate.cfg.xml"/>

​	</bean>

 

2.Spring提供了Hibernate的模板.只需要将HibernateTemplate模板注入给DAO.

\* DAO继承HibernateDaoSupport.

​	<!-- DAO的配置 -->

​	<bean id="bookDao" class="cn.itcast.dao.BookDao">

​		<property name="sessionFactory" ref="sessionFactory"/>

​	</bean>

 

改写DAO:继承HibernateDaoSupport类.

public class BookDao extends HibernateDaoSupport{

 

​	public void save(Book book) {

​		System.out.println("DAO层的保存图书...");

​		**this.getHibernateTemplate().save(book);**

​	}

 

}

 

3.创建一个映射文件 :

<hibernate-mapping>

​	<class name="cn.itcast.vo.Book" table="book">

​		<id name="id">

​			<generator class="native"/>

​		</id>

​		<property name="name"/>

​		<property name="price"/>

​	</class>

</hibernate-mapping>

 

4.别忘记事务管理:

事务管理器:

​	<!-- 管理事务 -->

​	<bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">

​		<property name="sessionFactory" ref="sessionFactory"/>

​	</bean>

 

5.注解管理事务:

<!-- 注解开启事务 -->

​	<tx:annotation-driven transaction-manager="transactionManager"/>

 

6.在业务层类上添加一个注解:

@Transactional

#### **没有Hibernate配置文件的形式(二)**

不需要Hibernate配置文件的方式,将Hibernate配置文件的信息直接配置到Spring中.

Hibernate配置文件中的信息 :

\* 连接数据库基本参数:

\* Hibernate常用属性:

\* 连接池:

\* 映射:

 

把Hibernate配置文件整合Spring中:

连接池:

<!-- 引入外部属性文件. -->

​	<context:property-placeholder location="classpath:jdbc.properties"/>

​	

​	<!-- 配置c3p0连接池 -->

​	<bean id="dataSource" class="com.mchange.v2.c3p0.ComboPooledDataSource">

​		<property name="driverClass" value="${jdbc.driver}"/>

​		<property name="jdbcUrl" value="${jdbc.url}"/>

​		<property name="user" value="${jdbc.user}"/>

​		<property name="password" value="${jdbc.password}"/>

​	</bean>

**Hibernate常用属性:**

<!-- 配置Hibernate的属性 -->

​		<property name="hibernateProperties">

​			<props>

​				<prop key="hibernate.dialect">org.hibernate.dialect.MySQLDialect</prop>

​				<prop key="hibernate.show_sql">true</prop>

​				<prop key="hibernate.format_sql">true</prop>

​				<prop key="hibernate.hbm2ddl.auto">update</prop>

​				<prop key="hibernate.connection.autocommit">false</prop>

​			</props>

​		</property>

 

**映射**

<!-- <property name="mappingResources">

​			<list>

​				<value>cn/itcast/vo/Book.hbm.xml</value>

​			</list>

​		</property> -->

​		<property name="mappingDirectoryLocations">

​			<list>

​				<value>classpath:cn/itcast/vo</value>

​			</list>

​		</property>

### 1.2.5 **HibernateTemplate的API:**

 Serializable save(Object entity) 						:保存数据

 void update(Object entity) 							:修改数据

 void delete(Object entity) 							:删除数据

 <T> T get(Class<T> entityClass, Serializable id) 		:根据ID进行检索.立即检索

 <T> T load(Class<T> entityClass, Serializable id) 		:根据ID进行检索.延迟检索.

 **List find(String queryString, Object... values)** 		**:支持HQL查询.直接返回List集合.**

 **List findByCriteria(DetachedCriteria criteria)**  		**:离线条件查询.**

 **List findByNamedQuery(String queryName, Object... values)**	**:命名查询的方式.**

 

### 1.2.6 **OpenSessionInView:**

 

## 1.3 **基于注解的方式整合SSH:**

导入以上工程jar包:

\* 导入struts2的注解开发:

\* struts2-convention-plugin-2.3.15.3.jar

 

\* web.xml:

<!-- 配置Spring的监听器 -->

<listener>

​	<!-- 监听器默认加载的是WEB-INF/applicationContext.xml -->

​	<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>

</listener>

 

<!-- 指定Spring框架的配置文件所在的位置 -->

<context-param>

​	<param-name>contextConfigLocation</param-name>

​	<param-value>classpath:applicationContext.xml</param-value>

</context-param>

 

<!-- 配置Struts2的核心过滤器 -->

<filter>

​	<filter-name>struts2</filter-name> 

​	<filter-class>org.apache.struts2.dispatcher.ng.filter.StrutsPrepareAndExecuteFilter</filter-class> 

</filter>

<filter-mapping>

​	<filter-name>struts2</filter-name> 

​	<url-pattern>/*</url-pattern> 

</filter-mapping>

 

\* 创建包结构:

\* 引入spring的配置文件、log4j、jdbc属性文件.

 

\* 创建页面:

\* 创建Action:

@Namespace("/")

@ParentPackage("struts-default")

public class BookAction extends ActionSupport implements ModelDriven<Book>{

​	private Book book = new Book();

​	public Book getModel() {

​		return book;

​	}

 

​	@Action(value="book_add")

​	public String add(){

​		System.out.println("web层添加图书...");

​		return NONE;

​	}

}

 

\* Action---Service----Dao

将各层类使用注解装配Spring中:

@Controller

@Service

@@Repository

 

完成属性注入:

@Autowired

​	@Qualifier("bookService")

 

\* 实体类:

@Entity

@Table(name="book")

public class Book {

​	@Id

​	@GeneratedValue(strategy=GenerationType.IDENTITY)

​	private Integer id;

​	@Column(name="name")

​	private String name;

​	private Double price;

​	public Integer getId() {

​		return id;

​	}

​	public void setId(Integer id) {

​		this.id = id;

​	}

​	public String getName() {

​		return name;

​	}

​	public void setName(String name) {

​		this.name = name;

​	}

​	public Double getPrice() {

​		return price;

​	}

​	public void setPrice(Double price) {

​		this.price = price;

​	}

​	@Override

​	public String toString() {

​		return "Book [id=" + id + ", name=" + name + ", price=" + price + "]";

​	}

​	

}

\* 事务管理:

 

\* 模板注入:

**今天内容总结:**

Spring的事务管理:

\* 编程式事务:(了解)

\* 声明式事务:

\* TransactionProxyFactoryBean.

*** AOP和事务配置:(\*****)**

*** 基于注解事务管理:(\*****)**

 

SSH整合:

\* SSH整合(带有hibernate配置文件)

\* 导包:

\* 配置文件:

\* Struts2+Spring

\* 两种方式:

\* Action的类由Struts框架创建.

\* Action的类由Spring框架创建.(scope=”prototype”)

\* Spring+Hibernate:

\* 在Spring框架中引入Hibernate的配置文件.

\* 管理事务:

\* DAO中注入sessionFactory.

 

\* SSH整合(不带Hibernate配置文件)

\* 导包:

\* 配置文件:

\* Struts2+Spring

\* 两种方式:

\* Action的类由Struts框架创建.

\* Action的类由Spring框架创建.(scope=”prototype”)

\* Spring+Hibernate

\* 把Hibernate配置信息配置到Spring中

\* 管理事务:

\* DAO中注入sessionFactory.

 

\* SSH注解.(**)

\* Struts2:

\* 在Action的类上

\* @Namespace(“/”)

\* @ParentPackage("struts-default")

 

\* 在要执行的方法上:

\* @Action

 

\* 把Action/Service/Dao交给Spring.

\* Action:

@Controller("bookAction")

@Scope("prototype")

\* Service

@Service

\* Dao

@Repository

 

\* 配置Spring中自动扫描;

<context:component-scan base-package="cn.itcast.action,cn.itcast.service,cn.itcast.dao"/>

 

\* 映射:

@Entity

@Table(name="book")

public class Book {

​	@Id

​	@GeneratedValue(strategy=GenerationType.IDENTITY)

​	private Integer id;

​	@Column(name="name")

private String name;

...

}

\* 配置SessionFactory:

<!-- 配置Hibernate的其他属性: -->

​	<bean id="sessionFactory" class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean">

​		<property name="dataSource" ref="dataSource"/>

​		<!-- 配置Hibernate的属性 -->

​		<property name="hibernateProperties">

​			<props>

​				<prop key="hibernate.dialect">org.hibernate.dialect.MySQLDialect</prop>

​				<prop key="hibernate.show_sql">true</prop>

​				<prop key="hibernate.format_sql">true</prop>

​				<prop key="hibernate.hbm2ddl.auto">update</prop>

​				<prop key="hibernate.connection.autocommit">false</prop>

​			</props>

​		</property>

​		<!-- 映射扫描 -->

​		<property name="packagesToScan">

​			<list>

​				<value>cn.itcast.vo</value>

​			</list>

​		</property>

​	</bean>

 

\* 事务管理:

​	<!-- 事务管理器 -->

​	<bean id="transactionManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">

​		<property name="sessionFactory" ref="sessionFactory"/>

​	</bean>

​	

​	<tx:annotation-driven transaction-manager="transactionManager"/>

 

\* DAO中使用Hibernate模板:

\* 手动注入HibernateTemplate :

​	<bean id="hibernateTemplate" class="org.springframework.orm.hibernate3.HibernateTemplate">

​		<property name="sessionFactory" ref="sessionFactory"/>

​	</bean>

\* 在Dao中

​	@Autowired

​	@Qualifier("hibernateTemplate")

​	private HibernateTemplate hibernateTemplate;
