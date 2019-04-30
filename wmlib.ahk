; wm functions

windows := {}
context := {}

Startup() {
    global
    context["left_pad"] := 150
    context["right_pad"] := 205
    context["col"] := 3
    context["row"] := 2

    WinGetPos,,,_w_, _h_, ahk_class Shell_TrayWnd
    context["tray_w"] := _w_
    context["tray_h"] := _h_
    ; effective screen size
    context["e_sw"] := A_ScreenWidth - context["right_pad"] - context["left_pad"]
    context["e_sh"] := A_ScreenHeight - context["tray_h"]
    context["colw"] := Floor(context["e_sw"] / context["col"])
    context["rowh"] := Floor(context["e_sh"] / context["row"])

    ; prepare position arrays
    context["pcol"] := []
    context["prow"] := []
    Loop, % context["col"] {
        mul := A_Index - 1
        context["pcol"].Push(Floor(mul * context["colw"] )+context["left_pad"])
    }

    Loop, % context["row"] {
        mul := A_Index - 1
        context["prow"].Push(Floor(mul * context["rowh"]))
    }

	context["previous"] := -1

	; todo setup and capture window events
}

Place(winid, num) {
	global
	row := Floor( num / context["col"] )
	col :=  num - ( row * context["col"] )

	x := context["pcol"][col+1]
	y := context["prow"][row+1]
	w := context["colw"]
	h := context["rowh"]
	SaveWindow(winid, num, x, y, w, h)
	WinMove, ahk_id %winid%,, x, y, w, h
}

SaveWindow(winid, gridpos, new_x, new_y, new_w, new_h){
	global
	WinGetPos, cur_x, cur_y, Width, Height, ahk_id %winid%
	data := {}

	prevdata := windows[winid]
	prevgridpos := -1
	if(prevdata != "" ){
		prevgridpos := prevdata.cur["grid"]
	}

    data.prev["x"] := cur_x
    data.prev["y"] := cur_y
    data.prev["w"] := Width
    data.prev["h"] := Height
	data.prev["grid"] := prevgridpos
	data.cur["x"] := new_x
    data.cur["y"] := new_y
    data.cur["w"] := new_w
    data.cur["h"] := new_h
	data.cur["grid"] := gridpos
	data.zoomed := false
	data.centered := false
	windows[winid] := data
}

FocusSlackTextField(tgtid) {
    WinGetTitle, ttl, ahk_id %tgtid%
    if (ttl == "slack.exe") {
        Send, /{Backspace}
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

FocusByName(exename)
{
	global context
	Init()
	WinGet, tgtid, ID, ahk_exe %exename%
	Focus(tgtid)
}

FocusByPrevious() {
	global context
	Init()
	Focus(context["previous"])
}

FocusByPosition(gridpos) {
	; todo - if gridpos is currently focused, try to find the next one

	global context, windows
	Init()
	for k,v in windows {
		if( v["cur"]["grid"] == gridpos ) {
			Focus( k )
			return
		}
	}
	; todo if window is not found in list, search screen by pixel and add and tag that window
	; to that grid value
}

Focus( tgtid ) {
	global context
    if (tgtid != -1 and tgtid != "" and tgtid != context["winid"] ) {
		context["previous"] := context["winid"]
        WinActivate, ahk_id %tgtid%
        FocusSlackTextField(tgtid)
    }
}

Move( offset ) {
	global context, windows
	Init()
	for k,v in windows {
		if( k == context["winid"] ) {
			newgrid := v["cur"]["grid"]+offset
			max := context["col"]*context["row"] - 1
			if(	newgrid < 0 or newgrid > max or newgrid == v["cur"]["grid"] ) {
				return
			}
			Place(context["winid"],newgrid)
			return
		}
	}
}

Zoom() {
	global context, windows
	Init()
	for k,v in windows {
		if( k == context["winid"] ) {
			tmpid := context["winid"]
			if( v["zoomed"] == false ) {
				v["zoomed"] := true
				; default factors
				width_factor := 1.5
				height_factor := 1.5
				ZoomFactor( width_factor, height_factor)
				new_w := Abs( context["cur_w"] * width_factor )
				new_h := Abs( context["cur_h"] * height_factor )
				new_x := (context["e_sw"]/2)-(new_w/2)+context["left_pad"]
				new_y := (context["e_sh"]/2)-(new_h/2)

				tmpid := context["winid"]
				WinMove, ahk_id %tmpid% ,, new_x, new_y, new_w, new_h
			} else {
				v["zoomed"] := false
				Place(tmpid, v["cur"]["grid"])
			}
		}
	}
}

ZoomFactor(ByRef width_factor, ByRef height_factor) {
	global context
	tmpid := context["winid"]
	WinGet, ttl, ProcessName, ahk_id %tmpid%
	if( ttl == "kitty.exe" ) {
		width_factor := 1.0
		height_factor := 1.5
		return
	}
}

Center() {
; todo - similar to zoom but keep the size the same
	global context, windows
	Init()
	for k,v in windows {
		if( k == context["winid"] ) {
			tmpid := context["winid"]
			if( v["centered"] == false ) {
				v["centered"] := true
				new_x := (context["e_sw"]/2)-(context["cur_w"]/2)+context["left_pad"]
				new_y := (context["e_sh"]/2)-(context["cur_h"]/2)
				tmpid := context["winid"]
				WinMove, ahk_id %tmpid% ,, new_x, new_y
			} else {
				v["centered"] := false
				Place(tmpid, v["cur"]["grid"])
			}
		}
	}
}

LogOutput(message) {
	dir = %A_ScriptDir%\log.txt
	FileAppend,  %A_Hour%:%A_Min%:%A_Sec% %message%`r`n, %dir%
}
