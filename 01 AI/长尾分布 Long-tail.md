欢迎访问 MyBlog: https://starwanan.github.io/#/ 

#AI/Long-tail

## 问题简介

在自然情况下，数据往往都会呈现如下相同的长尾分布。
<img src="https://s1.vika.cn/space/2023/02/15/cb3d3712cf9a458b9b600b03b3a5e8c3" alt="image.png" style="zoom:67%;" />
很少一部分类别拥有大量数据，而很大一部分类别只拥有很少的数据量。比如在做动物分类的问题时，猫狗可以轻松采集到大量数据，但是鹦鹉、雪豹等稀有动物或已灭绝动物的数据却很难采集到。

直接利用长尾数据来训练的分类和识别系统，**往往会对头部数据过拟合，从而在预测时忽略尾部的类别**。

长尾效应主要体现在==有监督==学习里，无监督/自监督学习等因为不依赖标注，所以长尾效应体现的不明显，目前也缺少这方面的研究（但并不代表无监督/自监督学习不受长尾效应的影响，因为图片本身也有分布，常见的图案和罕见的图案也会形成这样的长尾效应，从而使模型对常见的图案更敏感）。

## 技术路线
常见思路：
1. 从数据入手，通过过采样或降采样等手段，使得每个batch内的类别变得更为均衡一些；
2. 从loss入手，经典的做法就是类别$y$的样本loss除以类别出现的频率$p(y)$；
3. 从结果入手，对正常训练完的模型在预测阶段做些调整，更偏向于低频类别，比如正样本远少于负样本，我们可以把预测结果大于0.2（而不是0.5）都视为正样本。

长尾分布的最简单的两类基本方法是重采样(re-sampling)和重加权(re-weighting)。这类方法本质都是利用已知的数据集分布，在学习过程中对数据分布进行暴力的hacking，即反向加权，强化尾部类别的学习，抵消长尾效应。

### 重采样 re-sampling
早期研究中主要包含两种方法：
- 对头部类欠采样(under-sampling)
- 对尾部类过采样(over-sampling)
本质其实都是对不同类别的图片采样频率根据样本数量进行反向加权。所以可以统称为重采样。

其中最常用策略又叫类别均衡采样（class-balanced sampling）。类别均衡的概念主要是区别于传统学习过程中的样本均衡（instance-balanced sampling），也就是每个图片都有相同的概率被选中，不论其类别。而类别均衡采样的核心就是根据不同类别的样本数量，对每个图片的采样频率进行加权。

**采样策略:**

