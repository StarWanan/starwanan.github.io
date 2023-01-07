## 代码实现

每个线程进行一次实验，blocks的数量由实验总数和线程数量确定

### 1. 核函数`trial`

进行一次实验。`__global__` 修饰内核函数，表明GPU运行，CPU调用

参数解释：

- `x_d[]`：随机数数组
- `y_d[]`：随机数数组
- `count_d[]`：布尔数组，保存结果

```c++
__global__ void trial(int seed, bool count_d[], double x_d[], double y_d[]) {
    long long id = blockIdx.x * blockDim.x + threadIdx.x;
    double x = x_d[id], y = y_d[id];
    if(x*x + y*y <= 1) {
        count_d[id] = true;
    }
    else {
        count_d[id] = false;
    }
}
```

### 2. 主函数`main`

```c++
dim3 threads(tn);
dim3 blocks((total+tn-1) / tn);
long long real_total = threads.x * blocks.x;

bool* count_h = new bool[real_total];
bool* count_d;
double* x_h = new double[real_total];
double* y_h = new double[real_total];
double* x_d, *y_d;
for(long long i = 0; i < real_total; i++) {
    x_h[i] = (double)rand() / RAND_MAX;
    y_h[i] = (double)rand() / RAND_MAX;
}
cudaMalloc(&count_d, real_total * sizeof(bool));  // 用于保存结果的显存
cudaMalloc(&x_d, real_total * sizeof(double));    // 随机数数组x
cudaMalloc(&y_d, real_total * sizeof(double));    // 随机数数组y
cudaMemcpy(x_d, x_h, real_total * sizeof(double), cudaMemcpyHostToDevice);  // 拷贝随机数数组
cudaMemcpy(y_d, y_h, real_total * sizeof(double), cudaMemcpyHostToDevice);  // 拷贝
```

### 3. 调用核函数

```c++
trial<<<blocks, threads>>>(seed, count_d, x_d, y_d);
```

### 4. 计算结果

将结果拷贝回内存，统计每个线程的结果并计算$\pi$

```c++
cudaMemcpy(count_h, count_d, real_total * sizeof(bool), cudaMemcpyDeviceToHost);

long long count = 0;
for(long long i = 0; i < real_total; i++) {
    if(count_h[i]) {
        count++;
    }
}
double pi = 4 * (double)count / real_total;
```



### 5. 计算时间函数



```c++
//使用event计算时间
cudaEvent_t start,stop;
float tm;
cudaEventCreate(&start); //创建event
cudaEventCreate(&stop);  //创建event
cudaEventRecord(start,0);  //记录当前时间
/*
主要计算过程
*/
cudaEventRecord(stop,0);  //记录当前时间
cudaEventSynchronize(stop);  //等待stop event完成
cudaEventElapsedTime(&tm, start, stop);  //计算时间差（毫秒级）
printf("GPU Elapsed time:%.6f ms.\n",tm); 
```

### 6. 与CPU运算进行比较

```c++
//缺省__host__，表明CPU运行，CPU调用
double fun_for_cpu(long long total, double x_d[], double y_d[])
{
    long long count = 0;
    for (int i = 0; i < total; i++)
    {
        double x = x_d[i], y = y_d[i];
        if (x * x + y * y <= 1)
        {
            count++;
        }
    }
    double pi = 4 * (double)count / total;
    return pi;
}
```

```c++
clock_t clockBegin, clockEnd;
float duration;

clockBegin = clock();
pi = fun_for_cpu(real_total, x_h, y_h);
clockEnd = clock();
duration = (float)1000 * (clockEnd - clockBegin) / CLOCKS_PER_SEC;
printf("CPU Result: %.20lf\n", pi);
printf("CPU Elapsed time: %.6lfms\n", duration);
```

## 实验结果

| **进程**/线程 | **样本数量** | **执行时间** |
| :-----------: | :----------: | :----------: |
|     **1**     |  1,000,000   |    7.051     |
|     **8**     |  1,000,000   |    10.323    |
|    **64**     |  1,000,000   |    9.471     |
|    **128**    |  1,000,000   |    10.083    |
|    **512**    |  1,000,000   |    10.176    |
|   **1,024**   |  1,000,000   |    10.152    |
|     **1**     |  10,000,000  |    72.749    |
|     **8**     |  10,000,000  |    92.830    |
|    **64**     |  10,000,000  |    85.089    |
|    **128**    |  10,000,000  |    86.556    |
|    **512**    |  10,000,000  |    85.439    |
|   **1,024**   |  10,000,000  |    85.474    |
|     **1**     | 100,000,000  |   713.280    |
|     **8**     | 100,000,000  |   790.639    |
|    **64**     | 100,000,000  |   839.277    |
|    **128**    | 100,000,000  |   754.054    |
|    **512**    | 100,000,000  |   761.486    |
|   **1,024**   | 100,000,000  |   843.778    |

!![image-20220610140455925](https://s1.vika.cn/space/2022/06/10/a08d5c062696467abee1ea20d2691458)

分析：

- 在三种数据规模下，执行时间随线程数量的变化趋势都是==先上升后下降==，表示在线程数量小的时候，并行执行节省的时间不能抵消创建线程以及拷贝数据到GPU上的时间

- 在数据规模大小为$10^8$，线程数量为1024时，执行时间反而变长。

- 最优线程数量设置问题。多线程运行时，线程数量为64或128时达到最佳性能

  由于 多处理器 中并没有太多其他内存，因此每个 thread 的状态都是直接保存在多处理器 的寄存器中。所以，如果一个多处理器同时有愈多的 thread 要执行，就会需要愈多的寄存器空间。

  假设CUDA 装置中每个 多处理器 有 8,192 个寄存器，如果每个 thread 使用到16 个寄存器，那就表示一个 多处理器 同时最多只能维持 512 个 thread 的执行。

  如果同时进行的 thread 数目超过这个数字，那么就会需要把一部份的数据储存在显卡内存中，就会降低执行的效率了。

  所

![image-20220610140441528](https://s1.vika.cn/space/2022/06/10/6e7b752d3a8341b088c4f9f02f2fec49)

多线程并行时间均没有cpu串行执行快，并且与数据规模增长趋势基本呈线性，怀疑是需要拷贝数组而浪费了大量时间。所以对比积分法计算$\pi$
$$
\int^1_0 \dfrac{4}{1+ x^2} dx = \pi
$$


![image-20220610141019488](https://s1.vika.cn/space/2022/06/10/d818768a3df64d568e6690ebf36c0a3a)

