#算法/双端队列bfs

---
https://www.acwing.com/problem/content/2021/


题意：
(0,0) 走到 (SX,SY)的最短距离。有的点代价是1，有的点代价是0


思路：
双端队列bfs


代码：
```CPP
#include <iostream>
#include <cstring>
#include <deque>

using namespace std;

typedef pair<int, int> PII;
#define x first
#define y second

const int N = 1010;
int g[N][N];
int dis[N][N];
int n, sx, sy;

void bfs()
{
    deque<PII> q;
    q.push_back({sx, sy});
    memset(dis, 0x3f, sizeof dis);
    dis[sx][sy] = 0;
    
    int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};
    
    while (q.size())
    {
        PII t = q.front(); q.pop_front();
        
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i];
            int b = t.y + dy[i];
            if (a < 0 || a > N-1 || b < 0 || b > N-1) continue; // 数组会越界，注意范围
        
            int v = g[a][b];
            
            if (dis[a][b] > dis[t.x][t.y] + v)
            {
                dis[a][b] = dis[t.x][t.y] + v;
                if (v) q.push_back({a, b});
                else q.push_front({a, b});
            }
        }
    }
    return ;
}

int main()
{
    cin >> n >> sx >> sy;
    for (int i = 0; i < n; i ++)
    {
        int a, b;   cin >> a >> b;
        g[a][b] = 1;
    }
    
    bfs();
    
    cout << dis[0][0] << endl;
    
    // for (int i = 0; i < 5; i ++)
    // {
    //     for (int j = 0; j < 5; j ++)
    //         if (dis[i][j] < 10) cout << dis[i][j] << ' ';
    //         else cout << "x ";
    //     cout << endl;
    // }
    
    return 0;
}
```
