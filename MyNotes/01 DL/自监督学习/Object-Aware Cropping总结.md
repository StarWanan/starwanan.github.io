### Random Crop
图像表征的自监督学习：cropping data augmentation 裁剪数据增强是一个重要的方法

![image.png](https://s1.vika.cn/space/2023/02/09/00cd6b84aa164d1180fab20e4b824118)
【Random Crop】
- workflow：
	- 选择一个随机比例（0.2到1.0）和一个随机长宽比（0.75到1.33）。使用这两个值（比例和长宽比）对原始图像进行裁剪
	- 裁剪的大小被调整为224×224像素
优点：裁剪后再调整大小，迫使表征集中在具有不同长宽比的物体的不同部分。这使得该表征对诸如比例和遮挡等自然变化具有==鲁棒性==


- 基本假设：随机裁剪后调整大小的图像区域共享有关于关注的对象信息，而学习到的表征将捕获这些信息
	- 满足假设 - ImageNet: 大型、居中的物体。
	- 不满足假设 - COCO, OpenImages: 代表现实世界中未经整理的数据，图像中通常有多个小物体。
缺点：随机场景crop不包含足够的物体信息，导致表示质量下降。

![image.png](https://s1.vika.cn/space/2023/02/09/42029d1aa7fa429cb4dc2a99a9290c82)

几种SSL方法的结果对比（backbone: resnet50）：
![image.png](https://s1.vika.cn/space/2023/02/08/02f5353af29647e5b51f7b1aa69ba712)

### 分析与动机
数据集：OpenImages, 910万张图像, 包含复杂场景和多个物体的图像(平均每张图像包含8个注释的物体)
- 有标记边界框的图像 - 以便与完全监督学习进行比较
- 有两个不同类别的物体的图像进行抽样 - 反映现实世界中未经整理的数据
- 至少有900张图片的类别 - 减轻类别分布不平衡的影响
创建子集：212753张图，208类，平均每张图有12个物体。


证明：==场景裁剪的范围==是SSL在OpenImages上表现不佳的主要原因之一，而不是与ImageNet的其他差异
- 物体大小
- 长尾分布
- ImageNet预训练
- 图像大小
- 对 ground-truth 物体进行剪裁
- 改变随机调整大小的crop下限比例
![image.png](https://s1.vika.cn/space/2023/02/08/a3a36f0f75e94c248654d86a743dc17e)

结论：监督训练和SSL训练之间的性能差距可能是由于==数据增强==，而不是图像分布的特点。



### Object-aware
上述分析表明：基于纯粹的物体裁剪或纯粹的场景裁剪的SSL方法，都比监督学习的表现差。

假设：由于场景和物体之间的自然关联，物体周围的环境有助于学习稳健的表征。所以如果仅仅是crop物体，将不能利用这种自然关联，而且这种关联性对于下游任务是有帮助的。

所以考虑==将物体和场景都纳入剪裁==。

为了实现 object-aware 考虑选用的 object-proposal 模型：==BING==、Edge-boxes、unsupervised-object-proposal

最终选用BING：
- 性能极快
- 能产生许多 proposal
- 对很对数据集有很好的通用性

四种crop类型：
- (a) 扩张object-proposal(Obj-Obj+Dilate): 扩张 BING proposal 来产生第二个视角
- (b) 场景-场景裁剪（Scene-Scene）: random crop
- (c) 移位object-proposal（Obj-Obj+shift）: 第一个框的预先指定的距离范围内随机选择的一个框
- (d) 随机裁剪（Obj-Scene）: first view: BING proposal; second view: random

注意：
- object-proposal 本身是图像的一部分，通常随机裁剪范围的默认下限值(0.2)导致裁剪的图像过小。$s_{min} = \dfrac{0.2}{平均BING建议尺寸}$
- 两个视角应该使用两个 project head。分别用于特定物体的表示，或者用于包含场景信息的表示

除了上述对裁剪方法的改变外，对SSL流程的其他部分保持不变：其他的数据增强，如颜色偏移，以通常的方式应用，损失函数和训练制度也没有改变。因此，我们的方法对大多数SSL流程只包含非常简单的改变，只涉及几行代码。

### Results

#### OpenImage
![image.png](https://s1.vika.cn/space/2023/02/08/02f5353af29647e5b51f7b1aa69ba712)
![image.png](https://s1.vika.cn/space/2023/02/08/7d77107c02534ff6bbcb52ab5f74e5b8)

- 表现最好的Obj-Obj+Dilate裁剪比基线要好8.2mAP
- Obj-Scene裁剪的表现也优于基线8.1mAP
- Obj-Obj+Shift裁剪（54.1 mAP）的表现不如Obj-Obj+Dilate或Obj-Scene
	- 第二个物体crop被选在离第一个物体crop一定的最小半径处
	- 第二个物体裁剪只包含物体的一部分，而一个扩张的物体裁剪有可能包含整个物体和更多的场景信息
- ground truth 边界框比使用BING裁剪的效果要好，表明紧密贴合物体周围不能改进表征

#### COCO 物体检测、语义分割
COCO trainval2017预训练

![image.png](https://s1.vika.cn/space/2023/02/09/7a60cf5bf9584591ac47ed36f33d087c)
- 方法更简单，表现更好


#### COCO物体检测、语义分割 & VOC物体检测
完整OpenImage预训练

![image.png](https://s1.vika.cn/space/2023/02/09/3061bb45f85f48f797517fa20c683e8e)
- 不仅适用于像COCO这样的小型多物体数据集，也适用于像OpenImages这样的数据集
- 迁移学习表现良好


### 结论
- 对象感知裁剪，这是一种简单、快速和高效的数据增强，可以替代随机场景裁剪。
- 在一些数据集的分类、物体检测和语义分割的自监督预训练中，物体裁剪的性能比场景裁剪明显提高。
- 该方法可以以无缝方式纳入大多数自监督学习流程。

