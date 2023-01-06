# HelloWorld!

> StarWanan's Blog & Life

部署脚本 push.sh

```sh
message=$1

# 更新 master
git add .
git commit -m "$message"
git push -f git@github.com:StarWanan/starwanan.github.io.git master
```

一些未实现的功能：

==markdown高亮==

- [x] 行内公式 $L_y = \sum_{i=1}^N x_i$
- [x] 行间公式
$$
L_y = \sum_{i=1}^N x_i
$$
