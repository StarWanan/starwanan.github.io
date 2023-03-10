#算法/思维 

---
https://www.acwing.com/problem/content/description/1698/

1-n 随机排列。每次只能让最前面的数向后移动k个位置（k可取1~N-1任意值）
最少需要多少步，能够变成1-N的排列

局部排序：只要有一个数不在位置上，那么这个数之前的数都需要修改
每一段找逆序的位置，累加前面升序数的个数


```CPP
#include <iostream>

using namespace std;

const int N = 110;

int n, ans;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++ ) cin >> a[i];
    int cnt = 1;
    for (int i = 1; i < n; i ++ )
    {
        if (a[i] < a[i + 1]) cnt ++;
        else
        {
            ans += cnt;
            cnt = 1;
        }
    }
    cout << ans << endl;
}
```

如果一个牛它后面有一个比它序列小的，但必然它得移走，不然它后面永远到不了它前面。前面只要移动，那么一定有办法是一次性移动到位。
```CPP
#include <iostream>

using namespace std;

const int N = 110;

int n, ans;
int a[N];

int main()
{
    cin >> n;
    for (int i = 1; i <= n; i ++ ) {
        cin >> a[i];
        if (a[i] < a[i -1]) ans = i - 1;
    }
    cout << ans << endl;
}


```
