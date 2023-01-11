完成时间：2022-5-14

---

# 高性能第一次实验 —— MPI

## MPI基础

### 1. 运行MPI程序

1. `mpicc [main.cpp｜程序名] -o [a｜生成的文件名]`
2. `mpirun ./[a｜生成的文件名]`

### 2. MPI程序规范

1. MPI程序从MPI_Init开始：初始化MPI
2. MPI程序以MPI_Finalize结尾：终止MP
3. 所有的常量，变量和函数以MPI_开始编写

## 一、梯形求积分

### 基础部分

==原理==

将 `[a,b]` 区间划分为 n 个**等长**部分，求n个梯形的面积求和就是最后积分面积的近似值。

令函数为 $f(x)$

`[x1, x2]` 之间的梯形面积是：$\dfrac{|x_1 - x_2| * (f(x_1) + f(x_2))}{2}$

每个区间的长度为：$h = \dfrac{b - a}{n}$

所以推倒后的求和公式为：$S = h[\frac{f(x_0)}{2} + f(x_1) + ... + f(x_{n-1}) + \frac{f(x_n)}{2}]$

==功能代码==

```C++
double f(double x)
{
	return x * x;
}
double trap(double local_a, double local_b, int local_n, double h)
{
	double local_area, x;
	local_area = (f(local_a) + f(local_b)) / 2 * h;
	for (int i = 1; i < local_n; i++)
	{
		x = local_a + i * h;
		local_area = local_area + f(x);
	}
	local_area = local_area * h;
	return local_area;
}
```

==实验结果== 

![image-20220511234245591](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220511234245591.png)

### 实验改进

**（一）可读入**

说明：可输入a，b，n；分别代表区间端点以及梯形个数

读入数据的函数需要在初始化 `my_rank` 和 `comm_sz` 后才能调用。

`Get_input函数`：

```c++
void Get_input(
				int my_rank,
				int comm_sz,
				double *a_p,
				double *b_p,
				int *n_p) 
{
	int i;

	if (my_rank == 0) { // 0 号
		printf("input: ");
		scanf("%lf%lf%d", a_p, b_p, n_p);
		for (i = 1; i < comm_sz; i ++) {
			MPI_Send(a_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
			MPI_Send(b_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
			MPI_Send(n_p, 1, MPI_INT        , i, 0, MPI_COMM_WORLD);
		}
	}else {
		MPI_Recv(a_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		MPI_Recv(b_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
		MPI_Recv(n_p, 1, MPI_INT        , 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	}
}
```



修改后进行多次试验发现：虽然成功读入，但结果只和a的改变和n的改变有关。
![image-20220513145744163](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220513145744163.png)

仔细查看代码后发现，原来是开始的数据定义在读入之前就计算好了 h。

最终修改的成功的部分 `main函数` 代码如下：

```C++
int main(int argc, char *argv[])
{
	int comm_sz, my_rank, source;
	// 初始化
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
	
   //  读入数据
	int n;
	double a, b;
	Get_input(my_rank, comm_sz, &a, &b, &n);

	// 开始计算
	double h = (b - a) / n;
	int local_n;
	......(省略)
	MPI_Finalize();
	return 0;
}

```

正确实验结果如下：
![image-20220513150805717](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220513150805717.png)





**（二）`MPI_Reduce` & `MPI_Bcast`**

1. 全局规约函数`MPI_Reduce`： 将所有的发送信息进行同一个操作。

```C++
int MPI_Reduce(
void *input_data, /*指向发送消息的内存块的指针 */
void *output_data, /*指向接收（输出）消息的内存块的指针 */
int count，/*数据量*/
MPI_Datatype datatype,/*数据类型*/
MPI_Op operator,/*规约操作*/
int dest，/*要接收（输出）消息的进程的进程号*/
MPI_Comm comm);/*通信器，指定通信范围*/
```

