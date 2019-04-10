#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

context := {}
Startup()

; hook up to monitor window creation/activation/deletion
Gui +LastFound
hWnd := WinExist()
DllCall( "RegisterShellHookWindow", UInt,hWnd )
MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
OnMessage( MsgNum, "ShellMessage" )

; create gui
Gui, Margin, 20, 20
Gui, Add, Text, vStatus , Enter Command
OnMessage(WM_KEYDOWN := 0x100, "ON_KEYDOWN")
OnMessage(WM_SYSKEYDOWN := 0x104, "ON_KEYDOWN")
Return

; show gui
RControl::
    SetTimer, HideGui, 5000
    Init()
    Gui, Show

ShellMessage(wParam, lParam) {
    ; process window events
    WinGetTitle, Title, ahk_id %lParam%
    if ( wParam == 1 ) {
        ;  HSHELL_WINDOWCREATED := 1
        ;~ OutputDebug, window created %Title%
    } else if( wParam == 4 or wParam == 32772) {
        ; HSHELL_WINDOWACTIVATED := 4
        ; HSHELL_RUDEAPPACTIVATED := 32772
        ;~ OutputDebug, window activated %Title%
    } else if( wParam == 2 ) {
        ; HSHELL_WINDOWDESTROYED := 2
        ;~ OutputDebug, window deleted %Title%
    }
}

HideGui() {
    global context
    Gui, Hide
    context["placement"] := false
}

ON_KEYDOWN(WP, LP) {
   If (LP & 0x40000000) ; most likely auto-repeat
      Return 0
   VK := Hex(WP & 0xFF, 2)
   SC := Hex((LP & 0x1FF0000) >> 16, 3)
   nm := GetKeyName("VK" . VK . "SC" . SC)
   ProcessCommand(nm)
   Return 0
}

Hex(I, N) {
   SetFormat, Integerfast, H
   tmpstr := SubStr("00000000" . SubStr(I + 0,3), 1 - N)
   SetFormat, Integerfast, D
   return tmpstr
}

ProcessCommand(KeyPressed) {
    global right_pad, _h_, _w_, context
    SetTimer, HideGui, Off
    If (KeyPressed == "Escape") {
        HideGui()        	    
    }
    ; next commands need Init() called first
    tgtid := -1
    if( KeyPressed == "o") {
        WinGet, tgtid, ID, ahk_exe Spotify.exe
        Focus(tgtid)
    } else if( KeyPressed == "t") {
        WinGet, tgtid, ID, ahk_exe thunderbird.exe
        Focus(tgtid)
    } else if( KeyPressed == "s") {
        WinGet, tgtid, ID, ahk_exe slack.exe
        Focus(tgtid)
    } else if( KeyPressed == "k") {
        WinGet, tgtid, ID, ahk_exe kitty.exe
        Focus(tgtid)
    } if( KeyPressed == "v") {
        WinGet, tgtid, ID, ahk_exe vncviewer.exe
        Focus(tgtid)
    } if( KeyPressed > 0 and KeyPressed <= (context["col"]*context["row"]) ) {
        num := Keypressed - 1
        row := Floor( num / context["col"] )
        col :=  num - ( row * context["col"] )

        x := context["pcol"][col+1]
        y := context["prow"][row+1] 
        w := context["colw"]
        h := context["rowh"]
        tmpid := context["winid"]
        if(context["placement"] == true) {
            WinMove, ahk_id %tmpid%,, x, y, w, h
        } else {
            fudge := 50
            search_x := x + ( w / 2) 
            if( y > (context["e_sh"] / 2) - fudge ) {
                search_y := context["e_sh"] - fudge
            } else {
                search_y := y + fudge
            }
            tgtid := WinGetAtCoords( search_x, search_y)
            Focus(tgtid)
        }
    } else if( KeyPressed == "m" ) {
        context["placement"] := true
        SetTimer, HideGui, 5000
        return
    } else if( KeyPressed == "p" or KeyPressed == "Delete" ) {
        tgtid := context["previous"]
        Focus(tgtid)
    } else if( KeyPressed == "c" or KeyPressed == "``" ) {
        if( context["placement"] == false ) {
            tgtid := context["center_window"]
            Focus(tgtid)
        } else {
            new_x := (context["e_sw"]/2)-(context["cur_w"]/2)
            new_y := (context["e_sh"]/2)-(context["cur_h"]/2)
            tmpid := context["winid"]
            WinMove, ahk_id %tmpid% ,, new_x, new_y
            context["center_window"] := tmpid
        }
    }
    ;~ GuiControl,,Status, Focus %KeyPressed%
    ;~ Sleep, 500
    HideGui()
}

Startup() {
    global
    context["right_pad"] := 205
    context["col"] := 3
    context["row"] := 2

    WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd
    context["tray_w"] := _w_
    context["tray_h"] := _h_
    ; effective screen size
    context["e_sw"] := A_ScreenWidth - context["right_pad"]
    context["e_sh"] := A_ScreenHeight - context["tray_h"]
    context["colw"] := Floor(context["e_sw"] / context["col"])
    context["rowh"] := Floor(context["e_sh"] / context["row"])

    ; prepare position arrays
    context["pcol"] := []
    context["prow"] := []
    Loop, % context["col"] {
        mul := A_Index - 1
        context["pcol"].Push(Floor(mul * context["colw"] ))
    }

    Loop, % context["row"] {
        mul := A_Index - 1
        context["prow"].Push(Floor(mul * context["rowh"]))
    }
}

Init(){
    global
    context["winid"] := WinExist("A")
    winid := context["winid"]
    WinGetPos, cur_x, cur_y, Width, Height, ahk_id %winid%

    context["cur_x"] := cur_x
    context["cur_y"] := cur_y
    context["cur_w"] := Width
    context["cur_h"] := Height

    context["placement"] := false
}

Focus(tgtid)
{
    global context
    if (tgtid != -1 and tgtid != "" and tgtid != context["winid"]) {
        context["previous"] := context["winid"]
        WinActivate, ahk_id %tgtid%
    } else {
        ;~ MsgBox, not found
    }
}

WinGetAtCoords(xCoord, yCoord, ExludeWinID="") ; CoordMode must be relative to screen
{
    global winid, cur_x, cur_y, Width, Height, _w_, _h_, context
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
