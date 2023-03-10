[CNN的Flatten操作](https://cloud.tencent.com/developer/article/1620842)

- `torch.flatten(Python function, in torch)`
- `torch.nn.Flatten(Python class, in torch.nn)`
- `torch.Tensor.flatten(Python methodm in torch.nn.Tensor)`

#### torch.flatten
```python
#展平一个连续范围的维度，输出类型为Tensor
torch.flatten(input, start_dim=0, end_dim=-1) → Tensor
# Parameters：input (Tensor) – 输入为Tensor
# start_dim (int) – 展平的开始维度
# end_dim (int) – 展平的最后维度

#example
#一个3x2x2的三维张量
>>> t = torch.tensor([[[1, 2], [3, 4]],
                      [[5, 6], [7, 8]],
	                  [[9, 10],[11, 12]]])
#当开始维度为0，最后维度为-1，展开为一维
>>> torch.flatten(t)
tensor([ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12])
#当开始维度为0，最后维度为-1，展开为3x4，也就是说第一维度不变，后面的压缩
>>> torch.flatten(t, start_dim=1)
tensor([[ 1,  2,  3,  4],
        [ 5,  6,  7,  8],
        [ 9, 10, 11, 12]])
>>> torch.flatten(t, start_dim=1).size()
torch.Size([3, 4])
#下面的和上面进行对比应该就能看出是，当锁定最后的维度的时候
#前面的就会合并
>>> torch.flatten(t, start_dim=0, end_dim=1)
tensor([[ 1,  2],
        [ 3,  4],
        [ 5,  6],
        [ 7,  8],
        [ 9, 10],
        [11, 12]])
>>> torch.flatten(t, start_dim=0, end_dim=1).size()
torch.Size([6, 2])

```


#### torch.nn.Flatten()
torch.nn.Flatten()可以是Sequential模型的一层

pytorch中的 torch.nn.Flatten 类和 torch.Tensor.flatten 方法其实都是基于 torch.flatten 函数实现的。
