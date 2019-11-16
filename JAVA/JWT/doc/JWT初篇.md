---
layout:     post
title:      JWT初篇（json web token）
subtitle:   学习笔记
date:       2019-09-01
author:     chenyeshen
header-img: img/img13.jpg
catalog: true
tags:
    - Java
    - JWT

---



### 为什么使用JWT？

随着技术的发展，分布式web应用的普及，通过session管理用户登录状态成本越来越高，因此慢慢发展成为token的方式做登录身份校验，然后通过token去取redis中的缓存的用户信息，随着之后jwt的出现，校验方式更加简单便捷化，无需通过redis缓存，而是直接根据token取出保存的用户信息，以及对token可用性校验，单点登录更为简单。



### jwt依赖 pom.xml

```
<!-- https://mvnrepository.com/artifact/io.jsonwebtoken/jjwt -->
<dependency>
    <groupId>io.jsonwebtoken</groupId>
    <artifactId>jjwt</artifactId>
    <version>0.9.0</version>
</dependency>

```



### jwtUtils.java

```
package com.yeshen.xdvideo.utils;

import com.yeshen.xdvideo.domain.User;
import io.jsonwebtoken.*;
import lombok.extern.log4j.Log4j2;

import java.util.Date;

/**
 * jwt工具类
 */
@Log4j2
public class JwtUtil {

    public  static  final  String SUBJECT="yeshen";
    public  static  final  String APPSECET="yeshen";
    public  static  final long EXPIRE=1000*60*60*24*7;

    public static String  genJsonWebToken(User user){
        String compact = Jwts.builder().setSubject(SUBJECT)
                .claim("id", user.getId())
                .claim("name", user.getName())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRE))
                .signWith(SignatureAlgorithm.HS256, APPSECET)
                .compact();

        return  compact;

    }

    public  static Claims parserToken(String Token){

        try {
            Claims claims = Jwts.parser().setSigningKey(APPSECET).parseClaimsJws(Token).getBody();
            return  claims;
        } catch (ExpiredJwtException e) {
            log.info("令牌过期");
        } catch (UnsupportedJwtException e) {
            e.printStackTrace();
        } catch (MalformedJwtException e) {
            log.info("解压异常");
        } catch (SignatureException e) {
            log.info("签名有误");
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        }
        return null;
    }
}

```



### 代码测试

```
package com.yeshen.xdvideo;

import com.yeshen.xdvideo.config.WechatConfig;
import com.yeshen.xdvideo.domain.User;
import com.yeshen.xdvideo.utils.JwtUtil;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest
public class XdvideoApplicationTests {

    @Test
    public void contextLoads() {

        User user = new User();
        user.setId(1);
        user.setName("haha");
        String token=JwtUtil.genJsonWebToken(user);
        System.out.println(token);
    }

    @Test
    public void Loads() {

        String token="eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ5ZXNoZW4iLCJpZCI6MSwibmFtZSI6ImhhaGEiLCJpYXQiOjE1NjY2NTI1NjgsImV4cCI6MTU2NjY1MjU3MX0.w1gQeTCohT8PwMPF3tYEzXbjmryyOivS8IZi5UJ1k_I";
        Claims claims = JwtUtil.parserToken(token);

        String id=claims.get("id").toString();
        String name= (String) claims.get("name");

        System.out.println(claims);
    }

}

```



### 获取token

![file](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190824185958287.png)



### 异常

![file](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190824212910257.png)