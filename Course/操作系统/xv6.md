# xv6源码分析报告

> 姓名：
> 班级：
> 学号：
> 指导老师：
> 时间：2021-12-31

# 一、操作系统接口

## 进程和内存

`runcmd[sh.c:58]`

```cpp
void runcmd(struct cmd *cmd)
{
	int p[2];
	struct backcmd *bcmd;
	struct execcmd *ecmd;
	struct listcmd *lcmd;
	struct pipecmd *pcmd;
	struct redircmd *rcmd;

	if(cmd == 0)
	exit();

	switch(cmd->type){
		default:
			panic("runcmd");

		case EXEC:
			ecmd = (struct execcmd*)cmd;
			if(ecmd->argv[0] == 0)
				exit();
			exec(ecmd->argv[0], ecmd->argv);	
            // 执行exec.如果成功将会执行shell中用户输入的指令(如echo),而不是runcmd的
            // 某些之后echo会调用exit,是夫程序从main中的wait返回
            /*
            	fork exec分离特性,在实现I/O重定向中使用到
            */
			printf(2, "exec %s failed\n", ecmd->argv[0]);
			break;

		case REDIR:
			rcmd = (struct redircmd*)cmd;
			close(rcmd->fd);
			if(open(rcmd->file, rcmd->mode) < 0){
				printf(2, "open %s failed\n", rcmd->file);
				exit();
			}
			runcmd(rcmd->cmd);
			break;
            /*
            	Shell中实现 I/O 重定向
            	shell已经fork了子shell, runcmd调用exec加载新的程序
            	open()系统调用的第二个参数在fcntl.h中定义
            */

		case LIST:
			lcmd = (struct listcmd*)cmd;
			if(fork1() == 0)
				runcmd(lcmd->left);
			wait();
			runcmd(lcmd->right);
			break;

		case PIPE:
			pcmd = (struct pipecmd*)cmd;
			if(pipe(p) < 0)
				panic("pipe");
			if(fork1() == 0){
				close(1);
				dup(p[1]);
				close(p[0]);
				close(p[1]);
				runcmd(pcmd->left);
			}
			if(fork1() == 0){
				close(0);
				dup(p[0]);
				close(p[0]);
				close(p[1]);
				runcmd(pcmd->right);
			}
			close(p[0]);
			close(p[1]);
			wait();
			wait();
			break;

		case BACK:
			bcmd = (struct backcmd*)cmd;
			if(fork1() == 0)
				runcmd(bcmd->cmd);
			break;
	}
	exit();
}
```



`Shell[sh.c:145]`

- 主循环while：使用getcmd读取用户的一行输入
- 调用fork(): 创建Shell副本

```cpp
int main(void)
{
	static char buf[100];
	int fd;

	// Ensure that three file descriptors are open.
	while((fd = open("console", O_RDWR)) >= 0){
		if(fd >= 3){
			close(fd);
			break;
		}
	}
    /*
		xv6为每个进程单独维护一个以文件描述符为索引的表。每个进程都有一个从0开始的文件描述符私有空间
		0: 读取数据
		1: 写入输出
		2: 写入错误信息
		
	*/

  // Read and run input commands.
	while(getcmd(buf, sizeof(buf)) >= 0){
        if(buf[0] == 'c' && buf[1] == 'd' && buf[2] == ' '){
            // Chdir must be called by the parent, not the child.
            buf[strlen(buf)-1] = 0;  // chop \n
            if(chdir(buf+3) < 0)
            printf(2, "cannot cd %s\n", buf+3);
            continue;
	}
	if(fork1() == 0)
		runcmd(parsecmd(buf));
		wait();	
	}
	exit();
}
```



## I/O和文件描述符

shell确保自己总是有三个文件描述符打开`[user/sh.c:151]`

```cpp
// Ensure that three file descriptors are open.
while((fd = open("console", O_RDWR)) >= 0){
    if(fd >= 3){
        close(fd);
        break;
    }
}
```

**open**的第二个参数由一组用位表示的标志组成，用来控制**open**的工作。可能的值在文件控制(fcntl)头`(kernel/fcntl.h:1-5)`中定义

```cpp
#define O_RDONLY  0x000	// 读
#define O_WRONLY  0x001	// 写
#define O_RDWR    0x002	// 读写
#define O_CREATE  0x200	// 文件不存在则创建文件
#define O_TRUNC   0x400	// 将文件长度截断为0
```



## 管道

标准输入连接到管道的读取端

```cpp
int p[2];
char *argv[2];
argv[0] = "wc";
argv[1] = 0;
pipe(p);
if (fork() == 0)
{
    close(0);  // 释放文件描述符0
    dup(p[0]); // 复制一个p[0](管道读端)，此时文件描述符0（标准输入）也引用管道读端，故改变了标准输入。
    close(p[0]);
    close(p[1]);
    exec("/bin/wc", argv); // wc 从标准输入读取数据，并写入到参数中的每// 一个文件
}
else
{
    close(p[0]);
    write(p[1], "hello world\n", 12);
    close(p[1]);
}
```



`grep fork sh.c | wc -l`

```cpp
case PIPE:	// 执行shell的子进程创建一个管道来连接管道的左端和右端
    pcmd = (struct pipecmd*)cmd;
    if(pipe(p) < 0)
        panic("pipe");
    if(fork1() == 0){
        close(1);
        dup(p[1]);
        close(p[0]);
        close(p[1]);
        runcmd(pcmd->left);	// 在管道左端(写入端)调用fork和runcmd
    }
    if(fork1() == 0){
        close(0);
        dup(p[0]);
        close(p[0]);
        close(p[1]);
        runcmd(pcmd->right);	// 在右端(读取端)调用fork 和 runcmd
    }
    close(p[0]);
    close(p[1]);
    wait(0);
    wait(0);
    break;
```

管道似乎没有比临时文件拥有更多的功能：

``` shell
echo hello world | wc
```

不使用管道：

``` shell
echo hello world >/tmp/xyz; wc </tmp/xyz
```

管道比临时文件有四个优势:

- 管道会自动清理自己；如果是文件重定向，shell在完成后必须小心地删除/tmp/xyz
- 管道可以传递任意长的数据流，而文件重定向则需要磁盘上有足够的空闲空间来存储所有数据。
- 管道可以分阶段的并行执行，而文件方式则需要在第二个程序开始之前完成第一个程序。
- 如果你要实现进程间的通信，管道阻塞读写比文件的非阻塞语义更有效率。



# 二、操作系统组织

微内核:

<img src="https://s1.vika.cn/space/2022/06/13/08c0ca5b45204ab0b8ae2843c59e3e55" alt="微内核" style="zoom:50%;" />

## xv6的启动过程

当RISC-V计算机开机时，它会初始化自己，并运行一个存储在只读存储器中的**boot loader**。**Boot loader** 将xv6内核加载到内存中。然后，在机器模式下，CPU从 **`_entry`**`（kernel/entry.S:6）`开始执行xv6。RISC-V在禁用分页硬件的情况下启动：虚拟地址直接映射到物理地址。

```shell
_entry:
	# set up a stack for C.
        # stack0 is declared in start.c,
        # with a 4096-byte stack per CPU.
        # sp = stack0 + (hartid * 4096)
        la sp, stack0
        li a0, 1024*4
	csrr a1, mhartid
        addi a1, a1, 1
        mul a0, a0, a1
        add sp, sp, a0
	# jump to start() in start.c
        call start
```

loader将xv6内核加载到物理地址`0x80000000`的内存中。之所以将内核放在`0x80000000`而不是`0x0`，是因为地址范围`0x0`-`0x80000000`包含I/O设备。

**_entry**处的指令设置了一个栈，这样xv6就可以运行C代码。Xv6在文件start.c(kernel/start.c:11)中声明了初始栈的空间，即**stack0**。**_entry**处的指令设置了一个栈，这样xv6就可以运行C代码。Xv6在文件`start.c` `(kernel/start.c:11)`中声明了初始栈的空间，即**stack0**

```cpp
// entry.S needs one stack per CPU.
__attribute__ ((aligned (16))) char stack0[4096 * NCPU];
```

在**_entry**处的代码加载栈指针寄存器sp，地址为**stack0+4096**，也就是栈的顶部，因为RISC-V的栈是向下扩张的。现在内核就拥有了栈，**_entry**调用`start` `(kernel/start.c:21)`，并执行其C代码。

```cpp
// entry.S jumps here in machine mode on stack0.
void start()
{
    // set M Previous Privilege mode to Supervisor, for mret.
    unsigned long x = r_mstatus();
    x &= ~MSTATUS_MPP_MASK;
    x |= MSTATUS_MPP_S;
    w_mstatus(x);

    // set M Exception Program Counter to main, for mret.
    // requires gcc -mcmodel=medany
    w_mepc((uint64)main);

    // disable paging for now.
    w_satp(0);

    // delegate all interrupts and exceptions to supervisor mode.
    w_medeleg(0xffff);
    w_mideleg(0xffff);
    w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);

    // ask for clock interrupts.
    timerinit();

    // keep each CPU's hartid in its tp register, for cpuid().
    int id = r_mhartid();
    w_tp(id);

    // switch to supervisor mode and jump to main().
    asm volatile("mret");
}
```

函数start执行一些只有在机器模式下才允许的配置，然后切换到监督者模式。为了进入监督者模式，RISC-V提供了指令**mret**。这条指令最常用来从上一次的调用中返回，上一次调用从监督者模式到机器模式。**start**并不是从这样的调用中返回，而是把事情设置得像有过这样的调用一样：它在寄存器**mstatus**中把上一次的特权模式设置为特权者模式，它把**main**的地址写入寄存器**mepc**中，把返回地址设置为**main函数**的地址，在特权者模式中把0写入页表寄存器**satp**中，禁用虚拟地址转换，并把所有中断和异常委托给特权者模式。

在进入特权者模式之前，**start**还要执行一项任务：对时钟芯片进行编程以初始化定时器中断。在完成了这些基本管理后，**start**通过调用**mret**  "返回" 到监督者模式。这将导致程序计数器变为`main` `[kernel/main.c:11]`的地址。

```cpp
// start() jumps here in supervisor mode on all CPUs.
void main()
{
    if(cpuid() == 0){
        consoleinit();
        printfinit();
        printf("\n");
        printf("xv6 kernel is booting\n");
        printf("\n");
        kinit();         // physical page allocator
        kvminit();       // create kernel page table
        kvminithart();   // turn on paging
        procinit();      // process table
        trapinit();      // trap vectors
        trapinithart();  // install kernel trap vector
        plicinit();      // set up interrupt controller
        plicinithart();  // ask PLIC for device interrupts
        binit();         // buffer cache
        iinit();         // inode cache
        fileinit();      // file table
        virtio_disk_init(); // emulated hard disk
        userinit();      // first user process
        __sync_synchronize();
        started = 1;
    } else {
        while(started == 0)
            ;
        __sync_synchronize();
        printf("hart %d starting\n", cpuid());
        kvminithart();    // turn on paging
        trapinithart();   // install kernel trap vector
        plicinithart();   // ask PLIC for device interrupts
    }

    scheduler();        
}

```

