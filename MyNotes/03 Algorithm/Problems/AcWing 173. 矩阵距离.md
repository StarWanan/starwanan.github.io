#算法/bfs




---
[原题链接](https://www.acwing.com/problem/content/description/175/)

题意:
	n * m 的 01 矩阵, 求`dis[i][j]`: 表示(i,j) 到最近一个值为1的格子的最近距离
	输出 dis 矩阵

思路:
	多源bfs搜索

代码:
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <queue>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 1100;
int n, m;
int dis[N][N];
char g[N][N];



void bfs()
{
    int dx[] = {-1, 0, 1, 0};
    int dy[] = {0, 1, 0, -1};

    queue<PII> q;
    memset(dis, 0x3f, sizeof dis);

    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= m; j ++)
            if (g[i][j] == '1') q.push({i, j}), dis[i][j] = 0;

    while (q.size())
    {
        PII t = q.front(); q.pop();
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m) continue;
            if (dis[a][b] > dis[t.x][t.y] + 1)
            {
                dis[a][b] = dis[t.x][t.y] + 1;
                q.push({a, b});
            }
        }
    }

}

int main()
{
    cin >> n >> m;
    for (int i = 1; i<= n; i ++)
        cin >> g[i] + 1;

    bfs();

    for (int i = 1; i <= n; i ++)
    {
        for (int j = 1; j <= m; j ++)
            cout << dis[i][j] << ' ';
        cout << endl;
    }
    return 0;
}
```
