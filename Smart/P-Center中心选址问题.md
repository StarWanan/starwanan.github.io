# P-Center
Github项目地址：https://github.com/StarWanan/P-Center

主要目标：设计算法，解决P-Center问题

## 算法步骤

**Algorithm 1** VWTS算法的主要框架
**Input:** 图$G$，中心数$p$，覆盖半径$r_q$
**Output:** 目前找到的最佳解决方案$X^*$

```vb
1: A set of p centers X ← Init(G, p, rq) 		/* (Section 3.1) */
2: X∗← X, X0← X, tabu list TL ← ∅, iter ← 1
3: V ertex weights wi← 1,∀i ∈ V 				/* (Section 3.2) */
4: while termination condition is not met do
5: 		(i, j) ← FindPair(X’, TL, iter) 		/* (Algorithm 2) */
6: 		MakeMove(i, j)		 					/* (Algorithm 4) */
7: 		if |U(X)| < |U(X∗)| then 				/* U(X) is the set of */
8: 			X∗← X 								/* clients uncovered by X */
9: 		else if |U(X)| ≥ |U(X0)| then
10: 		wv← wv+ 1,∀v ∈ U(X) 				/* (Section 3.2) */
11: 	end if 									/* more uncovered clients than last solution */
12: 	T L ← {i, j} 							/* update tabu list (Section 3.4) */
13: 	X‘← X, iter ← iter + 1
14: end while
```


### 1. Greedy 初始化解X
筛选P次，每次贪心筛选出一个最好的中心。每一轮筛选步骤：
1. 计算n个点（跳过前几轮已经被选为中心的点）能够覆盖未覆盖节点的数量
2. 选择最多的一个点。
3. 如果有多个点能够覆盖未覆盖节点的数量相同，则`rand()`随机选择一个。

### 2. 顶点加权
- 初始时每个顶点的权重为 1
- 每一次，将未覆盖的点的权重 +1。目标只是0，这样就会优先解决多次未被覆盖到的点。

### 3. 邻域交换
#### 找到最佳交换对
`FINDPAIR`: 找到一组点对{i, j}, 将 i 作为新的中心，将原本的中心 j 关闭
1. 在未覆盖的点中随机选一个点 v，与点 v 相连的所有点都可以覆盖点 v，也就都是开放候选点【第4行】
2. 备份数据结构 delta【第5行】
3. 遍历所有的开放候选点，每一个候选点尝试开放时：
	1. 计算开放后的delta【第7行】
	2. 逐一尝试关闭当前中心，计算关闭后的目标值，将最好目标值的点对存储在list中【第8-17行】
	3. 恢复delta【第18行】
4. 随机在list中挑出一个点对


**Algorithm 2** 找到最佳交换对
```vb
1: function FINDPAIR(X, TL, iter)
2: 		The set of best swap moves M ← ∅
3: 		The best objective value obj ← +∞
4: 		v ← a randomly picked uncovered vertex in U(X)
5: 		δ’j← δj,∀j ∈ C 							/* backup before trial moves */
6: 		for all i ∈ Cv do 						/* Cv: candidates covering v */
7: 			TryToOpenCenter(i)  				/* (Algorithm 3) */
8: 			for all j ∈ X do 					/* evaluate closing center j */
9: 				if {i, j} ∩ T L = ∅ then 		/* not tabu move */
10: 				if f(X ⊕ Swap(i, j)) < obj then
11: 					obj ← f(X ⊕ Swap(i, j))
12: 					M ← {Swap(i, j)}
13: 				else if f(X ⊕ Swap(i, j)) = obj then
14: 					M ← M ∪ {Swap(i, j)}
15: 				end if
16: 			end if
17: 		end for
18: 		δj← δ’j,∀j ∈ C 						/* restore after trial moves */
19: 	end for 								/* v ∈ U(X) ⇔ Cv∩ X = ∅ */
20: 	return a randomly picked move in M
21: end function
```

尝试打开一个中心 $i$ ，与 $i$ 相连的所有点构成点集 $C_v$ ，当前中心点集 $X$。
- 原本 `delta[i]` 就是 $i$ 能覆盖到的未覆盖点数， $i$ 变为中心后，`delta[i]` 就是单独被 $i$ 覆盖的点数。所以 `delta[I]` 不用改动。
- 假设 $i$ 连接的点 $j$，能够再连接到当前解 $X$ 中的==某一个且仅这一个==中心 $l$，则 $j$ 点不再是中心 $c$ 能够单独覆盖的点，所以 `delta[l]` 需要改变
综上所述，应该执行的操作是：
1. 遍历与 $i$ 相连的所有点
	1. 假设其中一个点 $v$， 其 `toCenter_cnt[v] == 1` 表示只连到了一个中心，且这个中心是 `l = toCenter[v]`
	2. `delta[l] -= weight[v]`

