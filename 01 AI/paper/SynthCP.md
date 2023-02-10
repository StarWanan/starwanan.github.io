合成后比较



#### 解决的问题：

- 异常分割：分隔在训练图像中看不到的异常对象
- 实际上是**错误检测**，对象错误分类【注意不能完全依靠翻译软件，还需要结合文意和给出的示意图】
- ~~故障检测：是在训练图像中看到的对象，但是出现了故障~~ 
> 故障具体是指？是这个对象但是不对劲？出了故障？或者出现在了错误的位置？比如飞机出现在路上

#### 方法思路 & 来源 & 验证：
##### 思路：
原始图像 $x$，语义分割模型 $M$，分割后的语义信息预测图 $\hat{y}$ 
$\hat{y}$ 作为输入送入 $cGAN$ 合成图像 $\hat{x}$ 
$x$  和 $\hat{x}$ 送入比较模块进行比较，输出 $\hat{c}$ 作为比较结果。
GAN生成器G的优化不能保证生成图像与原始图像风格相同，所以不能用 $L1$ 距离简单的相似性测量。
两个任务设计了两个不同的比较模块 $F$

故障检测$\hat{c}$：
- $\hat{c}_{iu}$ ：预测的分割结果与“真值”的在当前图像上存在的类别的交并比【$L$】
- $\hat{c}_{m}$ ：定位到预测错误区域的error map【$h \times w$】

异常分割 $\hat{c}$ ：对于异常目标的分割图【$h \times w$】



#### 实验设计：
评估指标：
图像级：IoU —— MAE、STD、P.C.、S.C.
像素级：AUPR-Error、AUPR-Success、FPR95、AUROC

数据集：Cityscape数据集上验证SyntnCP

Direct Prediction：直接使用网络预测图像级和像素级故障。   （共享实验设置，可看作对 $\hat{x}$ 的消融实验）

实验过程：
1. cGAN SPADE定义好超参数之后从头开始训练，仅使用语义分割图作为输入。
2. backbone：ImageNet预训练的ResNet-18
3. Adam优化器  初始学习0.01.    $\beta = (00.9, 0.999)$
4. 20k次迭代

使用网络预测故障 —— 需要为网络生成训练数据
原始训练集划分为训练子集和验证子集，在训练子集上训练**分割模型**并在验证子集上进行测试。
验证子集上的测试结果可用于训练**故障预测器**。

训练集进行4折交叉验证

交叉验证的结果涵盖了原始训练集中的所有样本，能够生成足够的训练数据训练故障预测网络。



结果：
分割模型：FCN8、Deeplab-v2

图像级：
1. VAE alarm不能很好地展现街道场景的2D图像 —— VAE重建中很容易遗漏小的物体。
2. 如果没有来自分割结果的合成图像， Direct Prediction的结果比SynthCP差

像素级：
1. SynthCP的误报区域比Direct Prediction略多（FPR95） —— 可能是生成模型没有正确合成一些正确分割的区域




---

基线方法:
1. MSP [17]
2. MSP+CRF [16]
3. Dropout [10] 
4. 基于自动编码器 (AE) 的方法 [2]

除了 AE，所有其他三种方法都需要一个分割模型来提供 softmax 概率或不确定性估计。 
AE 是唯一需要对图像的自动编码器进行额外训练并计算像素级  $\ell_1$ 损失以进行异常分割的方法。

实施细节:
使用两个网络主干作为分割模型：ResNet-101 [15] 和 PSPNet [50]。 
cGAN 也使用与第 3.2 节中相同的训练策略进行了 SPADE [43] 训练。 
选择后处理阈值 t = 0.999 以获得更好的 AUPR，并在以下段落中详细讨论。

结果：SynthCP 将之前最先进的方法 MSP+CRF 在 AUPR 方面从 6.5% 提高到 9.3%。

研究 MSP 后处理对 SynthCP 的贡献，对不同的后处理阈值 t 进行实验:
1. 在没有后处理（t = 1.0）的情况下，SynthCP 实现了更高的 AUPR，但也产生了更多的误报，导致 FPR95 和 AUROC 降级。 
2. 在去除高 MSP 位置的误报后（$p^{(i)} > 0.999$），我们在所有三个指标下都实现了最先进的性能

---




##### 比较模块的具体设计：

###### 故障检测：
孪生网络比较合成图像与原始图像的差别。这里使用的是ResNet-18。输出image-level 和 pixel-level的置信度
> 孪生网络（siamese network）：网络结构相同，参数共享的两个网络

训练阶段网络的监督方法：
1. 预测IoU， $c_{iu}$ ：
训练阶段输入的图像有真值，所以可以计算预测图与真值的每个类别的IoU，即$c_{iu}$ ：
$$
c^{(l)}_{iu} = \frac{\lbrace i|\hat{y}^{(i)}=l\rbrace \cap \lbrace i|y^{(i)}=l \rbrace}{\lbrace i|\hat{y}^{(i)}=l\rbrace \cup \lbrace i|y^{(i)}=l \rbrace}
$$
 $l$代表其中第 $l$ 类。$i$ 代表第 $i$ 个像素。以其为监督信息，$1 Loss$ 未损失函数监督网络训练。训练好的网络就可以去预测 $c_{iu}$


2. 预测error map， $c_m$：
训练中有真值 $y$ 可以计算出真正的error map，即 $c_m$:
$$
c_m^{(i)} =
\begin{cases}
1 \quad if \ y^{(i)} \ne \hat{y}^{(i)} \\
0 \quad if \ y^{(i)} = \hat{y}^{(i)}
\end{cases}
$$
以此为监督信息，使用二元交叉熵损失函数去监督网络训练。这样训练好的网络可以去预测 $c_m$

以上两个损失函数可以写为：
$$
\mathcal{L} = \frac{1}{|\mathbb{L}|} \sum_l^{|\mathbb{L}|} \mathcal{L}_{\ell_1}(c_{iu}^{(l)},\hat{c}_{iu}^{(l)}) + \frac{1}{wh} \sum_i^{wh} \mathcal{L}_{ce}(c_m^{(i)},\hat{c}_m^{(i)})
$$


###### 异常分割：
语义分割后的东西都是根据已经有的标签进行标注，不会出现外分布对象。以此为基础通过cGAN生成的图像也不会含有外分布对象。
语义分割后的预测图 $\hat{y}$ 中只包含了给定类别，所以生成的图像 $\hat{x}$ 应该也只包含了给定类别，所以其与 $x$ 的差别很大，再送入 $M$ 时， $M$ 最后一层提取的特征也会有很大差别，这里用**余弦距离**作为指标衡量特征差异
$$
\hat{c}_n^{(i)} = F(x,\hat{x};M) = 1 - <\frac{f^i_M(x)}{||f^i_M(x)||_2}, \frac{f^i_M(\hat{x})}{||f^i_M(\hat{x})||_2}>
$$




##### 思考

GAN中不加噪声减少泛化能力？但是会不会影响图像质量？伪影问题可不可以使用更好的GAN模型进行替换？ 

比如CIPS条件独立像素生成模型对伪影有很大改善，并且是基于像素的，生成器的input就是每个像素点分割属于哪一个类别，这样的效果会不会更好
但是CIPS本身模型的经典问题之一就是会产生异常（LekyReLu的分割区域影响，换激活函数或许可以尝试）

semantic-to-image 和 text-to-image使用的GAN是否相同，是否能达到一样的效果？



