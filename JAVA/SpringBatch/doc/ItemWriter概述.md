# ItemWriter概述



## 普通文件中读取数据 再输出到数据库

### user.txt

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026140313.png)



### fileWriteToDbDemo.java

```java
package com.yeshen.springbatch_demo.fileWriteToDb;

import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.database.BeanPropertyItemSqlParameterSourceProvider;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.mapping.FieldSetMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.batch.item.file.transform.FieldSet;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.validation.BindException;

import javax.sql.DataSource;

@Configuration
@EnableBatchProcessing
public class fileWriteToDbDemo {

    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Bean
    public Job fileWriteToDbJob(){

        return  jobBuilderFactory.get("fileWriteToDbJob")
                .start(fileWriteToDbStep())
                .build();
    }

    @Bean
    public Step fileWriteToDbStep(){
        return  stepBuilderFactory.get("fileWriteToDbStep")
                .<User,User>chunk(2)
                .reader(fileItemRead())
                .writer(fileItemWrite())
                .build();
    }

    @Bean
    public JdbcBatchItemWriter<User> fileItemWrite() {
        JdbcBatchItemWriter<User> jdbcBatchItemWriter = new JdbcBatchItemWriter<User>();
        jdbcBatchItemWriter.setDataSource(dataSource);
        jdbcBatchItemWriter.setSql("insert into user(id,name,passwd) values(:id,:name,:passwd)");
        jdbcBatchItemWriter.setItemSqlParameterSourceProvider(new BeanPropertyItemSqlParameterSourceProvider<User>());
        jdbcBatchItemWriter.afterPropertiesSet();
        return  jdbcBatchItemWriter;
    }

    @Bean
    @StepScope
    public FlatFileItemReader<User> fileItemRead() {

        FlatFileItemReader<User> userFlatFileItemReader = new FlatFileItemReader<>();

        userFlatFileItemReader.setResource(new ClassPathResource("user3.txt"));

        //如何解析
        DefaultLineMapper<User> lineMapper=new DefaultLineMapper<User>();
        DelimitedLineTokenizer delimitedLineTokenizer=new DelimitedLineTokenizer();
        delimitedLineTokenizer.setNames(new String[]{"id","name","passwd"});
        lineMapper.setLineTokenizer(delimitedLineTokenizer);
        lineMapper.setFieldSetMapper(new FieldSetMapper<User>() {
            @Override
            public User mapFieldSet(FieldSet fieldSet) throws BindException {

                User user=new User();

                user.setId(fieldSet.readInt("id"));
                user.setName(fieldSet.readString("name"));
                user.setPasswd(fieldSet.readString("passwd"));

                return user;
            }
        });
        lineMapper.afterPropertiesSet();
        userFlatFileItemReader.setLineMapper(lineMapper);
        return  userFlatFileItemReader;
    }
}

```

### 运行结果：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026140427.png)





## 数据库中读取数据  再输出到普通文件



### 数据库user表数据

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026120506.png)

### DbWriterToFileDemo.java

```java
package com.yeshen.springbatch_demo.DbWriterToFile;

import cn.hutool.core.bean.BeanUtil;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.yeshen.springbatch_demo.bean.User;
import org.springframework.batch.core.Job;
import org.springframework.batch.core.Step;
import org.springframework.batch.core.configuration.annotation.EnableBatchProcessing;
import org.springframework.batch.core.configuration.annotation.JobBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepBuilderFactory;
import org.springframework.batch.core.configuration.annotation.StepScope;
import org.springframework.batch.item.database.BeanPropertyItemSqlParameterSourceProvider;
import org.springframework.batch.item.database.JdbcBatchItemWriter;
import org.springframework.batch.item.database.JdbcPagingItemReader;
import org.springframework.batch.item.database.Order;
import org.springframework.batch.item.database.support.MySqlPagingQueryProvider;
import org.springframework.batch.item.file.FlatFileItemReader;
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.mapping.DefaultLineMapper;
import org.springframework.batch.item.file.mapping.FieldSetMapper;
import org.springframework.batch.item.file.transform.DelimitedLineTokenizer;
import org.springframework.batch.item.file.transform.FieldSet;
import org.springframework.batch.item.file.transform.LineAggregator;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.validation.BindException;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class DbWriterToFileDemo {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Bean
    public Job DbWriteToFileJob1(){

        return  jobBuilderFactory.get("DbWriteToFileJob1")
                .start(DbWriteToFileStep())
                .build();
    }

    @Bean
    public Step DbWriteToFileStep(){
        return  stepBuilderFactory.get("DbWriteToFileStep")
                .<User,User>chunk(2)
                .reader(myDbItemRead())
                .writer(myFileItemWrite())
                .build();
    }

    @Bean
    public FlatFileItemWriter<User> myFileItemWrite() {
        FlatFileItemWriter<User> userFlatFileItemWriter = new FlatFileItemWriter<>();
        String path="d:\\user.txt";
        userFlatFileItemWriter.setResource(new FileSystemResource(path));
        userFlatFileItemWriter.setLineAggregator(new LineAggregator<User>() {
            @Override
            public String aggregate(User user) {
                String str=null;
                ObjectMapper mapper=new ObjectMapper();
                try {
                    str= mapper.writeValueAsString(user);
                } catch (JsonProcessingException e) {
                    e.printStackTrace();
                }
                return str;
            }
        });
        try {
            userFlatFileItemWriter.afterPropertiesSet();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return  userFlatFileItemWriter;
    }

    @Bean
    @StepScope
    public JdbcPagingItemReader<User> myDbItemRead() {
        JdbcPagingItemReader<User> reader = new JdbcPagingItemReader<>();
        reader.setDataSource(dataSource);
        reader.setRowMapper(new RowMapper<User>() {
            @Override
            public User mapRow(ResultSet resultSet, int i) throws SQLException {
                User user = new User();
                user.setId(resultSet.getInt(1));
                user.setName(resultSet.getString(2));
                user.setPasswd(resultSet.getString(3));
                return user;
            }
        });
        //定制mysq语句
        MySqlPagingQueryProvider mySqlPagingQueryProvider=new MySqlPagingQueryProvider();
        mySqlPagingQueryProvider.setSelectClause("id,name,passwd");
        mySqlPagingQueryProvider.setFromClause("from user");
        
         //必须有条件排序 不然报错
        Map<String, Order> orderHashMap = new HashMap<>(1);
        orderHashMap.put("id",Order.ASCENDING);

        mySqlPagingQueryProvider.setSortKeys(orderHashMap);
        reader.setQueryProvider(mySqlPagingQueryProvider);

        return reader;


    }
}

```

