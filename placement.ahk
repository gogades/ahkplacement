﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

Position := {"p1":0, "p2":0, "p3":0, "p4":0, "center": 0}

RCtrl::
	return
	
#If (A_PriorHotKey = "RCtrl" AND A_TimeSincePriorHotkey < 4000)
	1::
		tgt := Position["p1"]
		WinActivate, ahk_id %tgt% 
		return
	2::
		tgt := Position["p2"]
		WinActivate, ahk_id %tgt% 
		return
	3::
		tgt := Position["p3"]
		WinActivate, ahk_id %tgt% 
		return
	4::
		tgt := Position["p4"]
		WinActivate, ahk_id %tgt% 
		return
	RCtrl::
		tgt := Position["center"]
		WinActivate, ahk_id %tgt% 
		return
#If

AppsKey:: 
	Init()
	return

; The #If directive creates context-sensitive hotkeys:

#If (A_PriorHotKey = "AppsKey" AND A_TimeSincePriorHotkey < 4000)
    c::
	AppsKey::
		Position["center"]:=winid
    	WinMove, ahk_id %winid% ,, ((A_ScreenWidth-right_pad)/2)-(Width/2), ((A_ScreenHeight-_h_)/2)-(Height/2)
		return
    w::
	1::
		Position["p1"]:=winid
		WinMove, ahk_id %winid% ,,0,0, (A_ScreenWidth-right_pad)/2, ((A_ScreenHeight-_h_)/2)
		return
    e::
	2::
		Position["p2"]:=winid
		WinMove, ahk_id %winid% ,,(A_ScreenWidth-right_pad)/2,0, (A_ScreenWidth-right_pad)/2, ((A_ScreenHeight-_h_)/2)
		return
    s::
	3::
		Position["p3"]:=winid
		WinMove, ahk_id %winid% ,,0,((A_ScreenHeight-_h_)/2), (A_ScreenWidth-right_pad)/2, ((A_ScreenHeight-_h_)/2)
		return
    d::
	4::
		Position["p4"]:=winid
		WinMove, ahk_id %winid% ,,(A_ScreenWidth-right_pad)/2,((A_ScreenHeight-_h_)/2), (A_ScreenWidth-right_pad)/2, ((A_ScreenHeight-_h_)/2)
		return
    f::
		WinMove, ahk_id %winid% ,,0,0, (A_ScreenWidth-right_pad), (A_ScreenHeight-_h_)
		return
	r::
		Reload
		return
	Escape::
		return
#If ; turn of context sensitivity

Init(){
		global
		right_pad := 205
		winid := WinExist("A")
		WinGetPos,,, Width, Height, ahk_id %winid%
		WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd	
}