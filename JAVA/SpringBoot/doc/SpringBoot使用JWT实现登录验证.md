## 什么是JWT

> JSON Web Token（JWT）是一个开放的标准（RFC 7519），它定义了一个紧凑且自包含的方式，用于在各方之间以JSON对象安全地传输信息。这些信息可以通过数字签名进行验证和信任。可以使用秘密（使用HMAC算法）或使用RSA的公钥/私钥对来对JWT进行签名。
> 具体的jwt介绍可以查看官网的介绍：<https://jwt.io/introduction/>

## jwt请求流程

引用官网的图片
![img](https://segmentfault.com/img/remote/1460000012874057?w=1288&h=733)
中文介绍：

1. 用户使用账号和面发出post请求；
2. 服务器使用私钥创建一个jwt；
3. 服务器返回这个jwt给浏览器；
4. 浏览器将该jwt串在请求头中像服务器发送请求；
5. 服务器验证该jwt；
6. 返回响应的资源给浏览器。

## jwt组成

jwt含有三部分：头部（header）、载荷（payload）、签证（signature）

### 头部（header）

头部一般有两部分信息：声明类型、声明加密的算法（通常使用HMAC SHA256）
头部一般使用base64加密：`eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9`
解密后：

```
{
    "typ":"JWT",
    "alg":"HS256"
}
```

### 载荷（payload）

该部分一般存放一些有效的信息。jwt的标准定义包含五个字段：

- `iss`：该JWT的签发者
- `sub`: 该JWT所面向的用户
- `aud`: 接收该JWT的一方
- `exp(expires)`: 什么时候过期，这里是一个Unix时间戳
- `iat(issued at)`: 在什么时候签发的

这个只是JWT的定义标准，不强制使用。另外自己也可以添加一些公开的不涉及安全的方面的信息。

### 签证（signature）

JWT最后一个部分。该部分是使用了HS256加密后的数据；包含三个部分：

- header (base64后的)
- payload (base64后的)
- secret 私钥

secret是保存在服务器端的，jwt的签发生成也是在服务器端的，secret就是用来进行jwt的签发和jwt的验证，所以，它就是你服务端的私钥，在任何场景都不应该流露出去。一旦客户端得知这个secret, 那就意味着客户端是可以自我签发jwt了。

## 在SpringBoot项目中应用

首先需要添加JWT的依赖：

```
    <dependency>
        <groupId>io.jsonwebtoken</groupId>
        <artifactId>jjwt</artifactId>
        <version>0.6.0</version>
    </dependency>
```

接下来在配置文件中添加JWT的配置信息：

```
##jwt配置
audience:
  clientId: 098f6bcd4621d373cade4e832627b4f6
  base64Secret: MDk4ZjZiY2Q0NjIxZDM3M2NhZGU0ZTgzMjYyN2I0ZjY=
  name: restapiuser
  expiresSecond: 172800
```

配置信息的实体类，以便获取jwt的配置：

```
@Data
@ConfigurationProperties(prefix = "audience")
@Component
public class Audience {

    private String clientId;
    private String base64Secret;
    private String name;
    private int expiresSecond;

}
```

JWT验证主要是通过拦截器验证，所以我们需要添加一个拦截器来验证请求头中是否含有后台颁发的token，这里请求头的格式：这里`bearer;`后面就是服务器颁发的token

![img](https://segmentfault.com/img/remote/1460000012874058?w=912&h=218)

```
public class JwtFilter extends GenericFilterBean {

    @Autowired
    private Audience audience;

    /**
     *  Reserved claims（保留），它的含义就像是编程语言的保留字一样，属于JWT标准里面规定的一些claim。JWT标准里面定好的claim有：

     iss(Issuser)：代表这个JWT的签发主体；
     sub(Subject)：代表这个JWT的主体，即它的所有人；
     aud(Audience)：代表这个JWT的接收对象；
     exp(Expiration time)：是一个时间戳，代表这个JWT的过期时间；
     nbf(Not Before)：是一个时间戳，代表这个JWT生效的开始时间，意味着在这个时间之前验证JWT是会失败的；
     iat(Issued at)：是一个时间戳，代表这个JWT的签发时间；
     jti(JWT ID)：是JWT的唯一标识。
     * @param req
     * @param res
     * @param chain
     * @throws IOException
     * @throws ServletException
     */
    @Override
    public void doFilter(final ServletRequest req, final ServletResponse res, final FilterChain chain)
            throws IOException, ServletException {

        final HttpServletRequest request = (HttpServletRequest) req;
        final HttpServletResponse response = (HttpServletResponse) res;
        //等到请求头信息authorization信息
        final String authHeader = request.getHeader("authorization");

        if ("OPTIONS".equals(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            chain.doFilter(req, res);
        } else {

            if (authHeader == null || !authHeader.startsWith("bearer;")) {
                throw new LoginException(ResultEnum.LOGIN_ERROR);
            }
            final String token = authHeader.substring(7);

            try {
                if(audience == null){
                    BeanFactory factory = WebApplicationContextUtils.getRequiredWebApplicationContext(request.getServletContext());
                    audience = (Audience) factory.getBean("audience");
                }
                final Claims claims = JwtHelper.parseJWT(token,audience.getBase64Secret());
                if(claims == null){
                    throw new LoginException(ResultEnum.LOGIN_ERROR);
                }
                request.setAttribute(Constants.CLAIMS, claims);
            } catch (final Exception e) {
                throw new LoginException(ResultEnum.LOGIN_ERROR);
            }

            chain.doFilter(req, res);
        }
    }
}
```

注册JWT拦截器，可以在配置类中，也可以直接在SpringBoot的入口类中

```
    @Bean
    public FilterRegistrationBean jwtFilter() {
        final FilterRegistrationBean registrationBean = new FilterRegistrationBean();
        registrationBean.setFilter(new JwtFilter());
        //添加需要拦截的url
        List<String>  urlPatterns = Lists.newArrayList();
        urlPatterns.add("/article/insert");
        registrationBean.addUrlPatterns(urlPatterns.toArray(new String[urlPatterns.size()]));
        return registrationBean;
    }
```

登录处理，也就是jwt的颁发

```
  @PostMapping("login")
    public ResultVo login(@RequestParam(value = "usernameOrEmail", required = true) String usernameOrEmail,
                          @RequestParam(value = "password", required = true) String password,
                          HttpServletRequest request) {
        Boolean is_email = MatcherUtil.matcherEmail(usernameOrEmail);
        User user = new User();
        if (is_email) {
            user.setEmail(usernameOrEmail);
        } else {
            user.setUsername(usernameOrEmail);
        }
        User query_user = userService.get(user);
        if (query_user == null) {
            return ResultVOUtil.error("400", "用户名或邮箱错误");
        }
        //验证密码
        PasswordEncoder encoder = new BCryptPasswordEncoder();
        boolean is_password = encoder.matches(password, query_user.getPassword());
        if (!is_password) {
            //密码错误，返回提示
            return ResultVOUtil.error("400", "密码错误");
        }
     
       String jwtToken = JwtHelper.createJWT(query_user.getUsername(),
                                           query_user.getId(),
                                           query_user.getRole().toString(),
                                           audience.getClientId(),
                                           audience.getName(),
                                           audience.getExpiresSecond()*1000,
                                           audience.getBase64Secret());

        String result_str = "bearer;" + jwtToken;
        return ResultVOUtil.success(result_str);
    }
```

这里将jwt的颁发处理抽离出来了，JWT工具类：

```
public class JwtHelper {

    /**
     * 解析jwt
     */
    public static Claims parseJWT(String jsonWebToken, String base64Security){
        try
        {
            Claims claims = Jwts.parser()
                    .setSigningKey(DatatypeConverter.parseBase64Binary(base64Security))
                    .parseClaimsJws(jsonWebToken).getBody();
            return claims;
        }
        catch(Exception ex)
        {
            return null;
        }
    }

    /**
     * 构建jwt
     */
    public static String createJWT(String name, String userId, String role,
                                   String audience, String issuer, long TTLMillis, String base64Security)
    {
        SignatureAlgorithm signatureAlgorithm = SignatureAlgorithm.HS256;

        long nowMillis = System.currentTimeMillis();
        Date now = new Date(nowMillis);

        //生成签名密钥
        byte[] apiKeySecretBytes = DatatypeConverter.parseBase64Binary(base64Security);
        Key signingKey = new SecretKeySpec(apiKeySecretBytes, signatureAlgorithm.getJcaName());

        //添加构成JWT的参数
        JwtBuilder builder = Jwts.builder().setHeaderParam("typ", "JWT")
                .claim("role", role)
                .claim("unique_name", name)
                .claim("userid", userId)
                .setIssuer(issuer)
                .setAudience(audience)
                .signWith(signatureAlgorithm, signingKey);
        //添加Token过期时间
        if (TTLMillis >= 0) {
            long expMillis = nowMillis + TTLMillis;
            Date exp = new Date(expMillis);
            builder.setExpiration(exp).setNotBefore(now);
        }

        //生成JWT
        return builder.compact();
    }
}

```

最后，jwt可能会出现跨域的问题，所以最好添加一下对跨域的处理

```
@Configuration
public class CorsConfig {

    @Bean
    public FilterRegistrationBean corsFilter() {
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowCredentials(true);
        config.addAllowedOrigin("*");
        config.addAllowedHeader("*");
        config.addAllowedMethod("OPTIONS");
        config.addAllowedMethod("HEAD");
        config.addAllowedMethod("GET");
        config.addAllowedMethod("PUT");
        config.addAllowedMethod("POST");
        config.addAllowedMethod("DELETE");
        config.addAllowedMethod("PATCH");
        source.registerCorsConfiguration("/**", config);
        final FilterRegistrationBean bean = new FilterRegistrationBean(new CorsFilter(source));
        bean.setOrder(0);
        return bean;
    }

    @Bean
    public WebMvcConfigurer mvcConfigurer() {
        return new WebMvcConfigurerAdapter() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**").allowedMethods("GET", "PUT", "POST", "GET", "OPTIONS");
            }
        };
    }
}
```

