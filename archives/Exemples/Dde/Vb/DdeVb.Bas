Attribute VB_Name = "Module1"
Option Explicit

Global hInst As Long


Declare Function DdeInitialize Lib "user32" Alias "DdeInitializeA" (pidInst As Long, ByVal pfnCallback As Long, ByVal afCmd As Long, ByVal ulRes As Long) As Integer
Declare Function DdeCreateStringHandle Lib "user32" Alias "DdeCreateStringHandleA" (ByVal idInst As Long, ByVal psz As String, ByVal iCodePage As Long) As Long
'Declare Function DdeConnect Lib "user32" (ByVal idInst As Long, ByVal hszService As Long, ByVal hszTopic As Long, pCC As CONVCONTEXT) As Long
Declare Function DdePostAdvise Lib "user32" (ByVal idInst As Long, ByVal hszTopic As Long, ByVal hszItem As Long) As Long

Declare Function DdeQueryString Lib "user32" Alias "DdeQueryStringA" (ByVal idInst As Long, ByVal hsz As Long, ByVal psz As String, ByVal cchMax As Long, ByVal iCodePage As Long) As Long

Declare Function DdeDisconnect Lib "user32" (ByVal hConv As Long) As Long
Declare Function DdeUninitialize Lib "user32" (ByVal idInst As Long) As Long

