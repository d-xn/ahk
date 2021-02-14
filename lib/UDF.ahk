;; User Defined Functions
; 我不知道怎样才是最好的编程方法，于是只能摸着石头过河，不断试错，不断改进。


global ScriptNameNoExt
SplitPath, A_ScriptName, , , , ScriptNameNoExt,
global LogFileName := ScriptNameNoExt . ".log"

; 日志输出函数，改编自AHK文档
LogToFile(TextToLog)
{
    global LogFileName

    static t := A_Now
    FormatTime, t ,, yyyy年M月dd日 dddd HH:mm:ss 
    FileAppend, %t%: %TextToLog%`n, %LogFileName%
}

; ===========================================================================
;
; Description:      将改造的字符串输出到DebugView
; Syntax:           Debug(Message)
; Parameter(s):     $Message - 路径+文件名
; Requirement(s):   无
; Return Value(s):  无
; Author(s):        Dasn
;
; ===========================================================================


global DebugView := True

Debug(Message)
{
    global DebugView
    if DebugView
	; 输出脚本名称
	; 可以debugView中可使用 "*.ahk" 过滤调试信息，使调试变得方便

	if (InStr(Message, "`n"))
	{
	    ; 此处有多行文本，每行前面都加上脚本文件名
	    LineArray := StrSplit(Message, "`n")
	    msgbox % LineArray.MaxIndex()

	    Loop % LineArray.MaxIndex()
	    {
		this_line := LineArray[A_Index]
		OutputDebug % A_ScriptName . ": " . RTrim(this_line, "`r")
	    }
	} else {
	    ; 单行文本
	    OutputDebug % A_ScriptName . ": " . DebugFilter(Message)
	}
}

DebugFilter(StringToSend)
{
    local
    ReportToDebugger := ""
    if (StringToSend = "")
    {
	goto END 
    }

    if StringToSend is number
    {
	ReportToDebugger := "数字: " .  StringToSend
	goto END
    }

    ; 如果是对象，将对象做一层解析，转换成字符串输出
    if IsObject(StringToSend) {
	For index, value in StringToSend
		ReportToDebugger .=  index ":" value ","

	ReportToDebugger := "{" . RTrim(ReportToDebugger, ",") . "}"
	goto END
    }

    ReportToDebugger := StringToSend

END:
    return ReportToDebugger
}

; 输出版本调试信息
Debug("运行AutoHotkey版本: v" . A_AhkVersion)

; ===========================================================================
;
; Description:      返回指定文本文件的行数.
; Syntax:           FileCountLines(sFilePath)
; Parameter(s):     $sFilePath - 路径+文件名
; Requirement(s):   无
; Return Value(s):  成功 - 返回文件的行数
;                   失败 - 返回0 并设置 errorlevel = 1
; Author(s):        Tylo <tylo at start dot no> 修正 by thesnow Converted by Thinkai
;
; ===========================================================================
FileCountLines(sFilePath){
    ErrorLevel := 0
    IfNotExist, %sFilePath%
        {
        ErrorLevel := 1
        Return 0
        }
    Else
        {
        FileRead, m, %sFilePath%
        StringSplit, n, m, `n
        if n0 = 0
            Return 1
        Else
            Return n0
        }
}
 
 
BringWindowToActive(WinTitle)
{
	;; 把窗口放至最前，便于操作
	IfWinExist, %WinTitle%
	{
        
		WinActivate, %WinTitle%
		WinWaitActive, %WinTitle%

	}
	else
	{
		Debug(A_ThisFunc . ":查找窗口 '" . WinTitle . "' 失败")
	}
}
 
