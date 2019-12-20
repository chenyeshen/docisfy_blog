# lombok里的Builder注解

lombok注解在java进行编译时进行代码的构建，对于java对象的创建工作它可以更优雅，不需要写多余的重复的代码，这对于JAVA开发人员是很重要的，在出现lombok之后，对象的创建工作更提供Builder方法，它提供在设计数据实体时，对外保持private setter，而对属性的赋值采用Builder的方式，这种方式最优雅，也更符合封装的原则，不对外公开属性的写操作！

@Builder声明实体，表示可以进行Builder方式初始化，@Value注解，表示只公开getter，对所有属性的setter都封闭，即private修饰，所以它不能和@Builder现起用

一般地，我们可以这样设计实体！



```
@Builder(toBuilder = true)
@Getter
public class UserInfo {
  private String name;
  private String email;
  @MinMoney(message = "金额不能小于0.")
  @MaxMoney(value = 10, message = "金额不能大于10.")
  private Money price;

}
```



@Builder注解赋值新对象

```
UserInfo userInfo = UserInfo.builder()
        .name("zzl")
        .email("bgood@sina.com")
        .build();
```

@Builder注解修改原对象的属性值

修改实体，要求实体上添加@Builder(toBuilder=true)

```
 userInfo = userInfo.toBuilder()
        .name("OK")
        .email("zgood@sina.com")
        .build();
```

