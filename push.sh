message=$1

# 更新 master
git add .
git commit -m "$message"
git push -f git@github.com:StarWanan/starwanan.github.io.git master