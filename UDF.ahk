;; User Defined Functions
; �Ҳ�֪������������õı�̷���������ֻ������ʯͷ���ӣ������Դ����ϸĽ���


global ScriptNameNoExt
SplitPath, A_ScriptName, , , , ScriptNameNoExt,
global LogFileName := ScriptNameNoExt . ".log"

; ��־����������ı���AHK�ĵ�
LogToFile(TextToLog)
{
    global LogFileName

    static t := A_Now
    FormatTime, t ,, yyyy��M��dd�� dddd HH:mm:ss 
    FileAppend, %t%: %TextToLog%`n, %LogFileName%
}

; ===========================================================================
;
; Description:      ��������ַ��������DebugView
; Syntax:           Debug(Message)
; Parameter(s):     $Message - ·��+�ļ���
; Requirement(s):   ��
; Return Value(s):  ��
; Author(s):        Dasn
;
; ===========================================================================


global DebugView := True

Debug(Message)
{
    global DebugView
    if DebugView
	; ����ű�����
	; ����debugView�п�ʹ�� "*.ahk" ���˵�����Ϣ��ʹ���Ա�÷���

	if (InStr(Message, "`n"))
	{
	    ; �˴��ж����ı���ÿ��ǰ�涼���Ͻű��ļ���
	    LineArray := StrSplit(Message, "`n")
	    msgbox % LineArray.MaxIndex()

	    Loop % LineArray.MaxIndex()
	    {
		this_line := LineArray[A_Index]
		OutputDebug % A_ScriptName . ": " . RTrim(this_line, "`r")
	    }
	} else {
	    ; �����ı�
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
	ReportToDebugger := "����: " .  StringToSend
	goto END
    }

    ; ����Ƕ��󣬽�������һ�������ת�����ַ������
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

; ����汾������Ϣ
Debug("����AutoHotkey�汾: v" . A_AhkVersion)

; ===========================================================================
;
; Description:      ����ָ���ı��ļ�������.
; Syntax:           FileCountLines(sFilePath)
; Parameter(s):     $sFilePath - ·��+�ļ���
; Requirement(s):   ��
; Return Value(s):  �ɹ� - �����ļ�������
;                   ʧ�� - ����0 ������ errorlevel = 1
; Author(s):        Tylo <tylo at start dot no> ���� by thesnow Converted by Thinkai
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
	;; �Ѵ��ڷ�����ǰ�����ڲ���
	IfWinExist, %WinTitle%
	{
        
		WinActivate, %WinTitle%
		WinWaitActive, %WinTitle%

	}
	else
	{
		Debug(A_ThisFunc . ":���Ҵ��� '" . WinTitle . "' ʧ��")
	}
}
 
