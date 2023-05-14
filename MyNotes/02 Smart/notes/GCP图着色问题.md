---
alias: GCP
tag: Smart 
---
## 局部搜索
### 邻域评估

邻域动作：`<u, i, j>`代表节点 $u$ 从颜色 $i$ 变为颜色 $j$

邻域评估：找到最好的执行动作

`M[u][i]`: 节点 $u$ 的所有邻居(相邻点)中，颜色为 $i$ 的个数
<img src="https://s1.vika.cn/space/2023/03/07/83ea45c932764e8a8d1f82d8031f1c72" alt="image.png" style="zoom:30%;" />
进行一次邻域动作后，节点 $u$ 从颜色 $i$ 变成了颜色 $j$：
- 减少的冲突数是相邻点颜色为 $i$ 的
- 增加的冲突数是相邻点颜色为 $j$ 的

进行动作后，只有相邻节点的邻接颜色表会受到影响。而且只有颜色 i 和颜色 j 对应的两列会收到影响。
- 颜色 i 对应的那一列，全部 -1
- 颜色 j 对应的那一列，全部 +1

![image.png|400](https://s1.vika.cn/space/2023/03/20/879543c8e26c4a9884e0b9aca56ccfc1)


### 禁忌搜索

`<u, i, j>`执行后，t 步之内，u 的颜色不能回到 i

禁忌步长 $t = f(S) + rand(10)$

![image.png|500](https://s1.vika.cn/space/2023/03/20/9e64e2feeadd454dad395b2228cf45dd)

![image.png|500](https://s1.vika.cn/space/2023/03/20/91d007b27894473fa2840e98162d20a0)
![image.png|500](https://s1.vika.cn/space/2023/03/20/f0d0537338f345b5b6d0116ab7802551)


![image.png|500](https://s1.vika.cn/space/2023/03/20/2208584e7ef54735912a20903c1d636a)


## 混合进化算法

![500](https://s1.vika.cn/space/2023/04/17/1bacf52915214422937dce8933f22058)

![500](https://s1.vika.cn/space/2023/04/17/2914ba4c890445568b54b1545d96e226)







