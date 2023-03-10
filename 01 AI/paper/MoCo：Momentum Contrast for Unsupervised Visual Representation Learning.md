# 用于无监督视觉表征学习的动量对比学习
#AI/Transformer #AI/Contrastive 

MoCo是基于[[01 AI/lib/对比学习]]和[[01 AI/paper/Transformer]]的改进工作。

## Abstract
动量： $y_t = m \cdot y_{t-1} + (1-m) \cdot x_t$  使得当前输出不仅仅依靠输入。

用动态字典的角度去看对比学习。动态字典由两部分组成：
- 队列：这里样本不需要梯度回传，放很多负样本
- 移动平均的编码器：保证特征基本一致

而大量的特征基本一致的负样本，会使得对比学习结果变好


结果：
- 分类：linear protocol 在 ImageNet 上的结果。
- ==MoCO 训练的结果能很好的迁移到下游任务上。==
- 无监督的方法基本上都超越了有监督模型。
这代表视觉任务上，有监督和无监督之间的gap被填补上了。


## Instruction
无监督学习在 nlp 上的表现好，而在视觉上的表现仍然一般
- nlp：离散空间，tokenized 很好被建模，类似一个 label 帮助学习，像有监督
- vision：连续高维的视觉空间，不易建模


### 动态字典
MoCo这篇文章，将之前工作的[[01 AI/lib/对比学习]]方法归纳成了一个[[动态字典]]问题。将query和key中的某一个距离最小化即可
![[_Canvas/动态字典.canvas]]

在这个角度来看，想让结果更好，字典应该有两个特征：
1. 大：能更好的从连续的高维的视觉空间抽样。key越多，能表示的视觉信息、视觉特征越丰富。key和query对比时就更有可能学到能把物体区分开的、本质的特征。而不是在少量数据下学习到的捷径shortcut solution，没有泛化性。
2. 尽可能一致性。所有的key应该使用相同或者相似的编码器。

MoCo模型：
<img src="https://s1.vika.cn/space/2023/02/07/ed15ead6033a4e78bca928aa9be2ef50" alt="image.png" style="zoom:50%;" />
相较于基础框架的改进：

