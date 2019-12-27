# Utils工具集合类

### AesUtil

```
package com.zyd.blog.util;

import org.apache.commons.codec.binary.Base64;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;

/**
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @website https://www.zhyd.me
 * @version 1.0
 * @date 2018/4/16 16:26
 * @since 1.0
 */
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
        return Base64.encodeBase64String(result);
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
        byte[] result = cipher.doFinal(Base64.decodeBase64(encrypted));

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

### AspectUtil

```
package com.zyd.blog.util;

import com.alibaba.fastjson.JSON;
import com.zyd.blog.framework.exception.ZhydException;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.Signature;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.util.StringUtils;

import java.lang.reflect.Method;
import java.util.List;

/**
 * AOP相关的工具
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/6/29 11:59
 * @since 1.0
 */
public enum AspectUtil {

    INSTANCE;

    /**
     * 获取切面缓存的key
     *
     * @param point  当前切面执行的方法
     * @param extra  额外的参数 （非必选）
     * @param prefix key前缀 （非必选）
     * @throws NoSuchMethodException
     */
    public String getKey(JoinPoint point, String extra, String prefix) throws NoSuchMethodException {
        Method currentMethod = this.getMethod(point);
        if (null == currentMethod) {
            throw new ZhydException("Invalid operation! Method not found.");
        }
        String methodName = currentMethod.getName();
        return getKey(point, prefix) +
                "_" +
                methodName +
                CacheKeyUtil.getMethodParamsKey(point.getArgs()) +
                (null == extra ? "" : extra);
    }

    /**
     * 获取以类路径为前缀的键
     *
     * @param point 当前切面执行的方法
     */
    public String getKey(JoinPoint point, String prefix) {
        String keyPrefix = "";
        if (!StringUtils.isEmpty(prefix)) {
            keyPrefix += prefix;
        }
        keyPrefix += getClassName(point);
        return keyPrefix;
    }

    /**
     * 获取当前切面执行的方法所在的class
     *
     * @param point 当前切面执行的方法
     */
    public String getClassName(JoinPoint point) {
        return point.getTarget().getClass().getName().replaceAll("\\.", "_");
    }

    /**
     * 获取当前切面执行的方法的方法名
     *
     * @param point 当前切面执行的方法
     */
    public Method getMethod(JoinPoint point) throws NoSuchMethodException {
        Signature sig = point.getSignature();
        MethodSignature msig = (MethodSignature) sig;
        Object target = point.getTarget();
        return target.getClass().getMethod(msig.getName(), msig.getParameterTypes());
    }

    public String parseParams(Object[] params, String bussinessName) {
        if (bussinessName.contains("{") && bussinessName.contains("}")) {
            List<String> result = RegexUtils.match(bussinessName, "(?<=\\{)(\\d+)");
            for (String s : result) {
                int index = Integer.parseInt(s);
                bussinessName = bussinessName.replaceAll("\\{" + index + "}", JSON.toJSONString(params[index - 1]));
            }
        }
        return bussinessName;
    }
}

```

### BeanHelper

```
package com.fmq.common.util;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.springframework.beans.BeanUtils;

/**
 * 
 * @author ljg
 *
 */
public class BeanHelper {
	
	private static Log logger = LogFactory.getLog(BeanHelper.class);
	
	public static void copyProperties(Object source,Object target ,String[] ignoreProperties) {
		try {
			BeanUtils.copyProperties(source, target, ignoreProperties);
			
		} catch (Exception e) {
			logger.info(e.getMessage());
		}
	}
	
	public static void copyProperties(Object source,Object target) {
		try {
			BeanUtils.copyProperties(source, target);
			
		} catch (Exception e) {
			logger.info(e.getMessage());
		}
	}

}

```



### BeanConvertUtil

```
package com.zyd.blog.util;

import com.zyd.blog.framework.exception.ZhydException;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.BeansException;
import org.springframework.beans.FatalBeanException;
import org.springframework.lang.Nullable;
import org.springframework.util.Assert;
import org.springframework.util.ClassUtils;
import org.springframework.util.CollectionUtils;

import java.beans.PropertyDescriptor;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

/**
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
 */
public class BeanConvertUtil {

    /**
     * sourceList --> targetList 转换
     *
     * @param sourceArray
     * @param target
     * @param <T>
     * @return
     */
    public static <T> List<T> doConvert(List<?> sourceArray, Class<T> target) {
        if (CollectionUtils.isEmpty(sourceArray) || null == target) {
            return null;
        }
        return sourceArray.stream().map((bo) -> doConvert(bo, target)).collect(Collectors.toList());
    }

    /**
     * source --> target 的转换
     *
     * @param source 被转换的对象
     * @param target 转换成的对象
     * @param <T>
     * @return
     */
    public static <T> T doConvert(Object source, Class<T> target) {
        if (null == source || null == target) {
            return null;
        }
        try {
            T t = target.newInstance();
            BeanUtils.copyProperties(source, t);
            return t;
        } catch (InstantiationException e) {
            throw new ZhydException(target + " - 可能为一个抽象类、接口、数组类、基本类型或者该类缺少无参构造方法！", e);
        } catch (IllegalAccessException e) {
            throw new ZhydException(target + " - 该类或其构造方法是不可访问的，或该类缺少无参构造方法！", e);
        } catch (FatalBeanException e) {
            throw new ZhydException(target + " - 序列化失败！", e);
        }
    }

    /**
     * source --> target 的转换，只复制不为空null的属性
     *
     * @param source 被转换的对象
     * @param target 转换成的对象
     * @param <T>
     * @return
     */
    public static <T> T doConvert(Object source, Object target, Class<T> clazz) {
        if (null == source || null == target) {
            return null;
        }
        CustomBeanUtils.copyProperties(source, target);
        if (clazz.equals(target.getClass())) {
            return (T) target;
        }
        throw new ClassCastException(target.getClass() + " cannot be cast to " + clazz);
    }

    /**
     * 只复制不为空的属性
     */
    private static class CustomBeanUtils extends BeanUtils {
        public static void copyProperties(Object source, Object target) throws BeansException {
            copyProperties(source, target, null, (String[]) null);
        }

        private static void copyProperties(Object source, Object target, @Nullable Class<?> editable, @Nullable String... ignoreProperties) throws BeansException {
            Assert.notNull(source, "Source must not be null");
            Assert.notNull(target, "Target must not be null");
            Class<?> actualEditable = target.getClass();
            if (editable != null) {
                if (!editable.isInstance(target)) {
                    throw new IllegalArgumentException("Target class [" + target.getClass().getName() + "] not assignable to Editable class [" + editable.getName() + "]");
                }

                actualEditable = editable;
            }

            PropertyDescriptor[] targetPds = getPropertyDescriptors(actualEditable);
            List<String> ignoreList = ignoreProperties != null ? Arrays.asList(ignoreProperties) : null;
            PropertyDescriptor[] var7 = targetPds;
            int var8 = targetPds.length;

            for (int var9 = 0; var9 < var8; ++var9) {
                PropertyDescriptor targetPd = var7[var9];
                Method writeMethod = targetPd.getWriteMethod();
                if (writeMethod != null && (ignoreList == null || !ignoreList.contains(targetPd.getName()))) {
                    PropertyDescriptor sourcePd = getPropertyDescriptor(source.getClass(), targetPd.getName());
                    if (sourcePd != null) {
                        Method readMethod = sourcePd.getReadMethod();
                        if (readMethod != null && ClassUtils.isAssignable(writeMethod.getParameterTypes()[0], readMethod.getReturnType())) {
                            try {
                                if (!Modifier.isPublic(readMethod.getDeclaringClass().getModifiers())) {
                                    readMethod.setAccessible(true);
                                }

                                Object value = readMethod.invoke(source);
                                // 只copy不为null的值
                                if (null != value) {
                                    if (!Modifier.isPublic(writeMethod.getDeclaringClass().getModifiers())) {
                                        writeMethod.setAccessible(true);
                                    }

                                    writeMethod.invoke(target, value);
                                }
                            } catch (Throwable var15) {
                                throw new FatalBeanException("Could not copy property '" + targetPd.getName() + "' from source to target", var15);
                            }
                        }
                    }
                }
            }

        }
    }

}

```

### CacheKeyUtil

```
package com.zyd.blog.util;

import com.alibaba.fastjson.JSON;
import org.springframework.util.StringUtils;
import org.springframework.validation.support.BindingAwareModelMap;

/**
 * 缓存key相关的工具类
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/5/25 10:23
 * @since 1.0
 */
public class CacheKeyUtil {

    /**
     * 获取方法参数组成的key
     *
     * @param params
     *         参数数组
     */
    public static String getMethodParamsKey(Object... params) {
        if (null == params || params.length == 0) {
            return "";
        }
        StringBuilder key = new StringBuilder("(");
        for (Object obj : params) {
            if (obj.getClass().equals(BindingAwareModelMap.class)) {
                continue;
            }
            key.append(JSON.toJSONString(obj).replaceAll("\"", "'"));
        }
        key.append(")");
        return key.toString();
    }

}

```

### CookieUtils

```
package com.fmq.common.util;

import java.util.HashMap;
import java.util.Map;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * cookie
 * 
 * @author ljg
 *
 */
public class CookieUtils {

