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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《Pthread》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 高性能第二次实验：Pthread</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">郑芳 </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">姓　　名</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 朱焰星</td>     </tr>
        <tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">班　　级</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 计科1901</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">学　　号</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2019317220115 </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">日　　期</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-14</td>     </tr>
    </tbody>              
    </table>
</div>

<!-- 注释语句：导出PDF时会在这里分页 -->

## Pthread

### Pthread简介

Pthread是POSIX thread线程的建成，是线程的POSIX标准。该标准定义了创建和操纵线程的一整套API。在类Unix操作系统（Unix、Linux、Mac OS X等）中，都使用Pthreads作为操作系统的线程。Windows操作系统也有其移植版pthreads-win32。

### API

1. 线程管理（Thread management）: 第一类函数直接用于线程：创建（creating），分离（detaching），连接（joining）等等。包含了用于设置和查询线程属性（可连接，调度属性等）的函数。

2. 互斥量（Mutexes）: 第二类函数是用于线程同步的，称为互斥量（mutexes），是"mutual exclusion"的缩写。

3. Mutex函数提供了创建，销毁，锁定和解锁互斥量的功能。同时还包括了一些用于设定或修改互斥量属性的函数。

4. 条件变量（Condition variables）：第三类函数处理共享一个互斥量的线程间的通信，基于程序员指定的条件。这类函数包括指定的条件变量的创建，销毁，等待和受信（signal）。设置查询条件变量属性的函数也包含其中。

5. 命名约定：线程库中的所有标识符都以pthread开头

### 基本函数

#### pthread_create()

定义如下：

```c++
#include <pthread.h>
 int pthread_create(pthread_t * thread, pthread_attr_t * attr, 
 void * (*start_routine)(void *), void * arg);
```

thread是新线程的标识符，pthread*函数通过它来引用新线程。pthread_t是一个整形类型.
attr参数用于设置新线程的属性，给他传递NULL表示使用默认的线程属性。
start_routine和arg参数分别指定新线程将运行的函数及其参数。
pthread_create()成功时返回0；失败时返回错误码。

#### pthread_exit()

线程一旦被创建好，内核就可以调度内核线程来执行start_routine函数指针所指向的函数了，函数结束的时候调用pthread_exit(),以确保安全的退出。

```c++
 #include <pthread.h>
 void pthread_exit(void *retval);
```

pthread_exit()函数通过retval参数向线程回收者传递其退出信息。
它执行完不会返回到调用者，而且永远不会失败。

#### pthread_join()

一个进程中的所有线程都可以调用pthread_join()函数来回收其他的线程，即就是等待其他的线程结束，这类似于回收进程的wait()系统调用。pthread_join()定义如下：

```c++
#include <pthread.h>
int pthread_join(pthread_t thread, void **thread_return);  
```

thread参数是目标线程的标识符,thread_return是目标线程返回的退出信息。
这个函数会一直被阻塞着，一直到被回收的线程结束为止。
成功时返回0，失败时返回错误码。
可能的错误码如下：

错误码	描述
EDEADLK	可能引起死锁，比如两个线程互相针对对方调用pthread_join(),或者对自身调用pthread_join()
EINVAL	目标线程是不可回收的，或者已经有线程在回收该目标线程
ESRCH	目标线程不存在

## 实验内容

1. 使用Pthread编写矩阵向量乘法
2. 利用忙等待、互斥量及条件变量来编写求∏值的Pthreads程序。
3. 用信号量编写发送消息的Pthreads程序



## 实验结果

### 矩阵向量乘

#### 实验截图

