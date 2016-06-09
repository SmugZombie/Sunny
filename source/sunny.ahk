; Sunny v2.41
; Author: Jeff Reeves
; Contributor: Ron Egli [github.com/smugzombie]
; Last Updated: June 9, 2016

OnMessage(0x201, "WM_LBUTTONDOWN")
;OnMessage(0x204, "WM_RBUTTONDOWN")
;OnMessage(0x207, "WM_MBUTTONDOWN")

#NoEnv
#Persistent
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%
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
Menu, Tray, Tip, [Sunny v2.3] by Jeff Reeves

; tray icon for source code version
Menu, Tray, Icon, sunny_icon.ico

Process, Priority,, High

; setup clipboards
clipboard1 = %clipboard%
clipboard2 =
clipboard3 =
clipboard4 =
clipboard5 =
clipboard6 =
clipboard7 =
clipboard8 =
clipboard9 =
clipboard0 =

; user settings
IniRead, iniFound, sunny.ini, Found, iniFound, 0

; if an ini file is found, read from it
if(iniFound == 1){
  IniRead, displayType, sunny.ini, Display, displayType, 0
  IniRead, toggleSide, sunny.ini, Display, toggleSide, 0
  IniRead, nightMode, sunny.ini, Display, nightMode, 1
}
else {
  ; write ini file with default values
  IniWrite, 1, sunny.ini, Found, iniFound
  IniWrite, 0, sunny.ini, Display, displayType
  IniWrite, 0, sunny.ini, Display, toggleSide
  IniWrite, 1, sunny.ini, Display, nightMode

  ; load defaults
  displayType := 0
  toggleSide := 0
  nightMode := 1
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
        jeff@jefflr.com
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

  ; if the item copied doesn't match anything already in the clipboard array
  if((tempClipboard != clipboard0) && (tempClipboard != clipboard9) && (tempClipboard != clipboard8) && (tempClipboard != clipboard7) && (tempClipboard != clipboard6) && (tempClipboard != clipboard5) && (tempClipboard != clipboard4) && (tempClipboard != clipboard3) && (tempClipboard != clipboard2) && (tempClipboard != clipboard1)){
    ; shift each clipboard over one
    clipboard0 := clipboard9
    clipboard9 := clipboard8
    clipboard8 := clipboard7
    clipboard7 := clipboard6
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%

    Gosub, redrawGUI
  }

  if(tempClipboard == clipboard0){
    clipboard0 := clipboard9
    clipboard9 := clipboard8
    clipboard8 := clipboard7
    clipboard7 := clipboard6
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard9){
    clipboard9 := clipboard8
    clipboard8 := clipboard7
    clipboard7 := clipboard6
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard8){
    clipboard8 := clipboard7
    clipboard7 := clipboard6
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard7){
    clipboard7 := clipboard6
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard6){
    clipboard6 := clipboard5
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard5){
    clipboard5 := clipboard4
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard4){
    clipboard4 := clipboard3
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard3){
    clipboard3 := clipboard2
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }
  else if(tempClipboard == clipboard2){
    clipboard2 := clipboard1
    clipboard1 = %tempClipboard%
    Gosub, redrawGUI
  }

  tempClipboard =
  Return

getSystemInfo:
  ; get the primary monitor
  SysGet, monitorPrimary, MonitorPrimary

  ; get the name of the monitor
  SysGet, monitorName, MonitorName, monitorPrimary
  ; get the resolution of the monitor
  SysGet, monitorArea, Monitor, monitorPrimary
  ; get the work-able area (non-taskbar) of the monitors
  SysGet, monitorWorkArea, MonitorWorkArea, monitorPrimary
  Return

generateGUI:

  ; if we are generating only a single row
  if(displayType == 0){

    ; sets values of the GUI
    heightOfGUI := 20
    heightOfRow := 20
    transparencyLevel := 200

    ; sets the bottom position of the GUI above the taskbar
    posY := monitorAreaBottom - (heightOfGUI * 3)

    ; splits the work-able screen area into eleven cells
    sectionWidth := monitorWorkAreaRight / 10

    ; gets the x position of columns
    column1 := 0
    column2 := sectionWidth
    column3 := sectionWidth * 2
    column4 := sectionWidth * 3
    column5 := sectionWidth * 4
    column6 := sectionWidth * 5
    column7 := sectionWidth * 6
    column8 := sectionWidth * 7
    column9 := sectionWidth * 8
    column0 := sectionWidth * 9

    ;gets the y positon of rows
    row1 := 0

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

    ; single row of GUI
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column1% gputOnClipboard1 vclipboardOne, [1] %clipboard1%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column2% gputOnClipboard2 vclipboardTwo, [2] %clipboard2%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column3% gputOnClipboard3 vclipboardThree, [3] %clipboard3%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column4% gputOnClipboard4 vclipboardFour, [4] %clipboard4%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column5% gputOnClipboard5 vclipboardFive, [5] %clipboard5%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column6% gputOnClipboard6 vclipboardSix, [6] %clipboard6%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column7% gputOnClipboard7 vclipboardSeven, [7] %clipboard7%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column8% gputOnClipboard8 vclipboardEight, [8] %clipboard8%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column9% gputOnClipboard9 vclipboardNine, [9] %clipboard9%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x%column0% gputOnClipboard0 vclipboardTen, [0] %clipboard0%

    ; sets hide control on GUI
    ;Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% Center y0 x%column10% gdestroyGUI, Hide

    ; show GUI
    Gui, Show, W%monitorWorkAreaRight% H%heightOfGUI% x%column1% y%posY%, Sunny
  }
  ; we are generating a vertical column
  else if (displayType == 1){

    heightOfRow := 20
    heightOfGUI := heightOfRow * 10 ;gives the height for all ten columns
    transparencyLevel := 200

    ; sets the bottom position of the GUI above the taskbar
    posY := monitorAreaBottom - (heightOfRow * 12)

    ; splits the work-able screen area into four equal parts
    sectionWidth := monitorWorkAreaRight / 4

    ; gets the x position of columns
    if(toggleSide == 0){
      guiX := 0
    }
    else if(toggleSide == 1){
      guiX := monitorWorkAreaRight - sectionWidth
    }

    ; gets the y position of rows
    row1 := 0
    row2 := heightOfRow
    row3 := heightOfRow * 2
    row4 := heightOfRow * 3
    row5 := heightOfRow * 4
    row6 := heightOfRow * 5
    row7 := heightOfRow * 6
    row8 := heightOfRow * 7
    row9 := heightOfRow * 8
    row0 := heightOfRow * 9

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

    ; single column GUID
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row1% x0 gputOnClipboard1 vclipboardOne, [1] %clipboard1%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row2% x0 gputOnClipboard2 vclipboardTwo, [2] %clipboard2%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row3% x0 gputOnClipboard3 vclipboardThree, [3] %clipboard3%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row4% x0 gputOnClipboard4 vclipboardFour, [4] %clipboard4%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row5% x0 gputOnClipboard5 vclipboardFive, [5] %clipboard5%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row6% x0 gputOnClipboard6 vclipboardSix, [6] %clipboard6%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row7% x0 gputOnClipboard7 vclipboardSeven, [7] %clipboard7%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row8% x0 gputOnClipboard8 vclipboardEight, [8] %clipboard8%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row9% x0 gputOnClipboard9 vclipboardNine, [9] %clipboard9%
    Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%row0% x0 gputOnClipboard0 vclipboardTen, [0] %clipboard0%

    ; sets hide control on GUI
    ;Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% Center y0 x%column10% gdestroyGUI, Hide
    ; show GUI
    Gui, Show, W%sectionWidth% H%heightOfGUI% x%guiX% y%posY%, Sunny
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


  trimmedClipboard1 := SubStr(clipboard1, startPos, endPos)
  trimmedClipboard2 := SubStr(clipboard2, startPos, endPos)
  trimmedClipboard3 := SubStr(clipboard3, startPos, endPos)
  trimmedClipboard4 := SubStr(clipboard4, startPos, endPos)
  trimmedClipboard5 := SubStr(clipboard5, startPos, endPos)
  trimmedClipboard6 := SubStr(clipboard6, startPos, endPos)
  trimmedClipboard7 := SubStr(clipboard7, startPos, endPos)
  trimmedClipboard8 := SubStr(clipboard8, startPos, endPos)
  trimmedClipboard9 := SubStr(clipboard9, startPos, endPos)
  trimmedClipboard0 := SubStr(clipboard0, startPos, endPos)

  ; loop through trimmed clipboards to remove bad formatting
  loop, 10 {
   ; trim leading and trailing whitespace
   trimmedClipboard%A_Index% := trimmedClipboard%A_Index%
   ;StringReplace, trimmedClipboard%A_Index%, trimmedClipboard%A_Index%, %A_SPACE%, ,
   StringReplace, trimmedClipboard%A_Index%, trimmedClipboard%A_Index%, `r`n, %A_SPACE%,
  }

  GuiControl, -redraw, clipboardOne
  GuiControl,, clipboardOne, [1] %trimmedClipboard1%
  GuiControl, +redraw, clipboardOne

  GuiControl, -redraw, clipboardTwo
  GuiControl,, clipboardTwo, [2] %trimmedClipboard2%
  GuiControl, +redraw, clipboardTwo

  GuiControl, -redraw, clipboardThree
  GuiControl,, clipboardThree, [3] %trimmedClipboard3%
  GuiControl, +redraw, clipboardThree

  GuiControl, -redraw, clipboardFour
  GuiControl,, clipboardFour, [4] %trimmedClipboard4%
  GuiControl, +redraw, clipboardFour

  GuiControl, -redraw, clipboardFive
  GuiControl,, clipboardFive, [5] %trimmedClipboard5%
  GuiControl, +redraw, clipboardFive

  GuiControl, -redraw, clipboardSix
  GuiControl,, clipboardSix, [6] %trimmedClipboard6%
  GuiControl, +redraw, clipboardSix

  GuiControl, -redraw, clipboardSeven
  GuiControl,, clipboardSeven, [7] %trimmedClipboard7%
  GuiControl, +redraw, clipboardSeven

  GuiControl, -redraw, clipboardEight
  GuiControl,, clipboardEight, [8] %trimmedClipboard8%
  GuiControl, +redraw, clipboardEight

  GuiControl, -redraw, clipboardNine
  GuiControl,, clipboardNine, [9] %trimmedClipboard9%
  GuiControl, +redraw, clipboardNine

  GuiControl, -redraw, clipboardTen
  GuiControl,, clipboardTen, [0] %trimmedClipboard0%
  GuiControl, +redraw, clipboardTen

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
  if(toggleGUI := !toggleGUI){
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