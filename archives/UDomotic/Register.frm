VERSION 4.00
Begin VB.Form Register 
   Appearance      =   0  'Flat
   BackColor       =   &H00C0C0C0&
   Caption         =   "Don't forget to register !"
   ClientHeight    =   6108
   ClientLeft      =   4332
   ClientTop       =   3108
   ClientWidth     =   5712
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
      Name            =   "System"
      Size            =   9.6
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Height          =   6432
   Icon            =   "REGISTER.frx":0000
   Left            =   4284
   LinkMode        =   1  'Source
   LinkTopic       =   "Form2"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6108
   ScaleWidth      =   5712
   Top             =   2832
   Width           =   5808
   Begin VB.Frame Frame1 
      Caption         =   "About the Author"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1164
      Left            =   480
      TabIndex        =   9
      Top             =   3840
      Width           =   4716
      Begin VB.Label Label1 
         Caption         =   "Paris - 1998"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "Arial"
            Size            =   7.8
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   204
         Index           =   1
         Left            =   192
         TabIndex        =   15
         Top             =   492
         Width           =   2316
      End
      Begin VB.Label Label1 
         Caption         =   "Laurent Destailleur"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "Arial"
            Size            =   7.8
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   204
         Index           =   0
         Left            =   192
         TabIndex        =   14
         Top             =   288
         Width           =   2316
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "ld.home.ml.org"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   7.8
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   204
         Index           =   3
         Left            =   2688
         TabIndex        =   13
         Top             =   864
         Width           =   2316
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "Web:"
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
         Height          =   204
         Index           =   2
         Left            =   2688
         TabIndex        =   12
         Top             =   672
         Width           =   2316
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "ld@writeme.com"
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   7.8
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   204
         Index           =   1
         Left            =   2688
         TabIndex        =   11
         Top             =   480
         Width           =   2316
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "EMail:"
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
         Height          =   204
         Index           =   0
         Left            =   2688
         TabIndex        =   10
         Top             =   288
         Width           =   2316
      End
   End
   Begin VB.TextBox Text1 
      BackColor       =   &H00FFFFFF&
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
      Height          =   876
      Index           =   0
      Left            =   1632
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      TabIndex        =   6
      Text            =   "REGISTER.frx":030A
      Top             =   2592
      Width           =   2508
   End
   Begin VB.CommandButton PrintForm 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "&Print the registration form"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   420
      Left            =   480
      TabIndex        =   5
      Top             =   5376
      Width           =   2316
   End
   Begin VB.PictureBox Image1 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      DrawMode        =   2  'Blackness
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
      Height          =   495
      Left            =   2592
      Picture         =   "REGISTER.frx":0359
      ScaleHeight     =   492
      ScaleWidth      =   492
      TabIndex        =   4
      Top             =   672
      Width           =   495
   End
   Begin VB.CommandButton Cmd_OK 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "&Ok"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Arial"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   420
      Left            =   3000
      TabIndex        =   2
      Top             =   5376
      Width           =   2220
   End
   Begin VB.Label Etiquette8 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Unregistered Version"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.6
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   300
      Index           =   1
      Left            =   192
      TabIndex        =   8
      Top             =   1440
      Width           =   5388
   End
   Begin VB.Label Etiquette8 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Send  $10US  or  50FF  to the following address:"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   9.6
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FF0000&
      Height          =   300
      Index           =   0
      Left            =   384
      TabIndex        =   7
      Top             =   2304
      Width           =   4908
   End
   Begin VB.Label Etiquette3 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00FFFFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "To register and receive the last full version of Universal Domotic (with VB4 sources):"
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
      Height          =   396
      Left            =   960
      TabIndex        =   3
      Top             =   1824
      Width           =   3864
   End
   Begin VB.Label Lbl_IconWorks 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Universal Domotic"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Times New Roman"
         Size            =   13.2
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   336
      Left            =   480
      TabIndex        =   0
      Top             =   120
      Width           =   4728
   End
   Begin VB.Label Lbl_Version 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "Version 1.0"
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
      Height          =   240
      Left            =   1728
      TabIndex        =   1
      Top             =   420
      Width           =   2220
   End
End
Attribute VB_Name = "Register"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

Private Sub Cmd_OK_Click()
Unload Me
Domo.Show
End Sub

Private Sub Form_Load()
CENTRE Me

#If Win16 Then
    Lbl_Version.Caption = "Version " + Version + " (16bits)"
#Else
    Lbl_Version.Caption = "Version " + Version + " (32bits)"
#End If
End Sub

