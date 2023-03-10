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
