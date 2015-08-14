VERSION 4.00
Begin VB.Form Conf 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   Caption         =   "Universal Domotic      "
   ClientHeight    =   5616
   ClientLeft      =   1980
   ClientTop       =   4836
   ClientWidth     =   8544
   BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
      Name            =   "MS Sans Serif"
      Size            =   7.8
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Height          =   5988
   Icon            =   "CONFIGUR.frx":0000
   Left            =   1932
   LinkTopic       =   "Feuille3"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5616
   ScaleWidth      =   8544
   Top             =   4512
   Width           =   8640
   Begin VB.Frame Frame1 
      Caption         =   "Ports adresses"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1260
      Left            =   4416
      TabIndex        =   18
      Top             =   1344
      Width           =   3660
      Begin VB.ComboBox ListeModifiable1 
         ForeColor       =   &H00000000&
         Height          =   288
         Index           =   3
         Left            =   2952
         Style           =   2  'Dropdown List
         TabIndex        =   24
         Top             =   792
         Width           =   492
      End
      Begin VB.ComboBox ListeModifiable1 
         ForeColor       =   &H00000000&
         Height          =   288
         Index           =   2
         Left            =   2952
         Style           =   2  'Dropdown List
         TabIndex        =   23
         Top             =   492
         Width           =   492
      End
      Begin VB.ComboBox ListeModifiable1 
         ForeColor       =   &H00000000&
         Height          =   288
         Index           =   1
         Left            =   2952
         Style           =   2  'Dropdown List
         TabIndex        =   22
         Top             =   192
         Width           =   492
      End
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   1
         Left            =   1992
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   21
         Top             =   204
         Width           =   435
      End
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   2
         Left            =   1992
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   20
         Top             =   492
         Width           =   435
      End
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         ForeColor       =   &H00000000&
         Height          =   285
         Index           =   3
         Left            =   1992
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   19
         Top             =   792
         Width           =   435
      End
      Begin VB.Label Etiquette3 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Adresse du Port A"
         ForeColor       =   &H00000000&
         Height          =   252
         Left            =   192
         TabIndex        =   30
         Top             =   252
         Width           =   1812
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Adresse du Port B"
         ForeColor       =   &H00000000&
         Height          =   252
         Left            =   192
         TabIndex        =   29
         Top             =   552
         Width           =   1812
      End
      Begin VB.Label Etiquette5 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Adresse du Port C"
         ForeColor       =   &H00000000&
         Height          =   252
         Left            =   192
         TabIndex        =   28
         Top             =   852
         Width           =   1812
      End
      Begin VB.Label Etiquette12 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H80000008&
         Height          =   252
         Left            =   2472
         TabIndex        =   27
         Top             =   252
         Width           =   132
      End
      Begin VB.Label Etiquette13 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H80000008&
         Height          =   192
         Left            =   2472
         TabIndex        =   26
         Top             =   552
         Width           =   132
      End
      Begin VB.Label Etiquette14 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H80000008&
         Height          =   192
         Left            =   2472
         TabIndex        =   25
         Top             =   852
         Width           =   132
      End
   End
   Begin VB.OptionButton Option1 
      Caption         =   "LPT2"
      Height          =   204
      Index           =   1
      Left            =   480
      TabIndex        =   16
      Top             =   2304
      Width           =   3468
   End
   Begin VB.OptionButton Option1 
      Caption         =   "LPT1"
      Height          =   204
      Index           =   0
      Left            =   480
      TabIndex        =   15
      Top             =   2016
      Width           =   3372
   End
   Begin VB.OptionButton Option1 
      Caption         =   "Perso"
      Height          =   204
      Index           =   2
      Left            =   480
      TabIndex        =   14
      Top             =   1536
      Value           =   -1  'True
      Width           =   1452
   End
   Begin VB.PictureBox Image3 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   435
      Left            =   4020
      Picture         =   "CONFIGUR.frx":030A
      ScaleHeight     =   432
      ScaleWidth      =   492
      TabIndex        =   10
      Top             =   4920
      Width           =   495
   End
   Begin VB.TextBox octetini 
      Alignment       =   1  'Right Justify
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   288
      Left            =   2990
      MaxLength       =   2
      TabIndex        =   0
      Top             =   4199
      Width           =   432
   End
   Begin VB.TextBox adresses 
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H00000000&
      Height          =   285
      Index           =   0
      Left            =   6000
      MaxLength       =   3
      TabIndex        =   1
      Top             =   4200
      Width           =   435
   End
   Begin VB.CommandButton Commande2 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "&Cancel"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.6
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   432
      Left            =   960
      TabIndex        =   2
      Top             =   4920
      Width           =   2232
   End
   Begin VB.CommandButton Commande1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "&Ok"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.6
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   432
      Left            =   5184
      TabIndex        =   3
      Top             =   4920
      Width           =   2292
   End
   Begin VB.Label Etiquette11 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "PORTS"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   192
      Index           =   1
      Left            =   288
      TabIndex        =   17
      Top             =   288
      Width           =   7884
   End
   Begin VB.Label Etiquette19 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "h"
      ForeColor       =   &H00000000&
      Height          =   195
      Index           =   2
      Left            =   6474
      TabIndex        =   13
      Top             =   4251
      Width           =   364
   End
   Begin VB.Label Etiquette19 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "h  sur le Port d'initialisation en"
      ForeColor       =   &H00000000&
      Height          =   195
      Index           =   1
      Left            =   3471
      TabIndex        =   12
      Top             =   4251
      Width           =   2431
   End
   Begin VB.Line Ligne8 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      X1              =   240
      X2              =   240
      Y1              =   3000
      Y2              =   4620
   End
   Begin VB.Line Ligne7 
      BorderColor     =   &H00FFFFFF&
      BorderWidth     =   2
      X1              =   240
      X2              =   8280
      Y1              =   4620
      Y2              =   4620
   End
   Begin VB.Line Ligne6 
      BorderColor     =   &H00FFFFFF&
      BorderWidth     =   2
      X1              =   8280
      X2              =   8280
      Y1              =   4620
      Y2              =   3000
   End
   Begin VB.Line Ligne5 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      X1              =   8280
      X2              =   240
      Y1              =   3000
      Y2              =   3000
   End
   Begin VB.Line Ligne1 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      X1              =   240
      X2              =   240
      Y1              =   240
      Y2              =   2784
   End
   Begin VB.Line Ligne2 
      BorderColor     =   &H00FFFFFF&
      BorderWidth     =   2
      X1              =   240
      X2              =   8280
      Y1              =   2784
      Y2              =   2784
   End
   Begin VB.Line Ligne3 
      BorderColor     =   &H00FFFFFF&
      BorderWidth     =   2
      X1              =   8280
      X2              =   8280
      Y1              =   2784
      Y2              =   240
   End
   Begin VB.Line Ligne4 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      X1              =   8280
      X2              =   240
      Y1              =   240
      Y2              =   240
   End
   Begin VB.Label Etiquette8 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Adresses personnalisées pour carte d'extension:"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   192
      Left            =   480
      TabIndex        =   7
      Top             =   1260
      Width           =   3552
   End
   Begin VB.Label Etiquette7 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Ou adresses utilisées par le port  LPT1,  LPT2:"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   -1  'True
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   192
      Left            =   480
      TabIndex        =   11
      Top             =   1740
      Width           =   3552
   End
   Begin VB.Label Etiquette11 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "INITIALISATION"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   216
      Index           =   0
      Left            =   288
      TabIndex        =   9
      Top             =   3060
      Width           =   7884
   End
   Begin VB.Label Etiquette19 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Envoi de l'Octet d'initialisation"
      ForeColor       =   &H00000000&
      Height          =   195
      Index           =   0
      Left            =   390
      TabIndex        =   5
      Top             =   4264
      Width           =   2548
   End
   Begin VB.Label Etiquette9 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   $"CONFIGUR.frx":0614
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   793
      Left            =   390
      TabIndex        =   6
      Top             =   3380
      Width           =   7761
   End
   Begin VB.Label Etiquette6 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "1 - Choisissez la nature des adresses des ports à lire/écrire par Universal Domotic:"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   492
      Left            =   480
      TabIndex        =   4
      Top             =   660
      Width           =   3432
   End
   Begin VB.Label Etiquette1 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   $"CONFIGUR.frx":0743
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   612
      Left            =   4440
      TabIndex        =   8
      Top             =   660
      Width           =   3672
   End
