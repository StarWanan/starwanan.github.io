#算法/差分

---
https://www.acwing.com/problem/content/2043/


题意：
K次操作，在[L,R]区间数量加一。求操作之后，[1,N]中所有的数的中位数

思路：
差分修改，前缀和求出数组，sort排序，输出中位数


代码：
```CPP
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1000100;
int s[N], d[N];
int n, k;

int main()
{
    cin >> n >> k;
    while (k --)
    {
        int l, r;
        cin >> l >> r;
        d[l] ++;
        d[r + 1] --;
    }
    for (int i = 1; i <= n; i ++)
        s[i] = s[i - 1] + d[i];
    sort(s + 1, s + 1 + n);
    cout << s[n / 2 + 1] << endl;
}
```