	/**
	 * 设置cookie
	 * 
	 * @param response
	 * @param name
	 *            cookie名字
	 * @param value
	 *            cookie值
	 * @param maxAge
	 *            cookie生命周期 以秒为单位
	 */
	public static void addCookie(HttpServletResponse response, String name, String value, int maxAge) {
		Cookie cookie = new Cookie(name, value);
		cookie.setPath("/");
		if (maxAge > 0) {
			cookie.setMaxAge(maxAge);
		}
		cookie.setSecure(true);
		response.addCookie(cookie);
	}

	/**
	 * 根据名字获取cookie
	 * 
	 * @param request
	 * @param name
	 *            cookie名字
	 * @return
	 */
	public static String getCookieByName(HttpServletRequest request, String name) {
		Map<String, Cookie> cookieMap = readCookieMap(request);
		if (cookieMap.containsKey(name)) {
			Cookie cookie = (Cookie) cookieMap.get(name);
			return cookie.getValue();
		} else {
			return null;
		}
	}

	/**
	 * 将cookie封装到Map里面
	 * 
	 * @param request
	 * @return
	 */
	private static Map<String, Cookie> readCookieMap(HttpServletRequest request) {
		Map<String, Cookie> cookieMap = new HashMap<String, Cookie>(16);
		Cookie[] cookies = request.getCookies();
		if (null != cookies) {
			for (Cookie cookie : cookies) {
				cookieMap.put(cookie.getName(), cookie);
			}
		}
		return cookieMap;
	}
}

```



### DateHelper

```
package com.fmq.common.util;

import java.text.ParsePosition;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * 时间格式转换
 * 
 * @author ljg
 *
 */
public class DateHelper {

	/******* 日期常用格式化 ***********/

	/** 长日期: yyyy-MM-dd HH:mm:ss */
	public static String DATE_FMT_LONG = "yyyy-MM-dd HH:mm:ss";

	public static String DATE_FMT_LONG_EN = "yyyyMMddHHmmss";

	/** 中文长日期: yyyy年MM月dd日 HH:mm:ss */
	public static String DATE_FMT_LONG_CN = "yyyy年MM月dd日 HH:mm:ss";

	/** 中文普通日期: yyyy年MM月dd日 HH:mm */
	public static String DATE_FMT_NORMAL_CN = "yyyy年MM月dd日 HH:mm";
	public static String DATE_FMT_NORMAL_CN_1 = "yyyy年M月d日 HH:mm";

	public static String DATE_FMT_LONG_HMSS = "yyyyMMddHHmmssSSS";

	/** 短日期: yyyy-MM-dd */
	public static String DATE_FMT_SHORT = "yyyy-MM-dd";

	public static String DATE_FMT_SHORT_8 = "yyyyMMdd";

	/** 中文短日期: yyyy年MM月dd日 */
	public static String DATE_FMT_SHORT_CN = "yyyy年MM月dd日";
	/** 中文短日期: yyyy.MM.dd */
	public static String DATE_FMT_SHORTD_CN = "yyyy.MM.dd";
	/** 中文短日期 : yyyy年MM月 */
	public static String DATE_FMT_MONTH_CN = "yyyy年MM月";

	/**
	 * Date转字符串
	 * 
	 * @param date
	 *            , 默认今天
	 * @param format
	 * @return String
	 */
	public static String date2Str(Date date, String format) {
		if (date == null) {
			date = new Date();
		}
		if (format == null || "".equals(format)) {
			format = DATE_FMT_LONG;
		}
		SimpleDateFormat formatter = new SimpleDateFormat(format);
		String dateString = formatter.format(date);
		return dateString;
	}

	/**
	 * 字符串转Date
	 * 
	 * @param strDate
	 * @param format
	 * @return Date
	 */
	public static Date str2Date(String strDate, String format) {
		if (strDate == null) {
			return null;
		} else {
			if (format == null || "".equals(format)) {
				format = DATE_FMT_LONG;
			}
			SimpleDateFormat formatter = new SimpleDateFormat(format);
			ParsePosition pos = new ParsePosition(0);
			Date strtodate = formatter.parse(strDate, pos);
			return strtodate;
		}

	}

	public static Date getLastDate(Date date, long day) {
		long dateHm = date.getTime() - 3600000 * 24 * day;
		Date dateHmDate = new Date(dateHm);
		return dateHmDate;
	}

