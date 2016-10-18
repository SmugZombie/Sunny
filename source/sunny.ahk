; Sunny v3.00
; Author: Jeff Reeves
; Contributor: Ron Egli [github.com/smugzombie]
; Last Updated: October 17th, 2016

OnMessage(0x201, "WM_LBUTTONDOWN")
;OnMessage(0x204, "WM_RBUTTONDOWN")
;OnMessage(0x207, "WM_MBUTTONDOWN")

; environment
#NoEnv
#Persistent
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

; taskbar menu
Menu, Tray, NoStandard
Menu, Tray, Add, Controls
Menu, Tray, Add,
Menu, Tray, Add, Hide
Menu, Tray, Add, Show
Menu, Tray, Add,
Menu, Tray, Add, NightMode
Menu, Tray, Add,
Menu, Tray, Add, About
Menu, Tray, Add,
Menu, Tray, Add, Restart
Menu, Tray, Add, Close
Menu, Tray, Add,
Menu, Tray, Tip, [Sunny v3.0] by Jeff Reeves

; tray icon for source code version
Menu, Tray, Icon, sunny_icon.ico

; set the process to high prority
Process, Priority,, High

; user settings
IniRead, iniFound, sunny.ini, Found, iniFound, 0

; if an ini file is found, read from it
if(iniFound == 1){
  IniRead, displayType, sunny.ini, Display, displayType, 0
  IniRead, toggleSide, sunny.ini, Display, toggleSide, 0
  IniRead, nightMode, sunny.ini, Display, nightMode, 1
  IniRead, hideGUI, sunny.ini, Display, hideGUI, 0
  IniRead, numClipboards, sunny.ini, Clipboards, numClipboards, 9
}
else {
  ; write ini file with default values
  IniWrite, 1, sunny.ini, Found, iniFound
  IniWrite, 0, sunny.ini, Display, displayType
  IniWrite, 0, sunny.ini, Display, toggleSide
  IniWrite, 1, sunny.ini, Display, nightMode
  IniWrite, 0, sunny.ini, Display, hideGUI
  IniWrite, 10, sunny.ini, Clipboards, numClipboards

  ; load defaults
  displayType := 0
  toggleSide := 0
  nightMode := 1
  hideGUI := 0
  numClipboards := 9
}

; initialize clipboards
; create as many clipboards as desired by ini file
; default is 10 (9 with zero index)
Loop, %numClipboards% {

  if(%A_Index% != 0) {
    clipboard%A_Index% =
  }
  else {
    clipboard0 = %clipboard%
  }
}

; start program
Gosub, getSystemInfo
Gosub, generateGUI
Return


Controls:
  myMessage =
  (
    How to use Sunny:

    As you copy items they will be saved on your clipboard as plain text.

    Click on a previously copied item to copy it back to your primary clipboard.

    Alternatively, press Ctrl + <number> or Ctrl + <numpad_number>
      to paste directly from that item to your cursor's position.

    Left Ctrl + CapsLock toggles horizontal and vertical modes.

    Left Ctrl + Tab toggles the vertical mode between the left and
      right of the screen.
  )
  MsgBox, 0, Controls, %myMessage%
  Return


About:
  myMessage =
  (
    About Sunny:

    Sunny was designed to make copying and pasting multiple items easier.

    Each time text is copied, it will be saved to the first slot, and all
        previously copied text will shift over a slot.

    Users can click on the text to copy it back to their clipboard, or use a hotkey
        combination to paste it immediately.

    For more information on the controls, select "Controls" from the tray menu.

    Sunny is named after Sunny Emmerich in the Metal Gear universe.

    If you should have any questions or suggestions, please email me at:
        jeff@alchemist.digital
  )
  MsgBox, 0, About, %myMessage%
  Return


Hide:
  Gosub, destroyGUI
  Return


Show:
  Gosub, generateGUI
  Return


SaveIni:
  IniWrite, %displayType%, sunny.ini, Display, displayType
  IniWrite, %toggleSide%, sunny.ini, Display, toggleSide
  IniWrite, %nightMode%, sunny.ini, Display, nightMode
  IniWrite, %hideGUI%, sunny.ini, Display, hideGUI
  Return


NightMode:
  ;toggle nightMode to on or off
  nightMode := !nightMode
  Gosub, destroyGUI
  Gosub, generateGUI
  Return


Restart:
  Reload
  Return


Close:
  ExitApp
  Return


