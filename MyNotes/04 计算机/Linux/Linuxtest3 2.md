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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《基于共享内存的读者和写者问题程序设计》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> Linux第三次实验报告</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"></td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-20</td>     </tr>
    </tbody>              
    </table>
</div>



<!-- 注释语句：导出PDF时会在这里分页 -->

# Linux实验报告

## 实验目的 

基于Linux中IPC通信机制的应用开发，掌握有关IPC通信机制函数的使用方法，并掌握读者与消写模式的程序开发。

## 实验内容

（1）先启动读进程，它负责创建共享内存，读共享内存的数据。

（2）后启动写者进程。向共享内存写数据，数据内容的数量自定。

（3）采用信号灯解决涉及的同步与互斥问题


## 实验步骤

### 基础概念

共享内存指 (shared memory)在多处理器的计算机系统中，可以被不同中央处理器（CPU）访问的大容量内存。由于多个CPU需要快速访问存储器，这样就要对存储器进行缓存（Cache）。任何一个缓存的数据被更新后，由于其他处理器也可能要存取，共享内存就需要立即更新，否则不同的处理器可能用到不同的数据。共享内存是 Unix下的多进程之间的通信方法 ,这种方法通常用于一个程序的多进程间通信，实际上多个程序间也可以通过共享内存来传递信息。

**共享内存的特点：**

1. 共享内存是进程间共享数据的一种最快的方法。一个进程向共享的内存区域写入了数据，共享这个内存区域的所有进程就可以立刻看到其中的内容。
2. 使用共享内存要注意的是多个进程之间对一个给定存储区访问的互斥。若一个进程正在向共享内存区写数据，则在它做完这一步操作前，别的进程不应当去读、写这些数据

### 任务分析

假设一个系统中，有读者和写者两组并发进程，共享一个文件，当两个或两个以上的读进程同时访问共享数据时不会产生副作用，但若某个写进程和其他进程（读进程或写进程）同时访问共享数据时则可能导致数据不一致的错误。因此要求：
1、允许多个读者可以同时对文件执行读操作。
2、只允许一个写者往文件中写信息。
3、任一写者在完成写操作之前不允许其他读者或写者工作。
4、写者执行写操作前，应让已有的读者和写者全部退出。
读者功能描述：有一个数据块被多个用户共享，读者部分对数据块是只读的，而且允许多个读者同时读；
写者功能描述： 写者部分对数据块是只写的，当一个写者正在向数据块写信息的时候，不允许其他用户使用，无论是读还是写。

### 设计程序流程 

#### 写者

```flow
st=>start: start
c1=>condition: 信号量=1
c2=>condition: 信号量=0
op1=>operation: 进入reader临界区
op2=>operation: 信号量+1
op3=>operation: 进入读/写临界区
op4=>operation: 退出reader临界区
op5=>operation: 读取信息
op6=>operation: 信号量-1
op7=>operation: 退出读/写临界区
op8=>operation: 退出reader临界区

st->op1->op2->c1(yes,right)->op3->op4
c1(no,bottom)->op4->op5->op6->c2(yes,right)->op7->op8
c2(no,bottom)->op8(left)->op1
```

#### 读者

```flow
st=>start: start
op1=>operation: P(mutex)
op2=>operation: 写数据
op3=>operation: V(mutex)


st->op1->op2->op3->op1
```



### 程序分析

#### 函数分析

与内存共享相关的函数用法

头文件  

```c++
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
```

##### shmget()函数

功能：创建共享内存

函数原型:`int shmget (key_ t key,size t size,int shmflg)`

参数：

- key  长整型（唯一非零），系统建立IPC通信（消息队列、信号量和共字内存）时必须指定一个ID值。通常情况下，该I值通过ftok函数得到，由内核变成标识符，要想让两个进程看到同一个信号集，只需设置kes值不变就可以。

- size  指定共享内存的大小，它的值一般为一页大小的整数倍（未到一页，操作系统向上对齐到一页，但是用户实际能使用只有自己所申请的大小)。

- shmf1g  是一组标志，创建一个新的共享内存，将shmf1g设置了IPCCREAT标志后，共享内存存在就打开。而IPC_CREATIIPC_ExCL则可以创建一个新的，唯一的共享内存如果共享内存已存在，返回一个错误。

返回值：成功返回一个非负整数，即该共享内存段的ID；失败返回-1

##### shmctl()函数

功能：用于控制共享内存

函数原型：`int shmetl (int shm_id, int cmd, struct shmid_ds *buf)`

参数：

- shm_id:由shmget函数返回的共享内存标识。

- cmd：采取的操作，它可以取下面的三个值

  - IPCSTAT：把shmid_ds结构中的数据设置为共享内存的当前关联值
    即用共享内存的当前关联值覆盖shmid_ds的值：
  - IPC_SET：如果进程有足够的权限，就把共享内存的当前关联值设置为
    shmid_ds结构中给出的值
  - IPC_RMID：删除共享内存段

