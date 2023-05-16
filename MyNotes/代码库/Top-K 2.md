---
项目名称: 
相对路径: 
文件名称: 
代码名称: 
CUID: 202303151429
所在行: 
语言: python
框架: pytorch
简述: 分类任务评价指标Top-k
tags: code_snippet
---

## 代码名称
在深度学习中，计算机视觉的分类任务中，Top-1和Top-5是两种常用的评价指标。Top-1准确率指的是模型预测结果中概率最大的类别是否与真实类别相同。而Top-5准确率指的是模型预测结果中概率最大的5个类别中是否包含真实类别1。
## 代码实现

```python
def accuracy(output, target, topk=(1,)):
    """Computes the accuracy over the k top predictions for the specified values of k"""
    with torch.no_grad():
        maxk = max(topk)
        batch_size = target.size(0)

        _, pred = output.topk(maxk, 1, True, True)
        pred = pred.t()
        correct = pred.eq(target.view(1, -1).expand_as(pred))

        res = []
        for k in topk:
            correct_k = correct[:k].view(-1).float().sum(0, keepdim=True)
            res.append(correct_k.mul_(100.0 / batch_size))
        return res
```

## 使用注意
1. NewBing给出，未经验证

## 评论
- 2023-3-1 17 :05: 12 这坨屎一样的代码是我写的吗？

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

[[MyNotes/代码库/00. 代码库|代码管理主页]]

---

注：感谢 @咖啡豆 提供模板！

