github：https://github.com/Jun-CEN/Open-World-Semantic-Segmentation

开放世界语义分割  

- 开集语义分割模块   
  - 闭集语义分割子模块   
  - 异常分割子模块 
- 增量小样本学习模块


# CODE

multiscale 是自己设定的吗 `cfg.DATASET.imgSizes = (300, 375, 450, 525, 600)`

Seg 转化为long Tensor的目的是什么

colors的作用是什么



几个辅助函数的作用：

`Normalization(x)`: $\dfrac{x - min(x)}{max(x) - min(x)}$ 

`Coefficient_map(x, thre)`: $\dfrac{1}{1 + exp(50*(x - thre))}$

`normfun(x, mu, sigma)`:$\dfrac{exp(-\frac{(x - mu)^2}{2 * \sigma^2})}{\sigma * \sqrt{2*\pi}}$





可视化：

```python
def plot_images(img_list, img_wh, rank, save_path, text=None, margin=2):
    """
        img_list: list of images, float(0-1) or uint8(0-255), it is RGB order
    """
    row, col = rank
    assert row * col >= len(img_list)
    img_width, img_height = img_wh
    canv_width, canv_height = (img_width + margin) * col - margin, (img_height + margin) * row - margin
    canvas = np.zeros((canv_height, canv_width, 3), dtype=np.uint8)

    for i, img in enumerate(img_list):
        if img.dtype ==  np.dtype("float32") or img.dtype == np.dtype("float64"):
            if img.max() > 1 or img.min() < 0:
                img = (img - img.min()) / (img.max() - img.min())
            img = (img * 255).astype(np.uint8)

        img = cv2.resize(img, (img_width, img_height), interpolation=cv2.INTER_LINEAR)
        
        if img.ndim == 3: # rgb image
            pass
        elif img.ndim == 2:
            img = cv2.applyColorMap(img, cv2.COLORMAP_VIRIDIS)
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        else:
            raise ValueError("img dimension must be 2 or 3")
        up, left = (i//col)*(img_height+margin), (i%col)*(img_width+margin)
        canvas[up:up+img_height, left:left+img_width, :] = img
    if text is not None:
        cv2.putText(canvas, text, (5, 10), cv2.FONT_HERSHEY_COMPLEX, 0.5, (255, 0, 0))
    canvas = cv2.cvtColor(canvas, cv2.COLOR_RGB2BGR)
    cv2.imwrite(save_path, canvas)

    return cv2.cvtColor(canvas, cv2.COLOR_BGR2RGB)
```

```python
def vis(info, mat, ori, seg, pred, score):
    file_path = "./vision"
    if not os.path.exists(file_path):
        os.makedirs(file_path)
    filename = info.split('/')[-1]

    auroc, aupr, fpr = mat
    text = "aupr = %.3lf, fpr = %.3lf, auroc = %.3lf" % (float(aupr), float(fpr), float(auroc))

    # segmentation
    seg_color = colorEncode(seg, colors)

    # prediction
    pred_color = colorEncode(pred, colors)

    # anomaly gt
    ano = np.zeros_like(seg, np.uint8)
    ano[seg != 13] = 1
    ano_color = colorEncode(ano, colors)

    img_list = []
    img_list.append(ori)            # 原图
    img_list.append(seg_color)      # 语义分割gt
    img_list.append(pred_color)     # 语义分割预测
    img_list.append(ano_color)      # 异常gt
    img_list.append(score)          # 分数图 
    plot_images(img_list, (320, 180), (2, 3), os.path.join(file_path, filename), text)
```

```python
vinfo = batch_data['info']
vori = batch_data['img_ori']
vseg = seg_label
vpred = pred
vconf = conf
vlogit = logit
vprob_map = conf
vis(vinfo, mat, vori, vseg, vpred, -vprob_map)
```


### 数据集

StreetHazards

StreetHazards最异常的物体是大型稀有运输机器，如直升机、飞机和拖拉机

## DMLNet边界处理

### 传统方法cv2



```python
# 加载 opencv 和 numpy
import cv2
import numpy as np
# 以灰度图形式读入图像
img = cv2.imread('./DMLNet/anomaly/data/streethazards/test/images/test/t5/1.png', 0)
v1 = cv2.Canny(img, 80, 150, (3, 3))
v2 = cv2.Canny(img, 50, 100, (5, 5))
# np.vstack():在竖直方向上堆叠
# np.hstack():在水平方向上平铺堆叠
ret = np.hstack((v1, v2))
saveFile = "./1-.png"  # 保存文件的路径
cv2.imwrite(saveFile, ret)  # 保存图像文件
```





```python
# Candy 提取边界
img = batch_data['img_ori']
v1 = cv2.Canny(img, 80, 150, (3, 3))
```

在得到最后的异常map后，进行后处理

```python
# 结合Candy的提取结果
for i in range(len(v1)):
    for j in range(len(v1[0])):
        if v1[i][j] == 255:
            conf[i][j] = 1
```

