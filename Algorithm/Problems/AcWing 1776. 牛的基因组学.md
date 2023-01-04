#算法/枚举 

---
https://www.acwing.com/problem/content/1778/

2组字符串，每组N串M位。每一位可能字符是 `A C G T` 
如果在某一位上，仅靠这一位就可以分辨两组字符串，那么便符合条件，求这样的有多少位


首先枚举每一位，在位置 pos 上：
	1. 清空标记数组
	2. 遍历第一组N个字符串的 pos 位， 标记这一位上哪些字符出现过
	3. 遍历第二组N个字符串，如果字符和标记没有重合，即满足条件


```CPP
#include <iostream>
#include <unordered_map>

using namespace std;

const int N = 110;

int n, m;
char s1[N][N], s2[N][N];
int st[N];

int ans;

int main()
{
    cin >> n >> m;
    for (int i = 1; i <= n; i ++) cin >> s1[i] + 1;
    for (int i = 1; i <= n; i ++) cin >> s2[i] + 1;
    
    for (int j = 1; j <= m; j ++)
    {
        st['A'] = st['C'] = st['G'] = st['T'] = 0;
        
        for (int i = 1; i <= n; i ++)
            st[s1[i][j]] = 1;
        
        if (st['A'] && st['C'] && st['G'] && st['T']) continue;
        
        bool flag = true;
        for (int i = 1; i <= n; i ++)
            if (st[s2[i][j]] == 1) 
            {
                flag = false;
                break;
            }
            
        if (flag) ans ++;
    }
    
    cout << ans << endl;
    
}
```