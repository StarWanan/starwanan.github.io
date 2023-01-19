

CSDN同步更新：http://t.csdn.cn/P0YGb
博客园同步更新：https://www.cnblogs.com/StarTwinkle/p/16571290.html

【初步理解，更新补充中…】

Github：https://github.com/tianyu0207/PEBAL

# Article



---

Pixel-wise Energy-biased Abstention Learning for Anomaly Segmentation on Complex Urban Driving Scenes

复杂城市驾驶场景异常分割的像素级能量偏置弃权学习

<img src="https://s1.vika.cn/space/2022/08/07/dbcc149a1a9846ac815a88227b556521" alt="image-20220807090219904" style="zoom:30%;" />

---

```
@article{YuanhongChen2022PixelwiseEA,
  title={Pixel-wise Energy-biased Abstention Learning for Anomaly Segmentation on  Complex Urban Driving Scenes},
  author={Yuanhong Chen and Yu Tian and Yuyuan Liu and Guansong Pang and Fengbei Liu and Gustavo Carneiro},
  journal={arXiv: Computer Vision and Pattern Recognition},
  year={2022}
}
```



论文十问：

**Q1**论文试图解决什么问题？

> 复杂城市场景中，保证ID(in-distribution)对象分类准确前提下，准确识别出异常像素（OOD,Out-of-Distribution对象）
>
> in-distribution: 分布内对象，训练时已知的对象
> Out-of-Distribution: 异常对象，训练时未见过的对象



**Q2**这是否是一个新的问题？

> 之前已经有相关的研究，比如不确定度的方法和重建方法



**Q3**这篇文章要验证一个什么科学假设？

> 1. 自适应惩罚的放弃学习在像素集的异常检测中是有用的
> 2. 平滑性、稀疏性约束是有用的
> 3. 微调模型比重新训练效果更好



**Q4**有哪些相关研究？如何归类？谁是这一课题在领域内值得关注的研究员？

> 基于方法分类，比如：不确定度，重建
>
> 基于是否引入了异常像素进行分类，引入异常像素一般效果会比较好一些，但是也有一些缺点（如不可能引入真实世界的所有异常，可能会有危险）



**Q5**论文中提到的解决方案之关键是什么？

> 1. 将图像级的放弃学习应用到逐像素的异常检测上，采用自适应惩罚。
> 2. 微调模型，不重新训练



**Q6**论文中的实验是如何设计的？

> 在不同数据集上验证模型的整体性能。
>
> 消融实验证明AL，EBM以及这两个模块联合训练的有效性。
>
> 文章4.6节，选择了笔记本电脑等不可能在路上出现的物体、只选择一类异常进行训练，在Fishyscapes上仍达到了SOTA性能。这证明模型的稳健型，不需要仔细选择OE类，可以用于现实世界的自动驾驶系统。



**Q7**用于定量评估的数据集是什么？代码有没有开源？

> 1. LostAndFound
> 2. Fishyscapes
> 3. Road Anomaly
>
> 代码已经开源



**Q8**论文中的实验及结果有没有很好地支持需要验证的科学假设？

> 消融实验证明了每个模块的有效性和联合训练的有效性。
>
> 其他部分的实验结果也证明整体达到了SOTA性能



**Q9**这篇论文到底有什么贡献？

> 自适应惩罚放弃学习，能量模型，微调，平滑和稀疏约束



**Q10**下一步呢？有什么工作可以继续深入？

> 

## 名词解释

Outlier Exposure（OE）：离群点暴露。引入异常数据集训练异常检测器

Energy Based Model（EBM）：能量模型。对于一个模型有一个定义好的能量函数E(x,y)，这个函数当y是x的输出时小，y不是x的输出时大。在本文中局内点（inlier）的能量小，离群点（outlier）的能量大。采用了logsumexp算子

LSE: $logsumexp(x)_i = log \sum \limits_j exp(x_{ij})$ ，`torch.logsumexp`中采用了优化，避免了指数的上溢出或者下溢出

