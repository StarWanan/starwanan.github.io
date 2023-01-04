详细说明见官网：[sklearn.cluster.DBSCAN](https://scikit-learn.org/stable/modules/generated/sklearn.cluster.DBSCAN.html#sklearn.cluster.DBSCAN)

DBSCAN - Density-Based Spatial Clustering of Applications with Noise
基于密度的噪声应用空间聚类


## 代码使用
一个例子
```python
from sklearn.cluster import DBSCAN

'''
Input: feats. 此处输入是 (23623, 256) 的张量. 23256个样本特征，每个特征是256维
Output: res. 经过聚类后的结果
'''
res = DBSCAN(eps=35, min_samples=512).fit(feats)

# 列表，聚类后没个样本对应的标签
print(res.labels_)

```


### 常用参数
`eps: float, default=0.5`：邻域半径

`min_samples: int, default=5`：成为核心对象的在邻域半径内的最少点数。

这两个是最关键的参数值。


### 参数选择
定义 ==k = 2 * 特征维度 - 1==
这里我的特征维度是256，所以 **k = 511**

**min_samples = k + 1**

**eps** 利用 k-distance 选取
1. 计算出每个特征到其它所有特征的距离，记录第 k 近的距离，这样就获得了每个特征和其他特征的第 k 近距离
2. 假定有 n 个特征，就有 n 个第 k 近距离，排序这些距离，进行绘图
3. 找到**拐点对应的距离**，设定为 Eps 的值

k-distance绘制：
```python
def select_MinPts(data,k):
    k_dist = []
    for i in range(data.shape[0]):
        dist = (((data[i] - data)**2).sum(axis=1)**0.5)
        dist.sort()
        k_dist.append(dist[k])
    return np.array(k_dist)

k = 511     # 2*256 - 1
k_dist = select_MinPts(feats,k)
k_dist.sort()
plt.plot(np.arange(k_dist.shape[0]),k_dist[::-1])
```
![image.png](https://s1.vika.cn/space/2023/01/04/1b67ba259ede452b962982cdf347b894)

