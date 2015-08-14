// UClient.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "UClient.h"
#include "UClientDlg.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CUClientApp

BEGIN_MESSAGE_MAP(CUClientApp, CWinApp)
	//{{AFX_MSG_MAP(CUClientApp)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CUClientApp construction

CUClientApp::CUClientApp()
{
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CUClientApp object

CUClientApp theApp;

/////////////////////////////////////////////////////////////////////////////
// CUClientApp initialization

BOOL CUClientApp::InitInstance()
{
	if (!AfxSocketInit())
	{
		AfxMessageBox(IDP_SOCKETS_INIT_FAILED);
		return FALSE;
	}

	AfxEnableControlContainer();

	// Standard initialization

#ifdef _AFXDLL
	Enable3dControls();			// Call this when using MFC in a shared DLL
#else
	Enable3dControlsStatic();	// Call this when linking to MFC statically
#endif

	CUClientDlg dlg;
	m_pMainWnd = &dlg;
	dlg.DoModal();

	// Since the dialog has been closed, return FALSE so that we exit the
	//  application, rather than start the application's message pump.
	return FALSE;
}

