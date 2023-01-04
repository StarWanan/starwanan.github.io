#算法/dfs  


---
4个整数`a, b, c, d`，3个操作`op1, op2, op3`（均为`*` 或 `+`）. 
进行3次op操作. 每次任意选取两个整数, 按顺序进行op (第一次op1, 第二次op2, 第三次op3)
输出最小的答案


可直接进行dfs, 存储使用`vector`


```cpp
#include <iostream>
#include <vector>

using namespace std;
typedef long long LL;

const int N = 11;
const LL inf = 2e12;

vector<LL> a;
char op[N];

int vis1[N], vis2[N];

LL ans = inf;

void dfs(int u, vector<LL> x)
{
    if (x.size() == 1)
    {
        ans = min(ans, x[0]);
        return ;
    }
    for (int i = 0; i < x.size(); i ++)
        for (int j = 0; j < x.size(); j ++)
        {
            if (i == j) continue;
            
            vector<LL> tmp;
            
            if (op[u] == '*') tmp.push_back(x[i] * x[j]);
            else tmp.push_back(x[i] + x[j]);
            
            for (int k = 0; k < x.size(); k ++)
                if (k != i && k != j)
                    tmp.push_back(x[k]);
                    
            dfs(u + 1, tmp);
        }
}

int main()
{
    for (int i = 0; i < 4; i ++) {
        int x;  cin >> x;
        a.push_back(x);
    }
    for (int i = 0; i < 3; i ++) cin >> op[i];
    
    dfs(0, a);

    cout << ans << endl;
}
```