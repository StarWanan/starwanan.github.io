#算法/flood-fill 




---

[原题链接](https://www.acwing.com/problem/content/1108/)

题意：
	n * n的方格。每个各自上的数值代表山的高度。
	顶点重合就算相邻
	求山峰数和山谷数
> 山峰 & 山谷：
	 是一个连通块，块内山峰高度全部相等假定为 x
	块周围所有的山峰高度小于 x， 则该块为山峰
	块周围所有的山峰高度大于 x， 则该块为山谷
	若整张地图高度一样，则既是山峰，也是山谷
	
	
 思路：
	 求连通块，维护两个变量`has_low`  和 `has_high` 
	 在遇到连通块边界时，判断周围是否有耕地或者更高的山

用dfs会爆栈：**Memory Limit Exceeded**
在 1000 * 1000 全都是相同高度的情况下，递归深度过深
```CPP
void dfs(int x, int y)
{
    vis[x][y] = 1;
    int dx[] = {-1, 0, 1, 0, -1, -1, 1, 1};
    int dy[] = {0, 1, 0, -1, 1, -1, 1, -1};
    
    for (int i = 0; i < 8; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        if (a < 1 || a > n || b < 1 || b > n) continue;
        
        /** 一定要先判断边界，后判断是否遍历过，否则可能直接continue，不能发现周围山情况*/
        if (g[a][b] != g[x][y]) // 边界
        {
            if (g[a][b] > g[x][y]) has_high = true;
            else has_low = true;
            continue;
        }
        
        if (vis[a][b]) continue;
        dfs(a, b);
    }
}
```

所以只能使用bfs
代码：
```CPP
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 1010;

int n;
int cnt_h, cnt_l;
bool has_low, has_high;

int g[N][N];
int vis[N][N];


PII q[N * N];
void bfs(int sx, int sy)
{
    int dx[] = {-1, 0, 1, 0, -1, -1, 1, 1};
    int dy[] = {0, 1, 0, -1, 1, -1, 1, -1};
    
    int hh = 0, rr = -1;
    q[++ rr] = {sx, sy};
    vis[sx][sy] = 1;
    
    while (hh <= rr)
    {
        PII t = q[hh ++];
        for (int i = 0; i < 8; i ++)
        {   
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            
            if (a < 1 || a > n || b < 1 || b > n) continue;
            
            /** 一定要先判断边界，后判断是否遍历过，否则可能直接continue，不能发现周围山情况*/
            if (g[a][b] != g[t.x][t.y]) // 边界
            {
                if (g[a][b] > g[t.x][t.y]) has_high = true;
                else has_low = true;
                continue;
            }
            
            if (vis[a][b]) continue;
            
            q[++ rr] = {a, b};
            vis[a][b] = 1;
        }
    }
    
}

int main()
{
    cin >> n;
    
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= n; j ++)
            cin >> g[i][j];
    
    
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= n; j ++)
            if (!vis[i][j])
            {
                has_low = has_high = false;
                bfs(i, j);
                if (!has_low) cnt_l ++;
                if (!has_high) cnt_h ++;
                
                // printf("(%d,%d): l:%d  h:%d\n", i, j, cnt_l, cnt_h); 
            }
    printf("%d %d\n", cnt_h, cnt_l);
    return 0;
}
```