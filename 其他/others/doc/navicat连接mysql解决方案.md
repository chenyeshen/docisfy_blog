## navicat连接mysql出现Client does not support authentication protocol requested by server解决方案

在 window server 2012 服务器上安装navicat连接不上mysql

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190720013413030.png)

### 输入以下文本执行解决

```
USE mysql;

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '123456'; 

FLUSH PRIVILEGES;
```

 