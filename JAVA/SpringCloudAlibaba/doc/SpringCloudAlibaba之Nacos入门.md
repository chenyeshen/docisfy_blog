---
layout:     post
title:      springcloudAlibaba 初步入门
subtitle:   学习笔记
date:       2019-09-07
author:     chenyeshen
header-img: img/img10.jpg
catalog: true
tags:
    - springcloudAlibaba 
    - nacos
---

### 下载Nacos到本地

```
git clone https://gitee.com/mirrors/Nacos.git
```



### maven 打包jar

```
mvn -Prelease-nacos clean install -U
```



![file](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190729142617936.png)



### 双击startup.bat

- 在 E:\Workspace\nacos\distribution\target\nacos-server-1.1.0\nacos 双击startup.bat 运行

- 访问 <http://localhost:8848/nacos>

  ​

- 如图：

![file](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190729152251635.png)



#### 账号 ： nacos

#### 密码 ： nacos