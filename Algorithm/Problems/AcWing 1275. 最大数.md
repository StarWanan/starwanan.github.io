#算法/线段树

---
https://www.acwing.com/problem/content/1277/

维护序列，有添加查询两种操作
1. 添加`A t`：向最后加一个数， (t+a) mod p。其中，t 是输入的参数，a 是在这个添加操作之前最后一个询问操作的答案（如果之前没有询问操作，则 a=0）。
2. 查询`Q L`：询问序列中最后 LL 个数的最大数

线段树维护

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 200010;
int m, p, last, n;
struct node
{
    int l, r;
    int v;
}tr[N * 4];

void build(int u, int l, int r)
{
    tr[u] = {l, r};
    if (l == r) return ;
    int mid = l + r >> 1;
    build(u << 1, l , mid);
    build(u << 1 | 1, mid + 1, r);
}

void pushup(int u)
{
    tr[u].v = max(tr[u << 1].v, tr[u << 1 | 1].v);
}

void modify(int u, int k, int v)
{
    if (tr[u].l == k && tr[u].r == k) tr[u].v = v;
    else 
    {
        int mid = tr[u].l + tr[u].r >> 1;
        if (k <= mid) modify(u << 1, k, v);
        else modify(u << 1 | 1, k, v);
        pushup(u);
    }
}

int query(int u, int l, int r)
{
    if (l <= tr[u].l && r >= tr[u].r) return tr[u].v;
    else 
    {
        int mid = tr[u].l + tr[u].r >> 1;
        int v = 0;
        if (l <= mid) v = query(u << 1, l, r);
        if (r > mid) v = max(v, query(u << 1 | 1, l, r));
    }
}

int main()
{
    scanf("%d%d", &m, &p);
    build(1, 1, m);

    int x;
    char op[2];
    while (m -- )
    {
        scanf("%s%d", op, &x);
        if (*op == 'Q')
        {
            last = query(1, n - x + 1, n);
            printf("%d\n", last);
        }
        else
        {
            modify(1, n + 1, ((long long)last + x) % p);
            n ++ ;
        }
    }
}
```