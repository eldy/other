// TestvcDlg.cpp : implementation file
//

#include "stdafx.h"
#include "Testvc.h"
#include "TestvcDlg.h"



#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif



HINSTANCE gLibMyDll = NULL;
typedef double (*FONCTIONPUISSANCE)(double,double);
FONCTIONPUISSANCE MyFunction;
//double Puissance(double x,double y);



/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	//}}AFX_DATA

	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CAboutDlg)
	protected:
	virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
	//}}AFX_VIRTUAL

// Implementation
protected:
	//{{AFX_MSG(CAboutDlg)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTestvcDlg dialog

CTestvcDlg::CTestvcDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CTestvcDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CTestvcDlg)
	m_path = _T("");
	//}}AFX_DATA_INIT
	// Note that LoadIcon does not require a subsequent DestroyIcon in Win32
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CTestvcDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CTestvcDlg)
	DDX_Text(pDX, IDC_EDIT1, m_path);
	DDV_MaxChars(pDX, m_path, 256);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CTestvcDlg, CDialog)
	//{{AFX_MSG_MAP(CTestvcDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDOK2, OnOk2)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CTestvcDlg message handlers

BOOL CTestvcDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.

	// IDM_ABOUTBOX must be in the system command range.
	ASSERT((IDM_ABOUTBOX & 0xFFF0) == IDM_ABOUTBOX);
	ASSERT(IDM_ABOUTBOX < 0xF000);

	CMenu* pSysMenu = GetSystemMenu(FALSE);
	CString strAboutMenu;
	strAboutMenu.LoadString(IDS_ABOUTBOX);
	if (!strAboutMenu.IsEmpty())
	{
		pSysMenu->AppendMenu(MF_SEPARATOR);
		pSysMenu->AppendMenu(MF_STRING, IDM_ABOUTBOX, strAboutMenu);
	}

	// Set the icon for this dialog.  The framework does this automatically
	//  when the application's main window is not a dialog
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here
	m_path="d:\\Exemples\\Dll32\\MathDllVc\\Debug\\MathVc.dll";
	UpdateData(FALSE);

	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CTestvcDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUTBOX)
	{
		CAboutDlg dlgAbout;
		dlgAbout.DoModal();
	}
	else
	{
		CDialog::OnSysCommand(nID, lParam);
	}
}

// If you add a minimize button to your dialog, you will need the code below
//  to draw the icon.  For MFC applications using the document/view model,
//  this is automatically done for you by the framework.

void CTestvcDlg::OnPaint() 
{
	if (IsIconic())
	{
		CPaintDC dc(this); // device context for painting

		SendMessage(WM_ICONERASEBKGND, (WPARAM) dc.GetSafeHdc(), 0);

		// Center icon in client rectangle
		int cxIcon = GetSystemMetrics(SM_CXICON);
		int cyIcon = GetSystemMetrics(SM_CYICON);
		CRect rect;
		GetClientRect(&rect);
		int x = (rect.Width() - cxIcon + 1) / 2;
		int y = (rect.Height() - cyIcon + 1) / 2;

		// Draw the icon
		dc.DrawIcon(x, y, m_hIcon);
	}
	else
	{
		CDialog::OnPaint();
	}
}

// The system calls this to obtain the cursor to display while the user drags
//  the minimized window.
HCURSOR CTestvcDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


// Execution de la fonction Puissance de la DLL
void CTestvcDlg::OnOK() 
{
	UpdateData(TRUE);

	if (gLibMyDll != NULL) {
		MessageBox("La DLL a déjà été chargée.");
		return;
	}
	gLibMyDll=LoadLibrary((LPCTSTR) m_path);
	if (gLibMyDll == NULL) {
		MessageBox("Erreur: Echec du chargement de la DLL");
		return;
	}


}

void CTestvcDlg::OnOk2() 
{
	double d=0;
	char s[100];
	UpdateData(TRUE);

	if (gLibMyDll == NULL) {
		MessageBox("Erreur: La DLL n'est pas chargée.");
		return;
	}
	MyFunction=(FONCTIONPUISSANCE) GetProcAddress(gLibMyDll,"Puissance");
	d=MyFunction((double) 5,(double) 2);
	sprintf(s,"%f",d);
	MessageBox(s);
	
}
