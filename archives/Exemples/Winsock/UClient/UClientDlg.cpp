// UClientDlg.cpp : implementation file
//

#include "stdafx.h"
#include "UClient.h"
#include "UClientDlg.h"
#include "About.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#undef THIS_FILE
static char THIS_FILE[] = __FILE__;
#endif

#include <winsock.h>                // inclut aussi windows.h !
#define WM_SOCKET (WM_USER + 1)		// messages de la Socket
SOCKET gsConnect = INVALID_SOCKET;	// Socket qui assure la liaison
									// avec le serveur



/**********************************************************************/
/* ShowStatus: Ecrit un message de statut dans la zone de liste       */
/*--------------------------------------------------------------------*/
/* Paramètres:    hDlg  - handle de la boîte de dialogue              */
/*                lpMsg - message à afficher                          */
/* Valeur renvoyée: néant                                             */
/**********************************************************************/
void CUClientDlg::ShowStatus(CString Msg)
{
  int iEntries;
  // Ajoute un élément
  m_lStatus.AddString(Msg);
  // Affiche le dernier élément
  iEntries=m_lStatus.GetCount();
  m_lStatus.SetTopIndex(iEntries-1);
}




/////////////////////////////////////////////////////////////////////////////
// CUClientDlg dialog

CUClientDlg::CUClientDlg(CWnd* pParent /*=NULL*/)
	: CDialog(CUClientDlg::IDD, pParent)
{
	//{{AFX_DATA_INIT(CUClientDlg)
	m_server_address = _T("");
	m_server_port = 0;
	m_csend_string = _T("");
	//}}AFX_DATA_INIT
	m_hIcon = AfxGetApp()->LoadIcon(IDR_MAINFRAME);
}

void CUClientDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CUClientDlg)
	DDX_Control(pDX, IDC_PORT, m_cport);
	DDX_Control(pDX, IDC_PORT_WEB, m_port_web);
	DDX_Control(pDX, IDC_PORT_MAIL, m_port_mail);
	DDX_Control(pDX, IDC_PORT_PERSO, m_port_perso);
	DDX_Control(pDX, IDC_PORT_FTP, m_port_ftp);
	DDX_Control(pDX, IDC_STATUS, m_lStatus);
	DDX_Control(pDX, IDC_SENDDATA, m_send_string);
	DDX_Control(pDX, IDC_SEND, m_bsend);
	DDX_Control(pDX, IDC_RECEIVE, m_lreceive);
	DDX_Text(pDX, IDC_DESTADRESS, m_server_address);
	DDX_Text(pDX, IDC_PORT, m_server_port);
	DDV_MinMaxInt(pDX, m_server_port, 1, 9999);
	DDX_Text(pDX, IDC_SENDDATA, m_csend_string);
	DDV_MaxChars(pDX, m_csend_string, 50);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CUClientDlg, CDialog)
	//{{AFX_MSG_MAP(CUClientDlg)
	ON_WM_SYSCOMMAND()
	ON_WM_PAINT()
	ON_WM_QUERYDRAGICON()
	ON_BN_CLICKED(IDC_SEND, OnSend)
	ON_WM_DESTROY()
	ON_BN_CLICKED(IDC_PORT_FTP, OnPortFtp)
	ON_BN_CLICKED(IDC_PORT_WEB, OnPortWeb)
	ON_BN_CLICKED(IDC_PORT_MAIL, OnPortMail)
	ON_BN_CLICKED(IDC_PORT_PERSO, OnPortPerso)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CUClientDlg message handlers

BOOL CUClientDlg::OnInitDialog()
{
	CDialog::OnInitDialog();

	// Add "About..." menu item to system menu.
	SetIcon(m_hIcon, TRUE);			// Set big icon
	SetIcon(m_hIcon, FALSE);		// Set small icon
	
	// TODO: Add extra initialization here

	//********** Initialisation dialogue
	m_port_ftp.SetCheck(1);

	//********** Initialisation socket
	// Utilise la version 1.1 de la DLL Winsock
	WSADATA wsadata;
	if (WSAStartup(MAKEWORD(1,1), &wsadata))
	{
		MessageBox("Erreur à l'initialisation de WINSOCK.DLL",NomLogiciel,0);
		return(TRUE);
	}
	m_server_address = "localhost";
	m_server_port=DEFAULT_FTP_PORT;
	m_cport.SetReadOnly(TRUE);
	UpdateData(FALSE);
	
	return TRUE;  // return TRUE  unless you set the focus to a control
}

