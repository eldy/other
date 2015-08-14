VERSION 4.00
Begin VB.Form Domo 
   Caption         =   "Universal Domotic"
   ClientHeight    =   8172
   ClientLeft      =   1824
   ClientTop       =   1452
   ClientWidth     =   9540
   DrawMode        =   1  'Blackness
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
   Height          =   8724
   Icon            =   "DOMOTIC.frx":0000
   Left            =   1776
   LinkTopic       =   "Feuille1"
   ScaleHeight     =   8172
   ScaleWidth      =   9540
   Top             =   948
   Width           =   9636
   Begin VB.PictureBox Image3 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      ForeColor       =   &H00000000&
      Height          =   495
      Left            =   7728
      Picture         =   "DOMOTIC.frx":030A
      ScaleHeight     =   492
      ScaleWidth      =   552
      TabIndex        =   1
      Top             =   3612
      Width           =   555
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      DrawMode        =   3  'Not Merge Pen
      Height          =   372
      Index           =   3
      Left            =   1728
      Picture         =   "DOMOTIC.frx":0614
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   107
      Top             =   60
      Width           =   396
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      DrawMode        =   3  'Not Merge Pen
      Height          =   372
      Index           =   0
      Left            =   180
      Picture         =   "DOMOTIC.frx":091E
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   106
      Top             =   60
      Width           =   396
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   372
      Index           =   5
      Left            =   2688
      Picture         =   "DOMOTIC.frx":0C28
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   104
      Top             =   60
      Width           =   396
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   372
      Index           =   4
      Left            =   2220
      Picture         =   "DOMOTIC.frx":0F32
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   103
      Top             =   60
      Width           =   396
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      Height          =   372
      Index           =   2
      Left            =   1116
      Picture         =   "DOMOTIC.frx":123C
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   102
      Top             =   60
      Width           =   396
   End
   Begin VB.PictureBox Picture1 
      BorderStyle     =   0  'None
      DrawMode        =   3  'Not Merge Pen
      Height          =   372
      Index           =   1
      Left            =   660
      Picture         =   "DOMOTIC.frx":1546
      ScaleHeight     =   372
      ScaleWidth      =   396
      TabIndex        =   101
      Top             =   60
      Width           =   396
   End
   Begin VB.Frame Frame2 
      Caption         =   "Scheduler"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3252
      Left            =   120
      TabIndex        =   45
      Top             =   4536
      Width           =   9252
      Begin VB.TextBox Text1 
         Height          =   285
         Index           =   0
         Left            =   300
         MaxLength       =   3
         TabIndex        =   89
         Text            =   "Tex"
         Top             =   1608
         Width           =   435
      End
      Begin VB.TextBox Text1 
         Height          =   285
         Index           =   1
         Left            =   300
         MaxLength       =   3
         TabIndex        =   88
         Text            =   "Tex"
         Top             =   1968
         Width           =   435
      End
      Begin VB.TextBox Text1 
         Height          =   285
         Index           =   2
         Left            =   300
         MaxLength       =   3
         TabIndex        =   87
         Text            =   "Tex"
         Top             =   2328
         Width           =   435
      End
      Begin VB.TextBox Text1 
         Height          =   285
         Index           =   3
         Left            =   300
         MaxLength       =   3
         TabIndex        =   86
         Text            =   "Tex"
         Top             =   2688
         Width           =   435
      End
      Begin VB.ComboBox Combo1 
         Height          =   288
         Index           =   0
         Left            =   4920
         Style           =   2  'Dropdown List
         TabIndex        =   85
         Top             =   1608
         Width           =   1272
      End
      Begin VB.ComboBox Combo2 
         Height          =   288
         Index           =   0
         Left            =   6240
         Style           =   2  'Dropdown List
         TabIndex        =   84
         Top             =   1596
         Width           =   1272
      End
      Begin VB.TextBox Text2 
         Alignment       =   1  'Right Justify
         DataField       =   "heure"
         DataSource      =   "Data1"
         Height          =   285
         Index           =   0
         Left            =   7560
         TabIndex        =   83
         Text            =   "00"
         Top             =   1608
         Width           =   435
      End
      Begin VB.TextBox Text3 
         Alignment       =   1  'Right Justify
         DataField       =   "minute"
         DataSource      =   "Data1"
         Height          =   285
         Index           =   0
         Left            =   8040
         TabIndex        =   82
         Text            =   "00"
         Top             =   1608
         Width           =   435
      End
      Begin VB.TextBox Text4 
         Alignment       =   1  'Right Justify
         DataField       =   "seconde"
         DataSource      =   "Data1"
         Height          =   285
         Index           =   0
         Left            =   8520
         TabIndex        =   81
         Text            =   "00"
         Top             =   1608
         Width           =   435
      End
      Begin VB.ComboBox Combo3 
         Height          =   288
         Index           =   0
         Left            =   2940
         Style           =   2  'Dropdown List
         TabIndex        =   80
         Top             =   1608
         Width           =   1032
      End
      Begin VB.ComboBox Combo4 
         Height          =   288
         Index           =   0
         Left            =   2220
         Style           =   2  'Dropdown List
         TabIndex        =   79
         Top             =   1608
         Width           =   732
      End
      Begin VB.ComboBox Combo5 
         Height          =   288
         Index           =   0
         Left            =   3960
         Style           =   2  'Dropdown List
         TabIndex        =   78
         Top             =   1608
         Width           =   732
      End
      Begin VB.ComboBox Combo1 
         Height          =   288
         Index           =   1
         Left            =   4920
         Style           =   2  'Dropdown List
         TabIndex        =   77
         Top             =   1968
         Width           =   1272
      End
      Begin VB.ComboBox Combo1 
         Height          =   288
         Index           =   2
         Left            =   4920
         Style           =   2  'Dropdown List
         TabIndex        =   76
         Top             =   2328
         Width           =   1272
      End
      Begin VB.ComboBox Combo1 
         Height          =   288
         Index           =   3
         Left            =   4920
         Style           =   2  'Dropdown List
         TabIndex        =   75
         Top             =   2688
         Width           =   1272
      End
      Begin VB.ComboBox Combo2 
         Height          =   288
         Index           =   1
         Left            =   6240
         Style           =   2  'Dropdown List
         TabIndex        =   74
         Top             =   1968
         Width           =   1272
      End
      Begin VB.ComboBox Combo2 
         Height          =   288
         Index           =   2
         Left            =   6240
         Style           =   2  'Dropdown List
         TabIndex        =   73
         Top             =   2328
         Width           =   1272
      End
      Begin VB.ComboBox Combo2 
         Height          =   288
         Index           =   3
         Left            =   6240
         Style           =   2  'Dropdown List
         TabIndex        =   72
         Top             =   2688
         Width           =   1272
      End
      Begin VB.TextBox Text2 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   1
         Left            =   7560
         TabIndex        =   71
         Text            =   "00"
         Top             =   1968
         Width           =   435
      End
      Begin VB.TextBox Text2 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   2
         Left            =   7560
         TabIndex        =   70
         Text            =   "00"
         Top             =   2328
         Width           =   435
      End
      Begin VB.TextBox Text2 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   3
         Left            =   7560
         TabIndex        =   69
         Text            =   "00"
         Top             =   2688
         Width           =   435
      End
      Begin VB.TextBox Text3 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   1
         Left            =   8040
         TabIndex        =   68
         Text            =   "00"
         Top             =   1968
         Width           =   435
      End
      Begin VB.TextBox Text3 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   2
         Left            =   8040
         TabIndex        =   67
         Text            =   "00"
         Top             =   2328
         Width           =   435
      End
      Begin VB.TextBox Text3 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   3
         Left            =   8040
         TabIndex        =   66
         Text            =   "00"
         Top             =   2688
         Width           =   435
      End
      Begin VB.TextBox Text4 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   1
         Left            =   8520
         TabIndex        =   65
         Text            =   "00"
         Top             =   1968
         Width           =   435
      End
      Begin VB.TextBox Text4 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   2
         Left            =   8520
         TabIndex        =   64
         Text            =   "00"
         Top             =   2328
         Width           =   435
      End
      Begin VB.TextBox Text4 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   3
         Left            =   8520
         TabIndex        =   63
         Text            =   "00"
         Top             =   2688
         Width           =   435
      End
      Begin VB.ComboBox Combo3 
         Height          =   288
         Index           =   1
         Left            =   2940
         Style           =   2  'Dropdown List
         TabIndex        =   62
         Top             =   1968
         Width           =   1032
      End
      Begin VB.ComboBox Combo3 
         Height          =   288
         Index           =   2
         Left            =   2940
         Style           =   2  'Dropdown List
         TabIndex        =   61
         Top             =   2328
         Width           =   1032
      End
      Begin VB.ComboBox Combo3 
         Height          =   288
         Index           =   3
         Left            =   2940
         Style           =   2  'Dropdown List
         TabIndex        =   60
         Top             =   2688
         Width           =   1032
      End
      Begin VB.ComboBox Combo4 
         Height          =   288
         Index           =   1
         Left            =   2220
         Style           =   2  'Dropdown List
         TabIndex        =   59
         Top             =   1968
         Width           =   732
      End
      Begin VB.ComboBox Combo4 
         Height          =   288
         Index           =   2
         Left            =   2220
         Style           =   2  'Dropdown List
         TabIndex        =   58
         Top             =   2328
         Width           =   732
      End
      Begin VB.ComboBox Combo4 
         Height          =   288
         Index           =   3
         Left            =   2220
         Style           =   2  'Dropdown List
         TabIndex        =   57
         Top             =   2688
         Width           =   732
      End
      Begin VB.ComboBox Combo5 
         Height          =   288
         Index           =   1
         Left            =   3960
         Style           =   2  'Dropdown List
         TabIndex        =   56
         Top             =   1968
         Width           =   732
      End
      Begin VB.ComboBox Combo5 
         Height          =   288
         Index           =   2
         Left            =   3960
         Style           =   2  'Dropdown List
         TabIndex        =   55
         Top             =   2328
         Width           =   732
      End
      Begin VB.ComboBox Combo5 
         Height          =   288
         Index           =   3
         Left            =   3960
         Style           =   2  'Dropdown List
         TabIndex        =   54
         Top             =   2688
         Width           =   732
      End
      Begin VB.ComboBox Combo6 
         Height          =   288
         Index           =   3
         Left            =   1140
         Style           =   2  'Dropdown List
         TabIndex        =   53
         Top             =   2688
         Width           =   732
      End
      Begin VB.ComboBox Combo6 
         Height          =   288
         Index           =   2
         Left            =   1140
         Style           =   2  'Dropdown List
         TabIndex        =   52
         Top             =   2328
         Width           =   732
      End
      Begin VB.ComboBox Combo6 
         Height          =   288
         Index           =   1
         Left            =   1140
         Style           =   2  'Dropdown List
         TabIndex        =   51
         Top             =   1968
         Width           =   732
      End
      Begin VB.ComboBox Combo6 
         Height          =   288
         Index           =   0
         ItemData        =   "DOMOTIC.frx":1850
         Left            =   1128
         List            =   "DOMOTIC.frx":1852
         Style           =   2  'Dropdown List
         TabIndex        =   50
         Top             =   1608
         Width           =   732
      End
      Begin VB.CommandButton Command4 
         Caption         =   "Load"
         Height          =   300
         Left            =   6240
         TabIndex        =   49
         Top             =   360
         Width           =   1308
      End
      Begin VB.CommandButton Command5 
         Caption         =   "Save as"
         Enabled         =   0   'False
         Height          =   300
         Left            =   7680
         TabIndex        =   48
         Top             =   360
         Width           =   1332
      End
      Begin VB.CommandButton Command7 
         Caption         =   "New"
         Height          =   300
         Left            =   4800
         TabIndex        =   47
         Top             =   360
         Width           =   1308
      End
      Begin VB.TextBox ProgramFile 
         Height          =   288
         Left            =   1800
         TabIndex        =   46
         TabStop         =   0   'False
         Text            =   "Text5"
         Top             =   360
         Width           =   2892
      End
      Begin VB.Label Etiquette2 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         Caption         =   "Program file name:"
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
         Index           =   0
         Left            =   240
         TabIndex        =   100
         Top             =   432
         Width           =   1476
      End
      Begin VB.Label NbreOrdres 
         Alignment       =   1  'Right Justify
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "0"
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
         Height          =   252
         Left            =   2760
         TabIndex        =   99
         Top             =   1032
         Width           =   372
      End
      Begin VB.Label Etiquette16 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Number of programed orders:"
         ForeColor       =   &H00000000&
         Height          =   192
         Left            =   240
         TabIndex        =   98
         Top             =   1032
         Width           =   2532
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "Order No:"
         Height          =   252
         Left            =   240
         TabIndex        =   97
         Top             =   1368
         Width           =   852
      End
      Begin VB.Label Label2 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Jour"
         Height          =   252
         Left            =   5040
         TabIndex        =   96
         Top             =   1368
         Width           =   912
      End
      Begin VB.Label Label3 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Mois"
         Height          =   312
         Left            =   6180
         TabIndex        =   95
         Top             =   1368
         Width           =   1212
      End
      Begin VB.Label Label4 
         BackStyle       =   0  'Transparent
         Caption         =   "HH : MM : SS"
         Height          =   252
         Left            =   7680
         TabIndex        =   94
         Top             =   1368
         Width           =   1212
      End
      Begin VB.Label Label5 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Action"
         Height          =   252
         Left            =   3000
         TabIndex        =   93
         Top             =   1368
         Width           =   852
      End
      Begin VB.Label Label6 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Op1"
         Height          =   192
         Left            =   2220
         TabIndex        =   92
         Top             =   1368
         Width           =   732
      End
      Begin VB.Label Label7 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Op2"
         Height          =   192
         Left            =   3960
         TabIndex        =   91
         Top             =   1368
         Width           =   732
      End
      Begin VB.Label Label8 
         BackStyle       =   0  'Transparent
         Caption         =   "Bit        ="
         Height          =   192
         Left            =   1320
         TabIndex        =   90
         Top             =   1368
         Width           =   852
      End
      Begin VB.Line Ligne31 
         X1              =   264
         X2              =   9000
         Y1              =   840
         Y2              =   840
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Manual control"
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3132
      Left            =   120
      TabIndex        =   11
      Top             =   1320
      Width           =   9252
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   1
         Left            =   912
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   23
         TabStop         =   0   'False
         Top             =   1200
         Width           =   435
      End
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         Height          =   285
         Index           =   2
         Left            =   912
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   22
         TabStop         =   0   'False
         Top             =   1680
         Width           =   435
      End
      Begin VB.TextBox adresses 
         Alignment       =   1  'Right Justify
         Height          =   288
         Index           =   3
         Left            =   912
         MaxLength       =   3
         MousePointer    =   3  'I-Beam
         TabIndex        =   21
         TabStop         =   0   'False
         Top             =   2184
         Width           =   432
      End
      Begin VB.CommandButton Commande1 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         Caption         =   "&Switch bit"
         Height          =   300
         Left            =   4176
         TabIndex        =   20
         TabStop         =   0   'False
         Top             =   2640
         Width           =   1548
      End
      Begin VB.TextBox io 
         Enabled         =   0   'False
         Height          =   285
         Index           =   1
         Left            =   1656
         MaxLength       =   1
         TabIndex        =   19
         Top             =   1200
         Width           =   255
      End
      Begin VB.TextBox io 
         Enabled         =   0   'False
         Height          =   285
         Index           =   2
         Left            =   1656
         MaxLength       =   1
         TabIndex        =   18
         Top             =   1680
         Width           =   255
      End
      Begin VB.TextBox io 
         Enabled         =   0   'False
         Height          =   285
         Index           =   3
         Left            =   1656
         MaxLength       =   1
         TabIndex        =   17
         Top             =   2196
         Width           =   255
      End
      Begin VB.TextBox BitName 
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   7.8
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   288
         Left            =   2160
         MaxLength       =   15
         TabIndex        =   16
         TabStop         =   0   'False
         Text            =   "BitName"
         Top             =   2640
         Width           =   1668
      End
      Begin VB.CommandButton Command2 
         Caption         =   "Load"
         Height          =   300
         Left            =   6240
         TabIndex        =   15
         Top             =   240
         Width           =   1308
      End
      Begin VB.CommandButton Command3 
         Caption         =   "Save as"
         Height          =   300
         Left            =   7680
         TabIndex        =   14
         Top             =   240
         Width           =   1308
      End
      Begin VB.CommandButton Command6 
         Caption         =   "New"
         Height          =   300
         Left            =   4800
         TabIndex        =   13
         Top             =   240
         Width           =   1308
      End
      Begin VB.TextBox SettingFile 
         Height          =   288
         Left            =   1800
         TabIndex        =   12
         TabStop         =   0   'False
         Text            =   "Config.cfg"
         Top             =   240
         Width           =   2820
      End
      Begin Threed.SSPanel A 
         Height          =   396
         Index           =   0
         Left            =   2160
         TabIndex        =   24
         Top             =   1200
         Width           =   492
         _Version        =   65536
         _ExtentX        =   868
         _ExtentY        =   699
         _StockProps     =   15
         Caption         =   "SSPanel1"
         BackColor       =   12632256
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "MS Sans Serif"
            Size            =   7.8
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
      End
      Begin VB.Label Etiquette3 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Port A"
         ForeColor       =   &H00000000&
         Height          =   180
         Left            =   240
         TabIndex        =   44
         Top             =   1296
         Width           =   612
      End
      Begin VB.Label Etiquette7 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Ports       Adresse                                               "
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
         Height          =   204
         Index           =   0
         Left            =   240
         TabIndex        =   43
         Top             =   912
         Width           =   588
      End
      Begin VB.Label Etiquette9 
         Caption         =   "Selected bit name:"
         Height          =   192
         Left            =   240
         TabIndex        =   42
         Top             =   2736
         Width           =   1728
      End
      Begin VB.Label Etiquette12 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H00000000&
         Height          =   252
         Left            =   1416
         TabIndex        =   41
         Top             =   1296
         Width           =   132
      End
      Begin VB.Label Etiquette13 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H00000000&
         Height          =   192
         Left            =   1416
         TabIndex        =   40
         Top             =   1740
         Width           =   132
      End
      Begin VB.Label Etiquette14 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "h"
         ForeColor       =   &H00000000&
         Height          =   192
         Left            =   1416
         TabIndex        =   39
         Top             =   2256
         Width           =   132
      End
      Begin VB.Label Etiquette19 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "No initialisation."
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
         Height          =   684
         Left            =   6672
         TabIndex        =   38
         Top             =   1200
         Width           =   2316
      End
      Begin VB.Label Etiquette6 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Initialisation"
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
         Height          =   192
         Left            =   6672
         TabIndex        =   37
         Top             =   912
         Width           =   2316
      End
      Begin VB.Line Ligne16 
         BorderColor     =   &H00808080&
         X1              =   6672
         X2              =   7536
         Y1              =   1104
         Y2              =   1104
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 7"
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
         Height          =   204
         Index           =   0
         Left            =   2256
         TabIndex        =   36
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 6"
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
         Height          =   204
         Index           =   1
         Left            =   2736
         TabIndex        =   35
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit  5"
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
         Height          =   204
         Index           =   2
         Left            =   3216
         TabIndex        =   34
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 4"
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
         Height          =   204
         Index           =   3
         Left            =   3792
         TabIndex        =   33
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 3"
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
         Height          =   204
         Index           =   4
         Left            =   4272
         TabIndex        =   32
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 2"
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
         Height          =   204
         Index           =   5
         Left            =   4752
         TabIndex        =   31
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 1"
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
         Height          =   204
         Index           =   6
         Left            =   5328
         TabIndex        =   30
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Label9 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Bit 0"
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
         Height          =   204
         Index           =   7
         Left            =   5808
         TabIndex        =   29
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Etiquette7 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "I/O"
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
         Height          =   204
         Index           =   1
         Left            =   1584
         TabIndex        =   28
         Top             =   912
         Width           =   492
      End
      Begin VB.Label Etiquette5 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Port C"
         ForeColor       =   &H00000000&
         Height          =   204
         Left            =   240
         TabIndex        =   27
         Top             =   2256
         Width           =   612
      End
      Begin VB.Label Etiquette4 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         BackStyle       =   0  'Transparent
         Caption         =   "Port B"
         ForeColor       =   &H00000000&
         Height          =   204
         Left            =   240
         TabIndex        =   26
         Top             =   1776
         Width           =   684
      End
      Begin VB.Line Ligne30 
         X1              =   240
         X2              =   8976
         Y1              =   720
         Y2              =   720
      End
      Begin VB.Label Etiquette2 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H00C0C0C0&
         Caption         =   "Settings File:"
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
         Left            =   240
         TabIndex        =   25
         Top             =   336
         Width           =   996
      End
      Begin VB.Line Line2 
         X1              =   6480
         X2              =   6480
         Y1              =   720
         Y2              =   2928
      End
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   5
      Left            =   2640
      TabIndex        =   10
      Top             =   0
      Width           =   492
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   4
      Left            =   2160
      TabIndex        =   9
      Top             =   0
      Width           =   492
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   3
      Left            =   1680
      TabIndex        =   8
      Top             =   0
      Width           =   492
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   2
      Left            =   1080
      TabIndex        =   7
      Top             =   0
      Width           =   492
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   1
      Left            =   600
      TabIndex        =   6
      Top             =   0
      Width           =   492
   End
   Begin VB.CheckBox Option1 
      Caption         =   "  Run scheduler"
      Height          =   252
      Left            =   7236
      TabIndex        =   3
      Top             =   132
      Width           =   1572
   End
   Begin VB.CommandButton Commande0 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Commande0"
      Height          =   315
      Left            =   10080
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   2976
      Visible         =   0   'False
      Width           =   1155
   End
   Begin VB.Timer Temps 
      Interval        =   950
      Left            =   10464
      Top             =   3264
   End
   Begin Threed.SSPanel Status 
      Align           =   2  'Align Bottom
      Height          =   300
      Left            =   0
      TabIndex        =   4
      Top             =   7872
      Width           =   9540
      _Version        =   65536
      _ExtentX        =   16828
      _ExtentY        =   529
      _StockProps     =   15
      Caption         =   "On-line help"
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      BevelWidth      =   2
      BevelOuter      =   1
      Alignment       =   1
   End
   Begin VB.CommandButton BarCommand 
      Height          =   492
      Index           =   0
      Left            =   120
      TabIndex        =   108
      Top             =   0
      Width           =   492
   End
   Begin Threed.SSPanel Bar 
      Height          =   480
      Left            =   0
      TabIndex        =   5
      Top             =   12
      Width           =   9612
      _Version        =   65536
      _ExtentX        =   16955
      _ExtentY        =   847
      _StockProps     =   15
      BackColor       =   12632256
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   7.8
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      FloodShowPct    =   0   'False
   End
   Begin VB.Label DateEtHeure 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "jj/mm/aaaa    hh:mm"
      ForeColor       =   &H80000008&
      Height          =   264
      Left            =   6804
      TabIndex        =   105
      Top             =   744
      Width           =   2412
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   10464
      Top             =   2592
      _Version        =   65536
      _ExtentX        =   677
      _ExtentY        =   677
      _StockProps     =   0
   End
   Begin VB.Label Etiquette25 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Logiciel d' Acquisition, Traitements et de Programmation d'Entrées/Sorties Universel."
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
      Height          =   516
      Left            =   264
      TabIndex        =   2
      Top             =   720
      Width           =   5724
   End
   Begin VB.Line Ligne21 
      BorderColor     =   &H00FFFFFF&
      X1              =   9348
      X2              =   9348
      Y1              =   1032
      Y2              =   672
   End
   Begin VB.Line Ligne20 
      BorderColor     =   &H00000000&
      X1              =   6720
      X2              =   9360
      Y1              =   672
      Y2              =   672
   End
   Begin VB.Line Ligne6 
      BorderColor     =   &H00FFFFFF&
      X1              =   6720
      X2              =   9360
      Y1              =   1056
      Y2              =   1056
   End
   Begin VB.Line Ligne4 
      BorderColor     =   &H00000000&
      X1              =   6720
      X2              =   6720
      Y1              =   672
      Y2              =   1068
   End
   Begin VB.Menu MenuFichier 
      Caption         =   "&File"
      Begin VB.Menu MenuNewSet 
         Caption         =   "&New settings"
      End
      Begin VB.Menu MenuOpenSet 
         Caption         =   "&Open settings file"
      End
      Begin VB.Menu MenuSaveSet 
         Caption         =   "&Save settings file as..."
      End
      Begin VB.Menu barre1 
         Caption         =   "-"
      End
      Begin VB.Menu MenuNouveau 
         Caption         =   "&New program"
      End
      Begin VB.Menu MenuCharger 
         Caption         =   "&Open program file..."
      End
      Begin VB.Menu MenuSauver 
         Caption         =   "&Save program as..."
      End
      Begin VB.Menu barre2 
         Caption         =   "-"
      End
      Begin VB.Menu MenuQuitter 
         Caption         =   "&Quit"
      End
   End
   Begin VB.Menu MenuProgramme 
      Caption         =   "&Program"
      Enabled         =   0   'False
      Begin VB.Menu MenuSupprimer 
         Caption         =   "&Delete command"
      End
   End
   Begin VB.Menu MenuOptions 
      Caption         =   "&Options"
      Begin VB.Menu MenuEnregistrerConfiguration 
         Caption         =   "&Save configuration on exit"
         Checked         =   -1  'True
      End
   End
   Begin VB.Menu Aide 
      Caption         =   "&?"
      Begin VB.Menu menu_aide_aide 
         Caption         =   "Help"
         Shortcut        =   {F1}
      End
      Begin VB.Menu barre4 
         Caption         =   "-"
      End
      Begin VB.Menu MenuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "Domo"