	public static Date getDelayTime(Date lastTime, String delaySencod) {
		Date date = null;
		if (lastTime == null) {
			lastTime = new Date();
		}
		if (delaySencod == null || "".equals(delaySencod) || delaySencod.startsWith("0")) {
			delaySencod = "60";
		}
		try {
			long time = (lastTime.getTime() / 1000) + Integer.parseInt(delaySencod);
			lastTime.setTime(time * 1000);
			date = lastTime;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return date;
	}

	public static Date getDelayDay(Date lastTime) {
		return getDelayDay(lastTime, null);
	}

	public static Date getDelayDay(Date lastTime, String delay) {
		Date date = null;
		if (lastTime == null) {
			lastTime = new Date();
		}
		if (delay == null || "".equals(delay) || delay.startsWith("0")) {
			delay = "1";
		}
		try {
			long time = (lastTime.getTime() / 1000) + Integer.parseInt(delay) * 24 * 60 * 60;
			lastTime.setTime(time * 1000);
			date = lastTime;
		} catch (Exception e) {
			e.printStackTrace();
		}
		return date;
	}

	public static String getNextDay(String nowdate, String delay) {
		try {
			SimpleDateFormat format = new SimpleDateFormat(DATE_FMT_SHORT);
			String mdate = "";
			Date d = str2Date(nowdate, DATE_FMT_SHORT);
			long myTime = (d.getTime() / 1000) + Integer.parseInt(delay) * 24 * 60 * 60;
			d.setTime(myTime * 1000);
			mdate = format.format(d);
			return mdate;
		} catch (Exception e) {
			return "";
		}
	}

	public static String getDay(String nowdate, String delay, String formatStr) {
		try {
			if (formatStr == null || "".equals(formatStr)) {
				formatStr = DATE_FMT_SHORT;
			}
			SimpleDateFormat format = new SimpleDateFormat(formatStr);
			String mdate = "";
			Date d = null;
			if (nowdate == null || "".equals(nowdate)) {
				d = new Date();
			} else {
				d = str2Date(nowdate, formatStr);
			}
			long myTime = (d.getTime() / 1000) + Integer.parseInt(delay) * 24 * 60 * 60;
			d.setTime(myTime * 1000);
			mdate = format.format(d);
			return mdate;
		} catch (Exception e) {
			return "";
		}
	}

	public static Date getDate(String date, String format, int days) {

		Date strDate = str2Date(date, format);
		Calendar c = Calendar.getInstance();
		// 设置日期
		c.setTime(strDate);
		// 日期分钟加1,Calendar.DATE(天),Calendar.HOUR(小时)
		c.add(Calendar.DATE, days);
		// 结果
		return c.getTime();
	}

	public static String getWeek(String strDate, String num) {

		Date dd = str2Date(strDate, DATE_FMT_SHORT);
		Calendar c = Calendar.getInstance();
		c.setTime(dd);
		if ("1".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
		} else if ("2".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.TUESDAY);
		} else if ("3".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.WEDNESDAY);
		} else if ("4".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.THURSDAY);
		} else if ("5".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.FRIDAY);
		} else if ("6".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.SATURDAY);
		} else if ("0".equals(num)) {
			c.set(Calendar.DAY_OF_WEEK, Calendar.SUNDAY);
		}
		return new SimpleDateFormat(DATE_FMT_SHORT).format(c.getTime());
	}

	public static String getWeekDay() {
		String weekDay = null;
		Calendar c = Calendar.getInstance();
		switch (c.get(Calendar.DAY_OF_WEEK)) {
		case Calendar.SUNDAY:
			weekDay = "星期日";
			break;
		case Calendar.MONDAY:
			weekDay = "星期一";
			break;
		case Calendar.TUESDAY:
			weekDay = "星期二";
			break;
		case Calendar.WEDNESDAY:
			weekDay = "星期三";
			break;
		case Calendar.THURSDAY:
			weekDay = "星期四";
			break;
		case Calendar.FRIDAY:
			weekDay = "星期五";
			break;
		case Calendar.SATURDAY:
			weekDay = "星期六";
			break;
		  default:
		}
		return weekDay;
	}

	public static String getWeek(String sdate) {

		Date date = str2Date(sdate, DATE_FMT_SHORT);
		Calendar c = Calendar.getInstance();
		c.setTime(date);

		return new SimpleDateFormat("EEEE").format(c.getTime());
	}

	public static int compare(String format, Date date, Date todate) {
		String datestr = date2Str(date, format);
		String todatestr = date2Str(todate, format);
		date = str2Date(datestr, format);
		todate = str2Date(todatestr, format);
		return date.compareTo(todate);
	}

	public static String getNowTimes() {
		Date currentTime = new Date();
		SimpleDateFormat formatter = new SimpleDateFormat(DATE_FMT_LONG);
		String dateString = formatter.format(currentTime);
		return dateString;
	}

	public static String getNowTimes(String format) {
		if (format == null || "".equals(format)) {
			format = DATE_FMT_LONG;
		}
		Date currentTime = new Date();
		SimpleDateFormat formatter = new SimpleDateFormat(format);
		String dateString = formatter.format(currentTime);
		return dateString;
	}

	public static Date parseDate(String date) {
		SimpleDateFormat df = new SimpleDateFormat();
		Date rtnDate = null;
		if (date == null || date.trim().equals("") || date.trim().equals("null")) {
			return rtnDate;
		}
		try {
			date = date.trim();
			int length = date.length();
			if (date.indexOf("-") != -1) {
				if (length == 5) {
					if (date.indexOf("-") == length - 1) {
						// 2015-
						df.applyPattern("yyyy");
						date = date.substring(0, 4);
						rtnDate = df.parse(date);
					} else {
						df.applyPattern("yyyy-MM");
						// 2015-01
						rtnDate = df.parse(date);
					}
				} else if (length >= 6 && length <= 7) {
					// 2015-1 -- 2015-01
					df.applyPattern("yyyy-MM");
					rtnDate = df.parse(date);
				} else if (length >= 8 && length <= 9) {
					if (date.lastIndexOf("-") == length - 1) {
						// 2015-12-
						df.applyPattern("yyyy-MM");
						date = date.substring(0, length - 1);
						rtnDate = df.parse(date);
					} else {
						df.applyPattern("yyyy-MM-dd");
						// 2015-1-1 --
						// 2015-01-01
						rtnDate = df.parse(date);
					}
				} else if (length >= 10 && length <= 11) {
					if (date.indexOf(" ") > -1 && date.indexOf(" ") < length - 1) {
						// 2015-1-1 1 --
						df.applyPattern("yyyy-MM-dd HH");
						// 2015-1-1 11 中间有空格
						rtnDate = df.parse(date);
					} else {
						df.applyPattern("yyyy-MM-dd");
						// "2015-01-01"中间无空格
						rtnDate = df.parse(date);
					}
				} else if (length >= 12 && length <= 13) {
					if (date.indexOf(":") > -1 && date.indexOf(":") < length - 1) {
						df.applyPattern("yyyy-MM-dd HH:mm");
						// 2015-1-1 1:1 --
						// 2015-1-1 1:01
						// 中间有冒号
						rtnDate = df.parse(date);
					} else {
						df.applyPattern("yyyy-MM-dd HH");
						// 2015-01-01 01

						// 中间有空格
						rtnDate = df.parse(date);
					}
				} else if (length >= 14 && length <= 16) {
					int lastIndex = date.lastIndexOf(":");
					if (date.indexOf(":") > -1 && lastIndex < length - 1 && date.indexOf(":") != lastIndex) {
						df.applyPattern("yyyy-MM-dd HH:mm:ss");
						// 2015-1-1
						// 1:1:1 --
						// 2015-01-01
						// 1:1:1 中间有两个冒号
						if (lastIndex < length - 1 - 2) {
							date = date.substring(0, lastIndex + 3);
						}
						rtnDate = df.parse(date);
					} else if (date.indexOf(":") > -1 && lastIndex < length - 1 && date.indexOf(":") == lastIndex) {
						df.applyPattern("yyyy-MM-dd HH:mm");
						// 2015-01-01 1:1 --
						// 2015-01-01
						// 01:01中间只有一个冒号
						rtnDate = df.parse(date);
					} else if (date.indexOf(":") > -1 && lastIndex == length - 1 && date.indexOf(":") == lastIndex) {
						df.applyPattern("yyyy-MM-dd HH");
						// 2015-01-01 01:
						// 只有一个冒号在末尾
						date = date.substring(0, length - 1);
						rtnDate = df.parse(date);
					}
				} else if (length == 17) {
					int lastIndex = date.lastIndexOf(":");
					if (lastIndex < length - 1) {
						df.applyPattern("yyyy-MM-dd HH:mm:ss");
						// 2015-1-1
						// 1:1:1 --
						// 2015-01-01
						// 1:1:1 中间有两个冒号
						if (lastIndex < length - 1 - 2) {
							date = date.substring(0, lastIndex + 3);
						}
						rtnDate = df.parse(date);
					} else if (lastIndex == length - 1) {
						df.applyPattern("yyyy-MM-dd HH:mm");
						// 2015-01-01 1:1 --
						// 2015-01-01
						// 01:01中间只有一个冒号
						date = date.substring(0, length - 1);
						rtnDate = df.parse(date);
					}
				} else if (length >= 18) {
					df.applyPattern("yyyy-MM-dd HH:mm:ss");
					// 2015-1-1 1:1:1 --
					// 2015-01-01
					// 01:01:01 有两个冒号
					int lastIndex = date.lastIndexOf(":");
					if (lastIndex < length - 1 - 2) {
						date = date.substring(0, lastIndex + 3);
					}
					rtnDate = df.parse(date);
				}
			} else if (length == 4) {
				df.applyPattern("yyyy");
				rtnDate = df.parse(date);
			} else if (length >= 5 && length <= 6) {
				df.applyPattern("yyyyMM");
				rtnDate = df.parse(date);
			} else if (length >= 7 && length <= 8) {
				df.applyPattern("yyyyMMdd");
				rtnDate = df.parse(date);
			} else if (length >= 9 && length <= 10) {
				df.applyPattern("yyyyMMddHH");
				rtnDate = df.parse(date);
			} else if (length >= 11 && length <= 12) {
				df.applyPattern("yyyyMMddHHmm");
				rtnDate = df.parse(date);
			} else if (length >= 13 && length <= 14) {
				df.applyPattern("yyyyMMddHHmmss");
				rtnDate = df.parse(date);
			} else if (length >= 15) {
				df.applyPattern("yyyyMMddHHmmss");
				date = date.substring(0, 14);
				rtnDate = df.parse(date);
			}
		} catch (Exception ex) {
			// ex.printStackTrace();
		}
		return rtnDate;

	}

	/**
	 * date日期之前day天的日期 Description:
	 * 
	 * @param date
	 * @param day
	 * @return
	 */
	public static Date getPreDate(Date date, int day) {
		if (date == null) {
			return null;
		}
		long time = date.getTime();
		time -= 86400000L * day;
		return new Date(time);
	}

	public static Date addMinutes(Date date, int amount) {
		return add(date, 12, amount);
	}

	public static Date add(Date date, int calendarField, int amount) {
		if (date == null) {
			throw new IllegalArgumentException("The date must not be null");
		}
		Calendar c = Calendar.getInstance();
		c.setTime(date);
		c.add(calendarField, amount);
		return c.getTime();
	}

	/**
	 * 描述：日期格式化
	 * 
	 * @param date
	 *            日期
	 * @param pattern
	 *            格式化类型
	 * @return
	 */
	public static String formatDate(Date date, String pattern) {
		SimpleDateFormat dateFormat = new SimpleDateFormat(pattern);
		return dateFormat.format(date);
	}

	public static void main(String[] args) {
		System.out.println(parseDate("15-13"));
	}
}
```



### DateUtil

```
/*
 * Copyright 2015-2016 RonCoo(http://www.roncoo.com) Group.
 *  
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.roncoo.jui.common.util;

import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;

/**
 * 日期处理工具类
 * 
 * @author wujing
 */
public final class DateUtil {

	/**
	 * 此类不需要实例化
	 */
	private DateUtil() {
	}

	private static Date date = null;
	private static DateFormat dateFormat = null;
	private static Calendar calendar = null;

	/**
	 * 时间转换：长整型转换为日期字符型
	 * 
	 * @param format
	 *            格式化类型：yyyy-MM-dd
	 * @param time
	 *            13位有效数字：1380123456789
	 * 
	 * @return 格式化结果 (yyyy-MM-dd)
	 */
	public static String formatToString(String format, long time) {
		if (time == 0) {
			return "";
		}
		return new SimpleDateFormat(format).format(new Date(time));
	}

	/**
	 * 时间转换：日期字符型转换为长整型
	 * 
	 * @param format
	 *            格式化类型：yyyy-MM-dd
	 * 
	 * @return 13位有效数字 (1380123456789)
	 */
	public static long formatToLong(String format) {
		SimpleDateFormat f = new SimpleDateFormat(format);
		return Timestamp.valueOf(f.format(new Date())).getTime();
	}

	/**
	 * 获取当前年份
	 * 
	 * @return yyyy (2016)
	 */
	public static int getYear() {
		Calendar cal = Calendar.getInstance();
		return cal.get(Calendar.YEAR);
	}

	/**
	 * 获取当前月份
	 * 
	 * @return MM (06)
	 */
	public static String getMonth() {
		Calendar cal = Calendar.getInstance();
		return new DecimalFormat("00").format(cal.get(Calendar.MONTH));
	}

	/**
	 * 功能描述：格式化日期
	 * 
	 * @param dateStr
	 *            String 字符型日期
	 * @param format
	 *            String 格式
	 * @return Date 日期
	 */
	public static Date parseDate(String dateStr, String format) {
		try {
			dateFormat = new SimpleDateFormat(format);
			String dt = dateStr.replaceAll("-", "/");
			dt = dateStr;
			if ((!dt.equals("")) && (dt.length() < format.length())) {
				dt += format.substring(dt.length()).replaceAll("[YyMmDdHhSs]", "0");
			}
			date = (Date) dateFormat.parse(dt);
		} catch (Exception e) {
			e.printStackTrace();
		}
		return date;
	}

	/**
	 * 功能描述：格式化日期
	 * 
	 * @param dateStr
	 *            String 字符型日期：YYYY-MM-DD 格式
	 * @return Date
	 */
	public static Date parseDate(String dateStr) {
		return parseDate(dateStr, "MM/dd/yyyy");
	}

