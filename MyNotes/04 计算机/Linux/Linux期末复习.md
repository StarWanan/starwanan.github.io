选择 \* 10(文件系统的PPT、Shell的PPT)

大题 \* 8(4问答+4编程)

---

## 问答

### 1. R语言怎么执行python脚本

将R语言的输出重定向到标准输入，然后python解释器从标准输入中读

直接创建子进程，重定向父子的输入输出

借用标准文件，将r语言的输出重定向到标准输入，使python解释器从标准输入中读入，使用类实现重定向输入。

### 2. 为什么需要线程池

传统的服务器有一种监听线程用来监听是否有新的用户连接服务器。每有一个新的用户加入，服务器就开启一个新的线程处理这个用户的数据包，该线程服务于这个用户，当用户与服务器断开连接以后，服务器就销毁这个线程。而频繁地开辟与销毁线程极大占用了系统的资源。大量用户情况下会浪费了大量时间。

而线程池基本思想是在程序开始是就在内存中开辟一些线程，数量固定，独自形成一个类，屏蔽对外操作，服务器只需要将数据包交给线程池就可以。当有新用户请求到达时，不创建新的线程，而是从线程池中选择一个空间的线程为新用户请求服务。服务完成后线程进入空闲线程池。如果没有空闲线程，将数据包暂时累计，等待有空闲线程后再处理。

所以当一个应用需要频繁的创建和销毁线程，而任务的执行时间又非常短时，就可以使用线程池。

### 3. 非阻塞IO原理图

