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

