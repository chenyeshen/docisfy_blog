# spring-boot-shiro-jwt-redis实现登陆授权功能

## 一、前言

在微服务中我们一般采用的是无状态登录，而传统的session方式，在前后端分离的微服务架构下，如继续使用则必将要解决跨域sessionId问题、集群session共享问题等等。这显然是费力不讨好的，而整合shiro，却很不恰巧的与我们的期望有所违背：

1. shiro默认的拦截跳转都是跳转url页面，而前后端分离后，后端并无权干涉页面跳转。
2. shiro默认使用的登录拦截校验机制恰恰就是使用的session。

这当然不是我们想要的，因此如需使用shiro，我们就需要对其进行改造，那么要如何改造呢？我们可以在整合shiro的基础上自定义登录校验，继续整合JWT，或者oauth2.0等，使其成为支持服务端无状态登录，即token登录。

## 二、需求

1. 首次通过post请求将用户名与密码到login进行登入；
2. 登录成功后返回token；
3. 每次请求，客户端需通过header将token带回服务器做JWT Token的校验；
4. 服务端负责token生命周期的刷新
5. 用户权限的校验；

## 三、实现

### pom.xml

```
        <!--shiro-->
        <dependency>
            <groupId>org.apache.shiro</groupId>
            <artifactId>shiro-spring-boot-starter</artifactId>
            <version>1.4.0</version>
        </dependency>

        <!--JWT-->
        <dependency>
            <groupId>com.auth0</groupId>
            <artifactId>java-jwt</artifactId>
            <version>3.7.0</version>
        </dependency>

        <!-- Redis -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis</artifactId>
        </dependency>
        <dependency>
            <groupId>org.apache.commons</groupId>
            <artifactId>commons-pool2</artifactId>
        </dependency>

```

### ShiroConfig

```
/**
 * shiro 配置类
 */
@Configuration
public class ShiroConfig {
    /**
     * Filter Chain定义说明
     * 1、一个URL可以配置多个Filter，使用逗号分隔
     * 2、当设置多个过滤器时，全部验证通过，才视为通过
     * 3、部分过滤器可指定参数，如perms，roles
     */
    @Bean("shiroFilter")
    public ShiroFilterFactoryBean shiroFilter(SecurityManager securityManager) {
        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();
        shiroFilterFactoryBean.setSecurityManager(securityManager);
        // 拦截器
        Map<String, String> filterChainDefinitionMap = new LinkedHashMap<String, String>();
        // 配置不会被拦截的链接 顺序判断
        filterChainDefinitionMap.put("/sys/login", "anon"); //登录接口排除
        filterChainDefinitionMap.put("/sys/logout", "anon"); //登出接口排除
        filterChainDefinitionMap.put("/", "anon");
        filterChainDefinitionMap.put("/**/*.js", "anon");
        filterChainDefinitionMap.put("/**/*.css", "anon");
        filterChainDefinitionMap.put("/**/*.html", "anon");
        filterChainDefinitionMap.put("/**/*.jpg", "anon");
        filterChainDefinitionMap.put("/**/*.png", "anon");
        filterChainDefinitionMap.put("/**/*.ico", "anon");

        filterChainDefinitionMap.put("/druid/**", "anon");
        filterChainDefinitionMap.put("/user/test", "anon"); //测试

        // 添加自己的过滤器并且取名为jwt
        Map<String, Filter> filterMap = new HashMap<String, Filter>(1);
        filterMap.put("jwt", new JwtFilter());
        shiroFilterFactoryBean.setFilters(filterMap);
        // 过滤链定义，从上向下顺序执行，一般将放在最为下边
        filterChainDefinitionMap.put("/**", "jwt");

        //未授权界面返回JSON
        shiroFilterFactoryBean.setUnauthorizedUrl("/sys/common/403");
        shiroFilterFactoryBean.setLoginUrl("/sys/common/403");
        shiroFilterFactoryBean.setFilterChainDefinitionMap(filterChainDefinitionMap);
        return shiroFilterFactoryBean;
    }

    @Bean("securityManager")
    public DefaultWebSecurityManager securityManager(ShiroRealm myRealm) {
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(myRealm);
        
        /*
         * 关闭shiro自带的session，详情见文档
         * http://shiro.apache.org/session-management.html#SessionManagement-
         * StatelessApplications%28Sessionless%29
         */
        DefaultSubjectDAO subjectDAO = new DefaultSubjectDAO();
        DefaultSessionStorageEvaluator defaultSessionStorageEvaluator = new DefaultSessionStorageEvaluator();
        defaultSessionStorageEvaluator.setSessionStorageEnabled(false);
        subjectDAO.setSessionStorageEvaluator(defaultSessionStorageEvaluator);
        securityManager.setSubjectDAO(subjectDAO);

        return securityManager;
    }

    /**
     * 下面的代码是添加注解支持
     *
     * @return
     */
    @Bean
    @DependsOn("lifecycleBeanPostProcessor")
    public DefaultAdvisorAutoProxyCreator defaultAdvisorAutoProxyCreator() {
        DefaultAdvisorAutoProxyCreator defaultAdvisorAutoProxyCreator = new DefaultAdvisorAutoProxyCreator();
        defaultAdvisorAutoProxyCreator.setProxyTargetClass(true);
        return defaultAdvisorAutoProxyCreator;
    }

    @Bean
    public LifecycleBeanPostProcessor lifecycleBeanPostProcessor() {
        return new LifecycleBeanPostProcessor();
    }

    @Bean
    public AuthorizationAttributeSourceAdvisor authorizationAttributeSourceAdvisor(DefaultWebSecurityManager securityManager) {
        AuthorizationAttributeSourceAdvisor advisor = new AuthorizationAttributeSourceAdvisor();
        advisor.setSecurityManager(securityManager);
        return advisor;
    }

}

```

