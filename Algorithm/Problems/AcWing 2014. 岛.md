#算法/思维 #算法/枚举  #算法/离散化




---

https://www.acwing.com/problem/content/2016/

题意：
一列高度不同的山，海平面会处在不同高度。求某个时刻岛屿最多的数目
$H_i <= 10^9, N <= 10^5$   所以需要离散化


思路：
枚举海平面高度，从高到低。高度使用贡献法，遍历一遍确定不同高度的贡献。


代码：
```CPP
#include <iostream>
#include <algorithm>
#include <unordered_map>

using namespace std;

const int N = 100010, M = 10010;

int n;
int a[N], b[N]; 

unordered_map<int,int> id;
unordered_map<int,int> cnt;

void lisan()
{
    for (int i = 1; i <= n; i ++) b[i] = a[i];
    
    sort(b + 1, b + 1 + n);
    int m = unique(b + 1, b + 1 + n) - b - 1;
    
    // for (int i = 0; i <= m; i ++)
    //     printf("%d ", b[i]);
    // puts("");
    
    for (int i = 0; i <= m; i ++) id[b[i]] = i;
}

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
    {
        cin >> a[i];
        if (a[i] == a[i - 1]) i--, n--;
    }

    a[0] = a[n + 1] = 0;
    
    lisan();
    
    for (int i = 1; i <= n; i ++)
    {
        int x = id[a[i - 1]], y = id[a[i]], z = id[a[i + 1]];
        if (x < y && y > z) cnt[y] ++;
        else if (x > y && y < z) cnt[y] --;
    }

    int ans = 0, sum = 0;
    for (int i = N; i; i --)
    {
        sum += cnt[i];
        ans = max(ans, sum);
    }
    cout << ans << endl;
}

```

