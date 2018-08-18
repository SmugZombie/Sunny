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

; variables
global _debug := true
numberOfClipboards = 6
global clipboards := Object()


;==[ FUNCTIONS ]================================================================

; creates the array elements for each clipboard
initialize_clipboards(numberOfClipboards := 6) {

    ; iterate through each clipboard
    loop % numberOfClipboards {

        ; create a null string
        clipboards.Push("")
    }
}

; updates clipboard contents
; called on any clipboard change
update_clipboards() {

    ; trim whitespace at the beginning or end of the string
    tempClipboard := RegexReplace(clipboard, "^\s+|\s+$")

    ; flag for checking if a match was found in the existing clipboards array
    matchFound := false

    ; iterate through all current clipboards
    loop % clipboards.Length() {

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

    ; call function to update GUI

    ; debugging output to see values visually
    if(_debug == true) {
        MsgBox % "ClipboardLength: " clipboards.Length() "`n`nClipboard1:`n" clipboards[1] "`n`nClipboard2:`n" clipboards[2] "`n`nClipboard3:`n" clipboards[3] "`n`nClipboard4:`n" clipboards[4] "`n`nClipboard5:`n" clipboards[5] "`n`nClipboard6:`n" clipboards[6]
    }
}

;==[ MAIN ]=====================================================================

OnClipboardChange("update_clipboards")
initialize_clipboards(numberOfClipboards)