VERSION 4.00
Begin VB.Form Form1 
   Appearance      =   0  'Flat
   BackColor       =   &H00FFFFFF&
   Caption         =   "Form1"
   ClientHeight    =   2304
   ClientLeft      =   2892
   ClientTop       =   2364
   ClientWidth     =   6384
   BeginProperty Font 
      name            =   "MS Sans Serif"
      charset         =   1
      weight          =   700
      size            =   7.8
      underline       =   0   'False
      italic          =   0   'False
      strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00000000&
   Height          =   2976
   Left            =   2844
   LinkTopic       =   "Form1"
   ScaleHeight     =   2304
   ScaleWidth      =   6384
   Top             =   1740
   Width           =   6480
   Begin VB.Menu menu_fichier 
      Caption         =   "&Test"
   End
   Begin VB.Menu menu_fichier_quitter 
      Caption         =   "&Quitter"
   End
End
Attribute VB_Name = "Form1"
Attribute VB_Creatable = False
Attribute VB_Exposed = False
Option Explicit

Private Sub Form_Load()
Dim j As Double
Dim i As Integer
Rem i = inp(768)
Rem j = Puissance(5#, 2#)
Rem i = Signe(5)
Rem MsgBox Str(j) & "."
End Sub

Private Sub menu_fichier_Click()
' Le type de retoure des DLL pose pb avec les types reels

Dim i, j As Integer
Dim l As Long
Dim r1, r2 As Double
Dim s1 As Single
i = DiracZero(0)
j = DiracZero(1)
i = TextOut(Form1.hDC, 0, 0, Str$(i) + " - " + Str$(j), 7)

i = 5
j = 2
l = 2
r1 = 5
r2 = 2
r1 = Puis_entiere(i, r2)
i = TextOut(Form1.hDC, 0, 20, Str$(r1) + "     ", 5)

's1 = Puissance(r1, r2)
'i = TextOut(Form1.hDC, 0, 40, Str$(r1) + "     ", 5)
End Sub

Private Sub menu_fichier_quitter_Click()
Unload Form1
End Sub

