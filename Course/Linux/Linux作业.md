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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《Linux C编程实战：BT下载软件改进》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">作业 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> Linux作业</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">任继平 </td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-7-2</td>     </tr>
    </tbody>              
    </table>
</div>



<!-- 注释语句：导出PDF时会在这里分页 -->

## 项目简介

待开发的BT软件（即BT客户端）主要包含以下几个功能：

1. 解析种子文件获取待下载的文件的一些信息，连接Tracker获取peer的IP和端口，连接peer进行数据上传和下载、对要发布的提供共享文件制作和生成种子文件。
2. 种子文件和Tracker的返回信息都以一种简单而高效的编码方式进行编码，称为B编码。
3. 客户端与Tracker交换信息基于HTTP协议，Tracker本身作为一个Web服务器存在。
4. 客户端与其他peer采用面向连接的可靠传输协议TCP进行通信。

此项目整体架构如图：

![image-20220703192529832](https://s1.vika.cn/space/2022/07/03/8fd8e166f3be436487b0156924dea70b)

## 部分功能分析与改进


### 位图

```c++
bitfield.h
#ifndef BITFIELD_H
#define BITFIELD_H

typedef struct _Bitmap {
     unsigned char  *bitfield;       	// 保存位图
     int           bitfield_length; 	// 位图所占的总字节数
     int           valid_length;    	// 位图有效的总位数,每一位代表一个piece
} Bitmap;

int  create_bitfield();                      		// 创建位图,分配内存并进行初始化
int  get_bit_value(Bitmap *bitmap,int index);	// 获取某一位的值
int  set_bit_value(Bitmap *bitmap,int index, unsigned char value);
// 设置某一位的值
int  all_zero(Bitmap *bitmap); 					// 全部清零
int  all_set(Bitmap *bitmap);                		// 全部设置为1
void release_memory_in_bitfield();           		// 释放bitfield.c中动态分配的内存
int  print_bitfield(Bitmap *bitmap);         		// 打印位图值,用于调试

int  restore_bitmap(); 	// 将位图存储到文件中 
                 		  	// 在下次下载时,先读取该文件获取已经下载的进度
int  is_interested(Bitmap *dst,Bitmap *src);  	// 拥有位图src的peer是否对拥有
                                     				// dst位图的peer感兴趣
int  get_download_piece_num(); 		  			// 获取当前已下载到的总piece数

#endif
```

程序说明。

（1）结构体Bitmap中，bitfield_length为指针bitfield所指向的内存的长度（以字节为单位），而valid_length为位图的有效位数。例如，某位图占100字节，而有效位数位795，则位图最后一个字节的最后5位(100 ´ 8−795)是无效的。

（2）函数is_interested用于判断两个peer是否感兴趣，如果peer1拥有某个piece，而peer2没有，则peer2对peer1感兴趣，希望从peer1处下载它没有的piece。

（3）函数get_download_piece_num用于获得已下载的piece数，其方法是统计结构体Bitmap的bitfield成员所指向的内存中值为1的位数。

文件bitfield.c的头部包含的文件如下：

```c++
bitfield.c文件头部包括的内容
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <malloc.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include "parse_metafile.h"
#include "bitfield.h"

extern int  	pieces_length;
extern char 	*file_name;

Bitmap     	*bitmap = NULL;        	// 指向位图
int         download_piece_num = 0; 	// 当前已下载的piece数
```

程序说明。

（1）语句“extern int pieces_length;”声明了一个变量，这个变量是在parse_metafile.c中定义的全局变量。如果要在其他源文件中使用某个源文件中定义的变量，需要在使用该变量的源文件的头部以extern关键字声明。注意声明和定义的区别，声明仅仅是告知编译器有某个变量，而对于定义，编译器要分配内存空间来存储该变量的值。

（2）全局变量bitmap指向自己的位图，可以从位图中获知下载的进度。peer的位图存放在Peer结构体中。



### peer之间的通信协议

peer之间的通信协议又称为peer wire protocal，即peer连线协议，它是一个基于TCP协议的应用层协议。

为了防止有的peer只下载不上传，BitTorrent协议建议，客户端只给那些向它提供最快下载速度的4个peer上传数据。简单地说就是谁向我提供下载，我也提供数据供它下载；谁不提供数据给我下载，我的数据也不会上传给它。客户端每隔一定时间，比如10秒，重新计算从各个peer处下载数据的速度，将下载速度最快的4个peer解除阻塞，允许这4个peer从客户端下载数据，同时将其他peer阻塞。

一个例外情况是，为了发现下载速度更快的peer，协议还建议，在任一时刻，客户端保持一个优化非阻塞peer，即无论该peer是否提供数据给客户端下载，客户端都允许该peer从客户端这里下载数据。由于客户端向peer上传数据，peer接着也允许客户端从peer处下载数据，并且下载速度超过4个非阻塞peer中的一个。客户端每隔一定的时间，如30秒，重新选择优化非阻塞peer。

当客户端与peer建立TCP连接后，客户端必须维持的几个状态变量如下表所示。

| 状  态 变 量    | 含  义                                                       |
| --------------- | ------------------------------------------------------------ |
| am_chocking     | 该值若为1，表明客户端将远程peer阻塞。此时如果peer发送数据请求给客户端，客户端将不会理会。也就是说，一旦将peer阻塞，peer就无法从客户端下载到数据；该值若为0，则刚好相反，即表明peer未被阻塞，允许peer从客户端下载数据 |
| am_interested   | 该值若为1，表明客户端对远程的peer感兴趣。当peer拥有某个piece，而客户端没有，则客户端对peer感兴趣。该值若为0，则刚好相反，即表明客户端对peer不感兴趣，peer拥有的所有piece，客户端都拥有 |
| peer_chocking   | 该值若为1，表明peer将客户端阻塞。此时，客户端无法从peer处下载到数据。该值若为0，表明客户端可以向peer发送数据请求，客户端将进行响应 |
| peer_interested | 该值若为1，表明peer对客户端感兴趣。也即客户端拥有某个piece，而peer没有。该值若为0，表明peer对客户端不感兴趣 |

当客户端与peer建立TCP连接后，客户端将这几个变量的值设置为。
```c++
am_chocking   = 1。
am_interested = 0。
peer_chocking  = 1。
peer_interested = 0。
```

当客户端对peer感兴趣且peer未将客户端阻塞时，客户端可以从peer处下载数据。当peer对客户端感兴趣，且客户端未将peer阻塞时，客户端向peer上传数据。

除非另有说明，所有的整数型在本协议中被编码为4字节值（高位在前低位在后），包括在握手之后所有信息的长度前缀。

客户端与一个peer建立TCP连接后，首先向peer发送握手消息，peer收到握手消息后回应一个握手消息。

除了握手关系，也有很多其他关系，比如说：keep_alive, choke, interested…

其中：interested消息：<len=0001><id=2>

interested消息的长度固定，为5字节，消息长度占4个字节，消息编号占1个字节，没有负载。当客户端收到某peer的have消息时，如果发现peer拥有了客户端没有的piece，则发送interested消息告知该peer，客户端对它感兴趣。

而处理interested消息的代码如下：(其中提到的位图详解见2.1节)
```c++
int is_interested(Bitmap *dst,Bitmap *src)
{
     unsigned char const_char[8] = { 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01};
     unsigned char c1, c2;
     int              i, j;
     
     if( dst==NULL || src==NULL )  return -1;
     if( dst->bitfield==NULL || src->bitfield==NULL )  return -1;
     if( dst->bitfield_length!=src->bitfield_length || dst->valid_length!=src-> valid_length )
          return -1;
     // 如果dst中某位为1而src对应为0，则说明src对dst感兴趣
     for(i = 0; i < dst->bitfield_length-1; i++) {
          for(j = 0; j < 8; j++) {  // 比较某个字节的所有位
               c1 = (dst->bitfield)[i] & const_char[j];  // 获取每一位的值
               c2 = (src->bitfield)[i] & const_char[j];
               if(c1>0 && c2==0)  return 1; 
          }
     }
     
     j = dst->valid_length % 8;
     c1 = dst->bitfield[dst->bitfield_length-1];
     c2 = src->bitfield[src->bitfield_length-1];
     for(i = 0; i < j; i++) {  // 比较位图的最后一个字节
          if( (c1&const_char[i])>0 && (c2&const_char[i])==0 )
               return 1;
     }
     return 0;
}
```



问题一：附近客户端配对速度过慢(多个客户端串行化配对，每个主机都要等待配对一段时间

解决方法：并行主机配对，采用多线程，将所有主机的配对等待时间并行压缩起来。

1. 线程运行类的成员函数，需要传入this指针作为第一个参数 std::thread(classname::thr_start, this)    
2. 线程对象无法直接赋值，需要使用std::move接口完成，std::thread thr1 = std::move(std::thread())    
3. 线程参数传递，若传递的参数形参是引用参数，传递实参时，使用std::ref(variable)修饰。    
4. 线程参数传递过多的情况下，参数类型不匹配，需要控制参数个数



问题二：大文件下载比较慢(单线程串行下载)

采用多线程分块传输，对每个大文件进行下载时，每个线程只传输文件的一部分数据

1. 获取文件大小 -> 

2. 根据文件大小进行区域分块 -> 
3. 3.创建多线程进行下载文件(每个线程只负责下载自己负责的文件分块数据)

IO操作，分为等待IO就绪和数据拷贝操作两部分，多线程下载文件可将等待过程并行压缩。



## 总结

Linux下的C语言项目开发实战 —— BitTorrent下载客户端是个比较大型的项目，在一个学期中只是了解了每个部分具体的实现功能以及互相调用组合的整体架构。

本次作业我选择了其中的一部分功能查阅资料以及代码进行分析，主要是peer的数据结构实现一以及通信的实现部分。并根据自己的理解提出了一些改进方法。

本次作业不仅包含了Linux开发，也是基于计算机网络的知识进行编写代码。
