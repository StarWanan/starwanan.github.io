#算法/差分 




---
https://www.acwing.com/problem/content/1954/

题意:
 N个奶牛, 每个奶牛有一个舒适区间[A,B], 如果温度(Y>X, Y>Z):
	t < A 产奶 X
	t > B 产奶 Z
	A <= t <= B 产奶 Y
 温度课随意调节, 求最大产奶量


思路:
 差分 + 离散化


代码:
```cpp
#include <iostream>
#include <map>

using namespace std;
typedef pair<int, int> PII;
#define x first
#define y second
 
const int N = 20020;

int n, x, y, z;
map<int,int> d;

int main()
{
    cin >> n >> x >> y >> z;
    for (int i = 1; i <= n; i ++)
    {
        int a, b;
        cin >> a >> b;
        d[0] += x;
        d[a] += y - x;
        d[b + 1] += z - y;
    }
    int ans = 0, sum = 0;
    for (auto &[x, v]: d)
    {
        sum += v;
        ans = max(ans, sum);
    }
    cout << ans << endl;
}


```