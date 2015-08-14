// TestvcDlg.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CTestvcDlg dialog

class CTestvcDlg : public CDialog
{
// Construction
public:
	CTestvcDlg(CWnd* pParent = NULL);	// standard constructor

// Dialog Data
	//{{AFX_DATA(CTestvcDlg)
	enum { IDD = IDD_TESTVC_DIALOG };
	CString	m_path;
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CTestvcDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	HICON m_hIcon;

	// Generated message map functions
	//{{AFX_MSG(CTestvcDlg)
	virtual BOOL OnInitDialog();
	afx_msg void OnSysCommand(UINT nID, LPARAM lParam);
	afx_msg void OnPaint();
	afx_msg HCURSOR OnQueryDragIcon();
	virtual void OnOK();
	afx_msg void OnOk2();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
