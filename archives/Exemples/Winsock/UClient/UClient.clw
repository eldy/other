; CLW file contains information for the MFC ClassWizard

[General Info]
Version=1
LastClass=CUClientDlg
LastTemplate=CDialog
NewFileInclude1=#include "stdafx.h"
NewFileInclude2=#include "UClient.h"

ClassCount=3
Class1=CUClientApp
Class2=CUClientDlg

ResourceCount=4
Resource1=IDR_MENU1
Resource2=IDR_MAINFRAME
Resource3=IDD_UCLIENT_DIALOG
Class3=CAbout
Resource4=IDD_ABOUTBOX

[CLS:CUClientApp]
Type=0
HeaderFile=UClient.h
ImplementationFile=UClient.cpp
Filter=N
LastObject=ID_FILE_EXIT
BaseClass=CWinApp
VirtualFilter=AC

[CLS:CUClientDlg]
Type=0
HeaderFile=UClientDlg.h
ImplementationFile=UClientDlg.cpp
Filter=D
BaseClass=CDialog
VirtualFilter=dWC
LastObject=CUClientDlg

[DLG:IDD_ABOUTBOX]
Type=1
Class=CAbout
ControlCount=3
Control1=IDC_STATIC,static,1342177283
Control2=IDC_PRINT,button,1342242816
Control3=IDC_CANCEL,button,1342242816

[DLG:IDD_UCLIENT_DIALOG]
Type=1
Class=CUClientDlg
ControlCount=19
Control1=IDC_DESTADRESS,edit,1350631552
Control2=IDC_PORT,edit,1350631552
Control3=IDC_SENDDATA,edit,1350631552
Control4=IDC_RECEIVE,listbox,1353711873
Control5=IDC_STATUS_FONC,edit,1350566016
Control6=IDC_STATUS,listbox,1353711873
Control7=IDC_STATIC,static,1342308352
Control8=IDC_SEND,button,1342242817
Control9=IDC_STATIC,static,1342308352
Control10=IDC_STATIC,button,1342177287
Control11=IDC_STATIC,button,1342177287
Control12=IDC_STATIC,button,1342177287
Control13=IDC_PORT_FTP,button,1342242825
Control14=IDC_PORT_PERSO,button,1342373897
Control15=IDC_PORT_WEB,button,1342373897
Control16=IDC_PORT_MAIL,button,1342373897
Control17=IDC_STATIC,button,1342177287
Control18=IDC_STATIC,static,1342177283
Control19=IDC_STATIC,static,1342177793

[MNU:IDR_MENU1]
Type=1
Class=?
Command1=IDM_FILE_EXIT
Command2=IDM_HELP
Command3=IDM_ABOUT
CommandCount=3

[CLS:CAbout]
Type=0
HeaderFile=About.h
ImplementationFile=About.cpp
BaseClass=CDialog
Filter=D
LastObject=CAbout
VirtualFilter=dWC

