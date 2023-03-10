#算法/差分  #算法/离散化 

---
https://www.acwing.com/problem/content/1989/

题意：
坐标从0开始，N次移动，经过的地方被涂抹油漆。求至少被涂抹了 2 层油漆的区域的总长度。
距离出发地的距离不会超过 $10^9$。 


思路：
涂抹油漆相等于将一个区间中的数 +1。最后求前缀和得到原数组


代码：
```CPP
#include <iostream>
#include <map>

using namespace std;

const int N = 100010;

int n;
map<int,int> pos;

int main()
{
    cin >> n;
    int x = 0;
    for (int i = 1; i <= n; i ++)
    {
        int a; char op;
        cin >> a >> op;
        if (op == 'R')
        {
            pos[x] ++;
            pos[x + a] --;
            x += a;    
        }
        else if (op == 'L')
        {
            pos[x - a] ++;
            pos[x] --;
            x -= a;
        }   
        
    }
    
    int s = 0, last, ans = 0;
    for (auto [x, v] : pos)
    {
        if (s >= 2) ans += x - last;
        last = x;
        s += v;
        // printf("%d %d\n", x, v);
    }
    cout << ans << endl;
}
```

==ATT1==：不能用`unordered_map`，这样遍历的时候不是按顺序的