	/**
	 * 功能描述：格式化输出日期
	 * 
	 * @param date
	 *            Date 日期
	 * @param format
	 *            String 格式
	 * @return 返回字符型日期
	 */
	public static String format(Date date, String format) {
		String result = "";
		try {
			if (date != null) {
				dateFormat = new SimpleDateFormat(format);
				result = dateFormat.format(date);
			}
		} catch (Exception e) {
		}
		return result;
	}

	/**
	 * 功能描述：
	 * 
	 * @param date
	 *            Date 日期
	 * @return
	 */
	public static String format(Date date) {
		return format(date, "yyyy-MM-dd");
	}

	/**
	 * 功能描述：返回年份
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回年份
	 */
	public static int getYear(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.YEAR);
	}

	/**
	 * 功能描述：返回月份
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回月份
	 */
	public static int getMonth(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.MONTH) + 1;
	}

	/**
	 * 功能描述：返回日份
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回日份
	 */
	public static int getDay(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.DAY_OF_MONTH);
	}

	/**
	 * 功能描述：返回小时
	 * 
	 * @param date
	 *            日期
	 * @return 返回小时
	 */
	public static int getHour(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.HOUR_OF_DAY);
	}

	/**
	 * 功能描述：返回分钟
	 * 
	 * @param date
	 *            日期
	 * @return 返回分钟
	 */
	public static int getMinute(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.MINUTE);
	}

	/**
	 * 返回秒钟
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回秒钟
	 */
	public static int getSecond(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.get(Calendar.SECOND);
	}

	/**
	 * 功能描述：返回毫秒
	 * 
	 * @param date
	 *            日期
	 * @return 返回毫秒
	 */
	public static long getMillis(Date date) {
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		return calendar.getTimeInMillis();
	}

	/**
	 * 功能描述：返回字符型日期
	 * 
	 * @param date
	 *            日期
	 * @return 返回字符型日期 yyyy-MM-dd 格式
	 */
	public static String getDate(Date date) {
		return format(date, "yyyy-MM-dd");
	}

	/**
	 * 功能描述：返回字符型时间
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回字符型时间 HH:mm:ss 格式
	 */
	public static String getTime(Date date) {
		return format(date, "HH:mm:ss");
	}

	/**
	 * 功能描述：返回字符型日期时间
	 * 
	 * @param date
	 *            Date 日期
	 * @return 返回字符型日期时间 yyyy-MM-dd HH:mm:ss 格式
	 */
	public static String getDateTime(Date date) {
		return format(date, "yyyy-MM-dd HH:mm:ss");
	}

	/**
	 * 功能描述：日期相加
	 * 
	 * @param date
	 *            Date 日期
	 * @param day
	 *            int 天数
	 * @return 返回相加后的日期
	 */
	public static Date addDate(Date date, int day) {
		calendar = Calendar.getInstance();
		long millis = getMillis(date) + ((long) day) * 24 * 3600 * 1000;
		calendar.setTimeInMillis(millis);
		return calendar.getTime();
	}

	/**
	 * 功能描述：日期相加
	 * 
	 * @param date
	 *            yyyy-MM-dd
	 * @param day
	 *            int 天数
	 * @return 返回相加后的日期
	 * @throws ParseException
	 */
	public static String add(String date, int day) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat("dd/MM/yyyy");
		long d = df.parse(date).getTime();
		long millis = d + ((long) day) * 24 * 3600 * 1000;
		return df.format(new Date(millis));
	}

	/**
	 * 功能描述：日期相减
	 * 
	 * @param date
	 *            Date 日期
	 * @param date1
	 *            Date 日期
	 * @return 返回相减后的日期
	 */
	public static int diffDate(Date date, Date date1) {
		return (int) ((getMillis(date) - getMillis(date1)) / (24 * 3600 * 1000));
	}

	/**
	 * 功能描述：取得指定月份的第一天
	 * 
	 * @param strdate
	 *            String 字符型日期
	 * @return String yyyy-MM-dd 格式
	 */
	public static String getMonthBegin(String strdate) {
		date = parseDate(strdate);
		return format(date, "yyyy-MM") + "-01";
	}

	/**
	 * 功能描述：取得指定月份的最后一天
	 * 
	 * @param strdate
	 *            String 字符型日期
	 * @return String 日期字符串 yyyy-MM-dd格式
	 */
	public static String getMonthEnd(String strdate) {
		date = parseDate(getMonthBegin(strdate));
		calendar = Calendar.getInstance();
		calendar.setTime(date);
		calendar.add(Calendar.MONTH, 2);
		calendar.add(Calendar.DAY_OF_YEAR, -1);
		return formatDate(calendar.getTime());
	}

	/**
	 * 功能描述：常用的格式化日期
	 * 
	 * @param date
	 *            Date 日期
	 * @return String 日期字符串 yyyy-MM-dd格式
	 */
	public static String formatDate(Date date) {
		return formatDateByFormat(date, "yyyy-MM-dd");
	}

	/**
	 * 以指定的格式来格式化日期
	 * 
	 * @param date
	 *            Date 日期
	 * @param format
	 *            String 格式
	 * @return String 日期字符串
	 */
	public static String formatDateByFormat(Date date, String format) {
		String result = "";
		if (date != null) {
			try {
				SimpleDateFormat sdf = new SimpleDateFormat(format);
				result = sdf.format(date);
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return result;
	}

	/**
	 * 计算日期之间的天数
	 * 
	 * @param beginDate
	 *            开始日期 yyy-MM-dd
	 * @param endDate
	 *            结束日期 yyy-MM-dd
	 * @return
	 * @throws ParseException
	 */
	public static int getDay(String beginDate, String endDate) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd");
		long to = df.parse(endDate).getTime();
		long from = df.parse(beginDate).getTime();
		return (int) ((to - from) / (1000 * 60 * 60 * 24));
	}
}

```



### FreeMarkerUtil

```
package com.zyd.blog.util;

import freemarker.template.Configuration;
import freemarker.template.Template;
import freemarker.template.TemplateException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Freemarker模板操作工具类
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
 */
@Slf4j
public class FreeMarkerUtil {

    private static final String LT = "<";
    private static final String LT_CHAR = "&lt;";
    private static final String GT = ">";
    private static final String GT_CHAR = "&gt;";
    private static final String AMP = "&";
    private static final String AMP_CHAR = "&amp;";
    private static final String APOS = "'";
    private static final String APOS_CHAR = "&apos;";
    private static final String QUOT = "&quot;";
    private static final String QUOT_CHAR = "\"";

    /**
     * Template to String Method Note
     *
     * @param templateContent template content
     * @param map             tempate data map
     * @return
     */
    public static String template2String(String templateContent, Map<String, Object> map,
                                         boolean isNeedFilter) {
        if (StringUtils.isEmpty(templateContent)) {
            return null;
        }
        if (map == null) {
            map = new HashMap<>();
        }
        Map<String, Object> newMap = new HashMap<>(1);

        Set<String> keySet = map.keySet();
        if (keySet.size() > 0) {
            for (String key : keySet) {
                Object o = map.get(key);
                if (o != null) {
                    if (o instanceof String) {
                        String value = o.toString();
                        value = value.trim();
                        if (isNeedFilter) {
                            value = filterXmlString(value);
                        }
                        newMap.put(key, value);
                    } else {
                        newMap.put(key, o);
                    }
                }
            }
        }
        Template t = null;
        try {
            // 设定freemarker对数值的格式化
            Configuration cfg = new Configuration(Configuration.VERSION_2_3_22);
            cfg.setNumberFormat("#");
            t = new Template("", new StringReader(templateContent), cfg);
            StringWriter writer = new StringWriter();
            t.process(newMap, writer);
            return writer.toString();
        } catch (IOException e) {
            log.error("TemplateUtil -> template2String IOException.", e);
        } catch (TemplateException e) {
            log.error("TemplateUtil -> template2String TemplateException.", e);
        } finally {
            newMap.clear();
            newMap = null;
        }
        return null;
    }

    private static String filterXmlString(String str) {
        if (null == str) {
            return null;
        }
        str = str.replaceAll(LT, LT_CHAR);
        str = str.replaceAll(GT, GT_CHAR);
        str = str.replaceAll(AMP, AMP_CHAR);
        str = str.replaceAll(APOS, APOS_CHAR);
        str = str.replaceAll(QUOT, QUOT_CHAR);
        return str;
    }
}

```

### HtmlUtil

```
package com.zyd.blog.util;

import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;
import org.springframework.util.StringUtils;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author yadong.zhang email:yadong.zhang0415(a)gmail.com
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/1/19 10:32
 * @since 1.0
 */
public class HtmlUtil {

    /**
     * 获取Element
     *
     * @param htmlDocument
     * @param id
     * @return
     */
    public static Element getElementById(Document htmlDocument, String id) {
        if (htmlDocument == null || id == null || id.equals("")) {
            return null;
        }
        return htmlDocument.getElementById(id);
    }

    /**
     * 替换所有标签
     *
     * @param content
     * @return
     */
    public static String html2Text(String content) {
        if (StringUtils.isEmpty(content)) {
            return "";
        }
        // 定义HTML标签的正则表达式
        String regEx_html = "<[^>]+>";
        content = content.replaceAll(regEx_html, "").replaceAll(" ", "");
        content = content.replaceAll("&quot;", "\"")
                .replaceAll("&nbsp;", "")
                .replaceAll("&amp;", "&")
                .replaceAll("\n", " ")
                .replaceAll("&#39;", "\'")
                .replaceAll("&lt;", "<")
                .replaceAll("&gt;", ">")
                .replaceAll("[ \\f\\t\\v]{2,}", "\t");

        String regEx = "<.+?>";
        Pattern pattern = Pattern.compile(regEx);
        Matcher matcher = pattern.matcher(content);
        content = matcher.replaceAll("");
        return content.trim();
    }
}

