'Global objects
Global OraSession As Object
Global OraDatabase As Object
Global EmpDynaset As Object
Global DeptDynaset As Object

'Connection info and SELECT statements.
Global Const Connect$ = "scott/tiger"
Global Const DatabaseName$ = "ExampleDb"
Global Const DeptQuery$ = "select * from dept"
Global Const EmpQuery$ = "select * from emp where deptno = :deptno"

Global Const WarnFirstDept$ = "You are already on the first department."
Global Const WarnLastDept$ = "You are already on the last department."
Global Const WarnFirstEmp$ = "You are already on the first employee."
Global Const WarnLastEmp$ = "You are already on the last employee."