用起代替循环求面积之和的操作，修改后的代码部分如下：
```c++
// if (my_rank != 0)
// {
// 	MPI_Send(&local_area, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
// }
// else
// {
// 	total_area = local_area;
// 	for (source = 1; source < comm_sz; source++)
// 	{
// 		MPI_Recv(&local_area, 1, MPI_DOUBLE, source, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
// 		total_area += local_area;
// 	}
// }


MPI_Reduce(&local_area, &total_area, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD); // 全剧规约得到面积之和
```



2. 广播函数 `MPI_Bcast`函数：一个序列号为root的进程将一条消息发送到组内的所有进程
   包括它本身在内.调用时组内所有成员都使用同一个comm和root,
   其结果是将根的通信消息缓冲区中的消息拷贝到其他所有进程中去.

```c++
MPI_BCAST(buffer,count,datatype,root,comm) 
    IN/OUT　buffer　　  通信消息缓冲区的起始地址(可变)
    IN　　　 count　  　 通信消息缓冲区中的数据个数(整型) 
    IN 　　　datatype 　通信消息缓冲区中的数据类型(句柄) 
    IN　　　 root　  　　发送广播的根的序列号(整型) 
    IN 　　　comm   　　通信子(句柄) 
int MPI_Bcast(void* buffer,int count,MPI_Datatype datatype,int root, MPI_Comm comm) 
```

将循环发送消息使用该函数代替，改动后的代码结果如下(已增加计时函数)：

```c++
void Get_input(
				int my_rank,
				int comm_sz,
				double *a_p,
				double *b_p,
				int *n_p) 
{
	int i;

	if (my_rank == 0) { // 0 号
		printf("input: ");
		scanf("%lf%lf%d", a_p, b_p, n_p);
		// for (i = 1; i < comm_sz; i ++) {
		// 	MPI_Send(a_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
		// 	MPI_Send(b_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
		// 	MPI_Send(n_p, 1, MPI_INT   , i, 0, MPI_COMM_WORLD);
		// }
	}
	// else {
	// 	MPI_Recv(a_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// 	MPI_Recv(b_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// 	MPI_Recv(n_p, 1, MPI_INT   , 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// }
	MPI_Bcast(a_p, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
 	MPI_Bcast(b_p, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(n_p, 1, MPI_INT, 0, MPI_COMM_WORLD);
}
```



### 源码分析

