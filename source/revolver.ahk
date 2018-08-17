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

; globals
clipboards := []


;==[ FUNCTIONS ]================================================================

; 
initialize_clipboards(numberOfClipboards:=6) {

}

;==[ MAIN ]=====================================================================