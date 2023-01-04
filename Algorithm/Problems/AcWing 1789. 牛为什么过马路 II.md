#算法/栈 #算法/枚举 

---
https://www.acwing.com/problem/content/1791/

输入52个字母，包含A-Z各两个。相同字母为一条路径，求有多少交叉路径
PS：交叉路径是指 ABAB 两个相同字母之间夹杂另外字母的==一个==

用栈预处理字符串，使得成对相邻的相同字母都被处理掉 ABCCAB -> ABAB，并记录下字母的位置
之后枚举每个字母
枚举时要记得标记枚举过的字母，避免重复计算

```cpp
#include <iostream>

using namespace std;

typedef pair<int, int> PII;
#define x first
#define y second

const int N = 110;

pair<int,int> pos[N];
char st[N];
char s[N];
int idx;

int main()
{
    cin >> s + 1;
    st[++ idx] = s[1];
    pos[s[1]].x = idx;
    for (int i = 2; i <= 52; i ++)
    {
        if (s[i] == st[idx]) 
        {
            st[idx --] = '\0';
            pos[s[i]].x = 0;
        }
        else // 入栈
        {
            st[++ idx] = s[i];
            if (pos[s[i]].x  == 0) pos[s[i]].x = idx;
            else pos[s[i]].y = idx;
        }
    }
    
    // cout << st + 1 << endl;
    
    int ans = 0;
    // for (int i = 1; i <= idx; i ++)
    // {
    //     char c = st[i];
    //     printf("%c: %d - %d\n", c, pos[c].x, pos[c].y);
    //     int l = pos[c].x, r = pos[c].y;
    //     if (l < i) continue;
    //     ans += r - l - 1;
    //     i = r;
    // }
    
    for (int i = 1; i <= idx; i ++)
    {
        char c = st[i];
        if (c == '0') continue;
        int l = pos[c].x, r = pos[c].y;
        for (int j = i + 1; ; j ++)
        {
            char x = st[j];
            if (x == c) break;
            else
            {
                int l1 = pos[x].x, r1 = pos[x].y;
                if (l < l1 && r1 > r) ans ++;
            }
        }
        st[l] = st[r] = '0';
    }
    
    cout << ans << endl;
}
```