![AC67E98A-918F-4AAC-B74B-EC5D8343832A](https://s1.vika.cn/space/2022/06/26/9e467be3d8c241d5a3464413fce95eeb)

### 4. 为什么引入条件变量

多线程的同步互斥机制是为了在某一时刻只能有一个线程可以实现对共享资源的访问。条件变量工作原理是让当前不需要访问资源的线程进行阻塞等待（睡眠），如果某一时刻就共享资源的状态改变需要某一个线程处理，那么则可以通知该线程进行处理（唤醒）

条件变量看成对互斥锁的补充。互斥锁只有锁定和非锁定两种状态，无法决定线程执行先后。条件变量通过允许线程阻塞和等待另一个线程发送信号的方法弥补了互斥锁的不足。

互斥锁不能解决的问题

```c++
pthread_mutex_t work_mutex;
int i = 3;
int j = 7;

// thread A
pthread_lock()
{
	i ++;
    j --
}
pthread_unlock()
    
// thread_B
pthread_lock()
{
    if(i == j) do_somthing();
}
pthread_unlock()
```

如果只使用互斥锁，可能导致do_something()永远不会执行，这是不期望发生的，如下分析所示：

- 线程A抢占到互斥锁，执行操作，完成后`i == 4`，`j=6`；然后释放互斥锁；

- 线程A和线程B都有可能抢占到锁，如果B抢占到，条件不满足，退出；如果线程A抢占到，则执行操作，完成后i==5，j=5；然后释放互斥锁；
- 同理，线程A和线程B都有可能抢占到锁，如果B抢占到，则条件满足，do_something()得以执行，得到预期结果。但如果此时A没有抢占到，执行操作后i=6，j=4，此后i等于j的情况永远不会发生。



条件变量解决的问题：

```c++
pthread_mutex_t work_mutex;
pthread_cond_t condition;	// 增加条件变量
int i = 3;
int j = 7;

// thread A
pthread_lock()
{
	i ++;
    j --;
    if (i == j)
        释放锁，通知等待条件变量的线程;
}
pthread_unlock()
    
// thread_B
pthread_lock()
{
    if (i != j) 释放锁，使线程等待条件变量;
    if(i == j) do_somthing();
}
pthread_unlock()
```

条件变量基本操作：

| 功能                             | 函数                   |
| -------------------------------- | ---------------------- |
| 初始化条件变量                   | pthread_cond_init      |
| 阻塞等待条件变量                 | pthread_cond_wait      |
| 通知等待该条件变量的第1个线程    | pthread_cond_signal    |
| 在指定的时间之内阻塞等待条件变量 | pthread_cond_timedwait |
| 通知等待该条件变量的所有线程     | pthread_cond_broadcast |
| 销毁条件变量状态                 | pthread_cond_destroy   |



## 编程

### 1. 循环服务器实现文件服务器

处理多个客户端请求同时到来 —— 循环服务器、并发服务器

循环服务器：依次处理每个客户端，直到当前客户端的所有请求处理完毕，再处理下一个客户端。简单，但是容易造成当前客户端以外的其它客户端等待时间过长

实现方式：循环嵌套。外层循环依次接收客户端请求，建立TCP连接。内层接收并处理客户端的所有数据直到客户端关闭连接。当前客户端没有处理结束，其它客户端必须一直等待。所以循环服务器不能在同一时刻相应多个客户端的请求

TCP文件服务器
<img src="https://s1.vika.cn/space/2022/06/27/dcf5981304514f1c9601b09267ab38d4" alt="image-20220627182712421" style="zoom:30%;" />

客户端：
<img src="https://s1.vika.cn/space/2022/06/27/b9b4a5ee7daf48d985d700d6a47cae1a" alt="image-20220627182732287" style="zoom:63%;" />

服务端
<img src="https://s1.vika.cn/space/2022/06/27/682ac59905b84b2f8c2f9abd15907c6d" alt="image-20220627182851700" style="zoom:63%;" />
<img src="https://s1.vika.cn/space/2022/06/27/50a727361b624aba98c1598af888cce8" alt="image-20220627183001831" style="zoom:33%;" />

### 2. UDP聊天室实现流程图

服务器端通过创建子进程完成发送系统消息，通过父进程完成接收客户端信息
![image-20220626220506687](https://s1.vika.cn/space/2022/06/26/17952579707c4cc0b832a00990c19c33)

客户端父进程接收数据，子进程发送数据
![image-20220626220533466](https://s1.vika.cn/space/2022/06/26/ebbacc0ac3634bc5bcc1c843969615cf)

### 3. 管道的实现（以前是生产者&消费者）（完整代码）



```c++
ls | wc
    
if (fork() == 0)	// 子进程
{
	pip(fds[2]);
    if (fork() == 0) {	// 孙进程
		close(1);
        dup(fds[1]);	// 复制fds[1] -> 1
        /*
         * 用close(1)关闭了文件描述符，当调用dup时，
         * 它会找第一个未使用的文件描述符也就是我们刚关闭的标准输出，
         * 这时文件描述符fd与标准输出文件描述符指向同一个文件表;
        */
        close(fds[1]);
        close(fds[0]);
        execlp("ls", "ls", 0);	// ls执行write(1, ...)
    }
    close(0);
    dup(fds[0]);	// 复制fds[0] -> 0
    close(fds[0]);
    close(fds[1]);
    execlp("wc", "wc", 0);	// wc执行read(0, ...)
}
```

思路：子进程实现ls命令将结果返回给父进程，父进程再实现wc命令

dup函数：

- 作用：文件描述符的复制，可以实现文件共享

- 实现：从小到大找第一个未使用的文件描述符， 让他和oldfd指向同一个文件表，操作任何一个都是访问同一个文件

- 返回值：调用成功返回新的文件描述符，失败返回-1

看ls -l|wc -l命令的实现，就只需要调用dup**将子进程的输出与父进程的输入指向同一个文件描述符**即可，这就起到了类似于管道的作用。对于命令的执行，我们需要调用execlp函数，它会从PATH环境变量所指的目录中查找符合参数“ls” 以及“wc”的文件名，找到后便执行该文件。

### 4. 消息通信的编程。消息机制（完整代码）

6-1 msg_snd.c  

```c++
#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <string.h>
#include <errno.h>

#define N 128
#define SIZE sizeof(struct msgbuf) - sizeof(long)
struct msgbuf{
	long mtype;
	int a;
	char b;
	char buf[N];
};
int main(int argc, const char *argv[])
{
	key_t key;
/*创建key值*/
	if((key = ftok(".", 'a')) < 0){
		perror("ftok error");
		return -1;
	}
/*创建或打开消息队列*/
	int msqid;
	struct msgbuf msg;
	if((msqid = msgget(key, IPC_CREAT|IPC_EXCL|0664)) < 0){
		if(errno != EEXIST){
			perror("msgget error");
			return -1;
		}
		else{
			/*如果消息队列已存在，则打开消息队列*/
			msqid = msgget(key, 0664);
		}
	}
/*封装消息到结构体*/
	msg.mtype = 100;
	msg.a = 10;
	msg.b = 'm';
	strcpy(msg.buf, "hello");
/*发送消息*/
	if(msgsnd(msqid, &msg, SIZE, 0) < 0){
		perror("msgsnd error");
		return -1;
	}	
/*调用shell命令产看系统中的消息队列*/
	system("ipcs -q");
	return 0;
}
```

6-2 msg_rcv.c

```c++
#include <stdio.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/msg.h>
#include <string.h>
#include <errno.h>

#define N 128
#define SIZE sizeof(struct msgbuf) - sizeof(long)
struct msgbuf{
	long mtype;
	int a;
	char b;
	char buf[N];
};
int main(int argc, const char *argv[])
{
	key_t key;
/*创建key值*/
	if((key = ftok(".", 'a')) < 0){
		perror("ftok error");
		return -1;
	}
/*创建或打开消息队列*/
	int msqid;
	struct msgbuf msg;
	if((msqid = msgget(key, IPC_CREAT|IPC_EXCL|0664)) < 0){
		if(errno != EEXIST){
			perror("msgget error");
			return -1;
		}
		else{
			/*如果消息队列已存在，则打开消息队列*/
			msqid = msgget(key, 0664);
		}
	}
/*读取消息*/
	if(msgrcv(msqid, &msg, SIZE, 100, 0) < 0){
		perror("msgsnd error");
		return -1;
	}	

	printf("a = %d b = %c buf = %s\n", msg.a, msg.b, msg.buf);
/*删除消息队列*/
	msgctl(msqid, IPC_RMID, NULL);
/*调用shell命令产看系统中的消息队列*/
	system("ipcs -q");
	return 0;
}
```



----

0：标准输入

1：标准输出

2：出错输出



文件类型：普通文件、目录、字符设备、管道



信号发送函数：

```c++
kill(_pid. _sig) 
raise(_sig)
alarm(_seconds)
ualarm(_vvalue, _interval)
```

管道创建函数：

```c++
pipe(_pipedes[2])
mknod mkfio(_path, _mode)
```



两种管道文件：

- pipe
  1. 无文件名
  2. 先进先出，单向
  3. 临时文件，自动删除
  4. 同一家族进程
- fifo
  1. 作为特殊文件存在，有文件名
  2. 任何进程，不限同一家族均可共享
  3. 可长期存在，永久存储，手工删除



link，unlink，链接算法的内容

1. 搜索文件目录树，找到要删除文件的父目录（namei）
2. 如果共享正文文件且链接数为1，则从分区表中清除
3. 修改父目录，清除文件名，i节点置0
4. 连接数 -1
5. 释放 i 节点









---

![linux](https://s1.vika.cn/space/2022/06/26/d6ce7e7bbb7f4357a3aad71c1c1b1fc9)





