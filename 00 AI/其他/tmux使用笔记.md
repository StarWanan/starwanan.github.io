# tmux指南

```
1. tmux教程                                                                                                                                                                  
    功能：                                                                                                                                                                   
        (1) 分屏。                                                                                                                                                           
        (2) 允许断开Terminal连接后，继续运行进程。                                                                                                                           
    结构：                                                                                                                                                                   
        一个tmux可以包含多个session，一个session可以包含多个window，一个window可以包含多个pane。                                                                             
        实例：                                                                                                                                                               
            tmux:                                                                                                                                                            
                session 0:                                                                                                                                                   
                    window 0:                                                                                                                                                
                        pane 0                                                                                                                                               
                        pane 1                                                                                                                                               
                        pane 2                                                                                                                                               
                        ...                                                                                                                                                  
                    window 1                                                                                                                                                 
                    window 2                                                                                                                                                 
                    ...                                                                                                                                                      
                session 1                                                                                                                                                    
                session 2                                                                                                                                                    
                ...                                                                                                                                                          
    操作：                                                                                                                                                                   
        (1) tmux：新建一个session，其中包含一个window，window中包含一个pane，pane里打开了一个shell对话框。                                                                   
        (2) 按下Ctrl + a后手指松开，然后按%：将当前pane左右平分成两个pane。                                                                                                  
        (3) 按下Ctrl + a后手指松开，然后按"：将当前pane上下平分成两个pane。                                                                                                  
        (4) Ctrl + d：关闭当前pane；如果当前window的所有pane均已关闭，则自动关闭window；如果当前session的所有window均已关闭，则自动关闭session。                             
        (5) 鼠标点击可以选pane。                                                                                                                                             
        (6) 按下ctrl + a后手指松开，然后按方向键：选择相邻的pane。                                                                                                           
        (7) 鼠标拖动pane之间的分割线，可以调整分割线的位置。                                                                                                                 
        (8) 按住ctrl + a的同时按方向键，可以调整pane之间分割线的位置。                                                                                                       
        (9) 按下ctrl + a后手指松开，然后按z：将当前pane全屏/取消全屏。                                                                                                       
        (10) 按下ctrl + a后手指松开，然后按d：挂起当前session。                                                                                                              
        (11) tmux a：打开之前挂起的session。
		(12) 按下ctrl + a后手指松开，然后按s：选择其它session。                                                                                                      
            方向键 —— 上：选择上一项 session/window/pane                              
            方向键 —— 下：选择下一项 session/window/pane                              
            方向键 —— 右：展开当前项 session/window                                   
            方向键 —— 左：闭合当前项 session/window                                   
        (13) 按下Ctrl + a后手指松开，然后按c：在当前session中创建一个新的window。     
        (14) 按下Ctrl + a后手指松开，然后按w：选择其他window，操作方法与(12)完全相同。
        (15) 按下Ctrl + a后手指松开，然后按PageUp：翻阅当前pane内的内容。             
        (16) 鼠标滚轮：翻当前pane内的内容。                                         
        (17) 在tmux中选中文本时，需要按住shift键。（仅支持Windows和Linux，不支持Mac，不过该操作并不是必须的，因此影响不大）
        (18) tmux中复制/粘贴文本的通用方式：                                          
            (1) 按下Ctrl + a后松开手指，然后按[                                       
            (2) 用鼠标选中文本，被选中的文本会被自动复制到tmux的剪贴板                
            (3) 按下Ctrl + a后松开手指，然后按]，会将剪贴板中的内容粘贴到光标处
```

`Ctrl + a` 替换成 `Ctrl + b`