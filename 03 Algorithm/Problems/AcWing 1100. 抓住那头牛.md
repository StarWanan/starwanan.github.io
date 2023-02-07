#算法/图论 




---
[原题链接](https://www.acwing.com/problem/content/1102/)

题意:
	数轴上起始点N， 终点K。
	移动方式：
		1. x -> x-1  或 x-> x+1
		2. x -> 2x
	求最短路径长度

思路:
	bfs搜索

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

const int N = 200100;
int n, k;
int dis[N];

int bfs()
{
    queue<int> q;
    q.push(n);
    memset(dis, 0x3f, sizeof dis);
    dis[n] = 0;
    while (q.size())
    {
        int t = q.front(); q.pop();
        if (t == k)
            return dis[t];
        // printf("%d : %d\n", t, dis[t]);
        
        int a;
        
        a = t + 1;
        if (t < k && dis[a] > dis[t] + 1)
        {
            dis[a] = dis[t] + 1;
            q.push(a);
        }
        a = t * 2;
        if (t < k && dis[a] > dis[t] + 1)
        {
            dis[a] = dis[t] + 1;
            q.push(a);
        }
    
        a = t - 1;
        if (a >= 0 && dis[a] > dis[t] + 1)
        {
            dis[a] = dis[t] + 1;
            q.push(a);
        }
        
        
        
    }
    return -1;
}

int main()
{
    cin >> n >> k;
    cout << bfs();
    return 0;
}
```