```c++
#include <stdio.h>
#include "mpi.h"
double f(double x)
{
	return x * x;	// 函数f(x) = x^2
}
double trap(double local_a, double local_b, int local_n, double h)
{
	// 当前部分长度是 local_n，当前部分的两侧端点是 [local_a, local_b]
    // 惊醒梯形求积分的计算
    double local_area, x;
	local_area = (f(local_a) + f(local_b)) / 2 * h;
	for (int i = 1; i < local_n; i++)
	{
		x = local_a + i * h;
		local_area = local_area + f(x);
	}
	local_area = local_area * h;	// 按照推导公式进行面积计算
	return local_area;	// 返回这一部分的面积
}

void Get_input(
				int my_rank,
				int comm_sz,
				double *a_p,
				double *b_p,
				int *n_p) 
{
	int i;

	if (my_rank == 0) { // 0 号
		printf("input: ");
		scanf("%lf%lf%d", a_p, b_p, n_p);
		// for (i = 1; i < comm_sz; i ++) {
		// 	MPI_Send(a_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
		// 	MPI_Send(b_p, 1, MPI_DOUBLE, i, 0, MPI_COMM_WORLD);
		// 	MPI_Send(n_p, 1, MPI_INT   , i, 0, MPI_COMM_WORLD);
		// }
	}
	// else {
	// 	MPI_Recv(a_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// 	MPI_Recv(b_p, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// 	MPI_Recv(n_p, 1, MPI_INT   , 0, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// }
	MPI_Bcast(a_p, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);		// 讲读取到的数据发送给其他进程
 	 MPI_Bcast(b_p, 1, MPI_DOUBLE, 0, MPI_COMM_WORLD);
	MPI_Bcast(n_p, 1, MPI_INT, 0, MPI_COMM_WORLD);
}

int main(int argc, char *argv[])
{
	int comm_sz, my_rank, source;
	double start, end, t, t_sum;

    // 初始化
	MPI_Init(&argc, &argv);
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);

	int n;
	double a, b;
	Get_input(my_rank, comm_sz, &a, &b, &n);	// 读入数据

	MPI_Barrier(MPI_COMM_WORLD);	// 当所有进程都执行完之后，之后才开始计时

	start = MPI_Wtime();	// 计时开始

	double h = (b - a) / n;		// 每个梯形的高
	int local_n;

	double local_a, local_b, local_area, total_area;

	local_n = n / comm_sz;
	local_a = a + my_rank * local_n * h;
	local_b = local_a + local_n * h;
	local_area = trap(local_a, local_b, local_n, h);

	// if (my_rank != 0)
	// {
	// 	MPI_Send(&local_area, 1, MPI_DOUBLE, 0, 0, MPI_COMM_WORLD);
	// }
	// else
	// {
	// 	total_area = local_area;
	// 	for (source = 1; source < comm_sz; source++)
	// 	{
	// 		MPI_Recv(&local_area, 1, MPI_DOUBLE, source, 0, MPI_COMM_WORLD, MPI_STATUS_IGNORE);
	// 		total_area += local_area;
	// 	}
	// }

	
	MPI_Reduce(&local_area, &total_area, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD); // 全局规约得到面积之和
	
	end = MPI_Wtime();	// 计时结束

  	t = end - start;

	MPI_Reduce(&t, &t_sum, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);	// 每个部分面积求和

	if(my_rank==0) {
		printf("With n=%d traplezoids ,our estimate area is %lf from %lf to %lf\n",n,total_area,a,b); // 总面积
		printf("time = %e second\n", t_sum); 	// 总时间 
	}

	MPI_Finalize();
	return 0;
}
```

### 实验结果分析

![image-20220514001136366](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220514001136366.png)

1. 执行时间

   | 进程数 | 数据       | 运行时间（$\times 10^{-5}$s） |
   | ------ | ---------- | ----------------------------- |
   | 1      | 0，3，1024 | 5.126                         |
   | 4      | 0，3，1024 | 4.363                         |
   | 8      | 0，3，1024 | 4.029                         |
   | 16     | 0，3，1024 | 4.292                         |

2. 执行加速比

   加速比（ speedup）：是同一个任务在单处理器系统和并行处理器系统中运行消耗的时间的比率，用来衡量并行系统或程序并行化的性能和效果。

   $S_p=\dfrac{T_1}{T_p}$

   | 进程数 | 串行运行时间 | 运行时间 | 加速比      |
   | ------ | ------------ | -------- | ----------- |
   | 4      | 5.126        | 4.363    | 1.17487967  |
   | 8      | 5.126        | 4.029    | 1.272275999 |
   | 16     | 5.126        | 4.292    | 1.194315005 |

3. 执行效率 $E = \dfrac{S}{p}$

   | 进程数 | 加速比      | 效率        |
   | ------ | ----------- | ----------- |
   | 4      | 1.17487967  | 0.293719917 |
   | 8      | 1.272275999 | 0.1590345   |
   | 16     | 1.194315005 | 0.074644688 |

可见增加进程数时，并行程序可以使得运行时间降低。

但是当进程数增加到16时，相比于进程数为8时，时间反而增加，推测进程之间==通信的时间==带来的损耗已经超过了串行程序部分执行所需要的时间。

而在效率的角度来看，当4进程时，效率是最高的，所以在处理实际问题时还需要考虑效率与性价比的问题，不能单纯追求时间的极致减少。



## 二、矩阵向量乘法

### 代码分析