### ShiroRealm

```
/**
 * 用户登录鉴权和获取用户授权
 */
@Component
@Slf4j
public class ShiroRealm extends AuthorizingRealm {

    @Autowired
    @Lazy
    private ISysUserService sysUserService;
    @Autowired
    @Lazy
    private RedisUtil redisUtil;

    /**
     * 必须重写此方法，不然Shiro会报错
     */
    @Override
    public boolean supports(AuthenticationToken token) {
        return token instanceof JwtToken;
    }

    /**
     * 功能： 获取用户权限信息，包括角色以及权限。只有当触发检测用户权限时才会调用此方法，例如checkRole,checkPermission
     *
     * @param principals token
     * @return AuthorizationInfo 权限信息
     */
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        log.info("————权限认证 [ roles、permissions]————");
        SysUser sysUser = null;
        String username = null;
        if (principals != null) {
            sysUser = (SysUser) principals.getPrimaryPrincipal();
            username = sysUser.getUserName();
        }
        SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();

        // 设置用户拥有的角色集合，比如“admin,test”
        Set<String> roleSet = sysUserService.getUserRolesSet(username);
        info.setRoles(roleSet);

        // 设置用户拥有的权限集合，比如“sys:role:add,sys:user:add”
        Set<String> permissionSet = sysUserService.getUserPermissionsSet(username);
        info.addStringPermissions(permissionSet);
        return info;
    }

    /**
     * 功能： 用来进行身份认证，也就是说验证用户输入的账号和密码是否正确，获取身份验证信息，错误抛出异常
     *
     * @param auth 用户身份信息 token
     * @return 返回封装了用户信息的 AuthenticationInfo 实例
     */
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken auth) throws AuthenticationException {
        String token = (String) auth.getCredentials();
        if (token == null) {
            log.info("————————身份认证失败——————————IP地址:  " + CommonUtils.getIpAddrByRequest(SpringContextUtils.getHttpServletRequest()));
            throw new AuthenticationException("token为空!");
        }
        // 校验token有效性
        SysUser loginUser = this.checkUserTokenIsEffect(token);
        return new SimpleAuthenticationInfo(loginUser, token, getName());
    }

    /**
     * 校验token的有效性
     *
     * @param token
     */
    public SysUser checkUserTokenIsEffect(String token) throws AuthenticationException {
        // 解密获得username，用于和数据库进行对比
        String username = JwtUtil.getUsername(token);
        if (username == null) {
            throw new AuthenticationException("token非法无效!");
        }

        // 查询用户信息
        SysUser loginUser = new SysUser();
        SysUser sysUser = sysUserService.getUserByName(username);
        if (sysUser == null) {
            throw new AuthenticationException("用户不存在!");
        }

        // 校验token是否超时失效 & 或者账号密码是否错误
        if (!jwtTokenRefresh(token, username, sysUser.getPassWord())) {
            throw new AuthenticationException("Token失效请重新登录!");
        }

        // 判断用户状态
        if (!"0".equals(sysUser.getDelFlag())) {
            throw new AuthenticationException("账号已被删除,请联系管理员!");
        }

        BeanUtils.copyProperties(sysUser, loginUser);
        return loginUser;
    }

    /**
     * JWTToken刷新生命周期 （解决用户一直在线操作，提供Token失效问题）
     * 1、登录成功后将用户的JWT生成的Token作为k、v存储到cache缓存里面(这时候k、v值一样)
     * 2、当该用户再次请求时，通过JWTFilter层层校验之后会进入到doGetAuthenticationInfo进行身份验证
     * 3、当该用户这次请求JWTToken值还在生命周期内，则会通过重新PUT的方式k、v都为Token值，缓存中的token值生命周期时间重新计算(这时候k、v值一样)
     * 4、当该用户这次请求jwt生成的token值已经超时，但该token对应cache中的k还是存在，则表示该用户一直在操作只是JWT的token失效了，程序会给token对应的k映射的v值重新生成JWTToken并覆盖v值，该缓存生命周期重新计算
     * 5、当该用户这次请求jwt在生成的token值已经超时，并在cache中不存在对应的k，则表示该用户账户空闲超时，返回用户信息已失效，请重新登录。
     * 6、每次当返回为true情况下，都会给Response的Header中设置Authorization，该Authorization映射的v为cache对应的v值。
     * 7、注：当前端接收到Response的Header中的Authorization值会存储起来，作为以后请求token使用
     * 参考方案：https://blog.csdn.net/qq394829044/article/details/82763936
     *
     * @param userName
     * @param passWord
     * @return
     */
    public boolean jwtTokenRefresh(String token, String userName, String passWord) {
        String cacheToken = String.valueOf(redisUtil.get(CommonConstant.PREFIX_USER_TOKEN + token));
        if (CommonUtils.isNotEmpty(cacheToken)) {
            // 校验token有效性
            if (!JwtUtil.verify(cacheToken, userName, passWord)) {
                String newAuthorization = JwtUtil.sign(userName, passWord);
                redisUtil.set(CommonConstant.PREFIX_USER_TOKEN + token, newAuthorization);
                // 设置超时时间
                redisUtil.expire(CommonConstant.PREFIX_USER_TOKEN + token, JwtUtil.EXPIRE_TIME / 1000);
            } else {
                redisUtil.set(CommonConstant.PREFIX_USER_TOKEN + token, cacheToken);
                // 设置超时时间
                redisUtil.expire(CommonConstant.PREFIX_USER_TOKEN + token, JwtUtil.EXPIRE_TIME / 1000);
            }
            return true;
        }
        return false;
    }

}

```

