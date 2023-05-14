
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
