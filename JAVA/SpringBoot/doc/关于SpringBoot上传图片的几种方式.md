# 关于SpringBoot上传图片的几种方式

网站上传图片、文件等，最常见的就是直接上传到服务器的webapp目录下，或者直接上传服务的一个指定的文件夹下面。这种方式对于简单的单机应用确实是很方便、简单，出现的问题也会比较少。但是对于分布式项目，直接上传到项目路径的方式显然是不可靠的，而且随着业务量的增加，文件也会增加，对服务器的压力自然就增加了。这里简单的介绍自己所了解的几种方式保存文件。

1. 直接上传到指定的服务器路径；
2. 上传到第三方内容存储器，这里介绍将图片保存到七牛云
3. 自己搭建文件存储服务器，如：FastDFS

## 最简单的上传

首先说明，该项目结构是SpringBoot+mybatis。因为项目使用jar形式打包，所以这里将图片保存到一个指定的目录下。<!--more-->
添加WebAppConfig配置类

```
@Configuration
public class WebAppConfig extends WebMvcConfigurerAdapter{

    /**
     * 在配置文件中配置的文件保存路径
     */
    @Value("${img.location}")
    private String location;

    @Bean
    public MultipartConfigElement multipartConfigElement(){
        MultipartConfigFactory factory = new MultipartConfigFactory();
        //文件最大KB,MB
        factory.setMaxFileSize("2MB");
        //设置总上传数据总大小
        factory.setMaxRequestSize("10MB");
        return factory.createMultipartConfig();
    }
}
```

文件上传的方法,这个方法有些参数可能需要做简单的修改，大致就是文件先做文件保存路径的处理，然后保存文件到该路径，最后返回文件上传信息

```
    @PutMapping("/article/img/upload")
    public MarkDVo uploadImg(@RequestParam("editormd-image-file") MultipartFile multipartFile)  {
        if (multipartFile.isEmpty() || StringUtils.isBlank(multipartFile.getOriginalFilename())) {
           throw new BusinessException(ResultEnum.IMG_NOT_EMPTY);
        }
        String contentType = multipartFile.getContentType();
        if (!contentType.contains("")) {
            throw new BusinessException(ResultEnum.IMG_FORMAT_ERROR);
        }
        String root_fileName = multipartFile.getOriginalFilename();
        logger.info("上传图片:name={},type={}", root_fileName, contentType);
        //处理图片
        User currentUser = userService.getCurrentUser();
        //获取路径
        String return_path = ImageUtil.getFilePath(currentUser);
        String filePath = location + return_path;
        logger.info("图片保存路径={}", filePath);
        String file_name = null;
        try {
            file_name = ImageUtil.saveImg(multipartFile, filePath);
            MarkDVo markDVo = new MarkDVo();
            markDVo.setSuccess(0);
            if(StringUtils.isNotBlank(file_name)){
                markDVo.setSuccess(1);
                markDVo.setMessage("上传成功");
                markDVo.setUrl(return_path+File.separator+file_name);
                markDVo.setCallback(callback);
            }
            logger.info("返回值：{}",markDVo);
            return markDVo;
        } catch (IOException e) {
            throw new BusinessException(ResultEnum.SAVE_IMG_ERROE);
        }
    }
```

文件保存类

```
     /**
     * 保存文件，直接以multipartFile形式
     * @param multipartFile
     * @param path 文件保存绝对路径
     * @return 返回文件名
     * @throws IOException
     */
    public static String saveImg(MultipartFile multipartFile,String path) throws IOException {
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
        FileInputStream fileInputStream = (FileInputStream) multipartFile.getInputStream();
        String fileName = Constants.getUUID() + ".png";
        BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(path + File.separator + fileName));
        byte[] bs = new byte[1024];
        int len;
        while ((len = fileInputStream.read(bs)) != -1) {
            bos.write(bs, 0, len);
        }
        bos.flush();
        bos.close();
        return fileName;
    }
```

