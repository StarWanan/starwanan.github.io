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
    <span style="font-family:华文黑体Bold;text-align:center;font-size:20pt;margin: 10pt auto;line-height:30pt;">《2.4G有源RFID数据读取实验》</span>
    <p style="text-align:center;font-size:14pt;margin: 0 auto">实验报告 </p>
    </br>
    </br>
    <table style="border:none;text-align:center;width:72%;font-family:仿宋;font-size:14px; margin: 0 auto;">
    <tbody style="font-family:方正公文仿宋;font-size:12pt;">
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">题　　目</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 物联网第四次实验</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">上课时间</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> 2022-6-13</td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">授课教师</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">姓　　名</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">学　　号</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">组　　别</td>
    		<td style="width:%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋"> </td>     </tr>
    	<tr style="font-weight:normal;"> 
    		<td style="width:20%;text-align:right;">日　　期</td>
    		<td style="width:2%">：</td> 
    		<td style="width:40%;font-weight:normal;border-bottom: 1px solid;text-align:center;font-family:华文仿宋">2022-6-13</td>     </tr>
    </tbody>              
    </table>
</div>


<!-- 注释语句：导出PDF时会在这里分页 -->



# 实验报告

## 实验目的

有源RFID，又称为主动式RFID（Active tag），依据电子标签供电方式的不同进行划分的电子标签一种类型，通常支持远距离识别。电子标签可以分为有缘电子标签
(Active tag)、无源电子标 签(Passive tag)和半无源电子标签(Semi-passivetag)。有源电子标签内装有电池，无源射频标签没有内装电池，半无源电子标签(Semi-passive tag)部分依靠电池工作。

本次实验的目的就是了解2.4G有源卡的读取。

## 实验内容

1. 将读卡器和标签通电
2. 读卡器连接电脑
3. 使用串口工具获取数据

## 实验过程

1. 将读卡器接电，将标签连接好电池。

2. 用公母直连线连接电脑串口和有源2.4G节点的DB9接头，S1开关拨打到左边，让DB9和2.4G读卡器相连。

   ![1](https://s1.vika.cn/space/2022/06/13/80d60c1516a6439aa50ff33f8376d154)

3. 打开串口调试助手，端口为COM5，波特率为9600，数据位为8，停止位为1，无校验位。设置好后打开串口，标签自动向读卡器发信息。

   ![2](https://s1.vika.cn/space/2022/06/13/11722541c067440f8e61ce0019eb7b56)

## python实现

本次实验代码较为简单，只需设置好串口参数，使用serial模块进行读取即可。

```jsx
from pickle import TRUE
import serial #导入模块
import binascii, time
import sys
import tkinter as tk
bps=9600
timex=None

ser=serial.Serial("COM5",bps,timeout=timex)
window = tk.Tk()
window.title('2.4G有源RFID数据读取') # 设置窗口的标题
window.geometry('600x480') # 设置窗口的大小
l = tk.Label(window,text='')
l.pack()
l0 = tk.Label(window,text='')
l0.pack()
text1 = tk.Text(window, width=100, height=50)
text1.pack()
l1 = tk.Label(window,text='')
l1.pack()

def refresh():
    strs = ''
    count = ser.inWaiting()
    data = b''
    if count > 0:
        data = ser.read(count)
    if data != b'':
        strhex = str(binascii.b2a_hex(data))
        strhex = strhex[1:]
       
        cnt = 1
        for i in strhex:
            print(i)
            strs += i.upper()
            if cnt%2 != 0:
                strs += ' '
            cnt = cnt+1
    strs += '\n'
    text1.insert(tk.END, strs)
    text1.update()
    window.after(1000,refresh)
window.after(1000,refresh)
window.mainloop()
```

## 实验总结

本次实验为《物联网工程》课程的第四次实验，2.4G 有源RFID 数据读取实验-V20170317。实验要求了解2.4G 有源卡的读取，并且编写python 程序来监控串口接收的数据将其在GUI界面显示出来。
这次实验的步骤非常简洁，同时，由于这已经是物联网的第四次实验，我们已经有了设备使用经验，所以能够在实验指导书的指导下快速地完成实验。
通过此次实验，我们体会到了有源2.4G 节点读卡的过程，以及进行了数据的析。并且通过观看指导视频，我们还了解到了该模块的现实使用和ETC 的一些基本原理。