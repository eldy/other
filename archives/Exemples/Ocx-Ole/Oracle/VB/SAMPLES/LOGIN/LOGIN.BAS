Option Explicit

Global OraSession  As Object
Global OraDatabase As Object

'Connection Information
Global UserName$
Global Password$
Global DatabaseName$
Global Connect$

' Show parameters
Global Const MODAL = 1
Global Const MODELESS = 0

Sub CenterForm (F As Form)

' Center the specified form within the screen

    F.Move (Screen.Width - F.Width) \ 2, (Screen.Height - F.Height) \ 2

End Sub

