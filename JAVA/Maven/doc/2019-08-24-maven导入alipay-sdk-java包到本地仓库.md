---
layout:     post
title:      maven导入alipay-sdk-java包到本地仓库
subtitle:   学习笔记
date:       2019-08-24
author:     chenyeshen
header-img: img/bg18.jpg
catalog: true
tags:
    - java
    - maven
---

### 1.环境变量添加：

```
MAVEN_HOME:(maven位置)

M2_HOME:(maven位置)

PATH:%M2_HOME%\bin
```

（验证maven是否配置成功cmd-->maven -version）

### 2.安装sdk到本地仓库

将alipay-sdk-Java20170307171631.jar放在e:下，cmd进入e:输入下面的命令：

```
 mvn install:install-file -DgroupId=com.alipay -DartifactId=sdk-java -Dversion=20170307171631 -Dpackaging=jar -Dfile=alipay-sdk-java20170307171631.jar
```



### 3.pom中添加

```
 <dependency>
        <groupId>com.alipay</groupId>
        <artifactId>sdk-java</artifactId>
        <version>20170307171631</version>
   </dependency>
```

以上ok！