Attribute VB_Name = "INOUT"
' Global file for INOUT
' Note that INOUT.DLL must be accessible, either in
' the current directory, or in a directory in your path statement.
Declare Function inp Lib "d:\prog\dll'\INOUT.DLL" (ByVal address&) As Integer
Declare Sub out Lib "d:\prog\dll'\INOUT.DLL" (ByVal address&, ByVal value%)
Declare Function INPWord Lib "d:\prog\dll'\INOUT.DLL" (ByVal address&) As Long
Declare Sub OUTWord Lib "d:\prog\dll'\INOUT.DLL" (ByVal address&, ByVal value&)

