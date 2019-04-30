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
^#`::
	FocusByPosition(0)
	return

^#2::
^#Home::
	FocusByPosition(1)
	return

^#3::
^#PgUp::
	FocusByPosition(2)
	return

^#4::
^#Delete::
	FocusByPosition(3)
	return

^#5::
^#End::
	FocusByPosition(4)
	return

^#6::
^#PgDn::
	FocusByPosition(5)
	return

; ==================================== toggle zoom or center on current window
^#z::
^#/::
	Zoom()
	return

^#c::
^#.::
	Center()
	return


; ==================================== place by position
!^#1::
!^#`::
	winid := WinExist("A")
	Place( winid, 0)
	return

!^#2::
!^#Home::
	winid := WinExist("A")
	Place( winid, 1)
	return

!^#3::
!^#PgUp::
	winid := WinExist("A")
	Place( winid, 2)
	return

!^#4::
!^#Delete::
	winid := WinExist("A")
	Place( winid, 3)
	return

!^#5::
!^#End::
	winid := WinExist("A")
	Place( winid, 4)
	return

!^#6::
!^#PgDn::
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

