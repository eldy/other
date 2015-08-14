VERSION 4.00
Begin VB.Form Aide 
   Appearance      =   0  'Flat
   BackColor       =   &H00FFFFFF&
   Caption         =   "A  propos...  "
   ClientHeight    =   5808
   ClientLeft      =   1764
   ClientTop       =   2448
   ClientWidth     =   8016
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   DrawMode        =   1  'Blackness
   BeginProperty Font 
      name            =   "MS Serif"
      charset         =   0
      weight          =   700
      size            =   7.8
      underline       =   0   'False
      italic          =   0   'False
      strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00000000&
   Height          =   6180
   Left            =   1716
   LinkMode        =   1  'Source
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5808
   ScaleWidth      =   8016
   Top             =   2124
   Width           =   8112
   Begin VB.Timer Minuterie1 
      Interval        =   60000
      Left            =   7320
      Top             =   120
   End
   Begin VB.PictureBox Image1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      DrawMode        =   2  'Blackness
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   495
      Left            =   3720
      Picture         =   "AIDE.frx":0000
      ScaleHeight     =   492
      ScaleWidth      =   492
      TabIndex        =   4
      Top             =   780
      Width           =   495
   End
   Begin VB.CommandButton Command1 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      Cancel          =   -1  'True
      Caption         =   "&Ok"
      Default         =   -1  'True
      BeginProperty Font 
         name            =   "System"
         charset         =   0
         weight          =   700
         size            =   9.6
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      Height          =   432
      Left            =   5820
      TabIndex        =   0
      Top             =   4920
      Width           =   1392
   End
   Begin VB.Label Etiquette4 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "DESTAILLEUR LAURENT"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Index           =   0
      Left            =   480
      TabIndex        =   8
      Top             =   4800
      Width           =   3135
   End
   Begin VB.Label Etiquette5 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "TEL: 20 91 26 50"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   3480
      TabIndex        =   9
      Top             =   5040
      Width           =   1755
   End
   Begin VB.Label Etiquette4 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "121  RUE DE LA CRETE,"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Index           =   1
      Left            =   480
      TabIndex        =   14
      Top             =   5040
      Width           =   3135
   End
   Begin VB.Label Etiquette4 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "59650 VILLENEUVE D'ASCQ."
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Index           =   2
      Left            =   480
      TabIndex        =   13
      Top             =   5280
      Width           =   3135
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   $"AIDE.frx":030A
      BeginProperty Font 
         name            =   "Arial"
         charset         =   0
         weight          =   400
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   435
      Left            =   480
      TabIndex        =   12
      Top             =   1680
      Width           =   7035
   End
   Begin VB.Line Ligne4 
      BorderColor     =   &H00808080&
      BorderWidth     =   2
      X1              =   240
      X2              =   7740
      Y1              =   5580
      Y2              =   5580
   End
   Begin VB.Line Ligne3 
      BorderColor     =   &H00808080&
      BorderWidth     =   2
      X1              =   7740
      X2              =   7740
      Y1              =   3480
      Y2              =   5580
   End
   Begin VB.Line Ligne2 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      DrawMode        =   1  'Blackness
      X1              =   240
      X2              =   240
      Y1              =   3480
      Y2              =   5580
   End
   Begin VB.Line Ligne1 
      BorderColor     =   &H00000000&
      BorderWidth     =   2
      DrawMode        =   1  'Blackness
      X1              =   240
      X2              =   7740
      Y1              =   3480
      Y2              =   3480
   End
   Begin VB.Label Etiquette8 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "A cette fin (ou simplement pour entretenir une correspondance),  l'auteur est à votre disposition:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   400
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   192
      Left            =   480
      TabIndex        =   6
      Top             =   4500
      Width           =   7092
   End
   Begin VB.Label Etiquette7 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "-Des fichiers Sources (Visual Basic 3.0), d'une aide technique, etc..."
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   400
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   192
      Left            =   480
      TabIndex        =   11
      Top             =   4260
      Width           =   7092
   End
   Begin VB.Label Etiquette6 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "-Des versions suivantes d'Universal Domotic (Immunités aux pannes de courant, plus de fonctions)."
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   400
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   252
      Left            =   480
      TabIndex        =   10
      Top             =   4080
      Width           =   7152
   End
   Begin VB.Label Etiquette3 
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   $"AIDE.frx":03AF
      Enabled         =   0   'False
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00000000&
      Height          =   432
      Left            =   480
      TabIndex        =   7
      Top             =   3660
      Width           =   7092
   End
   Begin VB.Label Etiquette1 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   $"AIDE.frx":0443
      Enabled         =   0   'False
      BeginProperty Font 
         name            =   "Arial"
         charset         =   0
         weight          =   400
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   1275
      Left            =   480
      TabIndex        =   5
      Top             =   2160
      Width           =   6975
   End
   Begin VB.Label Label2 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Universal Domotic"
      BeginProperty Font 
         name            =   "Times New Roman"
         charset         =   0
         weight          =   700
         size            =   13.2
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   300
      Left            =   2880
      TabIndex        =   1
      Top             =   120
      Width           =   2220
   End
   Begin VB.Label Label3 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Version 1.00"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   3300
      TabIndex        =   2
      Top             =   420
      Width           =   1455
   End
   Begin VB.Label Label4 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "(c) 1997"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   7.8
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   3000
      TabIndex        =   3
      Top             =   1260
      Width           =   1935
   End
End
Attribute VB_Name = "Aide"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

Private Sub Command1_Click()
Me.Hide
End Sub

Private Sub Form_Load()
CENTRE About
End Sub

Private Sub Minuterie1_Timer()
Unload Me
End Sub

