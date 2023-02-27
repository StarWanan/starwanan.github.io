### git常用命令
clone
```sh
git clone [-b 分支] https://xxx.git
```




### 一些问题
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

