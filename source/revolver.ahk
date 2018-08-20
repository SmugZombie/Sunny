; Revolver (Sunny v4.0)
; Author: Jeff Reeves
; Purpose: Multiple clipboard manager for Windows
; Last Update: Complete rewrite from scratch

;==[ INIT ]=====================================================================

; environment
#NoEnv
#Persistent
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

; tray icon for source code version
Menu, Tray, Icon, revolver-64.png

; set the process to high prority
Process, Priority,, High

; debugging
global _debug := false

; settings
global numberOfClipboards := 6
global darkMode := true
global horizontalMode := true
global verticalLeftSide := true
global displayGui := true

; clipboards and gui elements
global clipboards := Object()
loop, % numberOfClipboards {
    guiClipboard%A_Index% = 
}
global sectionWidth := 320 ; default 320 = 1920 px width / 6 clipboards


;==[ FUNCTIONS ]================================================================

; creates the array elements for each clipboard
; accepts an int value for the number of clipboards to use, default = 6
initialize_clipboards() {

    ; sets clipboards object to an empty array
    clipboards := Object()

    ; iterate through each clipboard
    loop, % numberOfClipboards {

        ; create a null string
        clipboards.Push("")

        ; create an empty variable
        guiClipboard%A_Index% =
    }

    return
}

; initializes the keys to be bound to each clipboard
initialize_keybinds() {

    ; turn off all numpad hotkeys
    ; useful when reducing the number of clipboards in use
    loop, 9 {
        Hotkey, % "~^Numpad" A_Index, Off, UseErrorLevel

        ; if the hotkey is not already established (error 5 and 6)
        if (ErrorLevel in 5,6) {

            ; do nothing
            continue
        }
    }

    ; iterate through each clipboard element in the array
    ; uses global clipboards array
    loop, % clipboards.Length() {

        ; activates the numpad hotkeys for each clipboard
        Hotkey, % "~^Numpad" A_Index, % "loadClip" A_Index
    }

    return
}

; updates contents of clipboard array
; called on any clipboard change
update_clipboards() {

    ; trim whitespace at the beginning or end of the string
    tempClipboard := RegexReplace(clipboard, "^\s+|\s+$")

    ; flag for checking if a match was found in the existing clipboards array
    matchFound := false

    ; iterate through all current clipboards
    ; uses global clipboards array
    loop, % clipboards.Length() {

        ; check if any existing array value matches new item
        if (tempClipboard == clipboards[A_Index]) {

            ; update flag
            matchFound := true

            ; delete the matched element from the existing array
            clipboards.RemoveAt(A_Index)
        
            ; insert the match back at the start of the array
            ;   existing values are shifted over automatically
            clipboards.InsertAt(1, tempClipboard)
            break
        }
    }

    ; if no match was found
    if (matchFound == false) {

        ; insert the new item into the start of the array
        ;   existing values are shifted over automatically
        clipboards.InsertAt(1, tempClipboard)

        ; remove the last array element
        clipboards.Pop()
    }

    ; update GUI
    update_gui()

    ; debugging output to see values visually
    if (_debug == true) {
        MsgBox % "ClipboardLength: " clipboards.Length() "`n`nClipboard1:`n" clipboards[1] "`n`nClipboard2:`n" clipboards[2] "`n`nClipboard3:`n" clipboards[3] "`n`nClipboard4:`n" clipboards[4] "`n`nClipboard5:`n" clipboards[5] "`n`nClipboard6:`n" clipboards[6]
    }

    return
}

; changes the content of the active clipboard based on the numpad key pressed
change_clip(numpadKey := 1) {

    ; make sure numpad key is within range of clipboard array
    ; uses global clipboards array
    if (numpadKey <= clipboards.Length()) {

        ; move contents of element on clipboard array to active clipboard
        clipboard := clipboards[numpadKey]

        ; wait for clipboard to fully update
        ClipWait, 1
    }

    return
}

; pastes the clipboard's contents
paste_clip() {

    ; send keys to paste
    SendInput, ^v
}

get_monitor_info() {

    ; get total number of monitors 
    SysGet, numberOfMonitors, MonitorCount

    ; get primary monitor 
    SysGet, primaryMonitor, MonitorPrimary

    ; debugging output to see values visually
    if (_debug == true) {
        MsgBox, % "numberOfMonitors " numberOfMonitors
        MsgBox, % "primaryMonitor " primaryMonitor
    }

    ; get primary screen area minus taskbar
    ; uses global monitorWidth and monitorHeight
    SysGet, workArea, MonitorWorkArea, % primaryMonitor
    monitorWidth := workAreaRight - workAreaLeft
    monitorHeight := workAreaBottom - workAreaTop

    ; splits the work-able screen area to the number of clipboards
    sectionWidth := monitorWidth / clipboards.Length()

    ; debugging output to see values visually
    if (_debug == true) {
        MsgBox % "monitorWidth = " monitorWidth "`nmonitorHeight = " monitorHeight "`nsectionWidth = " sectionWidth
    }

    return, { monitorWidth: monitorWidth, monitorHeight: monitorHeight}
}

