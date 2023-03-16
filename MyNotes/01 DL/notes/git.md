
练习链接: [Learn Git Branching](https://learngitbranching.js.org/?locale=zh_CN)

## 主要操作
### 查看状态
暂存
```sh
git status [file]
```
- 查看本地仓库中是否有未提交或未暂存的更改，可以使用 `git status` 命令。这个命令会显示当前分支的状态，包括未暂存的更改、未提交的更改和未跟踪的文件。
- 只查看某个特定文件是否有未提交或未暂存的更改，可以使用 `git status <file>` 命令。其中 `<file>` 是你要检查的文件的名称。


分支
```sh
git branch [-a|r]
```
- 查看远程仓库中的所有分支，可以使用 `git branch -r` 命令。这个命令会列出远程仓库中所有的分支。
- 查看本地和远程仓库中所有的分支，可以使用 `git branch -a` 命令。



### 动作
创建分支
```sh
git branch <branch_name>
```



## 远程操作

clone
```sh
git clone [-b 分支] https://xxx.git
```


通过远程分支创建本地分支并切换
```sh
git checkout -b <local_branch> origin/<remote_branch>
git checkout <local_branch>
```
不能直接切换到远程分支，但是你可以在本地创建一个远程分支的副本，然后切换到这个本地分支。具体操作如下：
1.  使用 `git checkout -b <local_branch> origin/<remote_branch>` 命令在本地创建一个远程分支的副本。其中 `<local_branch>` 是你要创建的本地分支的名称，`<remote_branch>` 是远程分支的名称。
2.  使用 `git checkout <local_branch>` 命令切换到新创建的本地分支。


push到远程制定分支
```sh
git push origin <local_branch>:<remote_branch>
```

`push.default` 配置项用来指定当你使用 `git push` 命令但没有指定分支时，Git 应该采取什么行为。

在 Git 2.0 之前，默认值是 `matching`，这意味着 Git 会把本地仓库中所有与远程仓库中同名的分支都推送到远程仓库。从 Git 2.0 开始，默认值更改为 `simple`，这意味着只有当前分支会被推送到远程仓库。

如果你想保留当前的行为（即 `matching`），可以按照警告信息中的提示，使用 `git config --global push.default matching` 命令进行设置。如果你想采用新的默认行为（即 `simple`），可以使用 `git config --global push.default simple` 命令进行设置。



## Error
#### master - main 分支拉取报错
```sh
git push -f git@github.com:StarWanan/P-Center.git master
error: src refspec master does not match any
```

由于github的分支名称已经从master --> main，所以代码应该改成：
```sh
git push -f git@github.com:StarWanan/P-Center.git main
```


#### .gitignore失效
参考： [博客园](https://www.cnblogs.com/goloving/p/15017769.html)
.gitignore 文件只是 ignore 没有被 staged(cached) 文件，对于已经被 staged 的文件，加入 ignore 文件时一定要先从 staged 移除
```sh
git rm -r --cached .
git add .
git commit -m "update .gitignore"  // windows使用的命令时，需要使用双引号
```



#### 服务器-github代理问题
报错`GnuTLS recv error (-110): The TLS connection was non-properly terminated`

取消代理即可恢复正常，执行下面的命令即可

```
git config --global --unset http.https://github.com.proxy
```