在边界位置，也就是candy提取出的位置(v1[i,j] = 1)，将类别分数置为1

> 直接置为1是最好的选择吗？可能也会导致一些异常被置为了1，可能有一个数值的设定能够让最后的结果最优，假定为x
>
> x有什么含义或其他意义吗？能够以这个数值去将其他结果优化的更好吗？对于现实应用是否有意义？
>
> 是否能够基于x已知的情况下再做一些处理？



首先确定了两个双阈值，效果如下：
![image-20220621004928891](https://s1.vika.cn/space/2022/06/21/8858c6971aa74bd6ba52beea4c496fe9)

根据现在的DMLNet的效果对比：
<img src="https://s1.vika.cn/space/2022/06/21/5c32d2c7d85d49bc9ec619f1f3e6b885" alt="image-20220621005013559" style="zoom:50%;" />



发现Candy算子提取的边缘过于细节，所以继续调大阈值

```python
v1 = cv2.Canny(img, 300, 300, (3, 3))
v2 = cv2.Canny(img, 200, 300, (5, 5))
```

![image-20220621073913807](https://s1.vika.cn/space/2022/06/21/12773f34a5894c2f8f0797ab96a3ebd3)





#### 定性分析

`v1 = cv2.Canny(img, 180, 300, (3, 3))`
<img src="https://s1.vika.cn/space/2022/06/21/055f56955d28496387d80040112fd7d9" alt="image-20220621092443846" style="zoom:20%;" />

`v1 = cv2.Canny(img, 80, 150, (3, 3))`
<img src="https://s1.vika.cn/space/2022/06/21/e6741604b57348859449c7fecc4c0aff" alt="image-20220621092633981" style="zoom:20%;" />



#### 定量分析

修改对于IoU和准确度无影响。



不加Candy算子之前

```python
[Eval Summary]:
Mean IoU: 0.4975, Accuracy: 89.60%, Inference Time: 0.7467s
mean auroc =  0.9336512339662935 mean aupr =  0.14436207206590693  mean fpr =  0.18576746718088347
```

加上Candy算子：cv2.Canny(img, 80, 150, (3, 3))

```python
[Eval Summary]:
Mean IoU: 0.4975, Accuracy: 89.60%, Inference Time: 3.8104s
mean auroc =  0.899140196495888 mean aupr =  0.04883270392685814  mean fpr =  0.20719135712010475
Evaluation Done!
```

不过可以发现，推理时间明显增加了。后续需要重新思考代码实现，探索是否能换成更有效率的方式。

|                | 原始                | 原始+Candy          |      |
| -------------- | ------------------- | ------------------- | ---- |
| Inference Time | 0.7467              | 3.8104              |      |
| mean auroc     | 0.9336512339662935  | 0.899140196495888   |      |
| mean aupr      | 0.14436207206590693 | 0.04883270392685814 |      |
| mean fpr       | 0.18576746718088347 | 0.20719135712010475 |      |

error？

```python
[Eval Summary]:
Mean IoU: 0.4975, Accuracy: 89.60%, Inference Time: 2.1758s
mean auroc =  0.7614915879740766 mean aupr =  0.11675286378571968  mean fpr =  0.9861201381085487
Evaluation Done!
```

- auroc的一些解释：

  - 均匀抽取的随机阳性样本排名在均匀抽取的随机阴性样本之前的期望


  - 阳性样本排名在均匀抽取的随机阴性样本之前的期望比例


  - 若排名在一个随机抽取的随机阴性样本前分割，期望的真阳性率


  - 阴性样本排名在均匀抽取的随机阳性样本之后和期望比例


  - 若排名在一个均匀抽取的随机阳性样本后分割，期望的假阳性率


- fpr，假阳性率，FPR越高，我们错误分类的阴性数据点就越多。也就是把正常点分类为异常点的数据越高。

- aupr：

  - PR：召回率和正确率组成的曲线图

  - 如果只有较高的召回率，只能说明可以预测出较多的数据，但并不能保证预测出的样本是正确的。
    如果只有较高的正确率，说明所预测的样本的正确的，但只能是很少一部分数据集。



计算指标的代码：

```python
def eval_ood_measure(conf, seg_label, cfg, mask=None):
    out_labels = cfg.OOD.out_labels		# (13，) tuple, len = 1
    if mask is not None:
        seg_label = seg_label[mask]

    # conf = conf[seg_label != -1]
    # seg_label = seg_label[seg_label != -1]

    out_label = seg_label == out_labels[0]		# (720,1280), bool, 异常OOD为1，ID为0
    for label in out_labels:					# 遍历外分布的标签
        out_label = np.logical_or(out_label, seg_label == label)	# 分割标签 == 当前OOD标签 ｜ 分布外标签(第0类的异常)

    in_scores = - conf[np.logical_not(out_label)]	# ndarry:(910538,), float32, 非异常的分数取负数
    out_scores  = - conf[out_label]	# n darry:(11062,),float32, 异常分数取负数

    if (len(out_scores) != 0) and (len(in_scores) != 0):	# 异常和非异常的像素数量都不是0
        auroc, aupr, fpr = anom_utils.get_and_print_results(out_scores, in_scores)
        return auroc, aupr, fpr
    else:	# 没有异常，或者全是异常(没有正常)
        print("This image does not contain any OOD pixels or is only OOD.")
        return None
```

> ```python
> _C.OOD = CN()
> _C.OOD.exclude_back = False
> _C.OOD.ood = "msp"
> _C.OOD.out_labels = (13,)
> ```
>

```python
def get_and_print_results(out_score, in_score, num_to_avg=1):

    aurocs, auprs, fprs = [], [], []

    measures = get_measures(out_score, in_score)	# 传参，(ODD分数的负数, ID分数的负数)
    aurocs.append(measures[0]); auprs.append(measures[1]); fprs.append(measures[2])

    auroc = np.mean(aurocs); aupr = np.mean(auprs); fpr = np.mean(fprs)

    return auroc, aupr, fpr
```



```python
def get_measures(_pos, _neg, recall_level=recall_level_default):	# ODD，ID
    pos = np.array(_pos[:]).reshape((-1, 1))
    neg = np.array(_neg[:]).reshape((-1, 1))
    examples = np.squeeze(np.vstack((pos, neg)))	# 在竖直方向上堆叠，ODD分数，ID分数
    labels = np.zeros(len(examples), dtype=np.int32)
    labels[:len(pos)] += 1	# 异常标签是1

    auroc = sk.roc_auc_score(labels, examples)
    aupr = sk.average_precision_score(labels, examples)
    fpr = fpr_and_fdr_at_recall(labels, examples, recall_level)	# 传参：(标签, 分数样本, 0.95)

    return auroc, aupr, fpr
```



```python
def fpr_and_fdr_at_recall(y_true, y_score, recall_level=recall_level_default, pos_label=None):
    classes = np.unique(y_true)
    if (pos_label is None and
            not (np.array_equal(classes, [0, 1]) or
                     np.array_equal(classes, [-1, 1]) or
                     np.array_equal(classes, [0]) or
                     np.array_equal(classes, [-1]) or
                     np.array_equal(classes, [1]))):
        raise ValueError("Data is not binary and pos_label is not specified")
    elif pos_label is None:
        pos_label = 1.

    # make y_true a boolean vector
    y_true = (y_true == pos_label)

    # sort scores and corresponding truth values
    desc_score_indices = np.argsort(y_score, kind="mergesort")[::-1]
    y_score = y_score[desc_score_indices]
    y_true = y_true[desc_score_indices]

    # y_score typically has many tied values. Here we extract
    # the indices associated with the distinct values. We also
    # concatenate a value for the end of the curve.
    distinct_value_indices = np.where(np.diff(y_score))[0]
    threshold_idxs = np.r_[distinct_value_indices, y_true.size - 1]

    # accumulate the true positives with decreasing threshold
    tps = stable_cumsum(y_true)[threshold_idxs]
    fps = 1 + threshold_idxs - tps      # add one because of zero-based indexing

    thresholds = y_score[threshold_idxs]

    recall = tps / tps[-1]

    last_ind = tps.searchsorted(tps[-1])
    sl = slice(last_ind, None, -1)      # [last_ind::-1]
    recall, fps, tps, thresholds = np.r_[recall[sl], 1], np.r_[fps[sl], 0], np.r_[tps[sl], 0], thresholds[sl]

    cutoff = np.argmin(np.abs(recall - recall_level))

    return fps[cutoff] / (np.sum(np.logical_not(y_true)))   # , fps[cutoff]/(fps[cutoff] + tps[cutoff])
```



### SML

基本思路：找到边界，进行pooling

保存conf和label(均为numpy类型)，便于调试：
```python
np.savetxt("./try/label_{}".format(cnt), seg_label)
label = np.loadtxt("try/label_3")

np.savetxt("./try/conf_{}".format(cnt), conf)
res = np.loadtxt("try/conf_3")
```

```python
l1 = label.unsqueeze(0).unsqueeze(0)
boundaries = find_boundaries(l1)	# 寻找边界
```



- 最大池化因为取的是最大值所以可以提取到**边缘性**的信息

- 平均池化因为考虑了感受野中所有 pixel 的平均信息所以生成的特征也会更加平滑




#### 平均池化

可视化结果：
![image-20220708091609053](https://s1.vika.cn/space/2022/07/08/8bf759d798f747518fbfd8f279a09f40)

选择平均池化，思路：将结果map进行平均池化，在边界位置用这个答案替换原map

```python
[Eval Summary]:
Mean IoU: 0.4975, Accuracy: 89.60%, Inference Time: 0.9566s
mean auroc =  0.9339428510145064 mean aupr =  0.1447878389283098  mean fpr =  0.1845373580992796
Evaluation Done!
```

Cmp:

```python
Mean IoU: 0.4975, Accuracy: 89.60%, Inference Time: 0.7467s
mean auroc =  0.9336512339662935 mean aupr =  0.14436207206590693  mean fpr =  0.18576746718088347
```


发现AvgPool不管是在定性还是定量分析上，都和原结果没有很大的差别。

分析原因：最后判断是根据阈值，平均池化后可能仍然与原来没有很大区别。

所以尝试采用最大池化MaxPool

```python
mean auroc =  0.932561371097393 mean aupr =  0.14709254912634864  mean fpr =  0.1920421793169237
```










# 论文阅读

## 引言

Classical close-set semantic segmentation networks have limited ability to detect out-of-distribution (OOD) objects, which is important for safety-critical applications such as autonomous driving. Incrementally learning these OOD objects with few annotations is an ideal way to enlarge the knowledge base of the deep learning models. In this paper, we propose an open world semantic segmenta- tion system that includes two modules: 

(1) ==an open-set semantic segmentation module to detect both in-distribution and OOD objects==.

(2) an incremental few-shot learning module to gradually incorporate those OOD objects into its existing knowledge base. 

This open world semantic segmentation system behaves like a human being, which is able to identify OOD objects and gradually learn them **with corresponding supervision**. 

We adopt the ==Deep Metric Learning Network (DMLNet) with contrastive clustering== to implement open-set semantic segmentation. Compared to other open-set semantic segmentation methods, our DMLNet achieves state-of-the-art performance on three challenging open-set semantic segmentation datasets without using additional data or generative models. 

On this basis, two incremental few-shot learning methods are fur- ther proposed to progressively improve the DMLNet with the annotations of OOD objects

---

经典的闭集语义分割网络检测分布外 (OOD) 对象的能力有限，这对于自动驾驶等安全关键型应用很重要。 增量学习这些带有少量注释的 OOD 对象是扩大深度学习模型知识库的理想方法。 在本文中，我们提出了一个开放世界语义分割系统，包括两个模块：

(1) **一个开放集语义分割模块，用于检测内分布和OOD对象。**  

~~(2) 一个增量的小样本学习模块，逐渐将这些 OOD 对象纳入其现有的知识库。~~ 

这个开放世界的语义分割系统就像一个人，能够识别OOD对象并在相应的监督下逐渐学习它们。 

我们采用具有==对比聚类的深度度量学习网络（DMLNet）==来实现开放集语义分割。 与其他开放集语义分割方法相比，我们的 DMLNet 在三个具有挑战性的开放集语义分割数据集上实现了最先进的性能，而无需使用额外的数据或生成模型。 

~~在此基础上，进一步提出了两种增量少样本学习方法，通过 OOD 对象的注释逐步改进 DMLNet~~



## 6. Conclusion

We introduce an open world semantic segmentation system which incorporates two modules: 

- an open-set segmentation module 
- an incremental few-shot learning module.

Our proposed open-set segmentation module is based on the **deep metric learning network**, and it uses the **Euclidean distance sum** criterion to achieve state-of-the-art performance. 

Two incremental few-shot learning methods are proposed to broaden the perception knowledge of the network. Both modules of the open world semantic segmentation system can be further studied to improve the performance. We hope our work can draw more researchers to contribute to this practically valuable research direction.

---

我们介绍了一个开放世界语义分割系统，它包含两个模块：一个开放集分割模块和一个增量小样本学习模块。 

我们提出的开放集分割模块基于深度度量学习网络，它使用==欧几里德距离和标准==来实现最先进的性能。 

提出了两种增量少样本学习方法来拓宽网络的感知知识。 开放世界语义分割系统的两个模块都可以进一步研究以提高性能。 我们希望我们的工作能够吸引更多的研究人员为这个具有实际价值的研究方向做出贡献



## 1. 介绍

得益于高质量的数据集 [3,4,5]，深度卷积网络在语义分割任务 [1, 2] 中取得了巨大成功。 这些语义分割网络在许多应用中被用作感知系统，如自动驾驶[6]、医疗诊断[7]等。然而，这些感知系统中的大多数都是闭集和静态的。 闭集语义分割假设测试中的所有类都已经在训练期间参与，这在开放世界中是不正确的。 如果闭集系统错误地将分发中标签分配给 OOD 对象 [8]，它可能会在安全关键型应用程序（如自动驾驶）中造成灾难性后果。 同时，静态感知系统无法根据所见内容更新其知识库，因此，它仅限于特定场景，需要在一定时间后重新训练。 为了解决这些问题，我们提出了一种开放集的动态感知系统，称为开放世界语义分割系统。 它包含两个模块：  

（1）一个开放集语义分割模块，用于检测OOD对象并将正确的标签分配给分布中的对象。

  (2) 一个增量的小样本学习模块，将这些未知对象逐步合并到其现有的知识库中。

  我们提出的开放世界语义分割系统的整个流程如**图 1** 所示  

开放集语义分割和增量小样本学习都没有得到很好的解决。 

对于开集语义分割，最重要的部分是在一张图像的所有像素中识别OOD像素，称为异常分割。 异常分割的典型方法是将图像级的开集分类方法应用于像素级的开集分类。 

这些方法包括基于不确定性估计的方法 [9, 10, 11, 12] 和基于自动编码器的方法 [13, 14]。 然而，这两种方法已被证明在驾驶场景中无效，因为基于不确定性估计的方法==会给出许多假阳性异常值检测== [15] 并且自动编码器==无法重新生成复杂的城市场景== [16]。 最近，基于生成对抗网络（基于 GAN）的方法 [16, 17] 已被证明是有效的，但它们远==非轻量级==，因为它们需要在管道中使用多个深度网络。 

对于增量少样本学习，我们不仅要处理增量学习的挑战，例如灾难性遗忘[18]，还要处理少样本学习的挑战，包括从少量样本中提取代表性特征[19]  

在本文中，我们建议使用 DMLNet 来解决开放世界语义分割问题。 原因有三：  

(1) DMLNet的分类原理是基于**对比聚类**，可以有效识别异常物体，如**图2**所示
![image-20220427093204641](https://img-blog.csdnimg.cn/img_convert/3059369fae53d17d9774372efde6308d.png)

> 度量学习：从数据中学习一种度量数据对象间距离的方法。其目标是使得在学得的距离度量下，相似对象间的距离小，不相似对象间的距离大。
>
> 传统的度量学习方法只能学习出线性特征，虽然有一些能够提取非线性特征的核方法被提出，但对学习效果也没有明显提升
>
> 深度度量学习：深度学习的激活函数学习非线性特征的优秀能力，深度学习方法能够自动地从原始数据中学出高质量的特征。因此深度学习的网络结构与传统的度量学习方法相结合能够带来理想的效果。

~~(2) DMLNet结合原型非常适合few-shot 任务[19]。~~    

~~(3) DMLNet 的增量学习可以通过添加新的原型来实现，这是一种自然而有用的方法 [20]。~~

 基于 DMLNet 架构，我们为开放集语义分割模块开发了两种未知识别标准，为增量少样本学习模块开发了两种方法。

   根据我们的实验，这两个模块都被验证为有效且轻量级的。 总而言之，我们的贡献如下：    

- 我们率先推出开放世界语义分割系统，在实际应用中更加稳健实用。
- 我们提出的基于 DMLNet 的开放集语义分割模块在三个具有挑战性的数据集上实现了最先进的性能。
- 我们提出的few-shot 增量学习模块方法在很大程度上缓解了灾难性遗忘问题。
- 通过结合我们提出的开放集语义分割模块和增量少样本学习模块，实现了一个开放世界语义分割系统。



## 2. Related Work

#### 2.1 异常语义分割 

异常语义分割的方法可以分为两种趋势：  基于不确定性估计的方法和基于生成模型的方法。

不确定性估计的基线是最大softmax概率（MSP），它首先在[9]中提出。  Dan 等人没有使用 softmax 概率。  [11]提出使用最大logit（MaxLogit）并取得更好的异常分割性能。 贝叶斯网络采用深度学习网络的概率观点，所以它们的权重和输出是概率分布而不是特定的数字 [21, 22]。 在实践中，Dropout [10] 或集成 [12] 通常用于近似贝叶斯推理。 

自动编码器（AE）[23, 13] 和 RBM [14] 是典型的生成方法，假设 OOD 图像的重建误差大于分布内图像  

最近，另一种基于 GAN 再合成的生成模型被证明可以基于其可靠的高分辨率像素到像素转换结果实现最先进的性能。  SynthCP [17] 和 DUIR [16] 是基于 GAN 再合成的两种方法。 不幸的是，它们离轻量级还很远，因为必须依次使用两个或三个神经网络来进行 OOD 检测。 

与它们相比，我们证明了基于对比聚类的 DMLNet 具有更好的异常分割性能，而只需要推理一次  

#### 2.2 深度度量学习网络

DMLNets 已用于多种应用，包括视频理解 [24] 和人员重新识别 [25]。  DMLNet 使用欧几里得、马氏距离或 Matusita 距离 [26] 将此类问题转换为计算度量空间中的嵌入特征相似度。

**卷积原型网络和 DMLNets** 通常一起用于解决特定问题，例如检测图像级 OOD 样本 [27、28、29] 和用于语义分割的小样本学习 [19、30、31]。 我们也按照这种组合构建了第一个用于开放世界语义分割的 DMLNet  

#### 2.3 开放世界分类和检测 

开放世界分类首先由 [32] 提出。这项工作提出了最近非异常值 (NNO) 算法，该算法在增量添加对象类别、检测异常值和管理开放空间风险方面非常有效。
    最近约瑟夫等人。  [33]提出了一种基于对比聚类、未知感知提议网络和基于能量的未知识别标准的开放世界对象检测系统。 我们的开放世界语义分割系统的管道与他们的相似，除了两个重要的区别使我们的任务更具挑战性：（1）在他们的开放集检测模块中，他们依赖于区域提议网络（RPN）是 类不可知，因此也可以检测到未标记的潜在 OOD 对象。 这样，OOD样本的信息对于训练是有效的。 但是，我们专注于语义分割，其中训练中使用的每个像素都被分配了一个分布内标签，因此**不能将 OOD 样本添加到训练中**。  (2) 在增量学习模块中，他们使用新类的所有标记数据，而我们专注于自然更困难的少样本条件。 很少有研究集中在增量小样本学习上，其中包括用于分类的增量小样本学习[34]、对象检测[35]和语义分割[36]

## 3. 开放世界语义分割



在本节中，我们给出了开放世界语义分割系统的工作流程。 该系统由一个开放集语义分割模块和一个增量小样本学习模块组成。 假设$\mathcal{C}_{in} = \{\mathcal{C}_{in,1}, \mathcal{C}_{in,2},...,\mathcal{C}_{in,N} \}$  是 N 个分布内的类，它们都在训练数据集中进行了注释，并且 $\mathcal{C}_{out} = \{\mathcal{C}_{out,1},\mathcal{C}_{out,2},...,\mathcal{C}_{out,M} \}$ 是训练数据集中没有遇到的 M 个 OOD 类  

**开集语义分割模块**又分为两个子模块：**闭集语义分割子模**块和**异常分割子模块**。 

-  $\hat{Y}^{close}$ 是闭集语义分割子模块的输出图，所以每个像素的类别 $\hat{Y}^{close}_{i,j} ∈ C_{in}$。 
-  异常分割子模块的功能是识别OOD像素，其输出称为异常概率图：$\hat{P} \in [1,0]^{H \times W}$，其中 $H$ 和 $W$ 表示输入图像的高度和宽度。 

基于 $\hat{Y}_{close}$ 和 $\hat{P}$，开集语义分割图 $\hat{Y}^{open}$ 给出为:
$$
\hat{Y}^{open}_{i,j} = 
\begin{cases}
\mathcal{C}_{anomaly} \quad \     \hat{P}_{i,j} > \lambda_{out} \\
\hat{Y}_{i,j}^{close} \quad \quad \hat{P}_{i,j} \le \lambda_{out}
\end{cases} \tag{1}
$$
$\mathcal{C}_{anomaly}$ ：表示 OOD 类别
$λ_{out}$ ：确定 OOD 像素的阈值。

因此，openset语义分割模块应该识别OOD像素并分配正确的分布标签。然后 Yopen 可以转发给可以从 $C_{out}$ 中识别 $C_{anomaly}$ 并给出新类的相应注释的标注者  增量少样本学习模块用于在有新标签时将近集分割子模块的知识库从 $C_{in}$ 一个一个更新为 $C_{in+M}$，其中 $C_{in+t} = Cin \cup \{C_{out,1},C_{out,2},...,C_{out,t}\},t ∈{1,2,...,M}$。 **图 1** 显示了开放世界语义分割系统的循环工作流水线 

图 1. 开放世界语义分割系统。 第 1 步：识别已知和未知对象（蓝色箭头）。 第 2 步：注释未知对象（红色箭头）。 第 3 步：应用增量少样本学习来增加网络的分类范围（绿色箭头）。 第 4 步：在增量少样本学习之后，DMLNet 可以在更大的域中输出结果（紫色箭头）。
![image-20220420232032090](https://img-blog.csdnimg.cn/img_convert/a0bd42a6330af3e8f0f98b7db6003fa9.png)



## 4. 方法

我们采用 DMLNet 作为我们的特征提取器，并在 4.1 节讨论架构和损失函数。 开放集分割模块和增量少样本学习模块在 4.2 和 4.3 节中进行了说明

### 4.1 深度度量学习网络

> Classical CNN-based semantic segmentation networks can be disentangled into two parts: 
>
> - a feature extractor $f(X;θ_f)$ for obtaining the embedding vector of each pixel 
> - a classifier $g(f(X;θ_f);θ_g)$ for generating the decision boundary, 
>
> where $X$, $θ_f$ and $θ_g$ denote the **input image**, **parameters** of the feature extractor and classifier respectively. 
>
> This learnable classifier is not suitable for OOD detection because it assigns all feature space to known classes and leaves no space for OOD classes. 

传统CNN-based语义分割网络：

- $f(X;\theta_f)$ 特征提取器：获取每个像素的嵌入向量
- $g(f(X;\theta_f);\theta_g)$ 分类器：生成决策边界

这种==可学习的分类器不适用于 OOD 检测==，因为它将所有特征空间分配给已知类，并且没有为 OOD 类留下空间。 

> In contrast, the classifier is replaced by the Euclidean distance representation with all prototypes $\mathcal{M}_{in} = \{ m_t \in \mathbb{R}^{1 \times N}|t \in \{1,2,...,N\}  \}$ in DMLNet, where $m_t$ refers to the prototype of class $\mathcal{C}_{in,t}$. The feature extractor $f(X;θ_f)$ learns to map the input $X$ to the feature vector which has the same length as the prototype in metric space. For the close-set segmentation task, the probability of one pixel $X_{i,j}$ belonging to the class $\mathcal{C}_{in,t}$ is formulated as:

DMLNet 中, ==所有原型的欧几里得距离==表示代替了传统的可学习分类器

- $m_t$ 指的是 $\mathcal{C}_{in,t}$ 类的原型。

特征提取器 $f(X;θ_f)$学习将输入 X 映射到与度量空间中的原型长度相同的特征向量。 

对于闭集分割任务，一个像素 $X_{i,j}$ 属于类 $\mathcal{C}_{in,t}$ 的概率公式为： 
$$
p_t(X_{i,j}) = \frac{exp(-||f(X;\theta_f)_{i,j} - m_t||^2)}{\sum^N_{t'=1} exp(-||f(X;\theta_f)_{i,j} - m_{t'}||^2)} \tag{2}
$$


基于这种基于欧几里德距离的概率，**判别交叉熵 (DCE)** 损失函数 $\mathcal{L}_{DCE}(X_{i,j},Y_{i,j};θ_f,M_{in})$ [27] 定义为:
$$
\mathcal{L}_{DCE} = \sum_{i,j} -log (\frac{exp(-||f(X;\theta_f)_{i,j} - m_{Y_{i,j}}||^2)}{\sum^N_{k=1} exp(-||f(X;\theta_f)_{i,j} - m_{k}||^2)} \tag{3}
$$

$Y$：输入图像 $X$ 的标签
$\mathcal{L}_{DCE}$ 的分子和分母分别指图2中的吸引力和排斥力。 

> 排斥力不需要除去本身所属的类，本身类的原型吗？

图 2. DMLNet 的对比聚类。 在推理过程中，已知对象将被同一类的原型所吸引，而被剩余的原型所排斥。 最后，它们将围绕特定的原型进行聚合。 相反，异常对象将被所有原型排斥，因此它们将聚集在度量空间的中间。

![](https://img-blog.csdnimg.cn/img_convert/612d74a8faea61ce32297df9c175614a.png)

我们制定了另一个损失函数，称为**方差损失 (VL)** 函数 $\mathcal{L}_{VL}(X_{i,j},Y_{i,j};θ_f,M_{in})$，其定义为：
$$
\mathcal{L}_{VL} = \sum_{i,j} ||f(X;\theta_f)_{i,j} - m_{Y_{i,j}}||^2 \tag{4}
$$
$\mathcal{L}_{VL}$ 只有吸引力作用，没有排斥力作用。 

使用 DCE 和 VL，混合损失定义为：$\mathcal{L}= \mathcal{L}_{DCE} + λ_{VL}\mathcal{L}_{VL}$，其中 $λ_{VL}$ 是权重参数

### 4.2 开集语义分割模型

开集语义分割模块由闭集语义分割子模块和异常分割子模块组成。 开放集语义分割模块的流程如 图3 所示。

**图3**.闭集分割子模块包含在蓝色虚线框内，异常分割子模块包含在红色虚线框内。 开集分割图是这两个子模块生成的结果的组合。 在开放集分割图中预测分布内类和 OOD 类。  EDS map 和 MMSP map 的定义请参考 4.2 节。
![image-20220420113236739](https://img-blog.csdnimg.cn/img_convert/199103762c48247cdd50705bd8aae780.png)

- **闭集语义分割子模块**为一幅图像的所有像素分配分布标签。 由于一个像素 $X_{i,j}$ 属于类 $\mathcal{C}_{in,t}$ 的概率是用公式 2 表示，闭集分割图为：
  $$
  \hat{Y}_{i,j}^{close} = argmax_t \ p_t(X_{i,j}) \tag{5}
  $$

- **异常分割子模块**检测OOD像素。 我们提出了两个未知的识别标准来测量异常概率，包括_基于度量的最大softmax概率（MMSP）_和_欧几里得距离和（EDS）_。 

  - 以下是基于 MMSP 的异常概率：
    $$
    \hat{P}^{MMSP}_{i,j} = 1 - max \ p_t(X_{i,j}),\ t \in \{ 1,2,3...,N \} \tag{6}
    $$

  - EDS 是根据以下发现提出的：如果特征位于 OOD 像素聚集的度量空间的中心，则与所有原型的欧几里得距离和更小，即==异常的欧几里得距离较小==。  EDS 定义为：
    $$
    S(X_{i,j}) = \sum_{t=1}^N ||f(X;\theta_f)_{i,j} - m_t||^2 \tag{7}
    $$
    基于 EDS 的异常概率计算如下：
    $$
    \hat{P}^{EDS}_{i,j} = 1- \frac{S(X_{i,j})}{maxS(X)} \tag{8}
    $$

EDS 是类独立的，因此所有类的原型应该均匀分布在度量空间中，并且在训练期间不移动。 ==可学习的原型会在训练期间导致不稳定，并且对更好的性能没有贡献== [37]。 因此，我们以 one-hot 向量形式定义原型：只有 $m_t$ 的第 t 个元素是 $T$，而其他元素保持为零，其中 t ∈ {1,2,...,N}

> [[PAnS]]是什么情况？

EDS 是相对于所有像素之间的最大距离和的比率，即使图像中没有 OOD 对象，高异常分数区域肯定存在于每幅图像中。 此外，每个分布内类别的距离总和分布彼此略有不同，如图4所示。
![](https://img-blog.csdnimg.cn/img_convert/0d67bbc9c6b8ba396376bad696c5f660.png)


将MMSP与EDS相结合，以抑制那些实际上处于分布状态的具有中间响应的像素。

混合函数为：这里的含义是异常概率
$$
\hat{P} = \alpha \hat{P}^{EDS} + (1-\alpha)\hat{P}^{MMSP} \tag{9}
$$

- α ：
  $$
  \alpha = \frac{1}{1 + exp(-\beta(\hat{P}^{EDS} - \gamma))} \tag{10}
  $$

  - β 和 γ 是控制抑制效果和阈值的超参数。

通过方程 9 得到异常概率图和方程 5 得到闭集分割图后，我们应用方程 1 生成最终的开集分割图



## 5. 实验

Our experiments are divided into three parts. 

- We first evaluate our open-set semantic segmentation approach in Section 5.1. 
- ~~Then we demonstrate our incremental few-shot learning results in Section 5.2.~~ 
- ~~Based on the open-set semantic segmentation module and incremental few-show learning module, the whole open world semantic segmentation is realized in Section 5.3.~~

### 5.1 开集语义分割

 **数据集**。 三个数据集包括 StreetHazards [11]、Lost and Found [38] 和 Road Anomaly [16] 用于证明我们基于 DMLNet 的开放集语义分割方法的稳健性和有效性。  

- StreetHazards 的大多数异常物体是大型稀有运输机器，例如直升机、飞机和拖拉机。 
- Lost and Found 含许多小的异常物品，如货物、玩具和盒子。  
- Road Anomaly 数据集不再限制城市场景中的场景，还包含村庄和山脉的图像。

 **指标**。 开放集语义分割是封闭集分割和异常分割的组合，如 4.2 节所述。 

- 对于闭集语义分割任务，我们使用 mIoU 来评估性能。
- 对于异常分割任务，根据 [11] 使用三个指标，包括 ROC 曲线下面积（AUROC）、95% 召回的误报率（FPR95）和精确召回曲线下面积（AUPR）。

**实施细节**。 

- 对于 StreetHazards，我们遵循与 [11] 相同的训练程序，在 StreetHazards 的训练集上训练 PSPNet [2]。 

  > \[11]: Scaling out-of-distribution detection for real-world settings.

- 对于Lost and Found和 Road Anomaly，我们按照 [16] 使用 BDD-100k [39] 来训练 PSPNet。 请注意，PSPNet 仅用于提取我们在 4.1 节中讨论的特征（获得每个像素的嵌入向量）。 混合损失的 $λ_{VL}$ 为 0.01。   所有原型中非零元素 $T$ 为 3。等式 10 中的 β 和 γ 分别为 20 和 0.8。

  > \[16]: Detecting the unexpected via image resynthesis

**基线**。 

- StreetHazards:  MSP [9]、Dropout [10]、AE [13]、MaxLogit [11] 和 SynthCP [17]。 
- Lost and Found 和 Road Anomaly:  MSP、MaxLogit、Ensemble [12]、RBM [14] 和 DUIR [16]。

**结果**。

StreetHazards 的结果如表 1 所示。
![image-20220421080547891](https://img-blog.csdnimg.cn/img_convert/7af32b5d50560d198a2257c0403552c5.png)

对于 Lost and Found 和 Road Anomaly，mIoU 是无效的，因为它们只提供 OOD 类标签，但没有特定的分布内类标签。 结果在表 2 中。
![image-20220421080604032](https://img-blog.csdnimg.cn/img_convert/cc63fd7d97d7081dffe3de465d30dfb6.png)

我们的实验表明：

- 基于 DMLNet 的方法在所有三个异常分割相关指标中都达到了最先进的性能。 
- 与最近提出的基于 GAN 的方法（包括 DUIR 和 SynthCP）相比，我们的方法在异常分割质量方面优于它们，结构更轻量级，因为它们在整个流程中需要两个或三个深度神经网络，而我们只需要推理一次。  
- StreetHazards 中闭集分割的 mIoU 值表明我们的方法对闭集分割没有危害。

一些定性结果如图 8 所示  
![image-20220424132323338](https://img-blog.csdnimg.cn/img_convert/c5e1b4154631126fe31bd9d1048b62ba.png)

**消融研究**。 我们仔细进行了消融实验，研究了不同损失函数（VL 和 DCE）和异常判断标准（EDS 和 MMSP）的影响，如表 3 所示。
![](https://img-blog.csdnimg.cn/img_convert/8c7e4e19282709f61074e0ac5ec97503.png)

- DCE 在 mIoU 上的性能优于 VL 的事实表明了 排斥力。  
- EDS 在所有损失下都优于 MMSP 函数，这意味着==与类无关的标准更适合于异常分割任务==   

