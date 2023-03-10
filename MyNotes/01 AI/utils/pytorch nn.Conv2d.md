
[Pytorch的nn.Conv2d（）详解_风雪夜归人o的博客-CSDN博客_nn是什么意思](https://blog.csdn.net/qq_42079689/article/details/102642610)

---

```python
class Net(nn.Module):
    def __init__(self):
        nn.Module.__init__(self)
        self.conv2d = nn.Conv2d(in_channels=3,out_channels=64,kernel_size=4,stride=2,padding=1)

    def forward(self, x):
        print(x.requires_grad)
        x = self.conv2d(x)
        return x
    
print(net.conv2d.weight)
print(net.conv2d.bias)
```

