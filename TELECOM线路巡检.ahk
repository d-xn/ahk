;; 山东综合维护平台APP
;; 自动执行线路巡检任务
;; 
; Android手机 KEYCODE列表
; https://blog.csdn.net/jlminghui/article/details/39268419


; 点击绝对坐标x,y
; adb shell input tap x y 

; 从startX,startY坐标滑动到endX,endY坐标 最后一个参数为总体时间(ms)
; adb shell input swipe startX startY endX endY 500

; 长按就是特殊的滑动，坐标不变
; adb shell input swipe startX startY startX startY 500

; 输入文字
; adb shell input text 内容

; 按键事件
; adb shell input keyevent 82

; 休眠唤醒
; adb shell input keyevent 26

; 滑动屏幕解锁(Redmi 3S)
; adb shell input swipe 360 1240 350 800 500

; 截图并保存到 /mnt/sdcard/01.png
; adb shell screencap -p /sdcard/01.png

; 将截图下载到本地目录
; adb pull /sdcard/01.png

; 使用 ImageMagick 把图片中需要的文字 (宽x高+X坐标+X坐标) 截取出来保存为crop.png
; ./convert.exe -crop 120x40+530+164 01.png crop.png

#SingleInstance force
#NoEnv
#warn
#include <UDF>


;;;;;;;;;;;;;;;;;;;;
;; 辅助函数
;;;;;;;;;;;;;;;;;;;;

;; adb 命令调用
AdbShell(cmd)
{
	RunWait %comspec% /c ""adb" "shell" "%cmd%"",,hide
	return ErrorLevel
}

;; 处理经纬度文件
FilterTxtFile(fileName)
{
    lineArray := []
    M := ""
    loop, Read, %fileName%
    {
	
	if (RegExMatch(A_LoopReadLine, "O)^\s*([\d-.]+),([\d-.]+)\s*$", M))
	{
	    ; msgbox, % M.value(1) . ":" . M.value(2)
	    lineArray.push([M.value(1) , M.value(2)])
	}

    }
    return lineArray

}


;;;;;;;;;;;;;;;;;;;;
;; 构建图形界面
;;;;;;;;;;;;;;;;;;;;

; 设置脚本图标
Menu, Tray, Icon, Shell32.dll,131, ; 
; Menu, Tray, Icon, Shell32.dll,132,1
Menu, Tray, Tip, 线路自动巡检脚本

Gui, Add, Text,, 坐标文件:
Gui, Add, Edit, R1 vMyEdit
Gui, Add, Button, x150 y22 h25 w40, 选择
Gui, Add, Checkbox, x12 y50 h20 w90 vMySemiAuto, 半自动执行
Gui, Add, Button, x12 y75 h20 w180, 开始

;; 设置EDIT的默认值
GuiControl,, MyEdit, %A_ScriptDir%\经纬度.txt
xpos := A_ScreenWidth / 2 - 150
ypos := A_ScreenHeight / 2 - 150

Gui, Show, x%xpos% y%ypos% h100 w200, 自动巡检程序
GuiControl, Focus, 开始
Return

Button选择:
	GuiControlGet, MyEdit
	FileSelectFile, SelectedFile, 3, %MyEdit%, 打开, Text Documents (*.txt)

	if ( !(SelectedFile = "") )
	{
		GuiControl,, MyEdit, %SelectedFile%
	}
	return

Button开始:
	GuiControlGet, MyEdit
	GuiControlGet, a_checked,, MySemiAuto
	;; Task Modal option (8192) 暂停用户与主窗口交互
	; MsgBox, 8192, 提示!!!, 请先解绑帐号，点击确定开始测速
	Gui, Hide
	Start(MyEdit, a_checked)
	MsgBox, 巡检完成
	ExitApp

GuiClose:
	ExitApp

;;;;;;;;;;;;;;;;;;;;
;; 主程序
;;;;;;;;;;;;;;;;;;;;
Start(myedit, mychecked)
{
    ; 唤醒手机
    ; AdbShell("input keyevent 26")

    ; 解锁屏幕
    ; AdbShell("input swipe 360 1240 350 800 500")

    StrKeys := ""
    loop 20 {
    	; <BS> 键 KEYCODE_DEL (67)
    	StrKeys .= "KEYCODE_DEL "
    }

    ; 获取文件中的坐标，生成数组
    a := FilterTxtFile(myedit)
    for i, v in a
    {
	Debug("当前进度: " . i . "/" . a.maxIndex() . " 输出坐标: " . v[1] . ", " . v[2])

	; 下滑屏幕
	; Debug(AdbShell("input keyevent KEYCODE_PAGE_DOWN"))
	; sleep 1000
	AdbShell("input swipe 650 300 650 600 500")
	sleep 1000


	; 单击测试位置
	AdbShell("input tap 300 1000")

	; 长按测试
	AdbShell("input swipe 300 1000 300 1000 1000")
	sleep 1000

	; 点击编辑
	AdbShell("input tap 389 714")

	sleep 1000

	; 点击纬度
	AdbShell("input tap 400 489")
	sleep 500

	;; 输入20次<BS>键
	AdbShell("input keyevent " . StrKeys)

	; 输入纬度
	AdbShell("input text " . v[2])
	sleep 500

	; 点击经度
	AdbShell("input tap 400 620")
	sleep 500

	;; 输入20次<BS>键
	AdbShell("input keyevent " . StrKeys)

	; 输入经度
	AdbShell("input text " . v[1])
	sleep 1000


	; 退出输入法
	AdbShell("input keyevent KEYCODE_BACK")
	sleep 1000

	; 点击√，开始模拟位置
	AdbShell("input tap 627 1190")
	if (mychecked)
	{
	    pause
	}
	else 
	{
	    sleep 2000

	}

    }

}

;;;;;;;;;;;;;;;;;;;;
;; 热键
;;;;;;;;;;;;;;;;;;;;

;; 可随时暂停和启动程序
Pause::Pause
