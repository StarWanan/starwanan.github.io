#算法/图论 




---
[原题链接](https://www.acwing.com/problem/content/190/)

题意：
	n * m方格。’K‘ 到 ’H‘ 的最短路。只能以’日‘字型转移。不能站到  ’ * ‘ 障碍物上

思路：
	bfs
	注意 dx 和 dy 数组

代码：
```CPP
#include <iostream>
#include <queue>
#include <cstring>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 200;

char g[N][N];
int dis[N][N];
int n, m;
int sx, sy;

int bfs()
{
    int dx[] = {-2, -1, 1, 2, 2, 1, -1, -2};
    int dy[] = {1, 2, 2, 1, -1, -2, -2, -1};
    
    queue<PII> q;
    q.push({sx, sy});
    memset (dis, 0x3f, sizeof dis);
    dis[sx][sy] = 0;
    while (q.size())
    {
        auto t = q.front(); q.pop();
        // printf("%d %d\n", t.x, t.y);
        for (int i = 0; i < 8; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m) continue;
            if (g[a][b] == '*') continue;
            if (dis[a][b] > dis[t.x][t.y] + 1)
            {
                dis[a][b] = dis[t.x][t.y] + 1;
                q.push({a, b});
                if (g[a][b] == 'H') return dis[a][b];
            }
        }
    }
    return -1;
}


int main()
{
    cin >> m >> n;
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= m; j ++)
        {
            cin >> g[i][j];
            if (g[i][j] == 'K') 
            {
                sx = i;
                sy = j;
            }
        }
    
    // printf("-- %d %d\n", sx, sy);
    
    cout << bfs();
    
    return 0;
}
```