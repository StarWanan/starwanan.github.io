

`torch.nn.functional.interpolate(input, size=None, scale_factor=None, mode='nearest', align_corners=None, recompute_scale_factor=None)`

功能：利用插值方法，对输入的张量数组进行上\下**采样**操作，换句话说就是科学合理地改变数组的尺寸大小，尽量保持数据完整。

- `input(Tensor)`：需要进行采样处理的数组。
- `size(int或序列)`：输出空间的大小
- `scale_factor(float或序列)`：空间大小的乘数
- `mode(str)`：用于采样的算法。'nearest'| 'linear'| 'bilinear'| 'bicubic'| 'trilinear'| 'area'。默认：'nearest'
- `align_corners(bool)`：在几何上，我们将输入和输出的像素视为正方形而不是点。如果设置为True，则输入和输出张量按其角像素的中心点对齐，保留角像素处的值。如果设置为False，则输入和输出张量通过其角像素的角点对齐，并且插值使用边缘值填充用于边界外值，使此操作在保持不变时独立于输入大小scale_factor。
- `recompute_scale_facto(bool)`：重新计算用于插值计算的 scale_factor。当scale_factor作为参数传递时，它用于计算output_size。如果recompute_scale_factor的False或没有指定，传入的scale_factor将在插值计算中使用。否则，将根据用于插值计算的输出和输入大小计算新的scale_factor（即，如果计算的output_size显式传入，则计算将相同 ）。注意当scale_factor 是浮点数，由于舍入和精度问题，重新计算的 scale_factor 可能与传入的不同。

注意：

- 输入的张量数组里面的数据类型必须是float。
- 输入的数组维数只能是3、4或5，分别对应于时间、空间、体积采样。
- 不对输入数组的前两个维度(批次和通道)采样，从第三个维度往后开始采样处理。
- 输入的维度形式为：批量(batch_size)×通道(channel)×[可选深度]×[可选高度]×宽度(前两个维度具有特殊的含义，不进行采样处理)
- size与scale_factor两个参数只能定义一个，即两种采样模式只能用一个。要么让数组放大成特定大小、要么给定特定系数，来等比放大数组。
- 如果size或者scale_factor输入序列，则必须匹配输入的大小。如果输入四维，则它们的序列长度必须是2，如果输入是五维，则它们的序列长度必须是3。
- 如果size输入整数x，则相当于把3、4维度放大成(x,x)大小(输入以四维为例，下面同理)。
- 如果scale_factor输入整数x，则相当于把3、4维度都等比放大x倍。
- mode是’linear’时输入必须是3维的；是’bicubic’时输入必须是4维的；是’trilinear’时输入必须是5维的
- 如果align_corners被赋值，则mode必须是'linear'，'bilinear'，'bicubic'或'trilinear'中的一个。
- 插值方法不同，结果就不一样，需要结合具体任务，选择合适的插值方法。

————————————————
版权声明：本文为CSDN博主「视觉萌新、」的原创文章，遵循CC 4.0 BY-SA版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/qq_50001789/article/details/120297401
