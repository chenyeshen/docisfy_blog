# HttpUtil
&emsp;Java 网络请求工具类，支持异步请求，支持传递 header ，支持表单和 json 类型的参数提交。

> 包含两个工具类，一个`HttpUtil`一个`HttpBaseUtil`，一个依赖Spring，一个不依赖任何框架。

## HttpUtil
&emsp;&emsp;依赖于`Spring`框架，如果你的项目基于`Spring`或者`SpringBoot`，推荐使用此工具类。

**使用示例：**
```java
public class Test{
    public void test(){
        // get请求
        String res = HttpUtil.get("https://baidu.com", null);
        System.out.println(res);
        
        // 带参数
        MultiValueMap<String, String> params = new LinkedMultiValueMap<>();
        params.add("name", "hahaha");
        String res = HttpUtil.get("https://baidu.com", params);
        System.out.println(res);
        
        // json参数提交
        User params = new User();
        String res = HttpUtil.request("https://baidu.com", params, null, HttpMethod.POST, MediaType.APPLICATION_JSON);
        System.out.println(res);
        
        // 更多使用方法看源码中的注释
    }
}
```

查看全部使用方法

```
package com.wf.wxsign.common.utils;

import org.springframework.http.*;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.RestTemplate;

/**
 * http请求工具类
 *
 * @see HttpMethod 请求方式
 * @see MediaType 参数类型，表单（MediaType.APPLICATION_FORM_URLENCODED）、json（MediaType.APPLICATION_JSON）
 * Created by wangfan on 2018-12-14 上午 8:38.
 */
public class HttpUtil {
    /**
     * get请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String get(String url, MultiValueMap<String, String> params) {
        return get(url, params, null);
    }

    /**
     * get请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String get(String url, MultiValueMap<String, String> params, MultiValueMap<String, String> headers) {
        return request(url, params, headers, HttpMethod.GET);
    }

    /**
     * post请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String post(String url, MultiValueMap<String, String> params) {
        return post(url, params, null);
    }

    /**
     * post请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String post(String url, MultiValueMap<String, String> params, MultiValueMap<String, String> headers) {
        return request(url, params, headers, HttpMethod.POST);
    }

    /**
     * put请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String put(String url, MultiValueMap<String, String> params) {
        return put(url, params, null);
    }

    /**
     * put请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String put(String url, MultiValueMap<String, String> params, MultiValueMap<String, String> headers) {
        return request(url, params, headers, HttpMethod.PUT);
    }

    /**
     * delete请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String delete(String url, MultiValueMap<String, String> params) {
        return delete(url, params, null);
    }

    /**
     * delete请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String delete(String url, MultiValueMap<String, String> params, MultiValueMap<String, String> headers) {
        return request(url, params, headers, HttpMethod.DELETE);
    }

    /**
     * 表单请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @param method  请求方式
     * @return
     */
    public static String request(String url, MultiValueMap<String, String> params, MultiValueMap<String, String> headers, HttpMethod method) {
        if (params == null) {
            params = new LinkedMultiValueMap<>();
        }
        return request(url, params, headers, method, MediaType.APPLICATION_FORM_URLENCODED);
    }

    /**
     * http请求
     *
     * @param url
     * @param params    请求参数
     * @param headers   请求头
     * @param method    请求方式
     * @param mediaType 参数类型
     * @return
     */
    public static String request(String url, Object params, MultiValueMap<String, String> headers, HttpMethod method, MediaType mediaType) {
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        RestTemplate client = new RestTemplate();
        // header
        HttpHeaders httpHeaders = new HttpHeaders();
        if (headers != null) {
            httpHeaders.addAll(headers);
        }
        // 提交方式：表单、json
        httpHeaders.setContentType(mediaType);
        HttpEntity<Object> httpEntity = new HttpEntity(params, httpHeaders);
        ResponseEntity<String> response = client.exchange(url, method, httpEntity, String.class);
        return response.getBody();
    }
}

```



## HttpBaseUtil
&emsp;&emsp;不依赖于任何框架，使用`HttpURLConnection`实现，支持异步请求方式。

