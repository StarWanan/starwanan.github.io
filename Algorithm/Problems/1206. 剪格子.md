https://www.acwing.com/problem/content/description/1208/
#算法/搜索  #算法/剪枝 #算法/dfs #算法/bfs #算法/哈希 

n * m 的方格，每个格子上有一个数字。需要将其剪裁成两部分，使得两部分和相等。输出包含左上角格子方案数最小的数量。如果没有合法方案，输出0

首先全部的元素和如果是奇数，一定没有答案
有答案的情况下要包含左上角的格子，那么直接从左上角开始搜索即可

搜索结束后，这是保证一定联通的，那么找到这个连通块外的任意一个通过bfs判断剩下的所有各自是否连通，如果联通说明是合法方案，如果不连通说明是非法方案。记录下最小值即可。

第二个问题是，dfs只能保证搜出一条路径，并不能进行分支搜索，那么就需要提前加一个预处理。
首先一直维护一个vector数组，表示已经搜过的格子。在下一次dfs递归之前，先遍历所有搜过的格子下一步可搜索的点，保存下来成为一个tofind，也就是下一步可以搜索的点的集合，在遍历这个集合去进行下一步搜索。

这样已经可以通过8组数据，剩余3组会超时，所以要进行剪枝。最主要的是一个哈希判断对方案判重。

这样可以通过10组，还有最后一组。这个是要对tofind进行排序，从后向前遍历搜索，这样答案会更快收敛。因为前面的点大概率会重复。


```CPP
#include <iostream>
#include <cstring>
#include <queue>
#include <unordered_set>
#include <vector>
#include <algorithm>

using namespace std;
typedef long long LL;
typedef pair<int,int> PII;
#define x first
#define y second

const int N = 12, inf  = 0x3f3f3f3f, P = 120;

unordered_set<unsigned long long> se;
vector<PII> method;

int dx[] = {-1, 0, 1, 0}, dy[] = {0, 1, 0, -1};
bool st[N][N], st1[N][N];

int n, m;
int g[N][N];
int sum, sum_g;
int ans = inf;

int getid(int x, int y){ //计算一维编号
    return (x - 1) * m + y;
}

bool bfs(int x, int y, int tar)
{
    memset(st1, 0, sizeof st1);
    st1[x][y] = 1;
    int cnt = 1;
    queue<PII> q;
    q.push({x, y});
    while (q. size())
    {
        PII t = q.front(); q.pop();
        for (int i = 0; i < 4; i ++)
        {
            int a = t.x + dx[i], b = t.y + dy[i];
            if (a < 1 || a > n || b < 1 || b > m) continue;
            if (st[a][b] || st1[a][b]) continue;
            st1[a][b] = 1;
            q.push({a, b}); cnt ++;
        }
    }
    return cnt == tar;
}


bool check(vector<PII> u){//哈希表查重
    sort(u.begin(),u.end());
    unsigned long long x = 0;
    for (auto id:u){
        x = x*P + id.x;
        x = x*P + id.y;
    }
    if (se.count(x)) {
        return true;//如果该方案已存在，返回
    }
    se.insert(x);//插入新方案
    return false;
}

void dfs(int cnt, int num)
{
    if (num == sum_g) return ;
    if (num > ans) return ;
    if (cnt > (sum >> 1)) return ;
    if (check(method)) return ;
    if (cnt == (sum >> 1)) {
        int flag = 0;
        for (int i = n; i >= 1; i --)
            for (int j = m; j >= 1; j --)
                if (st[i][j] == 0) {
                    flag =bfs(i, j, sum_g - num);
                    break;
                }
        if (flag) ans = min(ans, num);
        return ;
    }

    vector<PII> tofind;
    int tost[N][N] = {0};
    for (auto t : method)
    {
        int a = t.x, b = t.y;
        tost[a][b] = 1;
        for (int i = 0; i < 4; i ++)
        {
            int nx = a + dx[i], ny = b + dy[i];
            if (nx < 1 || nx > n || ny < 1 || ny > m) continue;
            if (st[nx][ny] || tost[nx][ny]) continue;
            tost[nx][ny] = 1;
            tofind.push_back({nx, ny});
        }
    }

    sort(tofind.begin(), tofind.end());
    for (int i = tofind.size() - 1; i >= 0; i --)
    {
        auto t = tofind[i];
        int a = t.x, b = t.y;
        if (a < 1 || a > n || b < 1 || b > m) continue;
        if (st[a][b]) continue;
        st[a][b] = 1;
        method.push_back({a, b});
        dfs(cnt + g[a][b], num + 1);
        method.pop_back();
        st[a][b] = 0;

    }
    return ;
}

int main()
{
    cin >> m >> n;
    sum_g = n * m;
    for (int i = 1; i <= n; i ++)
        for (int j = 1; j <= m; j ++)
            cin >> g[i][j], sum += g[i][j];
    
    if (sum & 1) puts("0");
    else {
        st[1][1] = 1;
        method.push_back({1,1});
        dfs(g[1][1], 1);
        printf("%d\n", ans == inf ? 0 : ans);
    }
    return 0;
}
```