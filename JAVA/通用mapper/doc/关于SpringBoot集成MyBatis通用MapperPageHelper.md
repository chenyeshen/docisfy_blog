# **关于Spring Boot集成MyBatis、通用Mapper、PageHelper**

### 依赖:

##### mybatis :

```
<dependency>
            <groupId>org.mybatis</groupId>
            <artifactId>mybatis</artifactId>
            <version>3.4.0</version>
</dependency>
```

##### mybatis-spring-boot-starter：

```
<dependency>
            <groupId>org.mybatis.spring.boot</groupId>
            <artifactId>mybatis-spring-boot-starter</artifactId>
            <version>1.1.1</version>
</dependency>
```

##### mysql:

```
<dependency>
            <groupId>mysql</groupId>
            <artifactId>mysql-connector-java</artifactId>
</dependency>
```

##### mapper:

```
<dependency>
            <groupId>tk.mybatis</groupId>
            <artifactId>mapper</artifactId>
            <version>3.3.7</version>
</dependency>
```

### 配置

##### MyBatisMapperScannerConfig.java

```
package com.ljy.common.configure;

import java.util.Properties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import tk.mybatis.spring.mapper.MapperScannerConfigurer;

@Configuration
public class MyBatisMapperScannerConfig {
    @Bean
    public MapperScannerConfigurer mapperScannerConfigurer() {
        MapperScannerConfigurer mapperScannerConfigurer = new MapperScannerConfigurer();
        mapperScannerConfigurer.setSqlSessionFactoryBeanName("sqlSessionFactory");
        mapperScannerConfigurer.setBasePackage("com.ljy.dao");//扫描该路径下的dao
        Properties properties = new Properties();
        properties.setProperty("mappers", "com.ljy.common.BaseDao");//通用dao
        properties.setProperty("notEmpty", "false");
        properties.setProperty("IDENTITY", "MYSQL");
        mapperScannerConfigurer.setProperties(properties);
        return mapperScannerConfigurer;
    }

}
```

**其实MyBatisMapperScannerConfig 是一个MyBatis扫描Mapper接口扫描。**

MapperScannerConfigurer根据指定的创建接口或注解创建映射器。我们这里映射了com.ljy.dao包下的接口。

使用MapperScannerConfigurer，没有必要去指定SqlSessionFactory或SqlSessionTemplate，因为MapperScannerConfigurer将会创建MapperFactoryBean，之后自动装配。但是，如果你使用了一个以上的DataSource(因此，也是多个的SqlSessionFactory),那么自动装配可能会失效。这种情况下，你可以使用sqlSessionFactory或sqlSessionTemplate属性来设置正确的工厂/模板。

注意的是网络上有些文章中在MapperScannerConfigurer之前还配置了 MyBatisConfig，因为MapperScannerConfigurer会创建MapperFactoryBean，所以我的项目中没有再配置MyBatisConfig。经使用没有出现任何问题。

##### BaseDao.java:

```
package com.ljy.common;

import tk.mybatis.mapper.common.Mapper;
import tk.mybatis.mapper.common.MySqlMapper;

public interface BaseDao<T> extends Mapper<T>,MySqlMapper<T>{

}
```

### 附上测试表sql:

