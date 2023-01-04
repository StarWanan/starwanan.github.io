原型语义分割的异常检测


### 论文目标：
- 异常分割：分割在训练图像中看不到的异常对象

### 方法来源 & 验证：

原型学习，基于余弦相似度的分类器以**轻量级**方式在训练数据中提取原型

改进思路：
1. 避免训练成本高的生成式模型 
2. 避免依赖GAN的性能，例如受到伪影影响，影响分割效果
3. 余弦相似度 <—— 标准分类层无界性质导致阈值界定困难。（或许可以使用非极大抑制方法 ）


具体实现：
原型表示每个类，是这个类的参考特征向量
通过计算所有像素的特征与原型的相似性得到独立类的置信分数，余弦分类器，通过权重隐式编码类原型

验证：
实验中横向对比模型整体效果
直观展示效果差别（PAnS & MSP）
异常打分器  的比对测试以及消融实验


#### 模型架构
学习函数 $f$ 从图像映射到像素级的异常分数 
1. $\varphi$ 特征提取器-feature extractor：图像到特征空间 —— PSPNet
2. $\rho$ 打分器-scoring function：特征到像素级类别分数 ——  Cosine Classifier，$s_i^c = \rho_c^i(\varphi(x)) = <\varphi_i(x),w_c>$    $\bar{s}_i^c = \displaystyle{\frac{s_i^c + 1}{2}}$
3. $\sigma$ **异常打分器-anomaly score function**：类别分数到最终异常类 —— $\sigma_i(s_i) = 1 - max_{c \in C}\bar{s}_i^c$

[[MSP]]的缺点：平滑对每个像素的置信度，不会直接确定初始分数很高的像素是异常像素
改进方向：
1. 每个类独立
2. 不需要额外计算
3. 有界

损失函数 —— 基于softmax概率的标准交叉熵损失函数：$\ell_{CE}(x,y) = -\displaystyle{\frac{1}{|\mathcal{I}|}} \sum_{i \in \mathcal{I}} log \displaystyle{\frac{e^{\tau s_i^{y_i}}}{\sum_{c \in \mathcal{C}} e^{\tau s_i^c}}}$


### 实验设计：  

backbone： ResNet-50
head module： PSPNet
epoch = 40
bathsize = 2
lr = 0.007
权重衰减 + 学习率衰减
InPlace-ABN：节省GPU内存（ #promlem 待了解）

##### 与先进方法比较
数据集： StreetHazards
（5125训练集,有label + 1031验证集,无异常 + 1500测试集,有异常）

评价指标：（**异常像素是正样例**）
AUPR： Precision-Recall曲线下面积
AUROC： TRP-FPR下面积
FPR95： %95召回率的FPR


MSP 
MSP + CRF
AE
Dropout
SynthCP

FPR95： OOD样本分类正确率在95%时，OOD样本被错分到ID样本中的概率  —— 证明PAnS不易将已知类别划分为异常
AUROC： ROC曲线下面积，随机挑选一个正样本和一个负样本，当前分类算法得到的 Score 将这个正样本排在负样本前面的概率。 —— 识别异常和已知像素保持高置信度。
AUPR： PR曲线下面积 —— 与SynthCP相比，PAnS只需要进行一次前向传递，无需生成步骤，无需增加模型计算量。
而且与SynthCP相比，不依赖生成模型的性能。


##### 定性 —— 余弦分类器 vs MSP：
优点： 能够正确地将低分分配给存在异常的区域。（低分是因为最后的 异常打分器 1-max）
缺点：两者同样的会把边界标注为异常
图像检测中的边界处理可以提取出边界，比如模型拟合（RANSAC、Hough变换等），sift算子特征检测，如果用特征检测出来的图片与分类器输出的结果图片进行叠加，是否有效？


##### 异常评分函数 $\sigma$ 的对比测试：
测量指标：FPR95
数据集：StreetHazards

MSP
Cosine cls + MSP（softmax归一化，但是余弦界定了范围`[-1,1]`）—— 余弦提高了性能
线性分类器非归一化类别分数，Class scores —— 证明不归一化是有力的 （归一化可能使得两种分数相近的都变为0.5，从而得不到异常的高分）
PAnS，非归一化余弦分数

改进支撑：标准分类层分数的无界性质，定义用于检测异常的阈值更加困难



##### 分类器消融研究
已知：PAnS异常分割方面性能优秀       验证：PAnS在普通分割任务性能优秀
评价指标： IoU

结果：大多数类别仍能保持较好性能，极点类（pole category）略有下降。
原因：类别小且很少出现，难以估计出好的原型（权重矩阵学习不到位，可能类似欠拟合）

















