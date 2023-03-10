我认为[[01 AI/lib/异常分割]]和OOD检测是非常相近的两个东西。

**是什么：**
out-of-distribution 分布外检测

模型遇到和训练数据差别很大的数据的时候，会出现 OOD uncertainty。
识别出OOD数据非常重要，ex：异常检测、对抗样本

OOD样本是相对于 In-Distribution(ID)样本的概念


**怎么做：**

[OOD综述链接——知乎](https://zhuanlan.zhihu.com/p/102870562)

改进方法1：《Energy-based Out-of-distribution Detection》不改变模型结构，在任意模型上用能量函数代替softmax函数，识别输入数据是否为异常样本。

[博文链接：能量场改进OOD](https://blog.csdn.net/yanguang1470/article/details/122624493)


