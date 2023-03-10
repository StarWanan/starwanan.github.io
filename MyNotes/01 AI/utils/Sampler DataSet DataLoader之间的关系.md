

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

