#算法/模拟  #算法/字符串


---
https://www.acwing.com/problem/content/4215/

不区分大小写比较两个字符串

```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 110;

string a, b;

int main()
{
    cin >> a >> b;
    for (int i = 0; i < a.size(); i ++)
    {
        if (a[i] >= 'A' && a[i] <= 'Z') a[i] += 32;
        if (b[i] >= 'A' && b[i] <= 'Z') b[i] += 32;
    }
    if (a > b) puts("1");
    else if (a < b) puts("-1");
    else puts("0");
}
```