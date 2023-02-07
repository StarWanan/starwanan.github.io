#算法/模拟 #算法/二路归并



---
https://www.acwing.com/problem/content/1936/



题意
	初始速度1, 每次减速变为 1/2, 1/3,.....
	有在时间节点的减速
	有在距离节点的减速
	求1000米所用时间

思路
	模拟

代码:
```cpp
#include <iostream>
#include <algorithm>

using namespace std;

const int N = 10010;

int n, n1, n2;
int a[N], b[N];

int main()
{
    cin >> n;
    while (n -- )
    {
        char op[2];
        int x;
        cin >> op >> x;
        if (*op == 'T') a[++ n1] = x;
        else b[++ n2] = x;
    }
    
    sort(a + 1, a + 1 + n1);
    sort(b + 1, b + 1 + n2);
    
    double t = 0, s = 0;
    int v = 1;
    int i, j;
    for (i = 1, j = 1; i <= n1 && j <= n2;)
    {
        double t1 = (b[j] - s) * v;
        double t2 = a[i] - t;
        if (t1 < t2)    // 距离点先到
        {
            t += t1;
            s = b[j];
            j ++;
            v ++;
        }
        else if (t2 < t1)   // 时间点先到   
        {
            s += 1.0 * (a[i] - t) / v;
            t = a[i];
            i ++;
            v ++;
        }else
        {
            t = a[i];
            s = b[j];
            i ++, j ++;
            v += 2;
        }
        
    }
    while (i <= n1)
    {
        s += 1.0 * (a[i] - t) / v;
        v ++;
        t = a[i ++];
    }
    
    while (j <= n2)
    {
        t += (b[j] - s) * 1.0 * v;
        v ++;
        s = b[j ++];
    }
    cout << (int)(t + (1000 - s) * v + 0.5);//加上最后一段
}
```