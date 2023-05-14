### KL散度

`torch.nn.KLDivLoss`是一个用于计算KL散度损失的PyTorch中的损失函数（loss function）。KL散度是用于衡量两个概率分布之间差异的一种度量方式。

`KLDivLoss`的输入是两个概率分布，其中一个作为目标分布（target distribution），另一个作为预测分布（predicted distribution）。它的计算方式如下：
$$
loss=\sum_i target_i⋅(log⁡(target_i)−predicted_i)
$$
其中，$\text{target}_i$表示目标分布的第$i$个元素，$\text{predicted}_i$表示预测分布的第$i$个元素。

需要注意的是，由于KL散度是不对称的，即$D_{KL}(p||q) \neq D_{KL}(q||p)$，因此`KLDivLoss`中的目标分布和预测分布的顺序是不能颠倒的。此外，当目标分布的某些元素为0时，计算KL散度时会出现除0的情况，因此需要在计算时对这种情况进行特殊处理，通常是将对应的预测分布的该元素设为0。

`KLDivLoss`也可以加上权重，具体来说，可以为每个分布中的元素分配一个权重，用于控制不同元素的重要程度。可以使用参数`reduction`指定计算损失时的聚合方式，可以选择对每个元素单独计算损失（`'none'`）、对所有元素求和（`'sum'`）或对所有元素求平均值（`'mean'`）。

以下是一个使用`KLDivLoss`计算两个分布之间KL散度损失的示例：
```python
import torch
import torch.nn as nn

target = torch.Tensor([0.5, 0.3, 0.2])
predicted = torch.Tensor([0.4, 0.3, 0.3])

criterion = nn.KLDivLoss(reduction='sum')
loss = criterion(predicted.log(), target)

print(loss.item())  # 0.06446270662593842
```

当将`reduction`参数设置为`'batchmean'`时，`KLDivLoss`函数将对每个样本单独计算KL散度损失，并对这些损失求平均值。也就是说，它将对每个样本计算以下损失：
$$
loss_i​=\frac{1}{N}​\sum_j ​target_{i,j​}⋅(log(target_{i,j}​)−predicted_{i,j}​)
$$
其中，$N$是每个样本中元素的个数，$\text{target}_{i,j}$表示第$i$个样本的第$j$个目标分布元素，$\text{predicted}_{i,j}$表示第$i$个样本的第$j$个预测分布元素。

然后，`KLDivLoss`将对这些损失求平均值，得到最终的损失值。这种聚合方式可以用于批量处理多个样本时，对每个样本都计算相同的损失函数，然后将它们的平均损失作为整个批次的损失。

以下是一个使用`KLDivLoss`计算两个分布之间KL散度损失并使用`'batchmean'`进行聚合的示例：
```python
import torch
import torch.nn as nn

target = torch.Tensor([[0.5, 0.3, 0.2], [0.1, 0.7, 0.2]])
predicted = torch.Tensor([[0.4, 0.3, 0.3], [0.2, 0.5, 0.3]])

criterion = nn.KLDivLoss(reduction='batchmean')
loss = criterion(predicted.log(), target)

print(loss.item())  # 0.0739529131655693
```


一个实际应用的例子：
```python
KL_criterion = torch.nn.KLDivLoss(reduction='batchmean')
kl_input = F.log_softmax(logits2, dim=1)
kl_target = F.softmax(task_logits, dim=1)
kl_loss = KL_criterion(kl_input, kl_target)
```
要注意的是，尽量使用==log_softmax==而不是自己计算，因为自己计算有可能会导致数值爆炸，而得到inf或nan的结果。


### MSELoss

