[176. 装满的油箱 -  题库](https://www.acwing.com/problem/content/description/178/)
#算法/拆点 #算法/最短路 #算法/dijkstra

N点M无向边，每个点油价不同。有容量为C的油箱，问求起点到终点的最短路。

拆点。进行状态转移
相同点不同状态的转移：
如果在这个点油量没有达到油箱容量，那么是可以进行转移的【`[u][c] ->[u][c+1]` 】，转移后的状态此时的代价`d`如果更大，那么进行更新
不同点之间的转移：
如果当前点`t`的油量足够转移到相邻点（`t.c > w[i]`）那么就用这个点的代价`d`更新下一个点的相应状态【`[u][c] -> [j][c-w[i]]`】注意这里只用代价更新，而不需要加上边权`w[i]`，因为只有在点上买油才有代价，不同点转移时没有代价的。

```CPP
#include <iostream>
#include <cstring>
#include <queue>
#include <cstdio>

using namespace std;

const int N = 1010, M = 20010, C = 110;
struct Node
{
    int d, u, c;
    bool operator< (const Node &t) const {
        return d > t.d;
    }
};

int h[N], e[M], ne[M], w[M], idx = 1;
int dist[N][C], p[N];
bool st[N][C];

int n, m;

void add(int a, int b, int c)
{
    e[idx] = b, w[idx] = c, ne[idx] = h[a], h[a] = idx++;
}

int dj(int maxc, int sp, int ep)
{
    memset(dist, 0x3f, sizeof dist);
    memset(st, false, sizeof st);
    priority_queue<Node> q;

    q.push({0, sp, 0});
    dist[sp][0] = 0;

    while (q.size())
    {
        auto t = q.top();
        q.pop();

        if (t.u == ep) return t.d;
        
        if (st[t.u][t.c]) continue;
        st[t.u][t.c] = 1;

        if (t.c < maxc)
            if (dist[t.u][t.c + 1] > t.d + p[t.u])
            {
                dist[t.u][t.c + 1] = t.d + p[t.u];
                q.push({dist[t.u][t.c + 1], t.u, t.c + 1});
            }
        
        for (int i = h[t.u]; i; i = ne[i]) {
            int j = e[i];
            if (t.c >= w[i])
                if (dist[j][t.c - w[i]] > t.d)
                {
                    dist[j][t.c - w[i]] = t.d;
                    q.push({t.d, j, t.c - w[i]});
                }
        }
    }
    return -1;
}

int main()
{
    scanf("%d%d", &n, &m);
    for (int i = 0 ; i < n ; i ++) scanf("%d", p + i);
    
    for (int i = 0; i < m; i ++) {
        int u, v, d;
        scanf("%d%d%d", &u, &v, &d);
        add(u, v, d), add(v, u, d);
    }

    int T; scanf("%d", &T);
    while (T --) {
        int C, S, E;
        scanf("%d%d%d", &C, &S, &E);
        int d = dj(C, S, E);
        if (d == -1) puts("impossible");
        else printf("%d\n", d);
    }
}
```


