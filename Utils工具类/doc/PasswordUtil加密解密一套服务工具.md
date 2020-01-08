# PasswordUtil加密解密一套服务工具

### pom.xml

```
<dependency>
            <groupId>commons-codec</groupId>
            <artifactId>commons-codec</artifactId>
            <version>1.11</version>
        </dependency>
```



### AesUtil

```
package com.example.common.utils;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.codec.binary.Hex;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

public class AesUtil {
    private static final String KEY_ALGORITHM = "AES";
    private static final String DEFAULT_CIPHER_ALGORITHM = "AES/ECB/PKCS5Padding";

    /**
     * AES加密
     *
     * @param passwd
     *         加密的密钥
     * @param content
     *         需要加密的字符串
     * @return 返回Base64转码后的加密数据
     * @throws Exception
     */
    public static String encrypt(String passwd, String content) throws Exception {
        // 创建密码器
        Cipher cipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM);

        byte[] byteContent = content.getBytes("utf-8");

        // 初始化为加密模式的密码器
        cipher.init(Cipher.ENCRYPT_MODE, getSecretKey(passwd));

        // 加密
        byte[] result = cipher.doFinal(byteContent);

        //通过Base64转码返回
        return Hex.encodeHexString(result);
    }

    /**
     * AES解密
     *
     * @param passwd
     *         加密的密钥
     * @param encrypted
     *         已加密的密文
     * @return 返回解密后的数据
     * @throws Exception
     */
    public static String decrypt(String passwd, String encrypted) throws Exception {
        //实例化
        Cipher cipher = Cipher.getInstance(DEFAULT_CIPHER_ALGORITHM);

        //使用密钥初始化，设置为解密模式
        cipher.init(Cipher.DECRYPT_MODE, getSecretKey(passwd));

        //执行操作

        byte[] result = cipher.doFinal(Hex.decodeHex(encrypted));

        return new String(result, "utf-8");
    }

    /**
     * 生成加密秘钥
     *
     * @return
     */
    private static SecretKeySpec getSecretKey(final String password) throws NoSuchAlgorithmException {
        //返回生成指定算法密钥生成器的 KeyGenerator 对象
        KeyGenerator kg = KeyGenerator.getInstance(KEY_ALGORITHM);
        // javax.crypto.BadPaddingException: Given final block not properly padded解决方案
        // https://www.cnblogs.com/zempty/p/4318902.html - 用此法解决的
        // https://www.cnblogs.com/digdeep/p/5580244.html - 留作参考吧
        SecureRandom random = SecureRandom.getInstance("SHA1PRNG");
        random.setSeed(password.getBytes());
        //AES 要求密钥长度为 128
        kg.init(128, random);

        //生成一个密钥
        SecretKey secretKey = kg.generateKey();
        // 转换为AES专用密钥
        return new SecretKeySpec(secretKey.getEncoded(), KEY_ALGORITHM);
    }

}

```

### Md5Util

```
package com.example.common.utils;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.MessageDigest;

/**
 * MD5加密工具类
 */
@Slf4j
public class Md5Util {
    /**
     * 通过盐值对字符串进行MD5加密
     *
     * @param param
     *         需要加密的字符串
     * @param salt
     *         盐值
     * @return
     */
    public static String MD5(String param, String salt) {
        return MD5(param + salt);
    }

    /**
     * 加密字符串
     *
     * @param s
     *         字符串
     * @return
     */
    public static String MD5(String s) {
        char[] hexDigits = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
        try {
            byte[] btInput = s.getBytes();
            MessageDigest mdInst = MessageDigest.getInstance("MD5");
            mdInst.update(btInput);
            byte[] md = mdInst.digest();
            int j = md.length;
            char[] str = new char[j * 2];
            int k = 0;
            for (byte byte0 : md) {
                str[k++] = hexDigits[byte0 >>> 4 & 0xf];
                str[k++] = hexDigits[byte0 & 0xf];
            }
            return new String(str);
        } catch (Exception e) {
            log.error("MD5生成失败", e);
            return null;
        }
    }
}

```

### PasswordUtil

```
package com.example.common.utils;


public class PasswordUtil {


    public static final String SECURITY_KEY = "929123f8f17944e8b0a531045453e1f1";

    /**
     * AES 加密
     * @param password
     *         未加密的密码
     * @param salt
     *         盐值，默认使用用户名就可
     * @return
     * @throws Exception
     */

    public static String encrypt(String password, String salt) throws Exception {
        return AesUtil.encrypt(Md5Util.MD5(salt + SECURITY_KEY), password);
    }

    /**
     * AES 解密
     * @param encryptPassword
     *         加密后的密码
     * @param salt
     *         盐值，默认使用用户名就可
     * @return
     * @throws Exception
     */
    public static String decrypt(String encryptPassword, String salt) throws Exception {
        return AesUtil.decrypt(Md5Util.MD5(salt + SECURITY_KEY), encryptPassword);
    }
}

```

### LoginController

```
package com.example.logincenter.controller;


import com.example.common.utils.PasswordUtil;
import com.example.common.utils.ResultUtil;
import com.example.common.vo.ResponseVO;
import com.example.logincenter.model.User;
import com.example.logincenter.service.UserService;
import org.apache.commons.lang.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
public class LoginController {
    @Autowired
    private UserService userService;


    //登陆功能
    @PostMapping("/login")
    public ResponseVO Login(@RequestParam("username") String username, @RequestParam("password")
            String password) {

        User loginUser = userService.findByUsernameAndUserpassword(username);
        System.out.println(loginUser);
        if (loginUser == null) {
            return ResultUtil.error(406, "用户不存在");
        }

        try {
            //解开密码
            String decrypt = PasswordUtil.decrypt(loginUser.getPassword(), username);
            System.out.println("解开密码"+decrypt);
            System.out.println("loginUser解开密码"+loginUser.getPassword());
            if (password.equals(decrypt )) {
                return ResultUtil.success("登录成功", loginUser);
            }else {
                return ResultUtil.error(402, "密码不正确");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;

    }

    //注册功能
    @PostMapping("/register")
    public ResponseVO register(@RequestParam("username") String username, @RequestParam("password")
            String password, @RequestParam("password2") String password2) {
        //用户或密码为空的条件判断
        if (username.isEmpty() || password.isEmpty() || password2.isEmpty()) {

            return ResultUtil.error(405, "用户或密码不能为空");
        }
        //两次密码不一样的判断条件
        if (!password.equals(password2)) {

            return ResultUtil.error(402, "两次密码不一致");

        }
        //判断是否取到用户，如果没有就保存在数据库中
        User user = new User();
        user.setUsername(username);
        User existUser = userService.findByUsernameAndUserpassword(username);
        if (existUser == null) {
            //List<Login> register=loginService.save(username,password);
            User registersUser = new User();

            try {
                registersUser.setPassword(PasswordUtil.encrypt(password,username));
            } catch (Exception e) {
                e.printStackTrace();
            }
            registersUser.setUsername(username);
            registersUser.setUserUuid(StringUtils.substring(UUID.randomUUID().toString(), 0, 16));
            userService.save(registersUser);
            System.out.println("注册成功");

            return ResultUtil.success("注册成功", registersUser);

        }
        System.out.println("用户已存在");
        return ResultUtil.error(406, "用户已存在");


    }
}


```