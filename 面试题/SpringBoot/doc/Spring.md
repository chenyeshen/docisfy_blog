# spring

#### 1. 解释Spring支持的几种bean的作用域，作用域之间有什么区别

答： Spring框架支持以下五种bean的作用域：

singleton : bean在每个Spring ioc 容器中只有一个实例。

prototype：一个bean的定义可以有多个实例。

request：每次http请求都会创建一个bean，该作用域仅在基于web的Spring ApplicationContext情形下有效。

session：在一个HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的Spring ApplicationContext情形下有效。

global-session：在一个全局的HTTP Session中，一个bean定义对应一个实例。该作用域仅在基于web的Spring ApplicationContext情形下有效。

缺省的Spring bean 的作用域是Singleton.

#### 2. BeanFactory和ApplicationContext有什么区别？

答： BeanFactory 可以理解为含有bean集合的工厂类。BeanFactory 包含了种bean的定义，以便在接收到客户端请求时将对应的bean实例化。

​          BeanFactory还能在实例化对象的时生成协作类之间的关系。此举将bean自身与bean客户端的配置中解放出来。BeanFactory还包含了bean生命周期的控制，调用客户端的初始化方法（initialization methods）和销毁方法（destruction methods）。

从表面上看，application context如同bean factory一样具有bean定义、bean关联关系的设置，根据请求分发bean的功能。但application context在此基础上还提供了其他的功能。

#### 3. Spring框架中的单例bean是线程安全的吗?

答：不，Spring框架中的单例bean不是线程安全的。

#### 4. 解释Spring框架中bean的生命周期。

答：Spring容器 从XML 文件中读取bean的定义，并实例化bean。

Spring根据bean的定义填充所有的属性。

如果bean实现了BeanNameAware 接口，Spring 传递bean 的ID 到 setBeanName方法。

如果Bean 实现了 BeanFactoryAware 接口， Spring传递beanfactory 给setBeanFactory 方法。

如果有任何与bean相关联的BeanPostProcessors，Spring会在postProcesserBeforeInitialization()方法内调用它们。

如果bean实现IntializingBean了，调用它的afterPropertySet方法，如果bean声明了初始化方法，调用此初始化方法。

如果有BeanPostProcessors 和bean 关联，这些bean的postProcessAfterInitialization() 方法将被调用。

如果bean实现了 DisposableBean，它将调用destroy()方法

#### 5. 什么是 spring bean？

它们是构成用户应用程序主干的对象。

Bean 由 Spring IoC 容器管理。

它们由 Spring IoC 容器实例化，配置，装配和管理。

Bean 是基于用户提供给容器的配置元数据创建

 

#### 6. 在 Spring中如何注入一个java集合？

答：Spring提供以下几种集合的配置元素：

· <list>类型用于注入一列值，允许有相同的值。

· <set> 类型用于注入一组值，不允许有相同的值。

· <map> 类型用于注入一组键值对，键和值都可以为任意类型。

· <props>类型用于注入一组键值对，键和值都只能为String类型

#### 7. 什么是bean装配?

答：装配，或bean 装配是指在Spring 容器中把bean组装到一起，前提是容器需要知道bean的依赖关系，如何通过依赖注入来把它们装配到一起。

#### 8. 什么是bean的自动装配？

答：Spring 容器能够自动装配相互合作的bean，这意味着容器不需要<constructor-arg>和<property>配置，能通过Bean工厂自动处理bean之间的协作。

#### 9. Spring有几种自动装配方式，不同方式的自动装配的区别

答：有五种自动装配的方式，可以用来指导Spring容器用自动装配方式来进行依赖注入。

· no：默认的方式是不进行自动装配，通过显式设置ref 属性来进行装配。

· byName：通过参数名 自动装配，Spring容器在配置文件中发现bean的autowire属性被设置成byname，之后容器试图匹配、装配和该bean的属性具有相同名字的bean。

· byType:：通过参数类型自动装配，Spring容器在配置文件中发现bean的autowire属性被设置成byType，之后容器试图匹配、装配和该bean的属性具有相同类型的bean。如果有多个bean符合条件，则抛出错误。

· constructor：这个方式类似于byType， 但是要提供给构造器参数，如果没有确定的带参数的构造器参数类型，将会抛出异常。

· autodetect：首先尝试使用constructor来自动装配，如果无法工作，则使用byType方式。

#### 10. 自动装配有哪些局限性 ?

答：自动装配的局限性是：

· 重写： 你仍需用 <constructor-arg>和 <property> 配置来定义依赖，意味着总要重写自动装配。