Attribute VB_Creatable = False
Attribute VB_Exposed = False




Private Function ADRESSE_VALIDE(i As Integer) As Single
b = True
If (i < &H378 Or i > &H37A) And (i < &H278 Or i > &H27A) And (i < &H300 Or i > &H31F) Then
  b = False
  Message = "Addresse already used !" + CRLF + "Choose an other one..."
  MsgBox Message, 48, app.Title
  End If
For j = 0 To 3
  If i = Adresse(j) Then
    b = False
    Message = "Address already used !" + CRLF + "Choose an other one..."
    MsgBox Message, 48, app.Title
    End If
  Next j
ADRESSE_VALIDE = b
End Function

Public Sub InitScheduler()
'Initialisation affichage scheduler
For i = 0 To 3
combo1(i).Clear
combo1(i).AddItem "All"
combo1(i).AddItem "Monday"
combo1(i).AddItem "Tuesday"
combo1(i).AddItem "Wednesday"
combo1(i).AddItem "Thursday"
combo1(i).AddItem "Friday"
combo1(i).AddItem "Saturday"
combo1(i).AddItem "Sunday"
combo1(i).AddItem "Sat+Sunday"
combo2(i).Clear
combo2(i).AddItem "All"
combo2(i).AddItem "January"
combo2(i).AddItem "February"
combo2(i).AddItem "March"
combo2(i).AddItem "April"
combo2(i).AddItem "May"
combo2(i).AddItem "June"
combo2(i).AddItem "July"
combo2(i).AddItem "August"
combo2(i).AddItem "September"
combo2(i).AddItem "October"
combo2(i).AddItem "November"
combo2(i).AddItem "December"
combo3(i).Clear
combo3(i).AddItem "="
combo3(i).AddItem "=0"
combo3(i).AddItem "=1"
combo3(i).AddItem "NOT"
combo3(i).AddItem "OR"
combo3(i).AddItem "AND"
combo3(i).AddItem "XOR"
combo3(i).AddItem "NOR"
combo3(i).AddItem "NAND"
combo4(i).Clear
For j = 0 To 7
combo4(i).AddItem "A" + Trim$(Str$(j))
Next j
For j = 0 To 7
combo4(i).AddItem "B" + Trim$(Str$(j))
Next j
For j = 0 To 7
combo4(i).AddItem "C" + Trim$(Str$(j))
Next j
combo5(i).Clear
For j = 0 To 7
combo5(i).AddItem "A" + Trim$(Str$(j))
Next j
For j = 0 To 7
combo5(i).AddItem "B" + Trim$(Str$(j))
Next j
For j = 0 To 7
combo5(i).AddItem "C" + Trim$(Str$(j))
Next j
Next i
NbreOrdres = 0
End Sub

