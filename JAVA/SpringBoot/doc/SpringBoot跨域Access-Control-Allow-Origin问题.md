### **什么是跨域呢？**

> 我们先回顾一下域名地址的组成：
>
> http:// www . google : 8080 / script/jquery.js
>
> 　　http:// （协议号）
>
> 　　www  （子域名）
>
> 　　google （主域名）
>
> 　　 8080 （端口号）
>
> 　　script/jquery.js （请求的地址）
>
> \* 当协议、子域名、主域名、端口号中任意一各不相同时，都算不同的“域”。
>
> \* 不同的域之间相互请求资源，就叫“跨域”。



![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190830222012704.png)

![img](https://chenyeshen.oss-cn-shenzhen.aliyuncs.com/oneblog/article/20190830222135472.png)



### **跨域处理，三种方法：**

1、处理跨域方法一 **代理**

通过在同域名下的web服务器端创建一个代理： 

北京服务器(域名:www.beijing.com) 

上海服务器(域名：www.shanghai.com) 

比如在北京的web服务器的后台(www.beijing.com/proxy-shanghaiservice.php)来调用上海服务器(www.shanghai.com/services.php)的服务，然后再把访问结果返回给前端，这样前端调用北京同域名的服务就和调用上海的服务效果相同了。

### **2、处理跨域方式二——JSONP(只支持GET请求)：**

JSONP可用于解决主流浏览器的跨域数据访问的问题。 

在www.aaa.com页面中： 

<script> 

function jsonp(json){ 

alert(json["name"]); 

} 

</script> 

<script src="http;//www.bbb.com/jsonp.js"></script> 

在www.bbb.com页面中： 

jsonp({'name':'xx','age':24})

****

### **3、处理跨域的方法三——XHR2：**

1、HTML5提供的XMLHttpRequest Level2已经实现了跨域访问以及其他的一些新功能 

2.IE10以下的版本都不支持 

3.在服务器端 

header('Access-Control-Allow-Origin:*'); 

header('Access-Control-Allow-Methods:POST,GET'); 

### 方式一： 

在过滤器中设置响应头

```
@Component
public class CorsFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain) throws IOException, ServletException {
        HttpServletResponse response = (HttpServletResponse) res;

        HttpServletRequest reqs = (HttpServletRequest) req;

        // response.setHeader("Access-Control-Allow-Origin",reqs.getHeader("Origin"));
        response.setHeader("Access-Control-Allow-Origin","*");
        response.setHeader("Access-Control-Allow-Credentials", "true");
        response.setHeader("Access-Control-Allow-Methods", "POST, GET, PATCH, DELETE, PUT");
        response.setHeader("Access-Control-Max-Age", "3600");
        response.setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig filterConfig) {}

    @Override
    public void destroy() {}

```

### 方式二： 

对SpringBoot进行配置

```
@Configuration  
public class CorsConfig extends WebMvcConfigurerAdapter {  

    @Override  
    public void addCorsMappings(CorsRegistry registry) {  
        registry.addMapping("/**")  
                .allowedOrigins("*")  
                .allowCredentials(true)  
                .allowedMethods("GET", "POST", "DELETE", "PUT")  
                .maxAge(3600);  
    }  

}  
```