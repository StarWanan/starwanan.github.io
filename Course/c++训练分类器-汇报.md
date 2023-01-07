[TOC]

## 一、算法原理

### 1. 数据

`X`：是随机生成的符合标准正态分布的形状为`(2*num, 2)`的二维矩阵，表示总共 2 * num 个点的每一个点的二维坐标。并对前num个数据每一维分别+1，后num个数据每一维分别-1 （为了让两类点在空间中更有区分度，便于分类）。

`y`：是一个大小为`(2*num)`的一维矩阵，表示数据的真实标签，其中前num个点的标签为1，后num个点的标签为0。

`w_init`：是一个随机生成的符合标准正态分布的1*2的二维矩阵。

### 2.  函数说明

#### (1) train训练函数

```cpp
1）double* train(double X[][2],double y[],double w[],double lr)
作用：用一层神经网络训练模型
参数：数据X，标签y，参数矩阵w，学习率 lr
返回：训练后的参数矩阵w
```

==分析==：该训练函数是运用一层神经网络来对二维的数据X进行二分类，且这里面的b为0，b为0的原因我仔细想了一下，因为X的数据是一个符合N（0，1）的标准正态分布，所以数据X是主要集中在0附近的，当对一般的数据做（+1，+1）操作，另一半数据做（-1，-1）操作时，实际上就是对其中一半的数据向左上方移动，另一半的数据向右下方移动，因此用一个过原点的线将他们分开是比较合理的选择。其神经网络结构如下图所示：

![image-20220507084529736](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507084529736.png)

其中 x1， x2 分别代表一个点的坐标的两维，w1， w2 分别带白哦权重矩阵的两个维度。具体过程如下：

1. 权重矩阵与数据进行运算：$z = \sum_{i=1}^{d}w_ix_i = w^Tx$

2. logistic激活函数：$\hat{Y} = \sigma(z) = \dfrac{1}{1+exp(-z)}$

3. 损失函数Loss：$Loss = \frac{1}{2}(y - \hat{y})^2$

   > 激活函数与损失函数根据代码中的反向求导梯度更新权重矩阵推断出来
   >
   > `w = w + lr * x.reshape((2, 1)) * y_predict * (1 - y_predict) * (y[k] - y_predict`

其中logistic（sigmoid）函数求导过程为：

令 $y = \frac{1}{1 + e^{-x}} = (1 + e^{-x})^{-1}$

$\begin{align}
\frac{dy}{dx} =& -1 * (1 + e^{-x})^{-2} * e^{-x} * (-1) \\
=& e^{-x} * (1 + e^{-x})^{-2} \\
=& \frac{1 + e^{-x} - 1}{(1 + e^{-x})^2} \\
=& (1 + e^{-x})^{-1} - (1 + e^{-x})^{-2} \\
=& y - y^2 \\
=& y(1-y)
\end{align}$

具体改写代码如下：

```cpp
//训练函数
double* train(double X[][2],double y[],double w[],double lr)
{
    int n=2*num;
    int d=2;
    for(int i=0;i<epochs;i++)
    {
        int k=rand()%n;	//函数用于生成0和参数 n-1之间的任意整数
        double x[2];
        for(int j=0;j<2;j++) x[j]=X[k][j];
        //w是一个2*1的数组,x取的是一个一维数组1*2
        double y_predict = predict(x, w);

        for(int j=0;j<2;j++)
        {
            //用于更新w值
            //损失函数为1/2（y-y_predict)^2!!!
            //if(y_predict>0) w[j] += lr * x[j]* (y[k]-y_predict);
            w[j] += lr * x[j] * y_predict * (1-y_predict) * (y[k]-y_predict);
            //w[j] += lr * x[j] *2* y_predict * (1-y_predict) * (y[k]-y_predict);
        }
        //printf("lr: %lf, y_p: %lf, y: %lf\n", lr, y_predict, y[k]);

        //输出loss值
        cout<<"loss: ";
        cout<<eval(X, y, w)<<endl;
        //cout<<"w: "<<w[0]<<" "<<w[1]<<endl;
    }
    return w;
}
```