Function teste_ligne(index As Integer)
Dim b As Boolean

b = True
If (combo6(index).Text = "") Then b = False
If (combo3(index).Text = "") Then b = False
If (combo1(index).Text = "") Then b = False
If (combo2(index).Text = "") Then b = False
If ((combo4(index).Text = "") And (combo4(index).Enabled = True)) Then b = False
If ((combo5(index).Text = "") And (combo5(index).Enabled = True)) Then b = False
If b Then
    If index < 3 Then
        text1(index + 1).Enabled = True
        combo6(index + 1).Enabled = True
        combo4(index + 1).Enabled = True
        combo3(index + 1).Enabled = True
        combo5(index + 1).Enabled = True
        combo1(index + 1).Enabled = True
        combo2(index + 1).Enabled = True
        text2(index + 1).Enabled = True
        text3(index + 1).Enabled = True
        text4(index + 1).Enabled = True
        combo6(index + 1).SetFocus
        position1 = index + 1
        ' Sauve dans base
        ECRIREPROG text1(index).Text, index
    Else
        ' Sauve dans base
        ECRIREPROG text1(index).Text, index
        position1 = position1 + 1
        combo6(3).SetFocus
    End If
End If


End Function

Private Sub a_Click(index As Integer)
a(Port * 8 + bit - 8).BevelOuter = 2
a(Port * 8 + bit - 8).BevelInner = 0
bit = index Mod 8
Port = Int(index / 8) + 1
a(Port * 8 + bit - 8).BevelOuter = 1
a(Port * 8 + bit - 8).BevelInner = 1
BitName.Text = NomBit(Port, bit)
If (sens(Port)) And (mode = 0) Then
  Commande1.Enabled = True