`main`初始化几个设备和子系统后，它通过调用**`userinit`**`(kernel/proc.c:212)`来创建第一个进程。

```cpp
// Set up first user process.
void userinit(void)
{
    struct proc *p;
    p = allocproc();
    initproc = p;

    // allocate one user page and copy init's instructions
    // and data into it.
    uvminit(p->pagetable, initcode, sizeof(initcode));
    p->sz = PGSIZE;

    // prepare for the very first "return" from kernel to user.
    p->trapframe->epc = 0;      // user program counter
    p->trapframe->sp = PGSIZE;  // user stack pointer

    safestrcpy(p->name, "initcode", sizeof(p->name));
    p->cwd = namei("/");

    p->state = RUNNABLE;

    release(&p->lock);
}
```

第一个进程执行一个用RISC-V汇编编写的小程序**initcode.S**（user/initcode.S:1），它通过调用**exec**系统调用重新进入内核。

```shell
# Initial process that execs /init.
# This code runs in user space.

#include "syscall.h"

# exec(init, argv)
.globl start
start:
        la a0, init
        la a1, argv
        li a7, SYS_exec
        ecall

# for(;;) exit();
exit:
        li a7, SYS_exit
        ecall
        jal exit

# char init[] = "/init\0";
init:
  .string "/init\0"

# char *argv[] = { init, 0 };
.p2align 2
argv:
  .long init
  .long 0

```

**exec**用一个新的程序（本例中是/init）替换当前进程的内存和寄存器。一旦内核完成**exec**，它就会在**/init**进程中返回到用户空间。**`init`** `(user/init.c:15)`在需要时会创建一个新的控制台设备文件，然后以文件描述符0、1和2的形式打开它。然后它在控制台上启动一个shell。这样系统就启动了。

```cpp
int main(void)
{
    int pid, wpid;

    if(open("console", O_RDWR) < 0){
        mknod("console", CONSOLE, 0);
        open("console", O_RDWR);
    }
    dup(0);  // stdout
    dup(0);  // stderr

    for(;;){
        printf("init: starting sh\n");
        pid = fork();
        if(pid < 0){
            printf("init: fork failed\n");
            exit(1);
        }
        if(pid == 0){
            exec("sh", argv);
            printf("init: exec sh failed\n");
            exit(1);
        }

        for(;;){
            // this call to wait() returns if the shell exits,
            // or if a parentless process exits.
            wpid = wait((int *) 0);
            if(wpid == pid){
                // the shell exited; restart it.
                break;
            } else if(wpid < 0){
                printf("init: wait returned an error\n");
                exit(1);
            } else {
                // it was a parentless process; do nothing.
            }
        }
    }
}

```





# 三、页表

## 内核地址空间

`xv6内核内存布局的常量(memlayout.h)`

```cpp
// Memory layout

#define EXTMEM  0x100000            // Start of extended memory
#define PHYSTOP 0xE000000           // Top physical memory
#define DEVSPACE 0xFE000000         // Other devices are at high addresses

// Key addresses for address space layout (see kmap in vm.c for layout)
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#define V2P(a) (((uint) (a)) - KERNBASE)
#define P2V(a) ((void *)(((char *) (a)) + KERNBASE))

#define V2P_WO(x) ((x) - KERNBASE)    // same as V2P, but without casts
#define P2V_WO(x) ((x) + KERNBASE)    // same as P2V, but without casts
```

内核对RAM和内存映射设备寄存器使用"直接映射",将资源和你映射到和他们物理地址相同的虚拟地址上

- 例如`#define KERNBASE 0x80000000`,内核本身在虚拟地址空间和物理内存中的位置都是 `ox80000000`
- 这可以简化读/写物理内存的内核代码. 
  - `fork`为子进程分配用户内存时, 分配器直接返回内存的物理地址
  - `fork`将父进程的用户内存复制到子进程时, 直接使用该地址作为虚拟地址

也有特例的内核虚拟地址不是直接映射

- trampoline页. 被映射在虚拟地址空间的顶端
- 内核栈页. 每个进程都有自己的内核栈, 内核栈被映射到高地址处, xv6在后面留下一个未映射的**守护页**. 如果没有守护页如果栈溢出, 可能会覆盖其他内核的内存

内核将 trampoline 和 text（可执行程序的代码段）映射为有 **PTE_R** 和 **PTE_X** 权限的页.

守护页的映射是无效的（不设置 **PTE_V**）

## 创建地址空间

`创建内核页表[kernel/vm.c:22]`

```CPP
void kvminit()
{
	kernel_pagetable = (pagetable_t) kalloc();
	memset(kernel_pagetable, 0, PGSIZE);
	// uart registers
	kvmmap(UART0, UART0, PGSIZE, PTE_R | PTE_W);
	// virtio mmio disk interface
	kvmmap(VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
	// CLINT
	kvmmap(CLINT, CLINT, 0x10000, PTE_R | PTE_W);
	// PLIC
	kvmmap(PLIC, PLIC, 0x400000, PTE_R | PTE_W);
	// map kernel text executable and read-only.
	kvmmap(KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
	// map kernel data and the physical RAM we'll make use of.
	kvmmap((uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
	// map the trampoline for trap entry/exit to
	// the highest virtual address in the kernel.
	kvmmap(TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
}
```

在机器启动时,main调用kvminit创建内核页表. 调用发生在 xv6 在 RISC-V 启用分页之前，所以地址直接指向物理内存。

- 首先分配一页物理内存来存放根页表页
- 然后调用 **`kvmmap`** 将内核所需要的硬件资源映射到物理地址.(资源包括内核的指令和数据，`KERNBASE` 到 `PHYSTOP（0x86400000）`的物理内存，以及实际上是设备的内存范围)

`kvmmap`调用`mappages`,标记页表项(PTE)为有效

```CPP
void kvmmap(uint64 va, uint64 pa, uint64 sz, int perm)
{
	if(mappages(kernel_pagetable, va, sz, pa, perm) != 0)
		panic("kvmmap");
}
```

```cpp
int mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
	uint64 a, last;
	pte_t *pte;
	a = PGROUNDDOWN(va);
	last = PGROUNDDOWN(va + size - 1);
	for(;;){
		if((pte = walk(pagetable, a, 1)) == 0)
			return -1;
		if(*pte & PTE_V)
			panic("remap");
		*pte = PA2PTE(pa) | perm | PTE_V;
		if(a == last)
			break;
		a += PGSIZE;
		pa += PGSIZE;
	}
	return 0;
}
```

**`walk (kernel/vm.c:72)`**模仿 RISC-V 分页硬件查找虚拟地址的 PTE

```cpp
pte_t *walk(pagetable_t pagetable, uint64 va, int alloc)
{
	if(va >= MAXVA)
	panic("walk");
	/*
		每次降1级来查找三级页表
		也就是每次降低 9 位. 总共27位, 高9位标识根页表, 中间9位标识下一级页表, 第9位标识最后一级PTE
	*/
	for(int level = 2; level > 0; level--) {
		pte_t *pte = &pagetable[PX(level, va)];
		if(*pte & PTE_V) {	// 如果 PTE 无效，那么所需的物理页还没有被分配
			pagetable = (pagetable_t)PTE2PA(*pte);
		} else {
            // alloc 参数被设置 true，walk 会分配一个新的页表页，并把它的物理地址放在 PTE 中
			if(!alloc || (pagetable = (pde_t*)kalloc()) == 0) 
				return 0;
			memset(pagetable, 0, PGSIZE);
			*pte = PA2PTE(pagetable) | PTE_V;
		}
	}
	return &pagetable[PX(0, va)];	// 返回PTE在树的最低层中的地址
}
```

**`main`** 调用 **`kvminithart`** `(kernel/vm.c:53) `来映射内核页表

```cpp
void kvminithart()
{
	w_satp(MAKE_SATP(kernel_pagetable));
    /*
    	将根页表页的物理地址写入寄存器 **satp** 中。
    	在这之后，CPU 将使用内核页表翻译地址。
    	由于内核使用唯一映射，所以指令的虚拟地址将映射到正确的物理内存地址。
    */
	sfence_vma();
}
```

**`main`** 调用`procinit (kernel/proc.c:26)` ，为每个进程分配一个内核栈。

```cpp
void procinit(void)
{
	struct proc *p;

	initlock(&pid_lock, "nextpid");
	for(p = proc; p < &proc[NPROC]; p++) {
		initlock(&p->lock, "proc");
		// Allocate a page for the process's kernel stack.
		// Map it high in memory, followed by an invalid
		// guard page.
		char *pa = kalloc();
		if(pa == 0)
		panic("kalloc");
		uint64 va = KSTACK((int) (p - proc));
        /*
        	将每个栈映射在 KSTACK 生成的虚拟地址上，为栈守护页留下了空间
        */
		kvmmap(va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
		p->kstack = va;
	}
	kvminithart();
    /*
        Kvmmap 将对应的PTE加入到内核页表中
        然后调用 kvminithart 将内核页表重新加载到 satp 中，这样硬件就知道新的 PTE 了
    */
}
```

`sfence.vma(kernel/trampoline.S:79)`刷新当前 CPU 的 TLB

## 物理内存分配器

分配器的数据结构是一个可供分配的物理内存页的**空闲链表**，每个空闲页的链表元素是一个结构体 `struct run` `(kernel/kalloc.c:17)`

```cpp
struct run {
  struct run *next;
};
```

它把每个空闲页的 `run` 结构体存储在空闲页自身里面

空闲链表由一个**自旋锁**保护`（kernel/kalloc.c:21-24）`

```cpp
struct {
	struct spinlock lock;
	struct run *freelist;
} kmem;
```

**`main`** 调用` kinit `来初始化分配器`[kernel/kalloc.c:27]`

```cpp
void kinit()
{
    initlock(&kmem.lock, "kmem");
    freerange(end, (void*)PHYSTOP);
}
```

**`kfree`**`[kernel/kalloc.c:47]`将被释放的内存中的每个字节设置为 1. 使得释放内存后使用内存的代码（使用悬空引用）将会读取垃圾而不是旧的有效内容

```cpp
void kfree(void *pa)
{
	struct run *r;

	if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
		panic("kfree");

	// Fill with junk to catch dangling refs.
	memset(pa, 1, PGSIZE);

	r = (struct run*)pa;
    // 将 pa（物理地址）转为指向结构体 run 的指针

	acquire(&kmem.lock);
	r->next = kmem.freelist;
	kmem.freelist = r;
    // 在 r->next 中记录空闲链表之前的节点，并将释放列表设为 r
	release(&kmem.lock);
}
```