· 基本数据类型：你不能自动装配简单的属性，如基本数据类型，String字符串，和类。

· 模糊特性：自动装配不如显式装配精确，如果有可能，建议使用显式装配。

#### 11. Spring DI 的三种方式?

(1)构造器注入：通过构造方法初始化

<constructor-arg index="0" type="java.lang.String" value="宝马"></constructor-arg>

(2)setter方法注入：通过setter方法初始化

<property name="id" value="1111"></property>

(3)接口注入

#### 12. Spring IoC 的实现机制

Spring 中的 IoC 的实现原理就是工厂模式加反射机制。

#### 13. Spring MVC接收一个List数组集合对象，具体应该怎么实现？

 

#### 14. 什么是 AOP？

AOP(Aspect-Oriented Programming), 即 面向切面编程, 它与 OOP( Object-Oriented Programming, 面向对象编程) 相辅相成, 提供了与 OOP 不同的抽象软件结构的视角.在 OOP 中, 我们以类(class)作为我们的基本单元, 而 AOP 中的基本单元是 Aspect(切面)

#### 15. 什么是 Aspect？

aspect 由 pointcount 和 advice 组成, 它既包含了横切逻辑的定义, 也包括了连接点的定义. Spring AOP 就是负责实施切面的框架, 它将切面所定义的横切逻辑编织到切面所指定的连接点中.

AOP 的工作重心在于如何将增强编织目标对象的连接点上, 这里包含两个工作:

如何通过 pointcut 和 advice 定位到特定的 joinpoint 上

如何在 advice 中编写切面代码.

可以简单地认为, 使用 @Aspect 注解的类就是切面.

#### 16. AOP 有哪些实现方式？

实现 AOP 的技术，主要分为两大类：

静态代理 - 指使用 AOP 框架提供的命令进行编译，从而在编译阶段就可生成 AOP 代理类，因此也称为编译时增强；

编译时编织（特殊编译器实现）

类加载时编织（特殊的类加载器实现）。

动态代理 - 在运行时在内存中“临时”生成 AOP 动态代理类，因此也被称为运行时增强。

JDK 动态代理

CGLIB

#### 17. IOC，AOP的实现原理？

IOC：通过反射机制生成对象注入

AOP：动态代理

#### 18. Spring AOP and AspectJ AOP 有什么区别？

Spring AOP 基于动态代理方式实现；AspectJ 基于静态代理方式实现。
Spring AOP 仅支持方法级别的 PointCut；提供了完全的 AOP 支持，它还支持属性级别的 PointCut

#### 19. spring aop的底层原理是什么？拦截器的优势有哪些？

Spring AOP的底层都是通过代理来实现的

一种是基于JDK的动态代理

一种是基于CgLIB的动态代理

拦截器是基于Java反射机制实现的，使用代理模式

拦截器不依赖于servlet容器

拦截器只能对action请求起作用

拦截器可以访问action上下文

拦截器可以获取IOC容器中的各个bean

在action生命周期中，拦截器可以被多次调用

#### 20. AOP是底层实现方式有几大类，实现原理是怎样的

答：实现AOP的技术，主要分为两大类：

一是采用动态代理技术，利用截取消息的方式，对该消息进行装饰，以取代原有对象行为的执行；

二是采用静态织入的方式，引入特定的语法创建“方面”，从而使得编译器可以在编译期间织入有关“方面”的代码。

Spring AOP 的实现原理其实很简单：AOP 框架负责动态地生成 AOP 代理类，这个代理类的方法则由 Advice 和回调目标对象的方法所组成,并将该对象可作为目标对象使用。AOP 代理包含了目标对象的全部方法，但 AOP 代理中的方法与目标对象的方法存在差异，AOP 方法在特定切入点添加了增强处理，并回调了目标对象的方法。

 Spring AOP使用动态代理技术在运行期织入增强代码。

使用两种代理机制：基于JDK的动态代理（JDK本身只提供接口的代理）；基于CGlib的动态代理。

(1) JDK的动态代理主要涉及java.lang.reflect包中的两个类：Proxy和InvocationHandler。其中InvocationHandler只是一个接口，可以通过实现该接口定义横切逻辑，并通过反射机制调用目标类的代码，动态的将横切逻辑与业务逻辑织在一起。而Proxy利用InvocationHandler动态创建一个符合某一接口的实例，生成目标类的代理对象。 其代理对象必须是某个接口的实现,它是通过在运行期间创建一个接口的实现类来完成对目标对象的代理.只能实现接口的类生成代理,而不能针对类

