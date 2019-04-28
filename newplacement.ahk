#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force

#Include wmlib.ahk
Startup()

; ==================================== focus by app name
^#s::
	FocusByName("slack.exe")
	return

^#k::
	FocusByName("kitty.exe")
	return

^#v::
	FocusByName("vncviewer.exe")
	return

^#o::
	FocusByName("Spotify.exe")
	return

^#t::
	FocusByName("thunderbird.exe")
	return

; ==================================== focus previous
^#p::
	FocusByPrevious()
	return

; ==================================== focus by position
^#1::
	FocusByPosition(0)
	return

^#2::
	FocusByPosition(1)
	return

^#3::
	FocusByPosition(2)
	return

^#4::
	FocusByPosition(3)
	return

^#5::
	FocusByPosition(4)
	return

^#6::
	FocusByPosition(5)
	return

; ==================================== toggle zoom on current window
^#z::
	Zoom()
	return

; place by position
!^#1::
	winid := WinExist("A")
	Place( winid, 0)
	return

!^#2::
	winid := WinExist("A")
	Place( winid, 1)
	return

!^#3::
	winid := WinExist("A")
	Place( winid, 2)
	return

!^#4::
	winid := WinExist("A")
	Place( winid, 3)
	return

!^#5::
	winid := WinExist("A")
	Place( winid, 4)
	return

!^#6::
	winid := WinExist("A")
	Place( winid, 5)
	return

; ==================================== place by arrowkey
!^#Up::
	Move( 0 - context["col"] )
	return

!^#Down::
	Move( context["col"] )
	return

!^#Left::
	Move( -1 )
	return

!^#Right::
	Move( 1 )
	return

