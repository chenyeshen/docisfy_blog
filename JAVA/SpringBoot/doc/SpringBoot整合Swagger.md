### Swagger 简介

​       Swagger 是一个规范和完整的框架，用于生成、描述、调用和可视化 RESTful 风格的 Web 服务。总体目标是使客户端和文件系统作为服务器以同样的速度来更新。文件的方法，参数和模型紧密集成到服务器端的代码，允许API来始终保持同步。

### 1、引入依赖

```
 <!--SpringBoot整合Swagger2-->
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.7.0</version>
</dependency>
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.7.0</version>
</dependency>

```

### 2、Swagger配置类

```
package com.swaggerTest;
 
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import springfox.documentation.builders.ApiInfoBuilder;
import springfox.documentation.builders.PathSelectors;
import springfox.documentation.builders.RequestHandlerSelectors;
import springfox.documentation.service.ApiInfo;
import springfox.documentation.spi.DocumentationType;
import springfox.documentation.spring.web.plugins.Docket;
import springfox.documentation.swagger2.annotations.EnableSwagger2;
 
/**
 * Swagger2配置类
 * 在与spring boot集成时，放在与Application.java同级的目录下。
 * 通过@Configuration注解，让Spring来加载该类配置。
 * 再通过@EnableSwagger2注解来启用Swagger2。
 */
@Configuration
@EnableSwagger2
public class Swagger2 {
    
    /**
     * 创建API应用
     * apiInfo() 增加API相关信息
     * 通过select()函数返回一个ApiSelectorBuilder实例,用来控制哪些接口暴露给Swagger来展现，
     * 本例采用指定扫描的包路径来定义指定要建立API的目录。
     * @return
     */
    @Bean
    public Docket createRestApi() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.swaggerTest.controller"))
                .paths(PathSelectors.any())
                .build();
    }
    
    /**
     * 创建该API的基本信息（这些基本信息会展现在文档页面中）
     * 访问地址：http://项目实际地址/swagger-ui.html
     * @return
     */
    private ApiInfo apiInfo() {
        return new ApiInfoBuilder()
                .title("Spring Boot中使用Swagger2构建RESTful APIs")
                .description("更多请关注http://www.baidu.com")
                .termsOfServiceUrl("http://www.baidu.com")
                .contact("sunf")
                .version("1.0")
                .build();
    }
}

```

### 3、Swagger注解

@Api：用在类上，说明该类的作用。
@ApiOperation：注解来给API增加方法说明。
@ApiImplicitParams : 用在方法上包含一组参数说明。
@ApiImplicitParam：用来注解来给方法入参增加说明。
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190611203907637.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L2xpemhpcWlhbmcxMjE3,size_16,color_FFFFFF,t_70)
@ApiResponses：用于表示一组响应
@ApiResponse：用在@ApiResponses中，一般用于表达一个错误的响应信息。
 code：数字，例如400。
 message：信息，例如"请求参数没填好"。
 response：抛出异常的类 。
@ApiModel：描述一个Model的信息（一般用在请求参数无法使用@ApiImplicitParam注解进行描述的时候）
@ApiModelProperty：描述一个model的属性。

### 4、使用