```

### IpUtil

```
package com.zyd.blog.util;

import org.springframework.util.StringUtils;

import javax.servlet.http.HttpServletRequest;

/**
 * 获取IP的工具类
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
 */
public class IpUtil {

    /**
     * 获取真实IP
     *
     * @param request
     * @return
     */
    public static String getRealIp(HttpServletRequest request) {
        String ip = request.getHeader("x-forwarded-for");
        return checkIp(ip) ? ip : (
                checkIp(ip = request.getHeader("Proxy-Client-IP")) ? ip : (
                        checkIp(ip = request.getHeader("WL-Proxy-Client-IP")) ? ip :
                                request.getRemoteAddr()));
    }

    /**
     * 校验IP
     *
     * @param ip
     * @return
     */
    private static boolean checkIp(String ip) {
        return !StringUtils.isEmpty(ip) && !"unknown".equalsIgnoreCase(ip);
    }
}
```

### Md5Util

```
package com.zyd.blog.util;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.security.MessageDigest;

/**
 * MD5加密工具类
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
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

### MD5Util

```
/*
 * Copyright 2015-2016 RonCoo(http://www.roncoo.com) Group.
 *  
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.roncoo.jui.common.util;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * MD5加密，使用UTF-8编码
 *
 * @author wujing
 */
public final class MD5Util {

	private MD5Util() {
	}

	/**
	 * Used building output as Hex
	 */
	private static final char[] DIGITS = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

	/**
	 * 对字符串进行MD5加密， 默认使用UTF-8
	 * 
	 * @param text
	 *            明文
	 * @return 密文
	 */
	public static String MD5(String text) {
		return MD5(text, "UTF-8");
	}

	/**
	 * 对字符串进行MD5加密
	 * 
	 * @param text
	 *            明文
	 * @param charsetName
	 *            指定编码
	 * @return 密文
	 */
	public static String MD5(String text, String charsetName) {
		MessageDigest msgDigest = null;
		try {
			msgDigest = MessageDigest.getInstance("MD5");
		} catch (NoSuchAlgorithmException e) {
			throw new IllegalStateException("System doesn't support MD5 algorithm.");
		}
		try {
			msgDigest.update(text.getBytes(charsetName)); // 注意是按照指定编码形式签名
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException("System doesn't support your  EncodingException.");
		}
		byte[] bytes = msgDigest.digest();
		return new String(encodeHex(bytes));
	}

	private static char[] encodeHex(byte[] data) {
		int l = data.length;
		char[] out = new char[l << 1];
		for (int i = 0, j = 0; i < l; i++) {
			out[j++] = DIGITS[(0xF0 & data[i]) >>> 4];
			out[j++] = DIGITS[0x0F & data[i]];
		}
		return out;
	}

}

```



### PasswordUtil

```
package com.zyd.blog.util;

import com.zyd.blog.business.consts.CommonConst;

/**
 * @author: yadong.zhang
 * @date: 2017/12/15 17:03
 */
public class PasswordUtil {

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
        return AesUtil.encrypt(Md5Util.MD5(salt + CommonConst.ZYD_SECURITY_KEY), password);
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
        return AesUtil.decrypt(Md5Util.MD5(salt + CommonConst.ZYD_SECURITY_KEY), encryptPassword);
    }
}

```

### RegexUtils

```
package com.zyd.blog.util;

import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * 正则表达式工具类
 *
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
 */
public class RegexUtils {

    /**
     * @param regex
     *         正则表达式字符串
     * @param str
     *         要匹配的字符串
     * @return 如果str 符合 regex的正则表达式格式,返回true, 否则返回 false;
     */
    public static List<String> match(String str, String regex) {
        if (null == str) {
            return null;
        }
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(str);
        List<String> list = new LinkedList<>();
        while (matcher.find()) {
            list.add(matcher.group());
        }
        return list;
    }

    public static boolean checkByRegex(String str, String regex) {
        if (null == str) {
            return false;
        }
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(str);
        return matcher.find();
    }
}  


```

### RequestHolder

```
package com.zyd.blog.framework.holder;

import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/16 16:26
 * @since 1.0
 */
@Slf4j
public class RequestHolder {

    /**
     * 获取request
     *
     * @return HttpServletRequest
     */
    public static HttpServletRequest getRequest() {
        log.debug("getRequest -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return null;
        }
        return servletRequestAttributes.getRequest();
    }

    /**
     * 获取Response
     *
     * @return HttpServletRequest
     */
    public static HttpServletResponse getResponse() {
        log.debug("getResponse -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return null;
        }
        return servletRequestAttributes.getResponse();
    }

    /**
     * 获取session
     *
     * @return HttpSession
     */
    public static HttpSession getSession() {
        log.debug("getSession -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        HttpServletRequest request = null;
        if (null == (request = getRequest())) {
            return null;
        }
        return request.getSession();
    }

    /**
     * 获取session的Attribute
     *
     * @param name session的key
     * @return Object
     */
    public static Object getSession(String name) {
        log.debug("getSession -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return null;
        }
        return servletRequestAttributes.getAttribute(name, RequestAttributes.SCOPE_SESSION);
    }

    /**
     * 添加session
     *
     * @param name
     * @param value
     */
    public static void setSession(String name, Object value) {
        log.debug("setSession -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return;
        }
        servletRequestAttributes.setAttribute(name, value, RequestAttributes.SCOPE_SESSION);
    }

    /**
     * 清除指定session
     *
     * @param name
     * @return void
     */
    public static void removeSession(String name) {
        log.debug("removeSession -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return;
        }
        servletRequestAttributes.removeAttribute(name, RequestAttributes.SCOPE_SESSION);
    }

    /**
     * 获取所有session key
     *
     * @return String[]
     */
    public static String[] getSessionKeys() {
        log.debug("getSessionKeys -- Thread id :{}, name : {}", Thread.currentThread().getId(), Thread.currentThread().getName());
        ServletRequestAttributes servletRequestAttributes = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes());
        if (null == servletRequestAttributes) {
            return null;
        }
        return servletRequestAttributes.getAttributeNames(RequestAttributes.SCOPE_SESSION);
    }
}

```



### RequestUtil

```
package com.zyd.blog.util;

import com.zyd.blog.framework.holder.RequestHolder;

import javax.servlet.http.HttpServletRequest;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/4/18 11:48
 * @since 1.0
 */
public class RequestUtil {

    public static String getParameters() {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return null;
        }
        Enumeration<String> paraNames = request.getParameterNames();
        if (paraNames == null) {
            return null;
        }
        StringBuilder sb = new StringBuilder();
        while (paraNames.hasMoreElements()) {
            String paraName = paraNames.nextElement();
            sb.append("&").append(paraName).append("=").append(request.getParameter(paraName));
        }
        return sb.toString();
    }

    public static Map<String, Object> getParametersMap() {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return new HashMap<>();
        }
        Enumeration<String> paraNames = request.getParameterNames();
        if (paraNames == null) {
            return new HashMap<>();
        }
        Map<String, Object> res = new HashMap<>();
        while (paraNames.hasMoreElements()) {
            String paraName = paraNames.nextElement();
            res.put(paraName, request.getParameter(paraName));
        }
        return res;
    }

    public static String getHeader(String headerName) {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return null;
        }
        return request.getHeader(headerName);
    }

    public static String getReferer() {
        return getHeader("Referer");
    }

    public static String getUa() {
        return getHeader("User-Agent");
    }

    public static String getIp() {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return null;
        }
        return IpUtil.getRealIp(request);
    }

    public static String getRequestUrl() {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return null;
        }
        return request.getRequestURL().toString();
    }

    public static String getMethod() {
        HttpServletRequest request = RequestHolder.getRequest();
        if (null == request) {
            return null;
        }
        return request.getMethod();
    }

    public static boolean isAjax(HttpServletRequest request) {
        if (null == request) {
            request = RequestHolder.getRequest();
        }
        if (null == request) {
            return false;
        }
        return "XMLHttpRequest".equalsIgnoreCase(request.getHeader("X-Requested-With"))
                || request.getParameter("ajax") != null;

    }

}

```

### XssKillerUtil

```
package com.zyd.blog.util;

import org.jsoup.Jsoup;
import org.jsoup.safety.Whitelist;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @version 1.0
 * @website https://www.zhyd.me
 * @date 2018/8/07 18:13
 * @since 1.0
 */
public class XssKillerUtil {
    private static final String[] WHITE_LIST = {"p", "strong", "pre", "code", "span", "blockquote", "em", "a"};
    private static String reg = null;
    private static String legalTags = null;

    static {
        StringBuilder regSb = new StringBuilder("<");
        StringBuilder tagsSb = new StringBuilder();
        for (String s : WHITE_LIST) {
            regSb.append("(?!").append(s).append(" )");
            tagsSb.append("<").append(s).append(">");
        }
        regSb.append("(?!/)[^>]*>");
        reg = regSb.toString();
        legalTags = tagsSb.toString();
    }

    /**
     * xss白名单验证
     *
     * @param xssStr
     * @return
     */
    public static boolean isValid(String xssStr) {
        if (null == xssStr || xssStr.isEmpty()) {
            return true;
        }
        Pattern pattern = Pattern.compile(reg);
        Matcher matcher = pattern.matcher(xssStr);
        while (matcher.find()) {
            String tag = matcher.group();
            if (!legalTags.contains(tag.toLowerCase())) {
                return false;
            }
        }
        return true;
    }

