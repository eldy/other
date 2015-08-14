VERSION 4.00
Begin VB.Form Form1 
   Caption         =   "Test DDE depuis VB"
   ClientHeight    =   3612
   ClientLeft      =   2112
   ClientTop       =   2304
   ClientWidth     =   4992
   Height          =   3996
   Left            =   2064
   LinkTopic       =   "Form1"
   ScaleHeight     =   3612
   ScaleWidth      =   4992
   Top             =   1968
   Visible         =   0   'False
   Width           =   5088
   Begin VB.OptionButton Option1 
      Alignment       =   1  'Right Justify
      Caption         =   "DLL Windows"
      Height          =   252
      Index           =   1
      Left            =   1560
      TabIndex        =   14
      Top             =   480
      Width           =   1692
   End
   Begin VB.OptionButton Option1 
      Alignment       =   1  'Right Justify
      Caption         =   "Visual Basic"
      Height          =   252
      Index           =   0
      Left            =   1560
      TabIndex        =   13
      Top             =   240
      Value           =   -1  'True
      Width           =   1692
   End
   Begin VB.TextBox ret 
      Height          =   300
      Left            =   1344
      TabIndex        =   6
      Top             =   3072
      Width           =   588
   End
   Begin VB.TextBox Item 
      Height          =   300
      Left            =   1344
      TabIndex        =   2
      Text            =   "SysItems"
      Top             =   1584
      Width           =   2172
   End
   Begin VB.TextBox Topic 
      Height          =   300
      Left            =   1344
      TabIndex        =   1
      Text            =   "System"
      Top             =   1200
      Width           =   2172
   End
   Begin VB.TextBox Appli 
      Height          =   300
      Left            =   1344
      TabIndex        =   0
      Text            =   "WinWord"
      Top             =   816
      Width           =   2172
   End
   Begin VB.TextBox txtData 
      Height          =   288
      Left            =   1344
      TabIndex        =   5
      Top             =   2688
      Width           =   2148
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Send DDE Command"
      Height          =   732
      Left            =   3720
      TabIndex        =   4
      Top             =   1200
      Width           =   1092
   End
   Begin VB.TextBox Commande 
      Height          =   300
      Left            =   1344
      TabIndex        =   3
      Text            =   "[FileOpen(""essai.doc"")]"
      Top             =   1968
      Width           =   2148
   End
   Begin VB.Line Line1 
      X1              =   120
      X2              =   4800
      Y1              =   2520
      Y2              =   2520
   End
   Begin VB.Label Label2 
      Caption         =   "Mode de test"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   372
      Left            =   240
      TabIndex        =   15
      Top             =   240
      Width           =   732
   End
   Begin VB.Label Label1 
      Caption         =   "Code retour"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   5
      Left            =   240
      TabIndex        =   12
      Top             =   3120
      Width           =   1068
   End
   Begin VB.Label Label1 
      Caption         =   "Chp pour lien"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   4
      Left            =   240
      TabIndex        =   11
      Top             =   2784
      Width           =   1068
   End
   Begin VB.Label Label1 
      Caption         =   "Commande"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   3
      Left            =   240
      TabIndex        =   10
      Top             =   2064
      Width           =   1020
   End
   Begin VB.Label Label1 
      Caption         =   "Item"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   2
      Left            =   240
      TabIndex        =   9
      Top             =   1680
      Width           =   1068
   End
   Begin VB.Label Label1 
      Caption         =   "Topic"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   1
      Left            =   240
      TabIndex        =   8
      Top             =   1296
      Width           =   1068
   End
   Begin VB.Label Label1 
      Caption         =   "Appli"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   204
      Index           =   0
      Left            =   240
      TabIndex        =   7
      Top             =   912
      Width           =   1068
   End
End
Attribute VB_Name = "Form1"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit
' Erreurs à l'exécution
Const errNoAppResponded = 282
Const errDDERefused = 285

Const DDEML_NO_ERROR = 0
Const APPCMD_CLIENTONLY = 10
Const APPCLASS_STANDARD = 0
Const CP_WINANSI = 1004


Function essai()

End Function


Private Sub Command1_Click()
SendDDECommand appli.Text, topic.Text, item.Text, Commande.Text
End Sub

Public Sub Main()
Form1.Show
End Sub



Sub Disconnect(Ctl As Control)
Dim tempTimeOutVal
On Error Resume Next
' Le fait de déconnecter à l'aide de ProgMan entraîne une erreur de temporisation : ignorez-la
' et continuez.
    tempTimeOutVal = Ctl.LinkTimeout
    Ctl.LinkTimeout = 1
    Ctl.LinkMode = vbLinkNone
    Ctl.LinkTimeout = tempTimeOutVal
End Sub


Function StartApp(appname As String) As Integer
On Error Resume Next
    StartApp = (Shell(appname, 4) > 31)
    If err Then
        StartApp = 1
    Else
        StartApp = 0
    End If
End Function


