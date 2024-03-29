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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《设备驱动》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 嵌入式第四次实验</td>     </tr>
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

设备驱动学习

## 实验要求

1.	建立交叉编译环境
2.	编译开发板的linux内核
3.	驱动程序编写
4.	编写驱动程序的Makefile，编译生成.ko文件
5.	上传驱动文件到开发板
6.	驱动安装与验证

## 实验内容

### 实验任务

实验内容1：globalmem驱动

实验内容2：Tiny4412设备驱动学习

### 实验环境

硬件： Tiny4412开发板

软件： minicom，交叉编译器，vim，gcc，Linux系统

## 实验步骤

首先建立交叉编译环境。`arm-linux-gcc –v `进行验证

### Globalmem驱动

1. 编译开发板的linux内核

   1. `tar –zxvf linux-3.5-20150929.tgz` 解压内核文件到 home/pc
      ![x1](https://s1.vika.cn/space/2022/06/24/90c6feebd8c24bc4bfab94225d693ded)
   2. 将tiny4412_linux_defconfig文件复制到Linux内核配置文件.config中
   3. `make ARCH=arm CROSS_COMPILE=arm-linux-`语句进行内核编译（大约需要10分钟）
      ![x2](https://s1.vika.cn/space/2022/06/24/7513ff09364d45778b2cb4f85f882332)

2. 驱动程序编写

3. 编辑驱动Makefile，编译驱动生成globalmem.ko

   makefile编写如下：

   ```makefile
   obj-m += globalmem.o
   KERNELDIR ?= /home/pc/linux-3.5
   PWD := $(shell pwd)
   
   all:
   $(MAKE) -C $(KERNELDIR) M=$(PWD)
   clean:
   rm -rf *.o *.~core .depend .*.cmd *.ko.* *.mod.c .tmp_versions
   ```

   第一行是目标文件，是一个隐式关系，会自动寻找对应名称的.c文件

   第二行是内核所在位置

   PWD是调用函数，表示获取当前所在位置

   默认执行all：的部分

   如果编译失败，执行clean可以删除中间文件，重新编译即可

4. 上传驱动文件到开发板。上传之前需要删除之前的同名文件
   ![x5](https://s1.vika.cn/space/2022/06/24/27554f6a2b7a4ea89b7dacf70f27fde1)

5. 驱动安装与验证

   1. insmod globalmem.ko

   2. cat /proc/devices 命令查看驱动信息，devices/下有globalmem，说明安装成功！

      往里面写数据，再读出，读出与写入一致，说明驱动正确
      ![x6](https://s1.vika.cn/space/2022/06/24/b6bdf52fbdc740b68eb9964ae78e963e)
   
   3. echo “hello world globalmem” > /dev/globalmem
   
   4. cat /dev/globalmem
   
   5. 输出“hello world globalmem”说明往globalmem读写正确。
   
      ![](https://s1.vika.cn/space/2022/06/24/de9f83103a1246088b3a35c03129e436)

### Tiny4412设备驱动学习

1. 从/linux-3.5/drivers/char下拷贝tiny4412_leds.c到新建目录/leds 

2. 编辑Makefile

   ```c++
      obj-m +=tiny4412_leds.o
      KERNELDIR ?= /home/pc/linux-3.5
      PWD := $(shell pwd)
      all:
      $(MAKE) -C $(KERNELDIR) M=$(PWD)
      clean:
      rm -rf *.o *.~core .depend .*.cmd *.ko.* *.mod.c .tmp_versions
   ```

3. 编译驱动生成tiny4412_leds.ko

   <img src="https://s1.vika.cn/space/2022/06/24/3b54c81a07ed4027ba8ae4129689baed" alt="x1" style="zoom:67%;" />

4. 使用minicom把tiny4412_leds.ko上传到tiny4412开发板

5. 驱动安装并观察结果 insmod tinuy4412_leds.ko
   <img src="https://s1.vika.cn/space/2022/06/24/2b3268dbcf9b42f0ba532a0706b6c059" alt="x2" style="zoom:50%;" />



## 实验总结

本次实验室对于设备驱动的实验。这一部分的实验和上一次的网络不同，是更偏向于硬件和底层的实验。初步涉及到了linux的内核。

而且需要makefile去运行编译文件。虽然makefile的主要目的是大型多文件的工程运行，但是在一个文件中仍然可以用。通过理论课程中的讲解和ppt例子的参考，成功实践了makefile的应用。

## 代码附录

### Globalmem驱动

globalmem.c

```cpp
#include <linux/module.h>
#include <linux/types.h>
#include <linux/fs.h>
#include <linux/errno.h>
#include <linux/mm.h>
#include <linux/sched.h>
#include <linux/init.h>
#include <linux/cdev.h>
#include <asm/io.h>
#include <linux/slab.h>
#include <linux/version.h>

#if LINUX_VERSION_CODE > KERNEL_VERSION(3, 3, 0)
   #include <asm/switch_to.h>
#else
   #include <asm/system.h>
#endif
#include <asm/uaccess.h>

#define GLOBALMEM_SIZE 0x1000   /*全局内存最大 4K 字节*/
#define MEM_CLEAR 0x1 /*清 0 全局内存*/
#define GLOBALMEM_MAJOR 150 /*预设的 globalmem 的主设备号*/

static int globalmem_major = GLOBALMEM_MAJOR;
/*globalmem 设备结构体*/
struct globalmem_dev
{
    struct cdev cdev;/*cdev 结构体*/
    unsigned char mem[GLOBALMEM_SIZE];/*全局内存*/
};

struct globalmem_dev *globalmem_devp;/*设备结构体指针*/

int globalmem_open(struct inode *inode, struct file *filp)
{
    filp->private_data = globalmem_devp;
    return 0;
}
int globalmem_release(struct inode *inode, struct file *filp)
{
    return 0;
}
long globalmem_ioctl(struct file *filp. unsigned int cmd, unsigned long arg)
{
    struct globalmem_dev *dev = filp->private_data;
    /*
    获得设备结构体指针
    */
   switch (cmd)
   {
   case MEM_CLEAR:
     memset(dev_mem, 0, GLOBALMEM_SIZE);
     printk(KERN_INFO "globalmem is set to zero\n");
    break;
   
   default:
     return - EINVAL;
   }
    return 0;
}

static ssize_t globalmem_read(struct file *filp, char __user *buf, size_t
size, loff_t *ppos)
{
    unsigned int p = *ppos;
    unsigned int count = size;
    int ret = 0;
    struct globalmem_dev *dev = filp->private_data;/*活的设备结构体指针*/

    /*分析和获取有效的写长度*/
    if (p >= GLOBALMEM_SIZE)
        return count ? - ENXIO: 0;
    if (count > GLOBALMEM_SIZE - p)
        count = GLOBALMEM_SIZE - p;

    /*内核空间->用户空间*/
    if (copy_to_user(buf, (void*)(dev->mem + P), count))
    {
        ret =  - EFAULT;
    }
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_INFO "read %d bytes(s) from %d\n", count, p);
    }
    return ret;
}

static ssize_t globalmem_write(struct file *filp, char __user *buf, size_t
size, loff_t *ppos)
{
    unsigned int p = *ppos;
    unsigned int count = size;
    int ret = 0;
    struct globalmem_dev *dev = filp->private_data;/*活的设备结构体指针*/

    /*分析和获取有效的写长度*/
    if (p >= GLOBALMEM_SIZE)
        return count ? - ENXIO: 0;
    if (count > GLOBALMEM_SIZE - p)
        count = GLOBALMEM_SIZE - p;

    /*用户空间->内核空间*/
    if (copy_from_user(dev->mem + p,  buf, count))
    {
        ret =  - EFAULT;
    }
    else
    {
        *ppos += count;
        ret = count;
        printk(KERN_INFO "written %d bytes(s) from %d\n", count, p);
    }
    return ret;
}

static loff_t globalmem_llseek(struct file *filp, loff_t offset, int orig)
{
   loff_t ret = 0;
   switch (orig)
   {
   case 0:   /* 相对文件开始位置移动 */
     if (offset < 0)
     {
        ret = - EINVAL;
        break;
     }
     if ((unsigned int)offset > GLOBALMEM_SIZE)
     {
        ret = - EINVAL;
        break;
     }
     filp->f_pos = (unsigned int)offset;
     ret = filp->f_pos;
    break;
    case 1:   /* 相对文件当前位置偏移 */
     if ((filp->f_pos + offset) > GLOBALMEM_SIZE)
     {
        ret = - EINVAL;
        break;
     }
     if ((filp->f_pos + offset) < 0)
     {
        ret = - EINVAL;
        break;
     }
     filp->f_pos += offset;
     ret = filp->f_pos;
    break;
   
   default:
   ret = - EINVAL;
    break;
   }
   return ret;
}

static const struct file_operations globalmem_fops =
{
    .owner = THIS_MODULE,
    .llseek = globalmem_llseek,
    .read = globalmem_read,
    .write = globalmem_write,
    .unlocked_ioctl = globalmem_ioctl,
    .open = globalmem_open,
    .release = globalmem_release,
};
static void globalmem_setup_cdev(struct globalmem_dev *dev, int index)
{
    int err, devno = MKDEV(globalmem_major, index);
    
    cdev_init(&dev->cdev, &globalmem_fops);
    dev->cdev.owner = THIS_MODULE;
    // dev->cdev.ops = ______;
    err = cdev_add(&dev->cdev, devno, 1);
    if (err)
       printk(KERN_NOTICE "Error %d adding LED%d", err, index);
}
int globalmem_init(void)
{
    int result;
    dev_t devno = MKDEV(globalmem_major, 0);

    /*申请设备号*/
    if (globalmem_major)
        result = register_chrdev_region(devno, 1, "globalmem");
    else   /*动态申请设备号*/
    {
        result = alloc_chrdev_region(&devno, 0, 1, "globalmem");
        globalmem_major = MAJOR(devno);
    }
    if (result < 0)
       return result;
    
    /*动态申请设备结构体的内存*/
    globalmem_devp = kzalloc(sizeof(struct globalmem_dev), GFP_KERNEL);
    if (!globalmem_devp) /*申请失败*/
    {
        result = - ENOMEM;
        goto fail_malloc;
    }
    memset(globalmem_devp, 0, sizeof(struct globalmem_dev));
    globalmem_setup_cdev(globalmem_devp, 0);
    return 0;
fail_malloc: unregister_chrdev_region(devno, 1);
    return result;
}
void globalmem_exit(void)
{
    cdev_del(&globalmem_devp->cdev); /*注销 cdev*/
    kfree(globalmem_devp);              /*释放设备结构体内存*/          
    //unregister_chedev_region(MKDEV(globalmem_major, 0), 1);/*释放设备号*/
}
MODULE_AUTHOR("Song Baohua");
MODULE_LICENSE("Dual BSD/GPL");
module_param(globalmem_major, int, S_IRUGO);
module_init(globalmem_init);
module_exit(globalmem_exit);

```



### Tiny4412设备驱动学习

tinny4412_leds.c

```c++
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/miscdevice.h>
#include <linux/fs.h>
#include <linux/types.h>
#include <linux/moduleparam.h>
#include <linux/slab.h>
#include <linux/ioctl.h>
#include <linux/cdev.h>
#include <linux/delay.h>
 
#include <linux/gpio.h>
#include <mach/gpio.h>
#include <plat/gpio-cfg.h>


#define DEVICE_NAME "leds"

static int led_gpios[] = {
 EXYNOS4X12_GPM4(0),
 EXYNOS4X12_GPM4(1),
 EXYNOS4X12_GPM4(2),
 EXYNOS4X12_GPM4(3),
};

#define LED_NUM  ARRAY_SIZE(led_gpios)


static long tiny4412_leds_ioctl(struct file *filp, unsigned int cmd,
  unsigned long arg)
{
 switch(cmd) {
  case 0:
  case 1:
   if (arg > LED_NUM) {
    return -EINVAL;
   }

   gpio_set_value(led_gpios[arg], !cmd);
   //printk(DEVICE_NAME": %d %d\n", arg, cmd);
   break;

  default:
   return -EINVAL;
 }

 return 0;
}

static struct file_operations tiny4412_led_dev_fops = {
 .owner   = THIS_MODULE,
 .unlocked_ioctl = tiny4412_leds_ioctl,
};

static struct miscdevice tiny4412_led_dev = {
 .minor   = MISC_DYNAMIC_MINOR,
 .name   = DEVICE_NAME,
 .fops   = &tiny4412_led_dev_fops,
};

static int __init tiny4412_led_dev_init(void) {
 int ret;
 int i;

 for (i = 0; i < LED_NUM; i++) {
  ret = gpio_request(led_gpios[i], "LED");
  if (ret) {
   printk("%s: request GPIO %d for LED failed, ret = %d\n", DEVICE_NAME,
     led_gpios[i], ret);
   return ret;
  }

  s3c_gpio_cfgpin(led_gpios[i], S3C_GPIO_OUTPUT);
  gpio_set_value(led_gpios[i], 1);
 }

 ret = misc_register(&tiny4412_led_dev);

 printk(DEVICE_NAME"\tinitialized\n");

 return ret;
}

static void __exit tiny4412_led_dev_exit(void) {
 int i;

 for (i = 0; i < LED_NUM; i++) {
  gpio_free(led_gpios[i]);
 }

 misc_deregister(&tiny4412_led_dev);
}

module_init(tiny4412_led_dev_init);
module_exit(tiny4412_led_dev_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("FriendlyARM Inc.");


```























