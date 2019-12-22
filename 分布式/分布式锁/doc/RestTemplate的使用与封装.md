# RestTemplate 的使用与封装

```
package com.ruiyibd.edp.cloud.consumer.rest;
 
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.support.spring.FastJsonHttpMessageConverter;
import com.ruiyibd.edp.framework.web.WebConfiguration;
import com.ruiyibd.edp.framework.web.protocol.ResponseData;
import com.ruiyibd.edp.framework.web.protocol.ResponseDataFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.http.converter.json.MappingJackson2HttpMessageConverter;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.web.client.RestTemplate;
 
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
 
/**
 * 实现负载均衡的RestTemplate
 * @author Dorne
 * @date 2018-09-17
 */
public class LoadBalancedRestTemplate extends RestTemplate implements InitializingBean {
 
    @Autowired
    private ResponseDataFactory responseDataFactory;
    @Autowired(required = false)
    private FastJsonHttpMessageConverter fastJsonHttpMessageConverter;
    @Autowired(required = false)
    private List<LoadBalancedInterceptor> interceptors;
    @Autowired
    private LoadBalancedClientHttpRequestFactory clientHttpRequestFactory;
 
    /**
     * get调用，返回一个ResponseData
     * @param url 路径
     * @return 返回一个ResponseData对象
     */
    public <T extends ResponseData> T get(String url){
        return get(url, new Object[0]);
    }
 
    /**
     * get调用，返回一个ResponseData
     * @param url 路径
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <T extends ResponseData> T get(String url, Object... uriVariables){
        return (T)getDataForObject(url, responseDataFactory.getType(), uriVariables);
    }
 
    /**
     * get调用，返回一个ResponseData
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<E>> T get(String url, Class<E> dataType){
        return get(url, dataType, new Object[0]);
    }
 
    /**
     * get调用，返回一个ResponseData<List<E>>
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<List<E>>> T getList(String url, Class<E> dataType){
        return getList(url, dataType, new Object[0]);
    }
 
    /**
     * get调用，返回一个ResponseData
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<E>> T get(String url, Class<E> dataType, Object... uriVariables){
        String body = this.getDataForObject(url, String.class, uriVariables);
        T data = parseData(body, dataType);
        return data;
    }
 
    /**
     * get调用，返回一个ResponseData<List<E>>
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<List<E>>> T getList(String url, Class<E> dataType, Object... uriVariables){
        String body = this.getDataForObject(url, String.class, uriVariables);
        T data = parseList(body, dataType);
        return data;
    }
 
    private <T> T getDataForObject(String url, Class<T> dataType, Object... uriVariables){
        if(uriVariables == null || uriVariables.length == 0){
            return this.getForObject(url,dataType);
        }
        return this.getForObject(url, dataType, uriVariables);
    }
 
    /**
     * get调用，返回一个完整的ResponseEntity
     * @param url 路径
     * @return 返回一个ResponseEntity对象
     */
    public <T extends ResponseData> ResponseEntity<T> getEntity(String url){
        return getEntity(url, new Object[0]);
    }
 
    /**
     * get调用，返回一个完整的ResponseEntity
     * @param url 路径
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseEntity对象
     */
    public <T extends ResponseData> ResponseEntity<T> getEntity(String url, Object... uriVariables){
        ResponseEntity<T> entity = this.getDataForEntity(url, responseDataFactory.getType(), uriVariables);
        return entity;
    }
 
    /**
     * get调用，返回一个完整的ResponseEntity
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseEntity对象
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> getEntity(String url, Class<E> dataType){
        return getEntity(url, dataType, new Object[0]);
    }
 
    /**
     * get调用，返回一个完整的ResponseData<List<E>>
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseEntity对象
     */
    public <E,T extends ResponseData<List<E>>> ResponseEntity<T> getEntityList(String url, Class<E> dataType){
        return getEntityList(url, dataType, new Object[0]);
    }
 
    /**
     * get调用，返回一个完整的ResponseEntity
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseEntity对象
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> getEntity(String url, Class<E> dataType, Object... uriVariables){
        ResponseEntity<String> entity = this.getDataForEntity(url, String.class, uriVariables);
        ResponseEntity responseEntity = parseEntity(entity, dataType);
        return responseEntity;
    }
 
    /**
     * get调用，返回一个完整的ResponseEntity
     * @param url 路径
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseEntity对象
     */
    public <E,T extends ResponseData<List<E>>> ResponseEntity<T> getEntityList(String url, Class<E> dataType, Object... uriVariables){
        ResponseEntity<String> entity = this.getDataForEntity(url, String.class, uriVariables);
        ResponseEntity responseEntity = parseEntityList(entity, dataType);
        return responseEntity;
    }
 
    private <T> ResponseEntity<T> getDataForEntity(String url, Class<T> dataType, Object... uriVariables){
        if(uriVariables == null || uriVariables.length == 0){
            return this.getForEntity(url,dataType);
        }
        return this.getForEntity(url, dataType, uriVariables);
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @return 返回一个ResponseData对象
     */
    public <T extends ResponseData> T post(String url, Object request){
        return (T)this.post(url, request, new Object[0]);
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <T extends ResponseData> T post(String url, Object request, Object... uriVariables){
        return (T)this.postDataForObject(url, request, responseDataFactory.getType(), uriVariables);
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<E>> T post(String url, Object request, Class<E> dataType){
        return this.post(url, request, dataType, new Object[0]);
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<List<E>>> T postList(String url, Object request, Class<E> dataType){
        return this.postList(url, request, dataType, new Object[0]);
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<E>> T post(String url, Object request, Class<E> dataType, Object... uriVariables){
        String body = this.postDataForObject(url, request, String.class, uriVariables);
        T data = parseData(body, dataType);
        return data;
    }
 
    /**
     * post调用，返回一个ResponseData对象
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个ResponseData对象
     */
    public <E,T extends ResponseData<List<E>>> T postList(String url, Object request, Class<E> dataType, Object... uriVariables){
        String body = this.postDataForObject(url, request, String.class, uriVariables);
        T data = parseList(body, dataType);
        return data;
    }
 
    private <T> T postDataForObject(String url, Object request ,Class<T> dataType, Object... uriVariables){
        Object realRequest = parseRequest(request);
        if(uriVariables == null || uriVariables.length == 0){
            return this.postForObject(url, realRequest, dataType);
        }
        return this.postForObject(url, realRequest, dataType, uriVariables);
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @return 返回一个完整的ResponseEntity
     */
    public <T extends ResponseData> ResponseEntity<T> postEntity(String url, Object request){
        ResponseEntity<T> entity = this.postEntity(url, request, new Object[0]);
        return entity;
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param uriVariables url中参数变量值
     * @return 返回一个完整的ResponseEntity
     */
    public <T extends ResponseData> ResponseEntity<T> postEntity(String url, Object request, Object... uriVariables){
        ResponseEntity<T> entity = this.postDataForEntity(url, request, responseDataFactory.getType(), uriVariables);
        return entity;
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @return 返回一个完整的ResponseEntity
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> postEntity(String url, Object request, Class<E> dataType){
        return this.postEntity(url, request, dataType, new Object[0]);
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @return 返回一个完整的ResponseEntity
     */
    public <E,T extends ResponseData<List<E>>> ResponseEntity<T> postEntityList(String url, Object request, Class<E> dataType){
        return this.postEntityList(url, request, dataType, new Object[0]);
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个完整的ResponseEntity
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> postEntity(String url, Object request, Class<E> dataType, Object... uriVariables){
        ResponseEntity<String> entity = this.postDataForEntity(url, request, String.class, uriVariables);
        ResponseEntity<T> responseEntity = parseEntity(entity, dataType);
        return responseEntity;
    }
 
    /**
     * post调用，直接放回ResponseEntity<ResponseData<E>>的对象。
     * @param url 路径
     * @param request 如果是Map对象，作为表单方式提交；<br/>
     *                如果为HttpEntity,按照HttpEntity的规则执行；<br/>
     *                其他则会使用json格式通过requestBody提交
     * @param dataType ResponseData中data的类型
     * @param uriVariables url中参数变量值
     * @return 返回一个完整的ResponseEntity
     */
    public <E,T extends ResponseData<List<E>>> ResponseEntity<T> postEntityList(String url, Object request, Class<E> dataType, Object... uriVariables){
        ResponseEntity<String> entity = this.postDataForEntity(url, request, String.class, uriVariables);
        ResponseEntity responseEntity = parseEntityList(entity, dataType);
        return responseEntity;
    }
 
    private <T> ResponseEntity<T> postDataForEntity(String url, Object request ,Class<T> dataType, Object... uriVariables){
        Object realRequest = parseRequest(request);
        if(uriVariables == null || uriVariables.length == 0){
            return this.postForEntity(url, realRequest, dataType);
        }
        return this.postForEntity(url, realRequest, dataType, uriVariables);
    }
 
    private Object parseRequest(Object request){
        Object realRequest = request;
        if(request == null){
            return new HttpEntity(new LinkedMultiValueMap(), new HttpHeaders());
        }
        if(!(request instanceof HttpEntity)){
            HttpHeaders requestHeaders = new HttpHeaders();
            if(!(request instanceof Map)){
                requestHeaders.setContentType(MediaType.APPLICATION_JSON_UTF8);
            }
            HttpEntity requestEntity = new HttpEntity(request, requestHeaders);
            realRequest = requestEntity;
        }
        return realRequest;
    }
 
    /**
     * ResponseEntity<String>中body为jaon字符串，里面的body执行 this.parseData(String body,Class<E> dataType)。
     * 转化成ResponseEntity<ResponseData<E>>的对象
     * @param source
     * @param dataType ResponseData中data的类型
     * @return
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> parseEntity(ResponseEntity<String> source, Class<E> dataType){
        String body = source.getBody();
        ResponseData responseData = parseData(body, dataType);
        ResponseEntity responseEntity = new ResponseEntity(responseData, source.getHeaders(), source.getStatusCode());
        return responseEntity;
    }
 
    /**
     * ResponseEntity<String>中body为jaon字符串，里面的body执行 this.parseData(String body,Class<E> dataType)。
     * 转化成ResponseEntity<ResponseData<E>>的对象
     * @param source
     * @param dataType ResponseData中data的类型
     * @return
     */
    public <E,T extends ResponseData<E>> ResponseEntity<T> parseEntityList(ResponseEntity<String> source, Class<E> dataType){
        String body = source.getBody();
        ResponseData responseData = parseList(body, dataType);
        ResponseEntity responseEntity = new ResponseEntity(responseData, source.getHeaders(), source.getStatusCode());
        return responseEntity;
    }
 
    /**
     * json字符串序列化为ResponseData对象
     * @param body
     * @param dataType ResponseData中data的类型
     * @param <T>
     * @return
     */
    public <T extends ResponseData> T parseData(String body,Class dataType){
        ResponseData responseData = (ResponseData)JSON.parseObject(body, responseDataFactory.getType());
        JSONObject jsonData  = (JSONObject)responseData.getData();
        Optional.ofNullable(jsonData).ifPresent(j -> {
            Object data = JSON.parseObject(jsonData.toJSONString(),dataType);
            responseData.setData(data);
        });
        return (T)responseData;
    }
 
    /**
     * json字符串序列化为ResponseData<List>对象
     * @param body
     * @param dataType ResponseData中data的类型
     * @param <T>
     * @return
     */
    public <T extends ResponseData> T parseList(String body,Class dataType){
        ResponseData responseData = (ResponseData)JSON.parseObject(body, responseDataFactory.getType());
        JSONArray jsonData  = (JSONArray)responseData.getData();
        Optional.ofNullable(jsonData).ifPresent(j -> {
            List data = JSON.parseArray(jsonData.toJSONString(),dataType);
            responseData.setData(data);
        });
        return (T)responseData;
    }
 
    @Override
    public void afterPropertiesSet() throws Exception {
        this.setRequestFactory(clientHttpRequestFactory);
        if(interceptors != null){
            this.getInterceptors().addAll(interceptors);
        }
        List<HttpMessageConverter<?>> converters = this.getMessageConverters();
        if(fastJsonHttpMessageConverter != null){
            int i = 0;
            for(HttpMessageConverter converter : converters){
                if(converter instanceof MappingJackson2HttpMessageConverter){
                    converters.remove(converter);
                    converters.add(i, fastJsonHttpMessageConverter);
                    break;
                }
                i ++;
            }
        }
        converters.forEach(converter -> {
            if(converter instanceof StringHttpMessageConverter){
                StringHttpMessageConverter sc = (StringHttpMessageConverter)converter;
                WebConfiguration.setStringHttpMessageConverter(sc);
            }
        });
    }
}
```

