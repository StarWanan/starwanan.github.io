[从最优化的角度看待Softmax损失函数](https://zhuanlan.zhihu.com/p/45014864)
[Softmax理解之二分类与多分类](https://zhuanlan.zhihu.com/p/45368976)
[Softmax理解之Smooth程度控制](https://zhuanlan.zhihu.com/p/49939159)
[Label Smoothing分析](https://zhuanlan.zhihu.com/p/302843504)

---

## softmax 损失

### 优化目标

假设有 C 类，input --> f(x) --> C个分数

|   1  |  2   |  ...   |  C   | 
| --- | --- | --- | --- |

假设这个 input 的 ground-truth label 为 2，那么 2 的分数就最大

==优化目标：使目标分数 > 其他分数==
$z = f(x) \in R^C$ 是最终输出的向量,  $y \in [1,C]$ 为真值标签的序号，所以优化目标是：

$$
\forall j \ne y, z_y > z_j  
$$
希望： $z_y$ 升高，$z_j$ 下降
梯度下降：$z_y$ 需要一个**负**梯度，$z_j$ 需要一个**正**梯度
$$
\mathcal{L} = \sum_{i=1,i \ne y}^{C} max(z_i - z_y, 0)
$$
这样如果 $z_i$ 更大，就会得到一个正梯度，从而通过梯度下降而变小

为了提高模型泛化能力，借助 svm 的 margin 概念加入一个间隔，让 $z_y$ 要超过其他分数更多：
$$
\mathcal{L} = \sum_{i=1,i \ne y}^{C} max(z_i - z_y + m, 0)
$$

但是如果类别数 C 特别大时，会有**大量的非目标分数**得到优化，这样每次优化时的梯度幅度不等且非常巨大，极易梯度爆炸。
==优化目标：使目标分数 > **最大的**非目标分数==
$$
\mathcal{L} = max(max_{i \ne j}\{z_i\} - z_y, 0)
$$
优化这个损失函数时，每次最多只会有一个+1的梯度和一个-1的梯度进入网络，梯度幅度得到了限制。但这样修改每次优化的分数过少，会使得网络收敛极其缓慢。
> 为什么+1/-1？不会更大吗？还是因为是梯度的问题？


### smooth

| 函数    | smooth版本 | 输出 |
| ------- | ---------- | ---- |
| one-hot | softmax    | 向量 |
| max     | LogSumExp  | 值   |
| ReLU: max(x, 0)        | softplus           |      |

$$
\mathcal{L}_{lse} = max(log(\sum_{i=1, i \ne y}^{C}e^{z_i}) - z_y, 0)
$$

LogSumExp 的导数就是 softmax 函数：
$$
\dfrac{\partial \ log(\sum_{i=1, i \ne y}^{C}e^{z_i})}{\partial z_j} = \dfrac{e^{z_j}}{\sum_{i=1, i \ne y}^{C}e^{z_i}}
$$
给予非目标分数的1的梯度将会通过LogSumExp函数传播给所有的非目标分数，各个非目标分数得到的梯度是通过softmax函数进行分配的，较大的非目标分数会得到更大的梯度使其更快地下降。这些非目标分数的梯度总和为1，目标分数得到的梯度为-1，总和为0，绝对值和为2，这样我们就有效地限制住了梯度的总幅度。

LogSumExp函数值是大于等于max函数值，等于取到的条件非常苛刻，相当于加了一定的 m，但是还不够。所以有两种办法：
1. 效仿 hinge loss，添加一个 m
2. softmax 交叉熵损失，继续 smooth

ReLU函数 $max(x,0)$ 也有一个smooth版，即softplus函数：$log(1+e^x)$  
使用softplus函数之后，即使 $z_y$ 超过了 LogSumExp 函数，仍会得到一点点梯度让 $z_y$ 继续上升，这样其实也是变相地又增加了一点 m ，使得泛化性能有了一定的保障.

所以原来的 $max(log(\sum_{i=1, i \ne y}^{C}e^{z_i}) - z_y, 0)$ 就可以替换成：
$$
\begin{aligned}
\mathcal{L}_{softmax} &= log(1 + e^{log(\sum_{i=1, i \ne y}^{C}e^{z_i}) - z_y}) \\
&= log(1 + \frac{log(\sum_{i=1, i \ne y}^{C}e^{z_i})}{e^{z_y}}) \\
&= log(\frac{\sum_{i=1}^{C}e^{z_i}}{e^{z_y}}) \\
&= -log \frac{e^{z_y}}{\sum_{i=1}^{C}e^{z_i}}
\end{aligned}
$$
这个形式就是 ==softmax 交叉熵损失函数==。优点：
- 优化顺畅
- 引入类间间隔，提升泛化性能


优化目标可以改得更加简洁：==通过网络输出 C 个分数，使得目标分数最大。==
也就是说：$z_y = max\{z_i\}$
所以对应的损失函数是：
$$
\mathcal{L} = max\{z_i\} - z_y
$$
当 $z_y$ 恰好是 $z$ 中最大的元素时，损失函数为0；
当某非目标分数 $z_i$ 大于目标分数 $z_y$ 时，就产生了一个正的损失.
同样，通过 LogSumExp 可以转化成 Softmax 交叉熵损失。


从 smooth 控制的角度，观察 Softmax 交叉熵损失的缺点：
Softmax 交叉熵损失在输入的分数较小的情况下，并不能很好地近似我们的目标函数。
在使用 LSE(z) 对 max{z} 进行替换时， LSE(z) 将会远大于 max{z} ，不论 $z_y$ 是不是最大的，都会产生巨大的损失。
稍高的 LSE(z) 可以在类间引入一定的间隔，从而提升模型的泛化能力。但过大的间隔同样是不利于分类模型的，这样训练出来的模型必然结果不理想。
所以， z 的幅度既不能过大、也不能过小：
- 过小会导致近对目标函数近似效果不佳的问题；
- 过大则会使类间的间隔趋近于0，影响泛化性能。

解决方案：
- 温度项 T
- Feature Incay
- 将特征和权重归一化，这样 z 就从特征与权重的内积变成了特征与权重的余弦\[-1, 1\], z 的幅度大致确定。再乘**尺度因子 s** 保证分数在合理范围

总结：稍大的  z  幅度可以产生一定的间隔，但这个间隔毕竟也只是 smooth 化赠送的，很难控制其大小

### 手动控制类间间隔
对于有间隔项的损失函数
$$
\mathcal{L} = \sum_{i=1,i \ne y}^{C} max(z_i - z_y + m, 0)
$$
如果不限制分数 z 的取值范围，那网络会自动优化使得分数 z 整体取值都非常大，m 相对变小。
所以需要归一化，让分数 z 由余弦层后接一个尺度因子 s 来得到。这样我们就可以手动控制分数 z 的取值范围，以方便设置参数 m。
所以损失函数变为：
$$
\mathcal{L} = max(max_{i \ne y} \{sz_i\} - sz_y + sm, 0)
$$
损失函数再经过 smooth 约等于：
$$
\begin{aligned}
\mathcal{L} &= Softplus(LSE(sz_i;i \ne y)-s(z_y - m)) \\
&= -log(\dfrac{e^{s(z_y - m)}}{e^{s(z_y - m)} + \sum_{i \ne y}e^{sz_i}})
\end{aligned}
$$
所以这里是==带有加性间隔的 Softmax 交叉熵损失函数==

损失函数中有两个参数，一个  **s**  一个 **m**
s 的设置参照第三篇文章，其实只要超过一定的阈值就可以了，一般来说需要设置一个最小值，然后让 s 按照正常的神经网络参数的更新方式来更新。
对于 m 的设置目前还需要手动调节