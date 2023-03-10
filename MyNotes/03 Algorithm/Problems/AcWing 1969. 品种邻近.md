#算法/滑动窗口 #算法/枚举 




---
https://www.acwing.com/problem/content/1971/


题意:
n个数,  其中x, 满足有两个x在序列中的距离小于等于k.
找到最大的x, 如果没有输出-1

思路:

1. 最朴素的啥想法是双指针枚举, 一个个找过去.但是可能会超时
试了一下: ==TLE==
```cpp
#include <iostream>

using namespace std;

const int N = 50050;

int n, k;
int a[N];
int ans = -1;

int main()
{
    cin >> n >> k;
    for (int i = 1; i <= n; i ++)  cin >> a[i];
    
    for (int i = 1; i <= n; i ++)
    {
        int x = a[i];
        for (int j = i + 1; j <=n && j - i <= k; j ++)
        {
            if (a[j] == x) 
            {
                ans = max(ans, x);
                break;
            }
        }
    }
    cout << ans << endl;
}
```


1. 然后超时了, 但是其实可以用滑动窗口维护, 因为每次区间长度是固定的
==AC==
```cpp
#include <iostream>

using namespace std;

const int N = 50050, M = 1000010;

int n, k;
int a[N];
int ans = -1;
int num[M];

int main()
{
    cin >> n >> k;
    for (int i = 1; i <= n; i ++) cin >> a[i];
    for (int i = 1, j = 1; j <= n;) 
    {
        while (j - i <= k)
        {
            num[a[j]] ++;
            if (num[a[j]] > 1) ans = max(ans, a[j]);
            j ++;
        }
        num[a[i]] --;
        i ++;
    }
    cout << ans << endl;
}
```

