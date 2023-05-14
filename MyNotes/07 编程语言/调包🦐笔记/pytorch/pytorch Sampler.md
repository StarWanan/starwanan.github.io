
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

