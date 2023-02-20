相关度：两个量真实碰面的概率是它们随机相遇的概率的多少倍。$\dfrac{P(w_1,w_2)}{P(w_1)P(w_2)}=\dfrac{P(w_2|w_1)}{P(w_2)}$ 
- 如果它远远大于1，那么表明它们倾向于共同出现而不是随机组合的
- 如果它远远小于1，那就意味着它们俩是刻意回避对方的。

点互信息（Pointwise Mutual Information，PMI）是相关度的对数值：$PMI(w1,w2)=log\dfrac{P(w_1,w_2)}{P(w_1)P(w_2)}$

两个多元变量的相关度，等于它们两两单变量的相关度的乘积。
$$
PMI(Q,A) = \sum_{i=1}^k \sum_{j=1}^l PMI(q_i,a_j)
$$

参考文章：
> [从条件概率到互信息 - 苏剑林](https://spaces.ac.cn/archives/4669) 互信息的一些推导与解释
> [互信息（Mutual Information）介绍 - CSDN](https://blog.csdn.net/luoxuexiong/article/details/113059152) 

