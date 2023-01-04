#AI/Transformer


---
[BERT完全指南-从原理到实践](https://blog.csdn.net/u012526436/article/details/86296051?spm=1001.2014.3001.5502)
[[BERT]]
[使用pytorch 和 bert 实现一个简单的文本分类任务](https://blog.csdn.net/gjh1716718326/article/details/115335467) 

[Pytorch数据预处理：transforms的使用方法](https://zhuanlan.zhihu.com/p/130985895#:~:text=transfor,%E9%83%BD%E6%9C%89%E8%87%AA%E5%B7%B1%E7%9A%84%E5%8A%9F%E8%83%BD%E3%80%82)
[PyTorch 学习笔记（三）：transforms的二十二个方法](https://blog.csdn.net/u011995719/article/details/85107009)

---



transforms.Compose函数就是将transforms组合在一起

- `transforms.ToPILImage()`是转换数据格式，把数据转换为tensfroms格式。只有转换为tensfroms格式才能进行后面的处理。
- `transforms.Resize(256)`是按照比例把图像最小的一个边长放缩到256，另一边按照相同比例放缩。
- `transforms.RandomResizedCrop(224,scale=(0.5,1.0))`是把图像按照中心随机切割成224正方形大小的图片。
- `transforms.ToTensor() `转换为tensor格式，这个格式可以直接输入进神经网络了。
- `transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])`对像素值进行归一化处理。
- `transforms.CenterCrop()` 中心剪裁


# 总体结构
![Pasted image 20220124214311](https://s1.vika.cn/space/2022/09/14/e17431be6c884c4ba8625fffcff4123e)


![Pasted image 20220124214330](https://s1.vika.cn/space/2022/09/14/767a103fc0ac43668b8bced2e588d876)


encoder包含两层
- Self-Attrntion：帮助当前节点不仅仅只关注当前的次，能获取到上下文语意
- 前馈神经网络：

decoder包含三层
- Self-Attrntion
- attention层：帮助当前节点获取到当前需要关注的重点内容
- 前馈神经网络

# 内部细节
![Pasted image 20220124214628](https://s1.vika.cn/space/2022/09/14/670e2adc9ae346e38a4b36620d72f70e)



- 模型需要对输入的数据进行一个embedding操作，也可以理解为类似w2c的操作
- enmbedding结束之后，输入到encoder层，self-attention处理完数据后把数据送给前馈神经网络
- 前馈神经网络的计算可以并行，得到的输出会输入到下一个encoder

## Self-Attention
思想和attention类似，但是self-attention是Transformer用来将其他相关单词的“理解”转换成我们==正在处理的单词==的一种思路

`The animal didn't cross the street because it was too tired`

这里的 `it` 代表的是 `animal` 还是 `street` 对于机器很难判断, 但是self-attention可以将 `it` 和 `animal`  联系起来

1. self-attention会计算出三个新的向量: Query、Key、Value (论文中向量的维度是512维)
这三个向量是用embedding向量与一个矩阵相乘得到的结果
这个矩阵是随机初始化的，维度为(64，512).  注意第二个维度需要和embedding的维度一样
其值在BP的过程中会一直进行更新，得到的这三个向量的维度是64低于embedding维度的。
![Pasted image 20220124232552](https://s1.vika.cn/space/2022/09/14/826b0b3557564f37a7f52772ef7ee1f0)


2. 计算self-attention分数值    
分数值决定了当我们在某个位置encode一个词时，对输入句子的其他部分的关注程度
计算方法: Query与Key做点乘
例子:
Thinking:  计算出其他词对于该词的一个分数值，首先是针对于自己本身即q1·k1，然后是针对于第二个词即q1·k2
![Pasted image 20220124232902](https://s1.vika.cn/space/2022/09/14/68fd44762ade4ed7bc22a3f9b57c3e94)



3. 把点成的结果除以一个常数.这个值一般是采用上文提到的矩阵的第一个维度的开方(这里是64的开方8)，当然也可以选择其他的值，然后把得到的结果做一个softmax的计算
结果即是每个词对于当前位置的词的相关性大小，当然，当前位置的词相关性肯定会会很大
![Pasted image 20220124233010](https://s1.vika.cn/space/2022/09/14/f2b0dff091784681abe764eca6d3378c)



4. 把Value和softmax得到的值进行相乘，并相加，得到的结果即是self-attetion在当前节点的值。
![Pasted image 20220124233039](https://s1.vika.cn/space/2022/09/14/2228328198924aed95019d09bfbc3cbd)



实际场景: 提高计算速度，采用矩阵方式
- 直接计算出Query, Key, Value的矩阵
- 然后把embedding的值与三个矩阵直接相乘
- 把得到的新矩阵Q与K相乘，乘以一个常数，做softmax操作
- 最后乘上V矩阵
![Pasted image 20220124233141](https://s1.vika.cn/space/2022/09/14/19b377180771469cb5c887e99ce44bf8)
![Pasted image 20220124233152](https://s1.vika.cn/space/2022/09/14/6d1333a4b23f4199a2aec860fcb70c8d)



这种通过 query 和 key 的相似性程度来确定 value 的权重分布的方法被称为`scaled dot-product attention`。


## Multi-Headed Attention
不仅仅只初始化一组Q、K、V的矩阵，而是初始化多组，tranformer是使用了8组，所以最后得到的结果是8个矩阵。
![Pasted image 20220124233319](https://s1.vika.cn/space/2022/09/14/f2e194e5fbb141ab9c4550ba16a673df)



但是前馈神经网络没法输入8个矩阵
需要一种方式，把8个矩阵降为1个

- 把8个矩阵连在一起，这样会得到一个大的矩阵
- 再随机初始化一个矩阵和这个组合好的矩阵相乘，最后得到一个最终的矩阵。
![Pasted image 20220124233422](https://s1.vika.cn/space/2022/09/14/33a1261e47084d11bce49a183e5eb091)



## 全局
![](https://s1.vika.cn/space/2022/09/14/33a1261e47084d11bce49a183e5eb091)




## Positional Encoding
解释输入序列中单词顺序的方法

给encoder层和decoder层的输入添加了一个额外的向量Positional Encoding，维度和embedding的维度一样，这个向量采用了一种很独特的方法来让模型学习到这个值，这个向量能决定当前词的位置，或者说在一个句子中不同的词之间的距离。这个位置向量的具体计算方法有很多种，论文中的计算方法如下
 ![Pasted image 20220125221142](https://s1.vika.cn/space/2022/09/14/c6d82c6ba09f4d6997ae13c31a6b8cd1)
pos是指当前词在句子中的位置，i是指向量中每个值的index
**偶数位置，使用正弦编码，在奇数位置，使用余弦编码**

```python
position_encoding = np.array(
    [[pos / np.power(10000, 2.0 * (j // 2) / d_model) for j in range(d_model)] for pos in range(max_seq_len)])

position_encoding[:, 0::2] = np.sin(position_encoding[:, 0::2])
position_encoding[:, 1::2] = np.cos(position_encoding[:, 1::2])
```

最后把这个Positional Encoding与embedding的值相加，作为输入送到下一层。
![Pasted image 20220125221247](https://s1.vika.cn/space/2022/09/14/5bd38e57afdb41bb86147efdafb6e6b2)



## **Layer normalization**
每一个子层（self-attetion，ffnn）之后都会接一个残差模块，并且有一个 Layer normalization
![Pasted image 20220125222756](https://s1.vika.cn/space/2022/09/14/e725cb2170ee42f6b9d6861b82814634)

Normalization有很多种，但是它们都有一个共同的目的，那就是把输入转化成均值为0方差为1的数据。我们在把数据送入激活函数之前进行normalization（归一化），因为我们不希望输入数据落在激活函数的饱和区。