## 进程地址空间

每个进程都有一个单独的页表，当 xv6 在进程间切换时，也会改变页表。如图 2.3 所示，一个进程的用户内存从虚拟地址 0 开始，可以增长到 `MAXVA(kernel/riscv.h:348)`，原则上允许一个进程寻址 256GB 的内存。

```cpp
#define MAXVA (1L << (9 + 9 + 9 + 12 - 1))
```

## sbrk

**`Sbrk`** 是一个进程收缩或增长内存的系统调用。该系统调用由函数`growproc(kernel/proc.c:239)`

```cpp
int growproc(int n)
{
	uint sz;
	struct proc *p = myproc();

	sz = p->sz;
	if(n > 0){
	if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
		return -1;
	}
	} else if(n < 0) {
		sz = uvmdealloc(p->pagetable, sz, sz + n);
	}
	p->sz = sz;
	return 0;
}
```

## exec

**Exec** 创建一个地址空间的用户部分. 读取储存在文件系统上的文件用来初始化一个地址空间的用户部分

`Exec (kernel/exec.c:13)`使用 `namei (kernel/exec.c:26)`打开二进制文件路径

```cpp
if((ip = namei(path)) == 0){
    end_op();
    return -1;
}
```

然后读取文件的`ELF`头. `[kernel/elf.h]` 正确类型的ELF二进制文件需要以四个字节的“魔法数字” `0x7F`、`E`、`L`、`F`或 `ELF_MAGIC` `[kernel/elf.h:3]`开始

```cpp
#define ELF_MAGIC 0x464C457FU  // "\x7FELF" in little endian
```

```cpp
struct elfhdr {
    uint magic;  // must equal ELF_MAGIC
    uchar elf[12];
    ushort type;
    ushort machine;
    uint version;
    uint64 entry;
    uint64 phoff;
    uint64 shoff;
    uint flags;
    ushort ehsize;
    ushort phentsize;
    ushort phnum;
    ushort shentsize;
    ushort shnum;
    ushort shstrndx;
};
```

后面是程序段头`proghdr (kernel/elf.h:25)` 描述了一个必须加载到内存中的程序段

```cpp
struct proghdr {
    uint32 type;
    uint32 flags;
    uint64 off;
    uint64 vaddr;
    uint64 paddr;
    uint64 filesz;
    uint64 memsz;
    uint64 align;
};
```

**`Exec`** 

- 使用 **`proc_pagetable(kernel/exec.c:38)`**分配一个没有使用的页表

  ```cpp
  if((pagetable = proc_pagetable(p)) == 0)
      goto bad;
  ```

- 使用 **`uvmalloc (kernel/exec.c:52)`**为每一个 ELF 段分配内存

  ```cpp
  if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
        goto bad;
  ```

- 通过 **`loadseg (kernel/exec.c:10  :136)`**加载每一个段到内存中。

  ```cpp
  static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);
  ```

  ```CPP
  static int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
  {
      uint i, n;
      uint64 pa;
      if((va % PGSIZE) != 0)
          panic("loadseg: va must be page aligned");
  
      for(i = 0; i < sz; i += PGSIZE){
          pa = walkaddr(pagetable, va + i);
          // loadseg 使用 walkaddr 找到分配内存的物理地址，在该地址写入 ELF 段的每一页
          if(pa == 0)
              panic("loadseg: address should exist");
          if(sz - i < PGSIZE)
              n = sz - i;
          else
              n = PGSIZE;
          if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
          // 页的内容通过 readi 从文件中读取。
              return -1;
      }
      return 0;
  }
  ```



# 四、异常和系统调用

## Calling system calls

在内核中实现exec系统调用

用户代码将**exec**的参数放在寄存器**a0**和**a1**中，并将系统调用号放在**a7**中。系统调用号与函数指针表**`syscalls`**数组`(kernel/syscall.c:108)`中的项匹配。

```cpp
static uint64 (*syscalls[])(void) = {
    [SYS_fork]    sys_fork,
    [SYS_exit]    sys_exit,
    [SYS_wait]    sys_wait,
    [SYS_pipe]    sys_pipe,
    [SYS_read]    sys_read,
    [SYS_kill]    sys_kill,
    [SYS_exec]    sys_exec,
    [SYS_fstat]   sys_fstat,
    [SYS_chdir]   sys_chdir,
    [SYS_dup]     sys_dup,
    [SYS_getpid]  sys_getpid,
    [SYS_sbrk]    sys_sbrk,
    [SYS_sleep]   sys_sleep,
    [SYS_uptime]  sys_uptime,
    [SYS_open]    sys_open,
    [SYS_write]   sys_write,
    [SYS_mknod]   sys_mknod,
    [SYS_unlink]  sys_unlink,
    [SYS_link]    sys_link,
    [SYS_mkdir]   sys_mkdir,
    [SYS_close]   sys_close,
};
```

**ecall**指令进入内核，执行**uservec**、**usertrap**，然后执行**syscall**



**`syscall`** `(kernel/syscall.c:133)`从**`trapframe`**中的a7中得到系统调用号，并其作为索引在**syscalls**查找相应函数。

```cpp
void syscall(void)
{
    int num;
    struct proc *p = myproc();

    num = p->trapframe->a7;
    if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
        p->trapframe->a0 = syscalls[num]();
    } else {
        printf("%d %s: unknown sys call %d\n", p->pid, p->name, num);
        p->trapframe->a0 = -1;
    }
}
```

对于第一个系统调用**exec**，a7将为**`SYS_exec(kernel/syscall.h:8)`**，这会让**syscall**调用**exec**的实现函数**sys_exec**。

```cpp
#define SYS_exec    7
```

当系统调用函数返回时，**syscall**将其返回值记录在**p->trapframe->a0**中。用户空间的**exec()**将会返回该值，因为RISC-V上的C调用通常将返回值放在**a0**中。

系统调用返回:

- 负数表示错误
- 0或正数表示成功

如果系统调用号无效，**syscall**会打印错误并返回1。



# 五、中断和设备驱动

需要操作系统关注的设备通常可以被配置为产生中断，这是trap的一种类型。内核trap处理代码可以知道设备何时引发了中断，并调用驱动的中断处理程序

**`devintr`**`(kernel/trap.c:177)`

```cpp
int devintr()
{
    uint64 scause = r_scause();
    if((scause & 0x8000000000000000L) && (scause & 0xff) == 9){
        // this is a supervisor external interrupt, via PLIC.
        // irq indicates which device interrupted.
        int irq = plic_claim();
        if(irq == UART0_IRQ){
            uartintr();
        } else if(irq == VIRTIO0_IRQ){
            virtio_disk_intr();
        } else if(irq){
            printf("unexpected interrupt irq=%d\n", irq);
        }
        // the PLIC allows each device to raise at most one
        // interrupt at a time; tell the PLIC the device is
        // now allowed to interrupt again.
        if(irq)
            plic_complete(irq);
        return 1;
    } else if(scause == 0x8000000000000001L){
        // software interrupt from a machine-mode timer interrupt,
        // forwarded by timervec in kernelvec.S.
        if(cpuid() == 0){
            clockintr();
        }
        // acknowledge the software interrupt by clearing
        // the SSIP bit in sip.
        w_sip(r_sip() & ~2);
        return 2;
    } else {
        return 0;
    }
}
```

与驱动交互的UART硬件是由QEMU仿真的16550芯片. 

UART硬件在软件看来是一组**内存映射**的控制寄存器。也就是说，有一些RISC-V硬件的物理内存地址会关联到UART设备，因此加载和存储与设备硬件而不是RAM交互。UART的内存映射地址从0x10000000开始，即`UART0[kernel/memlayout.h:21]`

```cpp
#define UART0 0x10000000L
```

每个UART控制存器的宽度是一个字节。它们与UART0的偏移量定义在`(kernel/uart.c:22)`

```cpp
#define RHR 0                 // receive holding register (for input bytes)
#define THR 0                 // transmit holding register (for output bytes)
#define IER 1                 // interrupt enable register
#define IER_TX_ENABLE (1<<0)
#define IER_RX_ENABLE (1<<1)
#define FCR 2                 // FIFO control register
#define FCR_FIFO_ENABLE (1<<0)
#define FCR_FIFO_CLEAR (3<<1) // clear the content of the two FIFOs
#define ISR 2                 // interrupt status register
#define LCR 3                 // line control register
#define LCR_EIGHT_BITS (3<<0)
#define LCR_BAUD_LATCH (1<<7) // special mode to set baud rate
#define LSR 5                 // line status register
#define LSR_RX_READY (1<<0)   // input is waiting to be read from RHR
#define LSR_TX_IDLE (1<<5)    // THR can accept another character to send
```

- **LSR**寄存器中一些位表示是否有输入字符在等待软件读取

- 这些字符（如果有的话）可以从**RHR**寄存器中读取

- 每次读取一个字符，UART硬件就会将其从内部等待字符的FIFO中删除，并在FIFO为空时清除**LSR**中的就绪位

- 果软件向**THR**写入一个字节，UART就会发送该字节。

Xv6的**`main`**调用`consoleinit` `[kernel/console.c:184]`来初始化UART硬件

```cpp
void
consoleinit(void)
{
    initlock(&cons.lock, "cons");
    uartinit();
    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    devsw[CONSOLE].write = consolewrite;
}
```

当UART接收到一个字节的输入时，就产生一个接收中断，当UART每次完成发送一个字节的输出时，产生一个***传输完成(transmit complete)***中断`(kernel/uart.c:53)`。

```cpp
void uartinit(void)
{
    // disable interrupts.
    WriteReg(IER, 0x00);
    // special mode to set baud rate.
    WriteReg(LCR, LCR_BAUD_LATCH);
    // LSB for baud rate of 38.4K.
    WriteReg(0, 0x03);
    // MSB for baud rate of 38.4K.
    WriteReg(1, 0x00);
    // leave set-baud mode,
    // and set word length to 8 bits, no parity.
    WriteReg(LCR, LCR_EIGHT_BITS);
    // reset and enable FIFOs.
    WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    // enable transmit and receive interrupts.
    WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    initlock(&uart_tx_lock, "uart");
}
```

shell通过**`init.c`**`(user/init.c:19)`打开的文件描述符从控制台读取

```cpp
if(open("console", O_RDWR) < 0){
    mknod("console", CONSOLE, 0);
    open("console", O_RDWR);
}
```

对**`read`**的系统调用通过内核到达**`consoleread`**`[kernel/console.c:82]`

