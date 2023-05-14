---
项目名称: 
相对路径: 
文件名称: 
代码名称: fpr_at_95_tpr
CUID: 202303151044
所在行: 
语言: python
框架: pytorch
简述: 评价指标
tags: code_snippet
---

## 代码名称

## 代码描述
FPR95是假阳性率（False Positive Rate）在95%置信度下的值。它通常用于评估二元分类器的性能，特别是在不平衡数据集中。FPR定义为假阳性数除以假阳性数与真阴性数之和。在ROC曲线中，FPR95是当真阳性率（True Positive Rate）为95%时的FPR值。
```python
from sklearn.metrics import roc_curve

def fpr_at_95_tpr(y_true, y_score):
    fpr, tpr, _ = roc_curve(y_true, y_score)
    idx = np.argmin(np.abs(tpr - 0.95))
    return fpr[idx]
```
## 使用注意
1. NewBing给出，暂时未验证

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

