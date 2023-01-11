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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《SOCKET网络编程实验》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 嵌入式第三次实验</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">  </td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-23</td>     </tr>
    </tbody>              
    </table>
</div>

<!-- 注释语句：导出PDF时会在这里分页 -->

## 实验目的

1. 掌握在ARM开发板实现SOCKET网络编程。

2. 学习在ARM开发板上的TCP编程。

3. 学习在ARM开发板上的UDP编程。

## 实验要求

1. c语言的基础知识、程序调试的基础知识和方法，LINUX环境下常用命令和VI编辑器的操作。

2. TCP、UDP协议的基本知识。

3. SOCKET编程

### TCP & UDP

UDP 和 TCP 是协议层中两个最重要的协议，主要区别是两者在实现信息的可靠传递方面不同。TCP 协议中包含了专门的传递保证机制，当数据接收方收到发送方传来的信息时，会自动向发送方发出确认消息;发送方只有在接收到该确认消息之后才继续传送其他信息，否则将一直等待，直到收到确认信息为止。

UDP 协议并不提供数据传送的保证机制。如果在从发送方到接收方的传递 过程中出现数据报的丢失，协议本身并不能做出任何检测或提示。

这两种协议都有其存在的价值，本节中以 TCP 和 UDP 两种协议为例，介绍 Linux 的网络编程。

## 实验内容

### 实验任务

Linux编程，通过交叉编译实现在ARM开发板上的TCP和UDP的SOCKET网络通信

首先用网线连接开发板和pc机，然后需要配置IP地址，使得开发板和爬虫、机之间可以通信

### 实验环境（含主要设计设备，器材，软件等）

- 硬件： Tiny4412开发板、网线

- 软件： Ubuntu系统

## 实验步骤

首先建立交叉编译环境。`arm-linux-gcc –v `进行验证

### TCP实验

#### 基础介绍

网络通信大部分是在客户机/服务器模式下进行的，例如，telnet。使用 telnet 连接到 远程主机的端口时，主机就开始运行 telnet 的程序，用来处理所有进入的 telnet 连接，设置登录提示符等。

应当注意的是，客户机/服务器模式可以使用 SOCK_STREAM、SOCK_DGRAM，或者任何其他 的方式。例如，telnet/telnetd、ftp/ftpd 和 bootp/bootpd。

#### 详细过程

1. 交叉编译服务端程序（server）：`arm-linux-gcc server.c -o server.asm`

2. 编译客户端程序（client）：`gcc client.c -o client.out`

3. 将服务端程序上传到nimicom开发板

4. 在minicom开发板上运行服务端程序（server）：`./server.asm`

   <img src="https://s1.vika.cn/space/2022/06/24/063580d9826d4e51b8a15cdbcce5de8b" alt="image-20220624163758018" style="zoom:50%;" />

5. 在PC机上运行客户端程序（client）：`./client.out`

6. 服务器程序通过一个数据流连接发送字符串“Hello, World!\n”，然后在另一个窗口的客户端得到字符串。

   <img src="https://s1.vika.cn/space/2022/06/24/b9f0d398903442b9a52122bfeef5d5d8" alt="image-20220624163819851" style="zoom:50%;" />

#### 代码分析

##### 服务端Server

建立过程大致如下：

1. socket()建立一个套接口。
2. bind()绑定一个地址，包括 IP 地址和端口地址。这一步确定了服务器的位置，使客户端知道如何访问。
3. listen()监听端口的新的连接请求。
4. 通过函数 accept()接受新的连接。

```c++
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/wait.h>
#define MYPORT 3490 /* 用户将连接的端口 the port users will be connecting to */
#define BACKLOG 10  /* 将保持挂起的连接队列数how many pending connections queue will hold */
main()
{
    int sockfd, new_fd;            /* listen on sock_fd, new connection on new_fd */
    struct sockaddr_in my_addr;    /* 服务端地址 my address information */
    struct sockaddr_in their_addr; /* 连接者地址信息  connector's address information */
    int sin_size;
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == 1)
    {
        perror("socket");
        exit(1);
    }
    my_addr.sin_family = AF_INET;         /* host byte order */
    my_addr.sin_port = htons(MYPORT);     /* short, network byte order */
    my_addr.sin_addr.s_addr = INADDR_ANY; /* 自动填充IP auto-fill with my IP */
    bzero(&(my_addr.sin_zero), 8);        /* zero the rest of the struct */
    if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(struct sockaddr)) == 1)
    {
        perror("bind");
        exit(1);
    }
    if (listen(sockfd, BACKLOG) == 1)
    {
        perror("listen");
        exit(1);
    }
    while (1)
    { /* main accept() loop */
        sin_size = sizeof(struct sockaddr_in);
        if ((new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size)) == 1)
        {
            perror("accept");
            continue;
        }
        printf("server: got connection from %s\n", inet_ntoa(their_addr.sin_addr));
        if (!fork())
        { /* this is the child process */
            if (send(new_fd, "Hello, world!\n", 14, 0) == 1)
                perror("send");
            close(new_fd);
            exit(0);
        }
        close(new_fd); /* parent doesn't need this */
        while (waitpid(1, NULL, WNOHANG) > 0)
            ; /* clean up child processes */
    }
}
```



