// UClient.h : main header file for the UCLIENT application
//

#if !defined(AFX_UCLIENT_H__FB1FAD76_5EAF_11D1_891F_00403399D996__INCLUDED_)
#define AFX_UCLIENT_H__FB1FAD76_5EAF_11D1_891F_00403399D996__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols



#define NomLogiciel "Universal Client"
#define DEFAULT_FTP_PORT	21
#define DEFAULT_WEB_PORT	0
#define DEFAULT_EMAIL_PORT	0







/////////////////////////////////////////////////////////////////////////////
// CUClientApp:
// See UClient.cpp for the implementation of this class
//

class CUClientApp : public CWinApp
{
public:
	CUClientApp();

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CUClientApp)
	public:
	virtual BOOL InitInstance();
	//}}AFX_VIRTUAL

// Implementation

	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_UCLIENT_H__FB1FAD76_5EAF_11D1_891F_00403399D996__INCLUDED_)