OnClipboardChange:
  ; set a temp variable so that it doesn't have to read the clipboard each time
  tempClipboard = %clipboard%

  ; stores the index to start replacing at
  ; default is total number of clipboards
  replaceAt = %numClipboards%

  ; loop through all clipboards
  Loop, %numClipboards% {

    ; check for any matches
    if(clipboard%A_Index% == tempClipboard) {
      matchFound := 1

      ; get the clip number where a match was found
      replaceAt = %A_Index%
      
      ; break out of loop 
      Break 
    }
  }

  ; loop through the number of clipboards needing to be shifted over
  while (replaceAt > 0) {

    replaceFrom := replaceAt - 1

    ; shift each clipboard over one
    clipboard%replaceAt% := clipboard%replaceFrom%
    
    ; decrement 
    replaceAt--
  }

  ; place latest copy to the first clipboard
  clipboard0 := tempClipboard

  ; clear tempClipboard
  tempClipboard =

  ; redraw GUI 
  Gosub, redrawGUI

  Return


getSystemInfo:
  ; get total number of monitors 
  SysGet, numMonitors, MonitorCount
  ;MsgBox, numMonitors %numMonitors%

  ; get primary monitor 
  SysGet, primaryMonitor, MonitorPrimary
  ;MsgBox, primaryMonitor = %primaryMonitor%

  ; loop through each monitor to get their information 
  Loop, %numMonitors% {

    ; get screen area minus taskbar
    SysGet, tempWorkArea, MonitorWorkArea, %A_Index%
    monitor%A_Index%Width := tempWorkAreaRight - tempWorkAreaLeft
    monitor%A_Index%Height := tempWorkAreaBottom - tempWorkAreaTop

    tempValue := monitor%A_Index%Width
    tempValue2 := monitor%A_Index%Height
    ;MsgBox, monitor%A_Index%Width = %tempValue% `nmonitor%A_Index%Height = %tempValue2%
  }

  Return 

generateGUI:

  ; gets the total number of clipboards 
  totalClibpboards := numClipboards + 1 ; accounts for base 0 

  ; sets values of the GUI
  heightOfRow := 20
  transparencyLevel := 200

  ; gets the full height and width of the display screen
  screenHeight :=  monitor%primaryMonitor%Height
  screenWidth :=  monitor%primaryMonitor%Width

  ; sets horizontal and vertical GUI height
  horizontalGUIHeight := 20
  verticalGUIHeight := 20 * totalClibpboards

  ; splits the work-able screen area to the number of clipboards
  sectionWidth := screenWidth / totalClibpboards

  ; sets the bottom position of the GUI above the taskbar
  horizontalPosY := screenHeight - horizontalGUIHeight
  verticalPosY := screenHeight - verticalGUIHeight

  ; set x position of first clipboard column 
  column0 := 0

  ; gets the x position of columns for each additional clipboard
  Loop, %numClipboards% {
    multiple = %A_Index%
    column%A_Index% := sectionWidth * multiple
  }

  ; sets the y positon of the first clipboard row
  row0 := 0

  ; gets the y position of rows for each additional clipboard
  Loop, %numClipboards% {
    multiple = %A_Index%
    row%A_Index% := heightOfRow * multiple
  }  

  ; setup the GUI
  if (nightMode == 1){
    Gui, Font, s10, Verdana
    Gui, Font, cFFFFFF
    Gui, Color, 222222
    Gui, +AlwaysOnTop +ToolWindow +LastFound
    WinSet, Transparent, %transparencyLevel%
    Gui -Caption
  }
  else if (nightMode == 0){
    Gui, Font, s10, Verdana
    Gui, Font, c111111
    Gui, Color, DFDFDF
    Gui, +AlwaysOnTop +ToolWindow +LastFound
    WinSet, Transparent, %transparencyLevel%
    Gui -Caption
  }

  ; checks if GUI is set to either horizontal or vertical display
  ; if horizontal, single row, GUI
  if(displayType == 0){

    ; create first clipboard 
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row0% x%column0% gputOnClipboard0 vclipboard0, [0] %clipboard0%

    ; generate each additional clipboard 
    Loop, %numClipboards% {
      column := column%A_Index%
      clip := clipboard%A_Index%
      Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row0% x%column% gputOnClipboard%A_Index% vclipboard%A_Index%, [%A_Index%] %clip%
    }
    
    ; show GUI
    if(hideGUI == 0) {
      Gui, Show, W%screenWidth% H%horizontalGUIHeight% x%column0% y%horizontalPosY%, Sunny
    }

  }
  ; else if vertical, single column, GUI
  else if (displayType == 1) {

    ; create first clipboard 
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row0% x%column0% gputOnClipboard0 vclipboard0, [0] %clipboard0%

    ; generate each additional clipboard 
    Loop, %numClipboards% {
      row := row%A_Index%
      clip := clipboard%A_Index%
      Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row% x%column0% gputOnClipboard%A_Index% vclipboard%A_Index%, [%A_Index%] %clip%
    }
    
    ; show GUI
    if(hideGUI == 0) {
      Gui, Show, W%sectionWidth% H%verticalGUIHeight% x%column0% y%verticalPosY%, Sunny
    }
  }
  
  ; redrawGUI
  Gosub, redrawGUI

  Return

redrawGUI:

  ; get the active window
  WinGet, activeWindow, ID, A

  ; declare font size
  fontSize := 10

  ; trims text for preview in GUI of 14 characters in length
  startPos := 1
  endPos := sectionWidth / fontSize


  trimmedClipboard0 := SubStr(clipboard0, startPos, endPos)
  trimmedClipboard1 := SubStr(clipboard1, startPos, endPos)
  trimmedClipboard2 := SubStr(clipboard2, startPos, endPos)
  trimmedClipboard3 := SubStr(clipboard3, startPos, endPos)
  trimmedClipboard4 := SubStr(clipboard4, startPos, endPos)
  trimmedClipboard5 := SubStr(clipboard5, startPos, endPos)
  trimmedClipboard6 := SubStr(clipboard6, startPos, endPos)
  trimmedClipboard7 := SubStr(clipboard7, startPos, endPos)
  trimmedClipboard8 := SubStr(clipboard8, startPos, endPos)
  trimmedClipboard9 := SubStr(clipboard9, startPos, endPos)

  ; loop through trimmed clipboards to remove bad formatting
  loop, 10 {
   ; trim leading and trailing whitespace
   trimmedClipboard%A_Index% := trimmedClipboard%A_Index%
   ;StringReplace, trimmedClipboard%A_Index%, trimmedClipboard%A_Index%, %A_SPACE%, ,
   StringReplace, trimmedClipboard%A_Index%, trimmedClipboard%A_Index%, `r`n, %A_SPACE%,
  }

  GuiControl, -redraw, clipboard0
  GuiControl,, clipboard0, [0] %trimmedClipboard0%
  GuiControl, +redraw, clipboard0

  GuiControl, -redraw, clipboard1
  GuiControl,, clipboard1, [1] %trimmedClipboard1%
  GuiControl, +redraw, clipboard1

  GuiControl, -redraw, clipboard2
  GuiControl,, clipboard2, [2] %trimmedClipboard2%
  GuiControl, +redraw, clipboard2

  GuiControl, -redraw, clipboard3
  GuiControl,, clipboard3, [3] %trimmedClipboard3%
  GuiControl, +redraw, clipboard3

  GuiControl, -redraw, clipboard4
  GuiControl,, clipboard4, [4] %trimmedClipboard4%
  GuiControl, +redraw, clipboard4

  GuiControl, -redraw, clipboard5
  GuiControl,, clipboard5, [5] %trimmedClipboard5%
  GuiControl, +redraw, clipboard5

  GuiControl, -redraw, clipboard6
  GuiControl,, clipboard6, [6] %trimmedClipboard6%
  GuiControl, +redraw, clipboard6

  GuiControl, -redraw, clipboard7
  GuiControl,, clipboard7, [7] %trimmedClipboard7%
  GuiControl, +redraw, clipboard7

  GuiControl, -redraw, clipboard8
  GuiControl,, clipboard8, [8] %trimmedClipboard8%
  GuiControl, +redraw, clipboard8

  GuiControl, -redraw, clipboard9
  GuiControl,, clipboard9, [9] %trimmedClipboard9%
  GuiControl, +redraw, clipboard9

  ; shift focus back to active window
  WinActivate, ahk_id %activeWindow%
  Return

destroyGUI:
  Gui, Destroy
  Return

putContentOnClipboard(clipboardNum){
  clipboard := clipboard%clipboardNum%
}

putOnClipboard1:
  putContentOnClipboard(1)
  Return

putOnClipboard2:
  putContentOnClipboard(2)
  Return

putOnClipboard3:
  putContentOnClipboard(3)
  Return

putOnClipboard4:
  putContentOnClipboard(4)
  Return

putOnClipboard5:
  putContentOnClipboard(5)
  Return

putOnClipboard6:
  putContentOnClipboard(6)
  Return

putOnClipboard7:
  putContentOnClipboard(7)
  Return

putOnClipboard8:
  putContentOnClipboard(8)
  Return

putOnClipboard9:
  putContentOnClipboard(9)
  Return

putOnClipboard0:
  putContentOnClipboard(0)
  Return

sendContentOnClipboard(clipboardNum){
  oldClipboard := clipboard
  clipboard := clipboard%clipboardNum%
  SendInput, ^v
  Sleep 20
  clipboard := oldClipboard
  oldClipboard =
}

LCtrl & 1::
  ;sendContentOnClipboard(1)
  clipboard := clipboard1
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 2::
  ;sendContentOnClipboard(2)
  clipboard := clipboard2
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 3::
  ;sendContentOnClipboard(3)
  clipboard := clipboard3
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 4::
  ;sendContentOnClipboard(4)
  clipboard := clipboard4
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 5::
  ;sendContentOnClipboard(5)
  clipboard := clipboard5
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 6::
  ;sendContentOnClipboard(6)
  clipboard := clipboard6
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 7::
  ;sendContentOnClipboard(7)
  clipboard := clipboard7
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 8::
  ;sendContentOnClipboard(8)
  clipboard := clipboard8
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 9::
  ;sendContentOnClipboard(9)
  clipboard := clipboard9
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & 0::
  ;sendContentOnClipboard(0)
  clipboard := clipboard0
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad1::
  ;sendContentOnClipboard(1)
  clipboard := clipboard1
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad2::
  ;sendContentOnClipboard(2)
  clipboard := clipboard2
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad3::
  ;sendContentOnClipboard(3)
  clipboard := clipboard3
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad4::
  ;sendContentOnClipboard(4)
  clipboard := clipboard4
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad5::
  ;sendContentOnClipboard(5)
  clipboard := clipboard5
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad6::
  ;sendContentOnClipboard(6)
  clipboard := clipboard6
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad7::
  ;sendContentOnClipboard(7)
  clipboard := clipboard7
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad8::
  ;sendContentOnClipboard(8)
  clipboard := clipboard8
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad9::
  ;sendContentOnClipboard(9)
  clipboard := clipboard9
  Gosub, redrawGUI
  SendInput, ^v
  Return

LCtrl & Numpad0::
  ;sendContentOnClipboard(0)
  clipboard := clipboard0
  Gosub, redrawGUI
  SendInput, ^v
  Return

; hide/show GUI
LCtrl & Esc::
  if(hideGUI := !hideGUI){
      Gosub, destroyGUI
  }
  else {
      Gosub, generateGUI
  }
  Gosub, SaveIni
  Return

; Toggle the side the GUI is on (single column mode)
LCtrl & Tab::
  if(displayType == 1) {
    if(toggleSide == 0) {
      toggleSide := 1
    }
    else {
      toggleSide := 0
    }
    Gosub, destroyGUI
    Gosub, generateGUI
    Gosub, SaveIni
  }
  Return

; toggle single column and single row modes
LCtrl & CapsLock::
  if(displayType == 1) {
      displayType := 0
  }
  else {
      displayType := 1
  }
  Gosub, destroyGUI
  Gosub, generateGUI
  Gosub, SaveIni
  Return

WM_LBUTTONDOWN() {
   PostMessage, 0xA1, 2
   SetTimer, WatchMouse, 1000
   Return
}

EWD_WatchMouse:
GetKeyState, EWD_LButtonState, LButton, P
if EWD_RButtonState = U  ; Button has been released, so drag is complete.
{
    SetTimer, EWD_WatchMouse, off
    return
}
; Otherwise, reposition the window to match the change in mouse coordinates
; caused by the user having dragged the mouse:
CoordMode, Mouse
MouseGetPos, EWD_MouseX, EWD_MouseY
WinGetPos, EWD_WinX, EWD_WinY,,, %AppName% %Version%
SetWinDelay, -1   ; Makes the below move faster/smoother.
WinMove, ahk_id %EWD_MouseWin%,, EWD_WinX + EWD_MouseX - EWD_MouseStartX, EWD_WinY + EWD_MouseY - EWD_MouseStartY
EWD_MouseStartX := EWD_MouseX  ; Update for the next timer-call to this subroutine.
EWD_MouseStartY := EWD_MouseY
return

WatchMouse:
    SetTimer, EWD_WatchMouse, off
return
