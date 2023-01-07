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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《交叉编译等基础》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 第一次实验</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">武玲娟 </td>     </tr>
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

## 实验目的

1. 通过本次实验，了解Linux环境下的嵌入式开发流程。
2. 能够熟练配置交叉编译环境，为本次以及后续实验打下基础。
3. 熟悉Tiny4412开发板的基本使用方式。
4. 了解并熟练掌握minicom的使用方法，包括如何上传程序，如何运行。

## 实验要求

### 基本要求

1. C 语言基础

2. 掌握在 Linux 下常用编辑器的使用

3. 掌握 Makefile 的编写和使用

4. 掌握 Linux 下的程序编译与交叉编译过程

5. 掌握minicom使用

### 实验环境

硬件： Tiny4412开发板、PC主机

软件：Qtopia2.2.0（开发板）、Ubuntu（PC）

实验环境：Ubuntu

## 实验内容

### 交叉编译环境的安装

1. 打开终端后输入`sudo -s`进入root权限，密码`123456`。

2. 进入环境压缩包所在目录并解压压缩包。`tar xvzf arm-linux-gcc-4.5.1-v6-vfp-20120301.tgz –C [目的路径]`

3. 将交叉编译环境添加到环境变量：

   1. 打开终端，进入到root权限`sudo -s`

   2. 打开配置文件`gedit ~/.bashrc`，并在最后添加上如下语句(路径是解压后路径)，命令与结果如下所示：

      ```
      PATH=$PATH:/opt/FriendlyARM/toolschain/4.5.1/bin
      ```

      ![1](https://s1.vika.cn/space/2022/06/11/d5a8e8ba223741c58c5fb0b8b46bf7fc)

   3. 更新配置文件并下载插件（此时PC需要连接网线）

      ````
      source ~/.bashrc
      echo $PATH
      apt-get install lsb-core
      ````

   4. 验证环境是否配置成功`arm-linux-gcc -v`，若显示如下，则证明成功

      ![2](https://s1.vika.cn/space/2022/06/11/df937895c32c4ce9a5b30f8033967eb5)

其他注意事项：

1. 发现串口被锁，执行此命令删除该文件rm /var/lock/L*
2. gedit ~/.bashrc后报gedit错：用 vi ~/.bashrc编辑保存，再source ~/.bashrc更新配置





### minicom的配置

#### 参数设置

`ctrl + A  Z` 进入minicom设置界面。

设备：/dev/ttyS0

波特率：115200

**注意必须选择无硬件流控制**

#### 硬件连接

串口选择离电源近的接口，启动模式的按钮拨到上面。成功连接后终端会打印信息，如果没有打印则说明未连接成功，可能原因如下：

1. 串口线出现故障或未连接好
2. minicom设置不符合要求

#### 传输文件

传输文件：进入设置界面后，按下`S`进入传输文件

![303F7F32-919B-42CF-BA89-E04CA96B3351](https://s1.vika.cn/space/2022/06/17/ef12b49235544d6d97f5d99fc9e6ec98)

选择zmodem

![3](https://s1.vika.cn/space/2022/06/11/7d0857de24ac4b089ccbc771753596a2)

接下来选择要传输的文件即可

### 代码运行结果

#### Helloworld

```c++
#include <stdio.h>
int main(void)
{
    printf("hello World!");
}
```

执行第一个代码helloworld，运行结果如下所示：

![3-0](https://s1.vika.cn/space/2022/06/11/3b7842d05ac547bf8e36eaa0298a3d2e)

#### LED

```c++
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main(int argc, char **argv)
{
	int on;
	int led_no;
	int fd;

	if (argc != 3 || sscanf(argv[1], "%d", &led_no) != 1 || sscanf(argv[2],"%d", &on) != 1 ||
			on < 0 || on > 1 || led_no < 0 || led_no > 3) {
		fprintf(stderr, "Usage: leds led_no 0|1\n");
		exit(1);
	}

	fd = open("/dev/leds0", 0);
	if (fd < 0) {
		fd = open("/dev/leds", 0);
	}
	if (fd < 0) {
		perror("open device leds");
		exit(1);
	}

	ioctl(fd, on, led_no);
	close(fd);

	return 0;
}
```

如果命令行输入参数不是三个，则会进行提示并结束程序运行：

<img src="https://s1.vika.cn/space/2022/06/17/6e3caa7efd584407afaa73a98c253581" alt="image-20220617195609525" style="zoom:50%;" />



#### 蜂鸣器

```c++
#include <stdio.h>
#include <termios.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define PWM_IOCTL_SET_FREQ		1
#define PWM_IOCTL_STOP			0

#define	ESC_KEY		0x1b

static int getch(void)
{
	struct termios oldt,newt;
	int ch;

	if (!isatty(STDIN_FILENO)) {
		fprintf(stderr, "this problem should be run at a terminal\n");
		exit(1);
	}
	// save terminal setting
	if(tcgetattr(STDIN_FILENO, &oldt) < 0) {
		perror("save the terminal setting");
		exit(1);
	}

	// set terminal as need
	newt = oldt;
	newt.c_lflag &= ~( ICANON | ECHO );
	if(tcsetattr(STDIN_FILENO,TCSANOW, &newt) < 0) {
		perror("set terminal");
		exit(1);
	}

	ch = getchar();

	// restore termial setting
	if(tcsetattr(STDIN_FILENO,TCSANOW,&oldt) < 0) {
		perror("restore the termial setting");
		exit(1);
	}
	return ch;
}

static int fd = -1;
static void close_buzzer(void);
static void open_buzzer(void)
{
	fd = open("/dev/pwm", 0);
	if (fd < 0) {
		perror("open pwm_buzzer device");
		exit(1);
	}

	// any function exit call will stop the buzzer
	atexit(close_buzzer);
}

static void close_buzzer(void)
{
	if (fd >= 0) {
		ioctl(fd, PWM_IOCTL_STOP);
		if (ioctl(fd, 2) < 0) {
			perror("ioctl 2:");
		}
		close(fd);
		fd = -1;
	}
}

static void set_buzzer_freq(int freq)
{
	// this IOCTL command is the key to set frequency
	int ret = ioctl(fd, PWM_IOCTL_SET_FREQ, freq);
	if(ret < 0) {
		perror("set the frequency of the buzzer");
		exit(1);
	}
}
static void stop_buzzer(void)
{
	int ret = ioctl(fd, PWM_IOCTL_STOP);
	if(ret < 0) {
		perror("stop the buzzer");
		exit(1);
	}
	if (ioctl(fd, 2) < 0) {
		perror("ioctl 2:");
	}
}

int main(int argc, char **argv)
{
	int freq = 1000 ;
	
	open_buzzer();

	printf( "\nBUZZER TEST ( PWM Control )\n" );
	printf( "Press +/- to increase/reduce the frequency of the BUZZER\n" ) ;
	printf( "Press 'ESC' key to Exit this program\n\n" );
	
	
	while( 1 )
	{
		int key;

		set_buzzer_freq(freq);
		printf( "\tFreq = %d\n", freq );

		key = getch();

		switch(key) {
		case '+':
			if( freq < 20000 )
				freq += 10;
			break;

		case '-':
			if( freq > 11 )
				freq -= 10 ;
			break;

		case ESC_KEY:
		case EOF:
			stop_buzzer();
			exit(0);

		default:
			break;
		}
	}
}

```

执行代码后，会发出声音。按键盘上的 + 和 - 会调整频率，使得蜂鸣器的声音改变。同时终端会输出当前频率

![4-2](https://s1.vika.cn/space/2022/06/11/8281242f7cb5443e85a49445203189f3)



## 实验总结

第一次接触嵌入式实验并且是在Linux的环境下做实验，首先对于Linux的系统并不是非常熟悉，命令行终端进行大部分操作需要一段时间的适应。

硬件方面相关的实验有时并不会明确指出错误，甚至不会有任何提示。比如连接minicom时没有反应，一直修改配置，重新进行了很多次尝试，直到很久才锁定是因为串口线故障的原因。

本次实验掌握了基本的流程，为之后的实验打下了基础。

