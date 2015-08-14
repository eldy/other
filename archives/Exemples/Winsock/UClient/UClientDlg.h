// UClientDlg.h : header file
//

#if !defined(AFX_UCLIENTDLG_H__FB1FAD78_5EAF_11D1_891F_00403399D996__INCLUDED_)
#define AFX_UCLIENTDLG_H__FB1FAD78_5EAF_11D1_891F_00403399D996__INCLUDED_

#if _MSC_VER >= 1000
#pragma once
#endif // _MSC_VER >= 1000

/////////////////////////////////////////////////////////////////////////////
// CUClientDlg dialog

class CUClientDlg : public CDialog
{
// Construction
public:
	CUClientDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CUClientDlg)
	enum { IDD = IDD_UCLIENT_DIALOG };
	CEdit	m_cport;
	CButton	m_port_web;
	CButton	m_port_mail;
	CButton	m_port_perso;
	CButton	m_port_ftp;
	CListBox	m_lStatus;
	CEdit	m_send_string;
	CButton	m_bsend;
	CListBox	m_lreceive;
	CString	m_server_address;
	int		m_server_port;
	CString	m_csend_string;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CUClientDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	virtual LRESULT DefWindowProc(UINT message, WPARAM wParam, LPARAM lParam);
	virtual BOOL OnCommand(WPARAM wParam, LPARAM lParam);
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;
	void ShowStatus(CString Msg);

	// Generated message map functions
	//{{AFX_MSG(CUClientDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	afx_msg void OnSend();
	afx_msg void OnDestroy();
	afx_msg void OnPortFtp();
	afx_msg void OnPortWeb();
	afx_msg void OnPortMail();
	afx_msg void OnPortPerso();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

//{{AFX_INSERT_LOCATION}}
// Microsoft Developer Studio will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_UCLIENTDLG_H__FB1FAD78_5EAF_11D1_891F_00403399D996__INCLUDED_)
