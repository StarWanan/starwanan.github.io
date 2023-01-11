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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《LS命令实现程序》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> Linux第一次实验报告</td>     </tr>
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

Shell编程是linux编程的核心内容，Shell命令的理解和实现是理解Shell机制的最直接的方式，本实验要求用C语言编写和调试一个ls命令的实现程序。以达到理解Shell机制的目的。

## 实验内容

1.	Ls命令的操作手册阅读
   通过Linux命令帮助文档，查阅ls命令的帮助信息，并理解各个选项的内容。
2.	查阅有关Linux命令实现的有关资料
   结合Shell的机制，查阅有关Shell命令的实现思想，并设计Shell命令的实现框架。
3.	算法实现
   应用c语言编写程序并调试，对比ls命令的源代码，分析自己实现代码的不足和改进的想法。

## 实验步骤

### 任务分析

通过查阅资料，使用C语言实现ls的功能。能够通过用户输入不同的参数实现对应ls功能，将每个由Directory参数指定的目录或者每个由File参数指定的名称写到标准输出，以及用户所要求的和标志一起的其它信息。

(1) 输入的形式和输入值的范围：`ls [参数] [文件路径]`

(2) 输出的形式：目录、文件以及其他信息

(3) 程序所能达到的功能：根据用户输入，仿照实现ls对应功能。

(4) 测试数据：包括正确的输入及其输出结果和含有错误的输入及其输出结果(实验环境：macOS)

正确输入：`./a ls /` 
<img src="https://s1.vika.cn/space/2022/06/20/017143a70e6f4cc6a64c088db790b8a8" alt="image-20220620082629637" style="zoom:67%;" />

错误输入：`./a ls` 并未给出文件路径
<img src="https://s1.vika.cn/space/2022/06/20/5bdd9ef8f101488ea60c9c58df8fe5e3" alt="image-20220620082743302" style="zoom:67%;" />



实现ls更多功能：
<img src="https://s1.vika.cn/space/2022/06/20/b5ca2c373e59460fa717c0a7d080878d" alt="image-20220620085455657" style="zoom:67%;" />



为了之后调试方便，之后的程序都是用`#define`定义的文件路径，不需要在命令行给出。



### 概要设计

此小节说明本程序中用到的所有抽象数据类型的定义、主程序的流程以及各程序模块之间的层次(调用)关系。

#### 数据类型定义

`FILE_NAME`：文件路径。
本次实验中将其define为固定的当前目录下，即`#define FILE_NAME "."`

`DIR`：DIR结构体类似于FILE，是一个内部结构

`struct dirent`：一个文件结构体
目录文件（directory file）:这种文件包含了其他文件的名字以及指向与这些文件有关的信息的指针
==所以dirent不仅仅指向目录，还指向目录中的具体文件==

`struct stat`：存储文件的详细信息的结构体

`struct passwd`：存储用户信息的结构体

`struct group`：存储用户组信息的结构体

`struct tm`：日期和时间

#### 主程序流程

```flow
st=>start: start
e=>end: end
c1=>condition: 参数数量=1
c2=>condition: 参数数量=2
c3=>condition: argv[1] = a
c4=>condition: argv[1] = l
op1=>operation: ls
op2=>operation: ls -a
op3=>operation: ls -l

st->c1(yes,right)->op1(right)->e
c1(no)->c2(yes)->c3
c3(yes,right)->op2(right)->e
c3(no)->c4(yes)->op3(right)->e
```



### 详细设计　　

#### 数据类型实现

由于依赖了很多封装好的数据类型以及库，自己定义的数据类型并不复杂，所以本节主要解释程序中使用到的库中的数据类型。

##### DIR

`DIR`：DIR结构体类似于FILE，是一个内部结构

