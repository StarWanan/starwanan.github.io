#算法/前缀和


---
https://www.acwing.com/problem/content/description/1924/


题意:
	N个坐标, 每个坐标上有一个数
	可选定任意一个坐标 x, 使得 `[X - K, X + K]` 范围的数之和最大, 输出这个最大的数


思路:
	坐标排序, 构架前缀和数组, 枚举选定的 x (或者枚举左边界 `x - k`)


==ATT==: 坐标0上也可能有数据
==ATT2==: K可能很大,超出数组范围

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010, M = 2000010;

typedef long long LL;
typedef pair<int, int> PII;
#define x first
#define y second

int n, k;
PII a[N];
LL s[M];

int main()
{
    cin >> n >> k;
    for (int i = 1; i <= n; i ++)
        cin >> a[i].y >> a[i].x;
    sort(a + 1, a + 1 + n);
    
    int p = 1;
    if (a[1].x == 0) s[0] = a[p ++].y;
    for (int i = 1; i <= M; i ++)
    {
        s[i] = s[i - 1];
        if (i == a[p].x)
            s[i] += a[p ++].y;
    }
    
    // for (int i = 0; i < 16; i ++ )
    //     printf("%d ", s[i]);
    
    LL ans = s[min(M, 2 * k)];
    for (int i = 1; ; i ++)
    {
        ans = max(ans, s[min(M, i + 2 * k)] - s[i - 1]);
        if (i + 2 * k > M) break;
    }
    cout << ans << endl;
}
```
