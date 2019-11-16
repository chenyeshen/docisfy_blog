# 创建数据库

在`mysql`中创建`student`库并执行下面查询创建`student`表

```
-- ----------------------------
-- Table structure for student
-- ----------------------------
DROP TABLE IF EXISTS `student`;
CREATE TABLE `student` (
  `sno` int(15) NOT NULL,
  `sname` varchar(50) DEFAULT NULL,
  `sex` char(2) DEFAULT NULL,
  `dept` varchar(25) DEFAULT NULL,
  `birth` date DEFAULT NULL,
  `age` int(3) DEFAULT NULL,
  PRIMARY KEY (`sno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of student
-- ----------------------------
INSERT INTO `student` VALUES ('1', '李同学', '1', '王同学学习成绩很不错', '2010-07-22', '17');

```

在`mysql`中创建`teacher`库并执行下面查询创建`teacher`表

```
-- ----------------------------
-- Table structure for teacher
-- ----------------------------
DROP TABLE IF EXISTS `teacher`;
CREATE TABLE `teacher` (
  `Tno` varchar(20) NOT NULL DEFAULT '',
  `Tname` varchar(50) DEFAULT NULL,
  `sex` char(2) DEFAULT NULL,
  `dept` varchar(25) DEFAULT NULL,
  `birth` date DEFAULT NULL,
  `age` int(3) DEFAULT NULL,
  PRIMARY KEY (`Tno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of teacher
-- ----------------------------
INSERT INTO `teacher` VALUES ('1', '王老师', '1', '王老师上课很认真', '2018-07-06', '35');


```

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
	<artifactId>spring-boot-mybatis-datasource</artifactId>
	<version>0.0.1-SNAPSHOT</version>
	<packaging>jar</packaging>

	<name>spring-boot-mybatis-datasource</name>
	<description>this project for Spring Boot</description>



	<properties>
		<project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
		<project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
		<java.version>1.8</java.version>
		<!-- 版本控制 -->
		<commons-lang3.version>3.4</commons-lang3.version>
		<commons-codec.version>1.10</commons-codec.version>
		<mybatis-spring-boot.version>1.2.0</mybatis-spring-boot.version>
		<lombok.version>1.16.14</lombok.version>
		<fastjson.version>1.2.41</fastjson.version>
		<druid.version>1.1.2</druid.version>
	</properties>

	<repositories>
		<!-- 阿里私服 -->
		<repository>
			<id>aliyunmaven</id>
			<url>http://maven.aliyun.com/nexus/content/groups/public/</url>
		</repository>
	</repositories>

	<dependencies>

		<!-- mybatis核心包 start -->
		<dependency>
			<groupId>org.mybatis.spring.boot</groupId>
			<artifactId>mybatis-spring-boot-starter</artifactId>
			<version>${mybatis-spring-boot.version}</version>
		</dependency>
		<!-- mybatis核心包 end -->

		<!-- SpringWEB核心包 start -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-web</artifactId>
		</dependency>
		<!-- SpringWEB核心包 end -->

		<!-- mysql驱动核心包 start -->
		<dependency>
			<groupId>mysql</groupId>
			<artifactId>mysql-connector-java</artifactId>
			<scope>runtime</scope>
		</dependency>
		<!-- mysql驱动核心包 end -->

		<!-- sprigTest核心包 start -->
		<dependency>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-starter-test</artifactId>
			<scope>test</scope>
		</dependency>
		<!-- sprigTest核心包 end -->

		<!-- commons工具核心包 start -->
		<dependency>
			<groupId>org.apache.commons</groupId>
			<artifactId>commons-lang3</artifactId>
			<version>${commons-lang3.version}</version>
		</dependency>
		<dependency>
			<groupId>commons-codec</groupId>
			<artifactId>commons-codec</artifactId>
			<version>${commons-codec.version}</version>
		</dependency>
		<!-- commons工具核心包 end -->

		<!-- fastjson核心包 start -->
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>fastjson</artifactId>
			<version>${fastjson.version}</version>
		</dependency>
		<!-- fastjson核心包 end -->

		<!-- druid核心包 start -->
		<dependency>
			<groupId>com.alibaba</groupId>
			<artifactId>druid-spring-boot-starter</artifactId>
			<version>${druid.version}</version>
		</dependency>
		<!-- druid核心包 end -->

		<!-- lombok核心包 start -->
		<dependency>
			<groupId>org.projectlombok</groupId>
			<artifactId>lombok</artifactId>
			<version>${lombok.version}</version>
		</dependency>
		<!-- lombok核心包 end -->
	</dependencies>

	<build>
		<finalName>spring-boot-mybatis-datasource</finalName>
		<plugins>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-compiler-plugin</artifactId>
			<version>3.5.1</version>
			<configuration>
				<source>1.8</source>
				<target>1.8</target>
				<encoding>UTF-8</encoding>
			</configuration>
		</plugin>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-surefire-plugin</artifactId>
			<version>2.19.1</version>
		</plugin>

		<plugin>
			<groupId>org.springframework.boot</groupId>
			<artifactId>spring-boot-maven-plugin</artifactId>
			<dependencies>
				<dependency>
					<groupId>org.springframework</groupId>
					<artifactId>springloaded</artifactId>
					<version>1.2.4.RELEASE</version>
				</dependency>
			</dependencies>
			<configuration>
				<mainClass>cn.zhangbox.admin.SpringBootDruidApplication</mainClass>
				<jvmArguments>-Dfile.encoding=UTF-8 -Xdebug
					-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005
				</jvmArguments>
				<executable>true</executable>
				<fork>true</fork>
			</configuration>
		</plugin>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
				<configuration>
					<mainClass>cn.zhangbox.admin.SpringBootDruidApplication</mainClass>
					<jvmArguments>-Dfile.encoding=UTF-8 -Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005</jvmArguments>
					<executable>true</executable>
					<fork>true</fork>
				</configuration>
			</plugin>
		</plugins>
	</build>

</project>

```

**注意**：这里引入了`lombok`插件节省编写实体类时候写`get`和`set`方法,这里在`idea`中进行`set`和`get`操作需要下载`lombok`插件,在设置页面的`plugins`中搜索`lombok`插件在中央插件库下载后重启`idea`即可,更详细的lombok使用教程可以查考:

## 程序员DD的lombok系列教程:

[Lombok：让JAVA代码更优雅](http://blog.didispace.com/java-lombok-1/)

## 修改YML配置

```
#公共配置
server:
    port: 80
    tomcat:
      uri-encoding: UTF-8
spring:
  #激活哪一个环境的配置文件
  profiles:
    active: dev
  #连接池配置
  datasource:
    #配置student库驱动和连接池
    student:
      driver-class-name: com.mysql.jdbc.Driver
      # 使用druid数据源
      type: com.alibaba.druid.pool.DruidDataSource
    #配置teacher库驱动和连接池
    teacher:
      driver-class-name: com.mysql.jdbc.Driver
      # 使用druid数据源
      type: com.alibaba.druid.pool.DruidDataSource
    druid:
      # 配置测试查询语句
      validationQuery: SELECT 1 FROM DUAL
      # 初始化大小，最小，最大
      initialSize: 10
      minIdle: 10
      maxActive: 200
      # 配置一个连接在池中最小生存的时间，单位是毫秒
      minEvictableIdleTimeMillis: 180000
      testOnBorrow: false
      testWhileIdle: true
      removeAbandoned: true
      removeAbandonedTimeout: 1800
      logAbandoned: true
      # 打开PSCache，并且指定每个连接上PSCache的大小
      poolPreparedStatements: true
      maxOpenPreparedStatements: 100
      # 配置监控统计拦截的filters，去掉后监控界面sql无法统计，'wall'用于防火墙
      filters: stat,wall,log4j
      # 通过connectProperties属性来打开mergeSql功能；慢SQL记录
      connectionProperties: druid.stat.mergeSql=true;druid.stat.slowSqlMillis=5000

#mybatis
mybatis:
  # 实体类扫描
  type-aliases-package: cn.zhangbox.springboot.entity
  # 配置映射文件位置
  mapper-locations: classpath:mapper/*.xml
  # 开启驼峰匹配
  mapUnderscoreToCamelCase: true

---
#开发环境配置
server:
  #端口
  port: 8080
spring:
  profiles: dev
  # 数据源配置
  datasource:
    student:
      url: jdbc:mysql://127.0.0.1:3306/student?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
    teacher:
      url: jdbc:mysql://127.0.0.1:3306/teacher?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
#日志
logging:
  config: classpath:log/logback.xml
  path: log/spring-boot-mybatis-datasource

---
#测试环境配置
server:
  #端口
  port: 80
spring:
  profiles: test
  # 数据源配置
  datasource:
    student:
      url: jdbc:mysql://127.0.0.1:3306/student?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
    teacher:
      url: jdbc:mysql://127.0.0.1:3306/teacher?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
#日志
logging:
  config: classpath:log/logback.xml
  path: /home/log/spring-boot-mybatis-datasource

---
#生产环境配置
server:
  #端口
  port: 8080
spring:
  profiles: prod
  # 数据源配置
  datasource:
    student:
      url: jdbc:mysql://127.0.0.1:3306/student?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
    teacher:
      url: jdbc:mysql://127.0.0.1:3306/teacher?useUnicode=true&characterEncoding=utf8&useSSL=false&tinyInt1isBit=true
      username: root
      password: 123456
#日志
logging:
  config: classpath:log/logback.xml
  path: /home/log/spring-boot-mybatis-datasource

```

这里进行了`mybatis`整合,如果不会`mybatis`整合可以参考我写的这篇文章:

[SpringBoot非官方教程 | 第六篇：SpringBoot整合mybatis](https://www.jianshu.com/p/1451b107bf1e)

## 创建日志配置文件

在工程`resources`文件夹下新建文件夹`log`，并在该文件夹下创建`logback.xml`文件,加入以下配置：

```
<!-- Logback configuration. See http://logback.qos.ch/manual/index.html -->
<configuration scan="true" scanPeriod="10 seconds">
    <!--继承spring boot提供的logback配置-->
    <!--<include resource="org/springframework/boot/logging/logback/base.xml" />-->

    <!--设置系统日志目录-->
    <property name="APP_DIR" value="spring-boot-mybatis-datasource" />

    <!-- 彩色日志 -->
    <!-- 彩色日志依赖的渲染类 -->
    <conversionRule conversionWord="clr" converterClass="org.springframework.boot.logging.logback.ColorConverter" />
    <conversionRule conversionWord="wex" converterClass="org.springframework.boot.logging.logback.WhitespaceThrowableProxyConverter" />
    <conversionRule conversionWord="wEx" converterClass="org.springframework.boot.logging.logback.ExtendedWhitespaceThrowableProxyConverter" />
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
            <level>info</level>
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
            <appender-ref ref="CONSOLE" />
            <appender-ref ref="DEBUG_FILE" />
            <appender-ref ref="INFO_FILE" />
            <appender-ref ref="WARN_FILE" />
            <appender-ref ref="ERROR_FILE" />
        </root>
    </springProfile>

    <!--测试环境:打印控制台和输出到文件-->
    <springProfile name="test">
        <root level="info">
            <appender-ref ref="CONSOLE" />
            <appender-ref ref="INFO_FILE" />
            <appender-ref ref="WARN_FILE" />
            <appender-ref ref="ERROR_FILE" />
        </root>
    </springProfile>

    <!--生产环境:输出到文件-->
    <springProfile name="prod">
        <root level="info">
            <appender-ref ref="DEBUG_FILE" />
            <appender-ref ref="INFO_FILE" />
            <appender-ref ref="ERROR_FILE" />
        </root>
    </springProfile>

</configuration>

```

**注意：** `loback`配置文件中

```
<logger name="cn.zhangbox.springboot" level="debug"/>

```

`name`的属性值一定要是当前工程的`java`代码的完整目录,因为`mybatis`打印的日志级别是`debug`级别的，因此需要配置`debug`级别日志扫描的目录。

## 创建Druid配置类

在工程`java`代码目录下创建`config`的目录在下面创建`DruidDBConfig`类加入以下代码:

```
@Configuration
public class DruidDBConfig {

    @Bean
    public ServletRegistrationBean druidServlet() {
        ServletRegistrationBean reg = new ServletRegistrationBean();
        reg.setServlet(new StatViewServlet());
        reg.addUrlMappings("/druid/*");
        //设置控制台管理用户
        reg.addInitParameter("loginUsername","root");
        reg.addInitParameter("loginPassword","root");
        // 禁用HTML页面上的“Reset All”功能
        reg.addInitParameter("resetEnable","false");
        //reg.addInitParameter("allow", "127.0.0.1"); //白名单
        return reg;
    }

    @Bean
    public FilterRegistrationBean filterRegistrationBean() {
        //创建过滤器
        FilterRegistrationBean filterRegistrationBean = new FilterRegistrationBean();
        filterRegistrationBean.setFilter(new WebStatFilter());
        Map<String, String> initParams = new HashMap<String, String>();
        //忽略过滤的形式
        initParams.put("exclusions", "*.js,*.gif,*.jpg,*.bmp,*.png,*.css,*.ico,/druid/*");
        filterRegistrationBean.setInitParameters(initParams);
        //设置过滤器过滤路径
        filterRegistrationBean.addUrlPatterns("/*");
        return filterRegistrationBean;
    }
}

```

**注意**：这里`ServletRegistrationBean` 配置bean中通过`addInitParameter`设置了管控台的用户名密码都是`root`，可以在这里进行自定义配置也可以将这里的用户名密码通过转移数据库进行定制化配置实现。

## 创建Student数据源配置类

在工程`java`代码目录下创建`config`的目录在下面创建`StudentDataSourceConfig`类加入以下代码:

```
@Configuration
@MapperScan(basePackages ="cn.zhangbox.springboot.dao.student",sqlSessionFactoryRef = "studentSqlSessionFactory")//mybatis接口包扫描
public class StudentDataSourceConfig {

    @Value("${spring.datasource.student.type}")
    private Class<? extends DataSource> dataSourceType;

    /** *初始化连接池 * @return */
    @Bean(name = "studentDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.student")
    @Primary
    public DataSource writeDataSource() {
        return DataSourceBuilder.create().type(dataSourceType).build();
    }

    /** * * 构建 SqlSessionFactory * @return */
    @Bean(name = "studentSqlSessionFactory")
    @Primary
    public SqlSessionFactory studentSqlSessionFactory(@Qualifier("studentDataSource") DataSource dataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setDataSource(dataSource);
        //bean.setTypeAliasesPackage("com.ztzq.data.beans.bigdata");
        bean.setVfs(SpringBootVFS.class);
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath:mapper/student/*.xml"));
        return bean.getObject();
    }

    /** * 配置事物 * @param dataSource * @return */
    @Bean(name = "studentTransactionManager")
    @Primary
    public DataSourceTransactionManager TransactionManager(@Qualifier("studentDataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    /** * 构建 SqlSessionTemplate * @param sqlSessionFactory * @return * @throws Exception */
    @Bean(name = "studentSqlSessionTemplate")
    @Primary
    public SqlSessionTemplate SqlSessionTemplate(@Qualifier("studentSqlSessionFactory") SqlSessionFactory sqlSessionFactory) throws Exception {
        return new SqlSessionTemplate(sqlSessionFactory);
    }
}

```

## 创建Teacher数据源配置类

在工程`java`代码目录下创建`config`的目录在下面创建`TeacherDataSourceConfig`类加入以下代码:

```
@Configuration
@MapperScan(basePackages ="cn.zhangbox.springboot.dao.teacher",sqlSessionFactoryRef = "teacherSqlSessionFactory")//mybatis接口包扫描
public class TecaherDataSourceConfig {

    @Value("${spring.datasource.teacher.type}")
    private Class<? extends DataSource> dataSourceType;

    /** *初始化连接池 * @return */
    @Bean(name = "teacherDataSource")
    @ConfigurationProperties(prefix = "spring.datasource.teacher")
    public DataSource writeDataSource() {
        return DataSourceBuilder.create().type(dataSourceType).build();
    }

    /** * * 构建 SqlSessionFactory * @return */
    @Bean(name = "teacherSqlSessionFactory")
    public SqlSessionFactory teacherSqlSessionFactory(@Qualifier("teacherDataSource") DataSource dataSource) throws Exception {
        SqlSessionFactoryBean bean = new SqlSessionFactoryBean();
        bean.setDataSource(dataSource);
        //bean.setTypeAliasesPackage("com.ztzq.data.beans.bigdata");
        bean.setVfs(SpringBootVFS.class);
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath:mapper/teacher/*.xml"));
        return bean.getObject();
    }

    /** * 配置事物 * @param dataSource * @return */
    @Bean(name = "teacherTransactionManager")
    public DataSourceTransactionManager TransactionManager(@Qualifier("teacherDataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    /** * 构建 SqlSessionTemplate * @param sqlSessionFactory * @return * @throws Exception */
    @Bean(name = "teacherSqlSessionTemplate")
    public SqlSessionTemplate SqlSessionTemplate(@Qualifier("teacherSqlSessionFactory") SqlSessionFactory sqlSessionFactory) throws Exception {
        return new SqlSessionTemplate(sqlSessionFactory);
    }
}

```

## 创建实体

在工程`java`代码目录下创建`entity`的目录在下面创建`Student`类加入以下代码:

```
@Data
@EqualsAndHashCode(callSuper = false)
public class Student {

    private static final long serialVersionUID = 1L;

	/** * 主键id */
	private Integer sno;
    /** * 学生姓名 */
	private String sname;
    /** * 性别 */
	private String sex;
    /** * 生日 */
	private String birth;
    /** * 年龄 */
	private String age;
    /** * 简介 */
	private String dept;

}

```

在工程`java`代码目录下创建`entity`的目录在下面创建`Teacher`类加入以下代码:

```
@Data
@EqualsAndHashCode(callSuper = false)
public class Teacher {

    private static final long serialVersionUID = 1L;

	/** * 主键id */
	private Integer tno;
    /** * 老师姓名 */
	private String tname;
    /** * 性别 */
	private String sex;
    /** * 生日 */
	private String birth;
    /** * 年龄 */
	private String age;
    /** * 简介 */
	private String dept;

}

```

## 创建Controller

在工程`java`代码目录下创建`controller`的目录在下面创建`StudentConteroller`类加入以下代码:

```
@Controller
@RequestMapping("/student")
public class StudentConteroller {
    private static final Logger LOGGER = LoggerFactory.getLogger(StudentConteroller.class);

    @Autowired
    protected StudentService studentService;

    /** * 查询所有的学生信息 * * @param sname * @param age * @param modelMap * @return */
    @ResponseBody
    @GetMapping("/list")
    public String list(String sname, Integer age, ModelMap modelMap) {
        String json = null;
        try {
            List<Student> studentList = studentService.getStudentList(sname, age);
            modelMap.put("ren_code", "0");
            modelMap.put("ren_msg", "查询成功");
            modelMap.put("studentList", studentList);
            json = JSON.toJSONString(modelMap);
        } catch (Exception e) {
            e.printStackTrace();
            modelMap.put("ren_code", "0");
            modelMap.put("ren_msg", "查询失败===>" + e);
            LOGGER.error("查询失败===>" + e);
            json = JSON.toJSONString(modelMap);
        }
        return json;
    }
}

```

在工程`java`代码目录下创建`controller`的目录在下面创建`TeacherConteroller`类加入以下代码:

```
@Controller
@RequestMapping("/teacher")
public class TeacherConteroller {
    private static final Logger LOGGER = LoggerFactory.getLogger(TeacherConteroller.class);

    @Autowired
    protected TeacherService teacherService;

    /** * 查询所有的老师信息 * * @param tname * @param age * @param modelMap * @return */
    @ResponseBody
    @GetMapping("/list")
    public String list(String tname, Integer age, ModelMap modelMap) {
        String json = null;
        try {
            List<Teacher> teacherList = teacherService.getTeacherList(tname, age);
            modelMap.put("ren_code", "0");
            modelMap.put("ren_msg", "查询成功");
            modelMap.put("teacherList", teacherList);
            json = JSON.toJSONString(modelMap);
        } catch (Exception e) {
            e.printStackTrace();
            modelMap.put("ren_code", "0");
            modelMap.put("ren_msg", "查询失败===>" + e);
            LOGGER.error("查询失败===>" + e);
            json = JSON.toJSONString(modelMap);
        }
        return json;
    }
}

```

## 创建Service

在工程`java`代码目录下面创建`service`目录在下面创建`StudentService`类加入以下代码:

```
public interface StudentService {

    /** * 查询所有的学生信息 * * @param sname * @param age * @return */
    List<Student> getStudentList(String sname, Integer age);
}

```

在工程`java`代码目录下面创建`service`目录在下面创建`TeacherService`类加入以下代码:

```
public interface TeacherService {

    /** * 查询所有的老师信息 * * @param tname * @param age * @return */
    List<Teacher> getTeacherList(String tname, Integer age);
}


```

## 创建ServiceImpl

在工程`java`代码目录下的`service`的目录下面创建`impl`目录在下面创建`StudentServiceImpl`类加入以下代码:

```
@Service("StudentService")
@Transactional(readOnly = true, rollbackFor = Exception.class)
public class StudentServiceImpl implements StudentService {

	@Autowired
	StudentDao studentDao;

	@Override
	public List<Student> getStudentList(String sname, Integer age) {
		return studentDao.getStudentList(sname,age);
	}
}

```

在工程`java`代码目录下的`service`的目录下面创建`impl`目录在下面创建`TeacherServiceImpl`类加入以下代码:

```
@Service("TeacherService")
@Transactional(readOnly = true, rollbackFor = Exception.class)
public class TeacherServiceImpl implements TeacherService {

	@Autowired
	TeacherDao teacherDao;

	@Override
	public List<Teacher> getTeacherList(String tname, Integer age) {
		return teacherDao.getTeacherList(tname,age);
	}
}

```

## 创建Dao

在工程`java`代码目录下创建`dao`的目录下面创建`student`目录在此目录下创建`StudentDao`类加入以下代码:

```
public interface StudentDao {

	List<Student> getStudentList(@Param("sname")String sname, @Param("age")Integer age);

}

```

在工程`java`代码目录下创建`dao`的目录下面创建`teacher`目录在此目录下创建`TeacherDao`类加入以下代码:

```
public interface TeacherDao {

	List<Teacher> getTeacherList(@Param("tname") String tname, @Param("age") Integer age);

}

```

## 创建Mapper映射文件

在工程`resource`目录下创建`mapper`的目录下创建`student`目录在此目录下面创建`StudentMapper.xml`映射文件加入以下代码:

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="cn.zhangbox.springboot.dao.StudentDao" >
    <!-- 查询所有的学生信息 -->
    <select id="getStudentList" resultType="cn.zhangbox.springboot.entity.Student">
        SELECT
            s.sno,
            s.sname,
            s.sex,
            s.dept,
            s.birth,
            s.age
        FROM
            student s
        WHERE
        1 = 1
        <if test="sname != null">
            and s.sname = #{sname}
        </if>
        <if test="age != null">
            and s.age = #{age}
        </if>
    </select>
</mapper>

```

在工程`resource`目录下创建`mapper`的目录下创建`teacher`目录在此目录下面创建`TeacherMapper.xml`映射文件加入以下代码:

```
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN" "http://mybatis.org/dtd/mybatis-3-mapper.dtd" >
<mapper namespace="cn.zhangbox.springboot.dao.teacher.TeacherDao" >
    <!-- 查询所有的老师信息 -->
    <select id="getTeacherList" resultType="cn.zhangbox.springboot.entity.Teacher">
        SELECT
            s.tno,
            s.tname,
            s.sex,
            s.dept,
            s.birth,
            s.age
        FROM
            teacher s
        WHERE
        1 = 1
        <if test="tname != null">
            and s.tname = #{tname}
        </if>
        <if test="age != null">
            and s.age = #{age}
        </if>
    </select>
</mapper>

```

## 创建启动类

```
@SpringBootApplication
public class SpringBootManyDataSourceApplication extends SpringBootServletInitializer {

	public static void main(String[] args) {
		SpringApplication.run(SpringBootManyDataSourceApplication.class, args);
	}
}

```

## 启动项目进行测试：

## 控制台打印

```
 .   ____          _            __ _ _
 /\\ / ___'_ __ _ _(_)_ __ __ _ \ \ \ \ ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
 \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
  '  |____| .__|_| |_|_| |_\__, | / / / /
 =========|_|==============|___/=/_/_/_/
 :: Spring Boot ::        (v1.5.3.RELEASE)

2018-07-09 19:58:22.757  INFO 10096 --- [           main] .z.s.SpringBootManyDataSourceApplication : Starting SpringBootManyDataSourceApplication on 99IHXFJDHAQ7H7N with PID 10096 (started by Administrator in D:\开源项目\spring-boot-study)
2018-07-09 19:58:22.780  INFO 10096 --- [           main] .z.s.SpringBootManyDataSourceApplication : The following profiles are active: dev
2018-07-09 19:58:22.987  INFO 10096 --- [           main] ationConfigEmbeddedWebApplicationContext : Refreshing org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@35e5d0e5: startup date [Mon Jul 09 19:58:22 CST 2018]; root of context hierarchy
2018-07-09 19:58:23.460  INFO 10096 --- [kground-preinit] o.h.validator.internal.util.Version      : HV000001: Hibernate Validator 5.3.5.Final
2018-07-09 19:58:24.220  INFO 10096 --- [           main] o.s.b.f.s.DefaultListableBeanFactory     : Overriding bean definition for bean 'filterRegistrationBean' with a different definition: replacing [Root bean: class [null]; scope=; abstract=false; lazyInit=false; autowireMode=3; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=druidDBConfig; factoryMethodName=filterRegistrationBean; initMethodName=null; destroyMethodName=(inferred); defined in class path resource [cn/zhangbox/springboot/config/DruidDBConfig.class]] with [Root bean: class [null]; scope=; abstract=false; lazyInit=false; autowireMode=3; dependencyCheck=0; autowireCandidate=true; primary=false; factoryBeanName=com.alibaba.druid.spring.boot.autoconfigure.stat.DruidWebStatFilterConfiguration; factoryMethodName=filterRegistrationBean; initMethodName=null; destroyMethodName=(inferred); defined in class path resource [com/alibaba/druid/spring/boot/autoconfigure/stat/DruidWebStatFilterConfiguration.class]]
2018-07-09 19:58:25.440  INFO 10096 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat initialized with port(s): 8080 (http)
2018-07-09 19:58:25.457  INFO 10096 --- [           main] o.apache.catalina.core.StandardService   : Starting service Tomcat
2018-07-09 19:58:25.459  INFO 10096 --- [           main] org.apache.catalina.core.StandardEngine  : Starting Servlet Engine: Apache Tomcat/8.5.14
2018-07-09 19:58:25.594  INFO 10096 --- [ost-startStop-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring embedded WebApplicationContext
2018-07-09 19:58:25.594  INFO 10096 --- [ost-startStop-1] o.s.web.context.ContextLoader            : Root WebApplicationContext: initialization completed in 2608 ms
2018-07-09 19:58:26.138  INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean  : Mapping servlet: 'statViewServlet' to [/druid/*] 2018-07-09 19:58:26.139 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean : Mapping servlet: 'dispatcherServlet' to [/] 2018-07-09 19:58:26.140 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean : Mapping servlet: 'statViewServlet' to [/druid/*] 2018-07-09 19:58:26.141 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.ServletRegistrationBean : Servlet statViewServlet was not registered (possibly already registered?) 2018-07-09 19:58:26.146 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'characterEncodingFilter' to: [/*] 2018-07-09 19:58:26.147 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'hiddenHttpMethodFilter' to: [/*] 2018-07-09 19:58:26.148 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'httpPutFormContentFilter' to: [/*] 2018-07-09 19:58:26.148 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'requestContextFilter' to: [/*] 2018-07-09 19:58:26.149 INFO 10096 --- [ost-startStop-1] o.s.b.w.servlet.FilterRegistrationBean : Mapping filter: 'webStatFilter' to urls: [/*] 2018-07-09 19:58:27.694 INFO 10096 --- [ main] s.w.s.m.m.a.RequestMappingHandlerAdapter : Looking for @ControllerAdvice: org.springframework.boot.context.embedded.AnnotationConfigEmbeddedWebApplicationContext@35e5d0e5: startup date [Mon Jul 09 19:58:22 CST 2018]; root of context hierarchy 2018-07-09 19:58:27.792 INFO 10096 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/student/list],methods=[GET]}" onto public java.lang.String cn.zhangbox.springboot.controller.StudentConteroller.list(java.lang.String,java.lang.Integer,org.springframework.ui.ModelMap) 2018-07-09 19:58:27.794 INFO 10096 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/teacher/list],methods=[GET]}" onto public java.lang.String cn.zhangbox.springboot.controller.TeacherConteroller.list(java.lang.String,java.lang.Integer,org.springframework.ui.ModelMap) 2018-07-09 19:58:27.796 INFO 10096 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error]}" onto public org.springframework.http.ResponseEntity<java.util.Map<java.lang.String, java.lang.Object>> org.springframework.boot.autoconfigure.web.BasicErrorController.error(javax.servlet.http.HttpServletRequest) 2018-07-09 19:58:27.796 INFO 10096 --- [ main] s.w.s.m.m.a.RequestMappingHandlerMapping : Mapped "{[/error],produces=[text/html]}" onto public org.springframework.web.servlet.ModelAndView org.springframework.boot.autoconfigure.web.BasicErrorController.errorHtml(javax.servlet.http.HttpServletRequest,javax.servlet.http.HttpServletResponse) 2018-07-09 19:58:27.837 INFO 10096 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/webjars/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler] 2018-07-09 19:58:27.837 INFO 10096 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/**] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler] 2018-07-09 19:58:27.893 INFO 10096 --- [ main] o.s.w.s.handler.SimpleUrlHandlerMapping : Mapped URL path [/**/favicon.ico] onto handler of type [class org.springframework.web.servlet.resource.ResourceHttpRequestHandler]
2018-07-09 19:58:28.836  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Registering beans for JMX exposure on startup
2018-07-09 19:58:28.837  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Bean with name 'studentDataSource' has been autodetected for JMX exposure
2018-07-09 19:58:28.838  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Bean with name 'teacherDataSource' has been autodetected for JMX exposure
2018-07-09 19:58:28.838  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Bean with name 'statFilter' has been autodetected for JMX exposure
2018-07-09 19:58:28.846  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'studentDataSource': registering with JMX server as MBean [com.alibaba.druid.pool:name=studentDataSource,type=DruidDataSource]
2018-07-09 19:58:28.849  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'teacherDataSource': registering with JMX server as MBean [com.alibaba.druid.pool:name=teacherDataSource,type=DruidDataSource]
2018-07-09 19:58:28.851  INFO 10096 --- [           main] o.s.j.e.a.AnnotationMBeanExporter        : Located MBean 'statFilter': registering with JMX server as MBean [com.alibaba.druid.filter.stat:name=statFilter,type=StatFilter]
2018-07-09 19:58:28.877  INFO 10096 --- [           main] o.a.coyote.http11.Http11NioProtocol      : Initializing ProtocolHandler ["http-nio-8080"]
2018-07-09 19:58:28.905  INFO 10096 --- [           main] o.a.coyote.http11.Http11NioProtocol      : Starting ProtocolHandler ["http-nio-8080"]
2018-07-09 19:58:28.930  INFO 10096 --- [           main] o.a.tomcat.util.net.NioSelectorPool      : Using a shared selector for servlet write/read
2018-07-09 19:58:28.965  INFO 10096 --- [           main] s.b.c.e.t.TomcatEmbeddedServletContainer : Tomcat started on port(s): 8080 (http)
2018-07-09 19:58:28.972  INFO 10096 --- [           main] .z.s.SpringBootManyDataSourceApplication : Started SpringBootManyDataSourceApplication in 8.519 seconds (JVM running for 12.384)
2018-07-09 19:58:37.626  INFO 10096 --- [nio-8080-exec-1] o.a.c.c.C.[Tomcat].[localhost].[/]       : Initializing Spring FrameworkServlet 'dispatcherServlet'
2018-07-09 19:58:37.626  INFO 10096 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization started
2018-07-09 19:58:37.660  INFO 10096 --- [nio-8080-exec-1] o.s.web.servlet.DispatcherServlet        : FrameworkServlet 'dispatcherServlet': initialization completed in 33 ms
2018-07-09 19:58:37.981  INFO 10096 --- [nio-8080-exec-1] com.alibaba.druid.pool.DruidDataSource   : {dataSource-1} inited
2018-07-09 19:58:41.381  INFO 10096 --- [nio-8080-exec-2] com.alibaba.druid.pool.DruidDataSource   : {dataSource-2} inited

```

## 浏览器请求测试

## ![图片.png](https://upload-images.jianshu.io/upload_images/7109926-3c9e5d2656bca749.png)![图片.png](https://upload-images.jianshu.io/upload_images/7109926-faf3a9d409670891.png)本地日志打印效果

![图片.png](https://upload-images.jianshu.io/upload_images/7109926-1031c6af17276ab4.png)
![图片.png](https://upload-images.jianshu.io/upload_images/7109926-ff6cc2d54551a2cc.png)

```
2018-07-09 19:58:22.779 [main] DEBUG c.z.springboot.SpringBootManyDataSourceApplication - Running with Spring Boot v1.5.3.RELEASE, Spring v4.3.8.RELEASE
2018-07-09 19:58:38.386 [http-nio-8080-exec-1] DEBUG c.z.s.dao.student.StudentDao.getStudentList - ==>  Preparing: SELECT s.sno, s.sname, s.sex, s.dept, s.birth, s.age FROM student s WHERE 1 = 1 
2018-07-09 19:58:38.409 [http-nio-8080-exec-1] DEBUG c.z.s.dao.student.StudentDao.getStudentList - ==> Parameters: 
2018-07-09 19:58:38.436 [http-nio-8080-exec-1] DEBUG c.z.s.dao.student.StudentDao.getStudentList - <==      Total: 2
2018-07-09 19:58:41.461 [http-nio-8080-exec-2] DEBUG c.z.s.dao.teacher.TeacherDao.getTeacherList - ==>  Preparing: SELECT s.tno, s.tname, s.sex, s.dept, s.birth, s.age FROM teacher s WHERE 1 = 1 
2018-07-09 19:58:41.462 [http-nio-8080-exec-2] DEBUG c.z.s.dao.teacher.TeacherDao.getTeacherList - ==> Parameters: 
2018-07-09 19:58:41.472 [http-nio-8080-exec-2] DEBUG c.z.s.dao.teacher.TeacherDao.getTeacherList - <==      Total: 1

```

这里使用`logback`配置中将不同级别的日志设置了在不同文件中打印，这样很大程度上方便项目出问题查找问题。

## Druid管控台

![图片.png](https://upload-images.jianshu.io/upload_images/7109926-646fd3e60c263011.png)
![图片.png](https://upload-images.jianshu.io/upload_images/7109926-eb49b436faff6e14.png)
![图片.png](https://upload-images.jianshu.io/upload_images/7109926-a7cd9bdf57d4c756.png)
![图片.png](https://upload-images.jianshu.io/upload_images/7109926-2e551c6f47338b96.png)
![图片.png](https://upload-images.jianshu.io/upload_images/7109926-b6da55d2796e94db.png)
`