```c++
struct __dirstream
{
    void *__fd; /* `struct hurd_fd' pointer for descriptor.   */
    char *__data; /* Directory block.   */
    int __entry_data; /* Entry number `__data' corresponds to.   */
    char *__ptr; /* Current pointer into the block.   */
    int __entry_ptr; /* Entry number `__ptr' corresponds to.   */
    size_t __allocation; /* Space allocated for the block.   */
    size_t __size; /* Total valid data in the block.   */
    __libc_lock_define (, __lock) /* Mutex lock for this structure.   */
};
typedef struct __dirstream DIR;
```

函数 `DIR *opendir(const char *pathname)`，即打开文件目录，返回的就是指向DIR结构体的指针。该指针由以下几个函数调用：

```c++
truct dirent *readdir(DIR *dp);   
void rewinddir(DIR *dp);   
int closedir(DIR *dp);   
long telldir(DIR *dp);   
void seekdir(DIR *dp,long loc); 
```



##### dirent

`struct dirent`：一个文件结构体
目录文件（directory file）:这种文件包含了其他文件的名字以及指向与这些文件有关的信息的指针
==dirent不仅仅指向目录，还指向目录中的具体文件，readdir函数同样也读取目录下的文件==

```c++
struct dirent
{
   long d_ino; /* inode number 索引节点号 */
   off_t d_off; /* offset to this dirent 在目录文件中的偏移 */
   unsigned short d_reclen; /* length of this d_name 文件名长 */
   unsigned char d_type; /* the type of d_name 文件类型 */
   char d_name [NAME_MAX+1]; /* file name (null-terminated) 文件名，最长255字符 */
}
```

dirent结构体存储的关于文件的信息很少，所以dirent同样也是起着一个索引的作用，如果想获得类似ls -l那种效果的文件信息，必须要使用`stat`函数。

##### stat

通过readdir函数读取到的文件名存储在结构体dirent的d_name成员中，而函数`int stat(const char *file_name, struct stat *buf);`的作用就是获取文件名为d_name的文件的详细信息，存储在stat结构体中。以下为stat结构体的定义：

```c++
struct stat
{
    mode_t st_mode; //文件访问权限
    ino_t st_ino; //索引节点号
    dev_t st_dev; //文件使用的设备号
    dev_t st_rdev; //设备文件的设备号
    nlink_t st_nlink; //文件的硬连接数
    uid_t st_uid; //所有者用户识别号
    gid_t st_gid; //组识别号
    off_t st_size; //以字节为单位的文件容量
    time_t st_atime; //最后一次访问该文件的时间
    time_t st_mtime; //最后一次修改该文件的时间
    time_t st_ctime; //最后一次改变该文件状态的时间
    blksize_t st_blksize; //包含该文件的磁盘块的大小
    blkcnt_t st_blocks; //该文件所占的磁盘块
};
```

##### passwd

```c++
#include <sys/types.h> 
#include <pwd.h> 
struct passwd {
   char *pw_name;                /* 用户登录名 */
   char *pw_passwd;              /* 密码(加密后) */
   __uid_t pw_uid;               /* 用户ID */
   __gid_t pw_gid;               /* 组ID */
   char *pw_gecos;               /* 详细用户名 */
   char *pw_dir;                 /* 用户目录 */
   char *pw_shell;               /* Shell程序名 */ 
};
```

##### group

```c++
#include <sys/types.h> 
#include <grp.h> 
struct group {
   char *gr_name;  				/* 组名 */
   char *gr_passwd;  			/* 密码 */
   __gid_t gr_gid;  				/* 组ID */
   char **gr_mem;  				/* 组成员名单 */ 
}
```

##### tm

```c++
struct tm
{
  int tm_sec;                   //分后的秒(0~61)
  int tm_min;                   //小时后的分(0~59)
  int tm_hour;                  //小时(0~23)
  int tm_mday;                  //一个月天数(0~31)
  int tm_mon;                   //一个后的月数(0~11)
  int tm_year;                  //1900年后的年数 Year - 1900.  
  int tm_wday;                  //星期日开始的天数(0~6)
  int tm_yday;                  //从1月1日开始的时间(0~365)
  int tm_isdst;                 //夏令时标志(大于0说明夏令时有效，等于0说明无效，小于0说明信息不可用)
};

