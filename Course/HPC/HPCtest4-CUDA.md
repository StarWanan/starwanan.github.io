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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《CUDA编程》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 高性能第四次实验报告</td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-25</td>     </tr>
    </tbody>              
    </table>
</div>



<!-- 注释语句：导出PDF时会在这里分页 -->

## 实验目的

描述本实验的学习目的及你对本实验的学习预期。）

1. 将理论课中学习到的知识与实践结合，加深理解
2. 通过CUDA编程实现任务，了解并掌握基本函数的含义和用法。
3. 采用多种方法优化，认识不同方法实际使用效果的不同。

## 实验环境

（请描述本实验教学活动所使用的实际环境。）

实验环境如下，使用`nvidia-smi`查看GPU型号
<img src="https://s1.vika.cn/space/2022/06/25/9cb279015f0e4f8c88385be637728196" alt="image-20220625160331306" style="zoom:57%;" />

## 实验任务

计算一个32维度向量与1024个32维向量的欧式距离，并对其距离进行排序。

## 实验内容与过程

代码中的计时都只测了用于核函数计算的时间，而不包含数据拷贝的部分。目的是对比核函数的性能。

由于没有计入拷贝等预处理的时间，那些需要计算转置或者预读取的算法在这里会有优势一些。

### global memory

最基础的矩阵向量乘法。

设定线程块都是一维的，每个 CUDA 线程计算矩阵的一行与向量乘积，这样各线程之间没有读写冲突，不需要使用原子操作。

```c++
void __global__ MatVecMulGlobalMemory(const lf *A, const lf *B, lf *C, const size_t nRow, const size_t nCol)
{
	const size_t i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < nRow)
	{
		lf res = 0; //将结果先存在寄存器里，减少对向量C的访存
		for (size_t j = 0; j < nCol; ++j)
			res += A[i * nCol + j] * B[j];
		C[i] = res;
	}
}
```
### 合并访存

合并（coalesced）：数据从全局内存到SM（stream-multiprocessor）的传输，会进行cache，如果cache命中了，下一次的访问的耗时将大大减少。

合并访存：相邻的线程访问段对齐的地址，所有线程访问连续的对齐的内存块。

- 在之前的代码中:

`j == 0`时线程 0 访问A[0]，线程 1 访问A[nCol]，线程 2 访问A[2 * nCol]…
它们并不相邻，因此不满足合并访问的要求。

- 修改后的代码：

在这里我们把原来的矩阵𝐴求出转置$𝐴^𝑇$，此时`j == 0`时线程 0 访问At[0]，线程 1 访问At[1]，线程 2 访问At[2]…
此时满足了合并访问的要求。

```c++
void __global__ MatVecMulGlobalMemoryAlign(const lf *At, const lf *B, lf *C, const size_t nRow, const size_t nCol)
{
	const size_t i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < nRow)
	{
		lf res = 0;
		for (size_t j = 0; j < nCol; ++j)
			res += At[j * nRow + i] * B[j];
		C[i] = res;
	}
}
```


### constant memory 存放向量

#### constant memory 常量内存

Contant Memory用于保存在Kernel执行期间不会发生变化的数据。NVIDIA硬件提供64KB的Constan Memory。在某些情况，用Constant Memory替换Global Memory能有效的减少内存带宽。

constant Memory对于device来说只读但是对于host是可读可写。constant Memory和global Memory一样都位于DRAM，并且有一个独立的on-chip cache，比直接从constant Memory读取要快得多。每个SM上constant Memory cache大小限制为64KB。

constant Memory的获取方式不同于其它的GPU内存，对于constant Memory来说，最佳获取方式是warp中的32个thread获取constant Memory中的同一个地址。如果获取的地址不同的话，只能串行的服务这些获取请求了。

constant Memory使用`__constant__`限定符修饰变量。

#### 核函数

向量在计算过程中不会改变，且每个线程访问相同地址，因此可以把它放在 constant memory 中。

NVIDIA 硬件提供了 64KB 的常量内存，并且常量内存采用了不同于标准全局内存的处理方式。如果向量超过了 constant memory 的 64KB 上限，那就需要分批进行，多次传输和启动内核。

```c++
lf __constant__ d_Bc[(1 << 16) / sizeof(lf)]; //64KB
void __global__ MatVecMulConstantMemory(const lf *At, const lf *B, lf *C, const size_t nRow, const size_t nCol)
{
	const size_t i = blockDim.x * blockIdx.x + threadIdx.x;
	if (i < nRow)
	{
		lf res = 0;
		for (size_t j = 0; j < nCol; ++j)
			res += At[j * nRow + i] * d_Bc[j];
		C[i] = res;
	}
}
```
### shared memory 存放向量和矩阵

共享内存再大作业汇报时，拉屎也指出了可以利用这个方法进行优化。

#### shared memory 共享内存

global memory就是一块很大的on-board memory，并且有很高的latency。hared memory正好相反，是一块很小，低延迟的on-chip memory，比global memory拥有高得多的带宽。可以把他当做可编程的cache，其主要作用有：

- An intra-block thread communication channel 线程间交流通道

- A program-managed cache for global memory data可编程cache

- Scratch pad memory for transforming data to improve global memory access patterns