Else
  Commande1.Enabled = False
End If
End Sub

Private Sub adresses_GotFocus(index As Integer)
saves = Adresses(index).Text
End Sub

Private Sub adresses_KeyPress(index As Integer, KeyAscii As Integer)
If KeyAscii <> 13 Then Exit Sub
i = ATTENTE()  'Perd le focus
End Sub

Private Sub adresses_lostfocus(index As Integer)
s$ = Adresses(index).Text
If s$ = saves Then Exit Sub 'Quitter sans changement
If ADRESSE_VALIDE(HEX_DEC(s$)) Then
  Adresse(index) = HEX_DEC(s$)
Else: Adresse(index) = HEX_DEC(saves)
  Adresses(index).Text = saves
  End If
End Sub

Private Function ATTENTE()
commande0.Visible = True
If Not Chargement Then
  commande0.SetFocus
  End If
commande0.Visible = False
End Function



Private Sub combo1_Click(index As Integer)
teste_ligne (index)
End Sub


Private Sub combo2_Click(index As Integer)
teste_ligne (index)
End Sub


Private Sub combo3_Click(index As Integer)
If (combo3(index).Text = "=") Or (combo3(index).Text = "NOT") Then
    combo4(index).Enabled = True
    combo5(index).Enabled = False
    combo5(index).ListIndex = -1
ElseIf (combo3(index).Text = "=0") Or (combo3(index).Text = "=1") Then
    combo4(index).Enabled = False
    combo4(index).ListIndex = -1
    combo5(index).Enabled = False
    combo5(index).ListIndex = -1
Else
    combo4(index).Enabled = True
    combo5(index).Enabled = True
End If

teste_ligne (index)

End Sub


Private Sub combo4_Click(index As Integer)
teste_ligne (index)
End Sub


Private Sub combo5_Click(index As Integer)
teste_ligne (index)
End Sub


Private Sub combo6_Click(index As Integer)
teste_ligne (index)
End Sub


Private Sub Command2_Click()
MenuOpenSet_Click
End Sub

Private Sub Command3_Click()
MenuSaveSet_Click
End Sub

Private Sub Command4_Click()
MenuCharger_Click
End Sub

Private Sub Command5_Click()
MenuSauver_click
End Sub

Private Sub Command6_Click()
MenuNewSet_Click
End Sub

Private Sub Command7_Click()
MenuNouveau_Click
End Sub




Private Sub Form_Resize()
If Me.Width < Width_min Then
    On Error Resume Next 'Evite erreur si iconisation
    Me.Width = Width_min
    On Error GoTo 0
Else
    Bar.Width = Me.Width - 96
    Ligne20.X2 = Me.Width - 300
    
    Ligne21.X1 = Me.Width - 300
    Ligne21.X2 = Me.Width - 300
    
    Ligne6.X2 = Me.Width - 300
    Frame1.Width = Me.Width - 400
    Ligne30.X2 = Me.Width - 300 - 192
    Frame2.Width = Me.Width - 400
    Ligne31.X2 = Me.Width - 300 - 192