```
SET FOREIGN_KEY_CHECKS=0;

-- ----------------------------
-- Table structure for `user`
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` ( `id` int(11) NOT NULL, `username` varchar(255) DEFAULT NULL, `state` int(11) DEFAULT NULL, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES ('1', 'test', '1');
INSERT INTO `user` VALUES ('2', 'user', '2');
```

### 实体类:

##### User.java

```
package com.ljy.entity;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;

public class User implements Serializable {
    @Id
    @Column(name = "id")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;
    private String username;
    private Integer state;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public Integer getState() {
        return state;
    }

    public void setState(Integer state) {
        this.state = state;
    }

}
```

##### Dao:

```
package com.ljy.dao;

import com.ljy.common.BaseDao;
import com.ljy.entity.User;

public interface UserDao extends BaseDao<User>{

}
```

MyBatis的Dao与其它的ORM框架不一样的是，MyBatis的Dao其实就是Mapper，是一个接口，是通过MapperScannerConfigurer扫描后生成实现的，我们不需要再写Dao接口的实现。

### 业务处理及事务（Service层）

##### *Service

```
package com.ljy.service;

public interface UserService {

}
```

##### *ServiceImpl

```
package com.ljy.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ljy.dao.UserDao;
import com.ljy.entity.User;
import com.ljy.service.UserService;
@Service
public class UserServiceImpl implements UserService{
    @Autowired
    private UserDao userDao;
    public User getUser(int id) {
        return userDao.selectByPrimaryKey(id);
    }
}
```

Spring Boot集成MyBatis后，实现事物管理的方法很简单，只需要在业务方法前面加上@Transactional注解就可以了。

### 控制器测试

##### Test.java:

```
package com.ljy.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.ljy.entity.User;
import com.ljy.service.UserService;

@RestController
public class Test {
    @Autowired
    private UserService userService;

    @RequestMapping("/test")
    public User test() {
        return userService.getUser(1);
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528111403042.png)

### 集成PageHelper

##### 依赖包:

```
<dependency>  
    <groupId>com.github.pagehelper</groupId>  
    <artifactId>pagehelper</artifactId>  
    <version>4.1.0</version>  
</dependency>
```

### 配置类

##### MybatisConf.java

```
package com.ljy.common.configure;

import java.util.Properties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import com.github.pagehelper.PageHelper;

/* * 注册MyBatis分页插件PageHelper */  

@Configuration  
public class MybatisConf {  
        @Bean  
        public PageHelper pageHelper() {  
           System.out.println("MyBatisConfiguration.pageHelper()"); 
            PageHelper pageHelper = new PageHelper(); 
            Properties p = new Properties(); 
            p.setProperty("offsetAsPageNum", "true"); 
            p.setProperty("rowBoundsWithCount", "true"); 
            p.setProperty("reasonable", "true"); 
            pageHelper.setProperties(p); 
            return pageHelper; 
        }  
}
```

这时就可以使用PageHelp插件了，在controller中直接使用。

##### Test.java

```
package com.ljy.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.github.pagehelper.PageHelper;
import com.github.pagehelper.PageInfo;
import com.ljy.dao.UserDao;
import com.ljy.entity.User;
import com.ljy.service.UserService;

@RestController
public class Test {
    @Autowired
    private UserService userService;
    @RequestMapping("/test")
    public PageInfo<User> test() {
         /* * 第一个参数是第几页；第二个参数是每页显示条数。 */  
        PageHelper.startPage(1,1); 
        List<User> list=userService.getUsers();
        PageInfo<User> pageInfo=new PageInfo<User>(list);
        return pageInfo; 

    }
}
```

##### UserService .java:

```
package com.ljy.service;

import java.util.List;
import com.ljy.entity.User;

public interface UserService {
    public User getUser(int id);
    public List<User> getUsers();
}
```

##### UserServiceImpl.java

```
package com.ljy.service.impl;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.ljy.dao.UserDao;
import com.ljy.entity.User;
import com.ljy.service.UserService;
@Service
public class UserServiceImpl implements UserService{
    @Autowired
    private UserDao userDao;
    public User getUser(int id) {
        return userDao.selectByPrimaryKey(id);
    }
    @Override
    public List<User> getUsers() {
        // TODO Auto-generated method stub
        return userDao.selectAll();
    }
}
```

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528111402188.png)

### PageHelper实现原理

参考这篇文章<http://blog.csdn.net/jaryle/article/details/52315565>

原理：

pageHelper会使用ThreadLocal获取到同一线程中的变量信息，各个线程之间的Threadlocal不会相互干扰，也就是Thread1中的ThreadLocal1之后获取到Tread1中的变量的信息，不会获取到Thread2中的信息
所以在多线程环境下，各个Threadlocal之间相互隔离，可以实现，不同thread使用不同的数据源或不同的Thread中执行不同的SQL语句
所以，PageHelper利用这一点通过拦截器获取到同一线程中的预编译好的SQL语句之后将SQL语句包装成具有分页功能的SQL语句，并将其再次赋值给下一步操作，所以实际执行的SQL语句就是有了分页功能的SQL语句