VERSION 4.00
Begin VB.Form frmDeptEmp 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dept-Emp Master Detail Form"
   ClientHeight    =   5400
   ClientLeft      =   2355
   ClientTop       =   2235
   ClientWidth     =   6495
   BeginProperty Font 
      name            =   "MS Sans Serif"
      charset         =   0
      weight          =   700
      size            =   8.25
      underline       =   0   'False
      italic          =   0   'False
      strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Height          =   6090
   Left            =   2295
   LinkTopic       =   "Form1"
   ScaleHeight     =   5400
   ScaleWidth      =   6495
   Top             =   1605
   Width           =   6615
   Begin VB.TextBox txtLoc 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2640
      TabIndex        =   18
      Top             =   840
      Width           =   2775
   End
   Begin VB.CommandButton cmdEmpNext 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Next"
      Height          =   495
      Left            =   3600
      TabIndex        =   16
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton cmdEmpLast 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Last"
      Height          =   495
      Left            =   4920
      TabIndex        =   17
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton cmdEmpPrevious 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Previous"
      Height          =   495
      Left            =   1800
      TabIndex        =   15
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton cmdEmpFirst 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "First"
      Height          =   495
      Left            =   480
      TabIndex        =   14
      Top             =   4800
      Width           =   1215
   End
   Begin VB.CommandButton cmdLast 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Last"
      Height          =   495
      Left            =   4920
      TabIndex        =   5
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdFirst 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "First"
      Height          =   495
      Left            =   480
      TabIndex        =   2
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdNext 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Next"
      Height          =   495
      Left            =   3600
      TabIndex        =   4
      Top             =   1200
      Width           =   1215
   End
   Begin VB.CommandButton cmdPrevious 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "Previous"
      Height          =   495
      Left            =   1800
      TabIndex        =   3
      Top             =   1200
      Width           =   1215
   End
   Begin VB.TextBox txtEmpDeptno 
      Appearance      =   0  'Flat
      DataField       =   "deptno"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   13
      Top             =   4440
      Width           =   1215
   End
   Begin VB.TextBox txtDname 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2640
      TabIndex        =   1
      Top             =   480
      Width           =   2775
   End
   Begin VB.TextBox txtDeptno 
      Appearance      =   0  'Flat
      Height          =   285
      Left            =   2640
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
   Begin VB.TextBox txtComm 
      Appearance      =   0  'Flat
      DataField       =   "comm"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   12
      Top             =   4080
      Width           =   1215
   End
   Begin VB.TextBox txtSal 
      Appearance      =   0  'Flat
      DataField       =   "sal"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   11
      Top             =   3720
      Width           =   1215
   End
   Begin VB.TextBox txtHireDate 
      Appearance      =   0  'Flat
      DataField       =   "hiredate"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   10
      Top             =   3360
      Width           =   1215
   End
   Begin VB.TextBox txtMgr 
      Appearance      =   0  'Flat
      DataField       =   "mgr"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   9
      Top             =   3000
      Width           =   1215
   End
   Begin VB.TextBox txtJob 
      Appearance      =   0  'Flat
      DataField       =   "job"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   8
      Top             =   2640
      Width           =   2895
   End
   Begin VB.TextBox txtEname 
      Appearance      =   0  'Flat
      DataField       =   "ename"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   7
      Top             =   2280
      Width           =   2895
   End
   Begin VB.TextBox txtEmpno 
      Appearance      =   0  'Flat
      DataField       =   "empno"
      DataSource      =   "EmpData"
      Height          =   285
      Left            =   2520
      TabIndex        =   6
      Top             =   1920
      Width           =   1215
   End
   Begin VB.Label Label11 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Location:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   1560
      TabIndex        =   29
      Top             =   840
      Width           =   960
   End
   Begin VB.Label Label8 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Department Number:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   330
      TabIndex        =   28
      Top             =   4440
      Width           =   2145
   End
   Begin VB.Line Line1 
      BorderWidth     =   3
      X1              =   120
      X2              =   6360
      Y1              =   1800
      Y2              =   1800
   End
   Begin VB.Label Label10 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Department Name:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   600
      TabIndex        =   27
      Top             =   480
      Width           =   1950
   End
   Begin VB.Label Label9 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Department Number:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   360
      TabIndex        =   26
      Top             =   120
      Width           =   2145
   End
   Begin VB.Label Label7 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Commission:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1080
      TabIndex        =   25
      Top             =   4080
      Width           =   1335
   End
   Begin VB.Label Label6 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Salary:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1560
      TabIndex        =   24
      Top             =   3720
      Width           =   855
   End
   Begin VB.Label Label5 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Hire Date:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1320
      TabIndex        =   23
      Top             =   3360
      Width           =   1095
   End
   Begin VB.Label Label4 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Manager:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   240
      Left            =   1440
      TabIndex        =   22
      Top             =   3000
      Width           =   990
   End
   Begin VB.Label Label3 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Job:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   1920
      TabIndex        =   21
      Top             =   2640
      Width           =   495
   End
   Begin VB.Label Label2 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Employee Name:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   600
      TabIndex        =   20
      Top             =   2280
      Width           =   1815
   End
   Begin VB.Label Label1 
      Alignment       =   1  'Right Justify
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      Caption         =   "Employee Number:"
      BeginProperty Font 
         name            =   "MS Sans Serif"
         charset         =   0
         weight          =   700
         size            =   9.75
         underline       =   0   'False
         italic          =   0   'False
         strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   255
      Left            =   360
      TabIndex        =   19
      Top             =   1920
      Width           =   2055
   End
   Begin VB.Menu mExit 
      Caption         =   "E&xit!"
   End
