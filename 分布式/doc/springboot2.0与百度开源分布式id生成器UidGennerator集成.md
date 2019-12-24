# springboot2.0与百度开源分布式id生成器UidGennerator集成

UidGenerator 由百度开发，是Java实现的, 基于 Snowflake算法的唯一ID生成器。UidGenerator以组件形式工作在应用项目中, 支持自定义workerId位数和初始化策略, 从而适用于 docker等虚拟化环境下实例自动重启、漂移等场景

下面来看怎么在项目中集成：

### 代码结构

![](https://i.loli.net/2019/12/23/Py4bMJYu7ARhi1V.png)

### 下载源码

[源码](https://github.com/baidu/uid-generator )   https://github.com/baidu/uid-generator 拷贝源码到项目中某个目录

![](https://i.loli.net/2019/12/23/SLim6gHuBC3YNen.png)





**idea全局代替快捷键  ctrl+shift+r**

### 数据库中执行脚本

![](https://i.loli.net/2019/12/23/SK7EbV6Wteozc5p.png)

3.编译，修改报错的地方，使编码不报错

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191223201340.png)



4.去掉xml配置文件部分，用application.yml文件的配置和注解替换

    a.application.yml配置

```
       ################################### 日志log配置 ###################################
#logging:
#      level:
#            com.yeshen.eshop: debug
  #日志配置文件位置
#      config: classpath:log/logback.xml
  #日志打印位置，这里是默认在项目根路径下
#      path: log/eshop-log

init:
   aspire:
       uid: cache
spring:
      ####################################数据源配置##########################################
       datasource:
               type: com.alibaba.druid.pool.DruidDataSource
               driver-class-name: com.mysql.cj.jdbc.Driver
               url: jdbc:mysql://localhost:3306/eshop?useUnicode=true&characterEncoding=utf8&serverTimezone=GMT
               username: root
               password: root

       #################################### Redis集群配置 ##########################################
       redis:
            host: localhost
           # cluster:
               #nodes:
                   # - 192.168.150.137:7001
                   # - 192.168.150.137:7002
                    #- 192.168.150.138:7003
                   # - 192.168.150.138:7004
                    # - 127.0.0.1:6379

                  ## Redis数据库索引(默认为0)
            database: 0
                  # 连接超时时间（毫秒）
            timeout: 5000ms
            jedis:
                  pool:
                     ## 连接池最大连接数（使用负值表示没有限制）
                      max-active: 300
                      ## 连接池中的最大空闲连接
                      max-idle: 100
                      ## 连接池最大阻塞等待时间（使用负值表示没有限制）
                      max-wait: -1ms
                      ## 连接池中的最小空闲连接
                      min-idle: 20
            password: 123456
            port: 6379
mybatis:
  configuration:
    cache-enabled: true
    map-underscore-to-camel-case: true
  mapper-locations: classpath:mapper/*.xml

       #################################### kafka配置 ##########################################

     #  kafka:
      #     bootstrap-servers: 192.168.150.137:9092

```

![](https://i.loli.net/2019/12/23/vyr2c6z1UflHWLR.png)



  b.将到注解修改为下图所示



![](https://i.loli.net/2019/12/23/ZOCa67ATD5sUERv.png)



c.在下面类加上这两个注解

![](https://i.loli.net/2019/12/23/FbOMvUg84NoQ5X6.png)



d.下面类加上此注解



![](https://i.loli.net/2019/12/23/mOboLUgNdTPcSkh.png)



f.在下面类加上



![](https://i.loli.net/2019/12/23/ZVFLhncAtibSPzj.png)



5.启动测试

![](https://i.loli.net/2019/12/23/QdxDbatimk6FL9j.png)





![](https://i.loli.net/2019/12/23/AaS5j9mtyCYBc4J.png)