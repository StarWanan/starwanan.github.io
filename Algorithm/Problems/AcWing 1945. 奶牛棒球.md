#算法/双指针 #算法/枚举  #算法/暴力




----

题意:
一个序列, 代表在坐标轴上的位置,找出有多少个三元组(X,Y,Z) 
满足: X < Y < Z && |Y - X| <= |Z - Y| && |Z -  Y| <= 2 * |Y - X|
$N \le 1000$

思路:
三指针暴力枚举


代码：
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 1010;

int n;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) cin >> a[i];
    sort(a + 1, a + 1 + n);
    
    int ans = 0;
    for (int i = 1; i <= n; i ++)
        for (int j = i + 1; j <= n; j ++)
            for (int k = j + 1; k <= n; k ++)
                if ((a[k] - a[j]) >= (a[j] - a[i]) && (a[k] - a[j]) <= 2 * (a[j] - a[i]))
                    ans ++;
    
    cout << ans <<endl;
    return 0;
}
```