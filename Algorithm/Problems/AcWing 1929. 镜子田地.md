#算法/环图 #算法/搜素




---
https://www.acwing.com/problem/content/1931/


题意：
	n * m的矩阵中每个格子都摆放镜子，`/` 或者 `\`   从外界可以垂直或者水平照射光, 求最多反射的次数, 如果可以无限反射输出-1

思路:
	直接搜索, 因为有限制, 所以复杂度可以
	==环图==: 每个点的度都 <= 2   那么图中只由环或者简单路径构成

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

const int N = 1010;

int n, m;
int ans;

char g[N][N];
int vis[N][N][5];

int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};

int dfs(int x, int y, int d)
{
    int len = 1;
    if (g[x][y] == '/')
    {
        if (d == 0) d = 1;
        else if (d == 1) d = 0;
        else if (d == 2) d = 3;
        else if (d == 3) d = 2;
    }
    else if (g[x][y] == '\\')
    {
        if (d == 0) d = 3;
        else if (d == 1) d = 2;
        else if (d == 2) d = 1;
        else if (d == 3) d = 0;
    }
    int a = x + dx[d];
    int b = y + dy[d];
    if (a < 1 || a > n || b < 1 || b > m) return len;
    len += dfs(a, b, d);
    return len;
}

int main()
{
    cin >> n >> m;
    queue<PII> q;
    for (int i = 1; i <= n; i ++) 
        cin >> g[i] + 1;
    
    for (int i = 1; i <= n; i ++)
        ans = max(ans, dfs(i, 1, 1));
    for (int i = 1; i <= n; i ++)
        ans = max(ans, dfs(i, m, 3));
    for (int i = 1; i <= m; i ++)
        ans = max(ans, dfs(1, i, 2));
    for (int i = 1; i <= m; i ++)    
        ans = max(ans, dfs(n, i, 0));
    
    cout << ans << endl;
    
    return 0;
}
```