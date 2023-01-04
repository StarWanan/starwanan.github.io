#算法/排序 #算法/前缀最值

相似题目：[[AcWing 1012. 友好城市]]
题目和动态规划里面的友好城市很像，友好城市是求最长上升子序列，一开始我也是这么做的，但是发现不是正解。这里开始上升的时候并不是就不相交了。


---
https://www.acwing.com/problem/content/1980/


题意：
两个坐标轴 `y=1, y=0` 上分别有 n 个点，对应两两相连，求不相交的线的数量


思路：
如果一个线不和其他另外所有的线相交，那么 `y=1` 上在x点左边的点对应的点在另一条轴上也应该在 x' 左边. 同理右边可证
所以维护两个数组:
	`lmax[i]` :  第i个点左边对应的点中, 坐标最大的
	`rmin[i]` :  第i个点右边对应的点中, 坐标最小的
	只要 `x' > lmax[i] && x' < rmin[i]` 就不相交


代码:
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

typedef pair<int, int> PII;
#define x first
#define y second

const int N = 100010, inf = 0x3f3f3f3f;

int n;
PII a[N];
int lmax[N], rmin[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
        cin >> a[i].x >> a[i].y;
    
    sort(a + 1, a + 1 + n);
    
    lmax[0] = -inf;
    rmin[n + 1] = inf;
    for (int i = 1; i <= n; i ++) lmax[i] = max(lmax[i - 1], a[i].y);
    for (int i = n; i >= 1; i --) rmin[i] = min(rmin[i + 1], a[i].y);
    
    int ans = 0;
    for (int i = 1; i <= n; i ++)
    {
        if (a[i].y > lmax[i - 1] && a[i].y < rmin[i + 1])
            ans ++;
    }
    
    cout << ans << endl;
    return 0;
}
```


