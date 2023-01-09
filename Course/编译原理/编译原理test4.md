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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《LR(K)语法分析》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">编译原理第四次实验</td>     </tr>
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

# 实验四   LR(K)语法分析

## 实验目的

运用LR（K）语法分析的基本原理实现对于句子的语法分析
## 实验要求

1、输入的文法须是LR（0）文法。

2、该文法的LR（0）分析表由用户输入，请自行设计相应的数据结构。

## 实验内容

1、输入一个LR（0）文法及其对应的LR（0）分析表

2、输入一个字符串，运用LR（K）分析算法判断它是否为该文法的一个句子。

### LR(0)项目集规范族的构造

1. 改造文法，引入唯一的“接收态”产生式 S’ -> S

2. 计算 Closure(I) 和 Go(I,X)

   Go(I,x) = Closure(J)，其中 J = {任何形如A->$\alpha x\cdotp \beta$ | A->$\alpha \cdotp x\beta$ 属于I}

   直观上说，若 I 是对某个活前缀 $\gamma$ 有效项目集，那么Go(I,x)便是对 $\gamma x$ 有效的项目集

3. 以 {Closure({S’->S})} 为状态0，利用Go函数吧项目集连成一个DFA转换图

4. 按照以下规则构造 Action 子表和 Goto 子表

   1. 若项目 $A$->$\alpha \cdotp \beta$ 属于 $I_k$ 且 $Go(I_k,a)=I_j$, $a$为终结符，则 $Action[k,a]=S_j$
   2. 若项目 $A \rightarrow \alpha \cdotp$ 属于 $I_k$ ，那么对于任何终结符 $a$（或结束符 # ），$Action[k,a] = \gamma_j$
   3. 若项目 $S’ \rightarrow S\cdotp$ 属于 $I_k$， $Action[k,\#] = acc$
   4. 若 Go(I_k,A) = I_j, A为非终结符，则 Goto[k,A] = j
   5. 空白格为出错标志。

## 实验过程

### 输入输出

本次实验不要求从开始分析一个LR(0)的文法，只要求用户输入构造分析表之后，再输入一个字符串交给程序判断即可

### 数据结构

1. `char LR0[][50][100]`

存放LR0分析表，提前固定好，例如：
```c++
char LR0[50][50][100] = {{"S2"   ,"S3"   ,"null", "null" ,"null" ,"1"    ,"null" ,"null"},///   0
                         {"null" ,"null" ,"null", "null" ,"acc " ,"null" ,"null" ,"null"},///   1
                         {"null" ,"null" ,"S4"  , "S10"  ,"null" ,"null" ,"6"    ,"null"},///   2
                         {"null" ,"null" ,"S5"  , "S11"  ,"null" ,"null" ,"null" ,"7"   },///   3
                         {"null" ,"null" ,"S4"  , "S10"  ,"null" ,"null" ,"8"    ,"null"},///   4
                         {"null" ,"null" ,"S5"  , "S11"  ,"null" ,"null" ,"null" ,"9"   },///   5
                         {"r1"   ,"r1"   ,"r1"  , "r1"   ,"r1"   ,"null" ,"null" ,"null"},///   6
                         {"r2"   ,"r2"   ,"r2"  , "r2"   ,"r2"   ,"null" ,"null" ,"null"},///   7
                         {"r3"   ,"r3"   ,"r3"  , "r3"   ,"r3"   ,"null" ,"null" ,"null"},///   8
                         {"r5"   ,"r5"   ,"r5"  , "r5"   ,"r5"   ,"null" ,"null" ,"null"},///   9
                         {"r4"   ,"r4"   ,"r4"  , "r4"   ,"r4"   ,"null" ,"null" ,"null"},///   10
                         {"r6"   ,"r6"   ,"r6"  , "r6"   ,"r6"   ,"null" ,"null" ,"null"},///   11
                          };
```



2. `stack`

分为两个栈，分析句子时使用。符号栈和数据栈

```c++
stack<int>con;    ///状态栈
stack<char>cmp;   ///符号栈
```



### 实验过程

1. 将分析表输入，预先保存起来不用从文法表达式构造分析表.

2. 输入待判断的句子

3. 根据LR(0)分析方法分析句子。

   1. 需要Action和GOTO表。

   2. 当遇到规约项目的时候，查看产生式右部有k个字符，就需要在字符栈和状态栈pop几个字符。

   3. 产生式左部入栈

      ```c++
      [6] B -> ·d
      符号栈：pop(d), push(B)
      状态栈：pop()
      ”目前状态栈顶 + 左部“ 查表 goto(B) = k
      状态栈 push(k)
      ```

      

### 实验结果

输入：分析表
<img src="https://s1.vika.cn/space/2022/06/25/a4da5c0141a04fcf97e03c68d17afc29" alt="image-20220625084050748" style="zoom:100%;" />

输入待判断的句子：`bccd#`

输出：判断的过程和结果
<img src="https://s1.vika.cn/space/2022/06/25/d724b7bfc4de4c679c5f03cb439865fa" alt="image-20220625084139110" style="zoom:100%;" />

## 实验总结

LR语法分析是一种自底向上进行规范规约的语法分析方法

实质：是一个带先进后出存储器（栈）的确定有限状态自动机

L：从左到右扫描输入串
R：构造一个最右推导的逆过程

四个操作动作：移进、规约、接受、报错

文法的LR(0)项目规范族：构成识别一个文法活前缀的DFA项目集的全体

规约项目（==$\cdotp$ 在最后==）：$A \rightarrow \alpha \cdotp$ 
接受项目（==开始文法对应的==）：$S' \rightarrow \alpha \cdotp$
移进项目（==$\cdotp$后面是终结符==）：$A \rightarrow \alpha \cdotp a\beta, (a \in V_T)$
待约项目（==$\cdotp$后面是非终结符==）：$A \rightarrow \alpha \cdotp B\beta, (B \in V_N)$

这只是最简单的一种情况，只能处理没有移进-规约冲突和规约-规约冲突的情况。