shared memory（SMEM）是GPU的重要组成之一。物理上，每个SM包含一个当前正在执行的block中所有thread共享的低延迟的内存池。SMEM使得同一个block中的thread能够相互合作，重用on-chip数据，并且能够显著减少kernel需要的global memory带宽。由于APP可以直接显式的操作SMEM的内容，所以又被称为可编程缓存。

由于shared memory和L1要比L2和global memory更接近SM，shared memory的延迟比global memory低20到30倍，带宽大约高10倍。

当一个block开始执行时，GPU会分配其一定数量的shared memory，这个shared memory的地址空间会由block中的所有thread 共享。shared memory是划分给SM中驻留的所有block的，也是GPU的稀缺资源。所以，使用越多的shared memory，能够并行的active就越少。

我们可以动态或者静态的分配shared Memory，其声明即可以在kernel内部也可以作为全局变量。

其标识符为：`__shared__`。

如果在kernel中声明的话，其作用域就是kernel内，否则是对所有kernel有效。如果shared Memory的大小在编译器未知的话，可以使用`extern`关键字修饰

#### 核函数

对于 block 内内存来说，向量都是共享的，因此我们可以使用比 constant memory 更快的 shared memory 来存储，此时相比较使用常量内存，我们免掉了向量比较大的时候多次数据拷贝和启动核函数的开销，也没有使用全局变量，增加了代码的可扩展性。当然，shared memory 更小，因此需要对向量进行分块处理。

另外需要更正的一个问题是，并不需要使用 shared memory 去存矩阵，因为在这个矩阵向量乘的过程中，每个矩阵元素只被访问了一次。此外，shared memory 的大小也并不足以存下完整的矩阵（甚至是向量）。
```c++
void __global__ MatVecMulSharedMemory(const lf *At, const lf *B, lf *C, const size_t nRow, const size_t nCol)
{
	extern lf __shared__ Bs[];
	const size_t i = blockDim.x * blockIdx.x + threadIdx.x;
	lf res = 0;
	for (size_t jBeg = 0, jEnd = blockDim.x < nCol ? blockDim.x : nCol;
		 jBeg < nCol;
		 jBeg += blockDim.x, jEnd += blockDim.x)
	{
		__syncthreads(); //防止有的进程还在读Bs
		if (jBeg + threadIdx.x < nCol)
			Bs[threadIdx.x] = B[jBeg + threadIdx.x];
		__syncthreads();
		if (i < nRow)
			for (size_t j = jBeg; j < jEnd; ++j)
				res += At[j * nRow + i] * Bs[j - jBeg];
	}
	if (i < nRow)
		C[i] = res;
}
```
### 完整代码

## 测试结果

### 距离排序结果

结果输出：
```c++
// 输出最后的结果
for (int i = 0; i < nRow; i++)
{
    printf("c[%d] = %f\n", i, h_C[i]);
    printf("Dev_c[%d] = %f\n", i, h_C_device[i]);
}
```

部分结果如下所示：
<img src="https://s1.vika.cn/space/2022/06/25/184af73732aa4b7ea9669f3c83cdbd38" alt="image-20220625154346311" style="zoom:50%;" />

### 运行时间

对比四种核函数运行的时间：
![image-20220625154601372](https://s1.vika.cn/space/2022/06/25/f250fa41920447d889b7c09219231dba)

1. global memory的运行时间是：**0.042592ms**

2. 合并访存的运行时间是：**0.016224ms**，性能提高了两倍多，充分说明了合并访存增大cache命中率可以大幅度提高程序性能。

3. constant memory的运行时间为：**0.011264ms**，与方法二相比，效果略微提高。使用常量内存可以提升运算性能的原因主要有两个：

   - 对常量内存的单次读操作可以广播到同个半线程束的其他15个线程，这种方式产生的内存流量只是使用全局内存时的$\frac{1}{16}$

   - 硬件将主动把常量数据缓存在 GPU 上。在第一次从常量内存的某个地址上读取后，当其他半线程束请求同一个地址时，那么将命中缓存，这同样减少了额外的内存流量。

4. Shared memory的运行时间为：1.821696ms。与方法三对比有一定的下降。分析原因如下：

   - 使用常量内存时，将原来的数据拷贝到常量内存的时间并没有被算进去，而这里读内存的过程是在核函数内部的。想来如果在更大的矩阵上进行计算，使用 shared memory 应该会有更好的表现。
   - 实验环境下上的显卡性能比较高，内存读写性能比以往的显卡都要强很多，因此对本来已经很快的 global memory 的优化效果没有那么明显了，而对应的核函数却比朴素的算法更复杂，一定程度上增加了运行的时间常数

   

## 实验总结

通过本次实验，接触了并实践了使用GPU编程的方法。不仅仅使用CPU工作，而是与GPU协同。之前只是在深度学习的课程中使用python深度学习框架pytorch接触到了GPU的并行，而本次是通过自己编写程序使用GPU，对设备的架构、工作模式、运行原理都有了更加深刻的理解。

在GPU编程上也会有一些困难之处。比如一些常规的函数在GPU上并不能正常使用，需要通过其他方法或者自带的其他函数实现功能。

