#算法/模拟 #算法/置换

---
https://www.acwing.com/problem/content/description/1764/

n个牛每个牛有唯一id（7位数）和唯一编号（1-n）
置换3次，每次根据 `A[N]` 置换，`a[i]` 表示位置i要换到位置 `a_i`
给出 `A[i]` 和 3次置换后的顺序, 求原始顺序并输出 id

模拟

```CPP
#include <iostream>
#include <unordered_map>

using namespace std;

const int N = 110;

int n;
int a[N], b[N];
string s[N];
unordered_map<int,string> id;

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++) cin >> a[i];
    for (int i = 1; i <= n; i ++)
    {
        int x = a[i];
        x = a[x];
        x = a[x];
        b[x] = i;
    }
    for (int i = 1; i <= n; i ++) cin >> s[i];
    for (int i = 1; i <= n; i ++) id[b[i]] = s[i];
    for (int i = 1; i <= n; i ++) cout << id[i] << endl;
}
```
