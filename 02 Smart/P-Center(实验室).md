中心选址与单一成本集合覆盖 P-Center and Unicost Set Covering

中心选址与单一成本集合覆盖：
http://suzhouxing.gitee.io/techive/2020/12/22/Contest-2020pCenter/
提交说明：
http://suzhouxing.gitee.io/techive/2022/05/26/Contest-ReadMe/
题库：
http://suzhouxing.gitee.io/techive/tags/Challenge/
提交状态：
https://gitee.com/suzhouxing/npbenchmark.data/blob/data/Queue.md

提交名称：
Challenge2020PCP-朱焰星-华农-计科

压缩包名称：
朱焰星-华农-计科


```text
error: implicit instantiation of undefined template 'std::basic_ifstream<char>’
ifstream ifs("../instance/pmed1.n100p5.txt");    不允许使用不完整的类型
解决：加头文件`#include <fstream>`
```

相对路径读取不到文件内容 –> 改用绝对路径


### 算法复现

#### 完成贪心构造初始解

Center.cpp


```
#include "PCenter.h"

#include <random>
#include <iostream>


using namespace std;


namespace szx {

class Solver {
    // random number generator.
    mt19937 pseudoRandNumGen;
    void initRand(int seed) { pseudoRandNumGen = mt19937(seed); }
    int fastRand(int lb, int ub) { return (pseudoRandNumGen() % (ub - lb)) + lb; }
    int fastRand(int ub) { return pseudoRandNumGen() % ub; }
    int rand(int lb, int ub) { return uniform_int_distribution<int>(lb, ub - 1)(pseudoRandNumGen); }
    int rand(int ub) { return uniform_int_distribution<int>(0, ub - 1)(pseudoRandNumGen); }

public:
    void solve(Centers& output, PCenter& input, std::function<bool()> isTimeout, int seed) {
        initRand(seed);
        
        solution(output, input, isTimeout, seed);
        for (auto r = input.nodesWithDrops.begin(); !isTimeout() && (r != input.nodesWithDrops.end()); ++r) {
            reduceRadius(input, *r);
            solution(output, input, isTimeout, seed);
        }
        
    }
    
    void solution(Centers& output, PCenter& input,  std::function<bool()> isTimeout, int seed){
        Init(output, input, isTimeout, seed);
        
        vector<int> X0, TL;
        int iter = 1;
        X0.resize(input.centerNum);
        TL.resize(input.nodeNum);
        X0.clear(); TL.clear();
        
        vector<int> weights;
        weights.resize(input.nodeNum);
        weights.clear();
        for (int i = 0; i < input.nodeNum; i ++) {
            weights[i] = 1;
        }
        
        // print some information for debugging.
//        cerr << input.nodeNum << '\t' << input.centerNum << endl;
//        for (NodeId n = 0; !isTimeout() && (n < input.centerNum); ++n) { cerr << n << '\t' << output[n] << endl; }
    }
    
    void TryToOpenCenter(int i, PCenter& input) {
//        for (auto v : input.coverages[i]) {
//
//        }
    }
    
    void FindPair() {
        
    }
    
    void Init(Centers& output, PCenter& input,  std::function<bool()> isTimeout, int seed) {
        // greedy
        vector<NodeId> st, vis;
        st.resize(input.nodeNum);       // 节点是否被覆盖
        vis.resize(input.nodeNum);      // 节点是否被选为中心点
        st.clear(); vis.clear();
        for (int id = 0; id < input.centerNum; id ++) {

            // 遍历所有节点, 寻找能覆盖未覆盖节点最多的点，做为中心点
            int dis = 0, cnt = 0;
            for (int i = 0; i < input.nodeNum; i ++) {
                if (vis[i] == 1) continue;   // 已经被选为中心
                cnt = 0;
                for (auto x : input.coverages[i]) {
                    if (st[x] == 0) cnt ++;
                }
                if (cnt > dis) {
                    dis = cnt;
                    output[id] = i;
                    vis[i] = 1;
                }
            }
            
            // 更新未覆盖节点状态
            st[id] = 1;
            for (auto x : input.coverages[output[id]]) {
                st[x] = 1;
            }
        }
        
        
    }