#### (2) 前向传播，计算 y_predict

```cpp
2）double predict(double x[],double w[])
作用：计算向神经网络输入数据x和参数w后得到的y的值
参数：数据x和参数矩阵w
返回：y的预测结果
```

==分析==：该函数的作用就是计算向神经网络输入数据x和参数w后得到的y的值。在代码复现中为此写了一个`mul()`函数进行矩阵乘法运算。

具体代码如下：

```cpp
//预测函数
double predict(double x[],double w[])
{
    double z=mul(x,w);
    double y = 1.0 / (1 + exp(-z));	//激活函数sigmoid
    // double y = max(0.0,z);      	// Relu
    // double y = 2.0 / (1 + exp(-2*z))-1;
    return y;
}
```

#### (3) 评估函数

```cpp
3）int eval(double X[][2],double y[],double w[])
作用：计算预测错误的数据的数量
参数：数据X，y以及参数矩阵w
返回：预测结果与实际结果不相符的数量
```

==分析==：该函数的作用就是计算loss的值，这里把阈值设为了0.5，大于0.5的就全部当作1来看，小于等于0.5的就当作0来看，从而与y的真实值对比，预测错误就将loss的值 + 1，并最终返回loss。在该函数中也调用了矩阵相乘，但因为传入的参数维度与 `mul()` 函数中参数不同，于是我又写了一个 `mul1()` 函数。

具体代码如下：

```cpp
//用于计算loss的值的函数
int eval(double X[][2],double y[],double w[])
{
    double *y_predict=mul1(X,w);

    int loss=0;
    for(int i=0;i<num*2;i++)
    {
        //阈值为0.5
        if((y_predict[i]<=0.5&&y[i]>0.5)||(y_predict[i]>0.5&&y[i]<=0.5)) loss++;
    }
    return loss;
}
```

#### (4) 矩阵相乘

```cpp
4）double* mul1(double a[][2],double b[])
作用：实现矩阵相乘，这个函数实现的是当a是一个二维数组的情况下的矩阵相乘
参数：进行矩阵相乘的数组a和b
返回：矩阵相乘后的结果，是一个一维数组
```

==分析==：该函数的作用就是实现矩阵相乘，是为 `eval()` 函数所写。

```cpp
5）double mul(double a[],double b[])
作用：实现矩阵相乘，这个函数实现的是当a是一个一维数组的情况下的矩阵相乘
参数：进行矩阵相乘的数组a和b
返回：矩阵相乘后的结果，是一个值
```

==分析==：该函数的作用也是矩阵相乘，是为 `predict()` 函数所写。

具体代码如下：

```cpp
//predict函数中的矩阵相乘
double mul(double a[],double b[])
{
    return a[0]*b[0]+a[1]*b[1];
}

//eval函数中的矩阵相乘
double* mul1(double a[][2],double b[])
{
    double ans[num*2]={0};
    for(int i=0;i<num*2;i++)
    {
        double tem=0;
        for(int j=0;j<2;j++)
        {
            tem+=a[i][j]*b[j];
        }
        ans[i]=tem;
    }
    return ans;
}
```



### 3. 主函数说明

在主函数中主要实现了两个功能：

1. 初始化`X`, `y`, `w_init`
2. 调用 `train()` 函数。

#### 1. 初始化

```cpp
default_random_engine e;		// 随机数引擎
normal_distribution<double> u(0, 1);	// 随机数分布，符合(0,1)正态分布
```

`X`：对于X的初始化我是用了u(e)结合双层for循环对每个`X[i][j]`赋值。同时对i小于num的情况对结果+1处理，对i大于等于num的情况对结果-1处理，使得两类点位置进行偏移便于分类。

`y`：对y初始化就是用的 `fill()` 函数，这里用 `memset()` 函数可能会更快一点，但那是在数组很大的情况下，所以在本代码下差距并不明显。

