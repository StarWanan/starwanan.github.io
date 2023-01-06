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
![image.png](https://s1.vika.cn/space/2023/01/05/770ff00153a64bb48bb03fb4fef166b1)

