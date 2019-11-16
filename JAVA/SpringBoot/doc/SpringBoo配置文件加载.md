### 一、配置文件加载位置

 SpringBoot启动时会扫描以下位置的application.properties或者application.yml文件作为SpringBoot的默认配置文件。
 `file:./config/`
 `file:./`
 `classpath:/config/`
 `classpath:/`
优先级由高到底，高优先级的配置会覆盖低优先级的配置；SpringBoot会从这四个位置加载主配置文件；互补配置；

测试：
 分别在`file:./config/`、`file:./`、`classpath:/config/`、`classpath:/`下创建 application.properties 配置文件，分别设置 `server.port` 为：8084、8083、8082、8081。启动项目测试，项目在8084端口启动；注释掉`file:./config/`下application.properties 中 `server.port` 的配置，再启动，项目在8083端口启动；注释掉`file:./`下application.properties 中 `server.port` 的配置，再启动，项目在8082端口启动；注释掉`classpath:/config/`下application.properties 中 `server.port` 的配置，再启动，项目在8083端口启动。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190608195338936.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpemhpcWlhbmcxMjE3,size_16,color_FFFFFF,t_70)
我们在`classpath:/`下的 application.properties 配置文件中新增配置：

```
server.port=8081

#配置项目的访问路径
server.servlet.context-path=/boot02

```

### 创建HelloController

```
@RestController
public class HelloController {

    @RequestMapping("/hello")
    public String hello(){
       return "hello";
    }
}

```

 重新启动项目，在浏览器访问 <http://localhost:8084/hello> 发现访问不了。访问 <http://localhost:8084/boot02/hello> 则可以访问。说明几个配置文件之间形成了互补配置。
 我们还可以通过`spring.config.location`来改变默认的配置文件位置。项目打包好以后，我们可以使用命令行参数的形式，启动项目的时候来指定配置文件的新位置；指定的配置文件和默认加载的这些配置文件共同起作用形成互补配置；

```
java -jar spring-boot-02-config-02-0.0.1-SNAPSHOT.jar --spring.config.location=G:/springboot/application.properties

```

### 二、配置文件加载顺序

 SpringBoot也可以从以下位置加载配置；优先级从高到低；高优先级的配置覆盖低优先级的配置，所有的配置会形成互补配置。官方文档：<https://docs.spring.io/spring-boot/docs/1.5.9.RELEASE/reference/htmlsingle/#boot-features-external-config>
1、命令行参数
 所有的配置都可以在命令行上进行指定。多个配置用空格分开； `--配置项=值`。

```
 java -jar spring-boot-02-config-02-0.0.1-SNAPSHOT.jar --server.port=8087 --server.context-path=/abc 

```

2、来自java:comp/env的JNDI属性。
3、Java系统属性（System.getProperties()）。
4、操作系统环境变量。
5、RandomValuePropertySource配置的random.*属性值。
6、由jar包外向jar包内进行寻找；优先加载带profile的：
 jar包外部的application-{profile}.properties或application.yml(带spring.profile)配置文件。
 jar包内部的application-{profile}.properties或application.yml(带spring.profile)配置文件。
7、再加载不带profile的：
 jar包外部的application.properties或application.yml(不带spring.profile)配置文件。
 jar包内部的application.properties或application.yml(不带spring.profile)配置文件。
10、@Configuration注解类上的@PropertySource。
11、通过SpringApplication.setDefaultProperties指定的默认属性。

测试：
在jar包外新建配置文件application.properties

```
server.port=8088

#配置项目的访问路径
server.servlet.context-path=/boot

```

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190608202816893.png)
使用 java -jar 启动项目。`java -jar spring-boot-02-config-02-0.0.1-SNAPSHOT.jar`
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190608203202931.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpemhpcWlhbmcxMjE3,size_16,color_FFFFFF,t_70)