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

### clip()

`np.clip(a, a_min, a_max, out=None)`

作用：将一个nd.array的值限制在给定的上下界, 如果元素值小于下界则将值改为下界值a_min, 同理如果大于上界，则将值改为上界值a_max

参数：
- `a`: 输入的nd.array
- `a_min`: 设定的下界
- `a_max`: 设定的上界
- `out(可选项)`: 将处理后的矩阵存放在out中指定的矩阵中， 存放的矩阵尺寸要相同

```python
    >>> a = np.arange(10)
    >>> np.clip(a, 1, 8)
    array([1, 1, 2, 3, 4, 5, 6, 7, 8, 8])
    # 没有设定out，此时a值还是原来的
    >>> a
    array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
    >>> np.clip(a, 3, 6, out=a)
    array([3, 3, 3, 3, 4, 5, 6, 6, 6, 6])
    # 将转换后的矩阵存回a中， a的值改变了
    >>>a
    array([3, 3, 3, 3, 4, 5, 6, 6, 6, 6])
```