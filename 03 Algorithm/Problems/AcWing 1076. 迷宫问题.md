#算法/bfs

下一难度：[[03 Algorithm/Problems/AcWing 188. 武士风度的牛]]
	变式，日字形跳法


---
[原题链接](https://www.acwing.com/problem/content/1078/)

题意：
	n * n 地图。1墙，0路。输出左上到右下最短路线

思路：
	bfs裸题
	输出路径时有两种思路：
		1.  `p[x][y] = {a, b}`：(x, y) 下一步是 (a, b)
		2. `p[x][y] = {a, b}`：(x, y) 上一步是 (a, b)




代码：
```CPP
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 1010;
pair<int,int> p[N][N];
int g[N][N];
int dis[N][N];
int n;

void bfs()
{
    queue<pair<int,int>> q;
    q.push({0, 0});
    memset(dis, 0x3f, sizeof dis);
    dis[0][0] = 0;
    
    int dx[] = {-1, 0, 1, 0};
    int dy[] = {0, 1, 0, -1};
    
    while (q.size())
    {
        auto t = q.front();
        q.pop();
        
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            
            if (a < 0 || a >= n || b < 0 || b >= n || g[a][b] == 1) continue;
            
            if (dis[a][b] > dis[t.x][t.y] + 1)
            {
                dis[a][b] = dis[t.x][t.y] + 1;
                q.push({a, b});
                p[a][b] = {t.x, t.y};
            }
        }
    }
}

void dfs(int x, int y)
{
    if (p[x][y].x == -1 && p[x][y].y == -1) {printf("%d %d\n", x, y); return;}
    dfs(p[x][y].x, p[x][y].y);
    printf("%d %d\n", x, y);
}

int main()
{
    cin >> n;
    for (int i = 0; i < n; i ++)
        for (int j = 0; j < n; j ++)
            cin >> g[i][j];
    
    bfs();
    p[0][0] = {-1, -1};
    dfs(n - 1, n - 1);
    return 0;   
}

```