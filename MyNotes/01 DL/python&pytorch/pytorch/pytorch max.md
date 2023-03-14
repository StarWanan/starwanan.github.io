
`torch.max(input) → Tensor`:返回输入tensor中所有元素的最大值

`torch.max(input, dim, keepdim=False, out=None) -> (Tensor, LongTensor)`: 按维度dim 返回最大值，并且返回索引。

```python
torch.max()[0]， 只返回最大值的每个数

troch.max()[1]， 只返回最大值的每个索引

torch.max()[1].data 只返回variable中的数据部分（去掉Variable containing:）

torch.max()[1].data.numpy() 把数据转化成numpy ndarry

torch.max()[1].data.numpy().squeeze() 把数据条目中维度为1 的删除掉
```
