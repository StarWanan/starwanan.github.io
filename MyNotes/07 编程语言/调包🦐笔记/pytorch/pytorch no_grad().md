
`with torch.no_grad()`

> 参考：https://blog.csdn.net/sazass/article/details/116668755

作用：在该模块下，所有计算得出的tensor的requires_grad都自动设置为False。当requires_grad设置为False时,反向传播时就不会自动求导了，因此大大节约了显存或者说内存。