```

#### 函数和过程的调用关系图

```flow
op=>operation: main
c0=>condition: null
c1=>condition: -a
c2=>condition: -l
sub1=>subroutine: ls_a()
sub2=>subroutine: ls_l()

op->c1(yes,right)->sub1
c1(no)->c2(no,right)->sub1
c2(yes)->sub2
```





### 调试分析：　　

问题1：在输出文件seekoff时，原本结构体是soff，但是在运行时报错。

原因：新版的依赖库中，设置好的结构体中变量名称改变了

解决方法：查找源码，发现变量名称是seekoff，将代码中的相应位置更正即可

### 测试结果

此程序实现了有关ls的三个功能。分别是`ls`, `ls -a`, `ls -l`

运行结果如下：
<img src="https://s1.vika.cn/space/2022/06/20/a5ec45a00c2c448c875ad0e8dd8a3c8c" alt="image-20220620110208344" style="zoom:50%;" />

如果输入错误的参数：只会提示用法，并结束程序

<img src="https://s1.vika.cn/space/2022/06/20/fbe63efd363b4c4d850b74038e6d5152" alt="image-20220620184411702" style="zoom:50%;" />

### 使用说明

1. 编译cpp文件`g++ -std=c++11 ls.cpp -o a`
2. 执行文件，并在 命令行给出参数`./a ls [a|l]`

## 实验总结

1. 本次实验实现的ls一开始我认为是一个比较基础的功能。但是在实验进行中，我意识到了这个基础的功能仍然需要依赖很多的封装好的库。
1. 程序功能实现并不复杂，但是要了解相应的知识，比如文件结构体都是什么，需要调用什么函数来实现想要的功能等
1. 经历这一次实验之后，对于文件系统部分的内容了解的更加深刻，而且对Linux的基础编程以及ls指令的基本实现流程有了比较清楚的认知

## 附录

```c++
#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>
#include <pwd.h>
#include <grp.h>
#include <time.h>
#include <locale.h>
#include <langinfo.h>
#include <stdio.h>
#include <stdint.h>
#include <iostream>
#include <stdlib.h>

using namespace std;

#define FILE_NAME "."
char *getperm(char *perm, struct stat fileStat);
void ls_l();
void ls_a(bool type_a);

int main(int argc, char *argv[])
{
	printf("Usage: [./a] [null|a|l]\n");

	bool flag, flag_a, flag_l;
	flag = flag_a = flag_l = false;
	if (argc == 1)
	{
		flag = true;
	}
	else if (argc == 2) {
		char* op = argv[1];
		if (*op == 'a')
			flag_a = true;
		else if (*op == 'l') {
			flag_l = true;
		}
	}
	
	if (flag)
		ls_a(flag_a);
	else if (flag_a)
		ls_a(flag_a);
	else if (flag_l)
		ls_l();

	return 0;
}

void ls_a(bool type_a)
{
	DIR *dir;
    struct dirent *ptr;
    dir = opendir(FILE_NAME);
    if (NULL == dir)
    {
        cout << "opendir is NULL" << endl;
        return ;
    }
	while ((ptr = readdir(dir)) != NULL)    // 遍历目录下所有文件
    {
        if(!type_a && *ptr->d_name == '.') // 如果是隐藏文件('.'开头)，则不显示
            continue;
        printf("d_ino: %llu  d_off:%llu d_name: %s\n", ptr->d_ino, ptr->d_seekoff, ptr->d_name);
    }
}