End If
If Me.Height < Height_min Then
    On Error Resume Next 'Evite erreur si iconisation
    Me.Height = Height_min
    On Error GoTo 0
End If

End Sub




Private Sub MenuNewSet_Click()
If mode = 1 Then
  Message = "You can't change the settings while a program is running !" + CRLF + "Stop it first."
  MsgBox Message, 48, app.Title
Else
  Conf.Show 1
  InitNewConfig
End If
End Sub

Private Sub MenuOpenSet_Click()
CommonDialog1.DialogTitle = "Load a setting file"
CommonDialog1.InitDir = app.path
CommonDialog1.DefaultExt = ".cfg"
CommonDialog1.Filter = "Universal Domotic Setting file (*.cfg)|*.cfg"
CommonDialog1.action = 1

Fichier$ = CommonDialog1.filename
If Fichier$ <> "" Then
    SPLITFILENAME Fichier$, p$, f$
    If f$ <> "" Then LireConfig (Fichier$)
    NomConfig = f$
    InitNewConfig
End If

End Sub

Private Sub MenuSaveSet_Click()
CommonDialog1.DialogTitle = "Save a setting file"
CommonDialog1.InitDir = app.path
CommonDialog1.DefaultExt = ".cfg"
CommonDialog1.Filter = "Universal Domotic Setting file (*.cfg)|*.cfg"
CommonDialog1.action = 2

Fichier$ = CommonDialog1.filename
If Fichier$ <> "" Then
    SPLITFILENAME Fichier$, p$, f$
    If UCase(f$) = "NEW.CFG" Or UCase(Fichier$) = "NEW" Then
        MsgBox ("Error: Setting file can't be called 'new'.")
    Else
        EcrireConfig (Fichier$)
        NomConfig = f$
        SettingFile.Text = NomConfig
    End If
End If

End Sub


Private Sub Option1_Click()

If option1.Value Then
    'Mode automatique
    mode = 1
    'Modifie accès aux contrôles
    Commande1.Enabled = False
    Adresses(1).Enabled = False
    Adresses(2).Enabled = False
    Adresses(3).Enabled = False
    menunouveau.Enabled = False
    menucharger.Enabled = False
    Command7.Enabled = False
    Command4.Enabled = False
    i = ATTENTE()
Else
    'Mode manuel
    mode = 0
    If sens(Port) Then
      Commande1.Enabled = True
    Else
      Commande1.Enabled = False
    End If
    Adresses(1).Enabled = True
    Adresses(2).Enabled = True
    Adresses(3).Enabled = True
    menunouveau.Enabled = True
    menucharger.Enabled = True
    Command7.Enabled = True
    Command4.Enabled = True
    i = ATTENTE()
End If

End Sub

Private Sub Commande1_Click()
'Accès à _click uniquement si port=sortie et mode manuel
Temps.Enabled = False
If EtatBit(Port, bit) = 0 Then
  EtatBit(Port, bit) = 1
Else
  EtatBit(Port, bit) = 0
End If
'Ecriture des ports sorties
If (Adresse(Port) = &H37A) Or (Adresse(Port) = &H27A) Then
octet(Port) = EtatBit(Port, 0) Xor 1
Else
octet(Port) = EtatBit(Port, 0)
End If
If (Adresse(Port) = &H37A) Or (Adresse(Port) = &H27A) Then
octet(Port) = octet(Port) + ((EtatBit(Port, 1) * 2) Xor 2)
Else
octet(Port) = octet(Port) + (EtatBit(Port, 1) * 2)
End If
octet(Port) = octet(Port) + (EtatBit(Port, 2) * 4)
If (Adresse(Port) = &H37A) Or (Adresse(Port) = &H27A) Then
octet(Port) = octet(Port) + ((EtatBit(Port, 3) * 8) Xor 8)
Else
octet(Port) = octet(Port) + (EtatBit(Port, 3) * 8)
End If
octet(Port) = octet(Port) + (EtatBit(Port, 4) * 16)
octet(Port) = octet(Port) + (EtatBit(Port, 5) * 32)
octet(Port) = octet(Port) + (EtatBit(Port, 6) * 64)
octet(Port) = octet(Port) + (EtatBit(Port, 7) * 128)
#If Win16 Then
    OutByte Adresse(Port), octet(Port)
#End If
If EtatBit(Port, bit) = 1 Then
  a(8 * Port - 8 + bit).Caption = "1"
Else
  a(8 * Port - 8 + bit).Caption = "0"
End If
Temps.Enabled = True
i = ATTENTE()
End Sub

Private Sub CREE_BASE(chemin As String)
   Dim test As String
   Dim i As Integer
   Dim Td As New TableDef
   Dim fld() As New Field
   Dim idx() As New index

   ReDim fld(1 To 120)
   ReDim idx(1 To 2)
   
   'Efface ancien fichier chemin
   On Error Resume Next
   Kill chemin 'A supprimer (NomFichier doit etre inexistant)
   On Error GoTo 0

   'Crée Base
   Set Db = CreateDatabase(chemin, DB_LANG_GENERAL)

   Td.Name = "Table_actions"   ' Nom de la table
   '***************************************************
   ' Défini les champs d'un enregistrement mot de passe
   '***************************************************
       fld(1).Name = "num"
       fld(1).Type = DB_LONG
       fld(1).Size = 4
       Td.Fields.Append fld(1)
       fld(13).Name = "bit"
       fld(13).Type = DB_TEXT
       fld(13).Size = 4
       Td.Fields.Append fld(13)
       fld(2).Name = "day"
       fld(2).Type = DB_TEXT
       fld(2).Size = 10
       Td.Fields.Append fld(2)
       fld(3).Name = "month"
       fld(3).Type = DB_TEXT
       fld(3).Size = 10
       Td.Fields.Append fld(3)
       fld(5).Name = "hour"
       fld(5).Type = DB_LONG
       fld(5).Size = 4
       Td.Fields.Append fld(5)
       fld(6).Name = "minute"
       fld(6).Type = DB_LONG
       fld(6).Size = 4
       Td.Fields.Append fld(6)
       fld(9).Name = "second"
       fld(9).Type = DB_LONG
       fld(9).Size = 4
       Td.Fields.Append fld(9)
       fld(10).Name = "action"
       fld(10).Type = DB_TEXT
       fld(10).Size = 5
       Td.Fields.Append fld(10)
       fld(11).Name = "op1"
       fld(11).Type = DB_TEXT
       fld(11).Size = 4
       Td.Fields.Append fld(11)
       fld(12).Name = "op2"
       fld(12).Type = DB_TEXT
       fld(12).Size = 4
       Td.Fields.Append fld(12)

    ' Create Indexes.
    idx(1).Name = "PrimaryKey"
    idx(1).Fields = "num"
    idx(1).Primary = True
    idx(1).Unique = True
    idx(2).Name = "SecondaryKey"
    idx(2).Fields = "action"
    For i = 1 To 2
        Td.Indexes.Append idx(i)
    Next i

  'Valide table
  Db.TableDefs.Append Td
  Db.Close

'On rempli le fichier .mdb avec 4 enregistrements
Set Db = OpenDatabase(chemin)
Set MyTable = Db.OpenRecordset("Table_actions", dbOpenTable)
For i = 1 To 4
    MyTable.AddNew
    MyTable("num") = i
    MyTable.Update
Next i
MyTable.Close
Db.Close

End Sub

Private Sub Data1_Reposition()
Dim i, j As Integer
If Not Chargement Then
j = Data1.Recordset.RecordCount - position
If j > 3 Then j = 3  'j est donc entre 0 et 3
For i = 0 To j
  text1(i) = Data1.Recordset.Fields("num")
  If Data1.Recordset.Fields("bit") <> Null Then
    combo6(i).ListIndex = Data1.Recordset.Fields("bit")
  Else
    combo6(i).Text = ""
  End If
  If Data1.Recordset.Fields("action") <> Null Then
    combo3(i).ListIndex = Data1.Recordset.Fields("action")
  Else
    combo3(i).Text = ""
  End If
  If Data1.Recordset.Fields("op1") <> Null Then
    combo4(i).ListIndex = Data1.Recordset.Fields("op1")
  Else
    combo4(i).Text = ""
  End If
  If Data1.Recordset.Fields("op2") <> Null Then
    combo5(i).ListIndex = Data1.Recordset.Fields("op2")
  Else
    combo5(i).Text = ""
  End If
  If Data1.Recordset.Fields("day") <> Null Then
    combo1(i).ListIndex = Data1.Recordset.Fields("jour")
  Else
    combo1(i).Text = ""
  End If
  If Data1.Recordset.Fields("month") <> Null Then
    combo2(i).ListIndex = Data1.Recordset.Fields("mois")
  Else
    combo2(i).Text = ""
  End If
  Chargement = True
  Data1.Recordset.MoveNext
  Chargement = False
