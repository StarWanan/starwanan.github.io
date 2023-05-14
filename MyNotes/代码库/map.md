---
项目名称: 
相对路径: 
文件名称: 
代码名称: gen_map_res
CUID: 202304031500
所在行: 
语言: python
框架: numpy
简述: 模型评价指标
tags: code_snippet
---

## 代码名称
我是一个代码的名称以及功能简介
## 代码实现
我是代码内容实现了功能，这里使用 markdown 语法描述
```python
import numpy as np


def gen_map_res(query_labels, pred_labels):
    map_res, top1_preds, map_preds = [], [], []
    for idx, query_label in enumerate(query_labels):
        pred_label = pred_labels[idx]
        top1_preds.append(pred_label[0])
        ap = []
        flag = 0
        for idx, i in enumerate(pred_label):
            if i == query_label:
                ap.append((flag + 1) / (idx + 1))
                flag += 1
        if ap == []:
            ap = [0]
        map_res.append(mean(ap))
    
    return np.array(map_res), np.array(top1_preds), np.array(map_preds)
```

## 使用注意
使用时候要注意以下几点

## 评论



## 最近代码片段
```dataview
table
		语言,
 		框架,
		简述,
		file.cday AS "创建时间"
from #code_snippet and !"40 - Obsidian/模板"
where date(today) - file.ctime <=dur(7 days)
sort file.mtime desc
limit 10
```

[[00. 代码库|代码管理主页]]

---

注：感谢 @咖啡豆 提供模板！