##### 客户端Client

一个典型的 TCP 客户端程序需要先建立 socket 文件描述符，接着连接服务器，然后便 可以写进或读取数据。这个过程重复到写入和读取完所需信息后，才关闭连接。客户机所做 的是连接到主机的 3490 端口。它读取服务器发送的字符串。

```c++
#define PORT 3490       /* 连接端口 the port client will be connecting to */
#define MAXDATASIZE 100 /*一次能接受的最大字节数 max number of bytes we can get at once */
int main(int argc, char *argv[])
{
    int sockfd, numbytes;
    char buf[MAXDATASIZE];
    struct hostent *he;
    struct sockaddr_in their_addr; /* 连接地址信息 connector's address information */
    if (argc != 2)
    {
        fprintf(stderr, "usage: client hostname\n");
        exit(1);
    }
    if ((he = gethostbyname(argv[1])) == NULL)
    { /* get the host info */
        herror("gethostbyname");
        exit(1);
    }
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == 1)
    {
        perror("socket");
        exit(1);
    }
    their_addr.sin_family = AF_INET;   /* host byte order */
    their_addr.sin_port = htons(PORT); /* short, network byte order */
    their_addr.sin_addr = *((struct in_addr *)he->h_addr);
    bzero(&(their_addr.sin_zero), 8); /* zero the rest of the struct */
    if (connect(sockfd, (struct sockaddr *)&their_addr,
                sizeof(struct sockaddr)) == 1)
    {
        perror("connect");
        exit(1);
    }
    if ((numbytes = recv(sockfd, buf, MAXDATASIZE, 0)) == 1)
    {
        perror("recv");
        exit(1);
    }
    buf[numbytes] = '\0';
    printf("Received: %s", buf);
    close(sockfd);
    return 0;
}
```

### UDP实验

#### 基础介绍

UDP 协议的每个发送和接收的数据报都包含了发送方和接收方的地址信息。在发送和接 收数据之前，先要建立一个数据报方式的套接口，该 socket 的类型为 SOCK_ DGRAM，用如下 的调用产生:

```
    sockfd=socket(AF_INET, SOCK_DGRAM, 0);
```

由于不需要建立连接，因此产生 socket 后就可以直接发送和接收了。当然，要接收数 据报也必须绑定一个端口，否则发送方无法得知要发送到哪个端口。

#### 详细步骤

1. 交叉编译文件udptalk：`arm-linux-gcc udptalk.c -o arm-udptalk`
2. 编译文件udptalk：`arm-linux-gcc udptalk.c -o arm-udptalk`
3. PC输入：`./x86-udptalk [开发板的IP] 2000 [PC的IP] 2000`
   <img src="https://s1.vika.cn/space/2022/06/24/20afd38bc60e4f0d8db95f5bc47f041d" alt="image-20220624164618106" style="zoom:50%;" />
4. minicom开发板输入：`arm-udptalk [PC的IP] 2000 [开发板的IP] 2000`
   <img src="https://s1.vika.cn/space/2022/06/24/a3323fd093394593a41198ff30bc4e4e" alt="image-20220624164718324" style="zoom:50%;" />

#### 代码

