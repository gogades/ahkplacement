#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

context := {}

; SetBatchLines, -1
Gui, Margin, 20, 20
Gui, Add, Text, , Enter Command
OnMessage(WM_KEYDOWN := 0x100, "ON_KEYDOWN")
OnMessage(WM_SYSKEYDOWN := 0x104, "ON_KEYDOWN")
Return

GuiClose:
Gui, Hide

RControl::
	SetTimer, HideGui, 5000
	Init()
	Gui, Show

HideGui() {
	Gui, Hide
}

ON_KEYDOWN(WP, LP) {
   If (LP & 0x40000000) ; most likely auto-repeat
      Return 0
   VK := Hex(WP & 0xFF, 2)
   SC := Hex((LP & 0x1FF0000) >> 16, 3)
   ;~ Row := LV_Add("", GetKeyName("VK" . VK . "SC" . SC), VK, SC)
   ;~ LV_Modify(Row, "Vis")
   nm := GetKeyName("VK" . VK . "SC" . SC)
   ProcessCommand(nm)
   Return 0
}

Hex(I, N) {
   SetFormat, Integerfast, H
   Return SubStr("00000000" . SubStr(I + 0,3), 1 - N)
}


ProcessCommand(KeyPressed) {
	global right_pad, _h_, _w_, context
	SetTimer, GuiClose, Off
	If (KeyPressed == "Escape") {
		HideGui()        	    
	}
	; next commands need Init() called first
	tgtid := -1
	if( KeyPressed == "t") {
		WinGet, tgtid, ID, ahk_exe thunderbird.exe
	} else if( KeyPressed == "s") {
		WinGet, tgtid, ID, ahk_exe slack.exe
	} else if( KeyPressed == "k") {
		WinGet, tgtid, ID, ahk_exe kitty.exe
	} if( KeyPressed == "v") {
		WinGet, tgtid, ID, ahk_exe vncviewer.exe
	} else if( KeyPressed == "1" ) {
		tgtid := WinGetAtCoords(100,100)
	} else if( KeyPressed == "2" ) {
		tgtid := WinGetAtCoords(A_ScreenWidth-context["right_pad"]-100, 100) 
	} else if( KeyPressed == "3" ) {
		tgtid := WinGetAtCoords(100,A_ScreenHeight-context["tray_h"]-100) 
	} else if( KeyPressed == "4" ) {
		tgtid := WinGetAtCoords(A_ScreenWidth-context["right_pad"]-100,A_ScreenHeight-context["tray_h"]-100) 
	} else if( KeyPressed == "m" ) {
		context["placement"] := true
		return
	} else if( KeyPressed == "p"  ) {
		if( context["previous"] != "" ) {
			tgtid := context["previous"]
		} 
	}
	if (tgtid != -1 and tgtid != "" and tgtid != context["winid"]) {
		context["previous"] := context["winid"]
		WinActivate, ahk_id %tgtid%
	} else {
		;~ MsgBox, not found
	}
	HideGui()
}

Init(){
        global 
		context["right_pad"] := 205
		context["winid"] := WinExist("A")
        right_pad := 205
        winid := WinExist("A")
        
		WinGetPos, cur_x, cur_y, Width, Height, ahk_id %winid%
		context["cur_x"] := cur_x
		context["cur_y"] := cur_y
		context["cur_w"] := Width
		context["cur_h"] := Height
        WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd	
		context["tray_w"] := _w_
		context["tray_h"] := _h_
		context["placement"] := false
}

WinGetAtCoords(xCoord, yCoord, ExludeWinID="") ; CoordMode must be relative to screen
{
	global winid, cur_x, cur_y, Width, Height, _w_, _h_, context
	SetFormat, IntegerFast, D
	WinGet, _IDs, List,,, Program Manager
	Loop, %_ids%
	{
		_hWin := _ids%A_Index%
		WinGetTitle, _title, ahk_id %_hWin%
        if( _title == "NVIDIA GeForce Overlay" or _title == "Stream Viewer" or InStr(_title, "VirtualBox"))
            continue
		WinGetPos,,, w, h, ahk_id %_hWin%
		if (w < 110 or h < 110 or _title = "") ; Comment this out if you want to include small windows and windows without title
			continue
		WinGetPos, left, top, right, bottom, ahk_id %_hWin%
		right += left, bottom += top
		if (xCoord >= left && xCoord <= right && yCoord >= top && yCoord <= bottom && _hWin != ExludeWinID)
            break
	}
	return _hWin
}

RAlt::
    return
#If (A_PriorHotKey = "RAlt" AND A_TimeSincePriorHotkey < 500)
    RAlt::
        WinMinimize, A
        return
#If

; this allows non-handle alt keys to continue working
RAlt & j::Send, {RAlt Down}j{RAlt Up}
