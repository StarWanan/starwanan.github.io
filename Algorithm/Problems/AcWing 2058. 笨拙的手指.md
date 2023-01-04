#算法/枚举 #算法/进位转换




---
[原题链接](https://www.acwing.com/problem/content/2060/)


题意：
给定两个数，一个二进制，一个三进制。是由同一个数x转换而来，但是都有一位出错
求x


思路：
枚举哪一位出错，枚举这一位应该是什么，唯一确定一个x


代码：
```CPP
#include <iostream>
#include <cstring>
#include <algorithm>

using namespace std;

string a, b;

int get(string s, int b)
{
    int ans = 0;
    for (int i = 0; i < s.size(); i ++)
        ans = ans * b + s[i] - '0';
    return ans;
}

int main()
{
    cin >> a >> b;
    for (int i = 0; i < a.size(); i ++)
        for (int j = 0; j < b.size(); j ++)
            for (int k = '0'; k <= '2'; k ++)
            {
                string ta = a, tb = b;
                ta[i] ^= 1;
                tb[j] = k;

                int x = get(ta, 2);
                int y = get(tb, 3);
                if (x == y) 
                {
                    cout << x << endl;
                    return 0;
                }

            }
    return 0;
}


作者：星星亮了
链接：https://www.acwing.com/activity/content/code/content/2232667/
来源：AcWing
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。
```
