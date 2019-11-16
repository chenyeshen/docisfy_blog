### vps官网：

www.hkisl.net

### 美国虚拟地址：

http://www.haoweichi.com/

1. 点击网址选择注册，语言可以选择中文简体

2. 打开美国虚拟地址获取身份信息
3. 对照虚拟地址填入注册页面，注意邮箱一定要填知己的，谷歌邮箱不行，测试可以QQ邮箱，139邮箱，
4. 国家地区要填united state，还有就是大厦楼层随便输入一个数字就行，货币类型最好选USD
5. 提交注册，如果没有错误提示，登录邮箱点击链接激活就行了
6. 然后可以购买免费的vps
7. 购买后自己改ssh密码，不然连不上
8. 网速还是不错的，还有就是他的系统centos7.5缺少防火墙组件，搭建酸酸乳没网，其他版本不清楚，解决办法就是直接用脚本重装纯净版centos7
9. 这里建议大家选择debian9.4

```
apt-get update -y && apt-get install curl -y

bash <(curl -s -L https://git.io/v2ray.sh)
```

最后要撸多台，撸一台后要关一下网确定自己ip变了再撸第二台

![](https://raw.githubusercontent.com/mukeyeshen/mukeyeshen.github.io/master/githubBlog20190905124350.png)



### 下载 V2RayN

下载链接：[ https://github.com/2dust/v2rayN/releases/latest](https://github.com/2dust/v2rayN/releases/latest)

然后选择 v2rayN-Core.zip 下载
下载好了之后，解压，然后打开解压的文件夹

![](https://raw.githubusercontent.com/mukeyeshen/mukeyeshen.github.io/master/githubBlog20190905130043.png)


### 配置 V2RayN

双击 `v2rayN.exe` 启动，然后在任务栏托盘找到 V2RayN 图标并双击它
添加一个 VMess 服务器

从剪贴板导入 URL

设置本地监听端口，此处我将它设置为 10086

![](https://raw.githubusercontent.com/mukeyeshen/mukeyeshen.github.io/master/githubBlog20190905125029.png)

## 启用系统代理

在任务栏托盘找到 V2RayN 图标并鼠标右键，然后选择 启动系统代理
并且设置 系统代理模式 》PAC 模式
之后在 V2RayN 主界面，找到 检查更新 》检查更新 PAC

## 测试一下

在完成上面的步骤的时候，正常来说，你已经处于翻出去的状态了
OK，此时你已经自由了，赶紧打开 [Google](https://www.google.com/ncr) 





