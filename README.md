# HelloWorld!

> StarWanan's Blog & Life

部署脚本 push.sh

```sh
message=$1

# 更新 master
git add .
git commit -m "$message"
git push -f git@github.com:StarWanan/StarWanan_blog.git master
```