- buf是一个结构指针，它指向共享内存模式和访问权限的结构。shmid_ds
  结构至少包括以下成员

  ```c++
  struct hsmid_ds
  {
   	uid_t shm_perm.uid;
      uid_t shm_perm.gid;
      mode_t shmperm.mode;
  };
  ```

返回值：成功返回0，出错返回-1

##### shmat()函数

功能：将共享内存段连接到进程地址空间。

函数原型：`void *shmat (int shm_id,const void *shm_addr,int shmflg)`

参数：

- shm_id:由shmget函数返回的共享内存标识。
- shmaddr:指定共享内存连接到当前进程中的地址位置，通常为空，表示让系统来选择共享内存的地址
- shmflg:是一組标志位，通常为。

返回值：成功返回只想共享内存存储段的指针，出错返回-1

##### shmdt()函数

功能：将共享内存段与当前进程脱离。该函数不从系统中删除标识符及其数据结构，要显示调用shmctl(带命令IPC_RMID)才能删除它。

函数原型：`int shmdt (const void *shmaddr)`

参数：shmaddr-以前调用shmat时的返回值

返回值：成功0，出错-1

### 程序调试




## 实验总结



## 附录

main.c

```c++
#include"reader_writer.h"

int main(void)
{
    int choose;
    int i;
    counter = 0;
    num_reader = 1;
  	num_writer = 1;
    while((shmid = shmget(KEY, SIZE, IPC_CREAT | 0600))== -1);
	printf("Welcome to the ******  Reader And Writer  ******\n");
    while(1) 
    {        
        printf("\n**********1.Create a reader, and read the memory;\n");
        printf("**********2.Create a writer, and write to the memory;\n");
        printf("**********3.Exit the Reader And Writer!\n");
        printf("Please input your choose:\n");
        scanf("%d", &choose);

        pthread_mutex_init(&mutex, NULL); 
        pthread_mutex_init(&Rmutex, NULL); 	

        switch(choose)
        {
            case 1:
            pthread_create(&threads_r[num_reader++],NULL,reader_thread, NULL); 
            break;
            case 2:
            pthread_create(&threads_w[num_writer++],NULL,writer_thread,NULL); 
            break;
            case 3:
            Quit();
            break;
            default:
            printf("Not find your choose, please input again!\n");
        }       
    }
	return 0; 	
}
```

reader.c

```c++
#include"reader_writer.h"

void *reader_thread(void *arg)
{
    pthread_mutex_lock(&Rmutex);//P(Rmutex);

	if(counter == 0)		//If counter = 0 then P(mutex);
		pthread_mutex_lock(&mutex);
	counter = counter + 1;

	pthread_mutex_unlock(&Rmutex);		//V(Rmutex);

	Read_operation();

	pthread_mutex_lock(&Rmutex);		//P(Rmutex);

	if(counter == 1)		//If counter = 1 then V(mutex);
		pthread_mutex_unlock(&mutex);
	counter = counter + 1;

	pthread_mutex_unlock(&Rmutex);		//V(Rmutex);
}
```

reader-writer.c

```c++
#include"reader_writer.h"
void Read_operation()
{
    shmaddread = shmat(shmid, NULL, 0);		
	printf("This is Reader %d, reading the share memory:%s\n", num_reader - 1, shmaddread);
	shmdt(shmaddread);
}
void Writer_the_data()
{
    char string[100];
    shmaddr = (char*)shmat(shmid, NULL, 0);
	strcpy(string, "Message was writing by Writer");
    string[strlen(string) + 1] = '\0';
    string[strlen(string)] = num_writer - 1 + '0';
    strcpy(shmaddr, string);
    printf("Writer %d has writen to the memory!\n", num_writer - 1);
	shmdt(shmaddr);
}
void Quit()
{
    int i;
    shmctl(shmid, IPC_RMID, NULL);
	pthread_mutex_destroy(&mutex);						
    pthread_mutex_destroy(&Rmutex);
    for(i=0;i<num_reader;i++) 				
        pthread_join(threads_r[i],NULL); 
    for(i=0;i<num_writer;i++) 
        pthread_join(threads_w[i],NULL);
    exit(0);
}
```

reader-writer.h

```c++
#ifndef reader_writer_h
#define reader_writer_h

#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "pthread.h"
#include "signal.h"
#include "unistd.h"
#include "sys/shm.h"
#include "sys/ipc.h"
#include "sys/types.h"
#define SIZE 1024
#define KEY 1234

pthread_mutex_t mutex, Rmutex;
int counter;
int num_reader, num_writer;
pthread_t threads_r[100], threads_w[100];

int pid;
int shmid;
char *shmaddr;
char *shmaddread;
struct shmid_ds buf;

void Read_operation();
void Writer_the_data();

void *reader_thread(void *arg);
void *writer_thread(void *arg);
void Quit();

#endif
```



writer.c

```c++
#include"reader_writer.h"
void *writer_thread(void *arg)
{
	pthread_mutex_lock(&mutex);		//P(mutex);
	Writer_the_data();
	pthread_mutex_unlock(&mutex);	//V(mutex);
}
```