### 成功写入文件 如图：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026120226.png)





## 数据库中读取数据  再输出到Xml文件



### DbWriterToXmlDemo.java

```java
package com.yeshen.springbatch_demo.DbWriteToXmlDemo;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
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
import org.springframework.batch.item.file.FlatFileItemWriter;
import org.springframework.batch.item.file.transform.LineAggregator;
import org.springframework.batch.item.xml.StaxEventItemWriter;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.io.FileSystemResource;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.oxm.xstream.XStreamMarshaller;
import sun.security.krb5.internal.PAData;

import javax.sql.DataSource;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableBatchProcessing
public class DbWriterToXmlDemo {
    @Autowired
    private JobBuilderFactory jobBuilderFactory;

    @Autowired
    private StepBuilderFactory stepBuilderFactory;

    @Autowired
    private DataSource dataSource;

    @Bean
    public Job DbWriteToXmlJob1(){

        return  jobBuilderFactory.get("DbWriteToXmlJob1")
                .start(DbWriteToXmlStep())
                .build();
    }

    @Bean
    public Step DbWriteToXmlStep(){
        return  stepBuilderFactory.get("DbWriteToXmlStep")
                .<User,User>chunk(2)
                .reader(xmlDbItemRead())
                .writer(xmlFileItemWrite())
                .build();
    }

    @Bean
    public StaxEventItemWriter<User> xmlFileItemWrite() {
        StaxEventItemWriter<User> userStaxEventItemWriter = new StaxEventItemWriter<>();
        userStaxEventItemWriter.setRootTagName("Users");
        XStreamMarshaller marshaller=new XStreamMarshaller();
        Map<String,Class> aliasesMap=new HashMap<>();
        aliasesMap.put("User",User.class);
        marshaller.setAliases(aliasesMap);
        userStaxEventItemWriter.setMarshaller(marshaller);
        try {
            userStaxEventItemWriter.afterPropertiesSet();
        } catch (Exception e) {
            e.printStackTrace();
        }

        String path="d:\\user.xml";
        userStaxEventItemWriter.setResource(new FileSystemResource(path));

        return userStaxEventItemWriter;
    }

    @Bean
    @StepScope
    public JdbcPagingItemReader<User> xmlDbItemRead() {
        JdbcPagingItemReader<User> reader = new JdbcPagingItemReader<>();
        reader.setDataSource(dataSource);
        reader.setRowMapper(new RowMapper<User>() {
            @Override
            public User mapRow(ResultSet resultSet, int i) throws SQLException {
                User user = new User();
                user.setId(resultSet.getInt(1));
                user.setName(resultSet.getString(2));
                user.setPasswd(resultSet.getString(3));
                return user;
            }
        });
        MySqlPagingQueryProvider mySqlPagingQueryProvider=new MySqlPagingQueryProvider();
        mySqlPagingQueryProvider.setSelectClause("id,name,passwd");
        mySqlPagingQueryProvider.setFromClause("from user");

        Map<String, Order> orderHashMap = new HashMap<>(1);
        orderHashMap.put("id",Order.ASCENDING);

        mySqlPagingQueryProvider.setSortKeys(orderHashMap);
        reader.setQueryProvider(mySqlPagingQueryProvider);

        return reader;


    }
}

```



### 成功写入文件 如图：

![](https://raw.githubusercontent.com/mukeyeshen/picos/master/img/20191026145734.png)



