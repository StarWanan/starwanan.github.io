# 基于RFID+WSN猪场养殖信息管理和环境监控综合系统



## 一、设计思路

在猪场养殖的场景中，面临的问题主要有以下几点：

1. 监测养殖场环境。需要确保养殖的猪可以在合适的环境下顺理成长。
2. 调整养殖场环境。现在大多数养殖场并没有实现自动化和智能化，而是靠人类经验去手动调节，需要大量的人力物力。
3. 猪场中猪的个体健康问题。需要检测猪的身体健康问题，否则会对肉质、安全造成影响。但是这一类问题并不容易被发现，往往是病重后才有人员进行医治。错过了最佳时间。
4. 牲畜中的流行疾病问题。一旦有个体感染疾病，将会导致大片养殖场的猪都被感染，造成严重的经济损失以及食品安全、人员安全问题。

针对于以上问题，可以利用现代计算机通信技术进行解决与升级，其中需要两个技术：

1. RFID，射频识别技术(radiofrequency identification)
2. WSN，无线传感器网络技术(wirelesssensor network)

对于每一头猪个体来说：

1. 可以采用对猪身上佩戴无线传感装置，实时对其体温、心跳、运动等参数进行监督，并通过无线传感器传输到服务节点上。

2. 其次，RFID技术可以对每一头猪进行精准识别，记忆进行猪肉制品追踪监管。

对于环境检测：

1. 对于检测环境来说：可以利用WSN的传感器，比如在实验中曾经做过的基于ZigBee的传感设施对环境中的光照、温度、湿度、火焰（检测是否发生火灾）等自然参数进行检测，并从终端节点发送到服务节点，使管理人员能够随时检测到当前环境状态；
2. 对于调整环境：同样可以在服务节点由管理员发送指令，通过无线通信将指令发送给养殖场中的调节设施进行调节。甚至可以设定参数与规则后，采用实时检测、自动调节的技术。

将两者技术结合，就是RFID+WSN的猪场养殖信息管理和环境监控综合系统的基本设计思路。

## 二、系统结构

### 1. 系统设计

![RFID+WSN猪场-2](https://s1.vika.cn/space/2022/06/14/a8e6dc4874d040dfb4307bc284d4db21)

### 2. 控制流程

![RFID+WSN猪场](https://s1.vika.cn/space/2022/06/14/7727c744ba2844be91c4e94ee9fe3be1)

## 三、系统创新点

1. 在监控方面使用了RFID技术
2. 在数据传输方面放弃了传统的有线传输，而使用了更加方便灵活的WSN无线传感技术。
3. 将两者先进技术结合了起来，形成了基于RFID+WSN的猪场养殖信息管理和环境监控综合系统。



## 四、Python可视化

结果如下：
![image-20220609113027913](https://s1.vika.cn/space/2022/06/14/fc669aabb0b7461cab356d229e9f72f2)





代码如下：

```python
import tkinter
import time
import threading
import serial
from tkinter import ttk 

event = threading.Event()   # 创建事件管理标志
once=0
global flagtid
flagtid = 0

try:
    portx = "/dev/tty.Bluetooth-Incoming-Port"  # 串口号
    bps=11520       # 串口波特率
    timex=None      # 超时时间
    ser = serial.Serial(portx, bps, timeout=timex)  # 打开串口
except Exception as e: 
    print(e)



# ========================= 设置GUI ========================= 

window = tkinter.Tk()
window.title("猪场信息可视化")



button1=tkinter.Button(window,text="读取数据") 
button1.grid(row=0,column=2) 


label1 = tkinter.Label(window, text="温度")
label1.grid(row=0, column=0)
entry1 = tkinter.Entry(window)  # 一行文本框
entry1.grid(row=0,column=1)

label2 = tkinter.Label(window, text="湿度")
label2.grid(row=1, column=0)
entry2 = tkinter.Entry(window)  # 一行文本框
entry2.grid(row=1,column=1)

label3 = tkinter.Label(window, text="光照")
label3.grid(row=2, column=0)
entry3 = tkinter.Entry(window)  # 一行文本框
entry3.grid(row=2,column=1)

label4 = tkinter.Label(window, text="是否发生火灾",fg='red')
label4.grid(row=3, column=0)
entry4 = tkinter.Entry(window)  # 一行文本框
entry4.grid(row=3,column=1)


label5 = tkinter.Label(window, text=" ===== 参数调节 ===== ",fg='blue')
label5.grid(row=4, column=0, columnspan=3)



button2=tkinter.Button(window,text="确认调节",fg='green') 
button2.grid(row=5,column=2) 

from tkinter import scrolledtext # 导入滚动文本框的模块
scrolW = 50 # 设置文本框的长度
scrolH = 18 # 设置文本框的高度
text = scrolledtext.ScrolledText(window, width=scrolW, height=scrolH, wrap=tkinter.WORD) 
text.grid(row=5, columnspan=2, sticky=tkinter.E)

tkinter.mainloop()

```

