﻿#NoEnv
#include ListView.ahk
#SingleInstance force
#include osd.ahk
Menu, Tray, NoStandard
Menu, Tray, Add, &Show Power Modes, showAndMonitor
Menu, Tray, Default, &Show Power Modes
Menu, Tray, Add, Exit, Exit
Menu, Tray, Click, 1

IfPlanListShowing := 0
planListObj := 0
focusedSchemeName := ""
GUI_ID := 0
nameAndCommand := {"Power saver":".\vbs\Power_Saver.vbs"
    ,"Balanced":".\vbs\Balanced.vbs"
    ,"Cooler Gaming":".\vbs\Cooler_Gaming.vbs"
    ,"High performance":".\vbs\High_Performance.vbs"
    ,"Ultimate Performance":".\vbs\Ultimate_Performance.vbs"}
nameAndIcon := {"Power saver":"./icons/Power saver.ico"
    ,"Balanced":"./icons/Balanced.ico"
    ,"Cooler Gaming":"./icons/Cooler Gaming.ico"
    ,"High performance":"./icons/High performance.ico"
    ,"Ultimate Performance":"./icons/Ultimate Performance.ico"}
initializeProgram()

#F4::
    switchByHotKey(){
        ; MsgBox, wtf
        SetTimer, monitorForSelection, Off
        global IfPlanListShowing
        global planListObj
        global focusedSchemeName
        ; global ifMonitoring
        if (IfPlanListShowing = 0){
            getAllPowerSchemes()
            IfPlanListShowing := 1
            ; ifMonitoring := 1
        }
        else{
            focusedSchemeName := planListObj.setNextFocusedScheme()
        }
        ; if (IfPlanListShowing = 0){
        ;     monitorForSelection()
        ; }
    }
    switchByHotKey()
return

#F5::
    change()
    {
        global nameAndCommand

        message := New OSD
        static counter := 0
        static previousCounter := 0

        currentPowerScheme := StdOutToVar("powercfg -getactivescheme")
        RegExMatch(currentPowerScheme, "\((.*?)\)", M, 1+StrLen(M1) )
        if (M1 = "Power saver"){
            counter := -1
        }
        else if (M1 = "Balanced"){
            counter := 0
        }
        else if (M1 = "High performance" || M1 = "Cooler Gaming" || M1 = "Ultimate Performance"){
            counter := 1
        }
        if(counter = 0) {
            if (previousCounter = 1) {
                Run, % nameAndCommand["Power saver"]
                ; Run, .\vbs\Power_Saver.vbs
                counter := -1
                previousCounter := 0
                DisplayOSD(message, "Power saver")
                ; message.showAndHide("🍃 Power Saver", 1)
            } else {
                Run, % nameAndCommand["High performance"]
                ; Run, .\vbs\High_Performance.vbs
                counter := 1
                previousCounter := 0
                DisplayOSD(message, "High performance")
                ; message.showAndHide("🚀 High Performance", 0)
            }
        } else if (counter = 1) {
            Run, % nameAndCommand["Balanced"]
            ; Run, .\vbs\Balanced.vbs
            counter := 0
            previousCounter := 1
            DisplayOSD(message, "Balanced")
            ; message.showAndHide("☯️ Balanced")
        } else {
            Run, % nameAndCommand["Balanced"]
            ; Run, .\vbs\Balanced.vbs
            counter := 0
            previousCounter := -1
            DisplayOSD(message, "Balanced")
            ; message.showAndHide("☯️ Balanced")
        }
    }
    change()
Return

#If IfPlanListShowing
Esc::
    closePlanList(){
        global planListObj
        global IfPlanListShowing
        ; global ifMonitoring
        global focusedSchemeName
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        focusedSchemeName := ""
        SetTimer, monitorForSelection, Off
    }
    closePlanList()
return

#If IfPlanListShowing
Enter::
    setPlan(){
        SetTimer, monitorForSelection, Off
        global planListObj
        global IfPlanListShowing
        ; global ifMonitoring
        global focusedSchemeName
        global nameAndCommand
        if (focusedSchemeName != ""){
            osdTemp := New OSD
            commandTemp := nameAndCommand[focusedSchemeName]
            Run, %commandTemp%
            DisplayOSD(osdTemp, focusedSchemeName)
        }
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        focusedSchemeName := ""
    }
    setPlan()
return

; #If IfPlanListShowing
~LWin Up::
    autoSetPlan(){
        SetTimer, monitorForSelection, Off
        global planListObj
        global IfPlanListShowing
        ; global ifMonitoring
        global focusedSchemeName
        global nameAndCommand
        if (focusedSchemeName != ""){
            osdTemp := New OSD
            commandTemp := nameAndCommand[focusedSchemeName]
            Run, %commandTemp%
            DisplayOSD(osdTemp, focusedSchemeName)
        }
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        focusedSchemeName := ""
    }
    autoSetPlan()
