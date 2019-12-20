

# lombok使用及常用注解

### maven依赖

```
<!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.16.16</version>
</dependency>
```

## 常用方法

### @Data(常用)

> @Data直接修饰POJO or beans， getter所有的变量，setter所有不为final的变量。如果你不需要默认的生成方式，直接填写你需要的annotation的就可以了。默认生成的所有的annotation都是public的，如果需要不同权限修饰符可以使用AccessLevel.NONE选项。当然@Data 也可以使用staticConstructor选项生成一个静态方法。
>
> =@Setter+@Getter+@EqualsAndHashCode+@NoArgsConstructor

```
//原始类
@Data
public class TestEntity {
    @Setter(AccessLevel.PRIVATE)
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
 
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
 
    public String getName() {
        return this.name;
    }
 
    public Integer getAge() {
        return this.age;
    }
 
    public String getType() {
        this.getClass();
        return "person";
    }
 
    public void setAge(Integer age) {
        this.age = age;
    }
 
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        } else if(!(o instanceof TestEntity)) {
            return false;
        } else {
            TestEntity other = (TestEntity)o;
            if(!other.canEqual(this)) {
                return false;
            } else {
                label47: {
                    String this$name = this.getName();
                    String other$name = other.getName();
                    if(this$name == null) {
                        if(other$name == null) {
                            break label47;
                        }
                    } else if(this$name.equals(other$name)) {
                        break label47;
                    }
 
                    return false;
                }
 
                Integer this$age = this.getAge();
                Integer other$age = other.getAge();
                if(this$age == null) {
                    if(other$age != null) {
                        return false;
                    }
                } else if(!this$age.equals(other$age)) {
                    return false;
                }
 
                String this$type = this.getType();
                String other$type = other.getType();
                if(this$type == null) {
                    if(other$type != null) {
                        return false;
                    }
                } else if(!this$type.equals(other$type)) {
                    return false;
                }
 
                return true;
            }
        }
    }
 
    protected boolean canEqual(Object other) {
        return other instanceof TestEntity;
    }
 
    public int hashCode() {
        boolean PRIME = true;
        byte result = 1;
        String $name = this.getName();
        int result1 = result * 59 + ($name == null?43:$name.hashCode());
        Integer $age = this.getAge();
        result1 = result1 * 59 + ($age == null?43:$age.hashCode());
        String $type = this.getType();
        result1 = result1 * 59 + ($type == null?43:$type.hashCode());
        return result1;
    }
 
    public String toString() {
        return "TestEntity(name=" + this.getName() + ", age=" + this.getAge() + ", type=" + this.getType() + ")";
    }
 
    private void setName(String name) {
        this.name = name;
    }
}
 
```

### @Builder

构造Builder模式的结构。通过内部类Builder()进行构建对象。

```
//原始类
@Builder
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    @ConstructorProperties({"name", "age"})
    TestEntity(String name, Integer age) {
        this.name = name;
        this.age = age;
    }
 
    public static TestEntity.TestEntityBuilder builder() {
        return new TestEntity.TestEntityBuilder();
    }
 
    public static class TestEntityBuilder {
        private String name;
        private Integer age;
 
        TestEntityBuilder() {
        }
 
        public TestEntity.TestEntityBuilder name(String name) {
            this.name = name;
            return this;
        }
 
        public TestEntity.TestEntityBuilder age(Integer age) {
            this.age = age;
            return this;
        }
 
        public TestEntity build() {
            return new TestEntity(this.name, this.age);
        }
 
        public String toString() {
            return "TestEntity.TestEntityBuilder(name=" + this.name + ", age=" + this.age + ")";
        }
    }
}
 
//Builder模式使用方法
@Test
public  void test(){
    TestEntity testEntity = TestEntity.builder()
                    .name("java")
                    .age(18)
                    .build();
}
```

### @Value

> 与@Data相对应的@Value， 两个annotation的主要区别就是如果变量不加@NonFinal ，@Value会给所有的弄成final的。当然如果是final的话，就没有set方法了。