void CUClientDlg::OnSysCommand(UINT nID, LPARAM lParam)
{
	if ((nID & 0xFFF0) == IDM_ABOUT)
	{
		CAbout dlgAbout;
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

void CUClientDlg::OnPaint() 
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


HCURSOR CUClientDlg::OnQueryDragIcon()
{
	return (HCURSOR) m_hIcon;
}


LRESULT CUClientDlg::DefWindowProc(UINT message, WPARAM wParam, LPARAM lParam) 
{
	// TODO: Add your specialized code here and/or call the base class
  switch(message)
  {
   case WM_SOCKET:  // Exploite les messages de la Socket
    {          
      switch( WSAGETSELECTEVENT(lParam) )
      {
        case FD_CONNECT:                      // En provenance de connect()
		  ShowStatus( "FD_CONNECT" );    
          if( WSAGETSELECTERROR(lParam) == 0 )                // Tout va bien ?
			  m_bsend.EnableWindow(FALSE);
          else  
          {
            closesocket( gsConnect );
            gsConnect = INVALID_SOCKET;
            ShowStatus("Absence de serveur !" );    
            m_bsend.EnableWindow(TRUE);
          }
        break;
        case FD_READ:            // Données arrivées (Echo de Server)?
        {
          char readbytes[ 255 ];
          int iReadLen;

          // Lit les données et les affiche en zone de liste
          ShowStatus("FD_READ");    
          // Lecture de l'ensemble des données
          iReadLen = recv(gsConnect,readbytes,sizeof(readbytes)-1,0);
          if(iReadLen > 0)
          {
            readbytes[ iReadLen ] = 0;
            m_lreceive.AddString(readbytes);
          }
        }
        break;
        case FD_WRITE:                      // Socket prête à émettre ?
        {
		  UpdateData(TRUE);
 		  // Notification envoyée après établissement réussi de la connexion
          // ou lorsque les dernières données envoyées par send() sont arrivées
          // à destination
          ShowStatus("FD_WRITE" );    
          // send() renvoie une erreur en cas de blocage.
          // WSAGetLastError() retourne alors le code
          // WSAEWOULDBLOCK.
          ShowStatus("send()..." );    
          if( send( gsConnect, m_csend_string, m_csend_string.GetLength(), 0 ) != SOCKET_ERROR )
          {
            ShowStatus("... terminé" );    
            m_bsend.EnableWindow(TRUE);
          }
          else 
          {
            // Et voici l'événement "imprévu" qui du côté du serveur
            // conduit au déclenchement de FD_CLOSE
            if( WSAGetLastError() == WSAEWOULDBLOCK )
              ShowStatus("... bloqué" ); 
            else
              ShowStatus("Erreur à l'appel de send()" ); 
            
            ShowStatus("closesocket()" ); 
            m_bsend.EnableWindow( TRUE );
            closesocket( gsConnect );
            gsConnect = INVALID_SOCKET;
            ShowStatus("Interruption" ); 
          }
        }
        break;
        case FD_CLOSE:                  // Le serveur a coupé la communication
          ShowStatus("FD_CLOSE" );    
          m_bsend.EnableWindow(TRUE);
          closesocket( gsConnect );
          gsConnect = INVALID_SOCKET;
        break;
      }
    }
    break;
 
  }	
	
	return CDialog::DefWindowProc(message, wParam, lParam);
}

void CUClientDlg::OnSend() 
{
	// TODO: Add your control notification handler code here
          SOCKADDR_IN sin;            
          char Buffer[80];        // Tampon d'affichage pour zone de liste

		  UpdateData(TRUE);

          memset( &sin, 0, sizeof( sin ) );
    
          sin.sin_family = AF_INET;
          sin.sin_port = htons( m_server_port );     
          
          ShowStatus("inet_addr()" );

          // Conversion d'une adresse à points
          sin.sin_addr.s_addr = inet_addr( m_server_address);

          // Si erreur de conversion, tentative de résolution de l'adresse par DNS
          if( sin.sin_addr.s_addr == INADDR_NONE ) 
          {
            HOSTENT *he;
            ShowStatus( "gethostbyname()" );
            he = gethostbyname( m_server_address );
            if( he )
              sin.sin_addr.s_addr = *((DWORD*)he->h_addr);
            else
            {
              ShowStatus("Adresse Internet invalide" );
              return;
            }
          }

          // Affiche l'adresse de destination
          wsprintf( Buffer, "Adresse: 0x%08lx", 
                    ntohl( sin.sin_addr.s_addr ) );
          ShowStatus( Buffer );

          // Crée la Socket
          ShowStatus("socket()" );
          gsConnect = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );
      
          if( gsConnect == INVALID_SOCKET )
          {
            ShowStatus("Erreur à l'allocation de la Socket" );
            ShowStatus("Liaison impossible" );
            return;
          }
  
          // Prépare la Socket aux opérations asynchrones
          // et fixe les messages gérés

          ShowStatus("WSAAsyncSelect()" );
          if( WSAAsyncSelect( gsConnect, 
                              m_hWnd, 
                              WM_SOCKET, 
                              FD_CONNECT | 
                              FD_READ | 
                              FD_WRITE | 
                              FD_CLOSE) == 0 )
          {
            // La Socket n'est pas explicitement reliée à une adresse locale.
            // L'association est effectuée automatiquement
            // par connect().
            ShowStatus("connect()" );
            if( connect(gsConnect,(SOCKADDR*)&sin,sizeof(sin))==SOCKET_ERROR)
            {
              if( WSAGetLastError() == WSAEWOULDBLOCK )
              {
                ShowStatus("Attente..." );

                // Neutralise le bouton d'émission
                m_bsend.EnableWindow(FALSE);
                return;
              }
            }
          }
          else 
            ShowStatus("Erreur à l'appel de WSAAsyncSelect()" );

          ShowStatus( "closesocket()" );
          closesocket( gsConnect );
          gsConnect = INVALID_SOCKET;
}


void CUClientDlg::OnDestroy() 
{
	CDialog::OnDestroy();
	
	// TODO: Add your message handler code here
    if( gsConnect != INVALID_SOCKET )           // Clôture de la Socket
        closesocket( gsConnect );

    WSACleanup();                               // Nettoyage final
	
}

void CUClientDlg::OnPortFtp() 
{
	// TODO: Add your control notification handler code here
	m_server_port=DEFAULT_FTP_PORT;
	m_cport.SetReadOnly(TRUE);
	m_port_web.SetCheck(0);
	m_port_mail.SetCheck(0);
	m_port_perso.SetCheck(0);
	UpdateData(FALSE);
}

void CUClientDlg::OnPortWeb() 
{
	// TODO: Add your control notification handler code here
	m_server_port=DEFAULT_WEB_PORT;
	m_cport.SetReadOnly(TRUE);
	m_port_mail.SetCheck(0);
	m_port_ftp.SetCheck(0);
	m_port_perso.SetCheck(0);
	UpdateData(FALSE);
}

void CUClientDlg::OnPortMail() 
{
	// TODO: Add your control notification handler code here
	m_server_port=DEFAULT_EMAIL_PORT;
	m_cport.SetReadOnly(TRUE);
	m_port_web.SetCheck(0);
	m_port_ftp.SetCheck(0);
	m_port_perso.SetCheck(0);
	UpdateData(FALSE);
}

void CUClientDlg::OnPortPerso() 
{
	// TODO: Add your control notification handler code here
	m_cport.SetReadOnly(FALSE);
	m_port_web.SetCheck(0);
	m_port_ftp.SetCheck(0);
	m_port_mail.SetCheck(0);
}


BOOL CUClientDlg::OnCommand(WPARAM wParam, LPARAM lParam) 
{
	// TODO: Add your specialized code here and/or call the base class
	CAbout AboutDlg;
	switch(wParam) {
		case IDM_ABOUT:
			AboutDlg.DoModal();
			break;
		case IDM_HELP:
			break;
		case IDM_FILE_EXIT:
			EndDialog(0);
			break;
		}

	return CDialog::OnCommand(wParam, lParam);
}
