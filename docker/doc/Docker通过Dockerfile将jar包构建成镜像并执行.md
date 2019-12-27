# Docker通过Dockerfile将jar包构建成镜像并执行

##### 1.编写Dockerfile文件.

```
# 环境
FROM  centos
# 作者信息
MAINTAINER david "986945193@qq.com"
# 复制JDK环境
COPY jdk1.8.0_191 jdk1.8.0_191
# 配置环境变量
ENV JAVA_HOME=./jdk1.8.0_191
ENV PATH=$JAVA_HOME/bin:$PATH
ENV CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
# 拷贝jar
COPY imd_blog_eureka-1.0-SNAPSHOT.jar .
ADD imd_blog_eureka-1.0-SNAPSHOT.jar app.jar
# 爆漏的端口号
#EXPOSE 8080
# 执行命令
ENTRYPOINT ["java","-jar","/app.jar"]
```

##### 2.将jar包放在Dockerfile文件同一个目录下。执行构建命令

```
docker build -t david/imd_blog .

```

##### 3.然后就可以当做正常的镜像使用。

```
docker start david/imd_blog
```