```c++
#include <stdio.h>
#include <mpi.h>
#include <stdlib.h>

// time_t start,end;//
double start, end;

void Get_data( //获取输入的矩阵维度，并将维度广播到其他进程
    int my_rank,
    int comm_sz,
    int *n_p)
{

    int i, j;
    int n;
    if (my_rank == 0)
    {
        printf("Enter N:\n");
        scanf("%d", n_p);
    }

    MPI_Bcast(n_p, 1, MPI_INT, 0, MPI_COMM_WORLD);
}

int main()
{
    int N;

    int *vec = NULL;        //列向量
    double *mat = NULL;     //自己进程的那部分矩阵
    int my_rank;            //自己进程的进程号
    int comm_sz;            //总的进程数目
    int my_row;             //本进程处理的行数
    int i, j;               //通用游标
    double *result = NULL;  //用来存本进程计算出的结果向量
    double *all_rst = NULL; //只给0号进程存总的结果

    // 初始化
    MPI_Init(NULL, NULL);
    MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
    MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);

    Get_data(my_rank, comm_sz, &N);

    if (my_rank == 0)
    {
        // start=time(NULL);
        start = MPI_Wtime();
    }

    my_row = N / comm_sz; //本进程处理的行数就是总阶数/进程数

    //为每个进程都申请空间
    mat = malloc(N * my_row * sizeof(double)); // my_row行的小矩阵
    vec = malloc(N * sizeof(int));             //每个进程各自读入列向量
    result = malloc(my_row * sizeof(double));  //每个进程各自的结果向量

    double *a = NULL;

    // //赋值(省去读入的步骤,实际做时是读入自己那部分)
    // for(j=0;j<N;j++) {
    //     for(i=0;i<my_row;i++)
    //         mat[i*N+j]=j;
    //     vec[j]=1;
    // }

    if (my_rank == 0)
    {
        //开辟存储空间
        all_rst = malloc(N * sizeof(double));
        a = malloc(N * N * sizeof(double));

        //构建矩阵
        for (j = 0; j < N; j++)
        {
            for (i = 0; i < N; i++)
                a[i * N + j] = j;
            vec[j] = 1;
        }
        MPI_Scatter(a, N * my_row, MPI_DOUBLE, mat, N * my_row, MPI_DOUBLE, 0, MPI_COMM_WORLD); //块划分分发矩阵

        //计算
        for (i = 0; i < my_row; i++)
        {
            result[i] = mat[i * N] * vec[0];
            for (j = 1; j < N; j++)
                result[i] += mat[i * N + j] * vec[j];
        }
        //聚集给0号进程
        MPI_Gather(
            result,        /*发送内容的地址*/
            my_row,        /*发送的长度*/
            MPI_DOUBLE,    /*发送的数据类型*/
            all_rst,       /*接收内容的地址*/
            my_row,        /*接收的长度*/
            MPI_DOUBLE,    /*接收的数据类型*/
            0,             /*接收至哪个进程*/
            MPI_COMM_WORLD /*通信域*/
        );
    }
    else
    {
        MPI_Scatter(a, N * my_row, MPI_DOUBLE, mat, N * my_row, MPI_DOUBLE, 0, MPI_COMM_WORLD);
        // 计算
        for (i = 0; i < my_row; i++)
        {
            result[i] = mat[i * N] * vec[0];
            for (j = 1; j < N; j++)
                result[i] += mat[i * N + j] * vec[j];
        }
        MPI_Gather(
            result,
            my_row,
            MPI_DOUBLE,
            all_rst,
            my_row,
            MPI_DOUBLE,
            0,
            MPI_COMM_WORLD);
    }

    // 0号进程负责输出
    if (my_rank == 0)
    {

        // end=time(NULL);
        end = MPI_Wtime();

        // printf("time=%f\n",difftime(end,start));
        printf("time=%e\n", end - start);
        // printf("The Result is:\n");

        // //改变跨度可以采样获取结果,快速结束I/O
        // for (i = 0; i < N; i += N / 11)
        //     printf("%f\n", all_rst[i]);
    }

    MPI_Finalize();
    /**********************/
    //最终,free应无遗漏
    free(all_rst);
    free(mat);
    free(vec);
    free(result);

    return 0;
}

```



