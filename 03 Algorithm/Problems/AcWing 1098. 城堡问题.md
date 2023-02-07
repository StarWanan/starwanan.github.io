#算法/flood-fill 



---
[原题链接](https://www.acwing.com/problem/content/description/1100/)

题意：
	n * m的网状表格，每个方格有一个数 P 代表一个房间状态。1，2，4，8表示本房间有左、上、右、下墙，P即为总数。
	求房间个数以及最大的房间面积

思路：
	仍是将每个房间看作一个格子，至于属性在搜索时加以限制即可
	求连通块，记录连通块块内节点个数并取最大。
	可以使用bfs或者dfs实现。dfs方便书写， bfs直观易于计数（只需要返回最终队列长度即可）
dfs：
```CPP
int dfs(int x, int y)
{
    int sum = 1;
    vis[x][y] = 1;
    
    for (int i = 0; i < 4; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        if (a < 1 || a > n || b < 1 || b > m) continue;
        if (g[x][y] >> i & 1) continue;
        if (vis[a][b]) continue;
        sum += dfs(a, b);
    }
    return sum;
}
```
bfs：
```CPP
typedef pair<int, int> PII;
#define x first
#define y second
PII q[N*N];
int bfs(int sx, int sy)
{
    int hh = 0, rr = -1;
    q[++ rr] = {sx, sy};
    vis[sx][sy] = 1;
    
    while (hh <= rr)
    {
        auto t = q[hh ++];
        
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m) continue;
            if (g[t.x][t.y] >> i & 1) continue;
            if (vis[a][b]) continue;
            q[++ rr] = {a, b};
            vis[a][b] = 1;
        }
    }
    return rr + 1;
}
```

代码：
```cpp
#include <iostream>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 55;

int g[N][N];
int n, m;

PII q[N*N];
int vis[N][N];
int cnt, ans;

int dx[] = {0, -1, 0, 1};
int dy[] = {-1, 0, 1, 0};

int dfs(int x, int y)
{
    int sum = 1;
    vis[x][y] = 1;
    
    for (int i = 0; i < 4; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        if (a < 1 || a > n || b < 1 || b > m) continue;
        if (g[x][y] >> i & 1) continue;
        if (vis[a][b]) continue;
        sum += dfs(a, b);
    }
    // printf("(%d,%d): %d\n", x, y, sum);
    return sum;
}


int bfs(int sx, int sy)
{
    int hh = 0, rr = -1;
    q[++ rr] = {sx, sy};
    vis[sx][sy] = 1;
    
    while (hh <= rr)
    {
        auto t = q[hh ++];
        
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m) continue;
            if (g[t.x][t.y] >> i & 1) continue;
            if (vis[a][b]) continue;
            q[++ rr] = {a, b};
            vis[a][b] = 1;
        }
    }
    return rr + 1;
}

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n ; i ++)
        for (int j = 1; j <= m; j ++)
            cin >> g[i][j];
    
    for (int i = 1; i <= n ; i ++)
        for (int j = 1; j <= m; j ++)  
            if (!vis[i][j])
            {
                cnt ++;
                // ans = max(ans, dfs(i, j));
                ans = max(ans, bfs(i, j));
            }
    cout << cnt << endl;
    cout << ans << endl;
}


```