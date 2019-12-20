# 使用Git Bash上传文件及更新代码到GitHub教程

使用Git Bash上传文件及更新代码到GitHub教程,其实对于一个github来说已经给出了比较好的说明了。

###基本步骤
下面来实际操作下：
以D:\github文件夹为例。(如果要更新到其他repository，请另外新建一个文件夹)

首先启动 git bash


第一步：建立git仓库

```
git init
```

第二步：将项目的所有文件添加到仓库中，注意下方的 .

```
git add .
```

第三步：提交到仓库

```
git commit -m "注释语句"
```

第四步：将本地的仓库关联到GitHub，后面的https改成刚刚自己的地址，上面的红框处

```
git remote add origin https://github.com/yeshen/test0913
```

第五步：上传github之前pull一下

```
git pull origin master
```

第六步：上传代码到GitHub远程仓库

```
git push -u origin master
```

中间可能会让你输入Username和Password，你只要输入github的账号和密码就行了。执行完后，如果没有异常，等待执行完就上传成功了。


很尬尴，忘记退出账号。我这里使用的是别人的GIT bash 账号上传到了我自己的github 上。
###克隆代码
从远程库克隆
这是针对在本地的一个空的项目，要从远程库考代码下来，一般有两个步骤：

在本地想要克隆的文件夹下面创建GIT版本库，以及建立远程库的连接。（详细步骤可以查看前面章节内容）

用git clone克隆远程库所在项目的代码，比如要克隆上一节的代码，用下面命令即可

###更新代码
更换我自己的git 账号更新

第一步：查看当前的git仓库状态，可以使用git status

```
git status
```

第二步：更新全部

```
git add *
```

第三步：接着输入git commit -m “更新说明”

```
git commit -m "更新说明"
```

第四步：先git pull,拉取当前分支最新代码

```
git pull
```

第五步：push到远程master分支上

```
git push origin master
```


不出意外，打开GitHub已经同步了

git push命令会将本地仓库推送到远程服务器。
git pull命令则相反。
注：首次提交，先git pull下，修改完代码后，使用git status可以查看文件的差别，使用git add 添加要commit的文件。

大功告成，现在你知道如何将本地的项目提交到github上了。
###更多方法
#### it命令

##### 查看、添加、提交、删除、找回，重置修改文件

```
git help <command> # 显示command的help

git show # 显示某次提交的内容 git show $id

git co -- <file> # 抛弃工作区修改

git co . # 抛弃工作区修改

git add <file> # 将工作文件修改提交到本地暂存区

git add . # 将所有修改过的工作文件提交暂存区

git rm <file> # 从版本库中删除文件

git rm <file> --cached # 从版本库中删除文件，但不删除文件

git reset <file> # 从暂存区恢复到工作文件

git reset -- . # 从暂存区恢复到工作文件

git reset --hard # 恢复最近一次提交过的状态，即放弃上次提交后的所有本次修改

git ci <file> git ci . git ci -a # 将git add, git rm和git ci等操作都合并在一起做　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　

git ci -am "some comments"

git ci --amend # 修改最后一次提交记录

git revert <$id> # 恢复某次提交的状态，恢复动作本身也创建次提交对象

git revert HEAD # 恢复最后一次提交的状态
```



##### 查看文件diff

```
git diff <file> # 比较当前文件和暂存区文件差异 git diff

git diff <id1><id2> # 比较两次提交之间的差异

git diff <branch1>..<branch2> # 在两个分支之间比较

git diff --staged # 比较暂存区和版本库差异

git diff --cached # 比较暂存区和版本库差异

git diff --stat # 仅仅比较统计信息


查看提交记录

git log git log <file> # 查看该文件每次提交记录

git log -p <file> # 查看每次详细修改内容的diff

git log -p -2 # 查看最近两次详细修改内容的diff

git log --stat #查看提交统计信息

tig
Mac上可以使用tig代替diff和log，brew install tig
```



### Git 本地分支管理

##### 查看、切换、创建和删除分支

```
git br -r # 查看远程分支

git br <new_branch> # 创建新的分支

git br -v # 查看各个分支最后提交信息

git br --merged # 查看已经被合并到当前分支的分支

git br --no-merged # 查看尚未被合并到当前分支的分支

git co <branch> # 切换到某个分支

git co -b <new_branch> # 创建新的分支，并且切换过去

git co -b <new_branch> <branch> # 基于branch创建新的new_branch

git co $id # 把某次历史提交记录checkout出来，但无分支信息，切换到其他分支会自动删除

git co $id -b <new_branch> # 把某次历史提交记录checkout出来，创建成一个分支

git br -d <branch> # 删除某个分支

git br -D <branch> # 强制删除某个分支 (未被合并的分支被删除的时候需要强制)

分支合并和rebase

git merge <branch> # 将branch分支合并到当前分支

git merge origin/master --no-ff # 不要Fast-Foward合并，这样可以生成merge提交

git rebase master <branch> # 将master rebase到branch，相当于： git co <branch> && git rebase master && git co master && git merge <branch>

Git补丁管理(方便在多台机器上开发同步时用)

git diff > ../sync.patch # 生成补丁

git apply ../sync.patch # 打补丁

git apply --check ../sync.patch #测试补丁能否成功
```

### Git暂存管理

```
git stash # 暂存

git stash list # 列所有stash

git stash apply # 恢复暂存的内容

git stash drop # 删除暂存区
```

### Git远分支管理

```
git pull # 抓取远程仓库所有分支更新并合并到本地

git pull --no-ff # 抓取远程仓库所有分支更新并合并到本地，不要快进合并

git fetch origin # 抓取远程仓库更新

git merge origin/master # 将远程主分支合并到本地当前分支

git co --track origin/branch # 跟踪某个远程分支创建相应的本地分支

git co -b <local_branch> origin/<remote_branch> # 基于远程分支创建本地分支，功能同上

git push # push所有分支

git push origin master # 将本地主分支推到远程主分支

git push -u origin master # 将本地主分支推到远程(如无远程主分支则创建，用于初始化远程仓库)

git push origin <local_branch> # 创建远程分支， origin是远程仓库名

git push origin <local_branch>:<remote_branch> # 创建远程分支

git push origin :<remote_branch> #先删除本地分支(git br -d <branch>)，然后再push删除远程分支
```

### 创建远程仓库

```
git clone --bare robbin_site robbin_site.git # 用带版本的项目创建纯版本仓库

scp -r my_project.git git@ git.csdn.net:~ # 将纯仓库上传到服务器上

mkdir robbin_site.git && cd robbin_site.git && git --bare init # 在服务器创建纯仓库

git remote add origin git@ github.com:robbin/robbin_site.git # 设置远程仓库地址

git push -u origin master # 客户端首次提交

git push -u origin develop # 首次将本地develop分支提交到远程develop分支，并且track

git remote set-head origin master # 设置远程仓库的HEAD指向master分支

也可以命令设置跟踪远程库和本地库

git branch --set-upstream master origin/master

git branch --set-upstream develop origin/develop

解决 在使用git 对源代码进行push到gitHub时可能会出错，error: failed to push some refs to git。

出现错误的主要原因是github中的README.md文件不在本地代码目录中

可以通过如下命令进行github与本地代码合并: git pull --rebase origin master

重新执行之前的git push 命令，成功！

```


