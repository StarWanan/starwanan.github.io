#算法/bfs 



---
[原题链接](https://www.acwing.com/problem/content/1133/)

题意：
	n * m 的表格。求(1,1) -> (N,M)的最短路。无解输出-1。移动一次花费1。
	有墙与 $P$ 类门。拿到对应钥匙才能开门。钥匙在不同的格子，同一个单元可能存放 **多把钥匙**

数据范围：
	$1≤N,M,P≤10,$
	$1≤k≤150$

思路：
	bfs求最短路，维护三个值 `{x,y,key}` ，分别为（x,y）和持有的钥匙情况==二进制压缩==
	`g[x][y][a][b]`：(x, y) 和 (a, b) 之间的门的情况。注意建==双向==
	`dis[x][y][v]`：(x,y)处，持有钥匙的情况为v时，经过的距离。


代码：
```CPP
#include <iostream>
#include <cstring> 
#include <queue>
using namespace std;

const int N = 12;

struct node 
{
    int x, y, v;
};

int n, m, p;
int g[N][N][N][N];
int key[N][N];
int dist[N][N][1 << N];


int bfs() 
{
    int dx[] = {-1, 0, 1, 0};
    int dy[] = {0, 1, 0, -1};
    
    memset(dist, 0x3f, sizeof dist);
    queue<node> q;
    
    q.push({1, 1, key[1][1]});
    dist[1][1][key[1][1]] = 0;

    while (q.size()) {
        auto t = q.front(); q.pop();
        for (int i = 0; i < 4; i++) 
        {
            int a = t.x + dx[i], b = t.y + dy[i];
            
            if (a <= 0 || a > n || b <= 0 || b > m) continue;
            
			int& door = g[t.x][t.y][a][b];
            if (door >= 0 && (door == 0 || !(t.v >> door & 1)) ) continue;
            
            int nv = t.v | key[a][b];

            if (dist[a][b][nv] > dist[t.x][t.y][t.v] + 1) 
            {
                dist[a][b][nv] = dist[t.x][t.y][t.v] + 1;
                q.push({a, b, nv});
            }
            
            if (t.x == n && t.y == m) return dist[t.x][t.y][t.v];
        }
    }
    return -1;
}

int main() 
{
    cin >> n >> m >> p;
    int k; cin >> k;

    memset(g, -1, sizeof g);
    int x, y, a, b, t;
    while (k--) 
	{
        cin >> x >> y >> a >> b >> t;
        g[x][y][a][b] = g[a][b][x][y] = t;
    }

    int s; cin >> s;
    int q;
    while (s--) 
	{
        cin >> x >> y >> q;
        key[x][y] |= (1 << q);
    }

    cout << bfs();

    return 0;
}

```