**使用示例：**
```java
public class Test{
    public void test(){
        // get请求
        String res = HttpBaseUtil.get("https://baidu.com", null);
        System.out.println(res);
        
        // 带参数
        Map<String, String> params = new HashMap<>();
        params.add("name", "hahaha");
        String res = HttpUtil.get("https://baidu.com", params);
        System.out.println(res);
        
        // 异步请求
        System.out.println("开始请求...." + System.currentTimeMillis());
        HttpBaseUtil.getAsyn("https://baidu.com", null, new OnHttpResult() {
            @Override
            public void onSuccess(String result) {
                System.out.println("请求结束...." + System.currentTimeMillis());
                System.out.println(result);
            }

            @Override
            public void onError(String message) {
                System.out.println(message);
            }
        });
        System.out.println("---我来证明请求是异步的---");
        
        // json参数提交
        User user = new User();
        String params = JSON.toJSONString(user);
        String res = HttpBaseUtil.request("https://baidu.com", params, null, "POST", "application/json");
        System.out.println(res);
        
        // 更多使用方法看源码中的注释
    }
}
```

查看全部使用方法

```
package com.wf.wxsign.common.utils;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;

/**
 * http请求工具类
 * Created by wangfan on 2018-12-14 上午 8:38.
 */
public class HttpBaseUtil {

    /**
     * get请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String get(String url, Map<String, String> params) {
        return get(url, params, null);
    }

    /**
     * get请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String get(String url, Map<String, String> params, Map<String, String> headers) {
        return request(mapToString(url, params, "?"), null, headers, "GET");
    }

    /**
     * 异步get请求
     *
     * @param url
     * @param params       请求参数
     * @param onHttpResult 请求回调
     * @return
     */
    public static void getAsyn(String url, Map<String, String> params, OnHttpResult onHttpResult) {
        getAsyn(url, params, null, onHttpResult);
    }

    /**
     * 异步get请求
     *
     * @param url
     * @param params       请求参数
     * @param headers      请求头
     * @param onHttpResult 请求回调
     * @return
     */
    public static void getAsyn(String url, Map<String, String> params, Map<String, String> headers, OnHttpResult onHttpResult) {
        requestAsyn(mapToString(url, params, "?"), null, headers, "GET", onHttpResult);
    }

    /**
     * post请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String post(String url, Map<String, String> params) {
        return post(url, params, null);
    }

    /**
     * post请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String post(String url, Map<String, String> params, Map<String, String> headers) {
        return request(url, mapToString(null, params, null), headers, "POST");
    }

    /**
     * 异步post请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static void postAsyn(String url, Map<String, String> params, OnHttpResult onHttpResult) {
        postAsyn(url, params, null, onHttpResult);
    }

    /**
     * 异步post请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static void postAsyn(String url, Map<String, String> params, Map<String, String> headers, OnHttpResult onHttpResult) {
        requestAsyn(url, mapToString(null, params, null), headers, "POST", onHttpResult);
    }

    /**
     * put请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String put(String url, Map<String, String> params) {
        return put(url, params, null);
    }

    /**
     * put请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String put(String url, Map<String, String> params, Map<String, String> headers) {
        return request(url, mapToString(null, params, null), headers, "PUT");
    }

    /**
     * 异步put请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static void putAsyn(String url, Map<String, String> params, OnHttpResult onHttpResult) {
        putAsyn(url, params, null, onHttpResult);
    }

    /**
     * 异步put请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static void putAsyn(String url, Map<String, String> params, Map<String, String> headers, OnHttpResult onHttpResult) {
        requestAsyn(url, mapToString(null, params, null), headers, "PUT", onHttpResult);
    }

    /**
     * delete请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static String delete(String url, Map<String, String> params) {
        return delete(url, params, null);
    }

    /**
     * delete请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static String delete(String url, Map<String, String> params, Map<String, String> headers) {
        return request(mapToString(url, params, "?"), null, headers, "DELETE");
    }

    /**
     * 异步delete请求
     *
     * @param url
     * @param params 请求参数
     * @return
     */
    public static void deleteAsyn(String url, Map<String, String> params, OnHttpResult onHttpResult) {
        deleteAsyn(url, params, null, onHttpResult);
    }

    /**
     * 异步delete请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @return
     */
    public static void deleteAsyn(String url, Map<String, String> params, Map<String, String> headers, OnHttpResult onHttpResult) {
        requestAsyn(mapToString(url, params, "?"), null, headers, "DELETE", onHttpResult);
    }

    /**
     * 表单请求
     *
     * @param url
     * @param params  请求参数
     * @param headers 请求头
     * @param method  请求方式
     * @return
     */
    public static String request(String url, String params, Map<String, String> headers, String method) {
        return request(url, params, headers, method, "application/x-www-form-urlencoded");
    }

    /**
     * http请求
     *
     * @param url
     * @param params    请求参数
     * @param headers   请求头
     * @param method    请求方式
     * @param mediaType 参数类型,application/json,application/x-www-form-urlencoded
     * @return
     */
    public static String request(String url, String params, Map<String, String> headers, String method, String mediaType) {
        String result = null;
        if (url == null || url.trim().isEmpty()) {
            return null;
        }
        method = method.toUpperCase();
        OutputStreamWriter writer = null;
        InputStream in = null;
        ByteArrayOutputStream resOut = null;
        try {
            URL httpUrl = new URL(url);
            HttpURLConnection conn = (HttpURLConnection) httpUrl.openConnection();
            if (method.equals("POST") || method.equals("PUT")) {
                conn.setDoOutput(true);
                conn.setUseCaches(false);
            }
            conn.setReadTimeout(8000);
            conn.setConnectTimeout(5000);
            conn.setRequestMethod(method);
            conn.setRequestProperty("Accept-Charset", "utf-8");
            conn.setRequestProperty("Content-Type", mediaType);
            // 添加请求头
            if (headers != null) {
                Iterator<String> iterator = headers.keySet().iterator();
                while (iterator.hasNext()) {
                    String key = iterator.next();
                    conn.setRequestProperty(key, headers.get(key));
                }
            }
            // 添加参数
            if (params != null) {
                conn.setRequestProperty("Content-Length", String.valueOf(params.length()));
                writer = new OutputStreamWriter(conn.getOutputStream());
                writer.write(params);
                writer.flush();
            }
            // 判断连接状态
            if (conn.getResponseCode() >= 300) {
                throw new RuntimeException("HTTP Request is not success, Response code is " + conn.getResponseCode());
            }
            // 获取返回数据
            in = conn.getInputStream();
            resOut = new ByteArrayOutputStream();
            byte[] bytes = new byte[1024];
            int len;
            while ((len = in.read(bytes)) != -1) {
                resOut.write(bytes, 0, len);
            }
            result = resOut.toString();
            // 断开连接
            conn.disconnect();
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (resOut != null) {
                try {
                    resOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (in != null) {
                try {
                    in.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (writer != null) {
                try {
                    writer.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return result;
    }

    /**
     * 异步表单请求
     *
     * @param url
     * @param params       请求参数
     * @param headers      请求头
     * @param method       请求方式
     * @param onHttpResult 请求回调
     * @return
     */
    public static void requestAsyn(String url, String params, Map<String, String> headers, String method, OnHttpResult onHttpResult) {
        requestAsyn(url, params, headers, method, "application/x-www-form-urlencoded", onHttpResult);
    }

    /**
     * 异步http请求
     *
     * @param url
     * @param params       请求参数
     * @param headers      请求头
     * @param method       请求方式
     * @param mediaType    参数类型,application/json,application/x-www-form-urlencoded
     * @param onHttpResult 请求回调
     */
    public static void requestAsyn(String url, String params, Map<String, String> headers, String method, String mediaType, OnHttpResult onHttpResult) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String result = request(url, params, headers, method, mediaType);
                    onHttpResult.onSuccess(result);
                } catch (Exception e) {
                    onHttpResult.onError(e.getMessage());
                }
            }
        }).start();
    }

    /**
     * map转成string
     */
    private static String mapToString(String url, Map<String, String> params, String first) {
        StringBuilder sb;
        if (url != null) {
            sb = new StringBuilder(url);
        } else {
            sb = new StringBuilder();
        }
        if (params != null) {
            boolean isFirst = true;
            Iterator<String> iterator = params.keySet().iterator();
            while (iterator.hasNext()) {
                String key = iterator.next();
                if (isFirst) {
                    if (first != null) {
                        sb.append(first);
                    }
                    isFirst = false;
                } else {
                    sb.append("&");
                }
                sb.append(key);
                sb.append("=");
                sb.append(params.get(key));
            }
        }
        return sb.toString();
    }

    /**
     * 异步请求回调
     */
    public interface OnHttpResult {
        void onSuccess(String result);

        void onError(String message);
    }
}

```

