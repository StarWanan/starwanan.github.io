#算法/dfs 

---
https://www.acwing.com/problem/content/2007/



题意：
（）矩阵，走到该位置就一定获得该位置的括号类型，必须是类似`((()))`，而不能是`()()`。求括号匹配的最大长度。


思路：
dfs 注意回溯


代码：
```CPP
#include <iostream>

using namespace std;

const int N = 11;
int g[N][N];
int vis[N][N];
int n;
int ans;
int dx[4] = {-1, 0, 1, 0}, dy[4] = {0, 1, 0, -1};

void show(int a[][N])
{
    for (int i = 1; i <= n; i ++)
    {
        for (int j = 1; j <= n; j ++)
            cout << a[i][j] << ' ';
        cout << endl;
    }
    puts("--------------------");
}

void dfs(int x, int y, int cntl, int cntr)
{
    if (cntr == cntl)
    {
        // show(vis);
        ans = max(ans, cntl);
        return ;
    }
    for (int i = 0; i < 4; i ++)
    {
        int a = x + dx[i];
        int b = y + dy[i];
        
        if (vis[a][b] || a < 1 || a > n || b < 1 || b > n) continue;
        
        // printf("(%d,%d)\n", a, b);
        // if (g[a][b] == 0 && cntr != 0) continue;
        
        
        
        if (g[a][b] == 0 && cntr == 0) {
            vis[a][b] = 1;
            dfs(a, b, cntl + 1, cntr);
            vis[a][b] = 0;
        }
        
        if (g[a][b] == 1) 
        {
            vis[a][b] = 1;
            dfs(a, b, cntl, cntr + 1);
            vis[a][b] = 0;
        }
    }
}

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= n; j ++)
        {
            char c; cin >> c;
            if (c == '(') g[i][j] = 0;
            else g[i][j] = 1;
        }

    
    if (g[1][1] == 1) puts("0");
    else 
    {
        vis[1][1] = 1;
        dfs(1, 1, 1, 0);
        cout << ans * 2 << endl;
    }
    
    
    return 0;
}
```