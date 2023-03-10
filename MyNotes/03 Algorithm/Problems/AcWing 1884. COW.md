#算法/前缀和  #算法/枚举  #算法/递推 
#算法/状态机 #算法/dp 

---
https://www.acwing.com/problem/content/1886/

题意
	有只包含C、O、W三个字母的字符串，求可以组成多少个“COW”的子序列

思路
- 我一上来就是用了前缀和，之后遍历一遍枚举 ‘O’，将这个O前面'C'的数量乘后面'W'的数量
- 所以代码里面'O'的前缀和是不用做的, 而且其实可以从后向前算'W'的前缀和, 但是基本没差, 就不改了

```CPP
#include <iostream>

using namespace std;

const int N = 100010;

int n;
char str[N];
int s[N][3];
long long ans;

int main()
{
    cin >> n;
    cin >> str + 1;
    for (int i = 1; i <= n; i ++)
    {
        for (int j = 0; j < 3; j ++) s[i][j] = s[i - 1][j];
        if (str[i] == 'C') s[i][0] ++;
        else if (str[i] == 'O') s[i][1] ++;
        else if (str[i] == 'W') s[i][2] ++;
    }
    
    for (int i = 2; i <= n - 1; i ++)
    {
        if (str[i] == 'O')
        {
            ans += s[i][0] * (s[n][2] - s[i][2]);
        }
    }
    cout << ans << endl;
}

```


但是看题目的标签是状态机dp
![[_file/Pasted image 20220122094142.png]]
```CPP
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010;

int n;
char str[N];
long long f[N][3]; 
/*
    f[i][0]: 前i个字母中, "C" 的个数
    f[i][1]: 前i个字母中, "CO" 的个数
    f[i][2]: 前i个字母中, "COW" 的个数
*/

int main()
{
    cin >> n;
    cin >> str + 1;
    for (int i = 1; i <= n; i ++)
    {
        f[i][0] = f[i - 1][0];
        f[i][1] = f[i - 1][1];
        f[i][2] = f[i - 1][2];
        if (str[i] == 'C') f[i][0] ++;
        else if (str[i] == 'O') f[i][1] += f[i - 1][0];
        else if (str[i] == 'W') f[i][2] += f[i - 1][1];
    }
    cout << f[n][2] << endl;
}
```

当然可以优化一下空间
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010;

int n;
char str[N];
long long c, o, w; 
/*
    c: "C" 的个数
    o: "CO" 的个数
    w: "COW" 的个数
*/

int main()
{
    cin >> n;
    cin >> str + 1;
    for (int i = 1; i <= n; i ++)
    {
        if (str[i] == 'C') c ++;
        else if (str[i] == 'O') o += c;
        else if (str[i] == 'W') w += o;
    }
    cout << w << endl;
}
```

也可以用位运算继续稍微优化一下时间
```cpp
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

const int N = 100010;

int n;
char str[N];
long long c, o, w; 
/*
    c: "C" 的个数
    o: "CO" 的个数
    w: "COW" 的个数
*/

int main()
{
    cin >> n;
    cin >> str + 1;
    for (int i = 1; i <= n; i ++)
    {
        char ch = str[i];
        c += !(ch ^ 0x43);
        o += c * !(ch ^ 0x4f);
        w += o * !(ch ^ 0x57);
        /*
         ASCII码中:
            'C' 是 0x43
            'O' 是 0x4f
            'W' 是 0x57
         如果是对应字母, 那么异或上自己一定为0. 省去判断时间
        */
    }
    cout << w << endl;
}
```