    void coverAllNodesUnderFixedRadius(Centers& output, PCenter& input, std::function<bool()> isTimeout, int seed) {
        // TODO: implement your own solver which fills the `output` to replace the following trivial solver.
        // sample solver: pick center randomly (the solution can be infeasible).

        //                      +----[ exit before timeout ]
        //                      |
        for (NodeId n = 0; !isTimeout() && (n < input.centerNum); ++n) { output[n] = rand(input.nodeNum); }
        //                                                                             |
        //        [ use the random number generator initialized by the given seed ]----+

        // TODO: the following code in this function is for illustration only and can be deleted.
        // print some information for debugging.
        cerr << input.nodeNum << '\t' << input.centerNum << endl;
        for (NodeId n = 0; !isTimeout() && (n < input.centerNum); ++n) { cerr << n << '\t' << output[n] << endl; }
    }

    void reduceRadius(PCenter& input, Nodes nodesWithDrop) {
        for (auto n = nodesWithDrop.begin(); n != nodesWithDrop.end(); ++n) {
            input.coverages[*n].pop_back();
        }
    }
};

// solver.
void solvePCenter(Centers& output, PCenter& input, std::function<bool()> isTimeout, int seed) {
    Solver().solve(output, input, isTimeout, seed);
}

}
```



#### 开始完成主要算法，邻域搜索，顶点加权等

观察到有很多集合操作，尝试将`vector<int>`标记点更改为`bitset`

```c++
// error: Non-type template argument is not a constant expression
const int N = input.nodeNum;
bitset<M> st;

constexpr 由于input是输入阶段才有的数，所以便一阶段并不能得到具体数值。即使使用constexpr也不行
而bitset的空间是可以接受的，所以索性定义到最大，不根据不同样例大小而动态申请
```



```c++
// error
int id = best_nodelist[rand() % best_nodelist.size()];
rand() 报错，原因是和类中成员函数重名，将自己写的方法注释掉即可
```



一些细节问题：

1. 要注意，由于顶点加权的存在，在判断结果好坏是，不能单纯使用未覆盖节点的额个数。而是应该从贪心后，就持久性维护一个值，也就是目标函数值f_swap.
2. 开放、闭合中心的实际行动时，一定考虑对周围点的影响，更新所有点的delta值
3. 权值更改时，delta仍然需要更改。


1. mac设备
2. 顶点权重更新后，delta和f函数需不需要更新。uncover的最少

不要用debug版本

realise





---

#### 优化

目前进展：仅剩大样例不能算出

目前改进思路：

1. 很多vector的数据结构的改变
2. 禁忌列表



使用pcb3038p010r729的样例：



不使用 `vector<vector<int>>` 后：

```
iter:2561  time:5850.124000  uncovered_num:11
iter:2557  time:5847.597000  uncovered_num:29
iter:2600  time:5908.304000  uncovered_num:10
```

可以看出时间确实增加了。所以使用input中的成员变量，还不如直接使用G，只需要赋值一次不需要多次调用

==但是迭代次数也变多了。为什么迭代次数会变多呢？==



将vector全部换成int数组后：

```
iter:128  time:2477.580000  uncovered_num:26
iter:127  time:2461.193000  uncovered_num:26
iter:126  time:2444.711000  uncovered_num:52
```

迭代次数变少，结果变差，时间变少。



将初始化init换成了构造函数：

```
iter:325  time:9913.852000  uncovered_num:7
iter:333  time:10013.226000  uncovered_num:25
iter:333  time:10010.863000  uncovered_num:25
```

时间大幅度增加，而且诡异的是后面未覆盖节点的个数不变了，定格在了25（重复运行了4次）

增加析构函数：

```
iter:329  time:9965.085000  uncovered_num:12
iter:333  time:10016.029000  uncovered_num:25
iter:332  time:9997.642000  uncovered_num:22
iter:333  time:10010.151000  uncovered_num:25
```

没啥改进


改用vscode：

```
// mac
iter:603  time:240.493000  uncovered_num:0

// windows
// O2
iter:603  time:240.493000  uncovered_num:0
// 无O2
iter:85  time:0.814000  uncovered_num:0
```

疑惑，太疑惑了









