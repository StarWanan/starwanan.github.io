
[yacs使用 —— 知乎](https://zhuanlan.zhihu.com/p/366289700)

yacs库，用于为一个系统构建config文件

需要创建`CN()`这个作为容器来装载我们的参数，这个容器可以嵌套

### 手动增加参数
```python
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--device', default='0,1', type=str, help='设置使用哪些显卡')
parser.add_argument('--no_cuda', action='store_true', help='不适用GPU进行训练')
args = parser.parse_args()
print(args)
```

命令行：`python test.py --device 0 --no_cuda`

jupyter：

1. 首先代码第6行改成：`args = parser.parse_args(args=['--device', '0',  '--no_cuda'])`,传参改成**列表形式**
2. 运行jupyter单元