```
package com.swaggerTest.controller;
 
import org.springframework.stereotype.Controller;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
 
/**
 * 一个用来测试swagger注解的控制器
 * 注意@ApiImplicitParam的使用会影响程序运行，如果使用不当可能造成控制器收不到消息
 */
@Controller
@RequestMapping("/say")
@Api(value = "一个用来测试swagger注解的控制器")
public class SayController {
    
    @ResponseBody
    @RequestMapping(value ="/getUserName", method= RequestMethod.GET)
    @ApiOperation(value="根据用户编号获取用户姓名", notes="test: 仅1和2有正确返回")
    @ApiImplicitParam(paramType="query", name = "userNumber", value = "用户编号", required = true, dataType = "Integer")
    public String getUserName(@RequestParam Integer userNumber){
        if(userNumber == 1){
            return "张三丰";
        }
        else if(userNumber == 2){
            return "慕容复";
        }
        else{
            return "未知";
        }
    }
    
    @ResponseBody
    @RequestMapping("/updatePassword")
    @ApiOperation(value="修改用户密码", notes="根据用户id修改密码")
    @ApiImplicitParams({
        @ApiImplicitParam(paramType="query", name = "userId", value = "用户ID", required = true, dataType = "Integer"),
        @ApiImplicitParam(paramType="query", name = "password", value = "旧密码", required = true, dataType = "String"),
        @ApiImplicitParam(paramType="query", name = "newPassword", value = "新密码", required = true, dataType = "String")
    })
    public String updatePassword(@RequestParam(value="userId") Integer userId, @RequestParam(value="password") String password, 
            @RequestParam(value="newPassword") String newPassword){
      if(userId <= 0 || userId > 2){
          return "未知的用户";
      }
      if(StringUtils.isEmpty(password) || StringUtils.isEmpty(newPassword)){
          return "密码不能为空";
      }
      if(password.equals(newPassword)){
          return "新旧密码不能相同";
      }
      return "密码修改成功!";
    }
}

```

### 5、接收对象传参

```
package com.lizhiqiang.api.model.base;
 
import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;
 
/**
 * 医生对象模型
 */
@ApiModel(value="医生对象模型")
public class DemoDoctor{

    @ApiModelProperty(value="id" ,required=true)
    private Integer id;
    
    @ApiModelProperty(value="医生姓名" ,required=true)
    private String name;
 
    public Integer getId() {
        return id;
    }
 
    public void setId(Integer id) {
        this.id = id;
    }
 
    public String getName() {
        return name;
    }
 
    public void setName(String name) {
        this.name = name;
    }
 
    @Override
    public String toString() {
        return "DemoDoctor [id=" + id + ", name=" + name + "]";
    }
    
}

```

 在后台采用对象接收参数时，Swagger自带的工具采用的是JSON传参，测试时需要在参数上加入@RequestBody 注解。

