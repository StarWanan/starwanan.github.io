#算法/dp/数字三角形 

https://www.acwing.com/problem/content/1020/

一个 `n*n` 的方阵, 每个格子有一个数，从左上角走到右下角。只能横向或纵向走。求路径上的数总和最小。

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;
int n;
int g[N][N];
int f[N][N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            cin >> g[i][j];
        }
    }
    memset(f, 0x3f, sizeof f);
    f[1][0] = f[0][1] = 0;
    for (int i = 1; i <= n; i ++) {
        for (int j = 1; j <= n; j ++) {
            f[i][j] = min(f[i][j], min(f[i - 1][j], f[i][j - 1]));
            f[i][j] += g[i][j];
        }
    }
    cout << f[n][n] << endl;
}
```