Next i
For i = j + 1 To 3
  text1(i) = Data1.Recordset.Fields("num")
  If Data1.Recordset.Fields("bit") <> Null Then
    combo6(i).ListIndex = Data1.Recordset.Fields("bit")
  Else
    combo6(i).Text = ""
  End If
  If Data1.Recordset.Fields("action") <> Null Then
    combo3(i).ListIndex = Data1.Recordset.Fields("action")
  Else
    combo3(i).Text = ""
  End If
  If Data1.Recordset.Fields("op1") <> Null Then
    combo4(i).ListIndex = Data1.Recordset.Fields("op1")
  Else
    combo4(i).Text = ""
  End If
  If Data1.Recordset.Fields("op2") <> Null Then
    combo5(i).ListIndex = Data1.Recordset.Fields("op2")
  Else
    combo5(i).Text = ""
  End If
  If Data1.Recordset.Fields("day") <> Null Then
    combo1(i).ListIndex = Data1.Recordset.Fields("jour")
  Else
    combo1(i).Text = ""
  End If
  If Data1.Recordset.Fields("month") <> Null Then
    combo2(i).ListIndex = Data1.Recordset.Fields("mois")
  Else
    combo2(i).Text = ""
  End If
  Chargement = True
  Data1.Recordset.MoveNext
  Chargement = False
Next i
'On se repositionne sur position
critere_recherche = "num=" + Trim$(Str$(position))
Data1.Recordset.FindFirst critere_recherche
End If
End Sub

Private Sub ECRIREINI()

If NomConfig = "" Or UCase(NomConfig) = "NEW" Or UCase(NomConfig) = "NEW.CFG" Then NomConfig = "Standard.cfg"
i = WritePrivateProfileString("Domotic", "Windowstate", CStr(Me.WindowState), app.path + "\Domotic.ini")
i = WritePrivateProfileString("Domotic", "Top", CStr(Me.Top), app.path + "\Domotic.ini")
i = WritePrivateProfileString("Domotic", "Left", CStr(Me.Left), app.path + "\Domotic.ini")
i = WritePrivateProfileString("Domotic", "Height", CStr(Me.Height), app.path + "\Domotic.ini")
i = WritePrivateProfileString("Domotic", "Width", CStr(Me.Width), app.path + "\Domotic.ini")
If MenuEnregistrerConfiguration.Checked Then
  i = WritePrivateProfileString("Domotic", "SaveOnExit", "yes", app.path + "\Domotic.ini")
Else
  i = WritePrivateProfileString("Domotic", "SaveOnExit", "no", app.path + "\Domotic.ini")
End If
i = WritePrivateProfileString("Domotic", "Setup", NomConfig, app.path + "\Domotic.ini")
i = WritePrivateProfileString("Domotic", "Program", NomFichier, app.path + "\Domotic.ini")

End Sub
Private Sub Form_Activate()
'Lecture du programme
LIREPROG NomFichier
End Sub

Private Sub Form_Load()
Dim i As Integer
Dim j As Integer

Chargement = True
Me.Caption = "Universal Domotic V" + Version
CENTRE Me
'Initialisation affichage
For i = 0 To 7
  If i > 0 Then Load a(i)
  a(i).Left = a(0).Left + i * (a(0).Width + 20)
  a(i).Top = a(0).Top
  a(i).Caption = Str$(EtatBit(1, i))
  a(i).Visible = True
  Load a(i + 8)
  a(i + 8).Visible = True
  a(i + 8).Left = a(0).Left + i * (a(0).Width + 20)
  a(i + 8).Top = a(0).Top + a(0).Height + 50
  a(i + 8).Caption = Str$(EtatBit(2, i))
  Load a(i + 16)
  a(i + 16).Visible = True
  a(i + 16).Left = a(0).Left + i * (a(0).Width + 20)
  a(i + 16).Top = a(0).Top + 2 * a(0).Height + 100
  a(i + 16).Caption = Str$(EtatBit(3, i))
  Next i
Port = 1
bit = 0
a(0).BevelOuter = 1
a(0).BevelInner = 1
Chargement = True

