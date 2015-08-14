#if !defined(AFX_ABOUT_H__6EA1E184_808A_11D1_8920_8F9F37D58F45__INCLUDED_)
#define AFX_ABOUT_H__6EA1E184_808A_11D1_8920_8F9F37D58F45__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000
// About.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CAbout dialog

class CAbout : public CDialog
{
// Construction
public:
	CAbout(CWnd* pParent = NULL);   // standard constructor

// Dialog Data
	//{{AFX_DATA(CAbout)
	enum { IDD = IDD_ABOUTBOX };
		// NOTE: the ClassWizard will add data members here
	//}}AFX_DATA


// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAbout)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:

	// Generated message map functions
	//{{AFX_MSG(CAbout)
	afx_msg void OnCancel();
	afx_msg void OnPrint();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_ABOUT_H__6EA1E184_808A_11D1_8920_8F9F37D58F45__INCLUDED_)
