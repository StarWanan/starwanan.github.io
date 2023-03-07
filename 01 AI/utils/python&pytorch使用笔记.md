# pytorch

## 参数 & 命令行 & 辅助 

### logger

[logger模块解释 —— CSDN](https://blog.csdn.net/liming89/article/details/109609557)
[logger使用案例](https://vimsky.com/examples/detail/python-method-utils.logger.setup_logger.html)

logging模块是Python内置的标准模块，主要用于输出运行日志，可以设置输出日志的等级、日志保存路径、日志文件回滚等



### yacs.config

[yacs使用 —— 知乎](https://zhuanlan.zhihu.com/p/366289700)

yacs库，用于为一个系统构建config文件

需要创建`CN()`这个作为容器来装载我们的参数，这个容器可以嵌套

### 手动增加参数
```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--device', default='0,1', type=str, help='设置使用哪些显卡')
parser.add_argument('--no_cuda', action='store_true', help='不适用GPU进行训练')
args = parser.parse_args()
print(args)
```

命令行：`python test.py --device 0 --no_cuda`

jupyter：

1. 首先代码第6行改成：`args = parser.parse_args(args=['--device', '0',  '--no_cuda'])`,传参改成**列表形式**
2. 运行jupyter单元





## 设备相关

### torch.cuda.synchronize()

等待当前设备上所有流中的所有核心完成。

🌰：测试时间的代码

```python
# code 1
start = time.time()
result = model(input)
end = time.time()

# code 2
torch.cuda.synchronize()
start = time.time()
result = model(input)
torch.cuda.synchronize()
end = time.time()

# code 3
start = time.time()
result = model(input)
print(result)
end = time.time()
```

代码2是正确的。因为在pytorch里面，程序的执行都是异步的。
如果采用代码1，测试的时间会很短，因为执行完end=time.time()程序就退出了，后台的cu也因为python的退出退出了。
如果采用代码2，代码会同步cu的操作，等待gpu上的操作都完成了再继续成形end = time.time()

代码3和代码2的时间是类似的。
因为代码3会等待gpu上的结果执行完传给print函数，所以时间就和代码2同步的操作的时间基本上是一致的了。
将print(result)换成result.cpu()结果是一致的。



## 数据加载

### 图像数据变换

transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])

Normalize是把图像数据从[0,1]变成[-1,1]，变换公式是image=(image-mean)/std，那么其中的参数就分别是三个通道的mean和std，这个均值和标准差需要自己计算，范围就是训练集和验证集的所有图像。


### Sampler
[Pytorch Sampler详解 - cnblog](https://www.cnblogs.com/marsggbo/p/11541054.html)
  
所有的采样器都继承自`Sampler`这个类,可以看到主要有三种方法：分别是：
-   `__init__`: 这个很好理解，就是初始化
-   `__iter__`: 这个是用来产生迭代索引值的，也就是指定每个step需要读取哪些数据
-   `__len__`: 这个是用来返回每次迭代器的长度

```python
class Sampler(object):
    r"""Base class for all Samplers.
    Every Sampler subclass has to provide an __iter__ method, providing a way
    to iterate over indices of dataset elements, and a __len__ method that
    returns the length of the returned iterators.
    """
    # 一个 迭代器 基类
    def __init__(self, data_source):
        pass

    def __iter__(self):
        raise NotImplementedError

    def __len__(self):
        raise NotImplementedError
```


### DataSet、DataLoader

[CSDN原文链接](https://blog.csdn.net/weixin_42468475/article/details/108714940)
[collate_fn参数使用详解 —— 知乎](https://zhuanlan.zhihu.com/p/361830892)
[num_works参数 —— CSDN](https://blog.csdn.net/qq_24407657/article/details/103992170)

---

加载一个batch的数据这一步需要使用一个`torch.utils.data.DataLoader`对象，并且DataLoader是一个基于某个dataset的iterable，这个iterable每次从dataset中基于某种采样原则取出一个batch的数据。
也可以这样说：Torch中可以创建一个torch.utils.data.==Dataset==对象，并与torch.utils.data.==DataLoader==一起使用，在训练模型时不断为模型提供数据。

**torch.utils.data.DataLoader**

定义：Data loader. Combines a dataset and a sampler, and provides an iterable over the given dataset.
构造函数:
```python
torch.utils.data.DataLoader(dataset, 
							batch_size=1, 
							shuffle=False, 
							sampler=None,
							batch_sampler=None, num_workers=0, collate_fn=None,
							pin_memory=False, drop_last=False, timeout=0,
							worker_init_fn=None)
```
- dataset: 抽象类,包含两种类型
	- `map-style datasets `
	- `iterable-style datasets`
- batch_size : 每一次抽样的batch-size大小
- shuffle : True则随机打乱数据
- Num_works：将batch加载进RAM的进程数。内存开销大，CPU负担大。可能之后几次迭代的数据在本次迭代的时候已经加载进内存。
- collate_fn：如何取样本的，我们可以定义自己的函数来准确地实现想要的功能。
- drop_last：告诉如何处理数据集长度除于batch_size余下的数据。True就抛弃，否则保留。

**Map-style datasets**

是一个类，要求有 `__getitem__()`and`__len__()`这两个构造函数，代表一个从索引映射到数据样本。
- `__getitem__()`: 根据索引index遍历数据
- `__len__()`: 返回数据集的长度
- 可编写独立的数据处理函数
	- 在 `__getitem()__` 函数中进行调用
	- 直接将数据处理函数写在 `__getitem()__` 或者 `__init()__` 函数中，但是`__getitem()__`
	必须根据==index==返回响应的值，该值会通过index传到dataloader中进行后续的batch批处理。

基本需要满足：
```python
def __getitem__(self, index):
    return self.src[index], self.trg[index]

def __len__(self):
	return len(self.src)  
```



`getitem()`方法用来从datasets中读取一条数据，这条数据包含训练**图片**（以图片举例）和**标签**，参数index表示图片和标签在总数据集中的Index。

`len()`方法返回数据集的总长度（训练集的总数）。

**实现 MyDatasets 类**

1. 简单直白

把 x 和 label 分别装入两个列表 self.src 和 self.trg ，然后通过 getitem(self, idex) 返回对应元素
```python
import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader
 
class My_dataset(Dataset):
    def __init__(self):
        super().__init__()
        ## 使用sin函数返回10000个时间序列,如果不自己构造数据，就使用numpy,pandas等读取自己的数据为x即可。
        ## 以下数据组织这块既可以放在init方法里，也可以放在getitem方法里
        self.x = torch.randn(1000,3)
        self.y = self.x.sum(axis=1)
        self.src,  self.trg = [], []
        for i in range(1000):
            self.src.append(self.x[i])
            self.trg.append(self.y[i])
    
           
    def __getitem__(self, index):
        return self.src[index], self.trg[index]

    def __len__(self):
        return len(self.src) 
        
 ## 或者return len(self.trg), src和trg长度一样
 
data_train = My_dataset()
data_test = My_dataset()
data_loader_train = DataLoader(data_train, batch_size=5, shuffle=False)
data_loader_test = DataLoader(data_test, batch_size=5, shuffle=False)
## i_batch的多少根据batch size和def __len__(self)返回的长度确定
## batch_data返回的值根据def __getitem__(self, index)来确定
## 对训练集：(不太清楚enumerate返回什么的时候就多print试试)
for i_batch, batch_data in enumerate(data_loader_train):
    print(i_batch)  ## 打印batch编号
    print(batch_data[0])  ## 打印该batch里面src
    print(batch_data[1])  ## 打印该batch里面trg
## 对测试集：（下面的语句也可以）
for i_batch, (src, trg) in enumerate(data_loader_test):
    print(i_batch)  ## 打印batch编号
    print(src)  ## 打印该batch里面src的尺寸
    print(trg)  ## 打印该batch里面trg的尺寸    
```

生成的data_train可以通过 `data_train[xxx]`直接索引某个元素，或者通过`next(iter(data_train))` 得到一条条的数据。

2. 借助TensorDataset将数据包装成dataset
```python
import torch
from torch import nn
from torch.utils.data import Dataset, DataLoader, TensorDataset
 
src = torch.sin(torch.arange(1, 1000, 0.1))
trg = torch.cos(torch.arange(1, 1000, 0.1))
 
data = TensorDataset(src, trg)
data_loader = DataLoader(data, batch_size=5, shuffle=False)
for i_batch, batch_data in enumerate(data_loader):
    print(i_batch)  ## 打印batch编号
    print(batch_data[0].size())  ## 打印该batch里面src
    print(batch_data[1].size())  ## 打印该batch里面trg
```

3. 地址读取，生成数据的路径 txt 文件
```python
import os

from torch.utils.data import Dataset
from torch.utils.data import DataLoader
import matplotlib.image as mpimg



## 对所有图片生成path-label map.txt 这个程序可根据实际需要适当修改
def generate_map(root_dir):
	##得到当前绝对路径
    current_path = os.path.abspath('.')
    ##os.path.dirname()向前退一个路径
    father_path = os.path.abspath(os.path.dirname(current_path) + os.path.sep + ".")

    with open(root_dir + 'map.txt', 'w') as wfp:
        for idx in range(10):
            subdir = os.path.join(root_dir, '%d/' % idx)
            for file_name in os.listdir(subdir):
                abs_name = os.path.join(father_path, subdir, file_name)
                ## linux_abs_name = abs_name.replace("\\", '/')
                wfp.write('{file_dir} {label}\n'.format(file_dir=linux_abs_name, label=idx))

## 实现MyDatasets类
class MyDatasets(Dataset):

    def __init__(self, dir):
        ## 获取数据存放的dir
        ## 例如d:/images/
        self.data_dir = dir
        ## 用于存放(image,label) tuple的list,存放的数据例如(d:/image/1.png,4)
        self.image_target_list = []
        ## 从dir--label的map文件中将所有的tuple对读取到image_target_list中
        ## map.txt中全部存放的是d:/.../image_data/1/3.jpg 1 路径最好是绝对路径
        with open(os.path.join(dir, 'map.txt'), 'r') as fp:
            content = fp.readlines()
            ##s.rstrip()删除字符串末尾指定字符（默认是字符）
            ## 得到 [['d:/.../image_data/1/3.jpg', '1'], ...,]
            str_list = [s.rstrip().split() for s in content]
            ## 将所有图片的dir--label对都放入列表，如果要执行多个epoch，可以在这里多复制几遍，然后统一shuffle比较好
            self.image_target_list = [(x[0], int(x[1])) for x in str_list]

    def __getitem__(self, index):
        image_label_pair = self.image_target_list[index]
        ## 按path读取图片数据，并转换为图片格式例如[3,32,32]
        ## 可以用别的代替
        img = mpimg.imread(image_label_pair[0])
        return img, image_label_pair[1]

    def __len__(self):
        return len(self.image_target_list)


if __name__ == '__main__':
    ## 生成map.txt
    ## generate_map('train/')

    train_loader = DataLoader(MyDatasets('train/'), batch_size=128, shuffle=True)

    for step in range(20000):
        for idx, (img, label) in enumerate(train_loader):
            print(img.shape)
            print(label.shape)
```



### Sampler DataSet DataLoader之间的关系
> [一文弄懂Pytorch的DataLoader, DataSet, Sampler之间的关系 - cnblog](https://www.cnblogs.com/marsggbo/p/11308889.html)
> [迄今为止最细致的DataSet和Dataloader加载步骤 - 知乎](https://zhuanlan.zhihu.com/p/381224748)


![image.png](https://s1.vika.cn/space/2023/02/15/d8e3873e2a0e4ad491191cfc498cd743)

![image.png](https://s1.vika.cn/space/2023/02/15/8739a8e8fc454b799e25aaf242a27a35)



dataloader 源码：
```python
class DataLoader(object):
    def __init__(self, dataset, batch_size=1, shuffle=False, sampler=None,
				 batch_sampler=None, num_workers=0, collate_fn=default_collate,
				 pin_memory=False, drop_last=False, timeout=0,
				 worker_init_fn=None)
```
有两个和sampler相关的参数：
- `sampler`: 生成一系列的 index
- `batch_sampler`: 将sampler生成的 indices 打包分组

需要注意的是DataLoader的部分初始化参数之间存在互斥关系，可以通过阅读[源码](https://github.com/pytorch/pytorch/blob/0b868b19063645afed59d6d49aff1e43d1665b88/torch/utils/data/dataloader.py#L157-L182)更深地理解，这里只做总结：
- 如果你自定义了`batch_sampler`,那么这些参数都必须使用默认值：`batch_size`, `shuffle`,`sampler`,`drop_last`.
- 如果你自定义了`sampler`，那么`shuffle`需要设置为`False`
- 如果`sampler`和`batch_sampler`都为`None`,那么`batch_sampler`使用Pytorch已经实现好的`BatchSampler`,而`sampler`分两种情况：
    - 若`shuffle=True`,则`sampler=RandomSampler(dataset)`
    - 若`shuffle=False`,则`sampler=SequentialSampler(dataset)`

Sampler 源码：
```python
class Sampler(object):
    r"""Base class for all Samplers.
    Every Sampler subclass has to provide an :meth:`__iter__` method, providing a
    way to iterate over indices of dataset elements, and a :meth:`__len__` method
    that returns the length of the returned iterators.
    .. note:: The :meth:`__len__` method isn't strictly required by
              :class:`~torch.utils.data.DataLoader`, but is expected in any
              calculation involving the length of a :class:`~torch.utils.data.DataLoader`.
    """

    def __init__(self, data_source):
        pass

    def __iter__(self):
        raise NotImplementedError
		
    def __len__(self):
        return len(self.data_source)
```

DataSet:
```python
class Dataset(object):
	def __init__(self):
		...
		
	def __getitem__(self, index):
		return ...
	
	def __len__(self):
		return ...
```

`__next__`:DataLoader对数据的读取其实就是用了for循环来遍历数据
```python
class DataLoader(object): 
    ... 
     
    def __next__(self): 
        if self.num_workers == 0:   
            indices = next(self.sample_iter)  
            batch = self.collate_fn([self.dataset[i] for i in indices]) # this line 
            if self.pin_memory: 
                batch = _utils.pin_memory.pin_memory_batch(batch) 
            return batch
```

合并成一个batch的操作：
```python
class DataLoader(object): 
    ... 
     
    def __next__(self): 
        if self.num_workers == 0:   
            indices = next(self.sample_iter)  
            batch = self.collate_fn([self.dataset[i] for i in indices]) # this line 
            if self.pin_memory: 
                batch = _utils.pin_memory.pin_memory_batch(batch) 
            return batch
```
- `indices`: 表示每一个iteration，sampler返回的indices，即一个batch size大小的索引列表
- `self.dataset[i]`: 这里就是对第i个数据进行读取操作，一般来说`self.dataset[i]=(img, label)`
看到这不难猜出`collate_fn`的作用就是将一个batch的数据进行合并操作。默认的`collate_fn`是将img和label分别合并成imgs和labels，所以如果你的`__getitem__`方法只是返回 `img, label`,那么你可以使用默认的`collate_fn`方法，但是如果你每次读取的数据有`img, box, label`等等，那么你就需要自定义`collate_fn`来将对应的数据合并成一个batch数据，这样方便后续的训练步骤。


## 网络模型

### apply 初始化参数
[pytorch系列10 --- 如何自定义参数初始化方式 ，apply()](https://blog.csdn.net/dss_dssssd/article/details/83990511)


### nn.Conv2d
[Pytorch的nn.Conv2d（）详解_风雪夜归人o的博客-CSDN博客_nn是什么意思](https://blog.csdn.net/qq_42079689/article/details/102642610)

---

```python
class Net(nn.Module):
    def __init__(self):
        nn.Module.__init__(self)
        self.conv2d = nn.Conv2d(in_channels=3,out_channels=64,kernel_size=4,stride=2,padding=1)

    def forward(self, x):
        print(x.requires_grad)
        x = self.conv2d(x)
        return x
    
print(net.conv2d.weight)
print(net.conv2d.bias)
```


### flatten
[CNN的Flatten操作](https://cloud.tencent.com/developer/article/1620842)

---


- `torch.flatten(Python function, in torch)`
- `torch.nn.Flatten(Python class, in torch.nn)`
- `torch.Tensor.flatten(Python methodm in torch.nn.Tensor)`

#### torch.flatten
```python
#展平一个连续范围的维度，输出类型为Tensor
torch.flatten(input, start_dim=0, end_dim=-1) → Tensor
# Parameters：input (Tensor) – 输入为Tensor
# start_dim (int) – 展平的开始维度
# end_dim (int) – 展平的最后维度

#example
#一个3x2x2的三维张量
>>> t = torch.tensor([[[1, 2], [3, 4]],
                      [[5, 6], [7, 8]],
	                  [[9, 10],[11, 12]]])
#当开始维度为0，最后维度为-1，展开为一维
>>> torch.flatten(t)
tensor([ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12])
#当开始维度为0，最后维度为-1，展开为3x4，也就是说第一维度不变，后面的压缩
>>> torch.flatten(t, start_dim=1)
tensor([[ 1,  2,  3,  4],
        [ 5,  6,  7,  8],
        [ 9, 10, 11, 12]])
>>> torch.flatten(t, start_dim=1).size()
torch.Size([3, 4])
#下面的和上面进行对比应该就能看出是，当锁定最后的维度的时候
#前面的就会合并
>>> torch.flatten(t, start_dim=0, end_dim=1)
tensor([[ 1,  2],
        [ 3,  4],
        [ 5,  6],
        [ 7,  8],
        [ 9, 10],
        [11, 12]])
>>> torch.flatten(t, start_dim=0, end_dim=1).size()
torch.Size([6, 2])

```


#### torch.nn.Flatten()
torch.nn.Flatten()可以是Sequential模型的一层

pytorch中的 torch.nn.Flatten 类和 torch.Tensor.flatten 方法其实都是基于 torch.flatten 函数实现的。


### nn.Sequential
[pytorch系列7 -----nn.Sequential讲解](https://blog.csdn.net/dss_dssssd/article/details/82980222)

---
nn.Sequential
A sequential container. Modules will be added to it in the order they are passed in the constructor. Alternatively, an ordered dict of modules can also be passed in.

一个有序的==容器==，神经网络模块将按照在传入构造器的顺序依次被添加到计算图中执行，同时以神经网络模块为元素的有序字典也可以作为传入参数。

```python
# Example of using Sequential
model = nn.Sequential(
		  nn.Conv2d(1,20,5),
		  nn.ReLU(),
		  nn.Conv2d(20,64,5),
		  nn.ReLU()
		)

# Example of using Sequential with OrderedDict
model = nn.Sequential(OrderedDict([
		  ('conv1', nn.Conv2d(1,20,5)),
		  ('relu1', nn.ReLU()),
		  ('conv2', nn.Conv2d(20,64,5)),
		  ('relu2', nn.ReLU())
		]))

```



## train & eval

### with torch.no_grad()

> 参考：https://blog.csdn.net/sazass/article/details/116668755

作用：在该模块下，所有计算得出的tensor的requires_grad都自动设置为False。当requires_grad设置为False时,反向传播时就不会自动求导了，因此大大节约了显存或者说内存。



### nn.DataParallel
[Pytorch的nn.DataParallel - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/102697821)
多卡并行的命令，以及可能出的错误

---

当迭代次数或者epoch足够大的时候，我们通常会使用nn.DataParallel函数来用多个GPU来加速训练

````python
CLASS torch.nn.DataParallel(module, device_ids=None, output_device=None, dim=0)
````

module即表示你定义的模型
device_ids表示你训练的device
output_device这个参数表示输出结果的device


### nn.Parameter()
[PyTorch中的torch.nn.Parameter() 详解_Adenialzz的博客-CSDN博客](https://blog.csdn.net/weixin_44966641/article/details/118730730)

---

首先可以把这个函数理解为类型转换函数，将一个不可训练的类型Tensor转换成可以训练的类型parameter并将这个parameter绑定到这个module里面(net.parameter()中就有这个绑定的parameter，所以在参数优化的时候可以进行优化的)，所以经过类型转换这个self.v变成了模型的一部分，成为了模型中根据训练可以改动的参数了。使用这个函数的目的也是想让某些变量在学习的过程中不断的修改其值以达到最优化。

```python
self.pos_embedding = nn.Parameter(torch.randn(1, num_patches+1, dim))
self.cls_token = nn.Parameter(torch.randn(1, 1, dim))
```



### model.train() & model.eval()
- https://blog.csdn.net/asd123pwj/article/details/123017382
让模型开启训练/测试模式，训练测试就可以使用同一份代码。



## 功能函数

### 生成张量
`torch.rand(x,y)` 生成x行y列的均匀分布的张量
`torch.randn(x,y)` 生成x行y列的正态分布的张量

```python
A = torch.tensor([1.0,1.0],[2,2]) 
A 
#tensor([1.,1.], 
#       [2.,2.])  
```


### nn.functional.interpolate()

`torch.nn.functional.interpolate(input, size=None, scale_factor=None, mode='nearest', align_corners=None, recompute_scale_factor=None)`

功能：利用插值方法，对输入的张量数组进行上\下**采样**操作，换句话说就是科学合理地改变数组的尺寸大小，尽量保持数据完整。

`input(Tensor)`：需要进行采样处理的数组。
`size(int或序列)`：输出空间的大小
`scale_factor(float或序列)`：空间大小的乘数
`mode(str)`：用于采样的算法。'nearest'| 'linear'| 'bilinear'| 'bicubic'| 'trilinear'| 'area'。默认：'nearest'
`align_corners(bool)`：在几何上，我们将输入和输出的像素视为正方形而不是点。如果设置为True，则输入和输出张量按其角像素的中心点对齐，保留角像素处的值。如果设置为False，则输入和输出张量通过其角像素的角点对齐，并且插值使用边缘值填充用于边界外值，使此操作在保持不变时独立于输入大小scale_factor。
`recompute_scale_facto(bool)`：重新计算用于插值计算的 scale_factor。当scale_factor作为参数传递时，它用于计算output_size。如果recompute_scale_factor的False或没有指定，传入的scale_factor将在插值计算中使用。否则，将根据用于插值计算的输出和输入大小计算新的scale_factor（即，如果计算的output_size显式传入，则计算将相同 ）。注意当scale_factor 是浮点数，由于舍入和精度问题，重新计算的 scale_factor 可能与传入的不同。




注意：

- 输入的张量数组里面的数据类型必须是float。
- 输入的数组维数只能是3、4或5，分别对应于时间、空间、体积采样。
- 不对输入数组的前两个维度(批次和通道)采样，从第三个维度往后开始采样处理。
- 输入的维度形式为：批量(batch_size)×通道(channel)×[可选深度]×[可选高度]×宽度(前两个维度具有特殊的含义，不进行采样处理)
- size与scale_factor两个参数只能定义一个，即两种采样模式只能用一个。要么让数组放大成特定大小、要么给定特定系数，来等比放大数组。
- 如果size或者scale_factor输入序列，则必须匹配输入的大小。如果输入四维，则它们的序列长度必须是2，如果输入是五维，则它们的序列长度必须是3。
- 如果size输入整数x，则相当于把3、4维度放大成(x,x)大小(输入以四维为例，下面同理)。
- 如果scale_factor输入整数x，则相当于把3、4维度都等比放大x倍。
- mode是’linear’时输入必须是3维的；是’bicubic’时输入必须是4维的；是’trilinear’时输入必须是5维的
- 如果align_corners被赋值，则mode必须是'linear'，'bilinear'，'bicubic'或'trilinear'中的一个。
- 插值方法不同，结果就不一样，需要结合具体任务，选择合适的插值方法。

————————————————
版权声明：本文为CSDN博主「视觉萌新、」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_50001789/article/details/120297401

### torch.max()

`torch.max(input) → Tensor`:返回输入tensor中所有元素的最大值

`torch.max(input, dim, keepdim=False, out=None) -> (Tensor, LongTensor)`: 按维度dim 返回最大值，并且返回索引。

```python
torch.max()[0]， 只返回最大值的每个数

troch.max()[1]， 只返回最大值的每个索引

torch.max()[1].data 只返回variable中的数据部分（去掉Variable containing:）

torch.max()[1].data.numpy() 把数据转化成numpy ndarry

torch.max()[1].data.numpy().squeeze() 把数据条目中维度为1 的删除掉
```


### nn.init.normal_
`torch.nn.init.normal(tensor, mean=0, std=1)`
从给定均值和标准差的正态分布N(mean, std)中生成值，填充输入的张量或变量


## 训练问题
final_loss 会变成nan的情况： loss过大，学习率也很大，可能会梯度爆炸。






# python

## 算法
### 第 k 大，第 k 小
`heapq` 模块的 `nlargest()` 和 `nsmallest()` 函数

```python
heapq.nlargest(n, iterable[, key])
heapq.nsmallest(n, iterable[, key])
```
从迭代器对象 iterable 中返回前 n 个最大/小的元素列表，其中关键字参数 key 用于匹配是字典对象的 iterable，用于更复杂的数据结构中。

```python
import heapq
nums = [1, 8, 2, 23, 7, -4, 18, 23, 42, 37, 2]
print(heapq.nlargest(3, nums))   
#>>> [42, 37, 23]
print(heapq.nsmallest(3, nums))  
#>>> [-4, 1, 2]
```

这两个函数也可以按照关键字排序
```python
portfolio = [
    {'name': 'IBM', 'shares': 100, 'price': 91.1},
    {'name': 'AAPL', 'shares': 50, 'price': 543.22},
    {'name': 'FB', 'shares': 200, 'price': 21.09},
    {'name': 'HPQ', 'shares': 35, 'price': 31.75},
    {'name': 'YHOO', 'shares': 45, 'price': 16.35},
    {'name': 'ACME', 'shares': 75, 'price': 115.65}
]
cheap = heapq.nsmallest(3, portfolio, key=lambda s: s['price'])  #按price排序
expensive = heapq.nlargest(3, portfolio, key=lambda s: s['price'])

cheap
#[{'name': 'YHOO', 'shares': 45, 'price': 16.35},
# {'name': 'FB', 'shares': 200, 'price': 21.09},
# {'name': 'HPQ', 'shares': 35, 'price': 31.75}]

expensive
#[{'name': 'AAPL', 'shares': 50, 'price': 543.22},
# {'name': 'ACME', 'shares': 75, 'price': 115.65},
# {'name': 'IBM', 'shares': 100, 'price': 91.1}]


```

### 根据元素获取下标位置
#### 列表list
内置方法`index()`, 获取 list 中相应元素的第一个位置。缺点是只能获得一个位置
```python
a=[72, 56, 76, 84, 80, 88]
print(a.index(76))

>>> 2
```


`enumerate()`函数
```python
a=[72, 56, 76, 84, 80, 88]
print(list(enumerate(a)))

>>> [(0, 72), (1, 56), (2, 76), (3, 84), (4, 80), (5, 88)]

# 循环获取下标
print([i for i,x in enumerate(a) if x == 76])
>>> 2
```



#### 数组numpy.array
使用 `where()`
```python
import numpy
a1 = numpy.array([5,10,15,20])

# 获取元素信息
info = numpy.where(vector==10)
print(info)
>>>  (array([1], dtype=int64),)

# 元素下标
info[0][0]
>>>  1
```

## Matplotlib

绘制图片、保存图片
```python
plt.savefig('savepic.png')#保存图片
plt.show()
```


## 随机数random

随机生成 \[a, b\] 范围内的整数
```python
import random
random.randint(a,b)
```

## numpy
[numpy | 菜鸟教程](https://www.runoob.com/numpy/numpy-tutorial.html)

### N维数组对象 ndarray
#### 创建数组
##### 从已有的数组创建
参考：[菜鸟教程](https://www.runoob.com/numpy/numpy-array-from-existing-data.html)

#### array的比较
```python
a = np.array([1, 2, 3, 4, 5])
b = np.array([1, 2, 3, 4, 5])
d = np.array([1, 2, 3, 4, 0])
 
# 判断两个ndarray中所有元素都相同
print(a == b)
>>> [ True  True  True  True  True]
print((a == b).all())
>>> True

# 判断两个ndarray中同一位置上是否有相同元素
print(a == d)
>>> [ True  True  True  True False]
print((a == d).any())
>>> True
```

参考与拓展：[array的比较，is，is not...](https://blog.csdn.net/wangyangjingjing/article/details/81208318)

## 数据结构

### 列表list
#### 判断某元素是否在列表中
1. 循环暴力判断
2. `in` 关键字
```python
test_list = [ 1, 6, 3, 5, 3, 4 ] 
for i in test_list: 
    if(i == 4) : 
        print ("存在")

if (4 in test_list): 
    print ("存在") 
```

3. `set() + in`
4. `count()`
```python
test_list_set = [ 1, 6, 3, 5, 3, 4 ] 
test_list_bisect = [ 1, 6, 3, 5, 3, 4 ]
test_list_set = set(test_list_set) 
if 4 in test_list_set : 
    print ("存在") 


if test_list_bisect.count(4) > 0 :
    print ("存在") 
```

### 字典dict
#### 移除 key-value 对
```python
dic = {
	'a': 1,
	'b': 2,
	'c': 3
}

# del
del dic['a']

# pop()
dic.pop('a')

# items()
new_dic = {key:val for key, val in dic.items() if key != 'a'}
```


### 字符串
`str.lower()` 全部转化为小写字母

 

## 其他
### args & kwargs

https://zhuanlan.zhihu.com/p/50804195

args 是 arguments 的缩写，表示位置参数；
kwargs 是 keyword arguments 的缩写，表示关键字参数。

` *args` 必须放在 `**kwargs` 的前面，因为位置参数在关键字参数的前面

`*args`就是就是传递一个可变参数**元组**给函数实参

`**kwargs`则是将一个可变的关键字参数的**字典**传给函数实参





### setattr() & getattr()

`setattr()`: 设置属性值，该属性不一定是存在的。

```python
setattr(object, name, value)
object -- 对象。
name -- 字符串，对象属性。
value -- 属性值。
```

```python
对已存在的属性进行赋值：
>>>class A(object):
    bar = 1

>>> a = A()
>>> getattr(a, 'bar')          # 获取属性 bar 值
1
>>> setattr(a, 'bar', 5)       # 设置属性 bar 值
>>> a.bar
5
```

```python
如果属性不存在会创建一个新的对象属性，并对属性赋值：
class A():
    name = "runoob"
... 
>>> a = A()
>>> setattr(a, "age", 28)
>>> print(a.age)
28
>>>
```


### 安装包 pip & conda
[[python pip & conda]]

### json
[[python json文件]]


