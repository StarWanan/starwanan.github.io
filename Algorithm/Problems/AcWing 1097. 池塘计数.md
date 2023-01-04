#算法/flood-fill 


下一难度：[[AcWing 1098. 城堡问题]]
	难点：抽象题意。将格子中的墙，转变为转移时的限制

下一难度：[[AcWing 1106. 山峰和山谷]]
	难点：抽象题意。处理一整个连通块的边界，判断种类从而分类计数

---
[题目链接](https://www.acwing.com/activity/content/problem/content/1468/)


题意：求连通块个数

思路：dfs

代码：
```cpp
#include <iostream>

using namespace std;

const int N = 1010;

char g[N][N];
int vis[N][N];
int ans;
int n, m;

int dx[] = {-1, 0 ,1, 0, -1, 1, 1, -1};
int dy[] = {0, 1, 0, -1, 1, 1, -1, -1};

void dfs(int x, int y)
{
    vis[x][y] = 1;
    for (int i = 0; i < 8; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        if (a < 1 || a > n || b < 1 || b > m) continue;
        if (vis[a][b]) continue;
        if (g[a][b] == '.') continue;
        dfs(a, b);
    }
}

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; i ++)
        cin >> g[i] + 1;
    
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= m; j ++)
            if (!vis[i][j] && g[i][j] == 'W') dfs(i, j), ++ans;
    
    cout << ans << endl;
    return 0;
}
```
