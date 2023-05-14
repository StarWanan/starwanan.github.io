
### 单个json对象
```python
import json
with open('superheroes.json') as f:
    superHeroSquad = json.load(f)
print(type(superHeroSquad))  # Output: dict
print(superHeroSquad.keys())
# Output: dict_keys(['squadName', 'homeTown', 'formed', 'secretBase', 'active', 'members'])
```

- 函数load()作用为读取JSON文件生成Python对象
- 函数loads()作用为读取JSON 字符串流生成Python对象

字典

```python
import json

with open("save.json","r", encoding='utf-8'  ) as f:
    load_dict = json.load(f)

print(load_dict)

```

```python
import json

dict1 = {"小明":4,"张三":5,"李四":99}

with open("save.json","w", encoding='utf-8') as f: ## 设置'utf-8'编码
    f.write(json.dumps(dict1, ensure_ascii=False, indent=4))  # indent 缩进
    ## 如果ensure_ascii=True则会输出中文的ascii码，这里设为False
```


### 多json对象文件

写
```python
import json 

def write_jsonlines(json_file_name,date_dict):
    with open(json_file_name, 'a') as f:
        json.dump(date_dict, f)
        f.write("\n")
```

读
```python
import jsonlines

def json_data_read(json_file_name):
    """输入:需要读取的多对象json文件路径
    返回:由多个字典组成的列表"""

    json_list = []
    with open(json_file_name, 'r+') as f:
        for item in jsonlines.Reader(f):
            json_list.append(item)

    return  json_list
```