(2) CGLib采用底层的字节码技术，为一个类创建子类，并在子类中采用方法拦截的技术拦截所有父类的调用方法，并顺势织入横切逻辑.它运行期间生成的代理对象是目标类的扩展子类.所以无法通知final的方法,因为它们不能被覆写.是针对类实现代理,主要是为指定的类生成一个子类,覆盖其中方法.在spring中默认情况下使用JDK动态代理实现AOP,如果proxy-target-class设置为true或者使用了优化策略那么会使用CGLIB来创建动态代理.Spring　AOP在这两种方式的实现上基本一样．以JDK代理为例，会使用JdkDynamicAopProxy来创建代理，在invoke()方法首先需要织入到当前类的增强器封装到拦截器链中，然后递归的调用这些拦截器完成功能的织入．最终返回代理对象．

#### 21. Spring AOP 代理的实现，底层实现有哪两种方式

Spring AOP的底层实现有两种方式：一种是JDK动态代理，另一种是CGLib的方式。

自Java 1.3以后，Java提供了动态代理技术，允许开发者在运行期创建接口的代理实例，后来这项技术被用到了Spring的很多地方。

JDK动态代理主要涉及java.lang.reflect包下边的两个类：Proxy和InvocationHandler。其中，InvocationHandler是一个接口，可以通过实现该接口定义横切逻辑，并通过反射机制调用目标类的代码，动态地将横切逻辑和业务逻辑贬值在一起。

JDK动态代理的话，他有一个限制，就是它只能为接口创建代理实例，而对于没有通过接口定义业务方法的类，如何创建动态代理实例哪？答案就是CGLib。

CGLib采用底层的字节码技术，全称是：Code Generation Library，CGLib可以为一个类创建一个子类，在子类中采用方法拦截的技术拦截所有父类方法的调用并顺势织入横切逻辑。

1、如果目标对象实现了接口，默认情况下会采用JDK的动态代理实现AOP 
2、如果目标对象实现了接口，可以强制使用CGLIB实现AOP 

#### 22. 什么是代理?

答：代理是通知目标对象后创建的对象。从客户端的角度看，代理对象和目标对象是一样的。

#### 23. 写一个静态代理代理

 

#### 24. 静态代理和动态代理的区别

动态代理是区别于静态代理而言，主要区别在于：静态代理在编译阶段已经明确了代理类，而且一个代理类只能代理一个特定的目标类，这样的设计存在扩展性的问题，在扩展和后期维护方面会带来很多问题；动态代理的代理类是由程序在运行阶段动态生成，而且动态生成的代理类可以代理任何目标类

#### 25. 静态代理的缺点

(1)代理类和委托类实现了相同的接口，代理类通过委托类实现了相同的方法。这样就出现了大量的代码重复。如果接口增加一个方法，除了所有实现类需要实现这个方法外，所有代理类也需要实现此方法。增加了代码维护的复杂度。

(2)代理对象只服务于一种类型的对象，如果要服务多类型的对象。势必要为每一种对象都进行代理，静态代理在程序规模稍大时就无法胜任了。如代码是只为UserManager类的访问提供了代理，但是如果还要为其他类如Department类提供代理的话，就需要我们再次添加代理Department的代理类

#### 26. JDK 动态代理的实现

JDK代理是不需要以来第三方的库，只要要JDK环境就可以进行代理，它有几个要求

\* 实现InvocationHandler ，其中InvocationHandler接口是通用处理器接口，程序中需要实现它来构造我们自己的处理器；

\* 使用Proxy.newProxyInstance产生代理对象

\* 被代理的对象必须要实现接口

#### 27. 如何理解 Spring 中的代理？

将 Advice 应用于目标对象后创建的对象称为代理。在客户端对象的情况下，目标对象和代理对象是相同的。

Advice + Target Object = Proxy

#### 28. 有几种不同类型的自动代理？

答：BeanNameAutoProxyCreator

DefaultAdvisorAutoProxyCreator

Metadata autoproxying

#### 29. JDK动态代理具体实现原理：

通过实现InvocationHandlet接口创建自己的调用处理器；

通过为Proxy类指定ClassLoader对象和一组interface来创建动态代理；

通过反射机制获取动态代理类的构造函数，其唯一参数类型就是调用处理器接口类型；

通过构造函数创建动态代理类实例，构造时调用处理器对象作为参数参入；

JDK动态代理是面向接口的代理模式，如果被代理目标没有接口那么Spring也无能为力，Spring通过Java的反射机制生产被代理接口的新的匿名实现类，重写了其中AOP的增强方法

