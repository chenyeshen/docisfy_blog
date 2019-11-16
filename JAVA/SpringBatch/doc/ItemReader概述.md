# ItemReader概述

```
package com.yeshen.springbatch_demo.config;

import org.springframework.batch.core.*;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.scope.context.ChunkContext;
import org.springframework.batch.core.step.tasklet.Tasklet;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.support.ListItemReader;
import org.springframework.batch.repeat.RepeatStatus;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class ItemReaderDemo {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Bean
    public Job ItemReaderJob() {
        return jobBuilderFactory.get("ItemReaderJob")
                .start(ItemReaderJobStep())
                .build();
    }

    @Bean
    public Step ItemReaderJobStep() {

        return stepBuilderFactory.get("ItemReaderJobStep")
                .<String,String>chunk(2)
                .reader(MyItemReader())
                .writer(list -> {
                    for (String string:list){
                        System.out.println("数据为："+string);
                    }
                })
                .build();

    }

    public ItemReader<String> MyItemReader() {
        return  new ListItemReader<>(Arrays.asList("cat","dog","pig","tiger","bird"));
    }

}

```

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191025224634.png)





## JdbcPagingItemReader从数据库中读取

### user.java

```
package com.yeshen.springbatch_demo.bean;

public class User {

    private  int id;

    private  String name;

    private  String passwd;

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", passwd='" + passwd + '\'' +
                '}';
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPasswd() {
        return passwd;
    }

    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
}

```

### DbJdbcItemReaderDemo.java

```
package com.yeshen.springbatch_demo.config;

import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.ItemReader;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.JdbcPagingItemReader;
import org.springframework.batch.item.database.Order;
import org.springframework.batch.item.database.support.MySqlPagingQueryProvider;
import org.springframework.batch.item.support.ListItemReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.RowMapper;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class DbJdbcItemReaderDemo {

    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Autowired
    @Qualifier("jdbcWriter")
    private  ItemWriter<? super User> jdbcWriter;
    @Bean
    public Job DbJdbcJob5() {
        return jobBuilderFactory.get("DbJdbcJob5")
                .start(DbJdbcJobStep())
                .build();
    }

    @Bean
    public Step DbJdbcJobStep() {

        return stepBuilderFactory.get("DbJdbcJobStep")
                .<User,User>chunk(2)
                .reader(MyItemReader())
                .writer(jdbcWriter)
                .build();

    }
    @Bean
    @StepScope
    public JdbcPagingItemReader<User> MyItemReader() {
        JdbcPagingItemReader<User> reader=new JdbcPagingItemReader<User>();

        reader.setDataSource(dataSource);
        reader.setFetchSize(2);
        reader.setRowMapper(new RowMapper<User>() {
            @Override
            public User mapRow(ResultSet resultSet, int rowNum) throws SQLException {
                User user = new User();
                user.setId(resultSet.getInt(1));
                user.setName(resultSet.getString(2));
                user.setPasswd(resultSet.getString(3));
                return user;
            }
        });
        //制定sql语句
        MySqlPagingQueryProvider provider=new MySqlPagingQueryProvider();
        provider.setSelectClause("id,name,passwd");
        provider.setFromClause("from user");
        // 根据哪个排序
        Map<String,Order> map=new HashMap<>(1);
        map.put("id",Order.ASCENDING);
        provider.setSortKeys(map);
        
        reader.setQueryProvider(provider);
        return reader ;
    }

}

```

### JdbcWriter.java

```
package com.yeshen.springbatch_demo.config;

import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component("jdbcWriter")
public class JdbcWriter implements ItemWriter<User> {

    @Override
    public void write(List<? extends User> list) throws Exception {
        for (User user:list){
            System.out.println(user);
        }
    }
}

```



### 数据user表

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026001928.png)

### 读取数据库结果 如图：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026001828.png)





## StaxEventItemReader从xml中读取



### pom.xml

```
<!-- https://mvnrepository.com/artifact/org.springframework/spring-oxm -->
<dependency>
    <groupId>org.springframework</groupId>
    <artifactId>spring-oxm</artifactId>
    <version>5.1.4.RELEASE</version>
</dependency>

<!-- https://mvnrepository.com/artifact/com.thoughtworks.xstream/xstream -->
<dependency>
    <groupId>com.thoughtworks.xstream</groupId>
    <artifactId>xstream</artifactId>
    <version>1.4.11.1</version>
</dependency>
```

### user.xml

```
<?xml version="1.0" encoding="GBK" ?>
<xml>
    <users>
        <user>
            <id>001</id>
            <name>yeshen001</name>
            <passwd>batch001</passwd>
        </user>
        <user>
            <id>002</id>
            <name>yeshen002</name>
            <passwd>batch002</passwd>
        </user>
        <user>
            <id>003</id>
            <name>yeshen003</name>
            <passwd>batch003</passwd>
        </user>
        <user>
            <id>004</id>
            <name>yeshen004</name>
            <passwd>batch004</passwd>
        </user>

    </users>

</xml>
```

### user.java

```
package com.yeshen.springbatch_demo.bean;

public class User {

    private  int id;

    private  String name;

    private  String passwd;

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", passwd='" + passwd + '\'' +
                '}';
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPasswd() {
        return passwd;
    }

    public void setPasswd(String passwd) {
        this.passwd = passwd;
    }
}

```

### XmlItemReaderDemo.java

```
package com.yeshen.springbatch_demo.config;

import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.ItemWriter;
import org.springframework.batch.item.database.JdbcPagingItemReader;
import org.springframework.batch.item.database.Order;
import org.springframework.batch.item.database.support.MySqlPagingQueryProvider;
import org.springframework.batch.item.xml.StaxEventItemReader;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.oxm.xstream.XStreamMarshaller;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class XmlItemReaderDemo {

    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Autowired
    @Qualifier("xmlWriter")
    private  ItemWriter<? super User> xmlWriter;
    @Bean
    public Job XmlJob() {
        return jobBuilderFactory.get("XmlJob")
                .start(XMLJobStep())
                .build();
    }

    @Bean
    public Step XMLJobStep() {

        return stepBuilderFactory.get("XMLJobStep")
                .<User,User>chunk(2)
                .reader(XMLItemReader())
                .writer(xmlWriter)
                .build();

    }
    @Bean
    @StepScope
    public StaxEventItemReader<User> XMLItemReader() {
        StaxEventItemReader<User> reader=new StaxEventItemReader<User>();
        reader.setResource(new ClassPathResource("user.xml"));
        reader.setFragmentRootElementName("user");
        XStreamMarshaller ummarshaller=new XStreamMarshaller();
        Map<String,Class> map=new HashMap<>();
        map.put("user",User.class);
        ummarshaller.setAliases(map);
        reader.setUnmarshaller(ummarshaller);
        return  reader;
    }

}

```

### XmlWriter.java

```
package com.yeshen.springbatch_demo.config;

import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.item.ItemWriter;
import org.springframework.stereotype.Component;

import java.util.List;

@Component("xmlWriter")
public class XmlWriter implements ItemWriter<User> {

    @Override
    public void write(List<? extends User> list) throws Exception {
        for (User user:list){
            System.out.println(user);
        }
    }
}

```

### xml读取结果 如图所示：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026011135.png)



