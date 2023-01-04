## AcWing 835. Trie字符串统计

https://www.acwing.com/activity/content/problem/content/883/

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 10020;

int son[N][26], idx = 1;
int cnt[N];
int n;

void insert(string s)
{
    int p = 0;
    for (auto x : s)
    {
        int u = x - 'a';
        if (!son[p][u]) son[p][u] = idx ++;
        p = son[p][u];
    }
    cnt[p] ++;
}

int query(string s)
{
    int p = 0;
    for (auto x : s) {
        int u = x - 'a';
        if (!son[p][u]) return 0;
        p = son[p][u];
    }
    return cnt[p];
}

int main()
{
    cin >> n;
    char op[2];
    string s;
    while (n --) {
        cin >> op >> s;
        if (*op == 'I') {
            insert(s);
        }else {
            cout << query(s) << endl;
        }
    }
    return 0;
}
```

