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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《蒙特卡洛求PI》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">大作业汇报 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 高性能大作业汇报</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">郑芳 </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">姓　　名</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 朱焰星</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">学　　号</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2019317220115 </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">组　　别</td>
    		<td style="width:%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">邓云辉、张子强、肖书尧、朱焰星</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">日　　期</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-21</td>     </tr>
    </tbody>              
    </table>
</div>


<!-- 注释语句：导出PDF时会在这里分页 -->



## 一、基本原理

蒙特卡洛方法，又称 “随机抽样” 或 “统计试验” 方法，它的原理是通过大量的重复随机试验来对复杂数学系统的仿真。

用蒙特卡洛求Π的方法：在边长为1的正方形中，画一个四分之一的圆，如下图：

![Untitled](https://s1.vika.cn/space/2022/06/24/8ff91548ac034edebff28ecfb260bad5)

然后在正方形内随机生成点，最终用落在四分之一圆内的点（红色点）除以总点数就能近似Π/4，乘以4就可以得到Π。

## 二、基于MPI方法

### 2.1 原理

mpi的并行思路很简单，假设随机点有`total`个，进程数为`count`，那么0号进程计算出每个进程需要的产生的随机点数为`local_total = total/count`，用`MPI_Bcast()`将local_total由0号进程广播给其他进程。随后每个进程产生随机点进行模拟，将落在四分之一圆内的点数量记录下来，为`local_count`。最终用`MPI_Reduce()`将所有进程的`local_count`收集并求和得到有效点数count。最后用`count/total`得到Π/4，乘以4得到Π。

### **2.2 代码**

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <mpi.h>

int main(int argc, char** argv) {
    int world_size, my_rank;
    double startTime,endTime;
    MPI_Init(&argc, &argv);
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

    long long total;//总的随机点数
    long long local_total;//每个进程要生成的随机点数
    long long count;//进程数
    long long local_count = 0;//每个进程落在四分之一圆内的随即点数
    double x, y;//随机点坐标

    srand(time(NULL));  // 随机初始化seed

    if(my_rank == 0) {
        startTime=MPI_Wtime();
        total = 1e6;  // 默认100万个样本
        if(argc >= 2) {
            total = atoi(argv[1]);
        }
        // 在root中计算local_total
        local_total = total / world_size;
    }
    // 把local_total广播给所有进程
    MPI_Bcast(&local_total, 1, MPI_LONG_LONG, 0, MPI_COMM_WORLD);

    for(long long i = 0; i < local_total; i++) {//生成随机点，并记录有效点数
        x = (double)rand() / RAND_MAX;
        y = (double)rand() / RAND_MAX;
        if(x*x + y*y <= 1) {
            local_count++;
        }
    }
    //将所有local_total收集到count并且相加
    MPI_Reduce(&local_count, &count, 1, MPI_LONG_LONG, MPI_SUM, 0, MPI_COMM_WORLD);
    double pi = 4 * (double)count / total;//求Π

    if(my_rank == 0) {//输出结果
        endTime = MPI_Wtime();
        printf("\nProcesses = %d\n", world_size);
        printf("total = %lld\n", world_size * local_total);
        printf("count = %lld\n", count);
        printf("pi    = %f\n", pi);
        printf("time    = %lf\n",endTime-startTime);

    }

    MPI_Finalize();
    return 0;
}
```

### **2.3 结果**

1. **count=1，total = 1e6，1e7，1e8**
   
    ![Untitled](https://s1.vika.cn/space/2022/06/24/2a2937f4854b4f729c4e5f899af62a0c)
    
2. **count=4，total = 1e6，1e7，1e8**
   
    ![Untitled](https://s1.vika.cn/space/2022/06/24/8c171fb515624e94b599cef4129985ad)
    
3. **count=8，total = 1e6，1e7，1e8**
   
    ![Untitled](https://s1.vika.cn/space/2022/06/24/225663b9b5fe42cbb415f1fa23975070)
    
1. **表格**
   
   
    |      |  1e6   |  1e7  | 1e8  |
    | :--: | :----: | :---: | :--: |
    |  1   | 0.024  | 0.24  | 2.4  |
    |  4   | 0.0062 | 0.061 | 0.77 |
    |  8   | 0.0033 | 0.031 | 0.33 |

## 三、基于Pthread方法

### 3.1 代码

```cpp
#include<stdlib.h>
#include<stdio.h>
#include<math.h>
#include<pthread.h>
#include <sys/time.h>
int thread_count;
long long int num_in_circle,n;
pthread_mutex_t mutex;//声明互斥量
void* compute_pi(void* rank);

struct timeval start;
struct timeval end;
double time_use;

int main(int argc,char* argv[]){
    long    thread;
    pthread_t* thread_handles;
    thread_count=strtol(argv[1],NULL,10); //线程数量
    printf("please input the number of point\n");
    scanf("%lld",&n);
    
    gettimeofday(&start,NULL); //计时开始
    
    thread_handles=(pthread_t*)malloc(thread_count*sizeof(pthread_t));
    pthread_mutex_init(&mutex,NULL);//互斥量初始化，使用默认的属性，所以函数的
																		//后一个参数设置为NULL即可。
		/*
		int pthread_mutex_init(
				pthread_mutex_t *mutex, 
				const pthread_mutexattr_t *mutexattr
		)
		其中mutexattr用于指定互斥锁属性（见下），如果为NULL则使用缺省属性。
		* PTHREAD_MUTEX_TIMED_NP，这是缺省值，也就是普通锁。
		* PTHREAD_MUTEX_RECURSIVE_NP，嵌套锁。
		* PTHREAD_MUTEX_ERRORCHECK_NP，检错锁。
		* PTHREAD_MUTEX_ADAPTIVE_NP，适应锁，仅等待解锁后重新竞争。
		*/
    for(thread=0;thread<thread_count;thread++){
				//创建线程
        /*
        int pthread_create(
            pthread_t*    thread_p  //out 
            const    pthread_attr_t*    attr_p
            void*    (*start_routine)(void*)    //in
            void*    arg_p    //in
        )
				第一个参数是一个指针，指向对应的pthread_t对象。注意，pthread_t对象不是
				pthread_create函数分配的.必须在调用pthread_create函数前就为pthread_t
        对象分配内存空间。
				第二个参数不用，所以只是函数调用时把NULL传递参数。
				第三个参数表示该线程将要运行的函数；
				最后一个参数也是一个指针，指向传给函数start_routine的参数
        */
        pthread_create(&thread_handles[thread],NULL,compute_pi,(void*)thread);
    }
		//停止线程
    /*
    int pthread_join(
        pthread_t    thread    /in
        void**    ret_val_p    /out  可以接收任意由pthread_t对象所关联的那个线程产
																		 生的返回值。
    */
    for(thread=0;thread<thread_count;thread++){
        pthread_join(thread_handles[thread],NULL);
    }
    pthread_mutex_destroy(&mutex);//销毁互斥锁
    double pi=4*(double)num_in_circle/(double)n;
    
    gettimeofday(&end,NULL);//计时结束
    
    time_use=(end.tv_sec-start.tv_sec)*1000000+(end.tv_usec-start.tv_usec);
    printf("the esitimate value of pi is %lf\n",pi);
    printf("the time is %lfs\n",time_use/1000);
}
void* compute_pi(void* rank){
    long long int local_n;
    local_n=n/thread_count;
    double x,y,distance_squared;
    for(long long int i=0;i<local_n;i++){
        x=(double)rand()/(double)RAND_MAX;
        y=(double)rand()/(double)RAND_MAX;
        distance_squared=x*x+y*y;
        if(distance_squared<=1){
            pthread_mutex_lock(&mutex); //互斥锁上锁
            num_in_circle++;
            pthread_mutex_unlock(&mutex);  //互斥锁解锁
        }
    }
    return NULL;
}
```

### 3.2 结果

1. 截图
   
    ![Untitled](https://s1.vika.cn/space/2022/06/24/4194e054dabc434e93760f5946360f33)
    
    ![Untitled](https://s1.vika.cn/space/2022/06/24/bb03fa4de05b4256aa85d5d0bcfe155a)
    
    ![Untitled](https://s1.vika.cn/space/2022/06/24/71882a13ae414bc8947abf9c36e6f7ad)
    
2. 表格
   
   
    |      | 10000 | 100000 | 1000000 | 10000000 |
    | :--: | :---: | :----: | :-----: | :------: |
    |  4   | 0.754 | 6.151  | 197.241 | 5302.28  |
    |  8   |  3.9  | 41.495 | 319.961 | 9074.134 |
    |  16  | 2.37  | 24.537 | 622.641 | 6654.097 |
    |  32  | 1.763 | 63.371 | 491.801 | 3603.377 |

## 四、基于OpenMP方法

### 4.1 OpenMP简介

![Untitled](https://s1.vika.cn/space/2022/06/24/4aee5232beba4df6a8176a3520e9aa90)

![Untitled](https://s1.vika.cn/space/2022/06/24/c7ebf8d2a7ae4c5f99e3ca2ea9485a32)

### 4.2 程序实现

```python
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <omp.h>

int main(int argc, char* argv[]) 
{
    long long total = 1e6;  // 默认100万个样本
    int tn = 2;             // 默认2个线程
    if(argc >= 2) {
        total = atoi(argv[1]);  // 从参数中获取样本数
    }
    if(argc >= 3) {
        tn = atoi(argv[2]);     // 从参数中获得线程数
    }

    long long count = 0;//主线程定义的全局变量 
    double x, y;
    #pragma omp parallel num_threads(tn) //创建两个线程，每个都会执行大括号里的代码 
    {
        unsigned seed = time(NULL); //初始化随机数种子 

        #pragma omp for private(x, y) reduction(+:count)
		//归约操作，reduction(op:list)，op表示一个操作，list代表执行op操作的变量列表。
		//每个线程会各自拥有一个私有化的list中的变量，当所有线程计算完成后，对各个线程的私有化list进行op操作。
        for(long long i = 0; i < total; i++) //随机生成点的坐标x和y 
		{
            x = (double)rand_r(&seed) / RAND_MAX;
            y = (double)rand_r(&seed) / RAND_MAX;
            if(x*x + y*y <= 1) {
                count++;
            }
        }
    }
    double pi = 4 * (double)count / total;

    printf(" total = %lld\n", total);
    printf(" count = %lld\n", count);
    printf(" pi    = %f\n", pi);
    printf(" loss  = %e\n", acos(-1) - pi);  
    printf("\nnum_threads = %d\n", tn);

    return 0;
}
```

### 4.3 结果分析

实验过程示例截图

![Untitled](https://s1.vika.cn/space/2022/06/24/4e155e69f42a4056987e0db2045574ad)

![Untitled](https://s1.vika.cn/space/2022/06/24/d0471aa7c7b64981a82e259b619c36c5)

> real: 墙上时间，即程序从开启到结束的实际运行时间。
> user: 执行用户代码所花的实际时间（不包括内核调用），指进程执行所消耗的实际CPU时间。
> sys：该程序在内核调用上花的时间。
>
- 不同数据规模和线程数下进程执行所消的从程序开始到结束的实际运行时间如下：(real的数值）

|      | 100000 | 1000000 | 10000000 | 100000000 |
| :--: | :----: | :-----: | :------: | :-------: |
|  1   | 0.003  |  0.019  |  0.176   |   1.750   |
|  2   | 0.002  |  0.010  |  0.011   |   0.886   |
|  4   | 0.009  |  0.007  |  0.064   |   0.455   |
|  8   | 0.011  |  0.014  |  0.061   |   0.284   |
|  16  | 0.024  |  0.019  |  0.034   |   0.195   |
|  32  | 0.026  |  0.021  |  0.039   |   0.148   |
|  50  | 0.047  |  0.033  |  0.048   |   0.146   |
| 100  | 0.007  |  0.013  |  0.029   |   0.114   |
| 200  | 0.015  |  0.019  |  0.034   |   0.107   |
| 500  | 0.030  |  0.028  |  0.045   |   0.122   |
| 1000 | 0.064  |  0.046  |  0.064   |   0.128   |
- 不同规模、不同线程数下的加速比表格如下：

|      | 100000 | 1000000 | 10000000 | 100000000 |
| :--: | :----: | :-----: | :------: | :-------: |
|  1   |   1    |    1    |    1     |     1     |
|  2   | 1.500  |  1.900  |    16    |   1.975   |
|  4   | 0.333  |  2.714  |   2.75   |   3.846   |
|  8   | 0.272  |  1.357  |   2.88   |   6.162   |
|  16  | 0.125  |  1.000  |  5.176   |   8.974   |
|  32  | 0.115  |  0.905  |  4.513   |  11.824   |
|  50  | 0.034  |  0.576  |  3.667   |  11.986   |
| 100  | 0.428  |  1.462  |  6.069   |  15.351   |
| 200  | 0.200  |  1.000  |  5.176   |  16.355   |
| 500  | 0.100  |  0.678  |  3.911   |  14.344   |
| 1000 | 0.047  |  0.041  |  2.750   |  13.672   |
- 不同规模、不同线程数的执行效率表如下：

|      |  100000  | 1000000 | 10000000 | 100000000 |
| :--: | :------: | :-----: | :------: | :-------: |
|  1   |    1     |    1    |    1     |     1     |
|  2   |   0.75   |  0.95   |    8     |  0.9875   |
|  4   | 0.08325  | 0.6785  |  0.6875  |  0.9615   |
|  8   |  0.034   | 0.1696  |   0.36   |  0.3953   |
|  16  |  0.0078  | 0.0625  |  0.3235  |  0.5609   |
|  32  |  0.003   | 0.0283  |  0.1410  |  0.3526   |
|  50  | 0.00068  | 0.0115  |  0.0733  |  0.2397   |
| 100  |  0.0428  | 0.0146  |  0.0607  |  0.1535   |
| 200  |  0.001   | 0.0050  |  0.0259  |  0.0818   |
| 500  |  0.0002  | 0.0014  |  0.0078  |  0.0287   |
| 1000 | 0.000047 | 0.00004 | 0.02750  |  0.13672  |
- 不同数据规模和线程数下计算误差如下：

|      | 100000 | 1000000 | 10000000 | 100000000 |
| :--: | :----: | :-----: | :------: | :-------: |
|  1   | 0.0007 | 0.0001  |  0.0008  | 0.000046  |
|  2   | 0.0004 | 0.0008  |  0.0005  | 0.000047  |
|  4   | 0.0019 | 0.0008  |  0.0017  |  0.00014  |
|  8   | 0.0018 | 0.0069  |  0.0038  |  0.00053  |
|  16  | 0.0068 | 0.0052  |  0.0014  |  0.00024  |
|  32  | 0.0085 | 0.0066  |  0.0023  |  0.00063  |
|  50  |  0.03  |  0.004  |  0.0026  |  0.00020  |
| 100  |  0.10  |  0.005  |  0.0004  |  0.00085  |
| 200  |  0.12  |  0.042  |  0.0007  |  0.00017  |
| 500  |  0.16  |  0.068  |  0.0013  |  0.00010  |
| 1000 |  0.18  |  0.066  |  0.0037  |  0.00789  |

结合以上表格，可以看出在数据规模较小的情况下，比如在100000的数据规模下，并行计算所开的线程不宜太多，在线程数为2的时候运行时间达到最快，之后线程数越多，运行时间越慢。在数据规模为1000000的时候，在线程数为4的时候也较早地达到了最低谷值。其中比较有意思的是，在之前线程数越多越慢的趋势下，开100个线程明显比开50个线程计算时间要快，此后仍然慢慢上升。我推测使得运算时间较短的线程数可能不止有一个谷值，可能会有多个，在满足不同的适应条件下，会在不同的地方达到较低点。

在数据规模较大的情况下，比如在10000000和100000000的数据规模下，多线程并行计算的优势比较明显，基本上随着线程数的增多，运行时长减短，在线程数达到一定的时候又会反弹。比如10000000数据规模下线程数为100最佳，100000000的数据规模下线程数200最佳。

在运算规模较大的情况下，多线程并行计算必然明显优于串行计算，然而在数据规模较小的时候，甚至还出现了并行计算慢于串行计算的情况。我推测的原因有如下几点：

1. 一种是由于各个线程之间有共享的需要写入的一个变量，并行的时候发生了冲突，需要对共享的变量加锁来解决这个冲突，而访一次锁操作也需要至少一条cas指令，这又增加了额外的开销。在本例子中，count是全局的共享变量，多线程对其进行访问的前后需要上锁和解锁，这造成了一定的时间开销。

2. OpenMP的parallel 区域结束时，线程之间需要同步，即主线程需要等待所有其他线程完成工作之后才能继续，这个过程可以称做barrier。由于barrier的开销，OpenMP多线程就会比单线程还慢。

3. 线程上下文的调度欠妥。在嵌套循环中，内层循环并行。并行线程的创建与销毁会有开销，在嵌套循环的时候如果对内层for并行的话，这个开销会比较大。但我也尝试过将for循环放在并行计算的外侧，在数据规模较小的情况下也并无明显的提升。所以主要原因还是在任务量较小的时候，不需要并行计算，串行计算即可达到最快的时间。

关于误差精度，很明显可以看出，数据规模越大，误差越小，计算的pi值精度越高。这符合概率统计的规律，也符合常识。

## 五、基于CUDA方法

### 5.1 代码实现

每个线程进行一次实验，blocks的数量由实验总数和线程数量确定

#### 1. 核函数`trial`

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

#### 2. 主函数`main`

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

#### 3. 调用核函数

```c++
trial<<<blocks, threads>>>(seed, count_d, x_d, y_d);
```

#### 4. 计算结果

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

#### 5. 计算时间函数

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

#### 6. 与CPU运算进行比较

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

### 5.2 实验结果

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

![image-20220610140455925](https://s1.vika.cn/space/2022/06/10/a08d5c062696467abee1ea20d2691458)

分析：

- 在三种数据规模下，执行时间随线程数量的变化趋势都是==先上升后下降==，表示在线程数量小的时候，并行执行节省的时间不能抵消创建线程以及拷贝数据到GPU上的时间

- 在数据规模大小为$10^8$，线程数量为1024时，执行时间反而变长。

- 最优线程数量设置问题。多线程运行时，线程数量为64或128时达到最佳性能

  由于 多处理器 中并没有太多其他内存，因此每个 thread 的状态都是直接保存在多处理器 的寄存器中。所以，如果一个多处理器同时有愈多的 thread 要执行，就会需要愈多的寄存器空间。

  假设CUDA 装置中每个 多处理器 有 8,192 个寄存器，如果每个 thread 使用到16 个寄存器，那就表示一个 多处理器 同时最多只能维持 512 个 thread 的执行。

  如果同时进行的 thread 数目超过这个数字，那么就会需要把一部份的数据储存在显卡内存中，就会降低执行的效率了。


![image-20220610140441528](https://s1.vika.cn/space/2022/06/10/6e7b752d3a8341b088c4f9f02f2fec49)

多线程并行时间均没有cpu串行执行快，并且与数据规模增长趋势基本呈线性，怀疑是需要拷贝数组而浪费了大量时间。所以对比积分法计算 $\pi$ 
$$
\int^1_0 \dfrac{4}{1+ x^2} dx = \pi
$$


![image-20220610141019488](https://s1.vika.cn/space/2022/06/10/d818768a3df64d568e6690ebf36c0a3a)