    /**
     * xss白名单验证（Jsoup工具，效率较自己实现的那个有些差劲，见com.zyd.blog.util.XssKillerTest.test1()）
     *
     * @param xssStr
     * @return
     */
    public static boolean isValidByJsoup(String xssStr) {
        return Jsoup.isValid(xssStr, custome());
    }

    /**
     * 自定义的白名单
     *
     * @return
     */
    private static Whitelist custome() {
        return Whitelist.none().addTags("p", "strong", "pre", "code", "span", "blockquote", "br").addAttributes("span", "class");
    }

    /**
     * 根据白名单，剔除多余的属性、标签
     *
     * @param xssStr
     * @return
     */
    public static String clean(String xssStr) {
        if (null == xssStr || xssStr.isEmpty()) {
            return "";
        }
        return Jsoup.clean(xssStr, custome());
    }

    public static String escape(String xssStr) {
        if (null == xssStr || xssStr.isEmpty()) {
            return "";
        }

        // TODO ...
        return xssStr;
    }
}

```

### ApplicationContextUtil

```
package com.len.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

/**
 * @author zhuxiaomeng
 * @date 2018/1/5.
 * @email 154040976@qq.com
 */
public class ApplicationContextUtil implements ApplicationContextAware {

  private static ApplicationContext applicationContext;
  @Override
  public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
    ApplicationContextUtil.applicationContext=applicationContext;
  }

  public static ApplicationContext getContext(){
    return applicationContext;
  }

  public static Object getBean(String arg){
    return applicationContext.getBean(arg);
  }
}

```

### SpringContextHolder

```
package com.zyd.blog.framework.holder;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

/**
 * @author yadong.zhang (yadong.zhang0415(a)gmail.com)
 * @website https://www.zhyd.me
 * @version 1.0
 * @date 2018/4/16 16:26
 * @since 1.0
 */
@Component
public class SpringContextHolder implements ApplicationContextAware {

    private static ApplicationContext appContext = null;

    /**
     * 通过name获取 Bean.
     *
     * @param name
     * @return
     */
    public static Object getBean(String name) {
        return appContext.getBean(name);

    }

    /**
     * 通过class获取Bean.
     *
     * @param clazz
     * @param <T>
     * @return
     */
    public static <T> T getBean(Class<T> clazz) {
        return appContext.getBean(clazz);
    }

    /**
     * 通过name,以及Clazz返回指定的Bean
     *
     * @param name
     * @param clazz
     * @param <T>
     * @return
     */
    public static <T> T getBean(String name, Class<T> clazz) {
        return appContext.getBean(name, clazz);
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        if (appContext == null) {
            appContext = applicationContext;
        }
    }
}

```



### SpringUtil

```
package com.len.util;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;
/**
 * @author zhuxiaomeng
 * @date 2018/1/5.
 * @email 154040976@qq.com
 * 参照一些案例在此对 在此对网上分享者说声感谢 by：zxm
 * 通过封装applicationContext上线文
 * 获取 spring bean对象 bean启动时候 已经被打印出，可直接根据name、class、name class获取
 *
 * 很多地方能用得到
 */
@Component
public class SpringUtil implements ApplicationContextAware {

    private static ApplicationContext applicationContext;
  
    @Override  
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        if (SpringUtil.applicationContext == null) {  
            SpringUtil.applicationContext = applicationContext;  
        }
    }  
  
    public static ApplicationContext getApplicationContext() {  
        return applicationContext;  
    }

    /***
     * 根据name获取bean
     * @param name
     * @param <T>
     * @return
     */
    @SuppressWarnings("unchecked")  
    public static <T> T getBean(String name) {  
        return (T) getApplicationContext().getBean(name);  
    }  

    public static <T> T getBean(Class<T> clazz) {  
        return getApplicationContext().getBean(clazz);  
    }  

    public static <T> T getBean(String name, Class<T> clazz) {  
        return getApplicationContext().getBean(name, clazz);  
    }  
  
}  
```

### JsonUtil返回结果工具

```
package com.len.util;


import com.alibaba.fastjson.JSONObject;
import lombok.Data;

/**
 * @author zhuxiaomeng
 * @date 2017/12/15.
 * @email 154040976@qq.com
 * ajax 回执
 */
@Data
public class JsonUtil {

    //默认成功
    private boolean flag = true;
    private String msg;
    private JSONObject josnObj;
    private Integer status;
    private Object data;

    public boolean isFlag() {
        return flag;
    }

    public void setFlag(boolean flag) {
        this.flag = flag;
    }

    public JsonUtil() {
    }

    public JsonUtil(boolean flag, String msg) {
        this.flag = flag;
        this.msg = msg;
    }

    public JsonUtil(boolean flag, String msg, Integer status) {
        this.flag = flag;
        this.msg = msg;
        this.status = status;
    }

    /**
     * restful 返回
     */
    public static JsonUtil error(String msg) {
        return new JsonUtil(false, msg);
    }

    public static JsonUtil sucess(String msg) {
        return new JsonUtil(true, msg);
    }
}

```

### PageUtil

```
package com.len.util;

/**
 * @author zhuxiaomeng
 * @date 2017/12/6.
 * @email 154040976@qq.com
 * 分页工具
 */
public class PageUtil <T>{
  /**当前页*/
  private int curPageNo=1;
  private int pageCount;//总页数
  private int pageSize=5;//每页大小 默认5
  private int upPageNo;//上一页
  private int nextPageNo;//下一页
  private int startPage;//开始页

  private T t;

  public int getCurPageNo() {
    return curPageNo;
  }

  public void setCurPageNo(int curPageNo) {
    if(curPageNo<=0){
      this.curPageNo=1;
    }
    if(curPageNo!=1&&curPageNo>0){
      upPageNo=curPageNo-1;
    }
    nextPageNo=curPageNo+1;
    this.curPageNo = curPageNo;
    this.startPage=(curPageNo-1)*pageSize;
  }

  public int getPageCount() {
    return pageCount;
  }

  public void setPageCount(int pageCount) {
    if(pageCount%pageSize>0){
      this.pageCount=pageCount/pageSize+1;
    }else {
      this.pageCount = pageCount/pageSize;
    }
  }

  public int getPageSize() {
    return pageSize;
  }

  public void setPageSize(int pageSize) {
    this.pageSize = pageSize;
  }

  public int getUpPageNo() {
    return upPageNo;
  }

  public void setUpPageNo(int upPageNo) {
    this.upPageNo = upPageNo;
  }

  public int getNextPageNo() {
    return nextPageNo;
  }

  public void setNextPageNo(int nextPageNo) {
    this.nextPageNo = nextPageNo;
  }

  public int getStartPage() {
    return startPage;
  }

  public void setStartPage(int startPage) {

    this.startPage = startPage;
  }
}

```

### PageUtil

```
package com.roncoo.jui.common.util;

import java.io.Serializable;
import java.lang.reflect.InvocationTargetException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.BeanUtils;

import com.roncoo.jui.common.util.jui.Page;

/**
 * 分页
 * 
 * @author wujing
 * @param <T>
 */
public final class PageUtil<T extends Serializable> implements Serializable {

	private static final long serialVersionUID = 1L;

	private static final Logger logger = LoggerFactory.getLogger(PageUtil.class);

	private PageUtil() {
	}

	/**
	 * 默认每页记录数(20)
	 */
	public static final int DEFAULT_PAGE_SIZE = 20;

	/**
	 * 最大每页记录数(1000)
	 */
	public static final int MAX_PAGE_SIZE = 1000;

	/**
	 * 检测sql，防止sql注入
	 * 
	 * @param sql
	 *            sql
	 * @return 正常返回sql；异常返回""
	 */
	public static String checkSql(String sql) {
		String inj_str = "'|and|exec|insert|select|delete|update|count|*|%|chr|mid|master|truncate|char|declare|;|or|+|,";
		String inj_stra[] = inj_str.split("\\|");
		for (int i = 0; i < inj_stra.length; i++) {
			if (sql.indexOf(inj_stra[i]) >= 0) {
				return "";
			}
		}
		return sql;
	}

	/**
	 * 计算总页数
	 *
	 * @param totalCount
	 *            总记录数.
	 * @param pageSize
	 *            每页记录数.
	 * @return totalPage 总页数.
	 */
	public static int countTotalPage(final int totalCount, final int pageSize) {
		if (totalCount == 0) {
			return 1;
		}
		if (totalCount % pageSize == 0) {
			return totalCount / pageSize; // 刚好整除
		} else {
			return totalCount / pageSize + 1; // 不能整除则总页数为：商 + 1
		}
	}

	/**
	 * 校验当前页数pageCurrent<br/>
	 * 1、先根据总记录数totalCount和每页记录数pageSize，计算出总页数totalPage<br/>
	 * 2、判断页面提交过来的当前页数pageCurrent是否大于总页数totalPage，大于则返回totalPage<br/>
	 * 3、判断pageCurrent是否小于1，小于则返回1<br/>
	 * 4、其它则直接返回pageCurrent
	 *
	 * @param totalCount
	 *            要分页的总记录数
	 * @param pageSize
	 *            每页记录数大小
	 * @param pageCurrent
	 *            输入的当前页数
	 * @return pageCurrent
	 */
	public static int checkPageCurrent(int totalCount, int pageSize, int pageCurrent) {
		int totalPage = countTotalPage(totalCount, pageSize); // 最大页数
		if (pageCurrent > totalPage) {
			// 如果页面提交过来的页数大于总页数，则将当前页设为总页数
			// 此时要求totalPage要大于获等于1
			if (totalPage < 1) {
				return 1;
			}
			return totalPage;
		} else if (pageCurrent < 1) {
			return 1; // 当前页不能小于1（避免页面输入不正确值）
		} else {
			return pageCurrent;
		}
	}