### JwtFilter

```
/**
 * 鉴权登录拦截器
 **/
@Slf4j
public class JwtFilter extends BasicHttpAuthenticationFilter {

    /**
     * 执行登录认证
     *
     * @param request
     * @param response
     * @param mappedValue
     * @return
     */
    @Override
    protected boolean isAccessAllowed(ServletRequest request, ServletResponse response, Object mappedValue) {
        try {
            executeLogin(request, response);
            return true;
        } catch (Exception e) {
            throw new AuthenticationException("Token失效请重新登录");
        }
    }

    /**
     *
     */
    @Override
    protected boolean executeLogin(ServletRequest request, ServletResponse response) throws Exception {
        HttpServletRequest httpServletRequest = (HttpServletRequest) request;
        String token = httpServletRequest.getHeader(CommonConstant.ACCESS_TOKEN);

        JwtToken jwtToken = new JwtToken(token);
        // 提交给realm进行登入，如果错误他会抛出异常并被捕获
        getSubject(request, response).login(jwtToken);
        // 如果没有抛出异常则代表登入成功，返回true
        return true;
    }

    /**
     * 对跨域提供支持
     */
    @Override
    protected boolean preHandle(ServletRequest request, ServletResponse response) throws Exception {
        HttpServletRequest httpServletRequest = (HttpServletRequest) request;
        HttpServletResponse httpServletResponse = (HttpServletResponse) response;
        httpServletResponse.setHeader("Access-control-Allow-Origin", httpServletRequest.getHeader("Origin"));
        httpServletResponse.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS,PUT,DELETE");
        httpServletResponse.setHeader("Access-Control-Allow-Headers", httpServletRequest.getHeader("Access-Control-Request-Headers"));
        // 跨域时会首先发送一个option请求，这里我们给option请求直接返回正常状态
        if (httpServletRequest.getMethod().equals(RequestMethod.OPTIONS.name())) {
            httpServletResponse.setStatus(HttpStatus.OK.value());
            return false;
        }
        return super.preHandle(request, response);
    }
}

```

