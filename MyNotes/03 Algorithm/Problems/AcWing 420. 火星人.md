#算法/序列顺序 

https://www.acwing.com/problem/content/422/

```CPP
#include<bits/stdc++.h>
using namespace std;
const int N = 10010;
int a[N];
int n, m;
int main()
{
    cin >> n >> m;
    for(int i=1; i<=n; i++) {cin >> a[i]; }
    while(m--) {
        int k = n;
        while(a[k-1] > a[k]) k--;
        int t = k;
        while(a[t+1] > a[k-1]) t++;
        swap(a[k-1], a[t]);
        reverse(a+k, a+n+1);
    }
    for(int i=1; i<=n; i++) { cout << a[i] << ' '; }
    return 0;
}
```


  
库函数`next_permutation`
```CPP
#include<bits/stdc++.h>
using namespace std;
const int N = 10010;
int n, m;
int a[N];
int main()
{
    cin >> n >> m;
    for(int i=1; i<=n; i++) { cin >> a[i];}
    
    while(m--) {
        next_permutation(a+1, a+n+1);
    }
    for(int i=1; i<=n; i++) { cout << a[i] << " ";}
    cout << endl;
}
```