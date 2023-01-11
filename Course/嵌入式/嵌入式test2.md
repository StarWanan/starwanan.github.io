

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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《Pthread和串行程序设计》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 第二次实验</td>     </tr>
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

## 实验目的

1. 了解多线程程序设计的基本原理。 

2. 学习 pthread 库函数的使用。

3. 了解在 linux 环境下串行程序设计的基本方法。

4. 掌握终端的主要属性及设置方法，熟悉终端 IO 函数的使用。

5. 学习使用多线程来完成串口的收发处理。

## 实验要求

1. C 语言编程基础。 
2. 掌握在 Linux 下常用编辑器gedit,vi的使用。 
3. 掌握 Makefile 的编写和使用。 
4. 掌握 Linux 下的程序编译与交叉编译过程 
5. 掌握minicom使用
6. 熟悉Tiny4412开发环境

## 实验任务

ARM2410-linux实验指导书.pdf
实验2.2：多线程应用程序设计，P21，读懂实验源代码，编译并下载至开发板观察结果
实验2.3：串行端口程序设计，P30, 读懂实验源代码，编译并下载至开发板观察结果
加分项：实验2.2思考题，实验2.3思考题

实验报告中把2实验2.2，2.3的源代码放进去，并对主要过程添加注释说明！

## 实验内容

### 实验一 多线程应用程序设计

读懂pthread.c 的源代码，熟悉几个重要的 PTHREAD 库函数的使用。掌握共享锁和信号 量的使用方法。
进入/arm2410/exp/basic/02_pthread 目录，运行 make 产生 pthread 程序，使用 NFS 方式连接开发主机进行运行实验
在基础实验要求上，实现思考题1，加入新的线程用于处理键盘的输入，并在按键为ESC时终止所有线程。

### 实验二 串行端口程序设计

读懂程序源代码， 学习终端IO函数tcgetattr(), tcsetattr(),tcflush()的使用方法， 学习将多线程编程应用到串口的接收和发送程序设计中。

### 实验环境

硬件：嵌入式实验仪，PC机 pentumn500 以上, 硬盘 40G 以上,内存大于 128M。

软件：PC机操作系统 REDHAT LINUX 9.0 ＋MINICOM ＋ AMRLINUX 开发环境

## 实验步骤

配置交叉编译环境，使用`arm-linux-gcc –v `进行验证

### 多线程应用程序设计

1. 交叉编译代码：`arm-linux-gcc pthread.c -o pthread –lpthread`

2. 将目标文件传输到开发板

   <img src="https://s1.vika.cn/space/2022/06/24/5af38ff15577497db77c87d3b8afc6ed" alt="7A1325A4C5CC99B640B0FBDBE5554234" style="zoom:50%;" />