return

#If

; Loop {
;     powerPlanAutoManage()
;     Sleep, 100 ;just slowing it down for performance
; }
initializeProgram(){
    global nameAndIcon
    ; global ifMonitoring
    global GUI_ID
    currentPowerScheme := StdOutToVar("powercfg -getactivescheme")
    RegExMatch(currentPowerScheme, "\((.*?)\)", M, 1+StrLen(M1) )
    if (FileExist(nameAndIcon[M1])){
        Menu, Tray, Icon, % nameAndIcon[M1]
    }
    IniWrite, %a_scriptdir%, .\settings\setting.ini, WorkingDir, Dir
    #Persistent
    SetTimer, powerPlanAutoManage, 100
}
showAndMonitor(){
    ; global ifMonitoring
    getAllPowerSchemes()
    ; ifMonitoring := 1
    SetTimer, monitorForSelection, 100
}
getAllPowerSchemes(){
    global IfPlanListShowing
    global planListObj
    global nameAndCommand
    ; global ifMonitoring
    global GUI_ID
    if (IfPlanListShowing = 1){
        planListObj.destroy()
        planListObj := 0
        IfPlanListShowing := 0
        ; ifMonitoring := 0
        return
    }
    else {
        IfPlanListShowing := 1
    }
    allPowerSchemes := StdOutToVar("powercfg -l")
    ; StringSplit, stringOut, allPowerSchemes, "()"
    powerSchemeArray := []
    Pos := 1
    While Pos {
        if (Pos = 1){
            Pos:=RegExMatch(allPowerSchemes, "\((.*?)\)", M, Pos+StrLen(M1) )
        }
        else {
            Pos:=RegExMatch(allPowerSchemes, "\((.*?)\)", M, Pos+StrLen(M1) )
            if(StrLen(M1) != 0){
                powerSchemeArray.push(M1)
            }
        }
    }
    currentPowerScheme := StdOutToVar("powercfg -getactivescheme")
    RegExMatch(currentPowerScheme, "\((.*?)\)", M, 1+StrLen(M1) )
    powerSchemeArray.push(M1)

    planListObj := New PlanList
    planListObj.show(powerSchemeArray)
    GUI_ID := planListObj.getID()
}
StdOutToVar(cmd)
{
	DllCall("CreatePipe", "PtrP", hReadPipe, "PtrP", hWritePipe, "Ptr", 0, "UInt", 0)
	DllCall("SetHandleInformation", "Ptr", hWritePipe, "UInt", 1, "UInt", 1)

	VarSetCapacity(PROCESS_INFORMATION, (A_PtrSize == 4 ? 16 : 24), 0)    ; http://goo.gl/dymEhJ
	cbSize := VarSetCapacity(STARTUPINFO, (A_PtrSize == 4 ? 68 : 104), 0) ; http://goo.gl/QiHqq9
	NumPut(cbSize, STARTUPINFO, 0, "UInt")                                ; cbSize
	NumPut(0x100, STARTUPINFO, (A_PtrSize == 4 ? 44 : 60), "UInt")        ; dwFlags
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 60 : 88), "Ptr")    ; hStdOutput
	NumPut(hWritePipe, STARTUPINFO, (A_PtrSize == 4 ? 64 : 96), "Ptr")    ; hStdError
	
	if !DllCall(
	(Join Q C
		"CreateProcess",             ; http://goo.gl/9y0gw
		"Ptr",  0,                   ; lpApplicationName
		"Ptr",  &cmd,                ; lpCommandLine
		"Ptr",  0,                   ; lpProcessAttributes
		"Ptr",  0,                   ; lpThreadAttributes
		"UInt", true,                ; bInheritHandles
		"UInt", 0x08000000,          ; dwCreationFlags
		"Ptr",  0,                   ; lpEnvironment
		"Ptr",  0,                   ; lpCurrentDirectory
		"Ptr",  &STARTUPINFO,        ; lpStartupInfo
		"Ptr",  &PROCESS_INFORMATION ; lpProcessInformation
	)) {
		DllCall("CloseHandle", "Ptr", hWritePipe)
		DllCall("CloseHandle", "Ptr", hReadPipe)
		return ""
	}

	DllCall("CloseHandle", "Ptr", hWritePipe)
	VarSetCapacity(buffer, 4096, 0)
	while DllCall("ReadFile", "Ptr", hReadPipe, "Ptr", &buffer, "UInt", 4096, "UIntP", dwRead, "Ptr", 0)
		sOutput .= StrGet(&buffer, dwRead, "CP0")

	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, 0))         ; hProcess
	DllCall("CloseHandle", "Ptr", NumGet(PROCESS_INFORMATION, A_PtrSize)) ; hThread
	DllCall("CloseHandle", "Ptr", hReadPipe)
	return sOutput
}
Exit() {
    ExitApp
}
monitorForSelection(){
    global IfPlanListShowing
    global planListObj
    global nameAndCommand
    ; global ifMonitoring
    global GUI_ID
    ; SetTimer LoopStart, 100
    ; LoopStart:
    ; if (ifMonitoring = 0){
    ;     ifMonitoring := 1
    ;     return
    ; }
    ; Sleep, 100
    schemeTemp := planListObj.getSelectedScheme()
    if (schemeTemp != ""){
        osdTemp := New OSD
        commandTemp := nameAndCommand[schemeTemp]
        Run, %commandTemp%
        DisplayOSD(osdTemp, schemeTemp)
        planListObj.hide()
        planListObj.destroy()
        planListObj := 0
        GUI_ID := 0
        IfPlanListShowing := 0
        SetTimer, monitorForSelection, Off
    }
    ; return
}
displayOSD(osdTemp, schemeTemp){
    global nameAndIcon
    if (schemeTemp = "Power saver"){
        osdTemp.showAndHide("🍃 Power Saver", 1) ; 
        Menu, Tray, Icon, % nameAndIcon[schemeTemp]
    }
    else if (schemeTemp = "Balanced"){
        osdTemp.showAndHide("☯️ Balanced")
        Menu, Tray, Icon, % nameAndIcon[schemeTemp]
    }
    else if (schemeTemp = "Cooler Gaming"){
        osdTemp.showAndHide("🌀 Cooler Gaming")
        Menu, Tray, Icon, % nameAndIcon[schemeTemp]
    }
    else if (schemeTemp = "High performance"){
        osdTemp.showAndHide("🚀 High Performance", 0)
        Menu, Tray, Icon, % nameAndIcon[schemeTemp]
    }
    else if (schemeTemp = "Ultimate Performance"){
        osdTemp.showAndHide("☢ Ultimate Performance", 0)
        Menu, Tray, Icon, % nameAndIcon[schemeTemp]
    }
    ; else {
    ;     osdTemp.showAndHide(stringTemp)
    ; }
}


