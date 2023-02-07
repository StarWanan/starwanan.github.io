#算法/hash #算法/前缀和  #算法/枚举 


---
https://www.acwing.com/problem/content/1915/

题意：
	在不同的坐标上有G，H两种类型。选取最长的一段区间使得区间内是全G，全H或者G、H数量相等，求这个区间长度
	$1≤N≤10^5$
	$0≤xi≤10^9$

思路：
	先处理全G或全H的情况
	转化G，H为1，-1
	区间内两种类型相等，加起来的和就是0。使用前缀和。因为范围过大，所以使用hash表优化：
		`sum[i] - sum[j]  = 0`, 即 `sum[i] == sum[j]` 对于i来说，要找到最左边的j， 所以hash表存每一个sum第一次出现的位置, 也就是坐标最小的位置


```cpp
#include <iostream>
#include <unordered_map>
#include <algorithm>

using namespace std;

const int N = 100010;
typedef pair<int, int> PII;
#define x first
#define y second

int n, ans;
PII q[N];

int main()
{
    cin >> n;
    
    int x;
    char ty;
    for (int i = 1; i <= n; i ++)
    {
        cin >> x >> ty;
        if (ty == 'G') q[i] = {x, 1};
        else q[i] = {x, -1};
    }
    sort(q + 1, q + 1 + n);
    
    unordered_map<int,int> hash;
    
    int last = 0, sum = 0;
    for (int i = 1; i <= n; i ++)
    {
        if (!hash.count(sum)) hash[sum] = q[i].x;
        
        sum += q[i].y;
        if (hash.count(sum)) ans = max(ans, q[i].x - hash[sum]);
        
        if (i == 1 || q[i].y != q[i - 1].y) last = q[i].x;
        ans = max(ans, q[i].x - last);
    }
    cout << ans << endl; 
}
```