配置文件保存路径
![img](https://segmentfault.com/img/remote/1460000012844842?w=315&h=84)
测试：直接使用postman上传
![img](https://segmentfault.com/img/remote/1460000012844843?w=894&h=435)
![img](https://segmentfault.com/img/remote/1460000012844844?w=800&h=167)
下面需要访问预览该上传的图片
在配置文件中添加对静态资源的配置。SpringBoot对静态的的处理，[Springboot 之 静态资源路径配置](http://blog.csdn.net/zsl129/article/details/52906762)
![img](https://segmentfault.com/img/remote/1460000012844845?w=462&h=157)
然后在浏览器链接栏输入：此处应该忽略图片
![img](https://segmentfault.com/img/remote/1460000012844846?w=978&h=244)

## 上传到七牛云

这里首先要在七牛云中注册一个账号，并开通对象存储空间，免费用户有10G的存储空间。教程：<http://jiantuku.com/help/faq.html?src=settings_head>

然后在自己的项目中搭建环境：使用maven导包

```
<dependency>
    <groupId>com.qiniu</groupId>
    <artifactId>qiniu-java-sdk</artifactId>
    <version>[7.2.0, 7.2.99]</version>
</dependency>
```

然后再刚才找到刚才创建密钥，复制出来保存保存在项目资源文件中
![img](https://segmentfault.com/img/remote/1460000012844847?w=1228&h=506)
这里的bucket就是上面的存储空间名称，然后path是域名。
![img](https://segmentfault.com/img/remote/1460000012844848?w=554&h=140)
上传工具类：

```
@Component
public class QiniuUtil{

    private static final Logger logger = LoggerFactory.getLogger(QiniuUtil.class);

    @Value("${qiniu.accessKey}")
    private String accessKey;

    @Value("${qiniu.secretKey}")
    private String secretKey;

    @Value("${qiniu.bucket}")
    private String bucket;

    @Value("${qiniu.path}")
    private String path;

    /**
     * 将图片上传到七牛云
     * @param file
     * @param key 保存在空间中的名字，如果为空会使用文件的hash值为文件名
     * @return
     */
    public  String uploadImg(FileInputStream file, String key) {
        //构造一个带指定Zone对象的配置类
        Configuration cfg = new Configuration(Zone.zone1());
//...其他参数参考类注释
        UploadManager uploadManager = new UploadManager(cfg);
//...生成上传凭证，然后准备上传
//        String bucket = "oy09glbzm.bkt.clouddn.com";
        //默认不指定key的情况下，以文件内容的hash值作为文件名
        try {
            Auth auth = Auth.create(accessKey, secretKey);
            String upToken = auth.uploadToken(bucket);
            try {
                Response response = uploadManager.put(file, key, upToken, null, null);
                //解析上传成功的结果
                DefaultPutRet putRet = JSON.parseObject(response.bodyString(), DefaultPutRet.class);
//                DefaultPutRet putRet = new Gson().fromJson(response.bodyString(), DefaultPutRet.class);
//                System.out.println(putRet.key);
//                System.out.println(putRet.hash);
                String return_path = path+"/"+putRet.key;
                logger.info("保存地址={}",return_path);
                return return_path;
            } catch (QiniuException ex) {
                Response r = ex.response;
                System.err.println(r.toString());
                try {
                    System.err.println(r.bodyString());
                } catch (QiniuException ex2) {
                    //ignore
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }
}
```

上传接口方法

```
  /**
     * 上传文件到七牛云存储
     * @param multipartFile
     * @return
     * @throws IOException
     */
    @PutMapping("/article/img/qiniu")
    public String uploadImgQiniu(@RequestParam("editormd-image-file") MultipartFile multipartFile) throws IOException {
        FileInputStream inputStream = (FileInputStream) multipartFile.getInputStream();
        User currentUser = userService.getCurrentUser();
        String path = qiniuUtil.uploadImg(inputStream, currentUser.getUsername()+"_"+Constants.getUUID());
        return path;
    }
```

测试
![img](https://segmentfault.com/img/remote/1460000012844849?w=896&h=360)
![img](https://segmentfault.com/img/remote/1460000012844850?w=906&h=477)

## 上传文件到FastDFS

首先需要搭建FastDFS服务器，这里就不介绍了。传送门：[Linux下FastDFS系统的搭建](http://www.wanqhblog.top/2017/12/27/FastDFS%E7%B3%BB%E7%BB%9F%E7%9A%84%E6%90%AD%E5%BB%BA/)
依赖

```
   <!--FastDFS存储图片 start-->
    <dependency>
        <groupId>com.github.tobato</groupId>
        <artifactId>fastdfs-client</artifactId>
        <version>1.25.4-RELEASE</version>
    </dependency>
    <!--FastDFS存储图片 end-->
```

添加配置信息

![img](https://segmentfault.com/img/remote/1460000012844851?w=480&h=320)

FastDFS配置类

```
@Configuration
@ComponentScan(value = "com.github.tobato.fastdfs.service")
@Import(FdfsClientConfig.class)
@EnableMBeanExport(registration = RegistrationPolicy.IGNORE_EXISTING)
public class FastDfsConfig {
}
```

这里对于FastDFS文件的操作只处理上传，上传文件类：

```
    @Autowired
    private FastFileStorageClient storageClient;

    @Autowired
    private FdfsWebServer fdfsWebServer;

     @PutMapping("/article/img/fdfs")
    public String uploadImgfdfs(@RequestParam(value = "editormd-image-file") MultipartFile multipartFile) throws IOException {
        StorePath storePath= storageClient.uploadFile(multipartFile.getInputStream(), multipartFile.getSize(), "png", null);
        String path = storePath.getFullPath();
        logger.info("保存路径={}",path);
        return path;
    }
```

测试：
![img](https://segmentfault.com/img/remote/1460000012844852?w=815&h=35)