powerPlanAutoManage()
{
    Global
    getPowerState()
    ; MsgBox, wtf
    
    ; if ( loopCounter < 1)	;to manually retrieve currentPowerScheme only on initial run
    ;     loopCounter := 0
    ; if ( loopCounter = 0 )
    ;     Gosub, getactivePOWERscheme
    ; loopCounter += 1
    
    
    if acLineStatus = 0 ;if not on AC power
    {
        IfNotEqual, powerStateChange, 1 ;so if equal to 2
        {
            message := New OSD
            ; acLineStatus = Offline
            Run, .\vbs\Balanced.vbs
            powerStateChange:=1
            Sleep, 2000		;wait for asus's osd
            ; message.showAndHide("☯️ Balanced")
            DisplayOSD(message, "Balanced")
        }
    }
    Else If acLineStatus = 1	;if on AC power
    {
        IfNotEqual, powerStateChange, 2 ;so if equal to 1
        {
            message := New OSD
            ; acLineStatus = Online
            Run, .\vbs\Balanced.vbs
            powerStateChange:=2
            Sleep, 2000		;just slowing it down for performance
            ; message.showAndHide("☯️ Balanced")
            DisplayOSD(message, "Balanced")
        }
    }
}



GetInteger(ByRef @source, _offset = 0, _bIsSigned = false, _size = 4)
{
    local result
    Loop %_size%  ; Build the integer by adding up its bytes.
    {
        result += *(&@source + _offset + A_Index-1) << 8*(A_Index-1)
    }
    if (!_bIsSigned OR _size > 4 OR result < 0x80000000)
        Return result  ; Signed vs. unsigned doesn't matter in these cases.
    ; Otherwise, convert the value (now known to be 32-bit & negative) to its signed counterpart:
    return -(0xFFFFFFFF - result + 1)
}

getPowerState()
{
    Global
    VarSetCapacity(powerStatus, 1+1+1+1+4+4)
    success := DllCall("GetSystemPowerStatus", "UInt", &powerStatus)
    if (ErrorLevel != 0 OR success = 0) {
        MsgBox 16, Power Status, Can't get the power status...
        Exit
    }
    acLineStatus := GetInteger(powerStatus, 0, false, 1)
}



