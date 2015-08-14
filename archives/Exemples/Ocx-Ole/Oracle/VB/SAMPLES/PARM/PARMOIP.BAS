
'Global objects
Global OraSession As Object
Global OraDatabase As Object
Global EmpDynaset As Object

' Not required to be constant.
Global Const EmpQuery$ = "select * from emp where job=:job"
Global Const DatabaseName$ = "ExampleDb"
Global Const Connect$ = "scott/tiger"

Global Const WarnFirstEmp$ = "You are already on the first employee."
Global Const WarnLastEmp$ = "You are already on the last employee."



