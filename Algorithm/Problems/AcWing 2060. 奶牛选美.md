#算法/bfs  #算法/dfs

---
https://www.acwing.com/problem/content/2062/



题意：
每个样例都有两个块，求最少修改多少个点，可以变成一个块



思路：
dfs标记第一个块，所有点入队。开始bfs搜索直到第一个搜到另一个块时，是最短距离。


代码：
```CPP
#include <iostream>
#include <cstring>
#include <queue>

using namespace std;
typedef pair<int,int> PII;
#define x first
#define y second

const int N = 55;

int n, m;
char g[N][N];
int vis[N][N];
int dis[N][N];

queue<PII> q;

int dx[] = {-1, 0, 1, 0}, dy[] = {0, 1, 0, -1};
void dfs(int x, int y)
{
    vis[x][y] = 1;
    for (int i = 0 ;i < 4; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        if (a < 1 || a > n || b < 1 || b > m || vis[a][b] || g[a][b] == '.') continue;
        q.push({a, b});
        dis[a][b] = 0;
        dfs(a, b);
    }
}

int bfs()
{
    while (q.size())
    {
        PII t = q.front(); q.pop();
        for (int i = 0 ;i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m || vis[a][b]) continue;
            if (dis[a][b] > dis[t.x][t.y] + 1)
            {
                dis[a][b] = dis[t.x][t.y] + 1;
                if (g[a][b] == 'X') return dis[a][b];
                q.push({a, b});
            }
        }
    }
}

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; i ++)
        cin >> g[i] + 1;
    
    memset(dis, 0x3f, sizeof dis);
    bool flag = true;
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= m; j ++)
            if (flag && g[i][j] == 'X' && !vis[i][j])
            {
                q.push({i, j});
                dis[i][j] = 0;
                dfs(i, j);
                flag = false;
            }
            
    
    cout << bfs() - 1 << endl;
    
    // for (int i = 1; i <= n; i ++)
    // {
    //     for (int j = 1; j <= m; j ++)    
    //         if (dis[i][j] > 0x3f3f3f3f/2) cout << "inf ";
    //         else cout << dis[i][j] << ' ';
    //     cout << endl;
    // }

}
```