`w_init`：对于w的初始化同上面X，这里调用了两次u(e)函数。

#### 2. 调用train()函数进行训练

这里需要注意的是，传参数进去后，因为w参数是数组，传参时是数组首地址，相当于指针。因此在函数里面对 w[] 做出的改变会影响到`w_init[]`,导致我们输出返回的 `w[]` 和 `w_init[]` 做对比时发现值是一样的，因此我们可以在train函数里面重新定义一个 `w[]` ,并赋值，当然我这里是直接先输出原来的 `w_init[]`，再进行训练。





## 二、算法流程图

![未命名文件(12)](https://gitee.com/zyxstar/Pic_bed/raw/master/image/%E6%9C%AA%E5%91%BD%E5%90%8D%E6%96%87%E4%BB%B6(12).png)

## 三、测试分析程序

python程序运行结果：

![image-20220507095130879](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095130879.png)

最后结果是收敛到 loss=11,可以看到w_init的值为[-0.36604431, 0.40955051] ，训练后的值为[1.11668552，1.04533407]

C++程序运行结果：

![image-20220507095355468](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095355468.png)

![image-20220507095406313](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095406313.png)

最后结果是收敛到loss=19,可以看到w_init的值为[-0.339101, -0.0323489]，训练后的值为[1.37939, 1.30006]

==分析==：对比发现两个文件的训练结果相差不大，一个正确率在94.5%，另一个正确率在90.5%，在可以容忍的范围内，对比可以发现两个文件初始化的w_init值不同，这也可能是误差原因之一，两个文件的seed(200)所代表的种子不同（当把C++的种子设为50时，loss的值变成了18），因此我们可以认为复现的程序是正确的。

在C++程序中将 `w_init` 初始化为与python程序中相同的数值，发现运行结果如下：

![image-20220507095733409](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095733409.png)

![image-20220507095825220](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095825220.png)

发现效果达到更好，所以权重矩阵的初始化对于最后的结果有着很重要的影响。

## 四、运行时间对比

python运行时间如下：

![image-20220507095950308](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507095950308.png)

C++运行时间如下：

1. 运行环境一：windows10 + codebocks

   ![image-20220507100055289](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507100055289.png)

2. 运行环境二：MacOS + vscode

   ![image-20220507100123246](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507100123246.png)

==分析==：由对比结果可以看出C++程序的速度受到设备的影响比较大，设备二是很明显的看出C++程序的运行速度大于py的运行速度，是py的速度30倍，但设备一中C++程序的运行速度小于py的运行速度，是py的速度的75%左右。

**C++程序还是有很多优化的空间，比如：** （均在Windows + codeblocks的环境下改进）

1. 在本道题的背景下，我们是可以因为先验信息主观的知道两类数据一类在原点的左上方向，另一类在右下方向，这里原因在上述算法原理中的train（）中有分析到，因此我们在设置w的初始值时便可以有意的设置为{1，1}，从而减少本个程序中的时间消耗，使loss快速收敛，从而减少训练轮数，可以看出时间从0.45s减少到0.19s。

   ![image-20220507100427502](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507100427502.png)

2. 学习率，适当的将步长增大也可以加快收敛速度从而达到加速的效果，可以看出时间从0.45s减少到0.27s

   ![image-20220507100435421](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507100435421.png)

3. 矩阵相乘，这个在本程序上并不明显，但当数据量比较大时，我们可以从硬件上考虑优化时间。计算机组成课上讲过内存访问不连续会导致cache命中率不高。也会造成矩阵乘法。所以为了加速，就要尽可能使内存访问连续，即不要跳来跳去。

   因此矩阵相乘时按ikj顺序循环的速度要快于按ijk的顺序循环。

   ![image-20220507100444343](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507100444343.png)

   ![image-20220507120603742](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507120603742.png)

4. 激活函数，分别将激活函数换成了tanh函数和ReLu函数，训练结果都变得更差了，相对来说sigmoid激活函数的训练效果更好。推测是神经网络层数很小，并不会出现梯度消失的情况；而且样本较为简单，不容易发生过拟合。所以ReLu的优势并不是特别明显，甚至效果略差

## 五、结果可视化

可视化python程序：将输出保存到txt文件，之后读取之后进行画图

```python
import numpy as np
import matplotlib.pyplot as plt
import pylab as pl
from mpl_toolkits.axes_grid1.inset_locator import inset_axes
data_loss =np.loadtxt("train.txt")  
x = data_loss[:,0]
y = data_loss[:,1]

pl.plot(x,y,'g-',label=u'loss')
pl.legend()

pl.xlabel(u'iters')
pl.ylabel(u'loss')
plt.title('loss in training')
```

![image-20220507130322203](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507130322203.png)

分析：下面的图和老师发的不太一样，因为w_init的初始值不太一样，在py中w_init的两个维度一正一负，因此是一个上升的直线，而种子seed（200）在C++中随机生成的为两个正值，所以无论是w_init(蓝色）还是w（绿色）均为下降的直线。本图使用到了Visual C++编译器以及`#include <graphics.h>`头文件，剩下的代码为自行添加的，自行加了一个`graph2d.cpp`和`graph2d.h`来供test1.cpp文件调用，运行时只需要运行test1.cpp文件即可。画图时，散点是采用for循环的方式画出的，而两条直线是通过所给w的两个维度调用自己所写函数`fun()`来求出直线上的一个点，利用两点连成一条直线的方式画出。

文件结构如下：

![image-20220507115758389](../../../Application%20Support/typora-user-images/image-20220507115758389.png)

关键代码如下：

散点图：

![image-20220507115806250](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507115806250.png)

两条直线：

![image-20220507115828770](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507115828770.png)

可视化结果如下：

![image-20220507115843954](https://gitee.com/zyxstar/Pic_bed/raw/master/image/image-20220507115843954.png)





## 六、心得体会

本次考核任务是我于6号上午开始，前前后后到现在写了十个小时，前期就是在看老师发的python文件，代码比较短，复现起来比较简单，所以复现过程还是比较迅速的，，这途中又深深的体会到了python的方便之处，C++对数据的格式要求更加严格一点。

整个项目最大的困难在于画图，有将近七个小时我都在搞画图，因为C++标准库里是没有画图工具的（浏览资料时我一度想要把所有图信息写入一个二维数组（相当于像素点），将不同类的点用不同符号表示，最后输出整个二维数组，最终理智拉回了我，我还是老老实实的去寻找画图工具），于是我看到了一个博主的文章，这个文章大概意思是我需要先下载一个vC++的编译器，然后再下载  ，这个下载过程十分艰难，网络上很难找到这个软件，有些软件下载了却安装失败，终于最后下载了一个博主分享的网盘中的 2010版本，本以为这样就大功告成，但是发现很多图中需要的功能比如加坐标系，散点和函数都是没有的，于是我又开始找网上有没有博主写的类文件代码来实现该功能，找到了一些代码后发现受版本限制，我的编译器并不支持C++11，于是我通篇的改了整个头文件代码以此来实现我需要的函数调用。

在众多工作完成后我开始了报告的撰写工作，在这其中也多了很多思考，当然这些思考都写在了上述报告中，由此得到很大的感悟：

1. 无论是写代码还是做工程，做完之后写总结是很重要的，我的很多想法也是在撰写报告时实现了整合和以及走向了成熟；
2. 坚持是一个很美好的品质，很多时候一件事情成功与否只是在于你有没有坚持，回忆大学中做过的很多大作业，过程中总是充满了很多困难和代码bug难以解决，但坚持到最后都完成了，这次画图也一样，历尽艰难终于七个小时后画出来了，这时候再提到七个小时其实是自豪的！

以上是我对整个项目的报告，再次感谢老师肯给我这样一个宝贵的机会。