'Lecture du fichier domotic.ini
LIREINI
'Lecture du fichier config.cfg
LireConfig (app.path + "\" + NomConfig)
InitNewConfig

End Sub

Private Sub LIREINI()
Dim s As String
s = String$(255, 0)

'Lecture fichier ini pour remplacer valeurs par defaut
i = GetPrivateProfileInt("Domotic", "WindowState", 0, app.path + "\Domotic.ini")
If i < 0 Or i > 2 Then i = 2
Domo.WindowState = i
i = GetPrivateProfileInt("Domotic", "Top", 0, app.path + "\Domotic.ini")
If i < 0 Or i > 20000 Then i = 0
Domo.Top = i
i = GetPrivateProfileInt("Domotic", "Left", 0, app.path + "\Domotic.ini")
If i < 0 Or i > 20000 Then i = 0
Domo.Left = i
i = GetPrivateProfileInt("Domotic", "Height", 0, app.path + "\Domotic.ini")
If i < 0 Or i > 20000 Then i = 7200
Domo.Height = i
i = GetPrivateProfileInt("Domotic", "Width", 0, app.path + "\Domotic.ini")
If i < 0 Or i > 20000 Then i = 9600
Domo.Width = i
i = GetPrivateProfileString("Domotic", "SaveOnExit", "yes", s$, Len(s$), app.path + "\Domotic.ini")
If Mid$(s$, 1, 2) = "no" Then
      MenuEnregistrerConfiguration = False
Else
      MenuEnregistrerConfiguration = True
End If
NomConfig = ""
NomFichier = ""
i = GetPrivateProfileString("Domotic", "Setup", "Standard.cfg", s$, Len(s$), app.path + "\Domotic.ini")
If (i <> 0) Then
    NomConfig = Mid$(s$, 1, i)
Else
    NomConfig = "Standard.cfg"
End If
i = GetPrivateProfileString("Domotic", "Program", "", s$, Len(s$), app.path + "\Domotic.ini")
If (i <> 0) Then
    NomFichier = Mid$(s$, 1, i)
Else
    NomFichier = ""
End If

End Sub

Private Sub menu_aide_aide_Click()
i = Shell("winhelp " + app.HelpFile)
End Sub
Private Function LIREPROG(chaine As String) As Integer
Dim path As String
Dim file As String

SPLITFILENAME chaine, path, file
If path = "" Then chaine = app.path + "\data\" + chaine

InitScheduler
InitNewConfig

If chaine = "" Then
    GoTo noprogram
Else
    'Charge Programme
    ProgramFile.Text = chaine
    ProgramFile.Enabled = False
    option1.Enabled = True
    option1.Value = False
    menusauver.Enabled = True
    Command5.Enabled = True
    menuprogramme.Enabled = True
    etiquette16.Enabled = True
    NbreOrdres.Enabled = True
    'Définit Database
    On Error GoTo filenotfound
    Set Db = OpenDatabase(chaine)
    On Error GoTo 0
    Set MyTable = Db.OpenRecordset("Table_actions", dbOpenTable)
    Set MySet = Db.OpenRecordset("Table_actions", dbOpenDynaset)
    'Recherche les enregistrements
    critere_recherche = "bit <> Null"
    MySet.FindFirst critere_recherche
    While Not MySet.NoMatch
      NbreOrdres = NbreOrdres + 1
      MySet.FindNext critere_recherche
    Wend
    MySet.MoveFirst
    For i = 0 To 3
        If (i < (NbreOrdres + 1)) Then
            text1(i).Enabled = True
            text2(i).Enabled = True
            text3(i).Enabled = True
            text4(i).Enabled = True
            combo1(i).Enabled = True
            combo2(i).Enabled = True
            combo3(i).Enabled = True
            combo4(i).Enabled = True
            combo5(i).Enabled = True
            combo6(i).Enabled = True
        Else
            text1(i).Enabled = False
            text2(i).Enabled = False
            text3(i).Enabled = False
            text4(i).Enabled = False
            combo1(i).Enabled = False
            combo2(i).Enabled = False
            combo3(i).Enabled = False
            combo4(i).Enabled = False
            combo5(i).Enabled = False
            combo6(i).Enabled = False
        End If
        text1(i).Text = MySet("num")
        'Positionne commandes
        For j = 0 To combo6(i).ListCount - 1
            If combo6(i).List(j) = NullToBlank(MySet("bit")) Then
                combo6(i).ListIndex = j
                Exit For
            End If
        Next
        For j = 0 To combo1(i).ListCount - 1
            If combo1(i).List(j) = NullToBlank(MySet("day")) Then
                combo1(i).ListIndex = j
                Exit For
            End If
        Next
        For j = 0 To combo2(i).ListCount - 1
            If combo2(i).List(j) = NullToBlank(MySet("month")) Then
                combo2(i).ListIndex = j
                Exit For
            End If
        Next
        For j = 0 To combo3(i).ListCount - 1
            If combo3(i).List(j) = NullToBlank(MySet("action")) Then
                combo3(i).ListIndex = j
                Exit For
            End If
        Next
        For j = 0 To combo4(i).ListCount - 1
            If combo4(i).List(j) = NullToBlank(MySet("op1")) Then
                combo4(i).ListIndex = j
                Exit For
            End If
        Next
        For j = 0 To combo5(i).ListCount - 1
            If combo5(i).List(j) = NullToBlank(MySet("op2")) Then
                combo5(i).ListIndex = j
                Exit For
            End If
        Next
        text2(i).Text = NullToZero(MySet("hour"))
        text3(i).Text = NullToZero(MySet("minute"))
        text4(i).Text = NullToZero(MySet("second"))
        MySet.MoveNext
    Next i
    position1 = 0
    MySet.MoveFirst
End If
Exit Function

filenotfound:
MsgBox ("Warning: Can't find program file " + chaine + "." + Chr$(13) + Chr$(10) + "No program loaded.")

noprogram:
'Aucun programme charge
ProgramFile.Text = "None"
mode = 0
option1.Enabled = False
option1.Value = False
menusauver.Enabled = False
Command5.Enabled = False
menuprogramme.Enabled = False
etiquette16.Enabled = False
Commande1.Enabled = True
Adresses(1).Enabled = True
Adresses(2).Enabled = True
Adresses(3).Enabled = True
For i = 0 To 3
  text1(i).Enabled = False
  text2(i).Enabled = False
  text3(i).Enabled = False
  text4(i).Enabled = False
  combo1(i).Enabled = False
  combo2(i).Enabled = False
  combo3(i).Enabled = False
  combo4(i).Enabled = False
  combo5(i).Enabled = False
  combo6(i).Enabled = False
Next i

End Function
Private Function ECRIREPROG(no As String, index As Integer) As Integer
'***************************************************
' Ajoute ou met a jour enregistrement de cle no
'***************************************************
    
    'Detecte si cle num existe
    critere_recherche = "num = " + no
    MySet.FindFirst critere_recherche
    
    If MySet.NoMatch Then
        MySet.AddNew
        NbreOrdres = NbreOrdres + 1
    Else
        MySet.Edit
        If NbreOrdres < Val(no) Then NbreOrdres = Val(no)
    End If
      
    MySet("num") = no
    MySet("bit") = combo6(index).Text
    MySet("day") = combo1(index).Text
    MySet("month") = combo2(index).Text
    MySet("action") = combo3(index).Text
    If combo4(index).Text = "" Then
        MySet("op1") = Null
    Else
        MySet("op1") = combo4(index).Text
    End If
    If combo5(index).Text = "" Then
        MySet("op2") = Null
    Else
        MySet("op2") = combo5(index).Text
    End If
    MySet("hour") = text2(i).Text
    MySet("minute") = text3(i).Text
    MySet("second") = text4(i).Text
    MySet.Update

End Function

Private Sub MenuAbout_Click()
About.Show 1
End Sub

Private Sub MenuAjouter_Click()
If mode = 1 Then
  Message = "Un programme en cours d'exécution ne" + CRLF + "peut être modifié !" + CRLF + "Revenez d'abord en commande manuelle."
  MsgBox Message, 48, app.Title
  Option1_Click
Else

End If
End Sub
Private Sub MenuCharger_Click()
Dim i As Integer
Dim s As String
Dim pqual As String
Dim fqual As String
CommonDialog1.DialogTitle = "Load a program"
CommonDialog1.InitDir = app.path + "\data"
CommonDialog1.DefaultExt = ".mdb"
CommonDialog1.Filter = "Universal Domotic Program (*.mdb)|*.mdb"
CommonDialog1.action = 1

s = CommonDialog1.filename
If (Trim$(s) <> "") Then
    SPLITFILENAME s, pqual, fqual
    NomFichier = LCase$(fqual)
    'Lecture du programme
    LIREPROG NomFichier
End If
End Sub
Private Sub MenuEnregistrerConfiguration_Click()
MenuEnregistrerConfiguration.Checked = Not MenuEnregistrerConfiguration.Checked
End Sub

Private Sub MenuModifier_Click()
If mode = 1 Then
  Message = "Un programme en cours d'exécution" + CRLF + "ne peut être modifié !" + CRLF + "Revenez d'abord en commande manuelle."
  MsgBox Message, 48, app.Title
  Option1_Click
Else

  End If
End Sub

Private Sub MenuNouveau_Click()
Dim i As Integer
'Si il y a eu des modifs, sauver programme

'Si un programme est déjà actif
On Error Resume Next
    MySet.Close
    MyTable.Close
    Db.Close
On Error GoTo 0
'A ce point, aucun programme n'est charge
Screen.MousePointer = 11
Chargement = True
NomFichier = "program.mdb"
CREE_BASE (app.path + "\data\" + NomFichier)
' Ouvre Db et définit MySet
i = LIREPROG(NomFichier)
Chargement = False
Screen.MousePointer = 0
End Sub
Private Sub MenuQuitter_Click()
If MenuEnregistrerConfiguration.Checked Then ECRIREINI
Unload Conf
Unload About
Unload Me
End Sub

Private Sub MenuSauver_click()
If NbreOrdres < 1 Then
  Message = "No action programed !" + Chr$(13) + Chr$(10) + "You can't save a program with no commands."
  MsgBox Message, 48, app.Title
  Exit Sub
  End If
'A partir d ici, NbreOrdres > 0
CommonDialog1.DialogTitle = "Save a program as"
CommonDialog1.InitDir = app.path + "\data"
CommonDialog1.DefaultExt = ".mdb"
CommonDialog1.Filter = "Universal Domotic Program (*.mdb)|*.mdb"
CommonDialog1.filename = NomFichier
CommonDialog1.CancelError = True
On Error GoTo finsave
CommonDialog1.action = 2
If CommonDialog1.filename <> "" Then
    s$ = CommonDialog1.filename
    Db.Close
    FileCopy NomFichier, s$
    'Redéfinition
    NomFichier = s$
    LIREPROG (s$)
    End If
finsave:
End Sub

Private Sub MenuSupprimer_Click()
If mode = 1 Then
  Message = "Un programme en cours d'exécution" + CRLF + "ne peut être modifié !" + CRLF + "Revenez d'abord en commande manuelle."
  MsgBox Message, 48, app.Title
  Option1_Click
Else

  End If
End Sub


Private Sub Picture1_Click(index As Integer)
If index = 0 Then
MenuNewSet_Click
End If
If index = 1 Then
MenuOpenSet_Click
End If
If index = 2 Then
MenuSaveSet_Click
End If
If index = 3 Then
MenuNouveau_Click
End If
If index = 4 Then
MenuCharger_Click
End If
If index = 5 Then
MenuSauver_click
End If

End Sub

Private Sub Temps_Timer()
Dim i As Integer
Dim j As Integer
Dim masque As Integer
DateEtHeure.Caption = Format$(Now, "dd/mm/yyyy   hh:mm")
If mode = 1 Then 'Si mode programme
  For i = 1 To 3
    If sens(i) Then 'Si sortie
      trouve = False
      
      
      'Cherche ordre
      
      'octet(i) = ...
      
      If trouve Then OutByte Adresse(i), octet(i)
    Else 'Si entrée
#If Win16 Then
      octet(i) = InByte(Adresse(i))
#End If
      masque = 1
      For j = 0 To 7
        If (octet(i) And masque) = 0 Then
          If EtatBit(i, j) = 1 Then
            EtatBit(i, j) = 0
            a(8 * i - 8 + j).Caption = "0"
          End If
        Else
          If EtatBit(i, j) = 0 Then
            EtatBit(i, j) = 1
            a(8 * i - 8 + j).Caption = "1"
          End If
        End If
      masque = masque * 2
      Next j
    End If
  Next i
Else 'Si mode manuel
  For i = 1 To 3
    If Not sens(i) Then 'Si entrée
#If Win16 Then
      octet(i) = InByte(Adresse(i))
#End If
      'Remet en forme si port parallele
      If (Adresse(i) = &H379) Or (Adresse(i) = &H279) Then
        octet(i) = octet(i) Xor 128
      End If
      masque = 1
      For j = 0 To 7
        If (octet(i) And masque) = 0 Then
          'Comparaison pour éviter scintillement
          If EtatBit(i, j) = 1 Then
            EtatBit(i, j) = 0
            a(8 * i - 8 + j).Caption = "0"
          End If
        Else
          'Comparaison pour éviter scintillement
          If EtatBit(i, j) = 0 Then
            EtatBit(i, j) = 1
            a(8 * i - 8 + j).Caption = "1"
          End If
        End If
        masque = masque * 2
      Next j
    End If
  Next i
End If
End Sub

Private Sub BitName_KeyPress(KeyAscii As Integer)
If KeyAscii <> 13 Then Exit Sub
i = ATTENTE()
End Sub

Private Sub BitName_LostFocus()
NomBit(Port, bit) = BitName.Text
End Sub




Public Sub LireConfig(Fichier As String)
Dim s As String
s = String$(255, 0)

'Lecture fichier .cfg
i = GetPrivateProfileString("Init", "Address(0)", "&h0", s$, Len(s$), Fichier)
i = Val(s$)
Adresse(0) = i
i = GetPrivateProfileString("Init", "Byte(0)", "&h0", s$, Len(s$), Fichier)
i = Val(s$)
octet(0) = i
  
i = GetPrivateProfileString("Ports", "Address(1)", "&h300", s$, Len(s$), Fichier)
i = Val(s$)
Adresse(1) = i
i = GetPrivateProfileString("Ports", "Sens(1)", "I", s$, Len(s$), Fichier)
If Mid$(s$, 1, 1) = "O" Then
    sens(1) = True
Else
    sens(1) = False
End If
i = GetPrivateProfileString("Ports", "Address(2)", "&h301", s$, Len(s$), Fichier)
i = Val(s$)
Adresse(2) = i
i = GetPrivateProfileString("Ports", "Sens(2)", "I", s$, Len(s$), Fichier)
If Mid$(s$, 1, 1) = "O" Then
    sens(2) = True
Else
    sens(2) = False
End If
i = GetPrivateProfileString("Ports", "Address(3)", "&h302", s$, Len(s$), Fichier)
i = Val(s$)
Adresse(3) = i
i = GetPrivateProfileString("Ports", "Sens(3)", "I", s$, Len(s$), Fichier)
If Mid$(s$, 1, 1) = "O" Then
    sens(3) = True
Else
    sens(3) = False
End If
  
For i = 1 To 3
    For j = 0 To 7
        k = GetPrivateProfileString("Ports", "BitName(" + CStr(i) + "," + CStr(j) + ")", "NC", s$, Len(s$), Fichier)
        NomBit(i, j) = s$
    Next
Next

End Sub
Public Sub EcrireConfig(Fichier As String)
Dim s As String
s = String$(255, 0)

'Ecriture fichier .cfg
i = WritePrivateProfileString("Init", "Address(0)", CStr(Adresse(0)), Fichier)
i = WritePrivateProfileString("Init", "Byte(0)", CStr(octet(0)), Fichier)
  
i = WritePrivateProfileString("Ports", "Address(1)", CStr(Adresse(1)), Fichier)
If sens(1) Then
    s$ = "O"
Else
    s$ = "I"
End If
i = WritePrivateProfileString("Ports", "Sens(1)", s$, Fichier)
i = WritePrivateProfileString("Ports", "Address(2)", CStr(Adresse(2)), Fichier)
If sens(2) Then
    s$ = "O"
Else
    s$ = "I"
End If
i = WritePrivateProfileString("Ports", "Sens(2)", s$, Fichier)
i = WritePrivateProfileString("Ports", "Address(3)", CStr(Adresse(3)), Fichier)
If sens(3) Then
    s$ = "O"
Else
    s$ = "I"
End If
i = WritePrivateProfileString("Ports", "Sens(3)", s$, Fichier)

For i = 1 To 3
    For j = 0 To 7
        s$ = NomBit(i, j)
        If s$ = "" Then s$ = "NC"
        k = WritePrivateProfileString("Ports", "BitName(" + CStr(i) + "," + CStr(j) + ")", s$, Fichier)
    Next
Next

'Affichage ports
For i = 1 To 3
  Adresses(i).Text = Hex$(Adresse(i))
  If sens(i) Then
    io(i).Text = "O"
  Else
    io(i).Text = "I"
  End If
  Next i
etiquette17.Caption = Str(NbreOrdres)
a(0).BevelOuter = 1
a(0).BevelInner = 1
'Affichage nom bit
BitName.Text = NomBit(Port, bit)
If sens(Port) Then
  Form1.Commande1.Enabled = True
Else
  Form1.Commande1.Enabled = False
End If
'Initialisation de la carte PIA
If Adresse(0) <> 0 Then
  etiquette19.Caption = "Send the initialising Byte " + Hex$(octet(0)) + " h on Port  " + Hex$(Adresse(0)) + " h"
  OutByte (Adresse(0)), octet(0)
Else
  etiquette19.Caption = "No initialisation."
End If

'Affichage champ SettingFile
SettingFile.Text = NomConfig
SettingFile.Enabled = False

End Sub

Public Function NullToZero(s As Variant) As String
If IsNull(s) Then
    NullToZero = "00"
Else
    NullToZero = s
End If
End Function
Public Function NullToBlank(s As Variant) As String
If IsNull(s) Then
    NullToBlank = ""
Else
    NullToBlank = s
End If
End Function

Public Sub InitNewConfig()

'Affichage ports et définition liste Bit
For i = 0 To 3
    combo6(i).Clear
Next i
For i = 1 To 3
    Adresses(i).Text = Hex$(Adresse(i))
    If sens(i) Then
        io(i).Text = "O"
        For k = 0 To 3
            For j = 0 To 7
                If i = 1 Then combo6(k).AddItem "A" + Trim$(Str$(j))
                If i = 2 Then combo6(k).AddItem "B" + Trim$(Str$(j))
                If i = 3 Then combo6(k).AddItem "C" + Trim$(Str$(j))
            Next j
        Next k
    Else
      io(i).Text = "I"
    End If
Next i
'Affichage nom bit
BitName.Text = NomBit(Port, bit)
If sens(Port) Then
  Me.Commande1.Enabled = True
Else
  Me.Commande1.Enabled = False
End If
'Initialisation de la carte PIA
If Adresse(0) <> 0 Then
  etiquette19.Caption = "Send the initialising Byte " + Hex$(octet(0)) + " h on Port  " + Hex$(Adresse(0)) + " h"
  OutByte (Adresse(0)), octet(0)
Else
  etiquette19.Caption = "No initialisation."
End If

'Affichage champ SettingFile
SettingFile.Text = NomConfig
SettingFile.Enabled = False

End Sub

Private Sub text1_Change(index As Integer)
If oldfield <> "" Then text1(index).Text = oldfield
End Sub

Private Sub text1_GotFocus(index As Integer)
oldfield = text1(index)
End Sub


Private Sub text2_LostFocus(index As Integer)
If Val(text2(index).Text) < 0 Or Val(text2(index).Text) >= 24 Then
    text2(index).Text = "00"
Else
    text2(index).Text = Right$("00" + text2(index).Text, 2)
End If
End Sub


Private Sub text3_LostFocus(index As Integer)
If Val(text3(index).Text) < 0 Or Val(text3(index).Text) >= 60 Then
    text3(index).Text = "00"
Else
    text3(index).Text = Right$("00" + text3(index).Text, 2)
End If
End Sub


Private Sub text4_LostFocus(index As Integer)
If Val(text4(index).Text) < 0 Or Val(text4(index).Text) >= 60 Then
    text4(index).Text = "00"
Else
    text4(index).Text = Right$("00" + text4(index).Text, 2)
End If
End Sub