3. 运行：两个线程每隔一秒进行计数。达到预先设定的计数值时，进程结束。

   ![image-20220624200457587](https://s1.vika.cn/space/2022/06/24/ebba25d281274698a0a3b945c7158362)

### 串行端口程序设计

几个linux中设置串口的系统调用函数：

```c++
int tcsetattr(int fd, int optional_actions, const struct termios *termios_p);//设置串口属性
int tcgetattr(int fd, struct termios *termios_p);//获得串口属性
int tcflush(int fd, int queue_selector);//刷新串口的缓冲区
```

1. 交叉编译代码：`arm-linux-gcc term.c -o pthread –lpthread`

2. 将目标文件传输到开发板

3. 运行

   ![image-20220624200518410](https://s1.vika.cn/space/2022/06/24/aa12a6a3e37145beb87851d0b8da468d)

   发现运行结果和实际不符合



## 思考题

### 多线程应用程序设计

**要求**

1. 加入一个新的线程用于处理键盘的输入，并在按键为ESC时终止所有线程。 

2. 线程的优先级的控制。

**实现**

首先写一个函数用于读取键盘的输入，接着创建一个新的线程用于读入键盘输入，实现两个功能：

1. 预先设定一个数值，每读如一次键盘，计数值就+1，如果计数值达到设定值，线程退出
2. 如果读如到`Esc`，则将其他的两个线程退出，然后再退出自己的线程。这使得读如键盘的优先级高于其它两个线程。

读如键盘的函数如下：

```c++
int scanKeyboard()
{
	int in;
	struct termios new_settings;
	struct termios stored_settings;
	tcgetattr(0,&stored_settings);
	new_settings = stored_settings;
	new_settings.c_lflag &= (~ICANON);
	new_settings.c_cc[VTIME] = 0;
	tcgetattr(0,&stored_settings);
	new_settings.c_cc[VMIN] = 1;
	tcsetattr(0,TCSANOW,&new_settings);
 
	in = getchar();	// 读如一个字符
 
	tcsetattr(0,TCSANOW,&stored_settings);
	return in;
}
```

创建一个读取键盘输入的线程：`pthread_create(&th_getch, NULL, (void *)tinput, &x); `

处理`Esc`的功能函数如下：
```c++
void tinput(int* arg)
{
    int i=0;
    printf("thread1 is working\n");
    while(1){
        int ch=scanKeyboard();	// 调用键盘函数
        if(ch == 27){	// Esc则退出
            break;
        }else{			// sleep 1s后进行计数 +1
            sleep(1);
            printf("thread1 count: %d\n", ++i);
        }
    }
    pthread_cancel(th_a);	// 取消线程a
    pthread_cancel(th_b);	// 取消线程b
    printf("Thread1 say BYE.\n");
}
```



### 串行端口程序设计

1. 编写一个简单的文件收发程序完成串口文件下载。 
2. 终端对特殊字符的处理。

## 实验总结

第二次实验仍然需要用到交叉编译环境，但是由于第一次实验出了很多错没有总结，导致第二次实验还是浪费了许多时间。知道之后的实验都需要使用交叉编译环境之后，这一次实验过后总结了使用流程，为下一次实验做准备。

本次嵌入式是结合了多线程Pthread的应用。调用了一些Pthread的库函数，所以要注意的是在编译的时候需要调用 `-lpthread`来进行编译，否则会报错。

而关于串口的实验，由于机器环境的限制，不能运行出结果。

## 代码附录

Pthread.c

```c++
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <termio.h>
#include <time.h>
#include "pthread.h"
#define BUFFER_SIZE 16

pthread_t th_a, th_b, th_getch;

struct prodcons {
	int buffer[BUFFER_SIZE];
	pthread_mutex_t lock;
	int readpos, writepos;
	pthread_cond_t notempty;
	pthread_cond_t notfull;
};

/*--------------------------------------------------------*/
/* Initialize a buffer */
void init(struct prodcons * b)
{
	pthread_mutex_init(&b->lock, NULL);
	pthread_cond_init(&b->notempty, NULL);
	pthread_cond_init(&b->notfull, NULL);
	b->readpos = 0;
	b->writepos = 0;
}
/*--------------------------------------------------------*/
/* Store an integer in the buffer */
void put(struct prodcons * b, int data)
{
	pthread_mutex_lock(&b->lock);
	/* Wait until buffer is not full */
	while ((b->writepos + 1) % BUFFER_SIZE == b->readpos) {
		printf("wait for not full\n");
		pthread_cond_wait(&b->notfull, &b->lock);
	}
	/* Write the data and advance write pointer */
	b->buffer[b->writepos] = data;
	b->writepos++;
	if (b->writepos >= BUFFER_SIZE) b->writepos = 0;
	/* Signal that the buffer is now not empty */
	pthread_cond_signal(&b->notempty);
	pthread_mutex_unlock(&b->lock);
}
/*--------------------------------------------------------*/
/* Read and remove an integer from the buffer */
int get(struct prodcons * b)
{
	int data;
	pthread_mutex_lock(&b->lock);
	/* Wait until buffer is not empty */
	while (b->writepos == b->readpos) {
		printf("wait for not empty\n");
		pthread_cond_wait(&b->notempty, &b->lock);
	}
	/* Read the data and advance read pointer */
	data = b->buffer[b->readpos];
	b->readpos++;
	if (b->readpos >= BUFFER_SIZE) b->readpos = 0;
	/* Signal that the buffer is now not full */
	pthread_cond_signal(&b->notfull);
	pthread_mutex_unlock(&b->lock);
	return data;
}
/*--------------------------------------------------------*/
#define OVER (-1)
struct prodcons buffer;
/*--------------------------------------------------------*/
void * producer(void * data)	// 生产者线程
{
	int n;
	for (n = 0; n < 10; n++) {
		printf(" put-->%d\n", n);
		put(&buffer, n);
		sleep(1);
	}
	put(&buffer, OVER);
	printf("producer stopped!\n");
	return NULL;
}
/*--------------------------------------------------------*/
void * consumer(void * data)	// 消费者线程
{
	int d;
	while (1) {
		d = get(&buffer);
		if (d == OVER ) break;
		printf("%d-->get\n", d);
		sleep(1);
	}
	printf("consumer stopped!\n");
	return NULL;
}
/*--------------------------------------------------------*/

int scanKeyboard()	// 读如键盘输入
{
	int in;
	struct termios new_settings;
	struct termios stored_settings;
	tcgetattr(0,&stored_settings);
	new_settings = stored_settings;
	new_settings.c_lflag &= (~ICANON);
	new_settings.c_cc[VTIME] = 0;
	tcgetattr(0,&stored_settings);
	new_settings.c_cc[VMIN] = 1;
	tcsetattr(0,TCSANOW,&new_settings);
 
	in = getchar();
 
	tcsetattr(0,TCSANOW,&stored_settings);
	return in;
}

void tinput(int* arg)	// 读入键盘线程函数
{
        int i=0;
        printf("thread1 is working\n");
	    while(1){
	    	int ch=scanKeyboard();
	        if(ch == 27){
	            break;
	        }else{
	        	sleep(1);
	            printf("thread1 count: %d\n", ++i);
	        }
	    }
		pthread_cancel(th_a);
		pthread_cancel(th_b);
        printf("Thread1 say BYE.\n");
}

int main(void)
{
	
	void * retval;
	init(&buffer);

	int x, i;
    printf("write input num:");
    scanf("%d",&x);
    printf("th_getch: %d\n",x);
	
    // 创建三个线程
	pthread_create(&th_a, NULL, producer, 0);
	pthread_create(&th_b, NULL, consumer, 0);
	pthread_create(&th_getch, NULL, (void *)tinput, &x); 
    
	/* Wait until producer and consumer finish. */
	
    pthread_join(th_a, &retval);
	pthread_join(th_b, &retval);
	return 0;
}

```

term.c

```c++
#include <termios.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/signal.h>
#include <pthread.h>
#define BAUDRATE B115200
#define COM1 "/dev/ttyS0"
#define COM2 "/dev/ttyS1"
#define ENDMINITERM 27 /* ESC to quit miniterm */
#define FALSE 0
#define TRUE 1

volatile int STOP = FALSE;
volatile int fd;
void child_handler(int s)
{
    printf("stop!!!\n");
    STOP = TRUE;
}
/*--------------------------------------------------------*/
void *keyboard(void *data)
{
    int c;
    for (;;)
    {
        c = getchar();
        if (c == ENDMINITERM)
        {
            STOP = TRUE;
            break;
        }
    }
    return NULL;
}
/*--------------------------------------------------------*/
/* modem input handler */
void *receive(void *data)
{
    int c;
    printf("read modem\n");
    while (STOP == FALSE)
    {
        read(fd, &c, 1); /* com port */
        write(1, &c, 1); /* stdout */
    }
    printf("exit from reading modem\n");
    return NULL;
}
/*--------------------------------------------------------*/
void *send(void *data)
{
    int c = '0';
    printf("send data\n");
    while (STOP == FALSE) /* modem input handler */
    {
        c++;
        c %= 255;
        write(fd, &c, 1); /* stdout */
        usleep(100000);
    }
    return NULL; /* wait for child to die or it will become a zombie */
}
/*--------------------------------------------------------*/
int main(int argc, char **argv)
{
    struct termios oldtio, newtio, oldstdtio, newstdtio;
    struct sigaction sa;
    int ok;
    pthread_t th_a, th_b, th_c;
    void *retval;
    if (argc > 1)
        fd = open(COM2, O_RDWR);
    else
        fd = open(COM1, O_RDWR); //| O_NOCTTY |O_NONBLOCK);
    if (fd < 0)
    {
        error(COM1);
        exit(-1);
    }
    tcgetattr(0, &oldstdtio);
    tcgetattr(fd, &oldtio);
    /* save current modem settings */
    tcgetattr(fd, &newstdtio);
    /* get working stdtio */
    newtio.c_cflag = BAUDRATE | CRTSCTS | CS8 | CLOCAL | CREAD; /*ctrol flag*/
    newtio.c_iflag = IGNPAR;
    /*input flag*/
    newtio.c_oflag = 0;
    /*output flag*/
    newtio.c_lflag = 0;
    newtio.c_cc[VMIN] = 1;
    newtio.c_cc[VTIME] = 0;
    /* now clean the modem line and activate the settings for modem */
    tcflush(fd, TCIFLUSH);
    tcsetattr(fd, TCSANOW, &newtio); /*set attrib*/
    sa.sa_handler = child_handler;
    sa.sa_flags = 0;
    sigaction(SIGCHLD, &sa, NULL);
    /* handle dying child */
    pthread_create(&th_a, NULL, keyboard, 0);
    pthread_create(&th_b, NULL, receive, 0);
    pthread_create(&th_c, NULL, send, 0);
    pthread_join(th_a, &retval);
    pthread_join(th_b, &retval);
    pthread_join(th_c, &retval);
    tcsetattr(fd, TCSANOW, &oldtio);   /* restore old modem setings */
    tcsetattr(0, TCSANOW, &oldstdtio); /* restore old tty setings */
    close(fd);
    exit(0);
}
```






