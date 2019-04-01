#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

Position := {"p1":0, "p2":0, "p3":0, "p4":0, "center": 0}

class WinInfo {
    id := -1
    x := 0
    y := 0
    width := 0
    height := 0
}

center := new WinInfo()

RCtrl::
    Init()
    return
    
#If (A_PriorHotKey = "RCtrl" AND A_TimeSincePriorHotkey < 4000)
    RCtrl::
        tgt := Position["center"]
        WinActivate, ahk_id %tgt% 
        return
    1::
        tgt := WinGetAtCoords(100,100)
        WinActivate, ahk_id %tgt% 
        return
    2::
        tgt :=  WinGetAtCoords((A_ScreenWidth-right_pad) - 100, 100) 
        WinActivate, ahk_id %tgt% 
        return        
    3::
        tgt :=  WinGetAtCoords(100,(A_ScreenHeight-_h_) - 100) 
        WinActivate, ahk_id %tgt% 
        return
    4::
        tgt :=  WinGetAtCoords(A_ScreenWidth -right_pad - 100,(A_ScreenHeight-_h_) - 100) 
        WinActivate, ahk_id %tgt% 
        return
    t::
        WinActivate, ahk_exe thunderbird.exe
        return
    s::
        WinActivate, ahk_exe slack.exe
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
        if (winid != center.id or center.id == -1) {
            center.id := winid
            center.x := cur_x
            center.y := cur_y
            center.width := Width
            center.height := Height
            new_x := ((A_ScreenWidth-right_pad)/2)-(Width/2)
            new_y := ((A_ScreenHeight-_h_)/2)-(Height/2)
        } else {
            new_x := center.x
            new_y := center.y
            center.id := -1
        }
        WinMove, ahk_id %winid% ,, new_x, new_y
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
        WinGetPos,cur_x,cur_y, Width, Height, ahk_id %winid%
        WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd	
}

WinGetAtCoords(xCoord, yCoord, ExludeWinID="") ; CoordMode must be relative to screen
{
	WinGet, IDs, List,,, Program Manager
	Loop, %ids%
	{
		_hWin := ids%A_Index%
		WinGetTitle, title, ahk_id %_hWin%
		WinGetPos,,, w, h, ahk_id %_hWin%
		if (w < 110 or h < 110 or title = "") ; Comment this out if you want to include small windows and windows without title
			continue
		WinGetPos, left, top, right, bottom, ahk_id %_hWin%
		right += left, bottom += top
		if (xCoord >= left && xCoord <= right && yCoord >= top && yCoord <= bottom && _hWin != ExludeWinID)
            break
	}
	return _hWin
}