End
Attribute VB_Name = "Conf"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

Private Function ADRESSE_VALIDE(i As Integer) As Single
If (i < &H378 Or i > &H37A) And (i < &H278 Or i > &H27A) And (i < &H300 Or i > &H31F) Then
  Message = "Adresse non valide !" + CRLF + "Choisissez en une autre..."
  MsgBox Message, 48, app.Title
  ADRESSE_VALIDE = False
  End If
ADRESSE_VALIDE = True
End Function

Private Sub adresses_GotFocus(Index As Integer)
saves = Adresses(Index).Text
End Sub

Private Sub adresses_KeyPress(Index As Integer, KeyAscii As Integer)
If (KeyAscii = 13) Then adresses_lostfocus (Index)
End Sub

Private Sub adresses_lostfocus(Index As Integer)
If (Index = 0) Then Exit Sub
If ADRESSE_VALIDE(HEX_DEC(Trim$(Adresses(Index).Text))) Then
Else
  Adresses(Index).Text = saves
End If
End Sub

Private Sub Commande1_Click()
Dim i As Integer
s$ = Trim$(Adresses(0).Text)
Adresse(0) = HEX_DEC(s$)
s$ = octetini.Text
octet(0) = HEX_DEC(s$)
'Initialisation de la carte PIA
If Adresse(0) <> 0 Then
  Form1.etiquette19.Caption = "Send the initializing Byte " + Hex$(octet(0)) + " h to port " + Hex$(Adresse(0)) + " h"
  OutByte (Adresse(0)), octet(0)
