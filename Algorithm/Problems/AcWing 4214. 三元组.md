#算法/枚举  #算法/dp 
https://www.acwing.com/problem/content/4217/

给定两个长度为 n 的整数序列 s1,s2,…,sn 和 c1,c2,…,cn。
请你找到一个三元组 (i,j,k)，满足以下所有条件：
1.$i<j<k$
2. $s_i<s_j<s_k$
3. $c_i+c_j+c_k$ 尽可能小
输出 $c_i+c_j+c_k$ 的最小可能值。不存在输出-1

## 枚举
枚举j的位置, i/k分别处理即可

```cpp
#include <iostream>

using namespace std;

const int N = 3030, inf = 1e9;
int s[N], c[N];

int n;
int ans = inf;

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) cin >> s[i];
    for (int i = 1; i <= n; i ++) cin >> c[i];

    for (int j = 2; j < n; j ++)
    {
        int l = inf, r = inf;
        for (int i = 1; i < j; i ++) 
            if (s[i] < s[j]) l = min(c[i], l);
        for (int k = j + 1; k <= n; k ++) 
            if (s[k] > s[j]) r = min(c[k], r);
        ans = min(ans, l + r + c[j]);
    }
    if (ans == inf) puts("-1");
    else cout << ans << endl;
}
```


## dp
还没写完......
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>
#include <unordered_map>

using namespace std;

const int N = 3030;
int s[N], c[N], b[N];

int f[N][N];

int n;

unordered_map<int,int> id;

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) cin >> s[i], b[i] = s[i];
    for (int i = 1; i <= n; i ++) cin >> c[i];
    sort(b + 1, b + 1 + n);
    for (int i = 1; i <= n; i ++ )
        id[b[i]] = i;
    for (int i = 1; i <= n; i ++)
    {
        
    }
}
```