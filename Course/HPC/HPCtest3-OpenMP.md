<div class="cover" style="page-break-after:always;font-family:方正公文仿宋;width:100%;height:100%;border:none;margin: 0 auto;text-align:center;">
    <div style="width:60%;margin: 0 auto;height:0;padding-bottom:10%;">
        </br>
        <img src="https://s1.vika.cn/space/2022/06/11/f9da4f7f70174c899c960d7644cdaf76" alt="校名" style="width:100%;"/>
    </div>
    </br></br></br></br></br>
    <div style="width:60%;margin: 0 auto;height:0;padding-bottom:40%;">
        <img src="https://s1.vika.cn/space/2022/06/11/03e97917bb634f1b9468b3a4b9e2c5a7" alt="校徽" style="width:80%;"/>
	</div>
		</br></br></br>
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《OpenMP》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 高性能第三次实验：OpenMP</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">姓　　名</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
        <tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">班　　级</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">学　　号</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">日　　期</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-14</td>     </tr>
    </tbody>              
    </table>
</div>

<!-- 注释语句：导出PDF时会在这里分页 -->



## OpenMP

### OpenMP简介

OpenMP（Open Mutil-Processing）：一种应用程序借口（API），可用于显式地指挥多线程、共享内存并行性

有三个主要的API组件：

- 编译器指令
- 运行时库函数
- 环境变量

### OpenMP和MPI的区别

- OpenMP:线程级（并行粒度）；共享存储；隐式（数据分配方式）；可扩展性差；
- MPI：进程级；分布式存储；显式；可扩展性好。

OpenMP采用共享存储，意味着它只适应于SMP,DSM机器，不适合于集群。MPI虽适合于各种机器，但它的编程模型复杂：

- 需要分析及划分应用程序问题，并将问题映射到分布式进程集合；
- 需要解决通信延迟大和负载不平衡两个主要问题；
- 调试MPI程序麻烦；
- MPI程序可靠性差，一个进程出问题，整个程序将错误；

## 实验任务

1. 用OpenMP编写完整的奇偶变换并行排序程序（提示：对100万个数排序，试着与MPI相互比较）

2. 用OpenMP编写完整的矩阵-向量乘法并行程序。

## 实验结果

编译程序的指令是：`gcc -fopenmp [1.cpp] -o [1]`

### 奇偶交换排序

#### 实验结果截图

