#算法/贪心 #算法/二分

---
https://www.acwing.com/problem/content/1998/


题意：
n个字符串，可以按任意顺序排列。求每个串在按字典序排序情况下可以处在的最低位置和最高位置


思路：
对于最低位置：让其他的串都尽可能大，而这一串尽可能小
对于最高位置：让其他的串都尽可能小，而这一串尽可能大


代码：
```CPP
#include <iostream>
#include <algorithm>

using namespace std;

const int N = 500050;

typedef pair<int, int> PII;
#define x first
#define y second

int n;

string str[N], ustr[N], dstr[N];
string ds[N], us[N];

PII ans[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++)
    {
        cin >> str[i];
        
        sort(str[i].begin(), str[i].end(), greater<char>());
        dstr[i] = ds[i] = str[i];
        
        sort(str[i].begin(), str[i].end());
        ustr[i] = us[i] = str[i];
    }
    
    sort(ds + 1, ds + 1 + n);
    sort(us + 1, us + 1 + n);
    
    for (int i = 1; i <= n; i ++)
    {
        // 小 升序(ustr)去降序队列(ds)里面找位置
        string t =ustr[i];
        int l = 1, r = n;
        while (l < r)
        {
            int mid = l + r >> 1;
            if (ds[mid] < ustr[i]) l = mid + 1;
            else r = mid;
        }
        cout << r << ' ';
        
        // 大 大的序列(dstr)在小的排列(us)里面找
        t = dstr[i];
        l = 1, r = n;
        while (l < r)
        {
            int mid = l + r + 1 >> 1;
            if (us[mid] > t) r = mid - 1;
            else l = mid;
        }
        cout << r << endl;
    }
    
}

```