message=$1

# 更新 master
git add .
git commit -m "$message"
# Github
git push git@github.com:StarWanan/starwanan.github.io.git master
# Gitee
git push git@gitee.com:zyxstar/starwanan.github.io.git master