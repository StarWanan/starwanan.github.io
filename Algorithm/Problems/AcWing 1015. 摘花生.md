#算法/dp/数字三角形
https://www.acwing.com/problem/content/1017/

一个 `n*m` 的矩阵, 每个格子有一个数，从左上角走到右下角。只能横向或纵向走。求路径上的数总和最大。


```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;
int t;
int n, m;
int g[N][N], f[N][N];

int main()
{
    cin >> t;
    while (t --) {    
        cin >> n >> m;
        for (int i = 1; i <= n; i ++ ) {
            for (int j = 1; j <= m; j ++ )  {
                cin >> g[i][j];
            }
        }
        memset(f, 0, sizeof f);
        for (int i = 1; i <=n; i ++) {
            for (int j = 1; j <= m; j ++) {
                f[i][j] = max(f[i][j], f[i - 1][j]);
                f[i][j] = max(f[i][j], f[i][j - 1]);
                f[i][j] += g[i][j];
            }
        }
        cout << f[n][m] << endl;
    }
}
```