引用[Decoupling Representation and Classifier for Long-Tailed Recognition(ICLR 2020)](https://arxiv.org/pdf/1910.09217v2)的通用公式来表示:
$$
𝑝_𝑗=\frac{𝑛^𝑞_𝑗}{\sum^𝐶_{𝑖=1}𝑛^𝑞_𝑗}
$$
- p_j: 从类别j 中采样一个数据的概率
- $n_j$: 第j 类的样本数量
- $C$: 训练类别数量
- $q \in [0, 1]$
	- instance-balanced sampling, q = 1, 每张图都有相等概率被采样
	- Class-balanced sampling, q = 0, $p_j^{CB} = \frac{1}{C}$, 每类都有相等的概率被采样
	- Square-root sampling, q = 1/2, 一些变体
	在 $q \in [0,1)$ 的时候，尾部类别的样本图片会比头部类别有更高的概率被采样到。q = 0 就是类别均衡采样，所有的类别采样相同数量的样本。但是尾部类别会被反复采样，所以一般情况下会做数据增强，比如反转，随机裁剪

重采样就是在已有数据不均衡的情况下，人为的让模型学习时接触到的训练样本是类别均衡的，从而一定程度上减少对头部数据的过拟合。
- 尾部的少量数据往往被反复学习，缺少足够多的样本差异，不够鲁棒
- 头部拥有足够差异的大量数据又往往得不到充分学习


### 重加权 re-weighting
重加权主要体现在分类的loss上。loss计算比采样更加灵活方便。
- 基于类别分布的反向加权
- 不需要知道类别，直接根据分类的可信度进行的困难样本挖掘(Hard Example Mining), 如focal loss。 

Re-weighted Cross-Entropy Loss 的通用公式：
$$
loss = -\beta \cdot log\dfrac{exp(z_j)}{\sum^C_{i=1}exp(z_i)}
$$
- $z_i$: 网络输出的 logits
- $\beta$: 重加权的权重。
	- 不是常数，是一个取决于具体实现的经过计算的权重，一般趋势是==给头部类别低权重，给尾部类别高权重==，反向抵消长尾效应
	- 一般形式的简单实现形式为 $\beta=g(\dfrac{\sum^C_{i=1}f(n_i)}{f(n_j)})$, $f(\cdot), g(\cdot)$ 可以是任意单调递增函数，比如 log 或者各种幂大于0的指数函数






## 论文调研
### 重采样
**Decoupling Representation and Classifier for Long-Tailed Recognition** _ICLR 2020_

论文：[Decoupling Representation and Classifier for Long-Tailed Recognition, ICLR 2020](https://arxiv.org/pdf/1910.09217)

代码：[https://github.com/facebookresearch/classifier-balancing](https://github.com/facebookresearch/classifier-balancing)

这篇文章应该是目前长尾图片分类领域的SOTA了。**该文章和下面的BBN共同发现了一个长尾分类研究的经验性规律：**

> **规律1: 对任何不均衡分类数据集地再平衡本质都应该只是对分类器地再均衡，而不应该用类别的分布改变特征学习时图片特征的分布，或者说图片特征的分布和类别标注的分布，本质上是不耦合的。**

基于这个规律，Decoupling和BBN提出了两种不同的解决方案，Decoupling的方案更简单，实验更丰富

Decoupling将长尾分类模型的学习分为了两步:
1. 先不作任何再均衡，而是直接像传统的分类一样，利用原始数据学习一个分类模型（包含特征提取的backbone + 一个全连接分类器）
2. 将第一步学习的模型中的特征提取backbone的参数固定（不再学习），然后单独接上一个分类器（可以是不同于第一步的分类器），对分类器进行class-balanced sampling学习。
此外作者还发现全连接分类器的weight的norm和对应类别的样本数正相关，也就是说样本数越多的类，weight的模更大，也就导致最终分类时大类的分数（logits）更高（对头部类的过拟合）。

所以第二步的分类器为归一化分类器，文章中有两种较好的设计：
1. $\bar{𝑤}_𝑖=\dfrac{𝑤_𝑖}{‖𝑤𝑖‖^𝑇}$
2. $\bar{𝑤}_𝑖=\dfrac{𝑤_𝑖}{𝑓_𝑖}$
其中2利用了fixed第一步分类权重$w_i$，对每个类学习了一个加权参数$f_i$。

Decoupling的核心在于图片特征的分布和类别分布其实不耦合，所以学习backbone的特征提取时不应该用类别的分布去重采样（re-sampling），而应该直接利用原始的数据分布。

#todo BN?  采样fintune 

---
**Bilateral-Branch Network with Cumulative Learning for Long-Tailed Visual Recognition** _CVPR 2020_

论文：[Bilateral-Branch Network with Cumulative Learning for Long-Tailed Visual Recognition，CVPR 2020](https://arxiv.org/pdf/1912.02413.pdf)
代码：[https://github.com/Megvii-Nanjing/BBN](https://github.com/Megvii-Nanjing/BBN)

BBN的核心idea和Decoupling其实是一样的。正因为两个人同时发现了同样的规律，更证明了这个规律的通用性和可靠性。关于上文的规律，BBN做了更详细的分析：

![](https://s1.vika.cn/space/2023/02/17/97025419abff46c5b19ba71b8cd0ab16)


这个图说明，长尾分类的最佳组合来自于：利用Cross-Entropy Loss和原始数据学出来的backbone + 利用Re-sampling学出来的分类器。

和Decoupling的区别在于，BBN将模型两步的学习步骤合并至一个双分支模型。该模型的双分支共享参数，一个分支利用原始数据学习，另一个分支利用重采样学习，然后对这两个分支进行动态加权(𝛼 𝑣𝑠.(1−𝛼))。这样随着权重𝛼的改变，就实现了自然而然地从stage-one到state-two的过度。

![](https://s1.vika.cn/space/2023/02/17/1bbc1295b048463382fe5460edb54e7d)



### 重加权

**Remix: Rebalanced Mixup** _Arxiv Preprint 2020_

链接：[https://arxiv.org/abs/2007.03943](https://link.zhihu.com/?target=https%3A//arxiv.org/abs/2007.03943)

Mixup是一个这两年常用的数据增强方法，简单来说就是对两个sample的input image和one-hot label做线性插值，得到一个新数据。实现起来看似简单，但是却非常有效，因为他自带一个很强的约束，就是样本之间的差异变化是线性的，从而优化了特征学习和分类边界。

而Remix其实就是将类别插值的时候，往少样本类的方向偏移了一点，给小样本更大的 λy 。

![image.png](https://s1.vika.cn/space/2023/02/17/f1bb3acbabcd4550bab43b5dfa525e2b)



#todo remix




---
**Class-Balanced Loss Based on Effective Number of Samples** _CVPR 2019_

链接：[https://arxiv.org/abs/1901.05555](https://link.zhihu.com/?target=https%3A//arxiv.org/abs/1901.05555)

代码：[https://github.com/richardaecn/class-balanced-loss](https://link.zhihu.com/?target=https%3A//github.com/richardaecn/class-balanced-loss)

这篇文章的核心理念在于，随着样本数量的增加，每个样本带来的收益是显著递减的。所以作者通过理论推导，得到了一个更优的重加权权重的设计，从而取得更好的长尾分类效果。

实现上，该方法在Cross-Entropy Loss中对图片根据所属类给予 1/En 的权重，其中 En=(1−βn)/(1−β) 代表有效样本数， β=(N−1)/N ， n 是类别总样本， N 则可以看作类别的唯一原型数（unique prototypes）。

#todo 尺度问题。学习率-loss。 权重倍数归“一”化 权重设置上下限
#todo rare类删掉（<5 pic）

---
**Long-tail learning via logit adjustment** _ICLR 2021_
- [[Long-tail learning via logit adjustment.pdf]] 
- [[Long-tail learning via logit adjustment-ppt.pdf]]

**(1) 建模思路**

断定一个分类问题是否不均衡：一般的思路是从整个训练集里边统计出各个类别的频率$p(y)$，然后发现$p(y)$集中在某几个类别中。所以，解决类别不平衡问题的重点，就是如何把这个先验知识$p(y)$融入模型之中。

相比拟合条件概率，如果模型能直接拟合[[互信息 Mutual Information]]，那么将会学习到更本质的知识，因为互信息才是揭示核心关联的指标。但是拟合互信息没那么容易训练，容易训练的是条件概率，直接用交叉熵 $−log⁡\ p_θ(y|x)$ 进行训练就行了。所以，一个比较理想的想法就是：==如何使得模型依然使用交叉熵为loss，但本质上是在拟合互信息？==

原本条件概率模型：
$$
p_\theta(y|x)=\dfrac{exp(f_y(x;\theta))}{\sum_{i=1}^{K}exp(f_i(x;\theta)} \tag1
$$
改为建模互信息, 也就是希望：
$$
log\dfrac{p_\theta(y|x)}{p(y)} \sim f_y(x;\theta) \Leftrightarrow log\ p_\theta(y|x) \sim f_y(x;\theta) + log\ p(y) \tag2
$$
将右端进行softmax归一化，则有：$p_\theta(y|x)=\frac{exp(f_y(x;\theta)+log\ p(y))}{\sum_{i=1}^{K}exp(f_i(x;\theta)+ log\ p(i))}$, 写成loss形式：
$$
-log\ p_\theta(y|x) = -log\dfrac{exp(f_y(x;\theta)+log\ p(y))}{\sum_{i=1}^{K}exp(f_i(x;\theta)+ log\ p(i))} = log \left[ 1 + \sum_{i\ne y}\dfrac{p(i)}{p(y)}exp(f_i(x;\theta)-f_y(x;\theta)) \right] \tag3
$$
原论文称之为==logit adjustment loss==。如果更加一般化，那么还可以加个调节因子$τ$：
$$
-log\ p_\theta(y|x) = -log\dfrac{exp(f_y(x;\theta)+τ\ log\ p(y))}{\sum_{i=1}^{K}exp(f_i(x;\theta)+ τ\ log\ p(i))} = log \left[ 1 + \sum_{i\ne y}\left(\dfrac{p(i)}{p(y)}\right)^τexp(f_i(x;\theta)-f_y(x;\theta)) \right] \tag4
$$

一般情况下，$τ=1$的效果就已经接近最优了。如果$f_y(x;θ)$的最后一层有bias项的话，那么最简单的实现方式就是将bias项初始化为$τlog\ p(y)$。也可以写在损失函数中：
```python
import numpy as np
import keras.backend as K


def categorical_crossentropy_with_prior(y_true, y_pred, tau=1.0):
    """带先验分布的交叉熵
    注：y_pred不用加softmax
    """
    prior = xxxxxx  # 自己定义好prior，shape为[num_classes]
    log_prior = K.constant(np.log(prior + 1e-8))
    for _ in range(K.ndim(y_pred) - 1):
        log_prior = K.expand_dims(log_prior, 0)
    y_pred = y_pred + tau * log_prior
    return K.categorical_crossentropy(y_true, y_pred, from_logits=True)


def sparse_categorical_crossentropy_with_prior(y_true, y_pred, tau=1.0):
    """带先验分布的稀疏交叉熵
    注：y_pred不用加softmax
    """
    prior = xxxxxx  # 自己定义好prior，shape为[num_classes]
    log_prior = K.constant(np.log(prior + 1e-8))
    for _ in range(K.ndim(y_pred) - 1):
        log_prior = K.expand_dims(log_prior, 0)
    y_pred = y_pred + tau * log_prior
    return K.sparse_categorical_crossentropy(y_true, y_pred, from_logits=True)
```
可能会出现错误：
```
NotImplementedError: Cannot convert a symbolic Tensor (categorical_crossentropy_with_prior/add:0) to a numpy array. This error may indicate that you're trying to pass a Tensor to a NumPy call, which is not supported
```
可以尝试把1e-8去掉，不出现nan就没有影响。


**(2)结果分析**

logit adjustment loss也属于调整loss方案之一，不同的是它是在loglog里边调整权重，而常规的思路则是在loglog外调整。至于它的好处，就是互信息的好处：互信息揭示了真正重要的关联，所以给logits补上先验分布的bias，能让模型做到“==能靠先验解决的就靠先验解决，先验解决不了的本质部分才由模型解决==”。




---

参考文章：
> [Long tailed 长尾分布论文汇总 - CSDN](https://blog.csdn.net/adf1179/article/details/115691708) 本文汇总了2019-2021年在计算机视觉和文本分类方面的论文
> [Long-Tailed Classification - cnblog](https://www.cnblogs.com/fusheng-rextimmy/p/15389065.html) 本文介绍了2019-2020年论文、总结了技术路线，并提出了新的方法
> [计算机视觉中的长尾分布问题还值得做吗 - zhihu](https://zhuanlan.zhihu.com/p/548735583) 本文介绍22年的研究现状
> [ICLR2020 | Decoupling representation and classifier for long-tailed recognition](https://zhuanlan.zhihu.com/p/452668798) 论文分析
> [通过互信息思想来缓解类别不平衡问题 - 苏剑林](https://kexue.fm/archives/7615#how_to_cite) IID类间长尾分类问题建模, 有关Long-tail learing via logit adjustment
> [longtail论文笔记 - zhihu](https://zhuanlan.zhihu.com/p/403981340)
> [Long-Tail Learning via Logit Adjustment - CSDN](https://blog.csdn.net/QKK612501/article/details/126880798) 论文评析 
> 

