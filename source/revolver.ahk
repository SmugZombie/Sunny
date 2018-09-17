; Revolver (formerly Sunny)
; Author: Jeff Reeves
; Modifications: Ron Egli
; Purpose: Multiple clipboard manager for Windows

;==[ INIT ]=====================================================================

; environment
#NoEnv
#Persistent
#SingleInstance, Force
Process, Priority,, High
SetWorkingDir, %A_ScriptDir%

; enable mouse functionality
OnMessage(0x203, "WM_LBUTTONDBLCLK")
OnMessage(0x204, "WM_RBUTTONDOWN")

; taskbar
Menu, Tray, Tip, [Revolver] by Jeff Reeves
Menu, Tray, Icon, revolver-64.png
Menu, Tray, Add, ToggleGui, ToggleGui

; right click menu
Menu, Settings, Add, Change Orientation, ChangeView
Menu, Settings, Add, Change Theme, ChangeTheme

Menu, MainMenu, Add, Reload, GuiReload
Menu, MainMenu, Add, Settings, :Settings
Menu, MainMenu, Add
Menu, MainMenu, Add, Exit, GuiClose

; debugging
global _debug := 0

; key variables
global revolver := Object()
filename := "revolver.ini"


;==[ MAIN ]=====================================================================

revolver := GetUserINISettings()
revolver := InitializeClipboards(revolver)
revolver := GetMonitorInfo(revolver)
InitializeGUI(revolver)
UpdateGUI(revolver)
InitializeKeybinds(revolver)
SetClipboard(revolver)


;==[ SUBROUTINES ]==============================================================

OnClipboardChange:
    UpdateClipboards(revolver)
    UpdateGUI(revolver)

    if(_debug) {
        DisplayValues(revolver)
    }
    return

;==[ FUNCTIONS ]================================================================

GetUserINISettings() {
    global
    clipboardCount := 6
    hideGUI := 0
    darkMode := 1
    horizontalMode := 1
    positionRight := 1
    
    IniRead, iniFound, %filename%, Found, iniFound, 0

    if (iniFound){
        IniRead, clipboardCount,    %filename%, Clipboards, clipboardCount, %clipboardCount%
        IniRead, hideGUI,           %filename%, Display,    hideGUI,        %hideGUI%
        IniRead, darkMode,          %filename%, Display,    darkMode,       %darkMode%
        IniRead, horizontalMode,    %filename%, Display,    horizontalMode, %horizontalMode%
        IniRead, positionRight,     %filename%, Display,    positionRight,  %positionRight%
        IniRead, MyHeight,          %filename%, Display,    MyHeight,       %MyHeight%, Null
        IniRead, MyWidth,           %filename%, Display,    MyWidth,        %MyWidth%, Null
    }
    else {
        IniWrite, 1,                %filename%, Found,      iniFound
        IniWrite, %clipboardCount%, %filename%, Clipboards, clipboardCount
        IniWrite, %hideGUI%,        %filename%, Display,    hideGUI
        IniWrite, %darkMode%,       %filename%, Display,    darkMode
        IniWrite, %horizontalMode%, %filename%, Display,    horizontalMode
        IniWrite, %positionRight%,  %filename%, Display,    positionRight
    }

    return, { clipboardCount: clipboardCount
            , hideGUI: hideGUI
            , darkMode: darkMode
            , horizontalMode: horizontalMode
            , positionRight: positionRight
            , MyWidth: MyWidth
            , MyHeight: MyHeight }
}

InitializeClipboards(this) {

    clipboards := Object()

    loop, % this.clipboardCount {
        clipboards.Push("")
    }

    this.clipboards := clipboards

    return, this
}

UpdateClipboards(this) {

    trimmedClipboard := RegexReplace(clipboard, "^\s+|\s+$")

    loop, % this.clipboards.Length() {
        if (trimmedClipboard == this.clipboards[A_Index]) {
            matchFound := true
            this.clipboards.RemoveAt(A_Index)
            this.clipboards.InsertAt(1, trimmedClipboard)
            break
        }
    }

    if (!matchFound) {
        this.clipboards.InsertAt(1, trimmedClipboard)
        this.clipboards.Pop()
    }

    return
}

GetMonitorInfo(this) {

    SysGet, numberOfMonitors, MonitorCount
    SysGet, primaryMonitor, MonitorPrimary
    SysGet, workArea, MonitorWorkArea, % primaryMonitor

    this.monitorWidth := workAreaRight - workAreaLeft
    this.monitorHeight := workAreaBottom - workAreaTop

    this.sectionWidth := this.monitorWidth / this.clipboards.Length()

    return, this
}