```cpp
int consoleread(int user_dst, uint64 dst, int n)
{
    uint target;
    int c;
    char cbuf;
    target = n;
    acquire(&cons.lock);
    while(n > 0){
        // wait until interrupt handler has put some
        // input into cons.buffer.
        // 通过中断方式, 等待输入的到来
        while(cons.r == cons.w){	// 输入到缓冲区的cons.buf
            if(myproc()->killed){
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);	// 此时输入不是完整的一行,另外调用read进程进入sleep等待
        }
        c = cons.buf[cons.r++ % INPUT_BUF];
        if(c == C('D')){  // end-of-file
            if(n < target){
                // Save ^D for next time, to make sure
                // caller gets a 0-byte result.
                cons.r--;
            }
            break;
        }
        // copy the input byte to the user-space buffer.
        cbuf = c;
        if(either_copyout(user_dst, dst, &cbuf, 1) == -1)	// 复制到用户空间
            break;

        dst++;
        --n;

        if(c == '\n'){
            // 有换行符证明一整行到达, 返回用户级read()进程
            break;
        }
    }
    release(&cons.lock);
    return target - n;
}
```

**`consoleread`**等待输入的到来(通过中断)，输入会被缓冲在**`cons.buf`**，然后将输入复制到用户空间，再然后(在一整行到达后)返回到用户进程。

如果用户还没有输入完整的行，任何调用了**`read`**进程将在**`sleep`**中等待`(kernel/console.c:98)`

当用户键入一个字符时，UART硬件向RISC-V抛出一个中断，从而激活xv6的**`trap`**处理程序。trap处理程序调用`devintr(kernel/trap.c:177)`，它查看RISC-V的**`scause`**寄存器，发现中断来自一个外部设备。

```cpp
// 检查是一个外部中断或者是软件中断, 并且处理它.
int devintr()
{
    uint64 scause = r_scause();

    if((scause & 0x8000000000000000L) && (scause & 0xff) == 9){	// 查看scause寄存器
        // this is a supervisor external interrupt, via PLIC.
        // irq indicates which device interrupted.
        int irq = plic_claim();	// 向硬件单元询问哪个设备产生了终端中断.

        if(irq == UART0_IRQ){	// UART产生中断
            uartintr();		// 调用uartintr
        } else if(irq == VIRTIO0_IRQ){
            virtio_disk_intr();
        } else if(irq){
            printf("unexpected interrupt irq=%d\n", irq);
        }

        // the PLIC allows each device to raise at most one
        // interrupt at a time; tell the PLIC the device is
        // now allowed to interrupt again.
        if(irq)
            plic_complete(irq);
        return 1;	// 返回1是时钟中断
        
    } else if(scause == 0x8000000000000001L){
        // software interrupt from a machine-mode timer interrupt,
        // forwarded by timervec in kernelvec.S.

        if(cpuid() == 0){
            clockintr();
        }

        // acknowledge the software interrupt by clearing
        // the SSIP bit in sip.
        w_sip(r_sip() & ~2);

        return 2;	// 返回2是其他设备
    } else {
        return 0;	// 0是不可识别
    }
}
```

然后它向一个叫做PLIC的硬件单元询问哪个设备中断了`(kernel/trap.c:186)`。如果是UART，**`devintr`**调用**`uartintr`**。



```cpp
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void uartintr(void)
{
    // read and process incoming characters.
    while(1){
        int c = uartgetc();	// 从UART读取正在等待的字符
        if(c == -1)
            break;
        consoleintr(c);	// 交给consoleintr
    }

    // send buffered characters.
    acquire(&uart_tx_lock);
    uartstart();
    release(&uart_tx_lock);
}
```

```cpp
// the console input interrupt handler.
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    acquire(&cons.lock);
    switch(c){
        case C('P'):  // Print process list.
            procdump();
            break;
        case C('U'):  // Kill line.
            while(cons.e != cons.w &&
                  cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
                cons.e--;
                consputc(BACKSPACE);
            }
            break;
        case C('H'): // Backspace
        case '\x7f':
            if(cons.e != cons.w){
                cons.e--;
                consputc(BACKSPACE);
            }
            break;
        default:
            if(c != 0 && cons.e-cons.r < INPUT_BUF){
                c = (c == '\r') ? '\n' : c;
                // echo back to the user.
                consputc(c);
                // store for consumption by consoleread().
                cons.buf[cons.e++ % INPUT_BUF] = c;
                if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
                    // wake up consoleread() if a whole line (or end-of-file)
                    // has arrived.
                    cons.w = cons.e;
                    wakeup(&cons.r);
                }
            }
            break;
    }
    release(&cons.lock);
}
```

不会等待输入字符，因为以后的输入会引发一个新的中断.

**`consoleintr`**的工作是将中输入字符积累**`cons.buf`**中，直到有一行字符。 **`consoleintr`**会特别处理退格键和其他一些字符。当一个新行到达时，**`consoleintr`**会唤醒一个等待的**`consoleread`**

向控制台写数据的**`write`**系统调用最终会到达**`uartputc`**`(kernel/uart.c:87)`。设备驱动维护了一个输出缓冲区(**`uart_tx_buf`**)，这样写进程就不需要等待UART完成发送

```cpp
// 添加一个字符到输出缓冲区并告诉UART开始发送
// because it may block, it can't be called from interrupts; 
// it's only suitable for use by write().
void uartputc(int c)
{
    acquire(&uart_tx_lock);

    if(panicked){
        for(;;)
            ;
    }
    while(1){
        if(((uart_tx_w + 1) % UART_TX_BUF_SIZE) == uart_tx_r){
            // buffer is full.
            // wait for uartstart() to open up space in the buffer.
            sleep(&uart_tx_r, &uart_tx_lock); 	// 如果缓冲区空,则阻塞
        } else {
            uart_tx_buf[uart_tx_w] = c;
            uart_tx_w = (uart_tx_w + 1) % UART_TX_BUF_SIZE;
            uartstart();
            release(&uart_tx_lock);	// 释放
            return;
        }
    }
}
```

定时器中断`(kernel/start.c:57)`

```cpp
// set up to receive timer interrupts in machine mode,
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void timerinit()
{
    // each CPU has a separate source of timer interrupts.
    int id = r_mhartid();

    // ask the CLINT for a timer interrupt.
    int interval = 1000000; // cycles; about 1/10th second in qemu.
    *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;

    // prepare information in scratch[] for timervec.
    // scratch[0..3] : space for timervec to save registers.
    // scratch[4] : address of CLINT MTIMECMP register.
    // scratch[5] : desired interval (in cycles) between timer interrupts.
    uint64 *scratch = &mscratch0[32 * id];
    scratch[4] = CLINT_MTIMECMP(id);
    scratch[5] = interval;
    w_mscratch((uint64)scratch);

    // set the machine-mode trap handler.
    w_mtvec((uint64)timervec);

    // enable machine-mode interrupts.
    w_mstatus(r_mstatus() | MSTATUS_MIE);

    // enable machine-mode timer interrupts.
    w_mie(r_mie() | MIE_MTIE);
}
```



# 六、锁

xv6有两种锁: spinlock & sleeplock

## 自旋锁 spinlock

自旋锁的结构`spinlock` `(kernel/spinlock.h:2)`

```cpp
// Mutual exclusion lock.
struct spinlock {
    uint locked;       // Is the lock held?
	// 当锁可获得时，locked为零，当锁被持有时，locked为非零
    // For debugging:
    char *name;        // Name of lock.
    struct cpu *cpu;   // The cpu holding the lock.
};
```

所以在锁为0时, 要去获得一个锁, 然后将锁设置为1. 那么判断为0和设置为1的两个步骤必须作为一个**原子**, 否则可能有多个CPU同时执行这一步骤, 从而不同的CPU同时持有锁, 并没有互斥属性

`acquire` `[kernel/spinlock.c:22]`

- 使用了可移植的C库调用`__sync_lock_test_and_set`，它本质上为`amoswap`指令;
- 返回值是`lk->locked`的旧(被交换出来的)内容。
- `acquire`函数循环交换，重试(旋转)直到获取了锁。
- 每一次迭代都会将1交换到`lk->locked`中，并检查之前的值;
  - 如果之前的值为0，那么我们已经获得了锁，并且交换将`lk->locked`设置为1。
  - 如果之前的值是1，那么其他CPU持有该锁，而我们原子地将1换成`lk->locked`并没有改变它的值。

```cpp
void acquire(struct spinlock *lk)
{
    push_off(); // disable interrupts to avoid deadlock.
    if(holding(lk))
        panic("acquire");
    // On RISC-V, sync_lock_test_and_set turns into an atomic swap:
    //   a5 = 1
    //   s1 = &lk->locked
    //   amoswap.w.aq a5, a5, (s1)
    while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
        ;
    // Tell the C compiler and the processor to not move loads or stores
    // past this point, to ensure that the critical section's memory
    // references happen strictly after the lock is acquired.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
    // Record info about lock acquisition for holding() and debugging.
    lk->cpu = mycpu();
}
```

一旦锁被获取，`acquire`就会记录获取该锁的CPU，这方便调试。`lk->cpu`字段受到锁的保护，只有在持有锁的时候才能改变。

函数`release`(kernel/spinlock.c:47)与`acquire`相反:它清除`lk->cpu`字段，然后释放锁。

- 从概念上讲，释放只需要给`lk->locked`赋值为0。
- C标准允许编译器用多条存储指令来实现赋值，所以C赋值对于并发代码来说可能是非原子性的。
- 相反，`release`使用C库函数`__sync_lock_release`执行原子赋值。这个函数也是使用了RISC-V的`amoswap`指令。

```cpp
// Release the lock.
void release(struct spinlock *lk)
{
    if(!holding(lk))
        panic("release");

    lk->cpu = 0;
    // Tell the C compiler and the CPU to not move loads or stores
    // past this point, to ensure that all the stores in the critical
    // section are visible to other CPUs before the lock is released,
    // and that loads in the critical section occur strictly before
    // the lock is released.
    // On RISC-V, this emits a fence instruction.
    __sync_synchronize();
    // Release the lock, equivalent to lk->locked = 0.
    // This code doesn't use a C assignment, since the C standard
    // implies that an assignment might be implemented with
    // multiple store instructions.
    // On RISC-V, sync_lock_release turns into an atomic swap:
    //   s1 = &lk->locked
    //   amoswap.w zero, zero, (s1)
    __sync_lock_release(&lk->locked);
    pop_off();
}
```

在分配和释放的时候就使用了锁. 否则很有可能出错

`kalloc` `[kernel/kalloc.c:69]`

```cpp
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *kalloc(void)
{
  struct run *r;

  acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  release(&kmem.lock);

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
  return (void*)r;
}
```



`kfree` `[kernel/kalloc.c:47]`

```cpp
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
	struct run *r;

	if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
		panic("kfree");

	// Fill with junk to catch dangling refs.
	memset(pa, 1, PGSIZE);

	r = (struct run*)pa;

	acquire(&kmem.lock);
	r->next = kmem.freelist;
	kmem.freelist = r;
	release(&kmem.lock);
}
```



## 睡眠锁 sleeplock

睡眠锁的结构 `sleeplock` `[kernel/sleeplock.h]` 