这个算法的目的就是辅助目标值的计算，所以需要的 delta 就是开放这个中心的delta 以及被这个尝试开放中心影响的解中的中心的 delta。其他不需要改变。
**Algorithm 3** 模拟打开一个中心
```vb
1: function TRYTOOPENCENTER(i)
2: 		for all v ∈ Vi do 				/* |X ∩ Cv|: number of centers */
3: 			if |X ∩ Cv| = 1 then 		/* covering v in X */
4: 				/* cancel penalty for making v uncovered */
5: 				δl← δl− wv,for l ∈ X ∩ Cv  	/* O(1) */
6: 			end if 			/* l was the only center covering v but */
7: 		end for 			/* it will not be the only one if i opens so */
8: end function 			/* closing l does not make v uncovered */
```

此时就可以进行算法2的第8-17行，逐一尝试关闭某个中心，找到最优。而这里关闭导致的后续影响是对下一步造成的影响，所以不用再修改 delta。

#### 目标值的计算
假定打开中心 $i$，关闭中心 $j$，目标值为 $f$
- 打开：减少了未覆盖点，数量即为 $i$ 能覆盖到的未覆盖点数
- 关闭：增加了未覆盖点，数量即为仅被 $j$ 单独覆盖的点数

更新公式为：$f = f - delta[i] + delta[j]$

==注意这里不能直接更改目标值 f==，仅仅是找出最优对，并没有真正交换。

#### 移动：打开 i，关闭 j
可能出现的情况：
- 打开 i，所有与 i 相连的点中，假定有一个点 v：
	- v 原本被解中的某一个中心覆盖。改动如 `TryOpenCenter()`，与其相连的那个中心需要改变 delta
	- v 原本没有被覆盖。现在变为已覆盖，那么与其相连的点需要改变 delta
	- 更新点被覆盖的次数与被哪一个现在的中心覆盖的情况
- 关闭 j，所有与 j 相连的点中，假定有一个点 v：
	- v 原本仅被解中的一个中心覆盖，那一定是中心 j，关闭后变为未覆盖节点。
	- v 原本被解中的两个中心覆盖，关闭 j 之后，就单独被一个中心覆盖。
##### 修改delta
被开/关中心连接到的点 v，只有两个状态变化需要关注：
1. 未覆盖 —— 已覆盖
2. 被单独覆盖 —— 被两个及以上覆盖

开放中心：修改`isCenter[i] = true`
1. uncover -> cover：
	- 中心开放，delta 的值不变，因为未覆盖的点数都变成了被该中心单独覆盖的点数
	- 对与 v 相连的所有点的情况是：一个刚开放的中心 + 非中心点
	- 此时 v 对于刚开放中心的影响已经被计算过
	- 所有非中心点都失去了一个未覆盖点
	- 总结：**除待开放中心，其它点 `delta -= weight[v]`**
2. 单独覆盖 -> 被两个覆盖
	- 连接的原始解中的中心 $l$， `delta[l] -= weight[v]`

关闭中心：修改`isCenter[j] = false`
1. cover -> uncover(关闭中心)
	- 中心关闭，delta 的值不变，因为单独覆盖的点数都变成了该点连接的未覆盖点数
	- 对与 v 相连的所有点的情况是：一个刚关闭的中心 + 非中心点
	- 此时 v 对于刚关闭中心的影响已经被计算过
	- 所有非中新点都增加了一个未覆盖点
	- 总结：**除待开放中心，其它点 `delta += weight[v]`**
2. 被两个覆盖 -> 被单独覆盖
	- 遍历 v 能连接到的点，找到中心 $l$，`delta[l] += weight[v]`

##### 计算目标值





### 4. 禁忌搜索
实现一个禁忌列表 `TL[N]`。`TL[i] = x` 表示点 $i$ 封禁到第 $x$ 个 iter。所以当 `TL[i] > iter` 的时候，表示该 iter 时点 $i$ 可用。

实际使用2步禁忌。当第 iter 轮使用过点 $i$ 时，禁忌列表改为：`TL[i] = iter + 2`