### JwtToken

```
package cn.gathub.entity;

import org.apache.shiro.authc.AuthenticationToken;

public class JwtToken implements AuthenticationToken {

    private static final long serialVersionUID = 1L;
    private String token;

    public JwtToken(String token) {
        this.token = token;
    }

    @Override
    public Object getPrincipal() {
        return token;
    }

    @Override
    public Object getCredentials() {
        return token;
    }
}

```

### JwtUtils

```
/**
 * JWT工具类
 **/
public class JwtUtil {

    // 过期时间30分钟
    public static final long EXPIRE_TIME = 30 * 60 * 1000;

    /**
     * 校验token是否正确
     *
     * @param token  密钥
     * @param secret 用户的密码
     * @return 是否正确
     */
    public static boolean verify(String token, String username, String secret) {
        try {
            // 根据密码生成JWT效验器
            Algorithm algorithm = Algorithm.HMAC256(secret);
            JWTVerifier verifier = JWT.require(algorithm).withClaim("username", username).build();
            // 效验TOKEN
            DecodedJWT jwt = verifier.verify(token);
            return true;
        } catch (Exception exception) {
            return false;
        }
    }

    /**
     * 获得token中的信息无需secret解密也能获得
     *
     * @return token中包含的用户名
     */
    public static String getUsername(String token) {
        try {
            DecodedJWT jwt = JWT.decode(token);
            return jwt.getClaim("username").asString();
        } catch (JWTDecodeException e) {
            return null;
        }
    }

    /**
     * 生成签名,5min后过期
     *
     * @param username 用户名
     * @param secret   用户的密码
     * @return 加密的token
     */
    public static String sign(String username, String secret) {
        Date date = new Date(System.currentTimeMillis() + EXPIRE_TIME);
        Algorithm algorithm = Algorithm.HMAC256(secret);
        // 附带username信息
        return JWT.create().withClaim("username", username).withExpiresAt(date).sign(algorithm);

    }

    /**
     * 根据request中的token获取用户账号
     *
     * @param request
     * @return
     * @throws Exception
     */
    public static String getUserNameByToken(HttpServletRequest request) throws Exception {
        String accessToken = request.getHeader(CommonConstant.ACCESS_TOKEN);
        String username = getUsername(accessToken);
        if (CommonUtils.isEmpty(username)) {
            throw new Exception("未获取到用户");
        }
        return username;
    }
}

```

### LoginController