ECE：Expected Calibrated Error，预期校准误差。详情可见https://xishansnow.github.io/posts/144efbd1

> ECE：最小化期望校准误差
>
> 

## Abstract

背景：SOTA的异常分割方法都是基于不确定性估计和重建。

> uncertainty：
>
> 1. 直观
> 2. 假阳性，将正常像素检测为异常。某些hard-ID靠近分类边界
> 3. 假阴性，检测不出异常认为是正常像素。
>
> reconstruction：
>
> 1. 依赖分割结果
> 2. 额外网络难以训练；效率低
> 3. input不同导致分割模型变化则需要重新训练，适用性不高

提出了新的方法：PEBAL = AL + EBM, 两个模块联合训练

AL, Abstention Learning. 放弃学习，放弃将像素分类为ID标签，而是划分为异常。
EBM, Energy-based Model. 异常像素具有高能量，正常像素具有低能量

## Model

得到每像素的一个概率值
$$
p_{\theta}(y|\text{x})_w = \frac{exp(f_{\theta}(y;\text{x})_w)}{\sum_{y' \in \{1,...,Y+1\}} exp(f_{\theta}(y';\text{x})_w)}
$$

|            符号            | 意义                                              |
| :------------------------: | ------------------------------------------------- |
|          $\theta$          | 模型参数                                          |
|          $\omega$          | 图像点阵 $\Omega$ 中的像素索引                    |
| $p_{\theta}(y\|\text{x})_w$ | 标注像素 $\omega$ 在标签 $\{1,...,Y+1\}$ 上的概率 |
| $f_{\theta}(y;\text{x})_w$ | 像素 $\omega$ 在类别 $y$ 上的logit值[^1]          |

流程图：

<img src="https://s1.vika.cn/space/2022/08/09/e2e46dd2263d4ee4b21a49bf70505c25" alt="image-20220809190706827" style="zoom:100%;" />

|                     符号                     | 解释                                                         |
| :------------------------------------------: | ------------------------------------------------------------ |
|  $D^{in} = \{(x_i, y_i^{in})\}^{\|D^{in}\|}$   | inlier的训练图像和注释。<br />$x \in \mathcal{X} \subset \R^{H \times W \times C}$<br/>$y \in \mathcal{Y} \subset [0,1]^{H \times W \times Y}$ |
| $D^{out} = \{(x_i, y_i^{out})\}^{\|D^{out}\|}$ | outlier的训练图像和注释。<br />$y \in \mathcal{Y} \subset [0,1]^{H \times W \times (Y+1)}$ |

### （一）PEBAL_Loss

 <img src="https://s1.vika.cn/space/2022/08/09/c3184b48481f43de8a3e3f58dfe0167c" alt="image-20220809195506082" style="zoom:50%;" />

#### PAL_Loss

PAL（pixel-wise anomaly abstention loss）损失: 

1. 放弃outlier分类
2. 校准inlier类logit

最小化min $l_{pal}$ 就是对于log中的 变量 **最大化max**

 <img src="https://s1.vika.cn/space/2022/08/09/ac85d66fa25242e287304300c659eded" alt="image-20220809200858926" style="zoom:50%;" />

对于第一项，是像素对不同类的logit值

对于第二项，分子是像素在 Y+1 类处的logit值。(放弃预测)

针对类别c，两项就是类别c的logit值，和类别 Y+1 的logit值。考虑需要最大化谁的问题。

- 正常像素，惩罚系数高，鼓励进行有效预测
- 异常像素，惩罚系数低，鼓励进行放弃预测（Y+1类）



