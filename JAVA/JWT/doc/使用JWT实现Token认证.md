---
layout:     post
title:      使用JWT实现Token认证
subtitle:   学习笔记
date:       2019-08-28
author:     chenyeshen
header-img: img/img28.jpg
catalog: true
tags:
    - TOken
    - JWT
---

### 为什么使用JWT？

随着技术的发展，分布式web应用的普及，通过session管理用户登录状态成本越来越高，因此慢慢发展成为token的方式做登录身份校验，然后通过token去取redis中的缓存的用户信息，随着之后jwt的出现，校验方式更加简单便捷化，无需通过redis缓存，而是直接根据token取出保存的用户信息，以及对token可用性校验，单点登录更为简单。

### JWT架构图

![img](http://upload-images.jianshu.io/upload_images/3383598-c82676bb8445bae9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000/format/webp)

JWT架构图.png

使用JWT核心代码：

### maven依赖：

```
        <dependency>
            <groupId>com.auth0</groupId>
            <artifactId>java-jwt</artifactId>
            <version>3.2.0</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt</artifactId>
            <version>0.7.0</version>
        </dependency>

```

### JWT工具类：

用于生成Token，和Token验证

```
public class JwtUtils {
    /**
     * 签发JWT
     * @param id
     * @param subject 可以是JSON数据 尽可能少
     * @param ttlMillis
     * @return  String
     *
     */
    public static String createJWT(String id, String subject, long ttlMillis) {
        SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;
        long nowMillis = System.currentTimeMillis();
        Date now = new Date(nowMillis);
        SecretKey secretKey = generalKey();
        JwtBuilder builder = Jwts.builder()
                .setId(id)
                .setSubject(subject)   // 主题
                .setIssuer("user")     // 签发者
                .setIssuedAt(now)      // 签发时间
                .signWith(signatureAlgorithm, secretKey); // 签名算法以及密匙
        if (ttlMillis >= 0) {
            long expMillis = nowMillis + ttlMillis;
            Date expDate = new Date(expMillis);
            builder.setExpiration(expDate); // 过期时间
        }
        return builder.compact();
    }
    /**
     * 验证JWT
     * @param jwtStr
     * @return
     */
    public static CheckResult validateJWT(String jwtStr) {
        CheckResult checkResult = new CheckResult();
        Claims claims = null;
        try {
            claims = parseJWT(jwtStr);
            checkResult.setSuccess(true);
            checkResult.setClaims(claims);
        } catch (ExpiredJwtException e) {
            checkResult.setErrCode(SystemConstant.JWT_ERRCODE_EXPIRE);
            checkResult.setSuccess(false);
        } catch (SignatureException e) {
            checkResult.setErrCode(SystemConstant.JWT_ERRCODE_FAIL);
            checkResult.setSuccess(false);
        } catch (Exception e) {
            checkResult.setErrCode(SystemConstant.JWT_ERRCODE_FAIL);
            checkResult.setSuccess(false);
        }
        return checkResult;
    }
    public static SecretKey generalKey() {
        byte[] encodedKey = Base64.decode(SystemConstant.JWT_SECERT);
        SecretKey key = new SecretKeySpec(encodedKey, 0, encodedKey.length, "AES");
        return key;
    }
    
    /**
     * 
     * 解析JWT字符串
     * @param jwt
     * @return
     * @throws Exception
     */
    public static Claims parseJWT(String jwt) throws Exception {
        SecretKey secretKey = generalKey();
        return Jwts.parser()
            .setSigningKey(secretKey)
            .parseClaimsJws(jwt)
            .getBody();
    }
}

```

### 如何使用？

代码实例：

```
public class LoginController {
    @Autowired
    UserRepository userRepository;
    
    @ApiOperation(value="用户登陆")
    @RequestMapping(value="login",method = RequestMethod.POST)
    public ReturnVo login(String username, String password,HttpServletResponse
            response) {
        User user =  userRepository.findByUsername(username);
        if(user!=null){
            if(user.getPassword().equals(password)){
                //把token返回给客户端-->客户端保存至cookie-->客户端每次请求附带cookie参数
                String JWT = JwtUtils.createJWT("1", username, SystemConstant.JWT_TTL);
                return ReturnVo.ok(JWT);
            }else{
                return ReturnVo.error();
            }
        }else{
            return ReturnVo.error();
        }
    }
    @ApiOperation(value="获取用户信息")
    @RequestMapping(value="description",method = RequestMethod.POST)
    public ReturnVo description(String username) {
        User user =  userRepository.findByUsername(username);
        return ReturnVo.ok(user.getDescription());
    }
}
```