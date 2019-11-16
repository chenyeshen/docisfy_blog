

---
layout:     post
title:      SpringSecurity初步探索
subtitle:   SpringSecurity
date:       2019-08-15
author:     chenyeshen
header-img: img/bg18.jpg
catalog: true
tags:
    - Java
    - Springboot
    - SpringCecurity
---

# springsecurity自定义登录界面

### config

```
package com.example.demo;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@Configuration
public class config extends WebSecurityConfigurerAdapter {
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.formLogin()
                .loginPage("/hello")
                .loginProcessingUrl("/yeshen")
                .and()
                .authorizeRequests()
                .antMatchers("/hello").permitAll()  
                .anyRequest()
                .authenticated()
                .and()
                .csrf().disable(); 

    }


    @Bean
    public PasswordEncoder passwordEncoder(){
        return new BCryptPasswordEncoder();
    }
}

```

### MyUserDetailServer

```
package com.example.demo;

import lombok.extern.log4j.Log4j;
import lombok.extern.log4j.Log4j2;
import org.apache.juli.logging.Log;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@Log4j2
public class MyUserDetailServer implements UserDetailsService {

    @Autowired
    UserMapper userMapper;


    @Autowired
    PasswordEncoder passwordEncoder;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {




        log.info(""+username+"^^^^^^^^^^^^^^"+passwordEncoder.encode("1234"));
        return new User(username,passwordEncoder.encode("1234"),AuthorityUtils.commaSeparatedStringToAuthorityList("admin"));
    }
}

```



### hello.html

```
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>登录页面</title>
</head>
<body>
<h1>login 页面</h1>

<form action="/yeshen" method="post">
    <table>
        <tr>
            <td>用户名：</td>
            <td><input type="text" name="username"></td>
        </tr>

        <tr>
            <td>密码：</td>
            <td><input type="password" name="password"></td>
        </tr>

        <tr>
            <td colspan="2"><button type="submit">登录</button></td>

        </tr>


    </table>

</form>
</body>
</html>
```