> 此损失函数是根据 Gambler's Loss(押注者损失) 优化改进而来
>
> 可参考链接：https://www.cnblogs.com/CZiFan/p/12676577.html
>
> 可参考论文：[Deep Gamblers: Learning to Abstain with Portfolio Theory](https://arxiv.org/abs/1907.00208)



#### EBM_Loss

EBM损失：确保inlier能量低，outlier能量高

<img src="https://s1.vika.cn/space/2022/08/09/9c86b004a6e644ef84463cbd05690df0" alt="image-20220809221631509" style="zoom:50%;" />
<img src="https://s1.vika.cn/space/2022/08/09/49cc3ae37a424ec3b655794183f90342" alt="image-20220809221649009" style="zoom:50%;" />

校准了inlier的logit值（减少了logit），同时共享相似的值，同时促进PAL的学习。[^2]



#### 能量

能量：inlier能量低，outlier能量高。通过最小化 $l_{ebm}$ 实现这一点。

反推过去，inlier的logit指数和更大，outlier的指数和更小。outlier更倾向于放弃分类（Y+1），所以前Y类的logit求和更小

 <img src="https://s1.vika.cn/space/2022/08/09/6042d5904d1d4d5c8ca46e29e5e59e51" alt="image-20220809200306070" style="zoom:50%;" />

放弃inlier分类的自适应惩罚：inlier惩罚系数高，outlier惩罚系数低

 <img src="https://s1.vika.cn/space/2022/08/09/effa1b2d54054e8c858c9a47ad116ed8" alt="image-20220809200702171" style="zoom:50%;" />



inlier & outlier的不同数值对比：

|         | $\sum\limits_{t\in\{1,...,Y\}}exp(f_{\theta})$（大于1） | $E_{\theta}$（能量是负数） | $a_w$（能量是负数有如下结果） | $\frac{1}{a_w}$（$a_w$保证非负） | 结果         |
| ------- | ------------------------------------------------------- | -------------------------- | ----------------------------- | -------------------------------- | ------------ |
| inlier  | 大                                                      | 小                         | 大                            | 小                               | 鼓励正常分类 |
| outlier | 小                                                      | 大                         | 小                            | 大                               | 鼓励放弃分类 |



#### reg_Loss

平滑性，稀疏性【正则项】

 <img src="https://s1.vika.cn/space/2022/08/09/2c4865bf9ac549b693b02f89b894c952" alt="image-20220809224526695" style="zoom:50%;" />

第一项：相邻像素之间差别不能太大

第二项：异常像素能量高，就可以使得周边像素与自己差别过大





### （二）Training

（一）设置 $D^{in}$ 和 $D^{out}$

不能重合

（二）加载预训练的权重

（三）fine-tune

只微调分类模块

 

### （三）Inference

通过公式(4)计算出像素的自由能分数

通过模型(1)得到inlier的分割结果

应用高斯平滑核产生最终的energy map



## Experiment

### Datasets

- LostAndFound
  - 1023张包含车辆前方小障碍的图片
  - 37类异常
  - 13种不同街道场景

- Fishyscapes
  1. FS LostAndFound
     - 100张来自LostAndFound的真实道路异常对象图片
     - 精细标签
  2. FS Static
     - 30张来自Pascal VOC的混合异常对象图片

- Road Anomaly
  - 60张来自互联网的包含车辆前方的真实道路异常图像，包含意想不到的动物岩石、圆锥体和障碍物。
  - 包含各种尺度和大小的异常物体，更具挑战性



###  Comparison on Anomaly Segmentation Benchmarks

LostAndFound testing set【WideResnet38】

- 超越baseline
- AP和FPR95相比之前SOTA方法有较大提升。其中SML平衡预测分数的内部类别差异，但大多LF测试集是道路类，没有其他类。
- 证明了检测远而小的物体的有效性、鲁棒性
- 改进了EBM和AL的baseline
- 较低的FPR，减少误报，更可能应用到现实世界。

 <img src="https://s1.vika.cn/space/2022/09/14/639f8f7216634c99845f12088501028b" alt="image-20220914005536027" style="zoom:70%;" />



Fishyscapes Leaderboard
- <img src="https://s1.vika.cn/space/2022/09/14/a8fdcf90cba7459a95875bf364cd988d" alt="image-20220914005849373" style="zoom:50%;" />



适用于广泛的分割模型，结果如下：

1. Fishyscapes validation sets (LostAndFound and Static), Road Anomaly testing set【WideResnet38】

<img src="https://s1.vika.cn/space/2022/09/14/f30eda3f9515430ab602393d51a2e884" alt="image-20220914010042501" style="zoom:50%;" />

2. Fishyscapes validation sets (LostAndFound and Static), Road Anomaly testing set【Resnet101】

<img src="https://s1.vika.cn/space/2022/09/14/22d703394fbd455589263fe01b0074db" alt="image-20220914010320875" style="zoom:50%;" />



### Ablation Study

LostAndFound

 <img src="https://s1.vika.cn/space/2022/09/14/56d02a619dbc40c583c06ced0e773f3c" alt="image-20220914152946092" style="zoom:50%;" />



- baseline：entropy maximisation (EM)

- 各模块有效性
- 联合训练有效性，自适应惩罚的重要性
- 平滑、稀疏正则化稳定训练并进一步提高性能



# Code

## 配置环境

clone代码：`git clone https://github.com/tianyu0207/PEBAL.git`

进入相应文件夹：`cd PEBAL`

创建conda虚拟环境：`conda env create -f pebal.yml`

查看CUDA版本`nvidia-smi`

<img src="https://s1.vika.cn/space/2022/07/14/52fd3e11fbf947069035142d7bd24e45" alt="image-20220714223955363" style="zoom:50%;" />



```
$ conda activate pebal
# IF cuda version < 11.0
$ pip install torch==1.8.1+cu102 torchvision==0.9.1+cu102 torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html
# IF cuda version >= 11.0 (e.g., 30x or above)
$ pip install torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 -f https://download.pytorch.org/whl/torch_stable.html
```



## 数据集准备

### cityscapes

1. 在官网注册账号
2. 使用脚本下载zip压缩包
3. 使用cityscapes脚本处理代码https://github.com/mcordts/cityscapesScripts
   - 需要labelTrainIds的预处理后的图片
4. 将需要的文件重命名 `rename 's/_labelTrainIds//' *.png`
5. 最终的文件目录如下： 
   -    <img src="https://s1.vika.cn/space/2022/09/07/8876b70d140644748ecf18bb7d727080" alt="image-20220907155845453" style="zoom:50%;" />

6. 修改config文件中的数据集路径`C.city_root_path = 'xxx/xxx/Cityscapes'`

### fishyscapes 

*You can alternatively download both preprocessed fishyscapes & cityscapes datasets* [here](http://robotics.ethz.ch/~asl-datasets/Dissimilarity/data_processed.tar) (token from synboost GitHub).

采用作者提供的链接下载fishyscapes数据集。下载好解压后，将final_dataset中的fs数据集对应的两个文件分别改名为LostAndFound和Static

结构如下：

 <img src="https://s1.vika.cn/space/2022/09/07/88a072df9374433c99a14824f35bcbb2" alt="image-20220907155650632" style="zoom:50%;" />

修改config文件中的数据集路径`C.fishy_root_path = 'xxx/xxx/final_dataset'`

### coco

1. 官网下载数据并解压
2. 使用预处理代码进行处理
3. 修改config文件中的数据集路径



## 开始

登陆wandb

```
(pebal) huan@2678:~/zyx/PEBAL$ wandb login
wandb: Logging into wandb.ai. (Learn how to deploy a W&B server locally: https://wandb.me/wandb-server)
wandb: You can find your API key in your browser here: https://wandb.ai/authorize
wandb: Paste an API key from your profile and hit enter, or press ctrl+c to quit: 
wandb: Appending key for api.wandb.ai to your netrc file: /home/huan/.netrc
(pebal) huan@2678:~/zyx/PEBAL$ 
```

修改config.py中的API key



### 推理

1. 下载预训练模型，并上传到服务器上。

please download our checkpoint from [here](https://drive.google.com/file/d/12CebI1TlgF724-xvI3vihjbIPPn5Icpm/view?usp=sharing) and specify the checkpoint path ("ckpts/pebal") in config file.

2. 开始训练

`python code/test.py`

FS验证集上运行结果如下：

```
[pebal][INFO] validating cityscapes dataset ... 
labeled: 1097402, correct: 1091358: 100%|███████████████████████████████████████████████████████████| 500/500 [1:17:15<00:00,  9.27s/it]
[pebal][CRITICAL] current mIoU is 0.895736885447597, mAcc is 0.979122587176078 

[pebal][INFO] validating Fishyscapes_ls dataset ... 
100%|██████████████████████████████████████████████████████████████████████████████████████████████████| 100/100 [04:32<00:00,  2.72s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_ls: 0.9896340042387362 
[pebal][CRITICAL] AUPRC score for Fishyscapes_ls: 0.588127504166506 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_ls: 0.04766274243599872 

[pebal][INFO] validating Fishyscapes_static dataset ... 
100%|████████████████████████████████████████████████████████████████████████████████████████████████████| 30/30 [01:17<00:00,  2.59s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_static: 0.9960209766813635 
[pebal][CRITICAL] AUPRC score for Fishyscapes_static: 0.9208418393359893 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_static: 0.015202855528294194 
```

文章中数据：<img src="https://s1.vika.cn/space/2022/09/14/f30eda3f9515430ab602393d51a2e884" alt="image-20220914010042501" style="zoom:50%;" />

作者运行结果如下：

```
[pebal][INFO] Load checkpoint from file /home/yuyuan/work_space/PEBAL/ckpts/pretrained_ckpts/cityscapes_best.pth, Time usage:
	IO: 0.6330766677856445, restore snapshot: 0.011519193649291992 
[pebal][INFO] validating Fishyscapes_ls dataset ... 
100%|██████████████████████████████████████████████████████████████████████████████████████████████████| 100/100 [01:46<00:00,  1.07s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_ls: 0.9371502892755115 
[pebal][CRITICAL] AUPRC score for Fishyscapes_ls: 0.16046114663246977 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_ls: 0.41779574363621813 
[pebal][INFO] validating Fishyscapes_static dataset ... 
100%|████████████████████████████████████████████████████████████████████████████████████████████████████| 30/30 [00:30<00:00,  1.02s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_static: 0.9590370905998604 
[pebal][CRITICAL] AUPRC score for Fishyscapes_static: 0.4168195788594434 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_static: 0.17780031807571348 
```





可视化结果：





### 训练

1. 下载预训练权重文件 [here](https://drive.google.com/file/d/1P4kPaMY-SmQ3yPJQTJ7xMGAB_Su-1zTl/view?usp=sharing)
4. put it in "ckpts/pretrained_ckpts" directory

3. `python code/main.py `开始训练



训练结果：

```
Fishyscapes_ls_auroc 0.9705
Fishyscapes_ls_auprc 0.42089
Fishyscapes_ls_fpr95 0.16731

Fishyscapes_static_auroc 0.99387
Fishyscapes_static_auprc 0.88232
Fishyscapes_static_fpr95 0.02532
```





训练LOG

```python
[pebal][CRITICAL] distributed data parallel training: off 
[pebal][CRITICAL] gpus: 1, with batch_size[local]: 8 
[pebal][CRITICAL] network architecture: deeplabv3+, with ResNet cityscapes backbone 
[pebal][CRITICAL] learning rate: other 1e-05, and head is same [world] 
[pebal][INFO] image: 900x900 based on 1024x2048 
[pebal][INFO] current batch: 8 [world] 
wandb: Currently logged in as: starwanan. Use `wandb login --relogin` to force relogin
W&B online, running your script from this directory will now sync to the cloud.
wandb: Currently logged in as: starwanan. Use `wandb login --relogin` to force relogin
wandb: wandb version 0.13.3 is available!  To upgrade, please run:
wandb:  $ pip install wandb --upgrade
wandb: Tracking run with wandb version 0.13.2
wandb: Run data is saved locally in /home/huan/zyx/pebal/wandb/run-20220913_112942-38qy6qzd
wandb: Run `wandb offline` to turn off syncing.
wandb: Syncing run try_pebal_exp
wandb: ⭐️ View project at https://wandb.ai/starwanan/OoD_Segmentation
wandb: 🚀 View run at https://wandb.ai/starwanan/OoD_Segmentation/runs/38qy6qzd
[pebal][CRITICAL] restoring ckpt from pretrained file /home/huan/zyx/pebal/ckpts/pretrained_ckpts/cityscapes_best.pth. 
module.final.6.weight torch.Size([19, 256, 1, 1])
module.branch1.final.6.weight torch.Size([20, 256, 1, 1]) partial loading ...
Load model, Time usage:
        IO: 4.291534423828125e-06, initialize parameters: 0.06872677803039551
[pebal][INFO] Load checkpoint from file /home/huan/zyx/pebal/ckpts/pretrained_ckpts/cityscapes_best.pth, Time usage:
        IO: 6.251967668533325, restore snapshot: 0.06990909576416016 
[pebal][INFO] training begin... 
epoch (0) | gambler_loss: 0.465 energy_loss: 0.371  : 100%|████████████████████████████████████████████| 409/409 [22:01<00:00,  3.23s/it]   
[pebal][INFO] Saving checkpoint to file /home/huan/zyx/pebal/ckpts/try_pebal_exp/epoch_0.pth.pth 
[pebal][INFO] Save checkpoint to file /home/huan/zyx/pebal/ckpts/try_pebal_exp/epoch_0.pth.pth, Time usage:
        prepare snapshot: 0.0013539791107177734, IO: 0.8835365772247314 
[pebal][INFO] validating Fishyscapes_ls dataset ... 
100%|██████████████████████████████████████████████████████████████████████████████████████████████████| 100/100 [04:55<00:00,  2.95s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_ls: 0.9469176408559574 
[pebal][CRITICAL] AUPRC score for Fishyscapes_ls: 0.26278222245999183 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_ls: 0.36874238225544764 
[pebal][INFO] validating Fishyscapes_static dataset ... 
100%|████████████████████████████████████████████████████████████████████████████████████████████████████| 30/30 [01:20<00:00,  2.68s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_static: 0.9814998962929938 
[pebal][CRITICAL] AUPRC score for Fishyscapes_static: 0.7383053563215358 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_static: 0.0916278752590028 
...
epoch (39) | gambler_loss: 0.257 energy_loss: 0.132  : 100%|███████████████████████████████████████████| 409/409 [21:41<00:00,  3.18s/it]
[pebal][INFO] Saving checkpoint to file /home/huan/zyx/pebal/ckpts/try_pebal_exp/epoch_39.pth.pth 
[pebal][INFO] Save checkpoint to file /home/huan/zyx/pebal/ckpts/try_pebal_exp/epoch_39.pth.pth, Time usage:
        prepare snapshot: 0.0013608932495117188, IO: 0.6262259483337402 
[pebal][INFO] validating Fishyscapes_ls dataset ... 
100%|██████████████████████████████████████████████████████████████████████████████████████████████████| 100/100 [04:35<00:00,  2.75s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_ls: 0.9704954978462503 
[pebal][CRITICAL] AUPRC score for Fishyscapes_ls: 0.42088903096085584 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_ls: 0.16730910370608532 
[pebal][INFO] validating Fishyscapes_static dataset ... 
100%|████████████████████████████████████████████████████████████████████████████████████████████████████| 30/30 [01:18<00:00,  2.63s/it]
[pebal][CRITICAL] AUROC score for Fishyscapes_static: 0.9938681013744728 
[pebal][CRITICAL] AUPRC score for Fishyscapes_static: 0.8823226404330519 
[pebal][CRITICAL] FPR@TPR95 for Fishyscapes_static: 0.025324225018300082 
wandb: Waiting for W&B process to finish... (success).
wandb:                                                                                
wandb: 
wandb: Run history:
wandb:     Fishyscapes_ls_auprc ▁▅▄▇▅▇▇█▇█▇▅▆▅▆▆█▇▇▆▅▇▆▆▇▅▅▅▅▅▅▄▅▆▆▆▆▆▆▅
wandb:     Fishyscapes_ls_auroc ▁▆▄▆▄▆▆▆▆▇▆▃▄▅▆▅█▆▆▅▄▆▅▆▇▄▅▅▅▅▅▅▅▆▆▆▅▆▆▅
wandb:     Fishyscapes_ls_fpr95 █▃▅▃▅▃▃▃▃▁▃▅▅▄▃▃▁▃▂▃▄▂▃▂▂▄▃▃▃▄▃▃▄▂▂▃▃▂▂▃
wandb: Fishyscapes_static_auprc ▁▆▆▆▇█▇█▇▇▇▇█▇▇██▆▇▇▅▆▆▆▇▆▇▆▆▇▆▅▇▇▇▇▇▇▇▇
wandb: Fishyscapes_static_auroc ▁▇▆▇▇█▇█▇▇█▇▇▇▇▇█▇█▇▆▇▅▆▇▆▇▆▆▇▇▅▆▇▇▆▇▇▇▇
wandb: Fishyscapes_static_fpr95 █▂▃▂▃▁▂▁▁▁▁▂▁▂▂▂▁▃▁▂▃▂▃▃▂▃▂▃▃▂▂▄▂▂▂▂▂▂▁▂
wandb:              energy_loss █▂▂▃▄▂▃▂▁▃▁▁▂▂▁▁▁▃▁▁▂▂▂▄▁▁▄▂▁▃▁▂▁▁▂▁▁▁▁▁
wandb:             gambler_loss █▂▂▃▆▃▂▂▁▄▁▁▃▂▁▃▁▄▁▁▂▁▂▃▁▁▄▃▁▅▁▄▂▁▃▂▁▁▁▁
wandb:              global_step ▁▁▁▁▂▂▂▂▂▃▃▃▃▃▃▄▄▄▄▄▅▅▅▅▅▅▆▆▆▆▆▇▇▇▇▇▇███
wandb: 
wandb: Run summary:
wandb:     Fishyscapes_ls_auprc 0.42089
wandb:     Fishyscapes_ls_auroc 0.9705
wandb:     Fishyscapes_ls_fpr95 0.16731
wandb: Fishyscapes_static_auprc 0.88232
wandb: Fishyscapes_static_auroc 0.99387
wandb: Fishyscapes_static_fpr95 0.02532
wandb:              energy_loss 0.13229
wandb:             gambler_loss 0.25728
wandb:              global_step 39
wandb: 
wandb: Synced try_pebal_exp: https://wandb.ai/starwanan/OoD_Segmentation/runs/38qy6qzd
wandb: Synced 6 W&B file(s), 320 media file(s), 0 artifact file(s) and 0 other file(s)
wandb: Find logs at: ./wandb/run-20220913_112942-38qy6qzd/logs
```







`NameError: name 'numpy' is not defined`

```python
-- Process 1 terminated with the following error:
Traceback (most recent call last):
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/multiprocessing/spawn.py", line 59, in _wrap
    fn(i, *args)
  File "/home/huan/zyx/PEBAL/code/main.py", line 106, in main
    trainer.train(model=model, epoch=curr_epoch, train_sampler=train_sampler, train_loader=train_loader,
  File "/home/huan/zyx/PEBAL/code/engine/trainer.py", line 59, in train
    current_lr = self.lr_scheduler.get_lr(cur_iter=curr_idx)
  File "/home/huan/zyx/PEBAL/code/engine/lr_policy.py", line 42, in get_lr
    return numpy.real(numpy.clip(curr_lr, a_min=self.end_lr, a_max=self.start_lr))
NameError: name 'numpy' is not defined
```

在对应文件加入`import numpy`即可解决



`ValueError: Expected more than 1 value per channel when training, got input size torch.Size([1, 256, 1, 1])`

```
Traceback (most recent call last):
  File "main.py", line 151, in <module>
    main(-1, 1, config=config, args=args)
  File "main.py", line 106, in main
    trainer.train(model=model, epoch=curr_epoch, train_sampler=train_sampler, train_loader=train_loader,
  File "/home/huan/zyx/PEBAL/code/engine/trainer.py", line 42, in train
    logits = model(imgs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/parallel/data_parallel.py", line 167, in forward
    outputs = self.parallel_apply(replicas, inputs, kwargs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/parallel/data_parallel.py", line 177, in parallel_apply
    return parallel_apply(replicas, inputs, kwargs, self.device_ids[:len(replicas)])
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/parallel/parallel_apply.py", line 86, in parallel_apply
    output.reraise()
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/_utils.py", line 429, in reraise
    raise self.exc_type(msg)
ValueError: Caught ValueError in replica 0 on device 0.
Original Traceback (most recent call last):
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/parallel/parallel_apply.py", line 61, in _worker
    output = module(*input, **kwargs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/zyx/PEBAL/code/model/network.py", line 13, in forward
    return self.branch1(data, output_anomaly=output_anomaly, Vision=Vision)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/zyx/PEBAL/code/model/wide_network.py", line 146, in forward
    x = self.aspp(x)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/zyx/PEBAL/code/model/wide_network.py", line 58, in forward
    img_features = self.img_conv(img_features)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/container.py", line 119, in forward
    input = module(input)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/module.py", line 889, in _call_impl
    result = self.forward(*input, **kwargs)
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/modules/batchnorm.py", line 135, in forward
    return F.batch_norm(
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/functional.py", line 2147, in batch_norm
    _verify_batch_size(input.size())
  File "/home/huan/anaconda3/envs/pebal/lib/python3.8/site-packages/torch/nn/functional.py", line 2114, in _verify_batch_size
    raise ValueError("Expected more than 1 value per channel when training, got input size {}".format(size))
ValueError: Expected more than 1 value per channel when training, got input size torch.Size([1, 256, 1, 1])
```

2.网上查找的原因为模型中用了batchnomolization，训练中用batch训练的时候当前batch恰好只含一个sample，而由于BatchNorm操作需要多于一个数据计算平均值，因此造成该错误。

3.解决方法：在torch.utils.data.DataLoader类中或自己创建的继承于DataLoader的类中设置参数drop_last=True，把不够一个batch_size的数据丢弃。

在查看源代码时，发现已经设置。batch_size的数量是：`batch_size = config.batch_size // engine.world_size`

想到了味了GPU内存数量够用，在config里面设置了batchsize = 4，这里world_size也是4，造成了最后为1的情况

但是发现这好像不是原因，因为distributed没有设成为True，所以莫名奇妙的，img在外面是8batch，进去就变成1了。

在调试debug的时候：进不去模型
```
Frame skipped from debugging during step-in.
Note: may have been skipped because of "justMyCode" option (default == true). Try setting "justMyCode": false in the debug configuration (e.g., launch.json).
```

是在自己配置的调试文件launch.json文件里面启用了JustMyCode，不调试第三方库，导致前向传播的forword没办法调试，所以把这个关掉，重新调试。




# 遗留问题
[^1]: logit的值域范围是多少？

[^2]: 为什么校准logit就是减少logit？”share similar values at the same time” 是什么意思？

- https://github.com/tianyu0207/PEBAL/issues/9，不能理解最后关于 PAL 的解释。额外通道是指outlier吗，add back 是什么



### 数据问题

1. $D_{out}$ 中异常物体大小，位置是怎么粘贴的。一张图片可以有多个类别吗



### 网络架构问题

1. 具体的训练过程是什么？
2. in、out两张图片是怎么被送进网络中的？
3. 网络最后的分类头是一个还是两个？架构图中紫色的部分具体结构和作用？



