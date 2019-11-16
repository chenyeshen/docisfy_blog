# 快速安装

### 全局安装docsify

```
npm i docsify-cli -g

```



### 初始化项目

```
docsify init ./docs

```

初始化成功后，可以看到 ./docs 目录下创建的几个文件

index.html 入口文件

README.md 会做为主页内容渲染

.nojekyll 用于阻止 GitHub Pages 会忽略掉下划线开头的文件

直接编辑 docs/README.md 就能更新网站内容，当然也可以写多个页面。



### 本地预览网站

运行一个本地服务器，通过 docsify serve 可以方便的预览效果，而且提供 LiveReload 功能，可以实时的预览。默认通过 http://localhost:3000访问。

```
docsify serve docs

```



常用配置项

### **Github Corner**

通过设置index.html中window.$docsify的 repo 参数配置仓库地址或者 username/repo 的字符串，会在页面右上角渲染一个 GitHub Corner 挂件，点击即可跳转到Github中对应的项目地址。

```
<script>
 window.$docsify = {
 name: '豆瓣影音',
 repo: 'https://github.com/Hanxueqing/Douban-Movie.git',
 coverpage: true
 }
 </script>

```



### **封面**

通过设置index.html中window.$docsify的 coverpage 参数，即可开启渲染封面的功能。

```
<script>
 window.$docsify = {
 name: '喵星人',
 repo: '',
 coverpage: true
 }
 </script>

```

封面的生成同样是从 markdown 文件渲染来的。开启渲染封面功能后在文档根目录创建 _coverpage.md 文件，在文档中编写需要展示在封面的内容。

```
![logo](https://docsify.js.org/_media/icon.svg)
# 喵星人
> 好好学习 天天向上.
* good good study
[GitHub](https://github.com/yeshen/docsify)
[Get Started](#quick-start)

```



目前的背景是随机生成的渐变色，我们自定义背景色或者背景图。可以参考官网文档封面这一章节自行设置。

### **主题**

直接打开 index.html 修改替换 css 地址即可切换主题，官方目前提供五套主题可供选择，模仿 Vue 和 buble 官网订制的主题样式。还有 @liril-net 贡献的黑色风格的主题。

```
 <link rel="stylesheet" href="//unpkg.com/docsify/themes/vue.css">
 <link rel="stylesheet" href="//unpkg.com/docsify/themes/buble.css">
 <link rel="stylesheet" href="//unpkg.com/docsify/themes/dark.css">
 <link rel="stylesheet" href="//unpkg.com/docsify/themes/pure.css">
 <link rel="stylesheet" href="//unpkg.com/docsify/themes/dolphin.css">

```

其他主题docsify-themeable又提供了三种样式可供选择：

> docsify-themeable是一个用于docsify的，简单到令人愉悦的主题系统.

**Defaults**

```
<!-- Theme: Defaults -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-defaults.css">

```

**Simple**

```
<!-- Theme: Defaults -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-defaults.css">

```

**Simple Dark**

```
<!-- Theme: Simple Dark -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-simple-dark.css">

```

另外还有一种在网上看到的样式：

```
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/docsify-themeable@0/dist/css/theme-simple.css">

```

### **多页面**

目前我创建的文档是单页面的，上下滚动即可浏览全部内容。如果想创建多个页面，即点击左侧侧边栏导航跳转到不同url，就需要配置多级路由，这一功能在docsify中也很容易实现，我们需要在index.html文件中的window.$docsify中开启loadSidebar选项：

```
<script>
 window.$docsify = {
 loadSidebar: true
 }
</script>
<script src="//unpkg.com/docsify"></script>

```

然后在根目录创建自己的_sidebar.md文件，配置我们需要显示的页面。详细操作步骤参考官方多页文档教程。

*注：配置了loadSidebar后就不会生成默认的侧边栏了。*

### **插件**

官方还提供了非常多实用的插件，比如说全文搜索、解析emoji表情、一键复制代码等等，完整版请参考官方插件列表。

### Github Pages

> 和 GitBook 生成的文档一样，我们可以直接把文档网站部署到 GitHub Pages 或者 VPS 上。

GitHub Pages 支持从三个地方读取文件

- docs/ 目录
- master 分支
- gh-pages 分支

我们推荐直接将文档放在 docs/ 目录下，找到仓库的Settings设置页面

image

开启 **GitHub Pages** 功能并选择 master branch /docs folder 选项。



发布成功后会显示网站地址，通过这个地址即可在线访问你编写的技术文档了。