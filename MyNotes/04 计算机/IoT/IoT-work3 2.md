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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《智能拉杆箱》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">作业</p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">物联网作业3</td>     </tr>
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
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-23</td>     </tr>
    </tbody>              
    </table>
</div>



<!-- 注释语句：导出PDF时会在这里分页 -->

## 任务目标

设计一套带有定位、指纹识别、自动上锁、丢失报警功能的智能拉杆箱，说明设计思路、采用技术和控制流程图

## 设计思路

定位：增加定位模块，利用定位技术实现定位。A-GPS识别到位置之后，发送信息数据到移动设备上。使用者可以实时使用app查看自己和行李箱的位置。

指纹识别：通过指纹传感器进行指纹信息的采集和识别，以指纹解锁的方式提高行李箱的安全性能。当识别指纹正确后，行李箱自动解锁。

自动上锁：通过压力传感器，识别到行李箱盖子关闭之后，自动上锁。

丢失报警：以定位技术为前提，识别到行李箱距离用户超过预定的距离值后，自动产生报警信号，用以提高行李箱的安全性能。

## 采用技术

定位：A-GPS辅助GPS定位技术

指纹解锁：指纹传感器

自动上锁：压力传感器

丢失报警：A-GPS辅助GPS定位技术+测距报警



A-GPS（Assisted GPS）即辅助GPS技术，它可以提高 GPS 卫星定位系统的性能。通过移动通信运营基站它可以快速地定位，广泛用于含有GPS功能的手机上。GPS通过卫星发出的无线电信号来进行定位。
<img src="https://s1.vika.cn/space/2022/06/23/35a256cfd45e4d18bcb7aef66baf0bdd" alt="image-20220623110905723" style="zoom:40%;" />



## 控制流程图

```mermaid
graph TD;
1[行李箱控制按钮面板]
2.1[fun1:指纹管理]
2.2[fun2:识别指纹]
2.3[fun3:自动上锁]
f4[fun4:定位 & 丢失报警]
1-->2.1
1-->2.2
1-->2.3
1-->f4

2.1.3[按压Button1录入]
2.1.3.1[按压Button2删除]
2.1.4[手指放到指纹传感器上]
2.1.4.1[选择删除的指纹编号]
2.1.5[进行录入]
2.1.5.1[进行删除]
2.1.6[提示Success信息]
2.1-->2.1.3-->2.1.4-->2.1.5-->2.1.6
2.1-->2.1.3.1-->2.1.4.1-->2.1.5.1-->2.1.6

2.2.3[手指放到指纹传感器上]
2.2.4[解锁]
2.2 --> 2.2.3 -->2.2.4

f3-1[关闭行李箱]
f3-2[压力传感器识别]
f3-3[达到标准自动上锁]
2.3 --> f3-1 --> f3-2 --> f3-3

f4-1.1[A-GPS定位人]
f4-1.2[A-GPS定位箱子]
f4-2[位置app]
f4-3[计算人-箱位置]
f4-4[超过距离阈值报警]
f4-->f4-1.1-->f4-2
f4-->f4-1.2-->f4-2
f4-2-->f4-3-->f4-4
```