// 获取文件访问权限
char *getperm(char *perm, struct stat fileStat)
{

	if (S_ISLNK(fileStat.st_mode))
	{
		perm[0] = 'l';
	}
	else if (S_ISDIR(fileStat.st_mode))
	{
		perm[0] = 'd';
	}
	else if (S_ISCHR(fileStat.st_mode))
	{
		perm[0] = 'c';
	}
	else if (S_ISSOCK(fileStat.st_mode))
	{
		perm[0] = 's';
	}
	else if (S_ISFIFO(fileStat.st_mode))
	{
		perm[0] = 'p';
	}
	else if (S_ISBLK(fileStat.st_mode))
	{
		perm[0] = 'b';
	}
	else
	{
		perm[0] = '-';
	}
	perm[1] = ((fileStat.st_mode & S_IRUSR) ? 'r' : '-');
	perm[2] = ((fileStat.st_mode & S_IWUSR) ? 'w' : '-');
	perm[3] = ((fileStat.st_mode & S_IXUSR) ? 'x' : '-');
	perm[4] = ((fileStat.st_mode & S_IRGRP) ? 'r' : '-');
	perm[5] = ((fileStat.st_mode & S_IWGRP) ? 'w' : '-');
	perm[6] = ((fileStat.st_mode & S_IXGRP) ? 'x' : '-');
	perm[7] = ((fileStat.st_mode & S_IROTH) ? 'r' : '-');
	perm[8] = ((fileStat.st_mode & S_IWOTH) ? 'w' : '-');
	perm[9] = ((fileStat.st_mode & S_IXOTH) ? 'x' : '-');

	if (fileStat.st_mode & S_ISUID)
	{
		perm[3] = 's';
	}
	else if (fileStat.st_mode & S_IXUSR)
	{
		perm[3] = 'x';
	}
	else
	{
		perm[3] = '-';
	}

	if (fileStat.st_mode & S_ISGID)
	{
		perm[6] = 's';
	}
	else if (fileStat.st_mode & S_IXGRP)
	{
		perm[6] = 'x';
	}
	else
	{
		perm[6] = '-';
	}

	if (fileStat.st_mode & S_ISVTX)
	{
		perm[9] = 't';
	}
	else if (fileStat.st_mode & S_IXOTH)
	{
		perm[9] = 'x';
	}
	else
	{
		perm[9] = '-';
	}

	perm[10] = 0;

	return perm;
}

// ls -l
void ls_l()
{
	DIR *dir;
	struct dirent *dp;
	struct stat statbuf;
	struct passwd *pwd;
	struct group *grp;
	struct tm *tm;
	char datestring[256];
	char modestr[11];

	dir = opendir(FILE_NAME);
	if (NULL == dir)
	{
		cout << "opendir is NULL" << endl;
		return ;
	}
	/* 循环遍历目录条目 */
	while ((dp = readdir(dir)) != NULL)
	{
		printf("d_ino: %llu  d_off:%llu d_name: %s\n", dp->d_ino, dp->d_seekoff, dp->d_name);
		/* 获取条目信息  */
		if (stat(dp->d_name, &statbuf) == -1)
			continue;

		/* 打印出链接的类型、权限和数量*/
		printf("%10.10s", getperm(modestr, statbuf));
		printf("%4d", statbuf.st_nlink);

		/* 如果使用 getpwuid() 找到所有者的名称，则打印出所有者的名称。  */
		if ((pwd = getpwuid(statbuf.st_uid)) != NULL)
			printf(" %-8.8s", pwd->pw_name);
		else
			printf(" %-8d", statbuf.st_uid);

		/* 如果使用 getgrgid() 找到组名，则打印出组名。 */
		if ((grp = getgrgid(statbuf.st_gid)) != NULL)
			printf(" %-8.8s", grp->gr_name);
		else
			printf(" %-8d", statbuf.st_gid);

		/* 打印文件的大小。  */
		printf(" %9jd", (intmax_t)statbuf.st_size);

		tm = localtime(&statbuf.st_mtime);

		/* 获取本地化的日期字符串。 */
		strftime(datestring, sizeof(datestring), nl_langinfo(D_T_FMT), tm);

		printf(" %s %s\n", datestring, dp->d_name);
	}
	return;
}
```





