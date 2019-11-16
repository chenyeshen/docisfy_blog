你是否因为项目出现问题，查找日志文件定位错误花费N多时间，是否为此苦不堪言，没关系！现在通过这篇文章，将彻底解决你的烦恼，这篇文篇介绍，如何通过`logback`配置文件将日志进行分级打印，一个配置文件彻底搞定日志查找得烦恼。

## 构建工程

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>cn.zhangbox</groupId>
        <artifactId>spring-boot-study</artifactId>
        <version>1.0-SNAPSHOT</version>
    </parent>

    <groupId>cn.zhangbox</groupId>
    <artifactId>spring-boot-log</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>jar</packaging>

    <name>spring-boot-logging</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>


```

## 修改YML配置

```
#选择哪一个环境的配置
#这里可以在每个环境配置redis，数据库（mysql），消息（kafka）等相关的组件的配置
spring:
  profiles:
    active: dev

#文档块区分为三个---
---
server:
  port: 8081
spring:
  profiles: dev
#日志
logging:
#日志配置文件位置
  config: classpath:log/logback.xml
#日志打印位置，这里是默认在项目根路径下
  path: log/spring-boot-log

#文档块区分为三个---
---
server:
  port: 8082
spring:
  profiles: test
#日志
logging:
#日志配置文件位置
  config: classpath:log/logback.xml
#日志打印位置，这里是默认在项目根路径下
  path: usr/spring-boot/log/spring-boot-log

#文档块区分为三个---
---
server:
  port: 8083
spring:
  profiles: prod
#日志
logging:
#日志配置文件位置
  config: classpath:log/logback.xml
#日志打印位置，这里是默认在项目根路径下
  path: usr/spring-boot/log/spring-boot-log

