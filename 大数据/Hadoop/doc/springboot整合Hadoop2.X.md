# spring boot整合Hadoop 2.X

背景呢是因为需要在 web 中上传文件到 hdfs ，所以需要在spring boot中加入hadoop相关的jar包。在加入的过程中容易出一些错误，主要是包冲突这一类的问题，解决了之后就好了，在这里顺便记录一下此次解决问题的思路，有需要的朋友可以看看。

### 一. Spring boot整合Hadoop依赖

先给出答案吧，要整合hadoop，比如在 web 中对Hdfs 进行一些处理什么的，直接在pom.xml 中加入以下依赖就行。对了，记得要改成你对应的版本。

        <!-- hadoop 依赖 -->
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-hdfs</artifactId>
            <version>2.7.4</version>
            <exclusions>
                <exclusion> <groupId>org.slf4j</groupId> <artifactId>slf4j-log4j12</artifactId></exclusion>
                <exclusion> <groupId>log4j</groupId> <artifactId>log4j</artifactId> </exclusion>
                <exclusion> <groupId>javax.servlet</groupId> <artifactId>servlet-api</artifactId> </exclusion>
            </exclusions>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.apache.hadoop/hadoop-common -->
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-common</artifactId>
            <version>2.7.4</version>
            <exclusions>
                <exclusion> <groupId>org.slf4j</groupId> <artifactId>slf4j-log4j12</artifactId></exclusion>
                <exclusion> <groupId>log4j</groupId> <artifactId>log4j</artifactId> </exclusion>
                <exclusion> <groupId>javax.servlet</groupId> <artifactId>servlet-api</artifactId> </exclusion>
            </exclusions>
        </dependency>
        <dependency>
            <groupId>org.apache.hadoop</groupId>
            <artifactId>hadoop-client</artifactId>
            <version>2.7.4</version>
            <exclusions>
                <exclusion> <groupId>org.slf4j</groupId> <artifactId>slf4j-log4j12</artifactId></exclusion>
                <exclusion> <groupId>log4j</groupId> <artifactId>log4j</artifactId> </exclusion>
                <exclusion> <groupId>javax.servlet</groupId> <artifactId>servlet-api</artifactId> </exclusion>
            </exclusions>
        </dependency>
把这段代码放到pom.xml 里面应该就没问题了，这里主要是需要用 来排除掉一些hadoop的依赖包，不知道 标签的请自行百度。hadoop和 spring boot 冲突的主要有两个，一个是slf4j的日志包，一个是和tomcat冲突的 servlet-api 包，去掉 hadoop这两个依赖就可以成功运行 spring boot 了。

### 二. 发现问题的思路

刚开始加入hadoop包的时候，出现了这样的错误

```
Caused by: java.lang.IllegalStateException: Detected both log4j-over-slf4j.jar AND bound slf4j-log4j12.jar on the class path, preempting StackOverflowError. See also http://www.slf4j.org/codes.html#log4jDelegationLoop for more details.
```

我就明白是因为日志包log4j这些冲突了，于是就添加排除了这些包，但又有出现了新的错误。

```
java.util.concurrent.ExecutionException: org.apache.catalina.LifecycleException: Failed to start component [StandardEngine[Tomcat].StandardHost[localhost].TomcatEmbeddedContext[]]
	at java.util.concurrent.FutureTask.report(FutureTask.java:122) [na:1.8.0_151]
	at java.util.concurrent.FutureTask.get(FutureTask.java:192) [na:1.8.0_151]
	at org.apache.catalina.core.ContainerBase.startInternal(ContainerBase.java:941) ~[tomcat-embed-core-8.5.31.jar:8.5.31]
	at org.apache.catalina.core.StandardHost.startInternal(StandardHost.java:872) [tomcat-embed-core-8.5.31.jar:8.5.31]
	at org.apache.catalina.util.LifecycleBase.start(LifecycleBase.java:150) [tomcat-embed-core-8.5.31.jar:8.5.31]
	at org.apache.catalina.core.ContainerBase$StartChild.call(ContainerBase.java:1421) [tomcat-embed-core-8.5.31.jar:8.5.31]
	at org.apache.catalina.core.ContainerBase$StartChild.call(ContainerBase.java:1411) [tomcat-embed-core-8.5.31.jar:8.5.31]
	at java.util.concurrent.FutureTask.run(FutureTask.java:266) [na:1.8.0_151]
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149) [na:1.8.0_151]
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624) [na:1.8.0_151]
	at java.lang.Thread.run(Thread.java:748) [na:1.8.0_151]
```

这个问题在网上搜了会都没法解决，于是去 stackoverflod 找了找，直接给出解决方案的倒是没有，不过看到了这个信息：

```
Don’t know if your problem is resolved. I had similar issues and found out that one of the dependencies is built with an older version of servlet-api. Springboot doesn’t want you to include the servlet-api, but if the dependency is built with an older version, then you will see this error.
```

意思就是说这个错误是因为依赖中有其他版本的 servlet-api ，于是就会出现上面那个错误。看到这我再去 maven 里面看了看 hadoop-common 的依赖，果然发现了个宝贝！

然后就很简单啦，把这玩意也给排除了，万事大吉