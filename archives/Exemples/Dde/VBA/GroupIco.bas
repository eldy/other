Attribute VB_Name = "Groupe_Icon"
Option Explicit


Function CreatePROGMANIcon (CommandLine$, IconText$, GroupName$)
'**************************************************
' FUNCTION: CreatePROGMANIcon   
'
' To create an icon in the Windows Program Manager.
'   
' ARGUMENTS:
'   CommandLine - The command line argument to execute
'                 when the icon is double-clicked.
'   IconText    - The text to appear under the icon.
'   GroupName   - The name of the group to place the icon in.
'
' RESULT:
'   An icon is placed in the specified group. If the
'   group does not exist, a new group is created.   '
'
' EXAMPLE:
' CreatePROGMANIcon("C:\WINDOWS\NOTEPAD.EXE C:\AUTOEXEC.BAT", "Edition autoexec", "MAIN")
'
' *************************************************

Dim ChanNum As Integer
Dim Groups As String
Dim Exe As String

' Begin a DDE conversation with Program Manager.
ChanNum = DDEInitiate("PROGMAN", "PROGMAN")

' Request a tab delimited list of Program Manager groups.
Groups = DDERequest(ChanNum, "Progman")

' See if the requested group exists in the list.
' If not, create the group.
If Not InStr(1, Groups, GroupName) Then
	DDEExecute ChanNum, "[CreateGroup(" & GroupName & ")]"
End If

' Add an icon to the group with the specified text underneath.
Exe = "[AddItem(" & CommandLine & ", " & IconText & ",,)]"
DDEExecute ChanNum, Exe
DDETerminate ChanNum

End Function





Function CreatePROGMANIcon2 (CommandLine$, IconText$, GroupName$, IconFile$, IconNum$)
'**************************************************
' FUNCTION: CreatePROGMANIcon2
'
' To create an icon in the Windows Program Manager.
'   
' ARGUMENTS:
'   CommandLine - The command line argument to execute
'                 when the icon is double-clicked.
'   IconText    - The text to appear under the icon.
'   GroupName   - The name of the group to place the icon in.
'
' RESULT:
'   An icon is placed in the specified group. If the
'   group does not exist, a new group is created.   '
'
' EXAMPLE:
' CreatePROGMANIcon("C:\WINDOWS\NOTEPAD.EXE C:\AUTOEXEC.BAT", "Edition autoexec", "MAIN","toto.dll",1)
'
' *************************************************

Dim ChanNum As Integer
Dim Groups As String
Dim Exe As String

' Begin a DDE conversation with Program Manager.
ChanNum = DDEInitiate("PROGMAN", "PROGMAN")

' Request a tab delimited list of Program Manager groups.
Groups = DDERequest(ChanNum, "Progman")

' See if the requested group exists in the list.
' If not, create the group.
If Not InStr(1, Groups, GroupName) Then
	DDEExecute ChanNum, "[CreateGroup(" & GroupName & ")]"
End If

' Add an icon to the group with the specified text underneath.
Exe = "[AddItem(" & CommandLine & ", " & IconText & ", " & IconFile & ", " & IconNum & ")]"
DDEExecute ChanNum, Exe
DDETerminate ChanNum

End Function


