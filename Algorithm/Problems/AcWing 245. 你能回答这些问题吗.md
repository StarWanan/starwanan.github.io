#算法/线段树 

---
https://www.acwing.com/problem/content/246/

给定长度为 NN 的数列 AA，以及 MM 条指令，每条指令可能是以下两种之一：
1.  `1 x y`，查询区间 [x,y][x,y] 中的==最大连续子段和==，即 $max_{x≤l≤r≤y}{∑_{i=l}^rA[i]}$。
2.  `2 x y`，把 A[x] 改成 y。


需要维护4个值: sum, lmax, rmax, tmax
1. sum: 区间和
2. lmax: 区间左边开始最大子段和
3. rmax: 区间右边开始最大子段和
4. tmax: 区间最大子段和

因为最大连续子段和只有3种可能
1. 左
2. 右
3. 中间

所以更新的时候父节点唯一可能更大的就是中间的序列和
所以可以在（左节点最大，右节点最大，中间序列和）中取最大进行更新自己的最大值：
```CPP
u.tmax = max(max(l.tmax, r.tmax), l.rmax + r.lmax);
```
但是同样要更新维护父节点的 lmax 和 rmax
```CPP
u.lmax = max(l.lmax, l.sum + r.lmax);
u.rmax = max(r.rmax, r.sum + l.rmax);

```


```cpp
#include <iostream>

using namespace std;

const int N = 500010;

int n, m;
int a[N];
struct node
{
    int l, r;
    int sum, lmax, rmax, tmax;
}tr[N * 4];

void pushup(node &u, node &l, node &r)
{
    u.sum = l.sum + r.sum;
    u.lmax = max(l.lmax, l.sum + r.lmax);
    u.rmax = max(r.rmax, r.sum + l.rmax);
    u.tmax = max(max(l.tmax, r.tmax), l.rmax + r.lmax);
}

void pushup(int u)
{
    pushup(tr[u], tr[u << 1], tr[u << 1 | 1]);
}

void build(int u, int l, int r)
{
    if (l == r)
    {
        tr[u] = {l, r, a[l], a[l], a[l], a[l]};
        return ;
    }
    tr[u] = {l, r};
    int mid = l + r >> 1;
    build(u << 1, l, mid); build(u << 1 | 1, mid + 1, r);
    pushup(u);
}

void modify(int u, int k, int v)
{
    if (tr[u].l == k && tr[u].r == k) tr[u] = {k, k, v, v, v, v};
    else
    {
        int mid = tr[u].l + tr[u].r >> 1;
        if (k <= mid) modify(u << 1, k, v);
        else modify(u << 1 | 1, k, v);
        pushup(u);
    }
}

node query(int u, int l, int r)
{
    if (l <= tr[u].l && tr[u].r <= r) return tr[u];
    else
    {
        int mid = tr[u].l + tr[u].r >> 1;
        
        if (l > mid) return query(u << 1 | 1, l, r); 
        else if (r <= mid) return query(u << 1, l, r);
        else
        {
            node left, right, res;
            left = query(u << 1, l, r);
            right = query(u << 1 | 1, l, r);
            pushup(res, left, right);
            return res;
        }
    }
}

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; i ++)
        cin >> a[i];
    build(1, 1, n);
    
    int k, x, y;
    while (m -- )
    {
        cin >> k >> x >> y;
        
        if (k == 1) 
        {
            if (x > y) swap(x, y);
            cout << query(1, x, y).tmax << endl;
        }
        else 
            modify(1, x, y); 
    }
    
}
```