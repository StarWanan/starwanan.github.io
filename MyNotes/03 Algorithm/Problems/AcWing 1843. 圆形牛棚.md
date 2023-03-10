#算法/枚举 

---
https://www.acwing.com/problem/content/submission/code_detail/10362676/

圆形牛棚，有n个房间互相连通，每个房间需要有 $a_i$  头牛, 在任意一个房间中让所有的牛进入然后按照顺时针行进最后满足条件. 求所有牛需要行走的最小距离


枚举


```CPP
#include <iostream>

using namespace std;

const int N = 1010;

int n;
int ans = 1e9;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
        cin >> a[i];
    for (int i = 1; i <= n; i ++)
    {
        int sum = 0;
        for (int j = i, k = 1; k <= n; k ++, j ++)
        {
            sum += (j - i) * a[(j - 1) % n + 1];
        }
        ans = min(ans, sum);
    }
    cout << ans << endl;
}
```