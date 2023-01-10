# HelloWorld!

<span id="sitetime"></span>


> StarWanan's Blog & Life

本科&研究生专业都是计算机科学与技术的研0人；退役acmer；学过一些神经网络深度学习、计算机视觉，正在学习一些算法智能优化

此处是笔记也是归档，记录所学也方便查看。会不断增加新的学习笔记，也会不定时补充整理之前学过的内容。
如果有想让我补充可以联系我，我有条件有时间就会填坑。
也非常欢迎所有人对本仓库contribution～

欢迎评论、交流、提建议～也可以顺手再右上角去我的github点一个 Star🌟，也可交换[友链](https://starwanan.github.io/)


## 算法
- [算法模板](Algorithm/算法模板.md)
- [算法整理](Algorithm/算法整理.md)
- [AcWing算法课](Algorithm/AcWing算法课.md)

## 课程笔记

- 计算机体系结构
	- [体系结构考点](Course/计算机体系结构/体系结构考点.md)
	- [体系结构作业](Course/计算机体系结构/体系结构作业.md)
- 编译原理
	- [编译原理期末复习](Course/编译原理/编译原理期末复习.md)
	- [编译原理test1](Course/编译原理/编译原理test1.md)
	- [编译原理test2](Course/编译原理/编译原理test2.md)
	- [编译原理test3](Course/编译原理/编译原理test3.md)
	- [编译原理test4](Course/编译原理/编译原理test4.md)
- 嵌入式
	- [嵌入式期末复习](Course/嵌入式/嵌入式期末复习.md)
	- [嵌入式test1](Course/嵌入式/嵌入式test1.md)
	- [嵌入式test2](Course/嵌入式/嵌入式test2.md)
	- [嵌入式test3](Course/嵌入式/嵌入式test3.md)
	- [嵌入式test4](Course/嵌入式/嵌入式test4.md)
- Linux
	- [Linux期末复习](Course/Linux/Linux期末复习.md)
- 操作系统
	- [xv6](Course/操作系统/xv6.md)
	- [操作系统总结复习](Course/操作系统/操作系统总结复习.md)
- 高性能HPC
	- [HPC-大作业](Course/HPC/HPC-大作业.md)
	- [HPCtest1-MPI](Course/HPC/HPCtest1-MPI.md)
	- [HPCtest2-Pthread](Course/HPC/HPCtest2-Pthread.md)
	- [HPCtest3-OpenMP](Course/HPC/HPCtest3-OpenMP.md)
	- [HPCtest4-CUDA](Course/HPC/HPCtest4-CUDA.md)
- [多媒体](Course/多媒体期末复习.md)
- [计算计网络](Course/计算计网络复习.md)
- [神经网络与深度学习](Course/神经网络与深度学习期末复习.md)


## 网站搭建

### 一些想实现的功能
- [ ] ==markdown高亮==
- [x] 【2023.1.10已实现】回到顶部功能
- [x] 【2023.1.7已实现】live2D看板娘
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