	/**
	 * 校验页面输入的每页记录数pageSize是否合法<br/>
	 * 1、当页面输入的每页记录数pageSize大于允许的最大每页记录数MAX_PAGE_SIZE时，返回MAX_PAGE_SIZE
	 * 2、如果pageSize小于1，则返回默认的每页记录数DEFAULT_PAGE_SIZE
	 *
	 * @param pageSize
	 *            页面输入的每页记录数
	 * @return checkPageSize
	 */
	public static int checkPageSize(int pageSize) {
		if (pageSize > MAX_PAGE_SIZE) {
			return MAX_PAGE_SIZE;
		} else if (pageSize < 1) {
			return DEFAULT_PAGE_SIZE;
		} else {
			return pageSize;
		}
	}

	/**
	 * 计算当前分页的开始记录的索引
	 *
	 * @param pageCurrent
	 *            当前第几页
	 * @param pageSize
	 *            每页记录数
	 * @return 当前页开始记录号
	 */
	public static int countOffset(final int pageCurrent, final int pageSize) {
		return (pageCurrent - 1) * pageSize;
	}

	/**
	 * 根据总记录数，对页面传来的分页参数进行校验，并返分页的SQL语句
	 *
	 * @param pageCurrent
	 *            当前页
	 * @param pageSize
	 *            每页记录数
	 * @param pageBean
	 *            DWZ分页查询参数
	 * @return limitSql
	 */
	public static String limitSql(int totalCount, int pageCurrent, int pageSize) {
		// 校验当前页数
		pageCurrent = checkPageCurrent(totalCount, pageSize, pageCurrent);
		pageSize = checkPageSize(pageSize); // 校验每页记录数
		return new StringBuffer().append(" limit ").append(countOffset(pageCurrent, pageSize)).append(",").append(pageSize).toString();
	}

	/**
	 * 根据分页查询的SQL语句，获取统计总记录数的语句
	 *
	 * @param sql
	 *            分页查询的SQL
	 * @return countSql
	 */
	public static String countSql(String sql) {
		String countSql = sql.substring(sql.toLowerCase().indexOf("from")); // 去除第一个from前的内容
		return new StringBuffer().append("select count(*) ").append(removeOrderBy(countSql)).toString();
	}

	/**
	 * 移除SQL语句中的的order by子句（用于分页前获取总记录数，不需要排序）
	 *
	 * @param sql
	 *            原始SQL
	 * @return 去除order by子句后的内容
	 */
	private static String removeOrderBy(String sql) {
		Pattern pat = Pattern.compile("order\\s*by[\\w|\\W|\\s|\\S]*", Pattern.CASE_INSENSITIVE);
		Matcher mc = pat.matcher(sql);
		StringBuffer strBuf = new StringBuffer();
		while (mc.find()) {
			mc.appendReplacement(strBuf, "");
		}
		mc.appendTail(strBuf);
		return strBuf.toString();
	}

	/**
	 * 模糊查询
	 * 
	 * @param str
	 * @return
	 */
	public static String like(String str) {
		return new StringBuffer().append("%").append(str).append("%").toString();
	}

	public static <T extends Serializable> Page<T> transform(Page<?> page, Class<T> classType) {
		Page<T> pb = new Page<>();
		try {
			pb.setList(copy(page.getList(), classType));
		} catch (Exception e) {
			logger.error("transform error", e);
		}
		pb.setCurrentPage(page.getCurrentPage());
		pb.setNumPerPage(page.getNumPerPage());
		pb.setTotalCount(page.getTotalCount());
		pb.setTotalPage(page.getTotalPage());
		pb.setOrderField(page.getOrderField());
		pb.setOrderDirection(page.getOrderDirection());
		return pb;
	}

	/**
	 * @param source
	 * @param clazz
	 * @return
	 * @throws IllegalAccessException
	 * @throws InvocationTargetException
	 * @throws InstantiationException
	 */
	public static <T> List<T> copy(List<?> source, Class<T> clazz) throws IllegalAccessException, InvocationTargetException, InstantiationException {
		if (source.size() == 0) {
			return Collections.emptyList();
		}
		List<T> res = new ArrayList<>(source.size());
		for (Object o : source) {
			T t = clazz.newInstance();
			BeanUtils.copyProperties(o, t);
			res.add(t);
		}
		return res;
	}

}

```



### ReType

```
package com.len.util;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import lombok.Data;

import java.io.Serializable;
import java.util.List;
import java.util.Map;

/**
 * @author zhuxiaomeng
 * @date 2017/12/19.
 * @email 154040976@qq.com
 * 查询返回json格式依照ui默认属性名称
 */
@Data
public class ReType implements Serializable{
  /**状态*/
  public int code=0;
  /**状态信息*/
  public String msg="";
  /**数据总数*/
  public long count;
  /**页码*/
  public long pageNum;

  public List<?> data;

  public ReType() {
  }

  public ReType(long count, List<?> data) {
    this.count = count;
    this.data = data;
  }

  public ReType(long count,long pageNum, List<?> data) {
    this.count = count;
    this.pageNum=pageNum;
    this.data = data;
  }

  /**
   * 动态添加属性 map 用法可以参考 activiti 模块中 com.len.JsonTest 测试类中用法
   * @param count
   * @param data
   * @param map
   * @param node 绑定节点字符串 这样可以更加灵活
   * @return
   */
  public static String jsonStrng(long count,List<?> data,Map<String, Map<String,Object>> map,String node){
    JSONArray jsonArray=JSONArray.parseArray(JSON.toJSONString(data));
    JSONObject object=new JSONObject();
    for(int i=0;i<jsonArray.size();i++){
      JSONObject jsonData = (JSONObject) jsonArray.get(i);
      jsonData.putAll(map.get(jsonData.get(node)));
    }
    object.put("count",count);
    object.put("data",jsonArray);
    object.put("code",0);
    object.put("msg","");
    return object.toJSONString();
  }
}

```

### TreeUtil

```
package com.len.util;

import java.util.ArrayList;
import java.util.List;
import lombok.Getter;
import lombok.Setter;

/**
 * @author zhuxiaomeng
 * @date 2017/12/27.
 * @email 154040976@qq.com
 *
 * 树形工具类
 */
@Getter
@Setter
public class TreeUtil {
    /**级数*/
    private int layer;
    private String id;
    private String name;
    private String pId;
    /**是否开启 默认开启*/
    private boolean open=true;
    /**是否选择 checkbox状态可用 默认未选中*/
    private boolean checked=false;
    private List<TreeUtil> children=new ArrayList<>();


}

```

### UploadUtil

```
package com.len.util;

import com.len.exception.MyException;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.UUID;

/**
 * Created by meng on 2018/5/8.
 * 文件上传工具类
 */
@Getter
@Setter
@ConfigurationProperties
@Component
public class UploadUtil {

    /**
     * 按照当日创建文件夹
     */
    @Value("${lenosp.isDayType}")
    private boolean isDayType;
    /**
     * 自定义文件路径
     */
    @Value("${lenosp.uploadPath}")
    private String uploadPath;

    @Value("${lenosp.imagePath}")
    private String imagePath;

    public static final String IMAGE_SUFFIX = "bmp,jpg,png,gif,jpeg";


    public UploadUtil() {
    }

    public String upload(MultipartFile multipartFile) {
        if (isNull(multipartFile)) {
            throw new MyException("上传数据/地址获取异常");
        }

        LoadType loadType = fileNameStyle(multipartFile);
        try {
            FileUtils.copyInputStreamToFile(multipartFile.getInputStream(), loadType.getCurrentFile());
        } catch (IOException e) {
            e.printStackTrace();
        }
        return loadType.getFileName();
    }

    /**
     * 格式化文件名 默认采用UUID
     *
     * @return
     */
    public LoadType fileNameStyle(MultipartFile multipartFile) {
        String curr = multipartFile.getOriginalFilename();
        int suffixLen = curr.lastIndexOf(".");
        boolean flag=false;
        int index=-1;
        if("blob".equals(curr)){
            flag=true;
            index=0;
            curr=UUID.randomUUID() + ".png";
        } else if (suffixLen == -1) {
            throw new MyException("文件获取异常");
        }
        if(!flag){
            String suffix = curr.substring(suffixLen, curr.length());
            index = Arrays.binarySearch(IMAGE_SUFFIX.split(","),
                    suffix.replace(".", ""));

            curr = UUID.randomUUID() + suffix;
        }
        LoadType loadType = new LoadType();
        loadType.setFileName(curr);
        //image 情况
        curr = StringUtils.isEmpty(imagePath) || index == -1 ?
                uploadPath + File.separator + curr : imagePath + File.separator + curr;
        loadType.setCurrentFile(new File(curr));
        return loadType;
    }

    private boolean isNull(MultipartFile multipartFile) {
        if (null != multipartFile) {
            return false;
        }
        return true;
    }

}

@Data
class LoadType {
    private String fileName;
    private File currentFile;
}