```c++
/*****udptalk.c****/
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#define BUFLEN 255
int main(int argc, char **argv)
{
    struct sockaddr_in peeraddr, /*存放谈话对方 IP 和端口的 socket 地址*/ localaddr; /*本端 socket 地址*/
    int sockfd;
    char recmsg[BUFLEN + 1];
    int socklen, n;
    if (argc != 5)
    {
            printf("%s <dest IP address> <dest port> <source IP address>
            <source port>\n", argv[0]);
            exit(0);
    }
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        printf("socket creating err in udptalk\n");
        exit(1);
    }
    socklen = sizeof(struct sockaddr_in);
    memset(&peeraddr, 0, socklen);
    peeraddr.sin_family = AF_INET;
    peeraddr.sin_port = htons(atoi(argv[2]));
    if (inet_pton(AF_INET, argv[1], &peeraddr.sin_addr) <= 0)
    {
        printf("Wrong dest IP address!\n");
        exit(0);
    }
    memset(&localaddr, 0, socklen);
    localaddr.sin_family = AF_INET;
    if (inet_pton(AF_INET, argv[3], &localaddr.sin_addr) <= 0)
    {
        printf("Wrong source IP address!\n");
        exit(0);
    }
    localaddr.sin_port = htons(atoi(argv[4]));
    if (bind(sockfd, &localaddr, socklen) < 0)
    {
        printf("bind local address err in udptalk!\n");
        exit(2);
    }
    if (fgets(recmsg, BUFLEN, stdin) == NULL)
        exit(0);
    if (sendto(sockfd, recmsg, strlen(recmsg), 0, &peeraddr, socklen) < 0)
    {
        printf("sendto err in udptalk!\n");
        exit(3);
    }
    for (;;)
    {
        /*recv&send message loop*/
        n = recvfrom(sockfd, recmsg, BUFLEN, 0, &peeraddr, &socklen);
        if (n < 0)
        {
            printf("recvfrom err in udptalk!\n");
            exit(4);
        }
        else
        {
            /*成功接收到数据报*/ recmsg[n] = 0;
            printf("peer:%s", recmsg);
        }
        if (fgets(recmsg, BUFLEN, stdin) == NULL)
            exit(0);
        if (sendto(sockfd, recmsg, strlen(recmsg), 0, &peeraddr, socklen) < 0)
        {
            printf("sendto err in udptalk!\n");
            exit(3);
        }
    }
}
```

### 注意事项

1. 开发板IP设置，把arm开发板的ip设置成与主机网口的ip在一个地址段，设置命令 `ifconfig eth0 ipaddress` 

2. 开发板ip地址设置完毕后，使用网线把开发板和PC机连接起来。

## 思考题

1. 分析 TCP 协议从上层接收到数据后，通过以太网接口发送出去的过程?

TCP接收到数据之后，在TCP层为数据加上首部。也就是所谓的数据封装。在传输数据的时候，每一层都需要数据封装，具体见下图：
![img](https://s1.vika.cn/space/2022/06/24/85a32ed653da4007963b2c0bf46da14e)

首先TCP层（传输层）在接收到应用层的数据后，加上TCP首部，这包含了源端口，目的端口，协议类型等，在传递给网络层（IP层），包含了源ip，目的ip等内容，接下来传递给数据链路层，同样加上首部和尾部。

这是就需要根据目的MAC地址寻找需要将数据发送的位置，进行广播或其他方式寻找之后，通过以太网接口发送数据。





2. 分析以太网接口接收到数据后，如何提交给上层协议?

ethernet以太网帧有一定的数据格式，在《计算机网络》中我们学习的是IEEE802.3帧格式如下图：
![preview](https://s1.vika.cn/space/2022/06/24/e248526f86f44026a61537765a2f65cc)

头部去掉6字节的源和6字节的目标mac地址、2字节的协议字段，尾部去掉4字节的fcs字段，余下部分即为交付上层的数据了；以太网帧中包含一个Type字段，表示帧中的数据应该发送到上层哪个协议处理。所以上层可以确定处理数据的协议和方法。这样可以使用相应的协议解析数据帧，从而实现把数据交付给上层。

## 实验总结

本次实验进行了嵌入式网络编程。除了使用嵌入式和开发板之外，还与之前学习到的计算机网络的知识结合起来了。实验中遇到了两个问题：

1. 实验使用PC和minicom开发板充当服务机和客户端，所以实验前为了下载交叉编译的插件，没有把网线连接到开发板上，导致开始一直出现问题。
2. 配置IP的问题。PC端的IP地址不用配置，而minicom的开发板的ip应该和PC属于同一子网。如果不属于同一子网那么两者不能相互通信，也就不能ping通。所以这一部分的计算机网络知识仍然需要理解。不能单纯的运行代码，要理解原理之后再进行实验。



