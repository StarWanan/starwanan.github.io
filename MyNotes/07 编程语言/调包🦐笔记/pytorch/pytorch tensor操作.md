### 创建tensor

#### 随机Tensor
`torch.rand(x,y)` 生成x行y列的均匀分布的张量
`torch.randn(x,y)` 生成x行y列的正态分布的张量

```python
A = torch.tensor([1.0,1.0],[2,2]) 
A 
#tensor([1.,1.], 
#       [2.,2.])  
```



#### from_numpy
- https://pytorch.org/docs/stable/generated/torch.from_numpy.html
> torch.from_numpy(_ndarray_) → [Tensor](https://pytorch.org/docs/stable/tensors.html#torch.Tensor "torch.Tensor")

```python
>>> a = numpy.array([1, 2, 3])
>>> t = torch.from_numpy(a)
>>> t
tensor([ 1,  2,  3])
>>> t[0] = -1
>>> a
array([-1,  2,  3])
```



### 获取tensor的信息

#### 获取一个tensor的维度
1. shape: tensor自带的属性
2. size(): tensor的方法，是函数
ex:
```python
import torch

a = torch.tensor([[1, 2, 3], [4, 5, 6]])
print(a.shape)
print(a.size())

print(a.shape[0])
print(a.shape[1])
print(a.size(0))
print(a.size(1))
```


#### 拷贝数据信息

> `clone`(_memory_format=torch.preserve_format_)→ Tensor

返回tensor的拷贝，返回的新tensor和原来的tensor具有同样的大小和数据类型。而且原tensor和clone之后的tensor不共享同一块内存，修改其中一个不会影响另外一个。

要注意，如果原本的tensor在计算图中，那么clone出来的tensor梯度会叠加在原tensor上。所以视情况使用`detach()`截断梯度。


参考文章：
> [tensor.clone() 和 tensor.detach() - zhihu](https://zhuanlan.zhihu.com/p/148061684)



### tensor的变化

#### 维度变化

##### squeeze()
- https://pytorch.org/docs/stable/generated/torch.squeeze.html?highlight=squeeze#torch.squeeze
> torch.squeeze(_input_, _dim=None_) → [Tensor](https://pytorch.org/docs/stable/tensors.html#torch.Tensor "torch.Tensor")

参数：
- input：输入一个tensor
- dim：指定维度
	- 不指定dim时：返回一个tensor，将input的tensor中维数为1的维度全部移除。
	- 指定dim时：将维数为1的制指定维度移除。如果指定维度的维数不为1，则tensor不发生改变
ex:
```python
>>> x = torch.zeros(2, 1, 2, 1, 2)
>>> x.size()
torch.Size([2, 1, 2, 1, 2])

>>> y = torch.squeeze(x)
>>> y.size()
torch.Size([2, 2, 2])

>>> y = torch.squeeze(x, 0)
>>> y.size()
torch.Size([2, 1, 2, 1, 2])

>>> y = torch.squeeze(x, 1)
>>> y.size()
torch.Size([2, 2, 1, 2])
```


##### unsqueeze()
- https://pytorch.org/docs/stable/generated/torch.unsqueeze.html#torch.unsqueeze
> torch.unsqueeze(_input_, _dim_) → [Tensor](https://pytorch.org/docs/stable/tensors.html#torch.Tensor "torch.Tensor")

返回一个新的张量，插入到指定的位置一个新的维数为1的维度。

ex:
```python
>>> x = torch.tensor([1, 2, 3, 4])
>>> torch.unsqueeze(x, 0)
tensor([[ 1,  2,  3,  4]])
>>> torch.unsqueeze(x, 1)
tensor([[ 1],
        [ 2],
        [ 3],
        [ 4]])
```


#### 拼接操作

> [Pytorch tensor全面了解 | tensor的拼接方法大全 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/338470163)

##### cat()
功能：将给定的 tensors 在给定的维度上拼接
(注意：除了拼接的维度其余维度大小应一致)

参数：
- tensors - 多个tensor组成的元组（序列）  
- dim - 想要拼接的维度
Test
```python
x = torch.randn(2, 3, 3)
y = torch.cat((x, x, x), dim=0)
y_1 = torch.cat((x, x, x), dim=1)
y_2 = torch.cat((x, x, x), dim=2)
```
Output
```python
x.size() = torch.Size([2, 3, 3])
y.size() = torch.Size([6, 3, 3])
y_1.size() = torch.Size([2, 9, 3])
y_2.size() = torch.Size([2, 3, 9])
```

##### stack()
功能：将给定的 tensors 在新的维度进行拼接

注意：每一个 tensor 的大小都应一致

参数：tensors

- dim - 所要插入的维度，最小为 0 ，最大为输入数据的维度值

Test
```python
a = torch.zeros(3, 4)
b = torch.ones(3, 4)
c = torch.stack((a, b))
d = torch.stack((a, b), dim=0)
e = torch.stack((a, b), dim=1)
f = torch.stack((a, b), dim=2)
```

Output
```python
c.size() = torch.Size([2, 3, 4])
d.size() = torch.Size([2, 3, 4])
e.size() = torch.Size([3, 2, 4])
f.size() = torch.Size([3, 4, 2])
```

##### unbind()
> [torch.unbind — PyTorch 1.13 documentation](https://pytorch.org/docs/stable/generated/torch.unbind.html)

移除tensor的一个维度。返回包含着所有沿着指定的已经不存在的维度的所有片段的元组。

`torch.unbind(input,ddim=0) -> seq`

```python
>>> torch.unbind(torch.tensor([[1, 2, 3],
>>>                            [4, 5, 6],
>>>                            [7, 8, 9]]))
(tensor([1, 2, 3]), tensor([4, 5, 6]), tensor([7, 8, 9]))
```



#### 数据变化
##### repeat()
- https://pytorch.org/docs/stable/generated/torch.Tensor.repeat.html
在指定维度重复tensor中的元素。

>⚠️ `repeat()`是拷贝tensor的数值

参数: `sizes(torch.Size or int)` 沿着每一维要重复的倍数

ex：
```python
>>> x = torch.tensor([1, 2, 3])
>>> x.repeat(4, 2)    // 在第0维变成2倍，在第1维变成4倍
tensor([[ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3]])

>>> x.repeat(4, 2, 1).size()    // 原本x是一维，逐渐repeat后：size:(3,) -> 第0维1倍大小不变(3,) -> 第1维2倍(2, 3) -> 第2维4倍(4, 2, 3)
torch.Size([4, 2, 3])
```

##### expand()
- https://pytorch.org/docs/stable/generated/torch.Tensor.expand.html#torch.Tensor.expand





### 保存与加载tensor
- https://pytorch.org/docs/stable/notes/serialization.html#saving-and-loading-tensors-preserves-views
PyTorch中的tensor可以保存成 `.pt` 或者 `.pth` 格式的文件。使用`torch.save()`进行保存, 使用`torch.load()`进行加载
```python
>>> t = torch.tensor([1., 2.])
>>> torch.save(t, 'tensor.pt')
>>> torch.load('tensor.pt')
tensor([1., 2.])
```

但是保存下来的不仅仅数数据，还有数据之间的关系。

如果想只保存数据，那么可以使用`clone()`
```python
>>> large = torch.arange(1, 1000)
>>> small = large[0:5]
>>> torch.save(small.clone(), 'small.pt')  # saves a clone of small
>>> loaded_small = torch.load('small.pt')
>>> loaded_small.storage().size()
5
```

### 与其他数据类型的转化
numpy, list, tensor之间相互转换

> [(PyTorch)tensor的相关操作 - zhihu](https://zhuanlan.zhihu.com/p/477801671)

#### 报错处理
1. 转化list
```sh
TypeError: only integer tensors of a single element can be converted to an index
ValueError: only one element tensors can be converted to Python scalars
```

> [tensor转list中可能会遇到的两种错误 - CSDN](https://blog.csdn.net/qq_43391414/article/detDLls/120471616)


