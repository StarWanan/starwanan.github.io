---
项目名称: 
相对路径: 
文件名称: 
代码名称: simclr_augment
CUID: 202303151035
所在行: 
语言: python
框架: pytorch
简述: 对比学习中的强数据增强
tags: code_snippet
---

## 代码名称
我是一个代码的名称
## 代码描述
我是代码内容实现了功能，这里使用 markdown 语法描述
```python
from torchvision import transforms
import kornia

def simclr_augment(image):
    # random crop and resize
    transform = transforms.Compose([
        transforms.RandomResizedCrop(224),
        transforms.Resize(224)
    ])
    image = transform(image)
    # random color jitter
    color_jitter = transforms.ColorJitter(brightness=0.8, contrast=[0.2, 1.8], saturation=[0.2, 1.8], hue=0.2)
    image = color_jitter(image)
    # random grayscale
    gray = transforms.RandomGrayscale(p=1)
    image = gray(image)
    # random gaussian blur
    image = kornia.filters.gaussian_blur2d(image, (3, 3), (1.0, 1.0))
    return image
```

## 使用注意
1. 代码由NewBing提供，未验证正确性

## 评论
- 2022-3-27 17 :05: 12 这坨屎一样的代码是我写的吗？
- 2022-3-27 17 :07: 34 天啦，这代码写的简直超神了！
- 2022-3-27 17 :07: 59 TODO 需要改进一下代码结构，关联的几个都需要重构

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

