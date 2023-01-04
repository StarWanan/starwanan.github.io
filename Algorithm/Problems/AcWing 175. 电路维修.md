#算法/搜索 

---
[原题链接](https://www.acwing.com/problem/content/description/177/)

题意:
从(0,0) 到 (n,m), 只能斜向移动, 方向符合 字符方向代价是0, 不符合方向代价是 1
求最小代价

思路:
双端队列bfs

代码:
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <deque>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second

const int N = 510;
int t;
int n, m;
char g[N][N];
int dis[N][N];

int bfs()
{
    memset(dis, 0x3f, sizeof dis);
    dis[0][0] = 0;
    deque<PII> q;
    q.push_back({0, 0});
    
    int dx[] = {-1, -1, 1, 1}, dy[] = {-1, 1, 1, -1};
    char path[] = "\\/\\/";
    int ix[] = {-1, -1, 0, 0}, iy[] = {-1, 0, 0, -1};
    
    
    while (q.size())
    {
        PII t = q.front(); q.pop_front();
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            
            if (a < 0 || a > n || b < 0 || b > m) continue;
            
            char real = g[t.x + ix[i]][t.y + iy[i]];

            if (real == path[i]) 
            {
                if (dis[a][b] > dis[t.x][t.y])
                {
                    dis[a][b] = dis[t.x][t.y];
                    q.push_front({a, b});
                }
            }
            else
            {
                if (dis[a][b] > dis[t.x][t.y] + 1)
                {
                    dis[a][b] = dis[t.x][t.y] + 1;
                    q.push_back({a, b});
                }
            }
            
            if (a == n && b == m) return dis[a][b];
            
        }
    }
    return -1;
}

int main()
{
    cin >> t;
    while (t --)
    {
        cin >> n >> m;
        for (int i = 0; i < n; i ++)
            cin >> g[i];
        int t = bfs();
        if (t == -1) puts("NO SOLUTION");
        else cout << t << endl;
    }
        
    return 0;
}
```