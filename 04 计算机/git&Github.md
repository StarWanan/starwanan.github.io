### git命令
clone
```sh
git clone [-b 分支] https://xxx.git
```



### github拉取代码


报错`GnuTLS recv error (-110): The TLS connection was non-properly terminated`

取消代理即可恢复正常，执行下面的命令即可

```
git config --global --unset http.https://github.com.proxy
```



### github 的一些报错
```sh
git push -f git@github.com:StarWanan/P-Center.git master
error: src refspec master does not match any
```

由于github的分支名称已经从master --> main，所以代码应该改成：
```sh
git push -f git@github.com:StarWanan/P-Center.git main
```