### 试验结果分析

实验结果截图：

单线程（串行）：
![2258B7BD-5E5F-4F3A-836D-575AB2E32626](https://gitee.com/zyxstar/Pic_bed/raw/master/image/2258B7BD-5E5F-4F3A-836D-575AB2E32626.png)

4线程：
![A61993B3-9EFF-4C3F-89E3-A8D0E15963D8](https://gitee.com/zyxstar/Pic_bed/raw/master/image/A61993B3-9EFF-4C3F-89E3-A8D0E15963D8.png)

8线程：
![7DE32B36-ED54-4DBF-8F7E-665C583343E6](https://gitee.com/zyxstar/Pic_bed/raw/master/image/7DE32B36-ED54-4DBF-8F7E-665C583343E6.png)



16线程：
![D079A887-F1FC-4A5F-8A92-A4B99F4B27F4](https://gitee.com/zyxstar/Pic_bed/raw/master/image/D079A887-F1FC-4A5F-8A92-A4B99F4B27F4.png)





1. 执行时间

| 进程数 | 数据  | 运行时间（s） |
| ------ | ----- | ------------- |
| 1      | 1000  | 0.0406        |
| 1      | 2000  | 0.1202        |
| 1      | 4000  | 0.4113        |
| 1      | 8000  | 1.5463        |
| 1      | 16000 | 3.2174        |
| 4      | 1000  | 0.0391        |
| 4      | 2000  | 0.1213        |
| 4      | 4000  | 0.4083        |
| 4      | 8000  | 1.5567        |
| 4      | 16000 | 9.4591        |
| 8      | 1000  | 0.0391        |
| 8      | 2000  | 0.1206        |
| 8      | 4000  | 0.4087        |
| 8      | 8000  | 1.5479        |
| 8      | 16000 | 9.5514        |
| 16     | 1000  | 0.0390        |
| 16     | 2000  | 0.1161        |
| 16     | 4000  | 0.4091        |
| 16     | 8000  | 1.5497        |
| 16     | 16000 | 10.5776       |

2. 执行加速比&效率

   | 进程数 | 数据规模 | 运行时间 | 串行运行时间 | 加速比      | 效率   |
   | ------ | -------- | -------- | ------------ | ----------- | ------ |
   | 1      | 1000     | 0.0406   | 0.0406       | 1           | 1      |
   | 4      | 1000     | 0.0391   | 0.0406       | 1.038363171 | 0.2596 |
   | 8      | 1000     | 0.0391   | 0.0406       | 1.038363171 | 0.1298 |
   | 16     | 1000     | 0.039    | 0.0406       | 1.041025641 | 0.0651 |
   | 1      | 2000     | 0.1202   | 0.1202       | 1           | 1      |
   | 4      | 2000     | 0.1213   | 0.1202       | 0.990931575 | 0.2477 |
   | 8      | 2000     | 0.1206   | 0.1202       | 0.99668325  | 0.1246 |
   | 16     | 2000     | 0.1161   | 0.1202       | 1.035314384 | 0.0647 |
   | 1      | 4000     | 0.4113   | 0.4113       | 1           | 1      |
   | 4      | 4000     | 0.4083   | 0.4113       | 1.007347539 | 0.2518 |
   | 8      | 4000     | 0.4087   | 0.4113       | 1.006361634 | 0.1258 |
   | 16     | 4000     | 0.4091   | 0.4113       | 1.005377658 | 0.0628 |
   | 1      | 8000     | 1.5463   | 1.5463       | 1           | 1      |
   | 4      | 8000     | 1.5567   | 1.5463       | 0.993319201 | 0.2483 |
   | 8      | 8000     | 1.5479   | 1.5463       | 0.998966341 | 0.1249 |
   | 16     | 8000     | 1.5497   | 1.5463       | 0.997806027 | 0.0624 |
   | 1      | 16000    | 3.2174   | 3.2174       | 1           | 1      |
   | 4      | 16000    | 9.4591   | 3.2174       | 0.340138068 | 0.085  |
   | 8      | 16000    | 9.5514   | 3.2174       | 0.336851142 | 0.0421 |
   | 16     | 16000    | 10.5776  | 3.2174       | 0.304171079 | 0.019  |



可以看出增大数据规模时，并没有很好的体现出并行的优势。而在数据规模为1000时并行的速度比穿行要快，在数据规模为2000，4000，8000时差别并不明显，甚至还比串行的速度更慢，而到了16000的规模时，并行速度反而满的很多倍

效率在4核时仍为最高。



## 三、奇偶排序

### 算法原理

传统的排序算法因为串行度很高难以实现并行化，所以需要一种新的方法可以使得排序算法并行。

奇偶交换排序：

- 奇数阶段：按 `(a[0], a[1]), (a[2], a[3]), a[4], ...` 分组比较大小，并交换位置
- 偶数阶段：按 `a[0], (a[1], a[2], （a[3], a[4]), ...` 分组比较大小，并交换位置

> 定理：对于n个元素的序列，作为奇偶交换排序的输入，那么至多经过n个阶段后，该序列一定能排好序

每个阶段的比较和交换操作是可以同时进行的，所以奇偶交换排序适合并行。

所以如果将上述的 `a[0], a[1]` 看成不同进程所拥有的那一部分数据，那么此时需要做的不是简单地交换两个数据，而是将小的数据放在 `a[0]` 部分，大的数据放在 `a[1]` 部分。如果两部分的数据就是有序的，那么可以更高效更简单的完成大小数据的分配。

所以可以在晋城内部使用==快速排序==使得数据有序，再在相邻进程之间使用==归并排序==完成大小数据分配。

### 源码分析

```c++
#include<iostream>
#include<algorithm>
#include<random>
#include<time.h>
#include"mpi.h"
 
// #define N 16		//待排序的整型数量
 
using namespace std;

int N;

void Get_data( //获取输入的矩阵维度，并将维度广播到其他进程
    int my_rank,
    int comm_sz,
    int *n_p)
{

    int i, j;
    int n;
    if (my_rank == 0)
    {
        printf("Enter N:\n");
        scanf("%d", n_p);
    }

    MPI_Bcast(n_p, 1, MPI_INT, 0, MPI_COMM_WORLD);
}
 
/*该函数用来获得某个阶段，某个进程的通信伙伴*/
int Get_Partner(int my_rank, int phase) {
	// 偶通信阶段，偶数为通信双方的较小进程
	if (phase % 2 == 0) {
		if (my_rank % 2 == 0) {
			return my_rank - 1;
		}
		else {
			return my_rank + 1;
		}
	}
	// 奇通信阶段，奇数为通信双方的较小进程
	else {
		if (my_rank % 2 == 0) {
			return my_rank + 1;
		}
		else {
			return my_rank - 1;
		}
	}
}
 
/*这个函数用来产生随机数，并分发至各个进程*/
void Get_Input(int A[], int local_n, int my_rank) {
	int* a = NULL;
	// 主进程动态开辟内存，产生随机数，分发至各个进程
	if (my_rank == 0) {
		a = new int[N];
		srand((int)time(0));
		for (int i = 0; i < N; i++) {
			a[i] = rand() % 1000;
		}
		MPI_Scatter(a, local_n, MPI_INT, A, local_n, MPI_INT, 0, MPI_COMM_WORLD);
		delete[] a;
	}
	// 其余进程接收随机数
	else {
		MPI_Scatter(a, local_n, MPI_INT, A, local_n, MPI_INT, 0, MPI_COMM_WORLD);
	}
}
 
/*该函数用来合并两个进程的数据，并取较小的一半数据*/
void Merge_Low(int A[], int B[], int local_n) {
	int* a = new int[local_n];		// 临时数组，倒腾较小的数据
	int p_a = 0, p_b = 0, i = 0;	//分别为A,B,a三个数组的指针
 
	// 这里不同担心数组越界，因为三个数组的大小是相等的
	while (i < local_n) {
		if (A[p_a] < B[p_b]) {
			a[i++] = A[p_a++];
		}
		else {
			a[i++] = B[p_b++];
		}
	}
	// 倒腾一下
	for (i = 0; i < local_n; i++) {
		A[i] = a[i];
	}
	delete[] a;
}
 
/*该函数用来合并两个进程的数据，并取较大的一半数据，与前面的Merge_Low函数类似*/
void Merge_High(int A[], int B[], int local_n) {
	int p_a = local_n - 1, p_b = local_n - 1, i = local_n - 1;
	int* a = new int[local_n];
	// 注意取最大值需要从后往前面取
	while (i >= 0) {
		if (A[p_a] > B[p_b]) {
			a[i--] = A[p_a--];
		}
		else {
			a[i--] = B[p_b--];
		}
	}
	for (i = 0; i < local_n; i++) {
		A[i] = a[i];
	}
	delete[] a;
}
 
/*这个函数用来输出排序后的数组*/
void Print_Sorted_Vector(int A[], int local_n, int my_rank) {
	int* a = NULL;
	// 0号进程接收各个进程的A的分量，并输出至控制台
	if (my_rank == 0) {
		a = new int[N];
		MPI_Gather(A, local_n, MPI_INT, a, local_n, MPI_INT, 0, MPI_COMM_WORLD);
		for (int i = 0; i < N; i++) {
			cout << a[i] << "\t";
			if (i % 4 == 3) {
				cout << endl;
			}
		}
		cout << endl;
		delete[] a;
	}
	// 其余进程将y分量发送至0号进程
	else {
		MPI_Gather(A, local_n, MPI_INT, a, local_n, MPI_INT, 0, MPI_COMM_WORLD);
	}
}
 
int main() {
    
    int local_n;    // 各个进程中数组的大小
    int* A, * B;	// A为进程中保存的数据，B为进程通信中获得的数据
	int comm_sz, my_rank;
    double start, end, t, t_sum;
	
    MPI_Init(NULL, NULL);
	// 获得进程数和当前进程的编号
	MPI_Comm_size(MPI_COMM_WORLD, &comm_sz);
	MPI_Comm_rank(MPI_COMM_WORLD, &my_rank);
 
    start = MPI_Wtime();    // 开始时间

    Get_data(my_rank, comm_sz, &N);
    
	// 计算每个进程应当获得的数据量，动态开辟空间 
	local_n = N / comm_sz;
	A = new int[local_n];
	B = new int[local_n];
 
	// 随机产生数据并分发至各个进程
	Get_Input(A, local_n, my_rank);
 
	// 先有序化本地数据
	sort(A, A + local_n);
 
	// 定理：如果p个进程运行奇偶排序算法，那么p个阶段后，输入列表有序
	for (int i = 0; i < comm_sz; i++) {
		// 获得本次交换数据的进程号
		int partner = Get_Partner(my_rank, i);
		// 如果本次数据交换的进程号有效
		if (partner != -1 && partner != comm_sz) {
			// 与对方进程交换数据
			MPI_Sendrecv(A, local_n, MPI_INT, partner, 0, B, local_n, MPI_INT, partner, 0, MPI_COMM_WORLD, MPI_STATUSES_IGNORE);
			// 如果本进程号大于目标进程，就应该取值较大的部分
			if (my_rank > partner) {
				Merge_High(A, B, local_n);
			}
			// 否则应该取值较小的部分
			else {
				Merge_Low(A, B, local_n);
			}
		}
	}
 
    end = MPI_Wtime();   // 结束时间
    t = end - start;
    MPI_Reduce(&t, &t_sum, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);
    if (my_rank == 0)
    {
        printf("time=%e second\n", t_sum);
    }
	// 打印排序后的数组
	Print_Sorted_Vector(A, local_n, my_rank);
 
	MPI_Finalize();
	return 0;
}
```

### 实验结果分析

验证算法有效性：
![image-20220514223434327](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220514223434327.png)



在不同情况下比较运行时间：

![50877B04-7FFD-4677-AA74-37798E83EE6E](https://gitee.com/zyxstar/Pic_bed/raw/master/image/50877B04-7FFD-4677-AA74-37798E83EE6E.png)

发现了一组异常数据，就是进程数为4，数据规模为200时运行时间居然是7s多，接下来进行多次测试，证明确实为数据异常：
![A89978C9-9EB6-4B3E-99B2-17733CAFC085](https://gitee.com/zyxstar/Pic_bed/raw/master/image/A89978C9-9EB6-4B3E-99B2-17733CAFC085.png)



之后对每个配置都进行了多次测量，提出异常值之后取平均值作为最后结果

1. 执行时间

   | 进程数 | 数据规模 | 运行时间（s） |
   | ------ | -------- | ------------- |
   | 1      | 200      | 1.607         |
   | 4      | 200      | 1.228         |
   | 8      | 200      | 1.37          |
   | 16     | 200      | 2.326         |
   | 1      | 800      | 1.15          |
   | 4      | 800      | 1.191         |
   | 8      | 800      | 1.682         |
   | 16     | 800      | 1.769         |
   | 1      | 1600     | 1.487         |
   | 4      | 1600     | 1.517         |
   | 8      | 1600     | 1.751         |
   | 16     | 1600     | 1.779         |
   | 1      | 3200     | 1.023         |
   | 4      | 3200     | 1.132         |
   | 8      | 3200     | 0.8327        |
   | 16     | 3200     | 0.9738        |

   

2. 执行加速比 & 效率

   | 进程数 | 数据规模 | 运行时间 | 加速比      | 效率   |
   | ------ | -------- | -------- | ----------- | ------ |
   | 1      | 200      | 1.607    | 1           | 1      |
   | 4      | 200      | 1.228    | 1.308631922 | 0.3272 |
   | 8      | 200      | 1.37     | 1.172992701 | 0.1466 |
   | 16     | 200      | 2.326    | 0.690885641 | 0.0432 |
   | 1      | 800      | 1.15     | 1           | 1      |
   | 4      | 800      | 1.191    | 0.965575147 | 0.2414 |
   | 8      | 800      | 1.682    | 0.683709869 | 0.0855 |
   | 16     | 800      | 1.769    | 0.650084794 | 0.0406 |
   | 1      | 1600     | 1.487    | 1           | 1      |
   | 4      | 1600     | 1.517    | 0.980224127 | 0.2451 |
   | 8      | 1600     | 1.751    | 0.849229012 | 0.1062 |
   | 16     | 1600     | 1.779    | 0.835862844 | 0.0522 |
   | 1      | 3200     | 1.023    | 1           | 1      |
   | 4      | 3200     | 1.132    | 0.903710247 | 0.2259 |
   | 8      | 3200     | 0.8327   | 1.228533686 | 0.1536 |
   | 16     | 3200     | 0.9738   | 1.050523722 | 0.0657 |

在进行第三次实验时，明显发现了和前两个实验不同的地方。每一次运行的==时间差异会很大==。

而且进程数，数据规模与运行时间并无明显关联。



## 实验总结

1. 熟悉了mpi的基础函数功能记忆代码编写规范。
2. 掌握了mpi读入数据的基本操作
3. 深刻理解了进程间互相通信，相互作用的基本原理
4. 掌握了运行变异 mpi 文件的基本指令
5. 对与并行与串行的差异有了更加深刻的了解，并且熟悉掌握了几个评价指标，意识到在实际情况中不会像一开始理所应当想象的结果一样，实验结果很可能出乎意料。

​	
