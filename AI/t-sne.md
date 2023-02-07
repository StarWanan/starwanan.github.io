[sklearn.manifold.TSNE源网站](https://scikit-learn.org/stable/modules/generated/sklearn.manifold.TSNE.html)

[sklearn.manifold.TSNE中文网站](https://scikit-learn.org.cn/view/463.html)

## 代码使用

一个例子：将 256 维度的特征，变为 2 维的嵌入空间中可视化出来。
```python
from sklearn import manifold


'''t-SNE'''
tsne = manifold.TSNE(n_components=2, init='pca', random_state=501)
X_tsne = tsne.fit_transform(X)

print("Org data dimension is {}. Embedded data dimension is {}".format(X.shape[-1], X_tsne.shape[-1]))

'''嵌入空间可视化'''
x_min, x_max = X_tsne.min(0), X_tsne.max(0)
X_norm = (X_tsne - x_min) / (x_max - x_min)  # 归一化
plt.figure(figsize=(8, 8))
for i in range(X_norm.shape[0]):
    plt.text(X_norm[i, 0], X_norm[i, 1], str(y[i]), color=plt.cm.Set1(y[i]), 
             fontdict={'weight': 'bold', 'size': 3})
plt.xticks([])
plt.yticks([])
plt.show()
```

输入数据Input：
`X` : 特征feats
`y` : 每一条特征对应的 labels

Output：
<img src="https://s1.vika.cn/space/2023/02/06/69f67b92e9024fc2b6246e2f45adfd13" alt="image.png" style="zoom:50%;" />




可视化手写数字：
```python
import numpy as np

from sklearn import manifold, datasets

digits = datasets.load_digits(n_class=6)
X, y = digits.data, digits.target
n_samples, n_features = X.shape

'''显示原始数据'''
n = 20  # 每行20个数字，每列20个数字
img = np.zeros((10 * n, 10 * n))
for i in range(n):
    ix = 10 * i + 1
    for j in range(n):
        iy = 10 * j + 1
        img[ix:ix + 8, iy:iy + 8] = X[i * n + j].reshape((8, 8))
plt.figure(figsize=(8, 8))
plt.imshow(img, cmap=plt.cm.binary)
plt.xticks([])
plt.yticks([])
plt.show()
```

