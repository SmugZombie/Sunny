; Sunny v3.01
; Author: Jeff Reeves
; Contributor: Ron Egli [github.com/smugzombie] - added ability to drag GUI to anywhere on screen

; needed to process click-drag events on GUI
OnMessage(0x201, "WM_LBUTTONDOWN")

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

  ; gets the x position of columns and y position of rows for each additional clipboard

  x := numClipboards

  While (x >= 0) {
    multiple = %x%
    column%x% := sectionWidth * multiple
    row%x% := heightOfRow * multiple
    x--
  }

  ; set common GUI settings 
  Gui, Font, s10, Verdana
  Gui, +AlwaysOnTop +ToolWindow +LastFound
  WinSet, Transparent, %transparencyLevel%
  Gui -Caption

  ; light or dark mode settings
  if (nightMode == 1){
    Gui, Font, cFFFFFF
    Gui, Color, 222222
  }
  else if (nightMode == 0){
    Gui, Font, c111111
    Gui, Color, DFDFDF
  }

  ; create first clipboard 
  Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row0% x%column0% gputOnClipboard0 vclipboard0, [0] %clipboard0%

  ; generate each additional clipboard 
  Loop, %numClipboards% {

    ; checks if GUI is set to either horizontal or vertical display
    ; if horizontal, single row, GUI
    if(displayType == 0) {
      column := column%A_Index%
      row := 0
      GUIHeight := horizontalGUIHeight
      GUIWidth := screenWidth
      GUIYPos := horizontalPosY
      GUIXPos := column0 
    }
    ; else if vertical, single column, GUI
    else if (displayType == 1) {
      column := 0
      row := row%A_Index%
      GUIHeight := verticalGUIHeight
      GUIWidth := sectionWidth
      GUIYPos := verticalPosY

      ; check if the GUI should be on the left or right side
      if(toggleSide == 0) {
        GUIXPos := column0
      }
      else {
        GUIXPos := column%numClipboards%
      }
       
    }

    clip := clipboard%A_Index%

    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row% x%column% gputOnClipboard%A_Index% vclipboard%A_Index%, [%A_Index%] %clip%
  }
  
  ; if GUI is not hidden
  if(hideGUI == 0) {
    Gui, Show, W%GUIWidth% H%GUIHeight% x%GUIXPos% y%GUIYPos%, Sunny
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

  ; loop over all clips
  x := numClipboards
  While (x >= 0) {
    tempClipboard := clipboard%x%
    trimmedClipboard%x% := SubStr(tempClipboard, startPos, endPos)

    ; trim leading and trailing whitespace
    StringReplace, trimmedClipboard%x%, trimmedClipboard%x%, `r`n,,
    StringReplace, trimmedClipboard%x%, trimmedClipboard%x%, `n,,

    ; redrawn the GUI with the trimmed text
    currentTrim := trimmedClipboard%x%
    GuiControl, -redraw, clipboard%x%
    GuiControl,, clipboard%x%, [%x%] %currentTrim%
    GuiControl, +redraw, clipboard%x%

    ; decrement 
    x--
  }

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

; processes mouse button drag
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