![image-20220615091800564](https://s1.vika.cn/space/2022/06/15/25b4c75a5c9d4b7c9443279dea98ee83)

![image-20220615091814136](https://s1.vika.cn/space/2022/06/15/dd243a568a8c44ceb6c97b48a6b8252f)

![image-20220615103336709](https://s1.vika.cn/space/2022/06/15/bc9a50498a074ace8bcd10f0fca905b8)

#### 结果分析

##### ITC环境：

| **线程数** | **数据规模** | **执行时间（s）** | **串行时间（s）** | **加速比** |
| ---------- | ------------ | ----------------- | ----------------- | ---------- |
| **1**      | 20000        | 1.861             | 1.861             | 1.000      |
| **2**      | 20000        | 2.394             | 1.861             | 1.286      |
| **4**      | 20000        | 3.078             | 1.861             | 1.654      |
| **16**     | 20000        | 5.318             | 1.861             | 2.858      |
| **24**     | 20000        | 7.280             | 1.861             | 3.912      |
| **32**     | 20000        | 11.408            | 1.861             | 6.130      |
| **16**     | 2000         | 1.691             |                   |            |
| **16**     | 20000        | 5.318             |                   |            |
| **16**     | 200000       | 237.352           |                   |            |
| **16**     | 1000000      | 6305.570          |                   |            |

与MPI的对比：

| **线程数** | **数据规模** | **OpenMP** | **MPI** | **两者相比** |
| ---------- | ------------ | ---------- | ------- | ------------ |
| **1**      | 20000        | 1.861      | 4.01    | 0.464        |
| **2**      | 20000        | 2.394      | 1.479   | 1.619        |
| **4**      | 20000        | 3.078      | 1.68    | 1.832        |
| **16**     | 20000        | 5.318      | 4.388   | 1.212        |
| **24**     | 20000        | 7.280      | 1.682   | 4.328        |
| **32**     | 20000        | 11.408     | 1.512   | 7.545        |
| **16**     | 2000         | 1.691      | 3.658   | 0.462        |
| **16**     | 20000        | 5.318      | 1.914   | 2.778        |
| **16**     | 200000       | 237.352    | 1.998   | 118.795      |
| **16**     | 1000000      | 6305.570   | 3.00    | 2101.857     |

对于前6条数据（数据规模为20000）：

<img src="https://s1.vika.cn/space/2022/06/15/79e8d28a7c3149f0b2b970266b2916f4" alt="image-20220615092915484" style="zoom:50%;" />

1. 实验结果可以看出MPI比OpenMP的效果都要好
2. 而OpenMP并没有展现出并行的好处，线程数增加时，执行时间也会随之增加。

对于后4条数据：
![image-20220615093351008](https://s1.vika.cn/space/2022/06/15/fa38035db8e645d0ab03c5b746e3b075)

1. MPI在数据规模为20000和200000时运行时间差别不大，可以看出MPI并行是有效果的。
2. 但是OpenMP随着数据规模的增大，并没有显示出并行的优势。

两者对比时：

<img src="https://s1.vika.cn/space/2022/06/15/af6cfb17708a4a61b24a54ab592aebcc" alt="image-20220615102559017" style="zoom:50%;" />、

1. 发现在2000的数据规模时，OpenMP的执行速度超过了MPI
2. 随着数据规模的增大，OpenMP的执行时间也极具增大。几乎有了线性关系。而MPI的效果相比之下比较不错

##### macOS

对于OpenMP的异常状况，在另外一个环境下进行试验（macOS）：

| **线程数** | **数据规模** | **执行时间（s）** | **串行时间（s）** | **加速比** |
| ---------- | ------------ | ----------------- | ----------------- | ---------- |
| **1**      | 2000         | 0.834             | 0.834             | 1.000      |
| **2**      | 2000         | 0.471             | 0.834             | 0.565      |
| **3**      | 2000         | 0.301             | 0.834             | 0.361      |
| **4**      | 2000         | 0.234             | 0.834             | 0.281      |
| **5**      | 2000         | 0.198             | 0.834             | 0.237      |
| **6**      | 2000         | 0.136             | 0.834             | 0.163      |
| **10**     | 50000        | 0.92              |                   |            |
| **10**     | 100000       | 3.641             |                   |            |
| **10**     | 150000       | 8.34              |                   |            |
| **10**     | 200000       | 14.749            |                   |            |

由于MPI环境的问题，MPI的程序执行仍然使用ITC第一次实验的MPI代码以及环境，对比效果如下：

| **线程数** | **数据规模** | **OpenMP** | **MPI** | **两者相比** |
| ---------- | ------------ | ---------- | ------- | ------------ |
| **1**      | 2000         | 0.834      | 1.957   |              |
| **2**      | 2000         | 0.471      | 1.225   |              |
| **3**      | 2000         | 0.301      | 1.692   |              |
| **4**      | 2000         | 0.234      | 1.774   |              |
| **5**      | 2000         | 0.198      | 2.137   |              |
| **6**      | 2000         | 0.136      | 1.607   |              |
| **10**     | 50000        | 0.92       | 3.14    |              |
| **10**     | 100000       | 3.641      | 2.769   |              |
| **10**     | 150000       | 8.34       | 1.921   |              |
| **10**     | 200000       | 14.749     | 2.714   |              |

![image-20220615103233421](https://s1.vika.cn/space/2022/06/15/72a96ccef8c14806b0098260ff6a5be7)

左图是数据规模为2000时的六条实验结果；右图是线程数均为10时，数据规模不断增加的实验结果

可以发现：

1. 在数据规模较小时，OpenMP的执行效果比MPI好，并且可以看出程序并行是有效的。
2. 在数据规模接近100000时，MPI的性能仍旧保持稳定，但是OpenMP的执行时间已经开始逐步增加。这表明==OpenMP无力处理大规模数据==

### 矩阵-向量乘

#### 实验结果截图

![image-20220615011838747](https://s1.vika.cn/space/2022/06/15/a3e597c11b6d48778a6608a767577506)

#### 结果分析

| **进程数** | **数据规模** | **串行执行时间（**s） | **执行时间（s）** | **加速比** | **执行效率** |
| ---------- | ------------ | --------------------- | ----------------- | ---------- | ------------ |
| **1**      | 8000000 * 8  | 1.498                 | 1.498             | 1.000      | 1.000        |
| **2**      | 8000000 * 8  | 1.498                 | 1.147             | 0.766      | 0.383        |
| **4**      | 8000000 * 8  | 1.498                 | 1.193             | 0.796      | 0.199        |
| **16**     | 8000000 * 8  | 1.498                 | 1.630             | 1.088      | 0.068        |
| **1**      | 8000 * 8000  | 1.114                 | 1.114             | 1.000      | 1.000        |
| **2**      | 8000 * 8000  | 1.114                 | 0.717             | 0.644      | 0.322        |
| **4**      | 8000 * 8000  | 1.114                 | 0.505             | 0.453      | 0.113        |
| **16**     | 8000 * 8000  | 1.114                 | 0.247             | 0.222      | 0.014        |
| **1**      | 8 * 8000000  | 2.450                 | 2.450             | 1.000      | 1.000        |
| **2**      | 8 * 8000000  | 2.450                 | 1.350             | 0.551      | 0.276        |
| **4**      | 8 * 8000000  | 2.450                 | 0.628             | 0.256      | 0.064        |
| **16**     | 8 * 8000000  | 2.450                 | 0.451             | 0.184      | 0.012        |

![image-20220615011754811](https://s1.vika.cn/space/2022/06/15/7ac1892bbc4b4588860a79f641491d7e)

从以上的实验结果中可以看出来：

1. 数据规模为8000\*8000（绿色）以及8\*8000000（灰色）时，执行时间随着线程数的增加会减少。而数据规模为8000000\*8 （蓝色）时，线程数增加时执行时间反而会上升。
2. 执行效率都会随着线程数的增加而降低，每个线程并不能完全发挥所有的性能

## 代码

### 奇偶排序

```c++
#include <iostream>
#include <omp.h>
#include <fstream>
#include <ctime>
#include <stdio.h>
#include <stdlib.h>

using namespace std;
#pragma warning(disable : 4996)

int main(int argc, char **argv)
{
    if (argc < 2)
        return 0;
    int thread_count = atoi(argv[1]); // 命令行参数确定线程数量
    int *a, n, i, tmp, phase;

    ifstream cin("input.txt"); // 从文件读，标准输入流cin就从文件读取
    cin >> n;                  // 读入数量
    printf("N: %d\n", n);
    a = new int[n];
    for (i = 0; i < n; ++i) // 读入数据
        cin >> a[i];
    clock_t starttime, endtime; // 计时器
    starttime = clock();        // 开始计时
#pragma omp parallel num_threads(thread_count) default(none) shared(a, n) private(i, tmp, phase)
    // 奇偶排序主要过程
    for (phase = 0; phase < n; ++phase)
    {
        if (phase % 2 == 0)
        {
#pragma omp for
            for (i = 1; i < n; i += 2)
            {
                if (a[i - 1] > a[i])
                {
                    swap(a[i], a[i - 1]);
                }
            }
        }
        else
        {
#pragma omp for
            for (i = 1; i < n - 1; i += 2)
            {
                if (a[i] > a[i + 1])
                {
                    swap(a[i], a[i + 1]);
                }
            }
        }
    }
    endtime = clock();          // 计时结束
    ofstream out("output.txt"); // 将排序后的数组放入txt文件中，便于验证结果是否正确
    for (i = 0; i < n; ++i)
        out << a[i] << " ";
    cout << "Total time Serial: " << (double)(endtime - starttime) / CLOCKS_PER_SEC << "s" << endl;
    delete[] a;
}
```

由于当数据量很大的时候，在程序中生成太过麻烦，以及人工验证排序结果是否正确时几乎不可能，所以另外写两个程序，分别负责生成数据generate.py以及验证正确性check.py

1. `generate.py`

   ```python
   import sys
   import numpy as np
   
   N = int(sys.argv[1])
   a = np.random.randint(-100, 100, N)
   c = sorted(a)
   with open("input.txt", 'w') as f:
       f.write(str(N) + '\n')
       f.write(' '.join(list(map(str, a)))+'\n')
   with open("ans.txt", 'w') as f:
       for i in range(N):
           f.write(str(c[i]) + ' ')
   ```

2. `check.py`

   ```python
   with open('ans.txt', 'r')as f, open('output.txt', 'r') as r:
       a = f.readline()
       b = r.readline()
       print('right' if a == b else 'wrong')
   ```



### 矩阵向量乘

由于数组申请的空间不够，所以在外面定义两个const常量。

```c++
#include <stdio.h>
#include <omp.h>
#include <stdlib.h>
#include <time.h>

const int MAXM = 10, MAXN = 8000010;

int NUM_THREADS = 20;
typedef long long ll;
int m = MAXN, n = MAXN;
int mat[MAXM][MAXN];
int vec[MAXN], ans[MAXM];

void makeRandomMatrix()
{
    srand(time(NULL)); // 根据时间作为随机数种子
    int i, j;
    for (i = 0; i < m; i++)
    {
        for (j = 0; j < n; j++)
        {
            mat[i][j] = rand() % 10 + 1; // 为矩阵的每个元素分配一个1-10的值
        }
    }
}

void makeRandomVector()
{
    srand(time(NULL));
    int i;
    for (i = 0; i < n; i++)
    {
        vec[i] = rand() % 10 + 1; // 为向量分配 1-10 的值
    }
}

void funy(int a[], int cur) // 计算答案的第 cur 个
{
    int i;
    for (i = 0; i < n; i++)
    {
        ans[cur] += a[i] * vec[i];
    }
}

void fun()
{
    int i;
#pragma omp parallel
    {
        int id = omp_get_thread_num();
#pragma omp parallel for
        for (i = id; i < m; i += NUM_THREADS) // 并行计算答案
        {
            funy(mat[i], i);
        }
    }
}

int main(int argc, char *argv[])
{
    if (argc != 2)
    {
        printf("Usage: [./1] [thread_cnt]\n");
        exit(0);
    }
    NUM_THREADS = atoi(argv[1]); // 从命令行读取线程数量

    m = MAXM, n = MAXN; // 矩阵大小
    printf("Matrix_size: [%d * %d] & vector[%d * 1]\n", m, n, m);

    makeRandomMatrix(); //初始化矩阵
    makeRandomVector(); // 初始化向量

    double start_time = omp_get_wtime(); // 开始计时
    fun();                               // 主要过程
    double end_time = omp_get_wtime();   // 结束计时
    // for (int i = 0; i < m; i ++) printf("%d%c\n", ans[i], ' \n'[i==n-1]);
    printf("thread_cnt: %d, time: %f s\n", NUM_THREADS, end_time - start_time);
    return 0;
}
```



## 实验总结

### 感悟

本次实验不仅仅了解了OpenMP的基本原理、编程实现以及实验效果，也加深了对MPI的了解。

OpenMP对应的是单进程多线程的并发编程模型，可以将一个单线程的程序按for循环拆分成多线程——相当于pthread_create。对于同一个进程的多个线程来说，由于它们只是独占自己的栈内存，堆内存是共享的，因此数据交换十分地容易，直接通过共享变量就可以进行交换，编程模型非常简单易用，并且对于操作系统来说，线程的上下文切换成本也比进程低很多。但是，由于线程不能脱离进程独立存在，而一个进程不能存在于多台机器上，所以OpenMP只适用于拥有多个CPU核心的单台电脑。也就是说OpenMP是单点的。

多线程编程存在临界区（Critical Section），需要程序员去加锁，解决Race Condition问题，否则容易导致不可预知的后果。而且注释也是人手动添加的，如果逻辑不对，程序仍然能够正常运行，但是运行结果会相差很远。

而MPI虽然在开头的介绍中，看起来没有OpenMP这么简单易用，但是也有自己的优点。MPI是多进程的并发编程模型，每个节点数据并不共享，只能依靠通信，导致变成难度很大。但是，进程可以在分布式系统的每一台电脑之间转移，因此对于分布式系统来说，其并发性要明显好于OpenMP。

### 改进

下一步的改进空间，我认为是OpenMP与MPI相结合。这两种方法针对不同的内存模式，但是并非不可共存。MPI可以让多个节点互相通信，而OpenMP可以在单节点上并行。





























