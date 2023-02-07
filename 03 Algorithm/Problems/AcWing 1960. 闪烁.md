#算法/状态压缩 #算法/找环



---
https://www.acwing.com/problem/content/1962/


题意:
	长度为 n 的01串, 每次变换的规律是: 
		如果左边一位是1, 那么这一位就变化
		否则则不变
	求变化 B 次后的情况
	$3≤N≤16,$
	$1≤B≤10^{15}$

思路:
	状态压缩, int表示串, 最多只有 $2^{16}$ 的情况. 那么一定存在环
	变化步数取余后进行变化, 最终输出答案
	


代码:
```cpp
#include <iostream>
#include <cstring>

using namespace std;

const int N = 1 << 16;

typedef long long LL;

int n;
LL m;
int vis[N];     // vis[state] = i: 状态state的编号是i


void show(int state)
{
    for (int i = 0; i < n; i ++)
    {
        cout << (state >> i & 1) << endl;
    }
}

int get(int state)
{
    int res = 0;
    for (int i = 0; i < n; i ++)
    {
        int p = i;
        int q = (i - 1 + n) % n;
        int x = (state >> p & 1) ^ (state >> q & 1);
        res |= x << i;
    }
    return res;
}

int main()
{
    cin >> n >> m;
    int state = 0;
    for (int i = 0; i < n; i ++)
    {
        int x; cin >> x;
        state |= (x << i);
    }
    
    memset(vis, -1, sizeof vis);
    vis[state] = 0;
    
    for (int i = 1; ; i ++)
    {
        state = get(state);
        if (i == m) 
        {
            show(state);
            break;
        }
        if (vis[state] == -1) vis[state] = i;
        else 
        {
            int d = i - vis[state];
            int r = (m - i) % d;
            while (r --) state = get(state);
            show(state);
            break;
        }
    }
}
```