```cpp
// Long-term locks for processes
struct sleeplock {
    uint locked;       // Is the lock held?
    struct spinlock lk; // spinlock protecting this sleep lock

    // For debugging:
    char *name;        // Name of lock.
    int pid;           // Process holding lock
};
```



有时xv6需要长时间保持一个锁。例如，文件系统（第8章）在磁盘上读写文件内容时，会保持一个文件的锁定，这些磁盘操作可能需要几十毫秒。

- 如果另一个进程想获取一个自旋锁，那么保持那么长的时间会导致浪费，因为第二个进程在等待锁的同时会浪费CPU很长时间。

- 自旋锁的另一个缺点是，一个进程在保留自旋锁的同时不能释放CPU并将自身转变为就绪态；

在拥有自旋锁的进程等待磁盘时，其他进程可以使用CPU是更加合理且高效的。但是在持有自旋锁时释放CPU是非法的，因为如果第二个线程再试图获取自旋锁，可能会导致死锁；

由于`acquire`并不能释放CPU，第二个进程的等待可能会阻止第一个进程运行和释放锁。

Xv6睡眠锁(sleeplock):  在持有锁的同时释放CPU也会违反在持有自旋锁时中断必须关闭的要求。在等待获取的同时让CPU可以进行别的工作，并在锁被持有时允许释放CPU，同时开放中断。

- `acquiresleep` `[kernel/sleeplock.c:22]`在等待时产生CPU

  ```cpp
  void acquiresleep(struct sleeplock *lk)
  {
      acquire(&lk->lk);
      while (lk->locked) {
          sleep(lk, &lk->lk);
      }
      lk->locked = 1;
      lk->pid = myproc()->pid;
      release(&lk->lk);
  }
  ```

- 在高层次上，睡眠锁有一个由`spinlock`保护的锁定字段，`acquiresleep`调用`sleep`原子性地让渡CPU并释放`spinlock`。

- 所以在`acquireleep`等待的时候，其他线程可以执行。

因为睡眠锁使中断处于启用状态，所以它们不能用于中断处理程序中。由于`acquiresleep`可能会释放CPU，所以睡眠锁不能在自旋锁的核心代码中使用（尽管自旋锁可以在睡眠锁的核心代码中使用）。



==自旋锁最适合于短的关键部分，因为等待它们会浪费CPU时间；睡眠锁对长的操作很有效。==



# 七、调度

函数**`swtch`**执行内核线程切换的保存和恢复。

- **swtch**并不直接知道线程，只是保存和恢复寄存器组，称为***上下文(context)***。

- 当一个进程要放弃CPU的时候，进程的内核线程会调用**swtch**保存自己的上下文并返回到调度器上下文。

- 每个上下文都包含在一个结构体 **context(kernel/proc.h:2)**中，它本身包含在进程的结构体**proc**或CPU的结构体**cpu**中。

  ```cpp
  // 保存寄存器, 为了内核的上下文切换
  struct context {
      uint64 ra;	// ra寄存器: 函数return地址。
      uint64 sp;	// 栈顶指针寄存器
      // callee-saved
      uint64 s0;
      uint64 s1;
      uint64 s2;
      uint64 s3;
      uint64 s4;
      uint64 s5;
      uint64 s6;
      uint64 s7;
      uint64 s8;
      uint64 s9;
      uint64 s10;
      uint64 s11;
  };
  ```



**Swtch**有两个参数：**struct context old**和**struct context new**。它将当前的寄存器保存在old中，从new中加载寄存器，然后返回。

根据XV6的源代码，xv6中只有两处调用switch：

 ``` c
void
sched(void)
{
    // ...
    swtch(&p->context, &mycpu()->scheduler);
    // ...
}
 ```

``` c
void
scheduler(void)
{
    // ...
    swtch(&c->scheduler, &p->context);
    // ...
}
```

**这里没有两个用户进程之间的直接切换，只有用户进程和调度器线程之间的切换**：

- xv6中要主动让出cpu的进程都是通过调用exit/sleep/yield，间接调用sched，从而实现切换到调度器线程
- 再由调度器线程选出并切换到一个runnable。



# 八、文件系统

xv6文件系统的结构:

