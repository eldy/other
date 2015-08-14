Attribute VB_Name = "DLLWVB1"
'****************************************************************************
' Teste d'utilisation de DLL en Visual Basic sous Windows
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
Dim WinVersion As Integer, SoundAvailable As Integer
Declare Function GetWindowsDirectory Lib "Kernel" (ByVal P$, ByVal s%) As Integer
Declare Function GetSystemDirectory Lib "Kernel" (ByVal P$, ByVal s%) As Integer
Declare Function GetWinFlags Lib "Kernel" () As Long
Global Const WF_CPU286 = &H2&
Global Const WF_CPU386 = &H4&
Global Const WF_CPU486 = &H8&
Global Const WF_STANDARD = &H10&
Global Const WF_ENHANCED = &H20&
Global Const WF_80x87 = &H400&
Declare Function GetVersion Lib "Kernel" () As Long
Declare Function GetSystemMetrics Lib "User" (ByVal n As Integer) As Integer
Declare Function GetDeviceCaps Lib "GDI" (ByVal hDC%, ByVal nIndex%) As Integer
Declare Function GlobalCompact Lib "Kernel" (ByVal flag&) As Long
Declare Function GetFreeSpace Lib "Kernel" (ByVal flag%) As Long
Declare Function GetFreeSystemResources Lib "User" (ByVal fuSysResource As Integer) As Integer
Global Const GFSR_SYSTEMRESOURCES = &H0
Global Const GFSR_GDIRESOURCES = &H1
Global Const GFSR_USERRESOURCES = &H2
Declare Function sndPlaySound Lib "MMSystem" (lpsound As Any, ByVal flag As Integer) As Integer
Declare Function waveOutGetNumDevs Lib "MMSystem" () As Integer
Declare Function GetMenu Lib "User" (ByVal hWd%) As Integer
Declare Function GetSubMenu Lib "User" (ByVal hMenu%, ByVal nPos%) As Integer
Declare Function InsertMenu Lib "User" (ByVal hMenu As Integer, ByVal nPosition As Integer, ByVal wFlags As Integer, ByVal wIDNewItem As Integer, ByVal lpNewItem As Any) As Integer
Declare Function GetSystemMenu Lib "User" (ByVal hWnd As Integer, ByVal bRevert As Integer) As Integer
Global Const MF_POPUP = &H10
Global Const MF_BYPOSITION = &H400
Global Const MF_SEPARATOR = &H800
Declare Function GetDeskTopWindow Lib "User" () As Integer
Declare Function GetDC Lib "User" (ByVal hWnd%) As Integer
Declare Sub ReleaseDC Lib "User" (ByVal hWnd%, ByVal hDC%)
Declare Function BitBlt Lib "GDI" (ByVal destDC%, ByVal X%, ByVal Y%, ByVal w%, ByVal h%, ByVal srchDC%, ByVal srcX%, ByVal srcY%, ByVal rop&) As Integer
Declare Sub SetWindowPos Lib "User" (ByVal h1%, ByVal h2%, ByVal X%, ByVal Y%, ByVal cx%, ByVal cy%, ByVal f%)
Declare Function GetProfileString Lib "Kernel" (ByVal App$, Keyname As Any, ByVal DefaultVal$, ByVal RetBuf$, ByVal Size%) As Integer
Declare Function WriteProfileString Lib "Kernel" (ByVal App$, ByVal key$, ByVal Setting$) As Integer
Declare Function GetPrivateProfileString Lib "Kernel" (ByVal lpApplicationName As String, ByVal lpKeyName As String, ByVal lpDefault As String, ByVal lpReturnedString As String, ByVal nSize As Integer, ByVal lpFileName As String) As Integer
Declare Function RemoveMenu Lib "User" (ByVal hMenu, ByVal nPosition, ByVal wFlags)
Declare Function GetFocus Lib "User" () As Integer
Declare Function SendMessage Lib "User" (ByVal a%, ByVal b%, ByVal c%, ByVal d As Any) As Long
Declare Function WinHelp Lib "User" (ByVal hWnd As Integer, ByVal lpHelpFile As String, ByVal wCommand As Integer, dwData As Any) As Integer
Declare Function SetActiveWindow Lib "User" (ByVal hDC)
Declare Function LoadLibrary Lib "Kernel" (ByVal lpLibFileName As String) As Integer
Declare Sub FreeLibrary Lib "Kernel" (ByVal hLibModule As Integer)
Declare Function TextOut Lib "GDI" (ByVal hDC As Integer, ByVal X As Integer, ByVal Y As Integer, ByVal lpString As String, ByVal nCount As Integer) As Integer

Declare Function DiracZero Lib "d:\Exemples\Dll16\MathDllP\mathdll" (ByVal i As Integer) As Integer
Declare Function Signe Lib "d:\Exemples\Dll16\MathDllP\mathdll" (ByVal i As Double) As Integer
Declare Function Puis_entiere Lib "d:\Exemples\Dll16\MathDllP\mathdll" (ByVal i As Integer, ByVal j As Integer) As Long

Sub CENTRE(Feuille As Form)
Feuille.Top = (Screen.Height - Feuille.Height) / 2
Feuille.Left = (Screen.Width - Feuille.Width) / 2
End Sub

Function DeviceColors(hDC As Integer) As Long
Const PLANES = 14
Const BITSPIXEL = 12
DeviceColors = GetDeviceCaps(hDC, PLANES) * 2 ^ GetDeviceCaps(hDC, BITSPIXEL)
End Function

Function DosVersion()
Dim Ver As Long, DosVer As Long
Ver = GetVersion()
DosVer = Ver \ &H10000
DosVersion = Format((DosVer \ 256) + ((DosVer Mod 256) / 100), "Fixed")
End Function

Function GetSysIni(section, key)
Dim retVal As String, AppName As String, worked As Integer
retVal = String$(255, 0)
worked = GetPrivateProfileString(section, key, "", retVal, Len(retVal), "System.ini")
If worked = 0 Then
  GetSysIni = "inconnu"
Else
  GetSysIni = Left(retVal, worked)
End If
End Function

Function GetWinIni(section, key)
Dim retVal As String, AppName As String, worked As Integer
retVal = String$(255, 0)
worked = GetProfileString(section, key, "", retVal, Len(retVal))
If worked = 0 Then
  GetWinIni = "inconnu"
Else
  GetWinIni = Left(retVal, worked)
End If
End Function

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

Function SystemDirectory() As String
Dim WinPath As String
WinPath = String(145, Chr(0))
SystemDirectory = Left(WinPath, GetSystemDirectory(WinPath, Len(WinPath)))
End Function

Function WindowsDirectory() As String
Dim WinPath As String
WinPath = String(145, Chr(0))
WindowsDirectory = Left(WinPath, GetWindowsDirectory(WinPath, Len(WinPath)))
End Function

Function WindowsVersion()
Dim Ver As Long, WinVer As Long
Ver = GetVersion()
WinVer = Ver And &HFFFF&
WindowsVersion = Format((WinVer Mod 256) + ((WinVer \ 256) / 100), "Fixed")
End Function

