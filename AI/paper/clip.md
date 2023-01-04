[CLIP 论文逐段精读-bilibili](https://www.bilibili.com/video/BV1SL4y1s7LQ/?share_source=copy_web&vd_source=3ab58fb08fbcf9f90686847c7a48fb05)
[【CLIP系列Paper解读】CLIP: Learning Transferable Visual Models From Natural Language Supervision](https://zhuanlan.zhihu.com/p/486857682)
[paper](https://arxiv.org/pdf/2103.00020.pdf)
[官网](https://openai.com/blog/clip/)

---
一种预训练方法

Contrastive Language-Image Pre-training
对比学习。很灵活，只需要正样本负样本的定义

大数据
大模型

多模态特征。能 zero shot 迁移

训练效率：
- 文本 transformer，图片 cnn。给定一张图片，预测对应文本
- 对比学习。只需要判断图文是否配对，不需要逐词判断文本。效率至少提高4倍

 mixed-precision

![image.png](https://s1.vika.cn/space/2022/12/19/286075db5fee4573bb04fc0c29b2be40)


训练一个模型，可以不再微调应用到下游任务


prompt：提示，主要是在微调和推理的时候使用
需要prompt engineering 和 ensemble 的原因：
- 多义词。所以只用一个词做 prompt 会出现歧义。
- 预训练是句子，所以推理时使用单词可能出现 distribution gap 的问题

prompt template 提示模版 a photo of {label}. 这里也限定了一定是名词。
而且也能加入限定的先验知识。 a type of food 等


linear probe：训练好冻住，只训练一个分类头。参数量很少
fine-tune：需要为不同数据集量身定制参数


## limitation
识别不了 OOD 模型

对比学习 + 生成函数 结合

需要大量数据，数据利用率不高。
- 自监督
- 伪标签

都是web上的图片，可能模型带有社会偏见

语言无法描述的就效果不好

提供样本后，one，two，few shot之后效果反而变差

## 贡献
1. 打破了最大种类标签的限制。更加方便：
	1. 处理数据
	2. 训练模型
	3. 推理
2. 新意度，有效性，问题大小。 

