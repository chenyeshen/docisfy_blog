# SpringBoot整合elasticsearch

### pom.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.2.1.RELEASE</version>
        <relativePath/> <!-- lookup parent from repository -->
    </parent>
    <groupId>com.example</groupId>
    <artifactId>demo</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <name>demo</name>
    <description>Demo project for Spring Boot</description>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
            <exclusions>
                <exclusion>
                    <groupId>org.junit.vintage</groupId>
                    <artifactId>junit-vintage-engine</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <!-- https://mvnrepository.com/artifact/org.elasticsearch/elasticsearch -->
        <dependency>
            <groupId>org.elasticsearch</groupId>
            <artifactId>elasticsearch</artifactId>
            <version>6.5.4</version>
        </dependency>
        <!-- https://mvnrepository.com/artifact/org.elasticsearch.client/elasticsearch-rest-high-level-client -->
        <dependency>
            <groupId>org.elasticsearch.client</groupId>
            <artifactId>elasticsearch-rest-high-level-client</artifactId>
            <version>6.5.4</version>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>

</project>

```



### application.yml

```
yeshen:
   elasticsearch:
     # hostlist: ${eshostlist:127.0.0.1:9200,127.0.0.1:9201,}//多个节点用逗号分隔
      hostlist: ${eshostlist:127.0.0.1:9200}
spring:
  application:
    name: yeshen
```



### ElasticsearchConfig

```
package com.example.demo;

import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ElasticsearchConfig {
    @Value("${yeshen.elasticsearch.hostlist}")
    private String hostlist;

    @Bean
    public RestHighLevelClient restHighLevelClient(){
        String [] split=hostlist.split(",");
        HttpHost [] httpHostArray=new HttpHost[split.length];
        for (int i=0;i<split.length;i++){
            String item=split[i];
            httpHostArray[i]=new HttpHost(item.split(":")[0],Integer.parseInt(item.split(":")[1]));
        }
        return new RestHighLevelClient(RestClient.builder(httpHostArray));
    }
}

```



### 单元测试DemoApplicationTests

```
package com.example.demo;

import org.elasticsearch.action.DocWriteResponse;
import org.elasticsearch.action.admin.indices.create.CreateIndexRequest;
import org.elasticsearch.action.admin.indices.create.CreateIndexResponse;
import org.elasticsearch.action.admin.indices.delete.DeleteIndexRequest;
import org.elasticsearch.action.get.GetRequest;
import org.elasticsearch.action.get.GetResponse;
import org.elasticsearch.action.index.IndexRequest;
import org.elasticsearch.action.index.IndexResponse;
import org.elasticsearch.action.search.SearchRequest;
import org.elasticsearch.action.search.SearchRequestBuilder;
import org.elasticsearch.action.search.SearchResponse;
import org.elasticsearch.action.support.master.AcknowledgedResponse;
import org.elasticsearch.action.update.UpdateRequest;
import org.elasticsearch.action.update.UpdateResponse;
import org.elasticsearch.client.IndicesClient;
import org.elasticsearch.client.RestHighLevelClient;
import org.elasticsearch.common.settings.Settings;
import org.elasticsearch.common.xcontent.XContentType;
import org.elasticsearch.index.query.QueryBuilder;
import org.elasticsearch.index.query.QueryBuilders;
import org.elasticsearch.rest.RestStatus;
import org.elasticsearch.search.SearchHit;
import org.elasticsearch.search.SearchHits;
import org.elasticsearch.search.builder.SearchSourceBuilder;
import org.junit.jupiter.api.Test;
import org.omg.CORBA.OBJ_ADAPTER;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

@SpringBootTest
class DemoApplicationTests {

    @Autowired
    private RestHighLevelClient restHighLevelClient;
    @Test
    void contextLoads() throws IOException {
        DeleteIndexRequest indexRequest=new DeleteIndexRequest("yeshen");
        IndicesClient indices = restHighLevelClient.indices();
        AcknowledgedResponse acknowledgedResponse = indices.delete(indexRequest);
        boolean acknowledged = acknowledgedResponse.isAcknowledged();

        System.out.println("是否为"+acknowledged);
    }
    @Test
    void create() throws IOException {
        CreateIndexRequest indexRequest=new CreateIndexRequest("yeshen01");
        indexRequest.settings(Settings.builder().put("number_of_shards",1).put("number_of_replicas",0));


        indexRequest.mapping("doc","{\n" +
                "  \"properties\": {\t\"name\":{\n" +
                "\t  \"type\":\"text\"\n" +
                "\t},\n" +
                "\t\"description\":{\n" +
                "\t  \"type\":\"text\"\n" +
                "\t}\n" +
                "   }\n" +
                "}",XContentType.JSON);
        IndicesClient indices = restHighLevelClient.indices();
        CreateIndexResponse response = indices.create(indexRequest);
        boolean acknowledged = response.isAcknowledged();

        System.out.println("是否为"+acknowledged);
    }
    @Test
    public void save() throws IOException {

        IndexRequest indexRequest=new IndexRequest("yeshen01","doc");
         indexRequest.source("{\n" +
                "\t\"name\":\"网易新闻\",\n" +
                "\t\"description\":\"在正在举行的第二届中国国际进口博览会上\"\n" +
                "}", XContentType.JSON);
        IndexResponse indexResponse = restHighLevelClient.index(indexRequest);
        DocWriteResponse.Result responseResult = indexResponse.getResult();
        System.out.println(responseResult);
    }

