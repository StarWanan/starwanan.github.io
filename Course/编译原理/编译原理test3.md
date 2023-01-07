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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《矩阵方法的简单优先语法分析》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">编译原理第三次实验</td>     </tr>
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

# 实验三 简单优先语法分析

## 实验目的

运用简单优先语法分析的基本原理实现对于句子的语法分析

## 实验要求

1、文法及待分析符号串由用户输入

2、数据结构可仿照实验二，自行设计

## 实验内容

1、任意输入一个文法，判断它是否为简单优先文法

2、如果是，请构造该文法对应的简单优先分析表

3、输入一个字符串，判断它是否为该文法的一个句子。

## 实验过程

### 输入输出

输入：一个文法的所有表达式的文件，一个字符串

输出：该文法的First关系矩阵、Last关系矩阵，字符串是否属于该文法的一个句子

### 数据结构

1. `pair<string, vector<string>> exps[N];`

存储文法的表达式

2. `int _eq[N][N], _last[N][N], _first[N][N];`

存储几种关系的矩阵

3. `map<string, map<string, int>> eq_, last_, first_;`

根据编号，找到对应的终结符或者非终结符符号

### 实现思路

与正常的简单优先分析思路相同：

1. 构造优先关系表
2. 根据优先关系表进行分析

但是不同之处再有构造优先关系表时，不使用LastVT和FirstVT的两个集合构建，而是利用矩阵方法实现优先关系。

#### 优先关系表

- $a \doteq b$：对形如 P -> …ab… 或 P -> …aQb… 的产生式
- $a \lessdot b$：对形如 P -> …aP…，有 $b \in Firstvt(P)$
- $a \gtrdot b$：对形如 P -> …Pa…，有 $a \in Lastvt(P)$

FirstVT：第一个终结符

LastVT：最后一个终结符

#### 构造优先关系表的算法

根据表达式：

1. 先找出所有 $a\doteq b$ 的终结符对。
2. 构造Fitstvt和Lastvt集合
   1. 若有产生式 P -> a… 或 P -> Qa…，则 $a \in Firstvt(P)$
   2. 若 $a \in Firstvt(Q)$, 且有产生式 P -> Q… 则 $a \in Firstvt(P)$
   3. 若有产生式 p -> …a 或 P -> …aQ，则$a \in Lastvt(P)$
   4. 若 $a \in Lastvt(Q)$, 且有产生式 P -> …Q 则 $a \in Lastvt(P)$
3. 检查每个产生式的候选关系确定满足 $\lessdot$ 和 $\gtrdot$ 的所有终结符对（已知永远小于未知）

#### 矩阵方法构建优先关系表

定义两种关系：First关系以及Last关系

1. A First B

$A \rightarrow Ba$, $A \in V_N$, $B \in V$,  则称 First = {<A,B>}

2. A Last B

$A \rightarrow \alpha B$, $A \in V_N$, $B \in V$,  则称 Last = {<A,B>}

分别对这两种偏序关系做正闭包，得到First+和Last+的关系。求闭包的算法使用`Warshall`算法

而对于两种优先关系来说，按以下方法计算：

- $\lessdot$ : $\doteq\ First^+$
- $\gtrdot$ : $(Last^+)^T\ \doteq\ First^*$

### 实验结果

输入：一个语法规则
<img src="https://s1.vika.cn/space/2022/06/25/7b3d9e52fa2b4722bbbd0878e78ceca1" alt="image-20220625074343520" style="zoom:50%;" />

输出：矩阵关系
<img src="https://s1.vika.cn/space/2022/06/25/fba8397e70654f97ab34b9d6fc6b6c12" alt="image-20220625074424178" style="zoom:50%;" />

输出：优先关系表
<img src="https://s1.vika.cn/space/2022/06/25/e2b928cab8654ac8b07d19c004564b22" alt="image-20220625075926211" style="zoom:50%;" />

输出：分析一个字符串是否属于该文法的句子
<img src="https://s1.vika.cn/space/2022/06/25/71b9cf030c41455c8f918eceb5744677" alt="image-20220625092502545" style="zoom:70%;" />

## 实验总结

本次实验是简单优先语法分析，属于自底向上的优先语法分析。但是和理论课上讲解的理论不同，在实验课上老师新讲了一种方法，是利用矩阵的方法实现优先关系表的构造。没有用到各种规则去构建，用矩阵的方法显得更加简单，不过也需要严谨的数学知识支持，经过多步证明之后才能实现。