```
@RestController
@RequestMapping("/sys")
@Slf4j
public class LoginController {
    @Autowired
    private ISysUserService sysUserService;
    @Autowired
    private RedisUtil redisUtil;

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public Result<JSONObject> login(@RequestBody SysUser loginUser) throws Exception {
        Result<JSONObject> result = new Result<JSONObject>();
        String username = loginUser.getUserName();
        String password = loginUser.getPassWord();

        //1. 校验用户是否有效
        SysUser sysUser = sysUserService.getUserByName(username);
        result = sysUserService.checkUserIsEffective(sysUser);
        if (!result.isSuccess()) {
            return result;
        }

        //2. 校验用户名或密码是否正确
        String userpassword = PasswordUtil.encrypt(username, password, sysUser.getSalt());
        String syspassword = sysUser.getPassWord();
        if (!syspassword.equals(userpassword)) {
            result.error500("用户名或密码错误");
            return result;
        }

        //用户登录信息
        userInfo(sysUser, result);

        return result;
    }

    /**
     * 退出登录
     *
     * @param request
     * @param response
     * @return
     */
    @RequestMapping(value = "/logout")
    public Result<Object> logout(HttpServletRequest request, HttpServletResponse response) {
        //用户退出逻辑
        String token = request.getHeader(CommonConstant.ACCESS_TOKEN);
        if (CommonUtils.isEmpty(token)) {
            return Result.error("退出登录失败！");
        }
        String username = JwtUtil.getUsername(token);
        SysUser sysUser = sysUserService.getUserByName(username);
        if (sysUser != null) {
            log.info(" 用户名:  " + sysUser.getRealName() + ",退出成功！ ");
            //清空用户Token缓存
            redisUtil.del(CommonConstant.PREFIX_USER_TOKEN + token);
            //清空用户权限缓存：权限Perms和角色集合
            redisUtil.del(CommonConstant.LOGIN_USER_CACHERULES_ROLE + username);
            redisUtil.del(CommonConstant.LOGIN_USER_CACHERULES_PERMISSION + username);
            return Result.ok("退出登录成功！");
        } else {
            return Result.error("无效的token");
        }
    }

    /**
     * 用户信息
     *
     * @param sysUser
     * @param result
     * @return
     */
    private Result<JSONObject> userInfo(SysUser sysUser, Result<JSONObject> result) {
        String syspassword = sysUser.getPassWord();
        String username = sysUser.getUserName();
        // 生成token
        String token = JwtUtil.sign(username, syspassword);
        redisUtil.set(CommonConstant.PREFIX_USER_TOKEN + token, token);
        // 设置超时时间
        redisUtil.expire(CommonConstant.PREFIX_USER_TOKEN + token, JwtUtil.EXPIRE_TIME / 1000);

        // 获取用户部门信息
        JSONObject obj = new JSONObject();
        obj.put("token", token);
        obj.put("userInfo", sysUser);
        result.setResult(obj);
        result.success("登录成功");
        return result;
    }

}

```

## 四、演示

**使用正确的用户名密码进行登陆，登陆成功后返回token**

![img](http://upload-images.jianshu.io/upload_images/18143142-222bb258ccbf5b1c?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

在这里插入图片描述

使用错误的用户名密码进行登陆，登陆失败

![img](http://upload-images.jianshu.io/upload_images/18143142-d8b90b40639839f2?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

在这里插入图片描述

headers中携带正确的token访问接口

![img](http://upload-images.jianshu.io/upload_images/18143142-681bec2273e46105?imageMogr2/auto-orient/strip|imageView2/2/w/1180/format/webp)

在这里插入图片描述

headers中不携带token或者携带错误的token访问接口

![img](http://upload-images.jianshu.io/upload_images/18143142-0066baf2bd58f615?imageMogr2/auto-orient/strip|imageView2/2/w/1182/format/webp)

在这里插入图片描述

无权限的用户访问接口

![img](http://upload-images.jianshu.io/upload_images/18143142-d7ee529806ff6c84?imageMogr2/auto-orient/strip|imageView2/2/w/1200/format/webp)

在这里插入图片描述

无需登陆token也可以访问的接口（在过滤器中将接口或者资源文件放开）

![img](http://upload-images.jianshu.io/upload_images/18143142-a6cad025ac83c721?imageMogr2/auto-orient/strip|imageView2/2/w/1188/format/webp)

在这里插入图片描述

## 五、github源码地址

地址：[https://github.com/it-wwh/sping-boot-shiro-jwt-redis.git](https://links.jianshu.com/go?to=https%3A%2F%2Fgithub.com%2Fit-wwh%2Fsping-boot-shiro-jwt-redis.git)