; initializes the gui
initialize_gui(monitorWidth, monitorHeight) {

    ; sets values of the GUI
    heightOfRow := 20
    transparencyLevel := 200

    ; sets horizontal and vertical GUI height
    horizontalGUIHeight := 20
    verticalGUIHeight := 20 * clipboards.Length()

    ; sets the bottom position of the GUI above the taskbar
    horizontalPosY := monitorHeight - horizontalGUIHeight
    verticalPosY := monitorHeight - verticalGUIHeight

    ; create arrays to hold the x/y position of rows/columns for each clipboard
    row := []
    column := []
    Loop, % clipboards.Length() {
        row.Push(heightOfRow * (A_Index - 1)) ; subtract 1 to count from base 0
        column.Push(sectionWidth * (A_Index - 1))
        
        if (_debug == true) {
            MsgBox, % A_Index "`nrow " row[A_Index] "`ncolumn " column[A_Index]
        }
    }

    ; set common GUI settings 
    Gui, Font, s10, Verdana
    Gui, +AlwaysOnTop +ToolWindow +LastFound
    WinSet, Transparent, %transparencyLevel%
    Gui -Caption

    ; dark mode
    if (darkMode == true) {
        Gui, Font, cFFFFFF
        Gui, Color, 222222
    }
    else {
        Gui, Font, c111111
        Gui, Color, DFDFDF
    }

    ; generate the text element for each clipboard in the gui
    Loop, % clipboards.Length() {

        ; checks if GUI is set to either horizontal or vertical display
        ; if horizontal, single row gui
        if (horizontalMode == true) {

            currentColumn := column[A_Index]
            currentRow := 0
            GUIHeight := horizontalGUIHeight
            GUIWidth := monitorWidth
            GUIYPos := horizontalPosY
            GUIXPos := 0 
        }
        ; else vertical, single column gui
        else {

            currentColumn := 0
            currentRow := row[A_Index]
            GUIHeight := verticalGUIHeight
            GUIWidth := sectionWidth
            GUIYPos := verticalPosY

            ; check if the GUI should be on the left or right side
            if (verticalLeftSide == true) {
                GUIXPos := 0
            }
            else {
                GUIXPos := column[clipboards.Length()]
            }
            
        }

        ; get contents of clipboard
        currentClip := clipboards[A_Index]

        ; generate the gui element for each clipboard
        Gui, Add, Text, R1 H%heightOfRow% W%sectionWidth% y%currentRow% x%currentColumn% gloadClip%A_Index% vguiClipboard%A_Index%, [%A_Index%] %currentClip%
    }

    ; if GUI is not hidden
    if (displayGui == true) {
        Gui, Show, W%GUIWidth% H%GUIHeight% x%GUIXPos% y%GUIYPos%, Revolver
    }
    else {
        Gui, Hide
    }

    return
}

; redraws the gui
update_gui() {

    ; declare font size
    fontSize := 10

    ; trims text for preview in GUI
    startPos := 1
    endPos := sectionWidth / fontSize

    ; loop over all clips
    Loop, % clipboards.Length() {

        tempClipboard := clipboards[A_Index]
        trimmedClipboard := SubStr(tempClipboard, startPos, endPos)

        ; trim leading and trailing carriage returns / newlines
        StringReplace, trimmedClipboard, trimmedClipboard, `r`n,,
        StringReplace, trimmedClipboard, trimmedClipboard, `n,,

        ; redrawn the GUI with the trimmed text
        currentTrim := trimmedClipboard
        GuiControl, -redraw, guiClipboard%A_Index%
        GuiControl,, guiClipboard%A_Index%, [%A_Index%] %currentTrim%
        GuiControl, +redraw, guiClipboard%A_Index%
    }
    
    return
}

;==[ MAIN ]=====================================================================

initialize_clipboards()
system := get_monitor_info()
OnClipboardChange("update_clipboards")
initialize_keybinds()
initialize_gui(system.monitorWidth, system.monitorHeight)


;==[ SUBROUTINES ]==============================================================
; unfortuanetly AHK's syntax prevents using gFunction(param) during Gui, Add
; so it is necessary to create a bunch of subroutines bound to individual labels
; (see: https://autohotkey.com/boards/viewtopic.php?t=23277) 


; clipboard hotkey labels
;   called when clicking on Gui text or 

loadClip1:
    change_clip(1)
    paste_clip()
    update_gui()
    return
    
loadClip2:
    change_clip(2)
    paste_clip()
    update_gui()
    return

loadClip3:
    change_clip(3)
    paste_clip()
    update_gui()
    return
    
loadClip4:
    change_clip(4)
    paste_clip()
    update_gui()
    return

loadClip5:
    change_clip(5)
    paste_clip()
    update_gui()
    return
    
loadClip6:
    change_clip(6)
    paste_clip()
    update_gui()
    return

loadClip7:
    change_clip(7)
    paste_clip()
    update_gui()
    return

loadClip8:
    change_clip(8)
    paste_clip()
    update_gui()
    return
    
loadClip9:
    change_clip(9)
    paste_clip()
    update_gui()
    return