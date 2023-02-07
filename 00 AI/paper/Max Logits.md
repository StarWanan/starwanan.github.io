为真实世界设置扩展分布外检测
提出了Max logits 

---
logit在知识蒸馏[[KD]]里面也提到过


Scaling Out-of-Distrabution

### 解决的问题：

大规模多类异常分割任务中的分布外检测问题。


### 思路来源 & 验证

[[MSP]]缺点：大规模数据集存在问题，对象的确切类别很难确定
改进：最大非归一化logits的负数作为异常分数：
优势：未归一化，不受类数的影响，可作为大规模分布外检测的更好基线

目前方法的不足：会将整个图像划分为异常，而不是检测出异常区域
不足的原因：创造异常数据集时会引入很多干扰因素
贡献：创建新的StreetHazards数据集进行异常分割。

### 实验设置

通常，分类任务涉及预测单个标签，在这些情况下，类是**互斥**的，这意味着分类任务假定输入只属于一个类。
有些分类任务需要预测多个类标签。这意味着类标签或类成员**不是互斥**的。


#### OOD的多类预测

分布内ID数据集：ImageNet-1K、Places365

OOD测试数据集（训练中不可见）：
1. Gaussian：分布为 $N$(0,0.5) ，范围为 $[-1,1]$ 的独立同分布
2. $Rademacher$ ：从 $2 \ \cdotp Bernoulli(0.5) - 1$ 采样的独立同分布 `[-1,1]`
3. Blob examples： 更加结构化
4. Textures：可描述纹理图像组成。
5. LSUN：场景识别数据集
6. Places69：不与Places365共享类的场景分类数据集


MSP
MaxLogit


结果：
模型架构： ResNet-50
1. MaxLogit在 ImageNet-1K 和 Places365 上的所有指标都优于 MSP
2. 小规模 CIFAR-10 设置，MSP 的平均 AUROC 达到 90.08%，MaxLogit 达到 90.22%，相差 0.14%；在大规模设置中，单个 $D_{out}$ 数据集的差异可能超过 10%。

使用MaxLogit作为大规模多类分布外检测的新基线


#### OOD的多标签预测
数据集：PASCAL VOC、MS-COCO

评估：ImageNet-22K中的20个分布外类。（与ImageNet-1K、PASCAL VOC、MS-COCO没有重叠）

多标签分类器在ImageNet-1K上预训练。

方法：
在ImageNet-1K上与训练bakbone：ResNet-101
两个全连接层替换最后一层，sigmoid函数进行多标签预测。
冻结批归一化参数：图像不足，不能进行正确的均值和方差估计。
Adam优化器
epoch：50
$\beta_1$  = $10^{-4}$      $\beta_2$ = $10^{-5}$
数据增强：标准调整大小，随机剪裁，随机反转。`[256,256,3]`
ResNet-101 在 PASCAL VOC 上的 mAP 为 89.11%，MS-COCO 为 72.0%
> AP衡量的是学出来的模型在每个类别上的好坏，mAP是取所有类别AP的平均值，衡量的是在所有类别上的平均好坏程度。

检测器评估
IForest：孤立森林。将空间随即划分为半个空间形成决策树。点与树根的接近程度是分数  [孤立森林算法解释](https://www.jianshu.com/p/5af3c66e0410)
LogitAvg：logit值的平均值
LOF：局部异常因子。计算每个元素与其相邻元素之间的局部密度比。[LOF算法解释](https://www.cnblogs.com/wj-1314/p/14049195.html)
MaxLogit：将logit向量最大值的负数作为异常分数

在多标签logits强制使用softmax会导致MS-COCO上的AUROC下降19.6%


#### 组合异常对象分割（CAOS）基准
数据集：
StreetHazards：模拟提供多样化的、真实插入的异常对象
BDD-Anomaly：不同条件下的真实图像

MSP
Branch：置信度检测器去逐像素预测的直接端口（[9]待了解 #promlem ）
Background：背景类的后验概率作为异常分数（[17]待了解 #promlem ）
Dropout：MC Dropout（[22]待了解 #promlem ）
AE：像素级重建损失作为异常分数（[2,15]待了解 #promlem ）

其他：
ResNet-101。 PSPNet
epoch：20
SGD。动量=0.9
lr = 2e-2。 lr衰减：10e-4

AE：
4层U-Net
epoch：10
批规范化处理


结果：
背景类效果不佳 —— 可能与不常见的类视觉特征不一致
重构方法取得成功，但是AE在CAOS上表现不好 —— 更复杂的领域
AUPR分数很低 —— 大类不平衡导致



Maxlogit在边界处误报的问题没有那么严重：
1. 即使预测置信度在语义边界处下降，最大 logit 在类之间的“切换”过程中也可以保持不变
2. 这提供了一种自然机制对抗语义边界的伪影

基于AE的方法因为它们对输入本身进行建模可以避免在 MaxLogit 和 MSP 行中看到的边界效应。
虽然自动编码器方法在医学异常分割和产品故障检测方面取得了成功，但在更复杂的街景领域无效