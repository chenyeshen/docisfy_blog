### 微信登录

微信开放平台接入 官网：[https://open.weixin.qq.com](https://open.weixin.qq.com/)，在官网注册并添加应用后即可获得APP_ID和APP_SECRET。

### 步骤一：创建一个继承AuthService的接口，WeChatAuthService，如下

```
public interface WeChatAuthService extends AuthService {
    public JSONObject getUserInfo(String accessToken, String openId);
}
```

### 步骤二：WeChatService的具体实现如下

```
@Service
public class WeChatAuthServiceImpl extends DefaultAuthServiceImpl implements WeChatAuthService {

    private Logger logger = LoggerFactory.getLogger(WeChatAuthServiceImpl.class);

//请求此地址即跳转到二维码登录界面
    private static final String AUTHORIZATION_URL =
            "https://open.weixin.qq.com/connect/qrconnect?appid=%s&redirect_uri=%s&response_type=code&scope=%s&state=%s#wechat_redirect";

    // 获取用户 openid 和access——toke 的 URL
    private static final String ACCESSTOKE_OPENID_URL =
            "https://api.weixin.qq.com/sns/oauth2/access_token?appid=%s&secret=%s&code=%s&grant_type=authorization_code";

    private static final String REFRESH_TOKEN_URL =
            "https://api.weixin.qq.com/sns/oauth2/refresh_token?appid=%s&grant_type=refresh_token&refresh_token=%s";

    private static final String USER_INFO_URL =
            "https://api.weixin.qq.com/sns/userinfo?access_token=%s&openid=%s&lang=zh_CN";

    private static final String APP_ID="xxxxxx";
    private static final String APP_SECRET="xxxxxx";
    private static final String SCOPE = "snsapi_login";

    private String callbackUrl = "https://www.xxx.cn/auth/wechat"; //回调域名

    @Override
    public String getAuthorizationUrl() throws UnsupportedEncodingException {
        callbackUrl = URLEncoder.encode(callbackUrl,"utf-8");
        String url = String.format(AUTHORIZATION_URL,APP_ID,callbackUrl,SCOPE,System.currentTimeMillis());
        return url;
    }


    @Override
    public String getAccessToken(String code) {
        String url = String.format(ACCESSTOKE_OPENID_URL,APP_ID,APP_SECRET,code);

        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(url);
        URI uri = builder.build().encode().toUri();

        String resp = getRestTemplate().getForObject(uri, String.class);
        logger.error("getAccessToken resp = "+resp);
        if(resp.contains("openid")){
            JSONObject jsonObject = JSONObject.parseObject(resp);
            String access_token = jsonObject.getString("access_token");
            String openId = jsonObject.getString("openid");;

            JSONObject res = new JSONObject();
            res.put("access_token",access_token);
            res.put("openId",openId);
            res.put("refresh_token",jsonObject.getString("refresh_token"));

            return res.toJSONString();
        }else{
            throw new ServiceException("获取token失败，msg = "+resp);
        }
    }

    //微信接口中，token和openId是一起返回，故此方法不需实现
    @Override
    public String getOpenId(String accessToken) {
        return null;
    }

    @Override
    public JSONObject getUserInfo(String accessToken, String openId){
        String url = String.format(USER_INFO_URL, accessToken, openId);
        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(url);
        URI uri = builder.build().encode().toUri();

        String resp = getRestTemplate().getForObject(uri, String.class);
        logger.error("getUserInfo resp = "+resp);
        if(resp.contains("errcode")){
            throw new ServiceException("获取用户信息错误，msg = "+resp);
        }else{
            JSONObject data =JSONObject.parseObject(resp);

            JSONObject result = new JSONObject();
            result.put("id",data.getString("unionid"));
            result.put("nickName",data.getString("nickname"));
            result.put("avatar",data.getString("headimgurl"));

            return result;
        }
    }

    //微信的token只有2小时的有效期，过时需要重新获取，所以官方提供了
    //根据refresh_token 刷新获取token的方法，本项目仅仅是获取用户
    //信息，并将信息存入库，所以两个小时也已经足够了
    @Override
    public String refreshToken(String refresh_token) {

        String url = String.format(REFRESH_TOKEN_URL,APP_ID,refresh_token);

        UriComponentsBuilder builder = UriComponentsBuilder.fromHttpUrl(url);
        URI uri = builder.build().encode().toUri();

        ResponseEntity<JSONObject> resp = getRestTemplate().getForEntity(uri,JSONObject.class);
        JSONObject jsonObject = resp.getBody();

        String access_token = jsonObject.getString("access_token");
        return access_token;
    }
}
```

### 步骤三： 

在Controller中调用，代码如下：

```
@RequestMapping(value = "/wxLoginPage",method = RequestMethod.GET)
    public JSONObject wxLoginPage() throws Exception {
        String uri = weChatAuthService.getAuthorizationUrl();
        return loginPage(uri);
    }

    @RequestMapping(value = "/wechat")
    public void callback(String code,HttpServletRequest request,HttpServletResponse response) throws Exception {
        String result = weChatAuthService.getAccessToken(code);
        JSONObject jsonObject = JSONObject.parseObject(result);

        String access_token = jsonObject.getString("access_token");
        String openId = jsonObject.getString("openId");
// String refresh_token = jsonObject.getString("refresh_token");

        // 保存 access_token 到 cookie，两小时过期
        Cookie accessTokencookie = new Cookie("accessToken", access_token);
        accessTokencookie.setMaxAge(60 *2);
        response.addCookie(accessTokencookie);

        Cookie openIdCookie = new Cookie("openId", openId);
        openIdCookie.setMaxAge(60 *2);
        response.addCookie(openIdCookie);

        //根据openId判断用户是否已经登陆过
        KmsUser user = userService.getUserByCondition(openId);

        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/student/html/index.min.html#/bind?type="+Constants.LOGIN_TYPE_WECHAT);
        } else {
            //如果用户已存在，则直接登录
            response.sendRedirect(request.getContextPath() + "/student/html/index.min.html#/app/home?open_id=" + openId);
        }
    }
```

### 步骤四： 

前台js中，先请求auth/wxLoginPage，获取授权地址，等用户授权后会回调/auth/wechat，在此方法中进行逻辑处理即可。

遇到过的坑： 
1.在微信官网中配置回调域名的时候，不需要些http或https协议，只需要写上域即可，例如[http://baidu.com](http://baidu.com/)，只需要填写baidu.com即可，如果是想要跳转到项目下面的某个Controller的某个方法中，如baidu.com/auth/wechat ，配置的时候也只需要配baidu.com，不需要指定后面的auth/wechat，后面的地址在代码中配置回调的地址的时候写上即可，代码中应该配置为<https://baidu.com/auth/wechat> 
2.在跳转到授权二维码界面的时候，会遇到有的时候二维码出不来的状况，这是因为代码中的回调地址的问题，按照上面代码中的方式配置应该是没有问题的