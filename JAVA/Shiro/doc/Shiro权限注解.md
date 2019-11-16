# shiro注解

`@RequiresAuthentication`：表示当前Subject已经通过login 进行了身份验证；即 Subject. isAuthenticated() 返回 true。
 `@RequiresUser`：表示当前 Subject 已经身份验证或者通过记住我登录的。
 `@RequiresGuest`：表示当前Subject没有身份验证或通过记住我登录过，即是游客身份。
 `@RequiresRoles(value={“admin”, “user”}, logical= Logical.AND)`：表示当前 Subject 需要 admin 和 user 角色。
 `@RequiresPermissions (value={“user:a”, “user:b”}, logical= Logical.OR)`：表示当前 Subject 需要 `user:a` 或 `user:b` 权限。

测试：

### 1、创建类ShiroService

```
public class ShiroService {
	
	public void testMethod(){
		System.out.println("testMethod, time: " + new Date());
	}
	
}

```

### 2、在Spring配置文件中配置bean

```
<bean id="shiroService"
    	class="com.atguigu.shiro.services.ShiroService"></bean>

```

### 3、创建接口`shiro/testShiroAnnotation`。添加权限注解 `@RequiresRoles({"admin"})`

```
@Controller
@RequestMapping("/shiro")
public class ShiroHandler {
	
	@Autowired
	private ShiroService shiroService;
	
	@RequiresRoles({"admin"})
	@RequestMapping("/testShiroAnnotation")
	public String testShiroAnnotation(){
		shiroService.testMethod();
		return "redirect:/list.jsp";
	}

}

```

### 结果：

 当登录的用户有admin角色时，可以正常访问，否则抛异常：

```
org.apache.shiro.authz.UnauthorizedException: Subject does not have role [admin]

```

 对于异常可以使用 spring 的声明式异常，使用注解 @ExceptionHandler 和 @ControllerAdvice 对异常进行统一处理。

 注意：在Service方法上一般都会使用注解 @Transactional，使得在方法开始的时候会有事务，这个时候Service已经是一个代理对象，这时权限注解就不能加到 Service上，会发生类型转换异常。需要加到Controller上，因为不能够让 Service 成为代理的代理。