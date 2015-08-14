Attribute VB_Name = "Domotic"

'Variables classiques
Global Const Version = "1.0"
Global Message As String
Global NumFich As Integer
Global Chargement As Single
Global critere_recherche As String


'Variables spécifiques
'Nom fichier programme
Global NomConfig As String
Global NomFichier As String
Global ModifConfig As Boolean
Global ModifFichier As Boolean
'Mode exécution (0=manuel,1=programme)
Global mode As Integer
'Adresse des ports 0 à 3
Global Adresse(3) As Integer
'adresse sélectionné
Global sens(3) As Single
Global octet(3) As Integer
Global Port As Integer
'Bit sélectionné (0 à 7)
Global bit As Integer
'Nom du bit sélectionné
Global NomBit(3, 7) As String
'Etat du bit (0 ou 1)
Global EtatBit(3, 7) As Integer
Global Const NbreOrdresMax = 20
Global NbreOrdres As Integer
Global saves As String
Type tinstruction
  noordre As Integer
  jour As Integer
  mois As Integer
  heure As Integer
  minute As Integer
  seconde As Integer
  action As Integer
  operande1 As Integer
  operande2 As Integer
End Type
'Necessite DAO Object Library
Global Db As Database, MyTable As Recordset, MySet As Recordset
Global instruction(NbreOrdresMax) As tinstruction
Global position1, position2 As Integer

Global Width_min As Integer
Global Height_min As Integer
Global oldfield As String


' Déclaration de InOut
#If Win32 Then
    Declare Function InByte Lib "INOUT32.DLL" (ByVal address&) As Integer
    Declare Sub OutByte Lib "INOUT32.DLL" (ByVal address&, ByVal Value%)
    Declare Function InpWord Lib "INOUT32.DLL" (ByVal address&) As Long
    Declare Sub OutWord Lib "INOUT32.DLL" (ByVal address&, ByVal Value&)
#Else
    Declare Function InByte Lib "INOUT.DLL" Alias "inp" (ByVal address&) As Integer
    Declare Sub OutByte Lib "INOUT.DLL" Alias "out" (ByVal address&, ByVal Value%)
    Declare Function InpWord Lib "INOUT.DLL" Alias "INPWord" (ByVal address&) As Long
    Declare Sub OutWord Lib "INOUT.DLL" Alias "OUTWord" (ByVal address&, ByVal Value&)
#End If

Sub Main()
CRLF = Chr$(13) + Chr$(10)
ModifConfig = False
ModifFichier = False
Chargement = True
app.Title = "Universal Domotic"
app.HelpFile = app.path + "\domotic.hlp"
If app.PrevInstance Then
  MsgBox "Sorry, you have already launched " + app.Title + ".", 48
  End
End If

Width_min = 9600
Height_min = 8844

If Not Registered Then
    Register.Show
Else
    Domo.Show
End If

End Sub


