
### torch.cuda.synchronize()

等待当前设备上所有流中的所有核心完成。

🌰：测试时间的代码

```python
# code 1
start = time.time()
result = model(input)
end = time.time()

# code 2
torch.cuda.synchronize()
start = time.time()
result = model(input)
torch.cuda.synchronize()
end = time.time()

# code 3
start = time.time()
result = model(input)
print(result)
end = time.time()
```

代码2是正确的。因为在pytorch里面，程序的执行都是异步的。
如果采用代码1，测试的时间会很短，因为执行完end=time.time()程序就退出了，后台的cu也因为python的退出退出了。
如果采用代码2，代码会同步cu的操作，等待gpu上的操作都完成了再继续成形end = time.time()

代码3和代码2的时间是类似的。
因为代码3会等待gpu上的结果执行完传给print函数，所以时间就和代码2同步的操作的时间基本上是一致的了。
将print(result)换成result.cpu()结果是一致的。
