
[pytorch系列7 -----nn.Sequential讲解](https://blog.csdn.net/dss_dssssd/article/details/82980222)

nn.Sequential
A sequential container. Modules will be added to it in the order they are passed in the constructor. Alternatively, an ordered dict of modules can also be passed in.

一个有序的==容器==，神经网络模块将按照在传入构造器的顺序依次被添加到计算图中执行，同时以神经网络模块为元素的有序字典也可以作为传入参数。

```python
# Example of using Sequential
model = nn.Sequential(
		  nn.Conv2d(1,20,5),
		  nn.ReLU(),
		  nn.Conv2d(20,64,5),
		  nn.ReLU()
		)

# Example of using Sequential with OrderedDict
model = nn.Sequential(OrderedDict([
		  ('conv1', nn.Conv2d(1,20,5)),
		  ('relu1', nn.ReLU()),
		  ('conv2', nn.Conv2d(20,64,5)),
		  ('relu2', nn.ReLU())
		]))

```

