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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《词法分析器》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">编译原理第一次实验</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">汪毅</td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-24</td>     </tr>
    </tbody>              
    </table>
</div>



<!-- 注释语句：导出PDF时会在这里分页 -->

# 实验一  简单的C语言词法分析器的实现

## 实验目的

设计、编制并调试一个简单的c语言词法分析程序，加深对词法分析原理的理解

## 实验要求

1. 对单词的构词规则有明确的定义；

2. 编写的分析程序能够正确识别源程序中的单词符号；

3. 识别出的单词以（单词符号，种别码）的形式保存在符号表中。

​    

## 实验内容

词法分析中的输入为一个C语言程序文件，该文件由如下关键字、运算符、界限符、常量、标识符中的符号构成，将该程序经词法分析后，形成的单词序列，并保存在一个文本文件（.txt）中。

### 1. 单词的种类及组成

（1）关键字

 if else while do for  main return  int  float double char 

所有的关键字都是小写。

（2）运算符

 = + - * /  % < <=  > >=  != = = 

（3）界限符

;  ( ) { }

（4）常量

无符号整形常量，通过以下正规式定义：

dight dight*

（5）标识符（ID），通过以下正规式定义：

 letter (letter | digit)*

（6）空格有空白、制表符和换行符组成。空格一般用来分隔标识符、整数、运算符、界符和关键字，词法分析阶段被忽略。

 

### 2. 各种单词符号对应的类别码

| **单词符号**             | **类别码** | **单词符号** | **类别码** |
| ------------------------ | ---------- | ------------ | ---------- |
| main                     | 1          | >=           | 16         |
| if                       | 2          | <            | 17         |
| else                     | 3          | < =          | 18         |
| wile                     | 4          | = =          | 19         |
| do                       | 5          | !=           | 20         |
| for                      | 6          | =            | 21         |
| return                   | 7          | ；           | 22         |
| lettet（letter\|digit）* | 8          | (            | 23         |
| dight  dight*            | 9          | )            | 24         |
| +                        | 10         | {            | 25         |
| —                        | 11         | }            | 26         |
| *                        | 12         | int          | 27         |
| /                        | 13         | float        | 28         |
| %                        | 14         | double       | 29         |
| >                        | 15         | char         | 30         |

 

## 实验过程

### 输入输出形式

输入：一个C语言文件。

输出：将C语言文件中的所有内容编程预先设置好的类别码，保存在txt文件中。

### 数据结构

1. `unordered_map<string,int>` 

使用哈希表对应C语言中各种关键字与类别码。具体如下：

```c++
id["main"] = 1;		id["if"] = 2; 		id["else"] = 3;
id["while"] = 4; 	id["do"] = 5; 		id["for"] = 6;
id["return"] = 7; 	id["+"] = 10; 		id["-"] = 11;
id["*"] = 12; 		id["/"] = 13; 		id["%"] = 14;
id[">"] = 15; 		id[">="] = 16; 		id["<"] = 17;
id["<="] = 18; 		id["=="] = 19; 		id["!="] = 20;
id["="] = 21; 		id[";"] = 22; 		id["("] = 23;
id[")"] = 24;		id["{"] = 25;		id["}"] = 26;
id["int"] = 27;		id["float"] = 28;	id["double"] = 29;
id["char"] = 30;
```

2. `string`

用于存储C语言文件中的一行内容

### 实现思路

1. 打开C语言文件，放到标准输入。同时将标准输出保存为一个txt文件
2. 每一行进行读入，作为一个字符串
3. 逐个分析是否有关键字，将结果输出。

### 实验结果

读入文件：
<img src="https://s1.vika.cn/space/2022/06/24/8ad59b3b432243569a88685d66414db1" alt="image-20220624231226380" style="zoom:50%;" />



输出文件：
<img src="https://s1.vika.cn/space/2022/06/24/cb22c15891b84e0b87702e72ab8f7c36" alt="image-20220624231244687" style="zoom:50%;" />

## 实验总结

本次实验的内容比较简单，使用到的数据结构也不是很多。能够分析对应关键字的C语言程序。

实现的思路是直接暴力的实现，并不是非常高效。

本次实现的词法分析器都需要开始的预先定义，所以并不能实现识别`# include <iostream>`等内容。

以后的改进可以从实现方法、算法执行效率这两个方向进行改进。