- queue： 受限于显存大小，将当前min-batch要用的keys放入，将队列最老的min-batch推出，保证字典可以很大而且显存够用。
- momentum encoder：目前的key时当前编码器得到，其他很大一部分key是不同时刻编码器得到，特征不一致。
	- ![image.png](https://s1.vika.cn/space/2023/02/07/8b33a06d7d2a466798c03bf1069a5b4a)
	- 将 $m$ 设置为一个比较大的值，就会使 $\theta_k$ 更新的非常缓慢，能够保证一致


### 代理任务 Instance discrimination
[[01 AI/lib/代理任务]]是没什么人关心的任务，是为了学习更好的特征。

如果query-key是同一个图片的不同视角（比如随机裁剪），则认为能配对


### 结果
1. MoCo提取出的特征能直接迁移到下游任务。
2. MoCo无监督的方式，在包括检测和分割的7个下游任务上都超越了在ImageNet上有监督的训练方式
3. 没有性能保护的现象

## Related Work
不同代理任务可以和对比学习配对使用。

### 目标函数
- 生成式
- 判别式
- 对比学习
- 对抗式

### 代理任务



## Method
### InfoNCE
NCE：noisy contrastive estimation。将多分类变成二分类。
- noisy：在代理任务下，种类变成了图片数，还有指数操作，导致计算很困难。
- estimation：字典越大，越接近整个数据集，近似越准确。

InfoNCE：其他图片不是属于一个类，还是看成多分类比较合理。
- 温度 \tao: 调模型平滑程度。
	- 设置大：对所有负样本一视同仁，模型学习没有重点
	- 设置小：模型只会关注困难的负样本，而这些可能是潜在的正样本。这会导致模型难以收敛，难以泛化。
- 这就类似 Cross entropy loss。只是k指代的内容不同，一个是数据集的类别，一个是负样本的数量。所以其实就是 k+1 的分类任务，想要把 query 分类到 k+

### Momentum Contrast
- queue：将字典用队列表示
	- 是所有数据的一个子集
	- 将min-batch的大小和queue的大小剥离开。使用标准min-batch的同时，还可以用一个很大的字典，这个队列里有当前编码好的key，也有之前编码好的key
	- 大小灵活
	- 先进先出：每次移除都是最老的min-batch计算的key，是跟最新的key最不一致的key
- momentum update
	- 队列很大，没办法梯度回传。所以 key 的编码器 $f_k$ 没办法更新
	- 直接使用 query 的编码器 $f_q$ 参数，导致更新太快不能保证一致性
	- 所以使用动量更新，大部分是原来参数，小部分是 $f_q$ 的参数进行缓慢更新，既更新，又保证一致性。（m=0.999）


### Model
之前的工作：
- end-to-end：
	- $f_q, f_k$ 使用同一个模型，正负样本是同一个min-batch中的。一次forward能得到所有特征 
	- 能梯度回传，特征保持高度一致
	- 字典大小=min-batch大小
	- <img src="https://s1.vika.cn/space/2023/02/07/6a93222aa6914ec698d7c4b6a1ae5aee" alt="image.png" style="zoom:50%;" />

- memory bank
	- 整个数据集的特征都存储起来。
	- 抽取特征 - 学习更新模型 - 新的特征放回。又因为提督会穿编码器更新的很快，这就导致不同时刻编码器得到的特征差距很大。
	- 每个epoch遍历完一遍。下次再随机抽取时，不知道是上一个epoch哪一个时刻的特征。导致key-query特征相差很大
	- 也使用了动量更新，但是更新的是特征，MoCo更新的是编码器
	- 而且扩展性不好，数据量上升到1B时，存储就需要几十上百G了
	- <img src="https://s1.vika.cn/space/2023/02/07/a28356bfd24e4da492df9591d0936501" alt="image.png" style="zoom:50%;" />

### Algorithm
**Algorithm 1 Pseudocode of MoCo in a PyTorch-like style**
```python
# f_q, f_k: encoder networks for query and key
# queue: dictionary as a queue of K keys (CxK)
# m: momentum
# t: temperature

f_k.params = f_q.params # initialize
for x in loader: # load a minibatch x with N samples

   x_q = aug(x) # a randomly augmented version
   x_k = aug(x) # another randomly augmented version

   q = f_q.forward(x_q) # queries: NxC
   k = f_k.forward(x_k) # keys: NxC
   k = k.detach() # no gradient to keys

   # positive logits: Nx1

   l_pos = bmm(q.view(N,1,C), k.view(N,C,1))

   # negative logits: NxK

   l_neg = mm(q.view(N,C), queue.view(C,K))

   # logits: Nx(1+K)

   logits = cat([l_pos, l_neg], dim=1)

   # contrastive loss, Eqn.(1)   labels = zeros(N) # positives are the 0-th
   loss = CrossEntropyLoss(logits/t, labels)

   # SGD update: query network

   loss.backward()
   update(f_q.params)

   # momentum update: key network

   f_k.params = m*f_k.params+(1-m)*f_q.params

   # update dictionary   enqueue(queue, k) # enqueue the current minibatch
   dequeue(queue) # dequeue the earliest minibatch
```

## Experiments
学习率：30。无监督学习的特征和有监督的非常不一样。

对比学习的学习率可能很诡异。

==无监督学习的最主要目标是学习一个可以迁移的特征==

在COCO这篇论文中，提到如果下有任务中数据量足够大，随即初始化也能得到很好的效果，不需要预训练模型。大概是6x～9x的训练时常

在dense，pixel层次上，对比学习的效果可能不是特别好


## Discussion
1. 数据量1M -> 1B, 但是效果只提升1个点。可能大量数据集没有被很好的利用，更好的代理任务有可能解决这个问题
2. MoCo可能跟masked auto-encoding结合使用。

MoCo设计的本意，就是设计一个大的字典，让正负样本更好的对比，提供一个稳定的监督信号训练模型