![image-20220614202536847](https://s1.vika.cn/space/2022/06/14/e7d8cc39f33d47a8b45ad707fa6b5aeb)

#### 结果分析

表格如下（异常数据已经用黄色标注）：

| **编号** | **进程数** | **数据规模** | **串行执行时间** | **执行时间(微秒)** | **加速比** | **效率** |
| -------- | ---------- | ------------ | ---------------- | ------------------ | ---------- | -------- |
| 1        | 1          | 4800         | 84286            | 84286              | 1.0000     | 1.0000   |
| 2        | 2          | 4800         | 84286            | 90808              | 1.0774     | 0.5387   |
| 3        | 4          | 4800         | 84286            | 84286              | 1.0000     | 0.2500   |
| 4        | 16         | 4800         | 84286            | 83037              | 0.9852     | 0.0616   |
| 5        | 24         | 4800         | 84286            | 61214              | 0.7263     | 0.0303   |
| 6        | 32         | 4800         | 84286            | 50275              | 0.5965     | 0.0186   |
| 7        | 1          | 2000         |                  | 14041              |            |          |
| 8        | 1          | 4000         |                  | 63257              |            |          |
| 9        | 1          | 8000         |                  | 257268             |            |          |
| 10       | 1          | 16000        |                  | ==314==            |            |          |
| 11       | 1          | 3200         |                  | 41891              |            |          |
| 12       | 16         | 3200         |                  | 20900              |            |          |
| 13       | 16         | 6400         |                  | 35948              |            |          |
| 14       | 16         | 12800        |                  | ==717==            |            |          |
| 15       | 16         | 16000        |                  | ==775==            |            |          |

首先观察1-6号实验（数据规模4800）：

1. 随着进程数的增加，执行时间逐渐降低，证明并行能够减少程序的运行时间
2. 加速比在进程数为2时达到最大
3. 效率随着进程的增多而不断下降。
4. 虽然进程能够减少程序执行时间，但是创建和销毁进程的时间开销仍然会很大，所以在实际应用中要做出取舍。

![image-20220614203633779](https://s1.vika.cn/space/2022/06/14/7174c3e7e4e74515b133cfa6b30f5192)

接下来观察7-15号实验：

1. 发现在数据规模大于12800时，运行时间出现了异常。
2. 忽略异常后，发现随着数据规模的增大，线程数不变的情况下，执行时间也会随之增大

![image-20220614204236944](https://s1.vika.cn/space/2022/06/14/a6b6016623324b7795bfc30e9394c0e2)

### 求$\pi$

#### 实验结果

![image-20220614204456195](https://s1.vika.cn/space/2022/06/14/2166669e816449139882f109375980e4)

#### 结果分析

数据规模为 $n = 10^8$

三种方法的对比如下：

| **线程数目** | **忙等待** | **互斥量** | **条件变量** |
| ------------ | ---------- | ---------- | ------------ |
| **1**        | 70         | 59         | 76           |
| **2**        | 63         | 76         | 65           |
| **4**        | 71         | 58         | 65           |
| **8**        | 63         | 62         | 64           |
| **16**       | 63         | 69         | 67           |
| **32**       | 58         | 63         | 61           |
| **64**       | 64         | 80         | 63           |

可视化结果如下：

![image-20220614204439535](https://s1.vika.cn/space/2022/06/14/6cdb22257f334cf49ee718d0191ec447)

可以分析得到：

1. 数据规模相同的情况下，三种方法的运行时间并无很大差别
2. 随着线程数量增大的时候，会发现执行时间的趋势都会有一段**先上升后下降**的阶段。这就是创建进程时的时间开销，所以在使用多线程加速程序时，需要考虑时间开销是否远远小于加速时间。或者是一些对于执行速度有这严格要求切不计代价的场景。

## 代码分析

### 矩阵向量乘

```c++
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>

#define MAX 10000

int thread_count; // number of threads
int n;            // row
int m;            // column

double A[MAX][MAX]; // matrix input
double x[MAX];      // vector input
double y[MAX];      // result

void * Pth_mat_vect(void *rank);

int main(int argc, char *argv[])
{
    int i, j;
    FILE *fpread;
    FILE *fpwrite;
    long thread;

    printf("input n, m: ");
    scanf("%d%d", &n, &m);
    printf("input thread_cnt: ");
    scanf("%d", &thread_count);

    // 构造矩阵
    for (i = 0; i < n; i++)
    {
        for (j = 0; j < m; j++)
        {
            A[i][j] = i ;
        }
    }

    // 构造向量
    for (i = 0; i < m; i++)
    {
        x[i] = i;
    }

    struct timeval start;
    struct timeval end;
    // start = clock();
    gettimeofday(&start, NULL); 
    // ================= 计算开始 ==========================
    pthread_t *thread_handles;

    thread_handles = malloc(thread_count * sizeof(pthread_t));

    for (thread = 0; thread < thread_count; thread++)
    {
        pthread_create(&thread_handles[thread], NULL, Pth_mat_vect, (void *)thread);
    }

    for (thread = 0; thread < thread_count; thread++)
    {
        pthread_join(thread_handles[thread], NULL);
    }

    free(thread_handles);
    // ==================== 计算结束 =======================
    // end = clock();
    gettimeofday(&end, NULL); 

    // double time_use = (double)(end - start) / CLOCKS_PER_SEC;
    double time_use = (end.tv_sec - start.tv_sec) * 1000000 + (end.tv_usec - start.tv_usec);


    printf("time_use: %.2lf us\n", (double)time_use);
    return 0;
}

void *Pth_mat_vect(void *rank)
{
    long my_rank = (long)rank;
    int i, j;
    // consider that m cannnot be divided by thread_count exactly
    int local_m = (m % thread_count != 0) ? ((int)(m / thread_count) + 1) : (m / thread_count);
    int my_first_row = my_rank * local_m;
    // the last thread 最后一个线程
    int my_last_row = ((my_rank + 1) * local_m - 1) > m - 1 ? (m - 1) : ((my_rank + 1) * local_m - 1);

    for (i = my_first_row; i <= my_last_row; i++)
    {
        y[i] = 0.0;
        for (j = 0; j < n; j++)
        {
            y[i] += A[i][j] * x[j];
        }
    }

    return NULL;
}
```



### 求$\pi$值

#### 忙等待

```c++
/*
忙等待
*/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>
int thread_count; // thread's num
int n = 100000000;  // 10^8
double sum = 0.0;
int flag = 0;

void *Thread_sum(void *rank);


int main(int argc, char *argv[])
{
    struct timeval start;
    struct timeval end; // Use long in case of 64-bit system
    long thread;
    pthread_t *thread_handles = NULL;
    
    gettimeofday(&start, NULL); // Get number of threads from command line
    
    thread_count = strtol(argv[1], NULL, 10);   // 获取命令行的输入线程个数
    thread_handles = (pthread_t *)malloc(thread_count * sizeof(pthread_t));     // 为线程申请空间
    
    for (thread = 0; thread < thread_count; thread++)
    { // 创建线程
        pthread_create(&thread_handles[thread], NULL, Thread_sum, (void *)thread);
    }
    
    printf("Hello from the main thread\n");
    
    for (thread = 0; thread < thread_count; thread++)
    { // Wait util thread_handles[thread] complete
        pthread_join(thread_handles[thread], NULL);
    }
    
    gettimeofday(&end, NULL);   // 计时结束

    long long startusec = start.tv_sec * 1000000 + start.tv_usec;
    long long endusec = end.tv_sec * 1000000 + end.tv_usec;
    double elapsed = (double)(endusec - startusec);	
    printf("the result of π took %.2f us\n", elapsed);
    
    free(thread_handles);
    
    printf("sum: %lf\n", 4 * sum);
    return 0;
}
void *Thread_sum(void *rank)
{
    long my_rank = (long)rank;
    double factor, my_sum = 0.0;
    long long i;
    long long my_n = n / thread_count;
    long long my_first_i = my_n * my_rank;
    long long my_last_i = my_first_i + my_n;
    if (my_first_i % 2 == 0)
        factor = 1.0;
    else
        factor = -1.0;
    for (i = my_first_i; i < my_last_i; i++, factor = -factor)
    {
        my_sum += factor / (2 * i + 1);
    } 
    // Use Busy-Waiting to solve critical sections after loop
    // 忙等待
    while (flag != my_rank)
        ;
    sum += my_sum;
    flag = (flag + 1) % thread_count;
    return NULL;
}

```

#### 互斥量

```c++
/*
互斥量
*/

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <sys/time.h>
int thread_count; // thread's num
int n = 100000000;  // 10^8
double sum = 0.0;
int flag = 0;
int count = 0; // Use it to judge whether all of threads arrive barrier
pthread_mutex_t mutex;
pthread_cond_t cond_var;
void *Thread_sum(void *rank);
int main(int argc, char *argv[])
{ // Use long in case of 64-bit system
    long thread;
    pthread_t *thread_handles = NULL;
    struct timeval start;
    struct timeval end;
    gettimeofday(&start, NULL); // Get number of threads from command line
    thread_count = strtol(argv[1], NULL, 10);
    thread_handles = (pthread_t *)malloc(thread_count * sizeof(pthread_t)); // initialize Mutex
    pthread_mutex_init(&mutex, NULL);
    for (thread = 0; thread < thread_count; thread++)
    { // Create threads
        pthread_create(&thread_handles[thread], NULL, Thread_sum, (void *)thread);
    }
    printf("Hello from the main thread\n");
    for (thread = 0; thread < thread_count; thread++)
    {
        // Wait util thread_handles[thread] complete
        pthread_join(thread_handles[thread], NULL);
    }
    gettimeofday(&end, NULL);
    long long startusec = start.tv_sec * 1000000 + start.tv_usec;
    long long endusec = end.tv_sec * 1000000 + end.tv_usec;
    double elapsed = (double)(endusec - startusec);
    printf("the result of π took %.2f us\n", elapsed);
    free(thread_handles);
    pthread_mutex_destroy(&mutex);
    printf("sum: %f\n", 4 * sum);
    return 0;
}
void *Thread_sum(void *rank)
{
    long my_rank = (long)rank;
    double factor, my_sum = 0.0;
    long long i;
    long long my_n = n / thread_count;
    long long my_first_i = my_n * my_rank;
    long long my_last_i = my_first_i + my_n;
    if (my_first_i % 2 == 0)
        factor = 1.0;
    else
        factor = -1.0;
    for (i = my_first_i; i < my_last_i; i++, factor = -factor)
    {
        my_sum += factor / (2 * i + 1);
    }                           // Use Mutexes to solve critical sections after loop
    pthread_mutex_lock(&mutex); // Use condition variables to solve barrier problem
    sum += my_sum;
    count++;
    if (count == thread_count)
    {
        count = 0;
        pthread_cond_broadcast(&cond_var);
        printf("%ld(the last thread) has arrive at barrier\n", my_rank);
    }
    else
    {
        while (pthread_cond_wait(&cond_var, &mutex) != 0)
            ;
        printf("%ld wake up\n", my_rank);
    }
    pthread_mutex_unlock(&mutex);
    return NULL;
}
```

#### 条件变量

```c++
/*
条件变量
*/
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <time.h>
#include <sys/time.h>
int thread_count; // 线程数
int n = 100000000;  // 10^8 数据规模
double sum = 0.0;
int flag = 0;
int count = 0; // 判断是否所有的线程到达了barrier
pthread_mutex_t mutex;
pthread_cond_t cond_var;
void *Thread_sum(void *rank);
int main(int argc, char *argv[])
{
    struct timeval start;
    struct timeval end; 
    long thread;
    pthread_t *thread_handles = NULL; // 创建线程指针
    gettimeofday(&start, NULL);		// 计时开始
    thread_count = strtol(argv[1], NULL, 10);
    thread_handles = (pthread_t *)malloc(thread_count * sizeof(pthread_t)); // initialize Mutex
    pthread_mutex_init(&mutex, NULL);
    for (thread = 0; thread < thread_count; thread++)
    { // Create threads 创建线程
        pthread_create(&thread_handles[thread], NULL, Thread_sum, (void *)thread);
    }
    printf("Hello from the main thread\n");
    for (thread = 0; thread < thread_count; thread++)
    { // Wait util thread_handles[thread] complete 等待完成
        pthread_join(thread_handles[thread], NULL);
    }
    gettimeofday(&end, NULL);
    long long startusec = start.tv_sec * 1000000 + start.tv_usec;
    long long endusec = end.tv_sec * 1000000 + end.tv_usec;
    double elapsed = (double)(endusec - startusec);
    printf("the result of π took %.2f us\n", elapsed);
    free(thread_handles);
    pthread_mutex_destroy(&mutex);
    printf("sum: %f\n", 4 * sum);
    return 0;
} // main
void *Thread_sum(void *rank)
{
    long my_rank = (long)rank;
    double factor, my_sum = 0.0;
    long long i;
    long long my_n = n / thread_count;
    long long my_first_i = my_n * my_rank;
    long long my_last_i = my_first_i + my_n;
    if (my_first_i % 2 == 0)
        factor = 1.0;
    else
        factor = -1.0;
    for (i = my_first_i; i < my_last_i; i++, factor = -factor)
    {
        my_sum += factor / (2 * i + 1);
    }
    pthread_mutex_lock(&mutex);
    sum += my_sum;
    count++;
    if (count == thread_count)
    {
        count = 0;
        pthread_cond_broadcast(&cond_var);
        printf("%ld(the last thread) has arrive at barrier\n", my_rank);
    }
    else
    {
        while (pthread_cond_wait(&cond_var, &mutex) != 0)
            ;
        printf("%ld wake up\n", my_rank);
    }
    pthread_mutex_unlock(&mutex);
    return NULL;
}
```

### 信号量发消息

```c++
/*
信号量发消息
*/
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <semaphore.h>
#include <sys/time.h>
#pragma comment(lib, "pthreadVC2.lib") //必须加上这句
sem_t empty;                           //控制盘子里可放的水果数
sem_t apple;                           //控制苹果数
sem_t orange;                          //控制橙子数
pthread_mutex_t work_mutex;            //声明互斥量work_mutex
void *procf(void *arg)                 // father线程
{
    while (1)
    {
        sem_wait(&empty);                //占用一个盘子空间，可放水果数减1
        pthread_mutex_lock(&work_mutex); //加锁
        printf("apple ++ \n");
        sem_post(&apple);                  //释放一个apple信号了，可吃苹果数加1
        pthread_mutex_unlock(&work_mutex); //解锁
        //sleep(1000);
    }
}
void *procm(void *arg) // mother线程
{
    while (1)
    {
        sem_wait(&empty);
        pthread_mutex_lock(&work_mutex); //加锁
        printf("orange ++\n");
        sem_post(&orange);
        pthread_mutex_unlock(&work_mutex); //解锁
        //sleep(1200);
    }
}
void *procs(void *arg) // son线程
{
    while (1)
    {
        sem_wait(&apple);                //占用一个苹果信号量，可吃苹果数减1
        pthread_mutex_lock(&work_mutex); //加锁
        printf("apple --\n");
        sem_post(&empty);                  //吃了一个苹果，释放一个盘子空间，可放水果数加1
        pthread_mutex_unlock(&work_mutex); //解锁
        //sleep(2000);
    }
}
void *procd(void *arg) // daughter线程
{
    while (1)
    {
        sem_wait(&orange);
        pthread_mutex_lock(&work_mutex); //加锁
        printf("orange --\n");
        sem_post(&empty);
        pthread_mutex_unlock(&work_mutex); //解锁
        //sleep(2300);
    }
}

void main()
{
    pthread_t father; //定义线程
    pthread_t mother;
    pthread_t son;
    pthread_t daughter;

    sem_init(&empty, 0, 10); //信号量初始化
    sem_init(&apple, 0, 0);
    sem_init(&orange, 0, 0);
    pthread_mutex_init(&work_mutex, NULL); //初始化互斥量

    pthread_create(&father, NULL, procf, NULL); //创建线程
    pthread_create(&mother, NULL, procm, NULL);
    pthread_create(&daughter, NULL, procd, NULL);
    pthread_create(&son, NULL, procs, NULL);

    //sleep(1000000000);
}
```

## 实验总结

1. 任务一让我了解了pthread的基本编程实现，认识了一些pthread中 的常用函数；了解了Pthread编程的基本实现流程，能够掌握代码编写Pthread程序。
2. 任务二通过三种不同方法实现了对临界区的资源访问。一步一步由最简单直接的忙等待，在到使用互斥量和条件变量能够不必一直浪费系统资源的方法。

## 思考题

### 什么是程序，什么是进程？什么是线程？阐述进程与线程的区别。

进程：系统中正在运行的一个程序，程序一旦运行就是进程。
线程：进程的一个实体，是进程的一条执行路径。

进程与线程的区别：

1. 进程是拥有资源的最小单位；线程是调度的最小单位。
2. 进程拥有自己独立的地址空间，每启动一个进程，系统会为其配地址空间，建立数据来维护代码段、堆栈段、数据段；线程没有独立的空间地址，它使用相同的地址空间共享数据。
3. CPU切换一个线程比一个进程花费小。
4. 创建一个线程比一个进程开销小。
5. 线程占用的资源比进程少很多。
6. 线程之间通信更方便，同一进程下，线程共享全局变量、静态变量等数据。
7. 多进程程序更加安全、生命力更强，一个进程死掉不会影响另一个进程（它拥有独立地址空间）；多线程程序不易维护，一个线程死掉，整个线程就结束了（共享地址空间）。
8. 进程保护要求高，开销大，效率相对较低；线程效率就比较高，可以频繁切换。

### 什么是并行，什么是并发？多线程系统中如何实现并发？试举例说明并发的应用场景。

并发：在一段时间内以交替形式完成多个任务
并行：齐头并进的方式完成多个任务。

多线程系统中实现并发：
处理器一次只能运行一个线程，如果要实现 同一段时间内运行多个线程（并发），处理器是以时间片分配的技术来实现的，即给每个线程分配时间片，时间片结束，保存该线程状态，线程切换，执行下一个时间片的线程。而如果要实现并行，一个处理器不行，需要在同一时刻，多个处理器各自处理一个线程。

并发应用场景：

1. 在同一时间，多个用户进行操作，但是只有一台处理器。那么就要分配时间片，使得每个用户都觉得自己没有等待时间，或者等待时间是合理的，营造出并行的假象。

### pthread可以通过哪些方式对临界区进行访问，分别采用什么方式实现？

临界区是指一个小代码段，在代码能够执行前，它必须独占对某些资源的访问权。这是让若干代码能够"以原子操作方式"来使用资源的一种方法。

线程：信号量，条件变量
进程：互斥量

 

### 互斥锁、信号量、条件变量三种方式实现的pthread基本函数，并说明它们在线程同步作用中实现的区别

信号量：
```c++
sem_wait(&sem);
...
sem_post(&sem);
```

互斥锁：

```c++
pthread_mutex_lock(&mutex);
```

条件变量

```c++
pthread_mutex_lock(&mutex);
pthread_cond_wait(&cond,&mutex);
pthread_mutex_unlock(&mutex);
```

1. 互斥量定义：互斥量是互斥锁的简称，它是一个特殊类型的变量，通过某些特殊类型的函数，互斥量可以用来限制每次只有一个 线程能进入临界区。 

   互斥量可以保证了一个线程独享临界区，其他线程在有线程以及进入该临界区的情况下，不能同时进入

2. 信号量定义：Pthreads提供另一个控制访问临界区的方法：信号量( semaphore) • 信号量可以认为是一种特殊类型的unsigned int无符号整 型变量，可以赋值为0、1、2、 … 。只给它们赋值0和1，这种只有0和1值的信号量称为二元信号量。 

   粗略地讲，0对应于上了锁的互斥量，1对应于未上锁的互斥量

3. 条件变量定义：条件变量是一个数据对象，允许线程在某个特定条件或者事件发生之前都处于挂起状态。一个条件变量总是与一个互斥量相关联





