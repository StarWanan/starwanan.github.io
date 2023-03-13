# Hello World!
<span id="sitetime"></span>

> StarWanan's Blog & Life

本科&研究生专业都是计算机科学与技术的研0人；退役acmer；学过一些神经网络深度学习、计算机视觉，正在学习一些算法智能优化。

此处是笔记也是归档，记录所学也方便查看。会不断增加新的学习笔记，也会不定时补充整理之前学过的内容。
如果有想让我补充可以联系我，我有条件有时间就会填坑。
也非常欢迎所有人对本仓库contribution～不熟悉的同学可以参考下面的**CONTRIBUTION章节**。

欢迎评论、交流、提建议～也可以顺手再右上角去我的github点一个 Star🌟，也可交换[友链](https://starwanan.github.io/)

仓库同步在[Gitee](https://gitee.com/zyxstar/starwanan.github.io)更新, 由于Gitee审核问题，没有部署Gitee Page。

## 笔记导航
[Knowledge Library](MyNotes/Knowledge%20Library.md)


## 贡献CONTRIBUTION
非常欢迎任何人的贡献，接受pull requests，欢迎大家 star & fork！

熟悉 Github Pull requests 的同学可以直接把自己笔记添加了后 PR 给我们，记得保证版本与我的仓库一致（也就是说提交到远程前先pull同步一下）。
对于不熟悉PR的同学可以查阅[第一次参与开源](https://github.com/firstcontributions/first-contributions/blob/main/translations/README.zh-cn.md) 中的内容。

有其他问题、建议、想法，都非常欢迎进行 PR 和 Issue


## 网站搭建

**一些想实现的功能**
- [ ] 内嵌文件
- [ ] ==markdown高亮==
- [x] 【2023.1.10已实现】回到顶部功能
- [x] 【2023.1.7已实现】live2D看板娘
- [x] 【2023.1.6已实现】行内公式 $L_y = \sum_{i=1}^N x_i$  
- [x] 【2023.1.6已实现】行间公式 
$$
L_y = \sum_{i=1}^N x_i
$$


**本站搭建过程**

美化与部分功能参考： https://blog.csdn.net/wugenqiang/article/details/107071378



**部署脚本** 
```sh
message=$1

# 更新 master
git add .
git commit -m "$message"
# Github
git push -f git@github.com:StarWanan/starwanan.github.io.git master
# Gitee
git push -f git@gitee.com:zyxstar/starwanan.github.io.git master
```
