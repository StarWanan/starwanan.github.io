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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《LL(1)语法分析》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">编译原理第二次实验</td>     </tr>
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

# 实验二  LL（1）语法分析

## 实验目的

运用LL(1)语法分析的基本原理实现对于句子的语法分析

## 实验要求

1、文法由用户输入（注意：ε符号由@代替，文法中的“定义为”符号位->）

2、数据结构的定义

（1）产生式的数据类型定义如下：

```c++
typedef struct producion
{
    char left;
    char right[MAXSIZE];
} production;
```

（2）非终结符的first集合的数据类型定义如下：

```c++
typedef struct first
{
    char ch;
    char firstSet[MAXSIZE];
}first;
```

（3）非终结符的follow集合的数据类型定义如下：

```c++
typedef struct follow
{
    char ch;
    char followSet[MAXSIZE];
}follow;
```

（4）终结符号集合

   字符数组ts;

（5）非终结符号集合

   字符数组nts;

（6）文法

   production数组 gram;//注意：设产生式为6条

（7）select集合

  二维字符数组Select; 

（8）LL(1)分析表

  二维整型数组 lllist; //元素的值为0~5,即产生式在garm数组的下标； 

## 实验内容

1、任意输入一个文法，判断它是否为LL(1)文法

2、如果是一个LL(1)文法，请构造该文法对应的LL(1)分析表; 如果不是，请输出“该文法不是LL(1)文法”。

3、输入一个字符串，请用LL(1)分析算法判断它是否为该文法的一个句子。

## 实验过程

### 输入输出

输入：一个文法的所有表达式作为一个文件输入

输出：该文法的First集、Follow集

### 数据结构

1. `set<string> Vns, Vts, Vs;` 

Vns表示非终结符的集合，Vts表示终结符的集合, Vs是所有字符的集合

2. `map<string, set<string>> first;`

first集合

3. `map<string, set<string>> follow; `

follow集合

4. `pair<string, vector<string>> exps[N];`

存储文法的表达式

### 实现思路

1. 根据输入文法，求出该文法的First集和Follow集
2. 根据First和Follow，根据所有能推导出多个产生式的非终结符的表达式，判断该文法是否符合LL(1)文法的要求，如不符合要求，则提示并退出程序
3. 如果是LL(1)文法，构造分析表
4. 输入一个字符串，利用构造好的分析表，判断是否是该文法的一个句子

#### First集计算规则：

First需要看产生式的左部

- 若右部第一个是终结符，则加入集合
- 若右部第一个是非终结符，则将其First集加入集合

#### Follow集计算规则

Follow集需要看产生式右部

- 文法开始符，必有#
- 情况一(后面没东西)：A -> $\alpha B$ FOLLOW(B) B后为空，则将FOLLOW(A)加入到FOLLOW(B)中
- 情况二(后面有东西)：A -> $\alpha B\beta$ 
  - $\beta$ 是终结符，直接写下来
  - $\beta$ 是非终结符，first($\beta$) ==除去$\epsilon$== 加入到follow(B)
  - 如果 $\beta \rightarrow \epsilon$ ，则转回情况一

#### 判断文法是否是LL(1)

分析条件（判断一个文法是LL(1)文法）：

1. 文法不含左递归
2. 对于文法中每一个非终结符$A$的任意两产生式$\alpha_i$ 和 $\alpha_j$，即这种情况：$A \rightarrow \alpha_i | \alpha_j$
   1. 若候选首符集不包含 $\epsilon$ : $First(\alpha_i) \cap First(\alpha_j) = \phi$
   2. 若它存在某个候选首符集包含 $\epsilon$, 则 $First(A) \cap Follow(A) = \phi$

引出Select集：$A \rightarrow a, A\in V_N, a\in V^*$

1. $\alpha \stackrel{*}\Rightarrow \epsilon$ : $Select(A\rightarrow \alpha) = (First(\alpha)-\epsilon) \cup Follow(A)$
2. $\alpha \stackrel{*}\nRightarrow \epsilon$ : $Select(A\rightarrow \alpha) = First(\alpha)$

所以LL(1)文法的满足条件是：

对于每个非终结符 A 的任意两条产生式，都满足==$Select(A\rightarrow \alpha) \cup Select(A\rightarrow \beta) = \phi$==

#### 分析表构造规则

1. 对文法 $G$ 的每个产生式 $A \rightarrow \alpha$ 执行2，3 【根据产生式构造分析表】
2. 对每个终结符 $a \in First(\alpha)$，把 $A \rightarrow \alpha$ 加至 $M[A,a]$
3. 若 $\epsilon \in First(\alpha)$，即能推出空串，则对任何 $b\in Follow(A)$ 把 $A \rightarrow \alpha$ 加至 $M[A,b]$
4. 把所有无定义的 $M[A,a]$ 标上“出错标志”

### 实验结果

输入文件：
<img src="https://s1.vika.cn/space/2022/06/25/311be15af7a24c6c89486b4f120fda7b" alt="image-20220625044554861" style="zoom:50%;" />

输出结果：
<img src="https://s1.vika.cn/space/2022/06/25/3f67a38bd8674867aeb7377307bbfc79" alt="image-20220625044616864" style="zoom:50%;" />

判断字符串是否属于该句型的一个句子：
<img src="https://s1.vika.cn/space/2022/06/25/717dd57d59534d1ba371de3b26b9c0cb" alt="image-20220625090827856" style="zoom:80%;" />

## 实验总结

本次实验的内容是实现LL1文法分析程序。LL1文法的内容虽然比较简单，但是实现的时候仍然会有很大的困难，对于使用什么样子的数据结构存储表达式、First集、Follow集、构造分析表都是在设计阶段遇到的困难。

经过代码实践，对于理论课程中的理论部分有了更深的理解和掌握。

本次实验的代码量相比较第一次实验来说是很大的，实现起来也比较困难，所以之后还需要用实验强化理论知识的理解。