Function MakeConnection(appli As String, topic As String, item As String, clientLinkMode As Integer) As Integer
Dim ConnectTxt As Integer
    ConnectTxt = CreateLink(txtData, appli, topic, item, clientLinkMode)
    If ConnectTxt = errNoAppResponded Then
        MakeConnection = errNoAppResponded
    ElseIf ConnectTxt = 0 Then
        MakeConnection = 0
    End If
End Function

Private Function CreateLink(Ctl As Control, appli As String, topic As String, item As String, LinkType As Integer) As Integer
On Error Resume Next
    Ctl.LinkMode = vbLinkNone
    Ctl.LinkTopic = appli & "|" & topic
    Ctl.LinkItem = item
    Ctl.LinkMode = LinkType
    CreateLink = err
    If err = 0 And LinkType <> vbLinkAutomatic Then
        Ctl.LinkRequest
    End If
End Function

Public Function SendDDECommand(appli As String, topic As String, item As String, S As String) As Integer
'********************************************************************
' Entrée:   Appli       Ex: Word
'           Topic       Ex: System
'           Item        Ex: SysItems
'           Command     Ex: s="[FileOpen("essai.doc")]"
'
' Retour:   0   Ok
'           1   Appli non dans le Path
'           2   Impossible d'ouvrir la connection
'           3   Arguments invalides
'           4   Autre
'********************************************************************
Dim ChanNum As Integer
Dim Groups As String
Dim Exe As String
Dim retour As Integer
Dim hs1, hs2, hs3, hs4 As Long
Dim cc As CONVCONTEXT
Dim hConv
Dim l As Long

If appli = "" Or topic = "" Or item = "" Or S = "" Then
    SendDDECommand = 3
    End
End If

If Option1(0).Value Then
    'Ouvre connection en mode 1=auto, 2=manuel, 3=sur demande
    Select Case MakeConnection(appli, topic, item, 2)
        Case 0
            retour = 0
        Case errNoAppResponded 'Appli non lancée
            If StartApp(appli) = 0 Then
                Select Case MakeConnection(appli, topic, item, 2)
                   Case 0
                        retour = 0
                   Case errNoAppResponded
                        retour = 2
                End Select
            Else
                retour = 1
            End If
    End Select
    ' Si connection ok, execute commande
    If retour = 0 Then
        On Error Resume Next
        txtData.LinkExecute S
        Disconnect txtData
    End If
Else
    S = Space(1024)
    ' Begin a DDE conversation with Program Manager.
    ChanNum = DdeInitialize(hInst, 0, APPCLASS_STANDARD, 0)
    If ChanNum <> DDEML_NO_ERROR Then
        retour = 2
    Else
        hs1 = DdeCreateStringHandle(hInst, "Progman", CP_WINANSI)
        hs2 = DdeCreateStringHandle(hInst, appli, CP_WINANSI)
        hs3 = DdeCreateStringHandle(hInst, topic, CP_WINANSI)
        hs4 = DdeCreateStringHandle(hInst, item, CP_WINANSI)
        If (hs1 = 0) Or (hs2 = 0) Or (hs3 = 0) Or (hs4 = 0) Then
            retour = 4
        Else
            hConv = DdeConnect(hInst, hs2, hs3, cc)
            If (hConv = 0) Then
                If StartApp(appli) = 0 Then
                    hConv = DdeConnect(hInst, hs2, hs3, cc)
                    If hConv = 0 Then
                        retour = 2
                    Else
                        retour = 0
                    End If
                Else
                    retour = 1
                End If
            Else
                retour = 0
            End If
            ' Si connection ok, execute commande
            If retour = 0 Then
                l = DdePostAdvise(hInst, hs3, hs4)
                l = DdeDisconnect(hConv)
            End If
            l = DdeFreeStringHandle(hInst, hs1)
            l = DdeFreeStringHandle(hInst, hs2)
            l = DdeFreeStringHandle(hInst, hs3)
            l = DdeFreeStringHandle(hInst, hs4)
        End If
        l = DdeUninitialize(hInst)
    End If
End If

ret.Text = str$(retour)
SendDDECommand = retour
End Function


Private Sub Form_Load()
Dim a As String, t As String, i As String, C As String, S As String
Dim k As Integer

S = Trim$(Command)
If S <> "" Then
    Form1.Visible = False
    k = InStr(S, " ")
    If k > 0 Then a = Left$(S, k - 1)
    S = Right$(S, Len(S) - k)
    k = InStr(S, " ")
    If k > 0 Then t = Left$(S, k - 1)
    S = Right$(S, Len(S) - k)
    k = InStr(S, " ")
    If k > 0 Then i = Left$(S, k - 1)
    C = Right$(S, Len(S) - k)
    SendDDECommand a, t, i, C
    End
Else
    Form1.Visible = True
End If

End Sub


Private Sub Option1_Click(Index As Integer)
txtData.Text = ""
ret.Text = ""
End Sub
