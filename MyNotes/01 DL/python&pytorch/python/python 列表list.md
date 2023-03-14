#### 根据元素获取下标位置
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
