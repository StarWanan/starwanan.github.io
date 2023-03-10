#算法/Trie #算法/贪心 

https://www.acwing.com/activity/content/problem/content/884/

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010, M = N*31;
int son[M][2], idx = 1; 

int a[N];
int n, ans;

void insert(int x)
{
    int p = 0;
    for (int i = 30; i >= 0; i --) {
        int u = x >> i & 1;
        if (!son[p][u]) son[p][u] = idx ++;
        p = son[p][u];
    }
}

int query(int x)
{
    int res = 0;
    int p = 0;
    for (int i = 30; i >= 0; i --) {
        int u = x >> i & 1;
        if (son[p][!u]) {
            p = son[p][!u];
            res = (res << 1) | 1;
        }else {
            p = son[p][u];
            res <<= 1;
        }
    }
    return res;
}

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) {
        cin >> a[i];
        insert(a[i]);
    }
    for (int i = 1; i <= n; i ++) {
        ans = max(ans, query(a[i]));   
    }
    cout << ans << endl;
    return 0;
}
```

