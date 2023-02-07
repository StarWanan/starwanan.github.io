#算法/思维 



---
https://www.acwing.com/problem/content/1906/

题意:
	一个无限长的数轴上, 有不同位置的牛以不同速度向前进. 当撞到前面的牛时, 就要减速至与其一致. 成为一个小组.
	问最后能有多少个小组

思路:
	无限长, 意思是只要后面优速的大的, 就一定能追上前面的. 换言之, 最后的速度一定是由前面的牛决定的.
	倒序遍历, 找局部最小值, 就是这个小组的最终速度. 有几个局部最小, 就有几组


```cpp
#include <iostream>

using namespace std;

const int N = 100010;

int n;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
    {
        int  x;
        cin >> x >> a[i];
    }
    int ans = 0;
    int mmin = a[n];
    for (int i = n; i >= 1; i --)
    {
        if (mmin >= a[i])
        {
            mmin = a[i];
            ans ++;
        }
    }
    cout << ans << endl;
}
```