```

## 创建日志配置文件

在工程`resources`文件夹下新建文件夹`log`，并在该文件夹下创建`logback.xml`文件,加入以下配置：

```
     <!-- Logback configuration. See http://logback.qos.ch/manual/index.html -->
        <configuration scan="true" scanPeriod="10 seconds">
            <!--继承spring boot提供的logback配置-->
            <!--<include resource="org/springframework/boot/logging/logback/base.xml" />-->
        
            <!--设置系统日志目录-->
            <property name="APP_DIR" value="spring-boot-log"/>
        
            <!-- 彩色日志 -->
            <!-- 彩色日志依赖的渲染类 -->
            <conversionRule conversionWord="clr" converterClass="org.springframework.boot.logging.logback.ColorConverter"/>
            <conversionRule conversionWord="wex" converterClass="org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter"/>
            <conversionRule conversionWord="wEx" converterClass="org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter"/>
            <!-- 彩色日志格式 -->
            <property name="CONSOLE_LOG_PATTERN" value="${CONSOLE_LOG_PATTERN:-%clr(%d{yyyy-MM-dd HH:mm:ss.SSS}){faint} %clr(${LOG_LEVEL_PATTERN:-%5p}) %clr(${PID:- }){magenta} %clr(---){faint} %clr([%15.15t]){faint} %clr(%-40.40logger{39}){cyan} %clr(:){faint} %m%n${LOG_EXCEPTION_CONVERSION_WORD:-%wEx}}"/>
        
            <!-- 控制台输出 -->
            <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
                <encoder>
                    <Pattern>${CONSOLE_LOG_PATTERN}</Pattern>
                    <charset>UTF-8</charset> <!-- 此处设置字符集 -->
                </encoder>
                <!--此日志appender是为开发使用，只配置最底级别，控制台输出的日志级别是大于或等于此级别的日志信息-->
                <filter class="ch.qos.logback.classic.filter.ThresholdFilter">
                    <level>debug</level>
                </filter>
            </appender>
        
            <!-- 时间滚动输出 level为 DEBUG 日志 -->
            <appender name="DEBUG_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
                <!-- 正在记录的日志文件的路径及文件名 -->
                <file>${LOG_PATH}/log_debug.log</file>
                <!--日志文件输出格式-->
                <encoder>
                    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
                    <charset>UTF-8</charset> <!-- 此处设置字符集 -->
                </encoder>
                <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
                <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                    <!-- 归档的日志文件的路径，例如今天是2017-04-26日志，当前写的日志文件路径为file节点指定，可以将此文件与file指定文件路径设置为不同路径，从而将当前日志文件或归档日志文件置不同的目录。 而2017-04-26的日志文件在由fileNamePattern指定。%d{yyyy-MM-dd}指定日期格式，%i指定索引 -->
                    <fileNamePattern>${LOG_PATH}/debug/log-debug-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
                    <!-- 除按日志记录之外，还配置了日志文件不能超过500M，若超过500M，日志文件会以索引0开始， 命名日志文件，例如log-error-2017-04-26.0.log -->
                    <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                        <maxFileSize>500MB</maxFileSize>
                    </timeBasedFileNamingAndTriggeringPolicy>
                    <!--日志文件保留天数-->
                    <maxHistory>30</maxHistory>
                </rollingPolicy>
                <!-- 此日志文件只记录debug级别的 -->
                <filter class="ch.qos.logback.classic.filter.LevelFilter">
                    <level>debug</level>
                    <onMatch>ACCEPT</onMatch>
                    <onMismatch>DENY</onMismatch>
                </filter>
            </appender>
        
            <!-- 时间滚动输出 level为 INFO 日志 -->
            <appender name="INFO_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
                <!-- 正在记录的日志文件的路径及文件名 -->
                <file>${LOG_PATH}/log_info.log</file>
                <!--日志文件输出格式-->
                <encoder>
                    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
                    <charset>UTF-8</charset> <!-- 此处设置字符集 -->
                </encoder>
                <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
                <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                    <!-- 归档的日志文件的路径，例如今天是2017-04-26日志，当前写的日志文件路径为file节点指定，可以将此文件与file指定文件路径设置为不同路径，从而将当前日志文件或归档日志文件置不同的目录。 而2017-04-26的日志文件在由fileNamePattern指定。%d{yyyy-MM-dd}指定日期格式，%i指定索引 -->
                    <fileNamePattern>${LOG_PATH}/info/log-info-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
                    <!-- 除按日志记录之外，还配置了日志文件不能超过500M，若超过500M，日志文件会以索引0开始， 命名日志文件，例如log-error-2017-04-26.0.log -->
                    <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                        <maxFileSize>500MB</maxFileSize>
                    </timeBasedFileNamingAndTriggeringPolicy>
                    <!--日志文件保留天数-->
                    <maxHistory>30</maxHistory>
                </rollingPolicy>
                <!-- 此日志文件只记录info级别的 -->
                <filter class="ch.qos.logback.classic.filter.LevelFilter">
                    <level>info</level>
                    <onMatch>ACCEPT</onMatch>
                    <onMismatch>DENY</onMismatch>
                </filter>
            </appender>
        
            <!-- 时间滚动输出 level为 WARN 日志 -->
            <appender name="WARN_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
                <!-- 正在记录的日志文件的路径及文件名 -->
                <file>${LOG_PATH}/log_warn.log</file>
                <!--日志文件输出格式-->
                <encoder>
                    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
                    <charset>UTF-8</charset> <!-- 此处设置字符集 -->
                </encoder>
                <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
                <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                    <!-- 归档的日志文件的路径，例如今天是2017-04-26日志，当前写的日志文件路径为file节点指定，可以将此文件与file指定文件路径设置为不同路径，从而将当前日志文件或归档日志文件置不同的目录。 而2017-04-26的日志文件在由fileNamePattern指定。%d{yyyy-MM-dd}指定日期格式，%i指定索引 -->
                    <fileNamePattern>${LOG_PATH}/warn/log-warn-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
                    <!-- 除按日志记录之外，还配置了日志文件不能超过500M，若超过500M，日志文件会以索引0开始， 命名日志文件，例如log-error-2017-04-26.0.log -->
                    <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                        <maxFileSize>500MB</maxFileSize>
                    </timeBasedFileNamingAndTriggeringPolicy>
                    <!--日志文件保留天数-->
                    <maxHistory>30</maxHistory>
                </rollingPolicy>
                <!-- 此日志文件只记录warn级别的 -->
                <filter class="ch.qos.logback.classic.filter.LevelFilter">
                    <level>warn</level>
                    <onMatch>ACCEPT</onMatch>
                    <onMismatch>DENY</onMismatch>
                </filter>
            </appender>
        
            <!-- 时间滚动输出 level为 ERROR 日志 -->
            <appender name="ERROR_FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
                <!-- 正在记录的日志文件的路径及文件名 -->
                <file>${LOG_PATH}/log_error.log</file>
                <!--日志文件输出格式-->
                <encoder>
                    <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level %logger{50} - %msg%n</pattern>
                    <charset>UTF-8</charset> <!-- 此处设置字符集 -->
                </encoder>
                <!-- 日志记录器的滚动策略，按日期，按大小记录 -->
                <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
                    <!-- 归档的日志文件的路径，例如今天是2017-04-26日志，当前写的日志文件路径为file节点指定，可以将此文件与file指定文件路径设置为不同路径，从而将当前日志文件或归档日志文件置不同的目录。 而2017-04-26的日志文件在由fileNamePattern指定。%d{yyyy-MM-dd}指定日期格式，%i指定索引 -->
                    <fileNamePattern>${LOG_PATH}/error/log-error-%d{yyyy-MM-dd}.%i.log</fileNamePattern>
                    <!-- 除按日志记录之外，还配置了日志文件不能超过500M，若超过500M，日志文件会以索引0开始， 命名日志文件，例如log-error-2017-04-26.0.log -->
                    <timeBasedFileNamingAndTriggeringPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedFNATP">
                        <maxFileSize>500MB</maxFileSize>
                    </timeBasedFileNamingAndTriggeringPolicy>
                    <!--日志文件保留天数-->
                    <maxHistory>30</maxHistory>
                </rollingPolicy>
                <!-- 此日志文件只记录ERROR级别的 -->
                <filter class="ch.qos.logback.classic.filter.LevelFilter">
                    <level>error</level>
                    <onMatch>ACCEPT</onMatch>
                    <onMismatch>DENY</onMismatch>
                </filter>
            </appender>
        
            <logger name="org.springframework.web" level="info"/>
            <logger name="org.springframework.scheduling.annotation.ScheduledAnnotationBeanPostProcessor" level="INFO"/>
            <logger name="cn.zhangbox.springboot" level="debug"/>
        
            <!--开发环境:打印控制台-->
            <springProfile name="dev">
                <root level="info">
                    <appender-ref ref="CONSOLE"/>
                    <appender-ref ref="DEBUG_FILE"/>
                    <appender-ref ref="INFO_FILE"/>
                    <appender-ref ref="WARN_FILE"/>
                    <appender-ref ref="ERROR_FILE"/>
                </root>
            </springProfile>
        
            <!--测试环境:打印控制台和输出到文件-->
            <springProfile name="test">
                <root level="info">
                    <appender-ref ref="CONSOLE"/>
                    <appender-ref ref="INFO_FILE"/>
                    <appender-ref ref="WARN_FILE"/>
                    <appender-ref ref="ERROR_FILE"/>
                </root>
            </springProfile>
        
            <!--生产环境:输出到文件-->
            <springProfile name="prod">
                <root level="error">
                    <appender-ref ref="CONSOLE"/>
                    <appender-ref ref="DEBUG_FILE"/>
                    <appender-ref ref="INFO_FILE"/>
                    <appender-ref ref="ERROR_FILE"/>
                </root>
            </springProfile>
        
        </configuration>

