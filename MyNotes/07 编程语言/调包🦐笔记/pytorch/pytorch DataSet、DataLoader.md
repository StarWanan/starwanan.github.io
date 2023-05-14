

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
