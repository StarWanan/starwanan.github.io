
<br>

<span id="busuanzi_container_site_pv" style='display:none'>
    👀 本站总访问量：<span id="busuanzi_value_site_pv"></span> 次
</span>
<span id="busuanzi_container_site_uv" style='display:none'>
    | 🚴‍♂️ 本站总访客数：<span id="busuanzi_value_site_uv"></span> 人
</span>

<br>


# HelloWorld!

> StarWanan's Blog & Life



### 一些未实现的功能
- [x] live2D看板娘
- [ ] ==markdown高亮==
- [x] 【2023.1.6已实现】行内公式 $L_y = \sum_{i=1}^N x_i$  
- [x] 【2023.1.6已实现】行间公式 
$$
L_y = \sum_{i=1}^N x_i
$$

### 部署脚本 
push.sh
```sh
message=$1

# 更新 master
git add .
git commit -m "$message"
git push -f git@github.com:StarWanan/starwanan.github.io.git master
```

### 本站搭建过程

美化与部分功能参考：https://blog.csdn.net/wugenqiang/article/details/107071378
