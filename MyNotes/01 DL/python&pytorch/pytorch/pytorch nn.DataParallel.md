[Pytorch的nn.DataParallel - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/102697821)
多卡并行的命令，以及可能出的错误


当迭代次数或者epoch足够大的时候，我们通常会使用nn.DataParallel函数来用多个GPU来加速训练

````python
CLASS torch.nn.DataParallel(module, device_ids=None, output_device=None, dim=0)
````

module即表示你定义的模型
device_ids表示你训练的device
output_device这个参数表示输出结果的device