#### 30. JDK动态代理实现步骤

（1）创建被代理对象的接口类。

（2）创建具体被代理对象接口的实现类。

（3）创建一个InvocationHandler的实现类，并持有被代理对象的引用。然后在invoke方法中利用反射调用被代理对象的方法。

（4）利用Proxy.newProxyInstance方法创建代理对象，利用代理对象实现真实对象方法的调用。

#### 31. JDK动态代理实现示例代码

https://www.jianshu.com/p/3caa0c23a157

#### 32. 什么是CGLib动态代理

CGLib是一个强大、高性能的Code生产类库，可以实现运行期动态扩展java类，Spring在运行期间通过 CGlib继承要被动态代理的类，重写父类的方法，实现AOP面向切面编程呢。

cglib动态代理是利用asm开源包，对代理对象类的class文件加载进来，通过修改其字节码生成子类来处理。

#### 33. CGLIB实现动态代理的步骤：

（1）创建被代理的目标类。

（2）创建一个方法拦截器类，并实现CGLIB的MethodInterceptor接口的intercept()方法。

（3）通过Enhancer类增强工具，创建目标类的代理类。

（4）利用代理类进行方法调用，就像调用真实的目标类方法一样

#### 34. JDK 和 CGLib动态代理区别

JDK动态代理是面向接口的，利用反射机制生成一个实现代理接口的匿名类，在调用具体方法前调用InvokeHandler来处理。而cglib动态代理是利用asm开源包，对代理对象类的class文件加载进来，通过修改其字节码生成子类来处理。

jdk的动态代理是基于接口的，必须实现了某一个或多个任意接口才可以被代理，并且只有这些接口中的方法会被代理

JDK代理是不需要以来第三方的库，只要要JDK环境就可以进行代理，它有几个要求

\* 实现InvocationHandler 

\* 使用Proxy.newProxyInstance产生代理对象

\* 被代理的对象必须要实现接口

 

cglib是针对类来实现代理的，他的原理是对指定的目标类生成一个子类，并覆盖其中的方法实现增强，但因为采用的是继承，所以不能对final修饰的类进行代理。

CGLib动态代理是通过字节码底层继承要代理类来实现（如果被代理类被final关键字所修饰，那么抱歉会失败）。

CGLib 必须依赖于CGLib的类库，但是它需要类来实现任何接口代理的是指定的类生成一个子类，覆盖其中的方法，是一种继承但是针对接口编程的环境下推荐使用JDK的代理

在Hibernate中的拦截器其实现考虑到不需要其他接口的条件Hibernate中的相关代理采用的是CGLib来执行.

注意：

如果要被代理的对象是个实现类，那么Spring会使用JDK动态代理来完成操作（Spirng默认采用JDK动态代理实现机制）；

如果要被代理的对象不是个实现类那么，Spring会强制使用CGLib来实现动态代理。

#### 35. JDK和 CGLIB 动态代理各自的缺点

JDK 动态代理只能基于接口进行代理，CGLIB 动态代理无法处理final的情况（final修饰的方法不能被覆写），必须依赖第三方库

#### 36. JDK动态代理和CGLIB字节码生成的区别？

(1) JDK动态代理只能对实现了接口的类生成代理，而不能针对类

(2) CGLIB是针对类实现代理，主要是对指定的类生成一个子类，覆盖其中的方法

因为是继承，所以该类或方法最好不要声明成final 

#### 37. 如何强制使用CGLIB实现AOP？