    @Test
    public void update() throws IOException {

        Map<String,Object> map=new HashMap<>();

        map.put("name","spring开发");

        UpdateRequest updateRequest=new UpdateRequest("yeshen01","doc","-MNSTm4BvTucUsh-6Tji");
        updateRequest.doc(map);
        UpdateResponse indexResponse = restHighLevelClient.update(updateRequest);
        RestStatus status = indexResponse.status();
        System.out.println(status);

    }

    @Test
    public void get() throws IOException {


        GetRequest getRequest=new GetRequest("yeshen01","doc","-MNSTm4BvTucUsh-6Tji");
        GetResponse documentFields = restHighLevelClient.get(getRequest);

        Map<String, Object> sourceAsMap = documentFields.getSourceAsMap();
        System.out.println(sourceAsMap);

    }

    @Test
    public void search() throws IOException {

        SearchRequest searchRequest=new SearchRequest("yeshen01");
        searchRequest.types("doc");

        SearchSourceBuilder builder=new SearchSourceBuilder();
        builder.query(QueryBuilders.matchAllQuery());
        builder.fetchSource(new String[]{"name","description"},new String[]{});

        searchRequest.source(builder);

        SearchResponse response = restHighLevelClient.search(searchRequest);
        SearchHits hits = response.getHits();
        System.out.println(hits.totalHits);
        for(SearchHit hit :hits){
            Map<String, Object> sourceAsMap = hit.getSourceAsMap();
            String name= (String) sourceAsMap.get("name");
            String description= (String) sourceAsMap.get("description");

            System.out.println(name+"hahaha"+description);
        }

        }


    @Test
    public void page() throws IOException {

        SearchRequest searchRequest=new SearchRequest("yeshen01");
        searchRequest.types("doc");

        SearchSourceBuilder builder=new SearchSourceBuilder();
        builder.query(QueryBuilders.matchAllQuery());
        builder.fetchSource(new String[]{"name","description"},new String[]{});//

        int page=1;
        int size=4;
        int from=(page-1)*size;
        builder.from(from);
        builder.size(size);

        searchRequest.source(builder);

        SearchResponse response = restHighLevelClient.search(searchRequest);
        SearchHits hits = response.getHits();
        System.out.println(hits.totalHits);
        for(SearchHit hit :hits){
            Map<String, Object> sourceAsMap = hit.getSourceAsMap();
            String name= (String) sourceAsMap.get("name");
            String description= (String) sourceAsMap.get("description");

            System.out.println(name+"hahaha"+description);
        }

    }

    @Test
    public void ternQuary() throws IOException {

        SearchRequest searchRequest=new SearchRequest("yeshen01");
        searchRequest.types("doc");

        SearchSourceBuilder builder=new SearchSourceBuilder();
        builder.query(QueryBuilders.termQuery("name","spring"));
        builder.fetchSource(new String[]{"name","description"},new String[]{});//

        int page=1;
        int size=4;
        int from=(page-1)*size;
        builder.from(from);
        builder.size(size);

        searchRequest.source(builder);

        SearchResponse response = restHighLevelClient.search(searchRequest);
        SearchHits hits = response.getHits();
        System.out.println(hits.totalHits);
        for(SearchHit hit :hits){
            Map<String, Object> sourceAsMap = hit.getSourceAsMap();
            String name= (String) sourceAsMap.get("name");
            String description= (String) sourceAsMap.get("description");

            System.out.println(name+"hahaha"+description);
        }

    }

    /**
     * 根据id查询
     * @throws IOException
     */
    @Test
    public void ids() throws IOException {

        SearchRequest searchRequest=new SearchRequest("yeshen");
        searchRequest.types("doc");

        String ids_string[]=new String[]{"100100"};
        SearchSourceBuilder builder=new SearchSourceBuilder();
        builder.query(QueryBuilders.termsQuery("_id",ids_string));
        builder.fetchSource(new String[]{"name","description"},new String[]{});//

        int page=1;
        int size=4;
        int from=(page-1)*size;
        builder.from(from);
        builder.size(size);

        searchRequest.source(builder);

        SearchResponse response = restHighLevelClient.search(searchRequest);
        SearchHits hits = response.getHits();
        System.out.println(hits.totalHits);
        for(SearchHit hit :hits){
            Map<String, Object> sourceAsMap = hit.getSourceAsMap();
            String name= (String) sourceAsMap.get("name");
            String description= (String) sourceAsMap.get("description");

            System.out.println(name+"hahaha"+description);
        }

    }


}

```