```

### VerifyCodeUtils

```
package com.len.util;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.Random;
import javax.imageio.ImageIO;

public class VerifyCodeUtils {
  
    //使用到Algerian字体，系统里没有的话需要安装字体，字体只显示大写，去掉了1,0,i,o几个容易混淆的字符  
    public static final String VERIFY_CODES = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";  
    private static Random random = new Random();  
  
    
    /**
     * 验证码对象
     * @author zhou-baicheng
     *
     */
    public static class Verify{

        private String code;//如 1 + 2
    	
    	private Integer value;//如  3
		public String getCode() {
			return code;
		}
		public void setCode(String code) {
			this.code = code;
		}
		public Integer getValue() {
			return value;
		}
		public void setValue(Integer value) {
			this.value = value;
		}
    }
  
    /** 
     * 使用系统默认字符源生成验证码 
     * @param verifySize    验证码长度 
     * @return 
     */  
    public static Verify generateVerify(){  
    	int number1 = new Random().nextInt(10) + 1;;
    	int number2 = new Random().nextInt(10) + 1;;
    	Verify entity = new Verify();
    	entity.setCode(number1  + " x " + number2);
    	entity.setValue(number1 + number2);
    	return entity;
    }  
    
    /** 
     * 使用系统默认字符源生成验证码 
     * @param verifySize    验证码长度 
     * @return 
     */  
    public static String generateVerifyCode(int verifySize){  
        return generateVerifyCode(verifySize, VERIFY_CODES);  
    }  
    
    
    /** 
     * 使用指定源生成验证码 
     * @param verifySize    验证码长度 
     * @param sources   验证码字符源 
     * @return 
     */  
    public static String generateVerifyCode(int verifySize, String sources){  
        if(sources == null || sources.length() == 0){  
            sources = VERIFY_CODES;  
        }  
        int codesLen = sources.length();  
        Random rand = new Random(System.currentTimeMillis());  
        StringBuilder verifyCode = new StringBuilder(verifySize);  
        for(int i = 0; i < verifySize; i++){  
            verifyCode.append(sources.charAt(rand.nextInt(codesLen-1)));  
        }  
        return verifyCode.toString();  
    }  
      
    /** 
     * 生成随机验证码文件,并返回验证码值 
     * @param w 
     * @param h 
     * @param outputFile 
     * @param verifySize 
     * @return 
     * @throws IOException 
     */  
    public static String outputVerifyImage(int w, int h, File outputFile, int verifySize) throws IOException{  
        String verifyCode = generateVerifyCode(verifySize);  
        outputImage(w, h, outputFile, verifyCode);  
        return verifyCode;  
    }  
      
    /** 
     * 输出随机验证码图片流,并返回验证码值 
     * @param w 
     * @param h 
     * @param os 
     * @param verifySize 
     * @return 
     * @throws IOException 
     */  
    public static String outputVerifyImage(int w, int h, OutputStream os, int verifySize) throws IOException{  
        String verifyCode = generateVerifyCode(verifySize);  
        outputImage(w, h, os, verifyCode);  
        return verifyCode;  
    }  
      
    /** 
     * 生成指定验证码图像文件 
     * @param w 
     * @param h 
     * @param outputFile 
     * @param code 
     * @throws IOException 
     */  
    public static void outputImage(int w, int h, File outputFile, String code) throws IOException{  
        if(outputFile == null){  
            return;  
        }  
        File dir = outputFile.getParentFile();  
        if(!dir.exists()){  
            dir.mkdirs();  
        }  
        try{  
            outputFile.createNewFile();  
            FileOutputStream fos = new FileOutputStream(outputFile);  
            outputImage(w, h, fos, code);  
            fos.close();  
        } catch(IOException e){  
            throw e;  
        }  
    }  
      
    /** 
     * 输出指定验证码图片流 
     * @param w 
     * @param h 
     * @param os 
     * @param code 
     * @throws IOException 
     */  
    public static void outputImage(int w, int h, OutputStream os, String code) throws IOException{  
        int verifySize = code.length();  
        BufferedImage image = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);  
        Random rand = new Random();  
        Graphics2D g2 = image.createGraphics();  
        g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING,RenderingHints.VALUE_ANTIALIAS_ON);  
        Color[] colors = new Color[5];  
        Color[] colorSpaces = new Color[] { Color.WHITE, Color.CYAN,  
                Color.GRAY, Color.LIGHT_GRAY, Color.MAGENTA, Color.ORANGE,  
                Color.PINK, Color.YELLOW };  
        float[] fractions = new float[colors.length];  
        for(int i = 0; i < colors.length; i++){  
            colors[i] = colorSpaces[rand.nextInt(colorSpaces.length)];  
            fractions[i] = rand.nextFloat();  
        }  
        Arrays.sort(fractions);  
          
        g2.setColor(Color.GRAY);// 设置边框色  
        g2.fillRect(0, 0, w, h);  
          
        Color c = getRandColor(200, 250);  
        g2.setColor(c);// 设置背景色  
        g2.fillRect(0, 2, w, h-4);  
          
        //绘制干扰线  
        Random random = new Random();  
        g2.setColor(getRandColor(160, 200));// 设置线条的颜色  
        for (int i = 0; i < 20; i++) {  
            int x = random.nextInt(w - 1);  
            int y = random.nextInt(h - 1);  
            int xl = random.nextInt(6) + 1;  
            int yl = random.nextInt(12) + 1;  
            g2.drawLine(x, y, x + xl + 40, y + yl + 20);  
        }  
          
        // 添加噪点  
        float yawpRate = 0.05f;// 噪声率  
        int area = (int) (yawpRate * w * h);  
        for (int i = 0; i < area; i++) {  
            int x = random.nextInt(w);  
            int y = random.nextInt(h);  
            int rgb = getRandomIntColor();  
            image.setRGB(x, y, rgb);  
        }  
          
        shear(g2, w, h, c);// 使图片扭曲  
  
        g2.setColor(getRandColor(100, 160));  
        int fontSize = h-4;  
        Font font = new Font("Algerian", Font.ITALIC, fontSize);  
        g2.setFont(font);  
        char[] chars = code.toCharArray();  
        for(int i = 0; i < verifySize; i++){  
            AffineTransform affine = new AffineTransform();  
            affine.setToRotation(Math.PI / 4 * rand.nextDouble() * (rand.nextBoolean() ? 1 : -1), (w / verifySize) * i + fontSize/2, h/2);  
            g2.setTransform(affine);  
            g2.drawChars(chars, i, 1, ((w-10) / verifySize) * i + 5, h/2 + fontSize/2 - 10);  
        }  
          
        g2.dispose();  
        ImageIO.write(image, "jpg", os);  
    }  
      
    private static Color getRandColor(int fc, int bc) {  
        if (fc > 255)  
            fc = 255;  
        if (bc > 255)  
            bc = 255;  
        int r = fc + random.nextInt(bc - fc);  
        int g = fc + random.nextInt(bc - fc);  
        int b = fc + random.nextInt(bc - fc);  
        return new Color(r, g, b);  
    }  
      
    private static int getRandomIntColor() {  
        int[] rgb = getRandomRgb();  
        int color = 0;  
        for (int c : rgb) {  
            color = color << 8;  
            color = color | c;  
        }  
        return color;  
    }  
      
    private static int[] getRandomRgb() {  
        int[] rgb = new int[3];  
        for (int i = 0; i < 3; i++) {  
            rgb[i] = random.nextInt(255);  
        }  
        return rgb;  
    }  
  
    private static void shear(Graphics g, int w1, int h1, Color color) {  
        shearX(g, w1, h1, color);  
        shearY(g, w1, h1, color);  
    }  
      
    private static void shearX(Graphics g, int w1, int h1, Color color) {  
  
        int period = random.nextInt(2);  
  
        boolean borderGap = true;  
        int frames = 1;  
        int phase = random.nextInt(2);  
  
        for (int i = 0; i < h1; i++) {  
            double d = (double) (period >> 1)  
                    * Math.sin((double) i / (double) period  
                            + (6.2831853071795862D * (double) phase)  
                            / (double) frames);  
            g.copyArea(0, i, w1, 1, (int) d, 0);  
            if (borderGap) {  
                g.setColor(color);  
                g.drawLine((int) d, i, 0, i);  
                g.drawLine((int) d + w1, i, w1, i);  
            }  
        }  
  
    }  
  
    private static void shearY(Graphics g, int w1, int h1, Color color) {  
  
        int period = random.nextInt(40) + 10; // 50;  
  
        boolean borderGap = true;  
        int frames = 20;  
        int phase = 7;  
        for (int i = 0; i < w1; i++) {  
            double d = (double) (period >> 1)  
                    * Math.sin((double) i / (double) period  
                            + (6.2831853071795862D * (double) phase)  
                            / (double) frames);  
            g.copyArea(i, 0, 1, h1, 0, (int) d);  
            if (borderGap) {  
                g.setColor(color);  
                g.drawLine(i, (int) d, i, 0);  
                g.drawLine(i, (int) d + h1, i, h1);  
            }  
  
        }  
  
    }  
    public static void main(String[] args) throws IOException{  
        File dir = new File("F:/verifies");  
        int w = 200, h = 80;  
        for(int i = 0; i < 50; i++){  
            String verifyCode = generateVerifyCode(4);  
            File file = new File(dir, verifyCode + ".jpg");  
            outputImage(w, h, file, verifyCode);  
        }  
    }  
    
   
}
```