(1)添加CGLIB库，SPRING_HOME/cglib/*.jar

(2)在spring配置文件中加入<aop:aspectj-autoproxy proxy-target-class="true"/>

#### 38. 在Spring AOP 中，关注点和横切关注的区别是什么？

答：关注点是应用中一个模块行为，一个关注点可能会被定义成一个我们想实现的一个功能。
横切关注点是一个关注点，此关注点是整个应用都会使用的功能，并影响整个应用，比如日志，安全和数据传输，几乎应用的每个模块都需要的功能。因此这些都属于横切关注点。

#### 39. 什么是连接点

答：连接点代表一个应用程序的某个位置，在这个位置我们可以插入一个AOP切面，它实际上是个应用程序执行Spring AOP的位置。

#### 40. 什么是通知（Advice）？

特定 JoinPoint 处的 Aspect 所采取的动作称为 Advice。Spring AOP 使用一个 Advice 作为拦截器，在 JoinPoint “周围”维护一系列的拦截器。

#### 41. 通知有哪些类型

答：通知是个在方法执行前或执行后要做的动作，实际上是程序执行时要通过SpringAOP框架触发的代码段。

Spring切面可以应用五种类型的通知：

· before：前置通知，在一个方法执行前被调用。

· after: 在方法执行之后调用的通知，无论方法执行是否成功。

· after-returning: 仅当方法成功完成后执行的通知。

· after-throwing: 在方法抛出异常退出时执行的通知。

· around: 在方法执行之前和之后调用的通知。

#### 42. 指出在 spring aop 中 concern 和 cross-cutting concern 的不同之处。

concern 是我们想要在应用程序的特定模块中定义的行为。它可以定义为我们想要实现的功能。

cross-cutting concern 是一个适用于整个应用的行为，这会影响整个应用程序。例如，日志记录，安全性和数据传输是应用程序几乎每个模块都需要关注的问题，因此它们是跨领域的问题。

#### 43. 什么是切点

答：切入点是一个或一组连接点，通知将在这些位置执行。可以通过表达式或匹配的方式指明切入点。

#### 44. 什么是引入?

答：引入允许我们在已存在的类中增加新的方法和属性。

#### 45. 什么是目标对象?

答：被一个或者多个切面所通知的对象。它通常是一个代理对象。也指被通知（advised）对象。

#### 46. 什么是织入。什么是织入应用的不同点？

答：织入是将切面和到其他应用类型或对象连接或创建一个被通知对象的过程。

织入可以在编译时，加载时，或运行时完成。

#### 47. 什么是编织（Weaving）？

为了创建一个 advice 对象而链接一个 aspect 和其它应用类型或对象，称为编织（Weaving）。在 Spring AOP 中，编织在运行时执行。请参考下图：

![img](file:///C:\Users\yeshen\AppData\Local\Temp\ksohtml3824\wps8.jpg) 

#### 48. 解释基于XML Schema方式的切面实现

答：在这种情况下，切面由常规类以及基于XML的配置实现。

#### 49. 解释基于注解的切面实现

答：在这种情况下(基于@AspectJ的实现)，涉及到的切面声明的风格与带有java5标注的普通java类一致。

#### 50. Spring支持的事务管理类型有几种方式？

答：Spring支持如下两种方式的事务管理： 编码式事务管理：sping对编码式事务的支持与EJB有很大区别，不像EJB与java事务API耦合在一起．spring通过回调机制将实际的事务实现从事务性代码中抽象出来．你能够精确控制事务的边界，它们的开始和结束完全取决于你． 声明式事务管理：这种方式意味着你可以将事务管理和业务代码分离。你只需要通过注解或者XML配置管理事务。通过传播行为，隔离级别，回滚规则，事务超时，只读提示来定义．

#### 51. Spring框架的事务管理有哪些优点

答：ACID

原子性(Atomic):一个操作要么成功，要么全部不执行.

一致性(Consistent): 一旦事务完成，系统必须确保它所建模业务处于一致的状态

隔离性(Isolated): 事务允许多个用户对相同的数据进行操作，每个用户用户的操作相互隔离互补影响．

持久性(Durable): 一旦事务完成，事务的结果应该持久化．

#### 52. Spring的编程式事务与声明式事务区别

答：程式事务需要你在代码中直接加入处理事 务的逻辑,可能需要在代码中显式调用beginTransaction()、commit()、rollback()等事务管理相关的方法,如在执行a方 法时候需要事务处理,你需要在a方法开始时候开启事务,处理完后。在方法结束时候,关闭事务.声明式的事务的做法是在a方法外围添加注解或者直接在配置文件中定义,a方法需要事务处理,在spring中会通过配置文件在a方法前后拦截,并添加事务.
二者区别.编程式事务侵入性比较强，但处理粒度更细.

#### 53. spring事物的隔离级别有哪些

答：事务的隔离级别：

数据库系统提供了4种事务隔离级别，在这4种隔离级别中，Serializable的隔离级别最高，Read Uncommitted的隔离级别最低；

· Read Uncommitted   读未提交数据；（会出现脏读）

· Read Committed      读已提交数据；

· Repeatable Read       可重复读；

· Serializable              串行化 

#### 54. 事务的传播属性包括哪些

答： Required   业务方法需要在一个事务中运行，如果一个方法运行时已经处在一个事务中，那么加入到该事务，否则为自己创建一个新事务，80%的方法用到该传播属性；

· Not-Supported· Requiresnew· Mandatoky· Supports· Never· Nested

#### 55. @ResponseBody 忽略属性的某字段

答： @JsonIgnore