```
//原始类
@Value
public class TestEntity {
    @Setter(AccessLevel.PRIVATE)
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public final class TestEntity {
    private final String name;
    private final Integer age;
    private final String type = "person";
 
    @ConstructorProperties({"name", "age"})
    public TestEntity(String name, Integer age) {
        this.name = name;
        this.age = age;
    }
 
    public String getName() {
        return this.name;
    }
 
    public Integer getAge() {
        return this.age;
    }
 
    public String getType() {
        this.getClass();
        return "person";
    }
 
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        } else if(!(o instanceof TestEntity)) {
            return false;
        } else {
            TestEntity other;
            label44: {
                other = (TestEntity)o;
                String this$name = this.getName();
                String other$name = other.getName();
                if(this$name == null) {
                    if(other$name == null) {
                        break label44;
                    }
                } else if(this$name.equals(other$name)) {
                    break label44;
                }
 
                return false;
            }
 
            Integer this$age = this.getAge();
            Integer other$age = other.getAge();
            if(this$age == null) {
                if(other$age != null) {
                    return false;
                }
            } else if(!this$age.equals(other$age)) {
                return false;
            }
 
            String this$type = this.getType();
            String other$type = other.getType();
            if(this$type == null) {
                if(other$type != null) {
                    return false;
                }
            } else if(!this$type.equals(other$type)) {
                return false;
            }
 
            return true;
        }
    }
 
    public int hashCode() {
        boolean PRIME = true;
        byte result = 1;
        String $name = this.getName();
        int result1 = result * 59 + ($name == null?43:$name.hashCode());
        Integer $age = this.getAge();
        result1 = result1 * 59 + ($age == null?43:$age.hashCode());
        String $type = this.getType();
        result1 = result1 * 59 + ($type == null?43:$type.hashCode());
        return result1;
    }
 
    public String toString() {
        return "TestEntity(name=" + this.getName() + ", age=" + this.getAge() + ", type=" + this.getType() + ")";
    }
}
```



### @Setter

生成setter方法,final变量不包含

```
//原始类
@Setter
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "type";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
 
    public void setName(String name) {
        this.name = name;
    }
 
    public void setAge(Integer age) {
        this.age = age;
    }
}
```

### @Getter

生成getter方法,final变量不包含

```
//原始类
@Getter
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
 
    public String getName() {
        return this.name;
    }
 
    public Integer getAge() {
        return this.age;
    }
 
    public String getType() {
        this.getClass();
        return "person";
    }
}
```

### @NoArgsConstructor

生成空参构造

```
//原始类
@NoArgsConstructor
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
}
```

### @AllArgsConstructor

生成全部参数构造

```
//原始类
@AllArgsConstructor
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    @ConstructorProperties({"name", "age"})
    public TestEntity(String name, Integer age) {
        this.name = name;
        this.age = age;
    }
}
```

### @ToString

生成所有属性的toString()方法

```
//原始类
@ToString
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
 
    public String toString() {
        StringBuilder var10000 = (new StringBuilder()).append("TestEntity(name=").append(this.name).append(", age=").append(this.age).append(", type=");
        this.getClass();
        return var10000.append("person").append(")").toString();
    }
}
```



### @RequiredArgsConstructor

将标记为@NoNull的属性生成一个构造器

> 如果运行中标记为@NoNull的属性为null,会抛出空指针异常。

```
//原始类
@RequiredArgsConstructor
public class TestEntity {
 
    private String name;
    @NonNull
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    @NonNull
    private Integer age;
    private final String type = "person";
 
    @ConstructorProperties({"age"})
    public TestEntity(@NonNull Integer age) {
        if(age == null) {
            throw new NullPointerException("age");
        } else {
            this.age = age;
        }
    }
}
```

### @EqualsAndHashCode

生成equals()方法和hashCode方法

```
//原始类
@EqualsAndHashCode
public class TestEntity {
 
    private String name;
 
    private Integer age;
 
    private final String type = "person";
}
//反编译的类
public class TestEntity {
    private String name;
    private Integer age;
    private final String type = "person";
 
    public TestEntity() {
    }
 
    public boolean equals(Object o) {
        if(o == this) {
            return true;
        } else if(!(o instanceof TestEntity)) {
            return false;
        } else {
            TestEntity other = (TestEntity)o;
            if(!other.canEqual(this)) {
                return false;
            } else {
                label47: {
                    String this$name = this.name;
                    String other$name = other.name;
                    if(this$name == null) {
                        if(other$name == null) {
                            break label47;
                        }
                    } else if(this$name.equals(other$name)) {
                        break label47;
                    }
 
                    return false;
                }
 
                Integer this$age = this.age;
                Integer other$age = other.age;
                if(this$age == null) {
                    if(other$age != null) {
                        return false;
                    }
                } else if(!this$age.equals(other$age)) {
                    return false;
                }
 
                this.getClass();
                String this$type = "person";
                other.getClass();
                String other$type = "person";
                if(this$type == null) {
                    if(other$type != null) {
                        return false;
                    }
                } else if(!this$type.equals(other$type)) {
                    return false;
                }
 
                return true;
            }
        }
    }
 
    protected boolean canEqual(Object other) {
        return other instanceof TestEntity;
    }
 
    public int hashCode() {
        boolean PRIME = true;
        byte result = 1;
        String $name = this.name;
        int result1 = result * 59 + ($name == null?43:$name.hashCode());
        Integer $age = this.age;
        result1 = result1 * 59 + ($age == null?43:$age.hashCode());
        this.getClass();
        String $type = "person";
        result1 = result1 * 59 + ($type == null?43:$type.hashCode());
        return result1;
    }
}
```