Else
  Form1.etiquette19.Caption = "No initialisation."
  End If
'Valide les ports
For i = 1 To 3
  s$ = Adresses(i).Text
  Adresse(i) = HEX_DEC(s$)
  If ListeModifiable1(i).ListIndex = 0 Then
    sens(i) = False
    Form1.io(i).Text = "I"
  Else
    sens(i) = True
    Form1.io(i).Text = "O"
    End If
  Form1.Adresses(i).Text = s$
  Next i
'Assigne les noms de bits si ports choisi = ports parallèles
If (option1(0).Value) Or (option1(1).Value) Then
  NomBit(1, 0) = "DATA 0"
  NomBit(1, 1) = "DATA 1"
  NomBit(1, 2) = "DATA 2"
  NomBit(1, 3) = "DATA 3"
  NomBit(1, 4) = "DATA 4"
  NomBit(1, 5) = "DATA 5"
  NomBit(1, 6) = "DATA 6"
  NomBit(1, 7) = "DATA 7"
  NomBit(2, 0) = "NC"
  NomBit(2, 1) = "NC"
  NomBit(2, 2) = "NC"
  NomBit(2, 3) = "!ERROR"
  NomBit(2, 4) = "ON LINE"
  NomBit(2, 5) = "PAPER ERROR"
  NomBit(2, 6) = "!ACK"
  NomBit(2, 7) = "!BUSY"
  NomBit(3, 0) = "!STROBE"
  NomBit(3, 1) = "AUTO FEED"
  NomBit(3, 2) = "!INIT"
  NomBit(3, 3) = "SELECT ON LINE"
  NomBit(3, 4) = "IRQ ENABLE"
  NomBit(3, 5) = "NC"
  NomBit(3, 6) = "NC"
  NomBit(3, 7) = "NC"
Else
    For i = 1 To 3
        For j = 0 To 7
            NomBit(i, j) = "NC"
        Next
    Next
End If
'Affichage nouveau nom bit
Form1.BitName.Text = NomBit(Port, bit)
If sens(Port) Then
  Form1.Commande1.Enabled = True
Else
  Form1.Commande1.Enabled = False
End If
'Affichage nouveau nom fichier config
NomConfig = "New.cfg"
Form1.SettingFile.Text = NomConfig
ModifConfig = True
Me.Hide
End Sub

Private Sub Commande2_Click()
Unload Me
End Sub

Private Sub Form_Activate()
Option1_Click (2)
option1(2).Value = True
End Sub

Private Sub Form_Load()
CENTRE Conf
'Appel uniquement si aucun programme chargé
'Initialisation avec valeurs de form1
If Adresse(0) <> 0 Then
  Feuille3.Adresses(0).Text = Hex$(Adresse(0))
  octetini.Text = Hex$(octet(0))
  End If
For i = 1 To 3
  ListeModifiable1(i).AddItem "I"
  ListeModifiable1(i).AddItem "O"
Next i
End Sub

Private Sub ListeModifiable1_LostFocus(Index As Integer)
ListeModifiable1(Index).Refresh
End Sub

Private Sub octetini_GotFocus()
saves = octetini.Text
End Sub

Private Sub Option1_Click(Index As Integer)
Select Case Index
   Case 0:
     Adresses(1).Text = "378"
     Adresses(2).Text = "379"
     Adresses(3).Text = "37A"
     ListeModifiable1(1).ListIndex = 1
     ListeModifiable1(2).ListIndex = 0
     ListeModifiable1(3).ListIndex = 1
   Case 1:
     Adresses(1).Text = "278"
     Adresses(2).Text = "279"
     Adresses(3).Text = "27A"
     ListeModifiable1(1).ListIndex = 1
     ListeModifiable1(2).ListIndex = 0
     ListeModifiable1(3).ListIndex = 1
   Case 2:
     Adresses(1).Text = "300"
     Adresses(2).Text = "301"
     Adresses(3).Text = "302"
     ListeModifiable1(1).ListIndex = 1
     ListeModifiable1(2).ListIndex = 1
     ListeModifiable1(3).ListIndex = 1
End Select
If Index = 0 Or Index = 1 Then
  Etiquette9.ForeColor = &H808080
  etiquette11(0).ForeColor = &H808080
  For i = 0 To 2
    etiquette19(i).ForeColor = &H808080
  Next i
  octetini.Enabled = False
  Adresses(0).Enabled = False
Else
  Etiquette9.ForeColor = 0
  etiquette11(0).ForeColor = 0
  For i = 0 To 2
    etiquette19(i).ForeColor = 0
  Next i
  octetini.Enabled = True
  Adresses(0).Enabled = True
End If
End Sub

Private Sub Option2_Click()
End Sub


