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




参考：
> [菜鸟教程](https://www.runoob.com/python/python-dictionary.html)