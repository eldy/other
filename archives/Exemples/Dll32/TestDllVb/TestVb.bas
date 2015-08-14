Attribute VB_Name = "DLLWVB1"
'****************************************************************************
' Teste d'utilisation de DLL 32bits en Visual Basic 32bits sous Windows
'****************************************************************************
Option Explicit


'Constantes diverses
Global Const barhgt = 325
Global CRLF As String * 2
Global chargement As Single
Global res As Integer
Global NomFich As String
Global NumFich As Integer
Global Modif As Single

' Windows API Function Declarations
Declare Function TextOut Lib "gdi32" Alias "TextOutA" (ByVal hdc As Long, ByVal x As Long, ByVal y As Long, ByVal lpString As String, ByVal nCount As Long) As Long

Declare Function Signe Lib "d:\Exemples\Dll32\MathDllVc\Debug\Mathvc" (i As Integer) As Integer
Declare Function Puissance Lib "d:\Exemples\Dll32\MathDllVc\Debug\Mathvc" (ByVal i As Double, ByVal j As Double) As Double

Sub CENTRE(Feuille As Form)
Feuille.Top = (Screen.Height - Feuille.Height) / 2
Feuille.Left = (Screen.Width - Feuille.Width) / 2
End Sub





Function HEX_DEC(s As String) As Integer
HEX_DEC = Val("&h" + Right$("0000" + s, 4))
End Function

Sub MAIN()
chargement = True
CRLF = Chr$(13) + Chr$(10)
Modif = False
App.Title = "Test"
App.HelpFile = App.Path + "\test.hlp"
If App.PrevInstance Then
  MsgBox "Une instance de " + App.Title + " tourne déjà." + CRLF + "Appuyez sur ALT+TAB pour basculer dessus."
  End
End If
Form1.Show
chargement = False
NomFich = "*.*"
End Sub

Sub SetClientPrintOrigin(PFrm As Form)
' Move the (0, 0) coordinates of the Printer object so that it
' coincides with the (0, 0) coordinates of the form's client area
' centered in the page.
Printer.ScaleLeft = -((Printer.Width - PFrm.Width) / 2)
Printer.ScaleTop = -((Printer.Height - PFrm.Height) / 2) - (2 * barhgt)
End Sub

Sub SPLITFILENAME(fn As String, pqual As String, fqual As String)
' Sépare fn (path) en pqual (drive+dir) et fqual (file+extension)
Dim LastOne As Integer
Dim test As String
Dim i As Integer
test = fn
For i = 1 To Len(test)
  If Mid$(test, i, 1) = "\" Or Mid$(test, i, 1) = ":" Then
    LastOne = i
  End If
Next
Select Case LastOne
  Case 0
    pqual = ""
    fqual = fn
  Case 1
    pqual = "\"
    fqual = Right$(fn, Len(fn) - 1)
  Case 2, 3
    If Mid$(fn, 2, 1) = ":" Then
      pqual = Left$(fn, LastOne)
    Else
      pqual = Left$(fn, LastOne - 1)
    End If
    fqual = Right$(fn, Len(fn) - LastOne)
  Case Else
    pqual = Left$(fn, LastOne - 1)
    fqual = Right$(fn, Len(fn) - LastOne)
  End Select
End Sub




