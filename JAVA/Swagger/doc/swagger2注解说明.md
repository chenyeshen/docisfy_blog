# **swagger2 注解说明**

- ​

### 1、swagger2 注解整体说明

用于controller类上

| 注解   | 说明      |
| ---- | ------- |
| @Api | 对请求类的说明 |

用于方法上面（接收参数）

| 注解                                   | 说明                                      |
| ------------------------------------ | --------------------------------------- |
| @ApiOperation                        | 方法的说明                                   |
| @ApiImplicitParams、@ApiImplicitParam | 方法的参数的说明；@ApiImplicitParams 用于指定单个参数的说明 |

用于方法上面（返回参数或对象）

| 注解                         | 说明                                  |
| -------------------------- | ----------------------------------- |
| @ApiResponses、@ApiResponse | 方法返回值的说明 ；@ApiResponses 用于指定单个参数的说明 |

对象类

| 注解                | 说明                          |
| ----------------- | --------------------------- |
| @ApiModel         | 用在JavaBean类上，说明JavaBean的 用途 |
| @ApiModelProperty | 用在JavaBean类的属性上面，说明此属性的的含议  |

### 2、`@Api`：请求类的说明

```
@Api：放在 请求的类上，与 @Controller 并列，说明的请求类的用下，如用户登录类，订单类等。
	tags="说明该类的作用"
	value="该参数没什么意义，所以不需要配置"

```

示例：

```
@Api(tags="APP登录授权")
@Controller
public class ApiLoginController {

}

```

`@Api` 其它属性配置：

| 属性名称           | 备注                                     |
| -------------- | -------------------------------------- |
| value          | url的路径值                                |
| tags           | 如果设置这个值、value的值会被覆盖                    |
| description    | 对api资源的描述                              |
| basePath       | 基本路径                                   |
| position       | 如果配置多个Api 想改变显示的顺序位置                   |
| produces       | 如, “application/json, application/xml” |
| consumes       | 如, “application/json, application/xml” |
| protocols      | 协议类型，如: http, https, ws, wss.          |
| authorizations | 高级特性认证时配置                              |
| hidden         | 配置为true ，将在文档中隐藏                       |

### 3、`@ApiOperation`：方法的说明

```
@ApiOperation："用在请求的方法上，说明方法的作用"
	value="说明方法的作用"
	notes="方法的备注说明"

```

#### 3.1、`@ApiImplicitParams`、`@ApiImplicitParam`：方法参数的说明

```
@ApiImplicitParams：用在请求的方法上，包含一组参数说明
	@ApiImplicitParam：对单个参数的说明	    
	    name：参数名
	    value：参数的汉字说明、解释
	    required：参数是否必须传
	    paramType：参数放在哪个地方
	        · header --> 请求参数的获取：@RequestHeader
	        · query --> 请求参数的获取：@RequestParam
	        · path（用于restful接口）--> 请求参数的获取：@PathVariable
	        · body（请求体）-->  @RequestBody User user
	        · form（不常用）	   
	    dataType：参数类型，默认String，其它值dataType="Integer"	   
	    defaultValue：参数的默认值

```

示列：

```
@ApiOperation(value="用户登录",notes="手机号、密码都是必输项，年龄随边填，但必须是数字")
@ApiImplicitParams({
@ApiImplicitParam(name="mobile",value="手机号",required=true,paramType="form"),
@ApiImplicitParam(name="password",value="密码",required=true,paramType="form"),
@ApiImplicitParam(name="age",value="年龄",required=true,paramType="form",dataType="Integer")
})
@PostMapping("/login")
public JsonResult login(@RequestParam String mobile, @RequestParam String password,
@RequestParam Integer age){
...
    return JsonResult.ok(map);
}

```

### 4、`@ApiResponses`、`@ApiResponse`：方法返回值的说明

```
@ApiResponses：方法返回对象的说明
	@ApiResponse：每个参数的说明
	    code：数字，例如400
	    message：信息，例如"请求参数没填好"
	    response：抛出异常的类

```

示例：

```
@ApiOperation("获取用户信息")
@ApiImplicitParams({
	@ApiImplicitParam(paramType = "query", name = "userId", dataType = "String", required = true, value = "用户Id")
}) 
@ApiResponses({
	@ApiResponse(code = 400, message = "请求参数没填好"),
	@ApiResponse(code = 404, message = "请求路径没有或页面跳转路径不对")
}) 
@ResponseBody
@RequestMapping("/list")
public JsonResult list(@RequestParam String userId) {
	...
	return JsonResult.ok().put("page", pageUtil);
}

```

### 5、`@ApiModel`：用于JavaBean上面，表示一个JavaBean（如：响应数据）的信息

```
@ApiModel：用于JavaBean的类上面，表示此 JavaBean 整体的信息
			（这种一般用在post创建的时候，使用 @RequestBody 这样的场景，
			请求参数无法使用 @ApiImplicitParam 注解进行描述的时候 ）	

```

#### 5.1、`@ApiModelProperty`：用在JavaBean类的属性上面，说明属性的含义

示例:

```
@ApiModel(description= "返回响应数据")
public class RestMessage implements Serializable{

	@ApiModelProperty(value = "是否成功")
	private boolean success=true;
	@ApiModelProperty(value = "返回对象")
	private Object data;
	@ApiModelProperty(value = "错误编号")
	private Integer errCode;
	@ApiModelProperty(value = "错误信息")
	private String message;
		
	/* getter/setter */
}

```

<http://localhost:5680/zxmall/swagger-ui.html>

![这里写图片描述](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190528103438804.png)