InitializeGUI(this) {

    sectionWidth := this.sectionWidth
    heightOfRow := 20
    transparencyLevel := 200

    horizontalGUIHeight := 20
    verticalGUIHeight := 20 * this.clipboards.Length()

    horizontalPosY := this.monitorHeight - horizontalGUIHeight
    verticalPosY := this.monitorHeight - verticalGUIHeight

    row := []
    column := []
    Loop, % this.clipboards.Length() {
        row.Push(heightOfRow * (A_Index - 1)) ; subtract 1 to count from base 0
        column.Push(this.sectionWidth * (A_Index - 1))
    }

    Gui, Font, s10, Verdana
    Gui, +AlwaysOnTop +ToolWindow +LastFound
    WinSet, Transparent, %transparencyLevel%
    Gui -Caption

    if (this.darkMode) {
        Gui, Font, cFFFFFF
        Gui, Color, 222222
    }
    else {
        Gui, Font, c111111
        Gui, Color, DFDFDF
    }

    Loop, % this.clipboards.Length() {

        if (this.horizontalMode == true) {
            currentColumn := column[A_Index]
            currentRow := 0
            GUIHeight := horizontalGUIHeight
            GUIWidth := this.monitorWidth
            GUIYPos := horizontalPosY
            GUIXPos := 0 
        }
        else {
            currentColumn := 0
            currentRow := row[A_Index]
            GUIHeight := verticalGUIHeight
            GUIWidth := this.sectionWidth
            GUIYPos := verticalPosY

            if (this.positionRight) {
                GUIXPos := column[this.clipboards.Length()]
            }
            else {
                GUIXPos := 0
            }
            
        }

        currentClip := this.clipboards[A_Index]

        Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%currentRow% x%currentColumn% gClickedGUI, [%A_Index%] %currentClip%
    }

    if (this.horizontalMode != true) {
        ; Add a little tab to allow easier dragging without interacting with clips
    	GUIHeight := GUIHeight + 10
    }

    if (hideGui) {
        Gui, Hide
    }
    else {
        ; If we've moved the gui before, put it back where it was
    	if(this.MyWidth != "Null"){
    		Width := this.MyWidth
    		Height := this.MyHeight
    		Gui, Show, W%GUIWidth% H%GUIHeight% x%Width% y%Height%, Revolver
		}else{
			Gui, Show, W%GUIWidth% H%GUIHeight% x%GUIXPos% y%GUIYPos%, Revolver
		}
        
    }

    return
}

UpdateGUI(this) {

    fontSize := 10
    startPos := 1
    endPos := this.sectionWidth / fontSize

    Loop, % this.clipboards.Length() {

        trimmedClipboard := this.clipboards[A_Index]
        trimmedClipboard := SubStr(trimmedClipboard, startPos, endPos)

        StringReplace, trimmedClipboard, trimmedClipboard, `r`n,,
        StringReplace, trimmedClipboard, trimmedClipboard, `n,,

        GuiControl, -redraw, % "[" A_Index "]"
        GuiControl,, % "[" A_Index "]", % "[" A_Index "] " trimmedClipboard 
        GuiControl, +redraw, % "[" A_Index "]"
    }
    
    return
}

InitializeKeybinds(this) {

    hotkeyPrefix := "~^Numpad"
    maxClipboardCount := 9

    loop, % maxClipboardCount {
        Hotkey, % hotkeyPrefix A_Index, Off, UseErrorLevel
        if (ErrorLevel in 5,6) { ; non-existant hotkey error codes
            continue
        }
    }

    loop, % this.clipboards.Length() {
        Hotkey, % hotkeyPrefix A_Index, HotkeyPressed
    }

    return
}

SetClipboard(this, num := 1) {
    clipboard := this.clipboards[num]
    ClipWait, 1
    return
}

PasteClip() {
    SendInput, ^v
    return
}

HotkeyPressed() {
    numpadButtonPressed := SubStr(A_ThisHotkey, 9, 1) ; ~^Numpad_
    SetClipboard(revolver, numpadButtonPressed)
    PasteClip()
    return
}

ClickedGUI(){
    guiControlClicked := SubStr(A_GuiControl, 2, 1) ; [_] <content>
    SetClipboard(revolver, guiControlClicked)
    return
}

DisplayValues(myObject){
    summary := ""
    for key, value in myObject {
        if (IsObject(value)){
            summary .= key "= [ "
            for k, v in value {
                summary .= v ", "
            }
            summary .= " ]`n"
        }
        else {
            summary .= key "=" value "`n"
        }
    }
    MsgBox, % summary
    return
}

WM_LBUTTONDBLCLK(wParam, lParam){
    X := lParam & 0xFFFF
    Y := lParam >> 16
		PostMessage, 0xA1, 2,,, A 
		sleep 500
		WinGetPos,x,y,w,h,a
		; Save to INI
		SaveCoords(x,y)
}

SaveCoords(myx,myy){
	global
	IniWrite, %myy%, %filename%, Display, MyHeight
	IniWrite, %myx%, %filename%, Display, MyWidth
}

WM_RBUTTONDOWN(){
	Menu, MainMenu, Show
}

ChangeView(){
	global

	IniRead, horizontalMode,    %filename%, Display,    horizontalMode, %horizontalMode%
	if(horizontalMode == true){
		horizontalMode = 0
	}else{
		horizontalMode = 1
	}

	IniWrite, %horizontalMode%, %filename%, Display, horizontalMode
	reload
}

ChangeTheme(){
	global

	IniRead, darkMode,    %filename%, Display,    darkMode, %darkMode%
	if(darkMode == true){
		darkMode = 0
	}else{
		darkMode = 1
	}

	IniWrite, %darkMode%, %filename%, Display, darkMode
	reload
}

ToggleGui(){
	global

	IniRead, hideGUI,    %filename%, Display,    hideGUI, %hideGUI%
	if(hideGUI == true){
		hideGUI = 0
	}else{
		hideGUI = 1
	}

	IniWrite, %hideGUI%, %filename%, Display, hideGUI
	reload
}

ChangeClipCount(){
	global
	clipboardCount = 9
	IniWrite, %clipboardCount%, %filename%, Clipboards, clipboardCount
	reload
}

GuiReload:
Reload
return

GuiClose:
ExitApp
return