```

**注意**：`loback`配置文件中

```
<logger name="cn.zhangbox.springboot" level="debug"/>

```

`name`的属性值一定要是当前工程的`java`代码的完整目录,因为`mybatis`打印的日志级别是`debug`级别的，因此需要配置`debug`级别日志扫描的目录。

## 创建启动类

```
    @SpringBootApplication
    public class SpringBootConfigApplication {
    
        public static void main(String[] args) {
            SpringApplication.run(SpringBootConfigApplication.class, args);
        }
    }

```

## 控制台打印

```
  .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __ __ _ \ \ \ \ ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.5.3.RELEASE)

2018-07-05 15:05:13.680  INFO 15060 --- [           main] c.z.s.SpringBootLoggingApplication       : Starting SpringBootLoggingApplication on MS-20180428GSYE with PID 15060 (started by Administrator in D:\开源项目\spring-boot-study)
2018-07-05 15:05:13.685 DEBUG 15060 --- [           main] c.z.s.SpringBootLoggingApplication       : Running with Spring Boot v1.5.3.RELEASE, Spring v4.3.8.RELEASE
2018-07-05 15:05:13.686  INFO 15060 --- [           main] c.z.s.SpringBootLoggingApplication       : The following profiles are active: dev
2018-07-05 15:05:13.766  INFO 15060 --- [           main] ationConfigEmbeddedWebApplicationContext : Refreshing org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@79d94571: startup date [Thu Jul 05 15:05:13 GMT+08:00 2018]; root of context hierarchy
2018-07-05 15:05:14.223  INFO 15060 --- [kground-preinit] o.h.validator.internal.util.Version      : HV000001: Hibernate Validator 5.3.5.Final
2018-07-05 15:05:15.550  INFO 15060 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat initialized with port(s): 8081 (http)
2018-07-05 15:05:15.563  INFO 15060 --- [           main] o.apache.catalina.core.StandardService   : Starting service Tomcat
2018-07-05 15:05:15.565  INFO 15060 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.14
2018-07-05 15:05:15.703  INFO 15060 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2018-07-05 15:05:15.704  INFO 15060 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 1938 ms
2018-07-05 15:05:15.869  INFO 15060 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Mapping servlet: 'dispatcherServlet' to [/]
2018-07-05 15:05:15.876  INFO 15060 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean   : Mapping filter: 'characterEncodingFilter' to: [/*] 2018-07-05 15:05:15.877 INFO 15060 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'hiddenHttpMethodFilter' to: [/*] 2018-07-05 15:05:15.877 INFO 15060 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'httpPutFormContentFilter' to: [/*] 2018-07-05 15:05:15.877 INFO 15060 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'requestContextFilter' to: [/*] 2018-07-05 15:05:16.219 INFO 15060 --- [ main] s.w.s.m.m.a.RequestMappingHandlerAdapter : Looking for @ControllerAdvice: org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@79d94571: startup date [Thu Jul 05 15:05:13 GMT+08:00 2018]; root of context hierarchy 2018-07-05 15:05:16.298 INFO 15060 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error]}" onto public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.BasicErrorController.error(javax.servlet.http.HttpServletRequest) 2018-07-05 15:05:16.299 INFO 15060 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error],produces=[text/html]}" onto public org.springframework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse) 2018-07-05 15:05:16.328 INFO 15060 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/webjars/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler] 2018-07-05 15:05:16.328 INFO 15060 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler] 2018-07-05 15:05:16.369 INFO 15060 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/**/favicon.ico] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2018-07-05 15:05:16.616  INFO 15060 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2018-07-05 15:05:16.636  INFO 15060 --- [           main] o.a.coyote.http11.Http11NioProtocol      : Initializing ProtocolHandler ["http-nio-8081"]
2018-07-05 15:05:16.645  INFO 15060 --- [           main] o.a.coyote.http11.Http11NioProtocol      : Starting ProtocolHandler ["http-nio-8081"]
2018-07-05 15:05:16.659  INFO 15060 --- [           main] o.a.tomcat.util.net.NioSelectorPool      : Using a shared selector for servlet write/read
2018-07-05 15:05:16.679  INFO 15060 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8081 (http)
2018-07-05 15:05:16.685  INFO 15060 --- [           main] c.z.s.SpringBootLoggingApplication       : Started SpringBootLoggingApplication in 4.291 seconds (JVM running for 5.767)

```

## 本地日志打印效果

![图片.png](https://upload-images.jianshu.io/upload_images/7109926-adee1cd9c97c04ba.png)
这里因为`logback`配置中将不同级别的日志设置了在不同文件中打印，这样很大程度上方便项目出问题查找问题。

