#算法/dfs 


---
https://www.acwing.com/problem/content/1877/


7个变量`B,E,S,I,G,O,M `组成表达式: `(B+E+S+S+I+E)(G+O+E+S)(M+O+O) `
每个变量有不同的可以取的值, 求最后表达式结果为偶数的方案数



首先化简为: `(B+I)(G+O+E+S)(M)`
只要有一项不是奇数, 那么答案一定为偶数.  dfs枚举情况



```cpp
#include <iostream>

using namespace std;

const int N = 110;
int n;
int ans;
int ce[N], co[N];
int a[N];

string str = "BESIGOM";

void dfs(int u, int cnt)    // u：当前枚举到的字母  cnt：可能的情况数量
{
    if (u >= 7)
    {
        if ( ( (a['B'] + a['I']) & 1 ) && ((a['G'] + a['O'] + a['E'] + a['S']) & 1) && (a['M'] & 1) )    // 三项全是奇数。答案必定为奇数，此情况舍去 
            return ;
        ans += cnt;
        return ;
    }
    char x = str[u];    // 当前枚举到的字母
    a[x] = 1;    // 奇数
    dfs(u + 1, cnt * co[x]);
    a[x] = 2;    // 偶数
    dfs(u + 1, cnt * ce[x]);
    
}

int main()
{
    cin >> n;
    char c; int x;
    while (n -- ){
        cin >> c >> x;
        if (x & 1) co[c] ++;
        else ce[c] ++;
    }
    
    dfs(0, 1);
    
    cout << ans << endl;
    return 0;
}
```