![](https://s1.vika.cn/space/2022/12/12/7cf4575cd80f4bef83433e817ce54b10)



## Buffer cache

buffer缓存有两项工作:[代码见`bio.c`]

1. 同步访问磁盘块，以确保磁盘块在内存中只有一个buffer缓存，并且一次只有一个内核线程能使用该buffer缓存
2. 缓存使用较多的块，这样它们就不需要从慢速磁盘中重新读取

buffer缓存是一个由buffer组成的双端链表。

函数**binit**用静态数组**buf**初始化这个链表， **binit**在启动时由**main**`(kernel/main.c:27)`调用.(下方第15行)

```cpp
if(cpuid() == 0){
    consoleinit();
    printfinit();
    printf("\n");
    printf("xv6 kernel is booting\n");
    printf("\n");
    kinit();         // physical page allocator
    kvminit();       // create kernel page table
    kvminithart();   // turn on paging
    procinit();      // process table
    trapinit();      // trap vectors
    trapinithart();  // install kernel trap vector
    plicinit();      // set up interrupt controller
    plicinithart();  // ask PLIC for device interrupts
    binit();         // buffer cache
    iinit();         // inode cache
    fileinit();      // file table
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
} 
```

buffer有两个与之相关的状态字段。

- **valid**表示是否包含该块的副本（是否从磁盘读取了数据）。
- **disk**表示缓冲区的内容已经被修改需要被重新写入磁盘。



buffer缓存的主要接口包括**`bread`**和**`bwrite`**:

- bread返回一个在内存中可以读取和修改的块副本**buf**

  ```cpp
  // Return a locked buf with the contents of the indicated block.
  struct buf* bread(uint dev, uint blockno)
  {
      struct buf *b;
      b = bget(dev, blockno);
      if(!b->valid) {
          virtio_disk_rw(b, 0);
          b->valid = 1;
      }
      return b;
  }
  ```

  ​	**`bget`** `(kernel/bio.c:59)`

  ```cpp
  static struct buf*bget(uint dev, uint blockno)
  {
      struct buf *b;
  
      acquire(&bcache.lock);	// 持有锁
  
      // Is the block already cached?
      // 扫描buffer链表，寻找给定设备号和扇区号来查找缓冲区`(kernel/bio.c:65-73)`
      for(b = bcache.head.next; b != &bcache.head; b = b->next){
          if(b->dev == dev && b->blockno == blockno){	// 如果存在
              b->refcnt++;
              release(&bcache.lock);	// 释放锁
              acquiresleep(&b->lock);	// 获取该buffer的sleep-lock
              return b;	// 返回被锁定的buffer
          }
      }
  
      // Not cached.
      // 如果给定的扇区没有缓存的buffer，bget必须生成一个，可能会使用一个存放不同扇区的buffer
      // Recycle the least recently used (LRU) unused buffer.
      for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
          /*
          	再次扫描buffer链表，寻找没有被使用的buffer(b->refcnt = 0)
          	bget修改buffer元数据，记录新的设备号和扇区号，并获得其sleep-lock
          */
          if(b->refcnt == 0) {
              b->dev = dev;
              b->blockno = blockno;
              b->valid = 0;	
              // b->valid = 0 确保bread从磁盘读取块数据，而不是错误地使用buffer之前的内容。
              b->refcnt = 1;
              release(&bcache.lock);	// 释放锁
              acquiresleep(&b->lock);
              return b;
          }
      }
      panic("bget: no buffers");
  }
  ```

  每个磁盘扇区最多只能有一个buffer，以确保写操作对读取者可见，也因为文件系统需要使用buffer上的锁来进行同步。

  - **Bget**通过从第一次循环检查块是否被缓存
  - 第二次循环来生成一个相应的buffer（通过设置**dev**、**blockno**和**refcnt**）

  在进行这两步操作时，需要一直持有**bache.lock** 。持有**bache.lock**会保证上面两个循环在整体上是==原子==的。

  **bget**在**bcache.lock**保护的临界区之外获取buffer的sleep-lock是安全的，因为非零的**b->refcnt**可以防止缓冲区被重新用于不同的磁盘块。

  - sleep-lock保护的是块的缓冲内容的读写
  - bcache.lock保护被缓存块的信息。

  如果所有buffer都在使用，那么太多的进程同时在执行文件相关的系统调用，bget就会**`panic`**。
  一个更好的处理方式可能是睡眠，直到有buffer空闲，尽管这时有可能出现死锁。

  [`panic`: 尽可能把它此时能获取的全部信息都打印出来]

  ```cpp
  void panic(char *s)
  {
      pr.locking = 0;
      printf("panic: ");
      printf(s);
      printf("\n");
      panicked = 1; // freeze uart output from other CPUs
      for(;;)
          ;
  }
  ```

  

- **bwrite**将修改后的buffer写到磁盘上相应的块。

  一旦**bread**读取了磁盘内容（如果需要的话）并将缓冲区返回给它的调用者，调用者就独占该buffer，可以读取或写入数据。

  如果调用者修改了buffer，它必须在释放buffer之前调用**`bwrite`**将修改后的数据写入磁盘。

  ```cpp
  // Write b's contents to disk.  Must be locked.
  void bwrite(struct buf *b)
  {
      if(!holdingsleep(&b->lock))
          panic("bwrite");
      virtio_disk_rw(b, 1);	// 调用virtio_disk_rw与磁盘硬件交互。
  }
  ```

  

内核线程在使用完一个buffer后，必须通过调用**brelse**释放它。

```cpp
// Release a locked buffer.
// Move to the head of the most-recently-used list.
void brelse(struct buf *b)	// 释放sleep-lock
{
    if(!holdingsleep(&b->lock))
        panic("brelse");

    releasesleep(&b->lock);	// brelse释放锁

    acquire(&bcache.lock);
    b->refcnt--;
    if (b->refcnt == 0) {
        // no one is waiting for it.
        b->next->prev = b->prev;	// 将该buffer移动到链表的头部
        b->prev->next = b->next;
        b->next = bcache.head.next;
        b->prev = &bcache.head;
        bcache.head.next->prev = b;
        bcache.head.next = b;
        /*
        	移动buffer会使链表按照buffer最近使用的时间（最近释放）排序
        	链表中的第一个buffer是最近使用的，最后一个是最早使用的。
        	bget中的两个循环利用了这一点，在最坏的情况下，获取已缓存buffer的扫描必须处理整个链表，
        	由于数据局部性，先检查最近使用的缓冲区(从bcache.head开始，通过next指针)将减少扫描时间。
        	扫描选取可使用buffer的方法是通过从后向前扫描（通过prev指针）选取最近使用最少的缓冲区。
        */
    }
    release(&bcache.lock);	
}
```

buffer缓存为每个buffer的都设有sleep-lock，以确保每次只有一个线程使用buffer（从而使用相应的磁盘块）；**bread** 返回的buffer会被锁定，而**brelse**释放锁。



## log日志

Xv6通过简单的日志系统来解决文件系统操作过程中崩溃带来的问题。xv6的系统调用不直接写磁盘上的文件系统数据结构。相反，它将写入的数据记录在磁盘上的日志中。

- 系统调用记录全部的写入数据
- 在磁盘上写一个特殊的提交记录，表明该日志包含了一个完整的操作。
- 系统调用将日志中的写入数据写到磁盘上相应的位置。
- 执行完成后，系统调用将磁盘上的日志清除。

如果系统崩溃并重启，文件系统会在启动过程中恢复自己。

- 如果日志被标记为包含一个完整的操作，那么恢复代码将写入的内容复制到它们在磁盘文件系统中的相应位置。
- 如果日志未被标记为包含完整的操作，则恢复代码将忽略并清除该日志。

日志解决文件系统操作过程中崩溃问题的有效性 :

1. 如果崩溃发生在操作提交之前，那么磁盘上的日志将不会被标记为完成，恢复代码将忽略它，磁盘的状态就像操作根本没有开始一样。
2. 如果崩溃发生在操作提交之后，那么恢复代码会重新执行写操作，可能会重复执行之前的写操作。

不管是哪种情况，日志都会使写与崩溃为原子的，即恢复后，所有操作的写入内容，要么都在磁盘上，要么都不在。

系统调用中一般用法如下：

``` cpp
begin_op();
...
bp = bread(...);
bp->data[...] = ...;
log_write(bp);
...
end_op();
```

**`begin_op`**`(kernel/log.c:126)`会一直等到日志系统没有commiting，并且有足够的日志空间来容纳这次调用的写。

```cpp
// called at the start of each FS system call.
void begin_op(void)
{
    acquire(&log.lock);
    while(1){
        if(log.committing){
            sleep(&log, &log.lock);
        } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
            /*
            	log.outstanding统计当前系统调用的数量
            	可以通过log.outstanding乘MAXOPBLOCKS来计算已使用的日志空间。
            	自增log.outstanding既能预留空间，又能防止该系统调用期间进行提交。
            	假设每次系统调用最多写入MAXOPBLOCKS个块。
            */
            // this op might exhaust log space; wait for commit.
            sleep(&log, &log.lock);
        } else {
            log.outstanding += 1;
            release(&log.lock);
            break;
        }
    }
}
```

 **`log_write`** `(kernel/log.c:214)` 是**`bwrite`**的代理。
它将扇区号记录在内存中，在磁盘上的日志中使用一个槽，并自增**buffer.refcnt**防止该**buffer**被重用。在提交之前，块必须留在缓存中，即该缓存的副本是修改的唯一记录；在提交之后才能将其写入磁盘上的位置；该次修改必须对其他读可见。

```cpp
// Caller has modified b->data and is done with the buffer.
// Record the block number and pin in the cache by increasing refcnt.
// commit()/write_log() will do the disk write.
//
// log_write() replaces bwrite(); a typical use is:
//   bp = bread(...)
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void log_write(struct buf *b)
{
    int i;
    if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
        panic("too big a transaction");
    if (log.outstanding < 1)
        panic("log_write outside of trans");

    acquire(&log.lock);
    for (i = 0; i < log.lh.n; i++) {
        if (log.lh.block[i] == b->blockno)   // log absorbtion
            break;
    }
    log.lh.block[i] = b->blockno;
    if (i == log.lh.n) {  // Add new block to log?
        bpin(b);
        log.lh.n++;
    }
    release(&log.lock);
}
```

==注意==: 当一个块在一个事务中被多次写入时，他们在日志中的槽是相同的。这种优化通常被称为absorption(吸收)。

例如，在一个事务中，包含多个文件的多个inode的磁盘块被写多次，通过将几次磁盘写**吸收**为一次，文件系统可以节省日志空间，并且可以获得更好的性能，因为只有一份磁盘块的副本必须写入磁盘。

**`end_op`** `(kernel/log.c:146)`

```cpp
// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void end_op(void)
{
    int do_commit = 0;

    acquire(&log.lock);
    log.outstanding -= 1;	// 首先递减log.outstanding
    if(log.committing)
        panic("log.committing");
    if(log.outstanding == 0){
        do_commit = 1;		// 如果计数为零, 标志置1, 下方通过调用commit()来提交当前事务。
        log.committing = 1;
    } else {
        // begin_op() may be waiting for log space,
        // and decrementing log.outstanding has decreased
        // the amount of reserved space.
        wakeup(&log);
    }
    release(&log.lock);

    if(do_commit){
        // call commit w/o holding locks, since not allowed
        // to sleep with locks.
        commit();	// 
        acquire(&log.lock);
        log.committing = 0;
        wakeup(&log);
        release(&log.lock);
    }
}
```

**`Commit`**分为四个阶段：

1. **`write_log()`**`(kernel/log.c:178)`将事务中修改的每个块从buffer缓存中复制到磁盘上的日志槽

   ```cpp
   // Copy modified blocks from cache to log.
   static void write_log(void)
   {
       int tail;
   
       for (tail = 0; tail < log.lh.n; tail++) {
           struct buf *to = bread(log.dev, log.start+tail+1); // log block
           struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
           memmove(to->data, from->data, BSIZE);
           bwrite(to);  // write the log
           brelse(from);
           brelse(to);
       }
   }
   ```

2. **`write_head()`**`(kernel/log.c:102)`将header块写到磁盘上，就表明已提交，为提交点，写完日志后的崩溃，会导致在重启后重新执行日志。

   ```cpp
   // Write in-memory log header to disk.
   // This is the true point at which the
   // current transaction commits.
   static void write_head(void)
   {
       struct buf *buf = bread(log.dev, log.start);
       struct logheader *hb = (struct logheader *) (buf->data);
       int i;
       hb->n = log.lh.n;
       for (i = 0; i < log.lh.n; i++) {
           hb->block[i] = log.lh.block[i];
       }
       bwrite(buf);
       brelse(buf);
   }
   ```

3. **install_trans**(kernel/log.c:69)从日志中读取每个块，并将其写到文件系统中对应的位置。

   ```cpp
   // Copy committed blocks from log to their home location
   static void install_trans(void)
   {
       int tail;
   
       for (tail = 0; tail < log.lh.n; tail++) {
           struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
           struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
           memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
           bwrite(dbuf);  // write dst to disk
           bunpin(dbuf);
           brelse(lbuf);
           brelse(dbuf);
       }
   }
   ```

4. 最后修改日志块计数为0，并写入日志空间的header部分。这必须在下一个事务开始之前修改，这样崩溃就不会导致重启后的恢复使用这次的header和下次的日志块。

**`recover_from_log`** `(kernel/log.c:116)` 是在 **`initlog`**` (kernel/log.c:55) `中调用的

```cpp
static void recover_from_log(void)
{
    read_head();
    install_trans(); // if committed, copy from log to disk
    log.lh.n = 0;
    write_head(); // clear the log
}
```

```cpp
void initlog(int dev, struct superblock *sb)
{
    if (sizeof(struct logheader) >= BSIZE)
        panic("initlog: too big logheader");

    initlock(&log.lock, "log");
    log.start = sb->logstart;
    log.size = sb->nlog;
    log.dev = dev;
    recover_from_log();
}
```

**`initlog`** 是在第一个用户进程运行 `(kernel/proc.c:539) `之前, 由 **`fsinit`**`(kernel/fs.c:42) `调用的。它读取日志头，如果日志头显示日志中包含一个已提交的事务，则会像**end_op**那样执行日志。

```cpp
// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    static int first = 1;
    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    if (first) {
        // File system initialization must be run in the context of a
        // regular process (e.g., because it calls sleep), and thus cannot
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }
    usertrapret();
}
```

```cpp
// Init fs
void fsinit(int dev) {
    readsb(dev, &sb);
    if(sb.magic != FSMAGIC)
        panic("invalid file system");
    initlog(dev, &sb);
}
```

## Block allocator 块分配器

文件和目录存储在磁盘块中，必须从空闲池中分配，xv6的块分配器在磁盘上维护一个bitmap，每个块对应一个位。

- 0表示对应的块是空闲的
- 1表示正在使用中。

程序mkfs设置引导扇区、超级块、日志块、inode块和位图块对应的位。

块分配器提供了两个函数：**balloc**申请一个新的磁盘块，**bfree**释放一个块。**balloc**和**bfree**必须在事务中被调用。

`balloc` `[kernel/fs.c:71]`

```cpp
// Allocate a zeroed disk block.
static uint balloc(uint dev)
{
    int b, bi, m;
    struct buf *bp;

    bp = 0;
    /*
    	循环遍历每一个块，从块 0 开始，直到 sb.size，即文件系统中的块数。
    	为了提高效率，这个循环被分成两部分
    	外循环读取bitmap的一个块，内循环检查块中的所有BPB位。
    	如果两个进程同时试图分配一个块，可能会发生竞争，
    	但buffer缓存只允许块同时被一个进程访问，这就避免了这种情况的发生。
    */
    for(b = 0; b < sb.size; b += BPB){
        bp = bread(dev, BBLOCK(b, sb));
        for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
            m = 1 << (bi % 8);
            if((bp->data[bi/8] & m) == 0){  // Is block free? // 寻找一个位为0的空闲块
                bp->data[bi/8] |= m;  // Mark block in use.	// 更新bitmap
                log_write(bp);
                brelse(bp);
                bzero(dev, b + bi);
                return b + bi;	// 返回该块
            }
        }
        brelse(bp);
    }
    panic("balloc: out of blocks");
}
```

`Bfree` `[kernel/fs.c:90]`
找到相应的bitmap块并清除相应的位。**bread**和**brelse**暗含的独占性避免了显式锁定。

```cpp
// Free a disk block.
static void bfree(int dev, uint b)
{
    struct buf *bp;
    int bi, m;

    bp = bread(dev, BBLOCK(b, sb));
    bi = b % BPB;
    m = 1 << (bi % 8);
    if((bp->data[bi/8] & m) == 0)
        panic("freeing free block");
    bp->data[bi/8] &= ~m;
    log_write(bp);
    brelse(bp);
}
```



## inode

inode的含义:

1. 指的是磁盘上的数据结构，其中包含了文件的大小和数据块号的列表
2. 指的是内存中的inode，它包含了磁盘上inode的副本以及内核中需要的其他信息。

inode被放置在磁盘的连续区域, 每个inode大小一样. 给定一个 inode号或i-number能够很容易找到找到磁盘上的第n个inode。

结构体**`dinode`**`(kernel/fs.h:32)`定义了磁盘上的inode

```cpp
// On-disk inode structure
struct dinode {
    short type;           // File type: 区分文件\目录\特殊文件(设备)  type=0表示inode空闲
    short major;          // Major device number (T_DEVICE only)
    short minor;          // Minor device number (T_DEVICE only)
    short nlink;          // Number of links to inode in file system
    // 文件系统中引用inode的目录项的数量. 引用数为0时就释放磁盘上的inode及其数据块。
    uint size;            // Size of file (bytes)
    // 记录了文件中内容的字节数
    uint addrs[NDIRECT+1];   // Data block addresses
    // 记录了持有文件内容的磁盘块的块号
};
```

内核将在使用的inode保存在内存中；结构体**`inode`** `(kernel/file.h:17)`是磁盘**dinode**的拷贝。

```cpp
// in-memory copy of an inode
struct inode {
    uint dev;           // Device number
    uint inum;          // Inode number
    int ref;            // Reference count
    // 指向inode的指针的数量. 引用数量减少到零，内核就会从内存中丢弃这个inode
    // 如果大于0，则会使系统将该inode保留在缓存中，而不会重用该inode。
    struct sleeplock lock; // protects everything below here
    /*
    	在xv6的inode代码中，有四种锁或类似锁的机制。
    	icache.lock保证了一个inode在缓存只有一个副本，以及缓存inode的ref字段计数正确。
    	每个内存中的inode都有一个包含sleep-lock的锁字段，保证了可以独占访问inode的其他字段(如文件长度)以及inode的文件或目录内容块
    */
    int valid;          // inode has been read from disk?

    short type;         // copy of disk inode
    short major;
    short minor;
    short nlink;
    /*
    	每个inode都包含一个nlink字段(在磁盘上，缓存时会复制到内存中)
    	该字段统计链接该inode的目录项的数量；如果一个inode的链接数大于零，xv6不会释放它。
    */
    uint size;
    uint addrs[NDIRECT+1];
};
```

**`iget`**和**`iput`**函数引用和释放inode，并修改引用计数。指向inode的指针可以来自文件描述符，当前工作目录，以及短暂的内核代码，如**exec**。

**iget()**返回的**inode**指针在调用iput()之前都是有效的；inode不会被删除，指针所引用的内存也不会被另一个inode重新使用。**iget()**提供了对inode的非独占性访问，因此可以有许多指针指向同一个inode。

- 为了保持对inode的长期引用(如打开的文件和当前目录)
- 避免在操作多个inode的代码中出现死锁(如路径名查找)

inode缓存只缓存被指针指向的inode。它的主要工作其实是同步多个进程的访问，缓存是次要的。如果一个inode被频繁使用，如果不被inode缓存保存，buffer缓存可能会把它保存在内存中。inode缓存是***write-through***的，这意味着缓存的inode被修改，就必须立即用**iupdate**把它写入磁盘。



**`ialloc`**`(kernel/fs.c:196)`: 创建一个新的inode. **ialloc** 类似于 **balloc**
一次只能有一个进程持有对**bp:ialloc**的引用，所以可以确保其他进程不会同时看到inode是可用的并使用它。

```cpp
// Allocate an inode on device dev.
// Mark it as allocated by  giving it type type.
// Returns an unlocked but allocated and referenced inode.
struct inode* ialloc(uint dev, short type)
{
    int inum;
    struct buf *bp;
    struct dinode *dip;

    for(inum = 1; inum < sb.ninodes; inum++){	// 遍历磁盘上的inode, 寻找一个被标记为空闲的inode
        bp = bread(dev, IBLOCK(inum, sb));
        dip = (struct dinode*)bp->data + inum%IPB;
        if(dip->type == 0){  // a free inode
            memset(dip, 0, sizeof(*dip));
            dip->type = type;	// 找到后, 修改该inode的type字段来使用它
            log_write(bp);   // mark it allocated on the disk
            brelse(bp);
            return iget(dev, inum);	// 调用 iget (kernel/fs.c:210) 来从 inode 缓存中返回一个条目
        }
        brelse(bp);
    }
    panic("ialloc: no inodes");
}
```

**`Iget`** `(kernel/fs.c:243)` 在inode缓存中寻找一个带有所需设备号和inode号码的active条目 (`ip->ref > 0`)

```cpp
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode* iget(uint dev, uint inum)
{
    struct inode *ip, *empty;

    acquire(&icache.lock);

    // Is the inode already cached?
    empty = 0;
    for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
        if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
            ip->ref++;
            release(&icache.lock);
            return ip;	// 找到了，返回一个新的对该inode的引用
        }
        if(empty == 0 && ip->ref == 0)    // Remember empty slot.
            empty = ip;
        /*
        	当 iget 扫描时，它会记录第一个空槽的位置
        	当它需要分配一个缓存条目时，它会使用这个空槽。
        */
    }

    // Recycle an inode cache entry.
    if(empty == 0)
        panic("iget: no inodes");

    ip = empty;
    ip->dev = dev;
    ip->inum = inum;
    ip->ref = 1;
    ip->valid = 0;
    release(&icache.lock);

    return ip;
}
```

在读写inode的元数据或内容之前，代码必须使用**ilock**锁定它。**`Ilock`**`(kernel/fs.c:289)`

```cpp
// Lock the given inode.
// Reads the inode from disk if necessary.
void ilock(struct inode *ip)
{
    struct buf *bp;
    struct dinode *dip;

    if(ip == 0 || ip->ref < 1)
        panic("ilock");

    acquiresleep(&ip->lock);	// 使用sleep-lock来锁定。
	// 一旦ilock**锁定了inode，它就会根据自己的需要从磁盘（更有可能是buffer缓存）读取inode。
    if(ip->valid == 0){
        bp = bread(ip->dev, IBLOCK(ip->inum, sb));
        dip = (struct dinode*)bp->data + ip->inum%IPB;
        ip->type = dip->type;
        ip->major = dip->major;
        ip->minor = dip->minor;
        ip->nlink = dip->nlink;
        ip->size = dip->size;
        memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
        brelse(bp);
        ip->valid = 1;
        if(ip->type == 0)
            panic("ilock: no type");
    }
}
```

函数**`iunlock`** `(kernel/fs.c:317)`释放睡眠锁，这会唤醒正在等待该睡眠锁的进程。

```cpp
// Unlock the given inode.
void iunlock(struct inode *ip)
{
    if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
        panic("iunlock");

    releasesleep(&ip->lock);
}
```



**`Iput`** `(kernel/fs.c:333) `通过递减引用次数 `(kernel/fs.c:356)` 释放指向inode的指针。

```cpp
// Drop a reference to an in-memory inode.
// If that was the last reference, the inode cache entry can
// be recycled.
// If that was the last reference and the inode has no links
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void iput(struct inode *ip)
{
    acquire(&icache.lock);

    if(ip->ref == 1 && ip->valid && ip->nlink == 0){
        /*
        	果递减后的引用数为0，inode 缓存中的 就会释放掉该inode 在inode缓存中的槽位，该槽位就可以被其他inode使用。
        */
        // inode has no links and no other references: truncate and free.
        // ip->ref == 1 means no other process can have ip locked,
        // so this acquiresleep() won't block (or deadlock).
        acquiresleep(&ip->lock);
        release(&icache.lock);
        // 如果iput发现没有指针指向该inode，并且没有任何目录项链接该inode（不在任何目录中出现），
        // 那么该inode和它的数据块必须被释放。
        itrunc(ip);	// 调用itrunc将文件截断为零字节，释放数据块
        ip->type = 0;	// 将inode类型设置为0（未分配）
        iupdate(ip);
        ip->valid = 0;
        releasesleep(&ip->lock);
        acquire(&icache.lock);
    }
    ip->ref--;
    release(&icache.lock);
}
```

**iput**在释放inode的锁定协议有两个主要危险:

- 一个并发线程可能会在**ilock**中等待使用这个inode
  - 例如，读取一个文件或列出一个目录，但它没有意识到该inode可能被释放掉了。这种情况是不会发生:
    - 因为该inode的没有被目录项链接且**ip->ref**为1，那么系统调用是没有这个指针的（如果有，**ip->ref**应该为2）。这一个引用是调用 iput 的线程所拥有的。
    - **iput**会在其**icache.lock**锁定的临界区之外检查引用数是否为1，但此时已知链接数为0，所以没有线程会尝试获取新的引用。
- 并发调用**ialloc**可能会使**iput**返回一个正在被释放的inode。
  - 这种情况发生在**iupdate**写磁盘时**ip->type=0**。
  - 这种竞争是正常的，分配inode的线程会等待获取inode的睡眠锁，然后再读取或写入inode，但此时**iput**就结束了。





磁盘上的inode, 即dInode的结构体:

![](https://s1.vika.cn/space/2022/12/12/7f7af81481ab4b66908d9d0bb9dee997)

## directory layer 目录

目录的**inode**类型是**T_DIR**，它的数据是一个目录项的序列。每个条目是一个结构体`dirent(kernel/fs.h:56)`

```cpp
struct dirent {
    ushort inum;	// inode号
    // inode号为0的目录项是空闲的
    char name[DIRSIZ];	// 名称
    // 名称最多包含DIRSIZ(14)个字符，较短的名称以NULL(0)结束。
};
```

**`dirlookup`** `(kernel/fs.c:527)`在一个目录中搜索一个带有给定名称的条目。
Dirlookup是iget返回未锁定的inode的原因。调用者已经锁定了dp，所以如果查找的是 **“.”** ，当前目录的别名，在返回之前试图锁定inode，就会试图重新锁定dp而死锁。
调用者可以先解锁dp，然后再锁定ip，保证一次只持有一个锁。

```cpp
// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode* dirlookup(struct inode *dp, char *name, uint *poff)
{
    uint off, inum;
    struct dirent de;

    if(dp->type != T_DIR)	// 不是目录类型, 直接panic
        panic("dirlookup not DIR");

    for(off = 0; off < dp->size; off += sizeof(de)){
        if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlookup read");
        if(de.inum == 0)
            continue;
        if(namecmp(name, de.name) == 0){
            /*
            	找到一个对应名称的条目，则更新poff，并返回一个通过iget获得的未被锁定的inode。
            */
            // entry matches path element
            if(poff)
                *poff = off;	// 将poff设置为目录中条目的字节偏移量，以便调用者想要编辑它。
            inum = de.inum;
            return iget(dp->dev, inum);	// 找到了，它返回一个指向相应未上锁的inode的指针
        }
    }

    return 0;
}
```



**`dirlink`** `(kernel/fs.c:554)`会在当前目录dp中通过给定的名称和inode号创建一个新的目录项。

```cpp
// Write a new directory entry (name, inum) into the directory dp.
int dirlink(struct inode *dp, char *name, uint inum)
{
    int off;
    struct dirent de;
    struct inode *ip;

    // Check that name is not present.
    // 如果名称已经存在，dirlink 将返回一个错误
    if((ip = dirlookup(dp, name, 0)) != 0){
        iput(ip);
        return -1;
    }

    // Look for an empty dirent.
    for(off = 0; off < dp->size; off += sizeof(de)){	// 主循环读取目录项，寻找一个未使用的条目
        /*
        	当找到一个时，它会提前跳出循环并将off设置为该可用条目的偏移量
        	否则，循环结束时，将off设置为dp->size
        */
        if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
            panic("dirlink read");
        if(de.inum == 0)	
            break;	// 跳出循环
    }

    strncpy(de.name, name, DIRSIZ);	
    // 不管是哪种方式，dirlink都会在偏移量off的位置添加一个新的条目到目录中
    de.inum = inum;
    if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
        panic("dirlink");

    return 0;
}
```



## Path name

查找路径名会对每一个节点调用一次**`dirlookup`**。`Namei`  `(kernel/fs.c:661)` 解析路径并返回相应的inode。

```cpp
struct inode* namei(char *path)
{
    char name[DIRSIZ];
    return namex(path, 0, name);
}
```

**`nameiparent`**是**`namei`**的一个变种：它返回相应inode的父目录inode，并将最后一个元素复制到**name**中。这两个函数都通过调用**`namex`**来实现。

**`Namex`** `(kernel/fs.c:626)`首先确定路径解析从哪里开始

```cpp
// Look up and return the inode for a path name.
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode* namex(char *path, int nameiparent, char *name)
{
    struct inode *ip, *next;

    if(*path == '/')	// 如果路径以斜线开头，则从根目录开始解析
        ip = iget(ROOTDEV, ROOTINO);
    else	// 否则，从当前目录开始解析
        ip = idup(myproc()->cwd);

    while((path = skipelem(path, name)) != 0){	// 使用 skipelem 来遍历路径中的每个元素
        /*
        	每次迭代都必须在当前inode ip中查找name
        */
        ilock(ip);	// 迭代的开始是锁定ip
        /*
        	锁定ip是必要的, 不是因为ip->type可能会改变
        	而是因为在**ilock**运行之前, 不能保证ip->type已经从磁盘载入
        */
        if(ip->type != T_DIR){	// 并检查它是否是一个目录
            iunlockput(ip);
            return 0;	// 如果不是，查找就会失败
        }
        if(nameiparent && *path == '\0'){	// 如果调用的是nameiparent，而且这是最后一个路径元素
            // Stop one level early.
            /*
            	按照之前nameiparen*的定义，循环应该提前停止
            	最后一个路径元素已经被复制到name中，所以namex只需要返回解锁的ip
            */
            iunlock(ip);
            return ip;
        }
        /**	最后，循环使用dirlookup查找路径元素，并通过设置ip = next 为下一次迭代做准备 */ 
        if((next = dirlookup(ip, name, 0)) == 0){
            iunlockput(ip);
            return 0;
        }
        iunlockput(ip);
        ip = next;
        /* **/
    }
    if(nameiparent){
        iput(ip);
        return 0;
    }
    return ip;	// 当循环遍历完路径元素时，它返回 ip
}
```

**namex**可能需要很长的时间来完成：它可能会涉及几个磁盘操作，通过遍历路径名得到的目录的inode和目录块（如果它们不在buffer缓存中）。Xv6经过精心设计，如果一个内核线程对**namex**的调用阻塞在磁盘I/O上，另一个内核线程查找不同的路径名可以同时进行。**Namex**分别锁定路径中的每个目录，这样不同目录的查找就可以并行进行。

这种并发性带来了一些挑战。例如，当一个内核线程在查找一个路径名时，另一个内核线程可能正在取消链接一个目录，这会改变目录数。一个潜在的风险是，可能一个查找线程正在搜索的目录可能已经被另一个内核线程删除了，而它的块已经被另一个目录或文件重用了。

Xv6避免了这种竞争。例如，在**namex**中执行**dirlookup**时，查找线程会持有目录的锁，**dirlookup**返回一个使用**iget**获得的inode。**iget**会增加inode的引用次数。只有从**dirlookup**收到inode后，**namex**才会释放目录上的锁。现在另一个线程可能会从目录中取消链接inode，但xv6还不会删除inode，因为inode的引用数仍然大于零。

另一个风险是死锁。例如，当查找**". "**时，next指向的inode与**ip**相同。在释放对**ip**的锁之前锁定next会导致死锁。为了避免这种死锁，**namex**在获得对next的锁之前就会解锁目录。

==所以iget和ilock之间的分离是很重要的==

## File descriptor layer 文件描述符层

大部分资源都是以文件的形式来表示的. 文件描述符层就是实现这种统一性的一层

Xv6给每个进程提供了自己的打开文件表，或者说文件描述符表，每个打开的文件由一个结构体**`file`**`(kernel/file.h:1)`表示，它包装inode或管道，也包含一个I/O偏移量。

```cpp
struct file {
    enum { FD_NONE, FD_PIPE, FD_INODE, FD_DEVICE } type;
    int ref; // reference count
    char readable;
    char writable;
    struct pipe *pipe; // FD_PIPE
    struct inode *ip;  // FD_INODE and FD_DEVICE
    uint off;          // FD_INODE
    short major;       // FD_DEVICE
};
```

- 每次调用**open**都会创建一个新的打开文件（一个新的结构体file），如果多个进程独立打开同一个文件，那么不同的**file**实例会有不同的I/O偏移量。
- 一个打开的文件（同一个结构文件）可以在一个进程的文件表中出现多次，也可以在多个进程的文件表中出现。
  - 例如: 一个进程使用**open**打开文件，然后使用**dup**创建别名，或者使用**fork**与子进程共享文件
- 引用计数可以跟踪特定打开文件的引用数量。一个文件的打开方式可以为读，写，或者读写。通过**readable**和**writable**来指明。
- 

系统中所有打开的文件都保存在一个全局文件表中，即**ftable**。
文件表的功能有: 分配文件(**filealloc**)、创建重复引用(**fileup**)、释放引用(**fileclose**)、读写数据(**fileeread**和**filewrite**)。

- **`Filealloc`** `(kernel/file.c:30)` 扫描文件表，寻找一个未引用的文件 (f->ref == 0)，并返回一个新的引用

  ```cpp
  // Allocate a file structure.
  struct file* filealloc(void)
  {
      struct file *f;
  
      acquire(&ftable.lock);
      for(f = ftable.file; f < ftable.file + NFILE; f++){
          if(f->ref == 0){
              f->ref = 1;
              release(&ftable.lock);
              return f;
          }
      }
      release(&ftable.lock);
      return 0;
  }
  ```

- **`fileup`** `(kernel/file.c:48) `增加引用计数

  ```CPP
  // Increment ref count for file f.
  struct file* filedup(struct file *f)
  {
      acquire(&ftable.lock);
      if(f->ref < 1)
          panic("filedup");
      f->ref++;
      release(&ftable.lock);
      return f;
  }
  ```

- **`fileclose`** `(kernel/file.c:60)` 减少引用计数。当一个文件的引用数达到0时，**fileclose**会根据类型释放底层的管道或inode。

  ```CPP
  // Close file f.  (Decrement ref count, close when reaches 0.)
  void fileclose(struct file *f)
  {
      struct file ff;
  
      acquire(&ftable.lock);
      if(f->ref < 1)
          panic("fileclose");
      if(--f->ref > 0){
          release(&ftable.lock);
          return;
      }
      ff = *f;
      f->ref = 0;
      f->type = FD_NONE;
      release(&ftable.lock);
  
      if(ff.type == FD_PIPE){
          pipeclose(ff.pipe, ff.writable);
      } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
          begin_op();
          iput(ff.ip);
          end_op();
      }
  }
  ```

  

函数**filestat**、**fileread**和**filewrite**实现了对文件的统计、读和写操作. 

- `Filestat`(kernel/file.c:88)只允许对inodes进行操作，并调用**stati**。

  ```cpp
  // Get metadata about file f.
  // addr is a user virtual address, pointing to a struct stat.
  int filestat(struct file *f, uint64 addr)
  {
      struct proc *p = myproc();
      struct stat st;
  
      if(f->type == FD_INODE || f->type == FD_DEVICE){
          ilock(f->ip);
          stati(f->ip, &st);
          iunlock(f->ip);
          if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
              return -1;
          return 0;
      }
      return -1;
  }
  ```

- **`Fileread`**和**`filewrite`**首先检查打开模式是否允许该操作，然后再调用管道或inode的相关实现。如果文件代表一个inode，**fileread**和**filewrite**使用I/O偏移量作为本次操作的偏移量，然后前移偏移量（kernel/file.c:122- 123）（kernel/file.c:153-154）。

  ```cpp
  // Read from file f.
  // addr is a user virtual address.
  int fileread(struct file *f, uint64 addr, int n)
  {
      int r = 0;
  
      if(f->readable == 0)
          return -1;
  
      if(f->type == FD_PIPE){
          r = piperead(f->pipe, addr, n);
      } else if(f->type == FD_DEVICE){
          if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
              return -1;
          r = devsw[f->major].read(1, addr, n);
      } else if(f->type == FD_INODE){
          ilock(f->ip);
          if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
              f->off += r;	// 前移偏移量
          iunlock(f->ip);
      } else {
          panic("fileread");
      }
  
      return r;
  }
  ```

  

  ```cpp
  // Write to file f.
  // addr is a user virtual address.
  int filewrite(struct file *f, uint64 addr, int n)
  {
      int r, ret = 0;
  
      if(f->writable == 0)
          return -1;
  
      if(f->type == FD_PIPE){
          ret = pipewrite(f->pipe, addr, n);
      } else if(f->type == FD_DEVICE){
          if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
              return -1;
          ret = devsw[f->major].write(1, addr, n);
      } else if(f->type == FD_INODE){
          // write a few blocks at a time to avoid exceeding
          // the maximum log transaction size, including
          // i-node, indirect block, allocation blocks,
          // and 2 blocks of slop for non-aligned writes.
          // this really belongs lower down, since writei()
          // might be writing a device like the console.
          int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
          int i = 0;
          while(i < n){
              int n1 = n - i;
              if(n1 > max)
                  n1 = max;
  
              begin_op();
              ilock(f->ip);
              if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
                  f->off += r;	// 前移偏移量
              iunlock(f->ip);
              end_op();
  
              if(r < 0)
                  break;
              if(r != n1)
                  panic("short filewrite");
              i += r;
          }
          ret = (i == n ? n : -1);
      } else {
          panic("filewrite");
      }
  
      return ret;
  }
  ```

  

Pipes没有偏移量的概念。inode的函数需要调用者处理锁的相关操作`[kernel/file.c:94-96]` `[kernel/file.c:121-124]` `[kernel/file.c:163-166]`

inode加锁附带了一个不错的作用，那就是读写偏移量是原子式更新的，这样多个进程写一个文件时，自己写的数据就不会被其他进程所覆盖，尽管他们的写入可能最终会交错进行。