End
Attribute VB_Name = "frmDeptEmp"
Attribute VB_Creatable = False
Attribute VB_Exposed = False

Private Sub cmdEmpFirst_Click()

 EmpDynaset.DbMoveFirst
 Call EmpRefresh

End Sub

Private Sub cmdEmpLast_Click()

 EmpDynaset.DbMoveLast

 Call EmpRefresh

End Sub

Private Sub cmdEmpNext_Click()

 If EmpDynaset.EOF <> True Then
  EmpDynaset.DbMoveNext
  If EmpDynaset.EOF = True Then
   MsgBox WarnLastEmp$
   EmpDynaset.DbMoveLast
  End If
 End If

 Call EmpRefresh

End Sub

Private Sub cmdEmpPrevious_Click()

 If EmpDynaset.BOF <> True Then
  EmpDynaset.DbMovePrevious
  If EmpDynaset.BOF = True Then
   MsgBox WarnFirstEmp$
   EmpDynaset.DbMoveFirst
  End If
 End If

 Call EmpRefresh

End Sub

Private Sub cmdFirst_Click()

 DeptDynaset.DbMoveFirst

 Call DeptRefresh

End Sub

Private Sub cmdLast_Click()

 DeptDynaset.DbMoveLast

 Call DeptRefresh

End Sub

Private Sub cmdNext_Click()

 If DeptDynaset.EOF = True Then
  MsgBox WarnLastDept$
  DeptDynaset.DbMoveLast
 Else
  DeptDynaset.DbMoveNext
  Call DeptRefresh
 End If

End Sub

Private Sub cmdPrevious_Click()

 If DeptDynaset.BOF <> True Then
  DeptDynaset.DbMovePrevious
  If DeptDynaset.BOF = True Then
   MsgBox WarnFirstDept$
   DeptDynaset.DbMoveFirst
  End If
 End If
  
 Call DeptRefresh

End Sub

Private Sub DeptRefresh()

 If DeptDynaset.BOF <> True And DeptDynaset.EOF <> True Then

  txtDeptno = DeptDynaset.Fields("deptno").Value
  txtDname = DeptDynaset.Fields("dname").Value
  txtLoc = DeptDynaset.Fields("loc").Value

  Call EmpDynasetRefresh

 End If

End Sub

Private Sub EmpDynasetRefresh()

  'Only need to refresh the dynaset since we are using
  'a SQL parameter.
  OraDatabase.Parameters("deptno").Value = DeptDynaset.Fields("deptno").Value
  EmpDynaset.DbRefresh
  EmpDynaset.DbMoveFirst

End Sub

Private Sub EmpRefresh()

 If EmpDynaset.EOF <> True And EmpDynaset.BOF <> True Then

  txtEmpno = EmpDynaset.Fields("empno").Value
  txtEname = EmpDynaset.Fields("ename").Value
  txtJob = EmpDynaset.Fields("job").Value

  'check if mgr=nul
  If Not IsNull(EmpDynaset.Fields("mgr").Value) Then
   txtMgr = EmpDynaset.Fields("mgr").Value
  Else
   txtMgr = ""
  End If

  txtHireDate = EmpDynaset.Fields("hiredate").Value
  txtSal = EmpDynaset.Fields("sal").Value

  'check if comm=nul
  If Not IsNull(EmpDynaset.Fields("comm").Value) Then
   txtComm = EmpDynaset.Fields("comm").Value
  Else
   txtComm = ""
  End If

  txtEmpDeptno = EmpDynaset.Fields("deptno").Value

 Else
  txtEmpno = ""
  txtEname = ""
  txtJob = ""
  txtMgr = ""
  txtHireDate = ""
  txtSal = ""
  txtComm = ""
  txtEmpDeptno = ""

 End If

End Sub

Private Sub Form_Load()

'Session and Database are declared global in deptoip.bas
 Set OraSession = CreateObject("OracleInProcServer.XOraSession")
 Set OraDatabase = OraSession.OpenDatabase(DatabaseName$, Connect$, 0&)

 'Add the deptno param for input
 OraDatabase.Parameters.Add "deptno", 0, 1
 
 'Create the inital EmpDynaset
 Set EmpDynaset = OraDatabase.DbCreateDynaset(EmpQuery$, 0&)

 'Create the actual DeptDynaset
 Set DeptDynaset = OraDatabase.DbCreateDynaset(DeptQuery$, 0&)
 Call DeptRefresh

 Call EmpRefresh

End Sub

Private Sub mExit_Click()
 End
End Sub

