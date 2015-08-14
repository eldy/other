VERSION 4.00
Begin VB.Form Form1 
   Appearance      =   0  'Flat
   BackColor       =   &H00FFFFFF&
   Caption         =   "Form1"
   ClientHeight    =   2304
   ClientLeft      =   4188
   ClientTop       =   1776
   ClientWidth     =   6384
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
   Height          =   2976
   Left            =   4140
   LinkTopic       =   "Form1"
   ScaleHeight     =   2304
   ScaleWidth      =   6384
   Top             =   1152
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
' Pb lors de l'appel de DLL avec une valeur
' de retour de type non entier
Dim i As Integer
i = 5
i = Signe(5)
'i = Puissance(i, 2)
i = TextOut(Form1.hdc, 0, 0, Str$(i) + "    ", 3)
End Sub

Private Sub menu_fichier_quitter_Click()
Unload Form1
End Sub