```
package com.lizhiqiang.api.controller.app;
 
import java.util.ArrayList;
import java.util.List;
import javax.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import com.github.pagehelper.PageInfo;
import com.lizhiqiang.api.exception.HttpStatus401Exception;
import com.lizhiqiang.api.model.base.DemoDoctor; 
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiImplicitParam;
import io.swagger.annotations.ApiImplicitParams;
import io.swagger.annotations.ApiOperation;
 
/**
 * 医生类（模拟）
 */
@RequestMapping("/api/v1")
@Controller
@Api(value = "DoctorTestController-医生信息接口模拟")
public class DoctorTestController {
    
    /**
     * @param doctor 医生类对象
     * @return
     * @throws Exception
     */
    @ResponseBody
    @RequestMapping(value="/doctor",  method= RequestMethod.POST )
    @ApiOperation(value="添加医生信息", notes="")
    public String addDoctor(@RequestBody DemoDoctor doctor) throws Exception{
        if(null == doctor || doctor.getId() == null){
            throw new HttpStatus401Exception("添加医生失败","DT3388","未知原因","请联系管理员");
        }
        try {
          System.out.println("成功----------->"+doctor.getName());  
        } catch (Exception e) {
            throw new HttpStatus401Exception("添加医生失败","DT3388","未知原因","请联系管理员");
        }
        
        return doctor.getId().toString();
    }
    
    /**
     * 删除医生
     * @param doctorId 医生ID
     * @return
     */
    @ResponseBody
    @RequestMapping(value="/doctor/{doctorId}",  method= RequestMethod.DELETE )
    @ApiOperation(value="删除医生信息", notes="")
    @ApiImplicitParam(paramType="query", name = "doctorId", value = "医生ID", required = true, dataType = "Integer")
    public String deleteDoctor(@RequestParam Integer doctorId){
        if(doctorId > 2){
            return "删除失败";
        }
        return "删除成功";
    }
    
    /**
     * 修改医生信息
     * @param doctorId 医生ID
     * @param doctor 医生信息
     * @return
     * @throws HttpStatus401Exception
     */
    @ResponseBody
    @RequestMapping(value="/doctor/{doctorId}",  method= RequestMethod.POST )
    @ApiOperation(value="修改医生信息", notes="")
    @ApiImplicitParam(paramType="query", name = "doctorId", value = "医生ID", required = true, dataType = "Integer")
    public String updateDoctor(@RequestParam Integer doctorId, @RequestBody DemoDoctor doctor) throws HttpStatus401Exception{
        if(null == doctorId || null == doctor){
            throw new HttpStatus401Exception("修改医生信息失败","DT3391","id不能为空","请修改");
        }
        if(doctorId > 5 ){
            throw new HttpStatus401Exception("医生不存在","DT3392","错误的ID","请更换ID");
        }
        System.out.println(doctorId);
        System.out.println(doctor);
        return "修改成功";
    }
    
    /**
     * 获取医生详细信息
     * @param doctorId 医生ID
     * @return
     * @throws HttpStatus401Exception
     */
    @ResponseBody
    @RequestMapping(value="/doctor/{doctorId}",  method= RequestMethod.GET )
    @ApiOperation(value="获取医生详细信息", notes="仅返回姓名..")
    @ApiImplicitParam(paramType="query", name = "doctorId", value = "医生ID", required = true, dataType = "Integer")
    public DemoDoctor getDoctorDetail(@RequestParam Integer doctorId) throws HttpStatus401Exception{
        System.out.println(doctorId);
        if(null == doctorId){
            throw new HttpStatus401Exception("查看医生信息失败","DT3390","未知原因","请联系管理员");
        }
        if(doctorId > 3){
            throw new HttpStatus401Exception("医生不存在","DT3392","错误的ID","请更换ID");
        }
        DemoDoctor doctor = new DemoDoctor();
        doctor.setId(1);
        doctor.setName("测试员");
        return doctor;
    }
    
    /**
     * 获取医生列表
     * @param pageIndex 当前页数
     * @param pageSize 每页记录数
     * @param request
     * @return
     * @throws HttpStatus401Exception
     */
    @ResponseBody
    @RequestMapping(value="/doctor",  method= RequestMethod.GET )
    @ApiOperation(value="获取医生列表", notes="目前一次全部取，不分页")
    @ApiImplicitParams({
        @ApiImplicitParam(paramType="header", name = "token", value = "token", required = true, dataType = "String"),
        @ApiImplicitParam(paramType="query", name = "pageIndex", value = "当前页数", required = false, dataType = "String"),
        @ApiImplicitParam(paramType="query", name = "pageSize", value = "每页记录数", required = true, dataType = "String"),
    })
    public PageInfo<DemoDoctor> getDoctorList(@RequestParam(value = "pageIndex", required = false, defaultValue = "1") Integer pageIndex,
            @RequestParam(value = "pageSize", required = false) Integer pageSize,
            HttpServletRequest request) throws HttpStatus401Exception{
        
        String token = request.getHeader("token");
        if(null == token){
            throw new HttpStatus401Exception("没有权限","SS8888","没有权限","请查看操作文档");
        }
        if(null == pageSize){
            throw new HttpStatus401Exception("每页记录数不粗安在","DT3399","不存在pageSize","请查看操作文档");
        }
        
        DemoDoctor doctor1 = new DemoDoctor();
        doctor1.setId(1);
        doctor1.setName("测试员1");
        DemoDoctor doctor2 = new DemoDoctor();
        doctor2.setId(2);
        doctor2.setName("测试员2");
        
        List<DemoDoctor> doctorList = new ArrayList<DemoDoctor>();
        doctorList.add(doctor1);
        doctorList.add(doctor2);
        return new PageInfo<DemoDoctor>(doctorList);
    }
    
}
```