## AcWing 4604. 集合询问

https://www.acwing.com/problem/content/4607/

#算法/哈希表

题意：

初始时空集{}, 进行 t 次操作，操作分为：

- `+ x`，将一个非负整数 x 添加至集合中。注意，集合中可以存在多个相同的整数。
- `- x`，从集合中删除一个非负整数 x。可以保证执行此操作时，集合中至少存在一个 x。
- `? s`，询问操作，给定一个由 0 和 1 组成的模板 s，请你计算并输出此时集合中有多少个元素可以与 s 相匹配。

判断匹配的方法：

- 将模版和 x 高位补0至相同位数。
- 在每个位置i，模版若为1，x第i位则为奇数；若为0，x第i位则为偶数。

$1≤t≤10^5，0≤x<10^{18}，s 的长度范围 [1,18]$



题解：

一个模版可以对应很多个数，相反的，通过一个数x可以计算出对应的唯一的模版s

所以用数组模拟哈希表就可以达到 O(1) 查询

通过长度可以发现，s最大是 $2^{18}$ ，大概是100，000。

```c++
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;
const int N = 1000010;
int t;
int cnt[N];

int main()
{
    scanf("%d", &t);
    
    char op[2], str[20];
    
    while (t --)
    {
        scanf("%s%s", op, str);
        int x = 0;
        for (int i = 0; str[i]; i ++)
            x = x * 2 + str[i] % 2;
        // cout << x << endl;
        if (*op == '+') cnt[x] ++;
        else if (*op == '-') cnt[x] --;
        else if (*op == '?') printf("%d\n", cnt[x]);
    }
}
```

