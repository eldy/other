/**********************************************************************/
/*                       W S S E R V E R . C                          */
/*--------------------------------------------------------------------*/
/* Fonction: Impl�mentation d'un serveur d'�cho sous TCP/IP           */
/*--------------------------------------------------------------------*/
/* Auteurs:       Michael Tischer et Bruno Jennrich                   */
/* d�velopp� le : 1.4.97                                              */
/**********************************************************************/
#include <winsock.h>                        // inclut �galement windows.h 
#include "resource.h"           // constantes pour zones de dialogue

#include <stdio.h>

#define MAX_CONNECTIONS 20               // max. 20 clients simultan�s
#define SERVER_PORT 5001                // num�ro de port arbitraire

SOCKET gsListen;                          //  Socket � l'�coute des clients
SOCKET gsAccepted[ MAX_CONNECTIONS ];     // connexions prises en charge

#define WM_LISTEN     (WM_USER + 1)    // messages de la Socket � l'�coute
#define WM_CONNECTION (WM_USER + 2)      // messages de la connexion

#define WM_ASYNCGETHOSTBYNAME (WM_USER+1023)
char HostentBuffer[ MAXGETHOSTSTRUCT ];
HANDLE hAsync = NULL;

/**********************************************************************/
/* ShowStatus: Ecrit un message de statut dans la zone de liste       */
/*--------------------------------------------------------------------*/
/* Param�tres:    hDlg  - handle de la bo�te de dialogue              */
/*               lpMsg -  message � afficher                          */
/* Valeur renvoy�e: n�ant                                             */
/**********************************************************************/
void ShowStatus(HWND hDlg, LPSTR lpMsg)
{
  int iEntries;
  SendMessage(GetDlgItem(hDlg, IDC_STATUS), 
               LB_ADDSTRING, 
               (WPARAM)-1, 
               (LPARAM)lpMsg);

  // affiche le dernier �l�ment ajout�
  iEntries = SendMessage(GetDlgItem(hDlg, IDC_STATUS), 
               LB_GETCOUNT,
               0,                 
               0);
  SendMessage(GetDlgItem(hDlg, IDC_STATUS), 
               LB_SETTOPINDEX,
               iEntries-1,            
               0);
}


/**********************************************************************/
/* WSServerProc: Proc�dure de fen�tre principale                      */
/*--------------------------------------------------------------------*/
/* Param�tres: Standard pour bo�te de dialogue                        */
/* Valeur renvoy�e: d�pend du message                                 */
/**********************************************************************/
BOOL WINAPI WSServerProc(HWND hDlg, UINT msg, LPARAM wP, WPARAM lP)
{
  switch(msg)
  {
    case WM_ASYNCGETHOSTBYNAME:
    {
      hAsync = NULL; // op�ration asynchrone termin�e 
      if(!WSAGETASYNCERROR(lP))
      {
        if(WSAGETASYNCBUFLEN(lP) >= sizeof(HOSTENT))
        {
          HOSTENT *he = (HOSTENT*) HostentBuffer;
          DWORD IPAdress = *(DWORD*)(he->h_addr);
        }
      }
    }
    break;

    // Initialisation de la bo�te de dialogue------------------------------
    case WM_INITDIALOG: 
    {
      int i;
      SOCKADDR_IN sin;
    
      hAsync = WSAAsyncGetHostByName(hDlg, 
                                  WM_ASYNCGETHOSTBYNAME, 
                                  "netscape.com", 
                                  HostentBuffer, 
                                  sizeof(HostentBuffer));
      if(!hAsync)
      {
        // Erreur
      }

      // Initialise le tableau global des Sockets (= pas de connexion) 
      for( i = 0; i < MAX_CONNECTIONS; i++ ) 
        gsAccepted[i] = INVALID_SOCKET; 
            
      // Cr�e la Socket pour Listen()--------------------------------
      ShowStatus( hDlg, "socket()" );
      gsListen = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );      
     
      if( gsListen != INVALID_SOCKET )           // Erreur � l'appel de Socket()?
      {
        // D�finit les notifications de la Socket. La Socket est
        // mise en mode non bloquant par WSAAsyncSelect()
        ShowStatus( hDlg, "WSAAsyncSelect()" );      
        if( WSAAsyncSelect(gsListen,hDlg,WM_LISTEN,FD_ACCEPT)  
           != SOCKET_ERROR)
        {  
          // Pr�pare une structure d'adresse. Toutes les demandes de connexion
          // seront prises en compte
          memset( &sin, 0, sizeof( sin ) );
          sin.sin_family = AF_INET;
          sin.sin_port = htons( SERVER_PORT );     
          sin.sin_addr.s_addr = INADDR_ANY;

          // Associe une adresse � la Socket
          ShowStatus( hDlg, "bind()" );
          if(bind(gsListen,(SOCKADDR *)&sin,sizeof(sin))!=SOCKET_ERROR)
          {
            // Association r�ussie, on se met � l'�coute
            //  du port 
            ShowStatus( hDlg, "listen()" );
            if( listen( gsListen, SOMAXCONN ) != SOCKET_ERROR )
            {
              ShowStatus( hDlg, "Attente..." );
              return TRUE;
            }
            else ShowStatus(hDlg, "Erreur � l'appel de listen()");
          }
          else ShowStatus(hDlg, "Erreur � l'appel de bind()");
        }
        else ShowStatus(hDlg, "Erreur � l'appel de WSAAsnycSelect()");
      }
      else ShowStatus(hDlg, "Erreur � l'appel de Socket()");

      // Erreur de cr�ation de la Socket
      if( gsListen != INVALID_SOCKET )
      {
        ShowStatus( hDlg, "closesocket()" );
        closesocket( gsListen );
      }
      ShowStatus(hDlg, "Connexion impossible");
      ShowStatus(hDlg, "V�rifiez votre configuration ");
      ShowStatus(hDlg, "et relancez le serveur !");
      MessageBeep( 0 );
      return TRUE;
    }
    break;
    case WM_LISTEN:  // Traite le message de la Socket � l'�coute
    {
      switch(WSAGETSELECTEVENT(lP))        // Quel message?
      {
        case FD_ACCEPT:                     // Demande de connexion
        {
          SOCKET s;
          SOCKADDR_IN addr_accept;
          int iLen = sizeof(addr_accept);

          ShowStatus(hDlg, "FD_ACCEPT");    

          ShowStatus(hDlg, "accept()");    // Prend en charge la connexion
          
          // ...dans tous les cas !
          s = accept(gsListen, (SOCKADDR *) &addr_accept, &iLen);
          if(s == INVALID_SOCKET) 
            ShowStatus(hDlg, "Erreur � l'appel d'accept()");
          else
          {
            int i;
            // Cherche une Socket libre ---------------------------------
            for(i = 0; i < MAX_CONNECTIONS; i++)
            {
              if(gsAccepted[i] == INVALID_SOCKET)
              {
                char Buffer[ 80 ];
                
                gsAccepted[ i ] = s; // m�morise la connexion

                wsprintf(Buffer, // affiche l'adresse du client
                          "(%d) connect� � 0x%08lx, port n� : %5d", 
                          i, 
                          ntohl(addr_accept.sin_addr.s_addr), 
                          ntohs(addr_accept.sin_port));
                ShowStatus(hDlg, Buffer);

                // La Socket de prise en charge
                // a les m�mes attributs que la Socket � l'�coute
                // et g�re notamment les m�mes messages. Mais ceux-ci
                // doivent �tre modifi�s pour que la Socket connect�e
                // ne re�oive plus de notification FD_ACCEPT
                // tout en r�agissant � READ/CLOSE

                WSAAsyncSelect( s, 
                                hDlg,
                                WM_CONNECTION, 
                                FD_READ | FD_CLOSE );
                return 0;                                      // Termin�
              }
            }

            ShowStatus( hDlg, "Il n'y a plus de Socket disponible !" );
            closesocket( s );
          }
        }
        break;
      }
    }
    break;
    case WM_CONNECTION:
    {
      char Buffer[ 80 ];          // Tampon d'affichage pour zone de liste
      int iAccept;                // Indice de la Socket dans le tableau
      SOCKET actSocket;
      int i;
      
      actSocket = (SOCKET)wP;         // Socket renseign�e par WPARAM

      iAccept = -1;
      for(i = 0; i < MAX_CONNECTIONS; i++)
        if(gsAccepted[i] == actSocket)
        {
          iAccept = i;
          break;
        }

      switch(WSAGETSELECTEVENT(lP))        // Quel message ?
      {
        case FD_READ:                    // Le client envoie des donn�es
        {
          char readbytes[ 255 ];
          char sendbytes[ 512 ];
      
          int iReadLen;
          int i, j;

          wsprintf(Buffer, "FD_READ(%d)", iAccept);
          ShowStatus(hDlg, Buffer);

          iReadLen = recv(actSocket,               // Lecture des donn�es
                          readbytes,
                          sizeof(readbytes), 
                          0);
  
          if(iReadLen > 0)
          {
            wsprintf(Buffer, "echo-send(%d)", iAccept);
            ShowStatus(hDlg, Buffer);

            // Convertit la cha�ne re�ue en majuscules -----
            j = 0;
            for( i = 0; i < iReadLen; i++ )
            {
                sendbytes[j++] = toupper(readbytes[ i ]);
			}

            if( send( actSocket,
                      sendbytes, 
                      j, 
                      0 ) == SOCKET_ERROR )
              ShowStatus(hDlg, "Erreur dans re-send()");
          }
          else ShowStatus(hDlg, "Erreur dans recv()");

          wsprintf(Buffer, "closeSocket(%d)", iAccept);
         ShowStatus( hDlg, Buffer );
          closesocket( actSocket );

          // Neutralise la Socket dans le tableau
          gsAccepted[ iAccept ] = INVALID_SOCKET;
        }
        break;
        case FD_CLOSE:                   // le client cl�ture la liaison
          wsprintf( Buffer, "FD_CLOSE(%d)", iAccept );
          ShowStatus( hDlg, Buffer );

          wsprintf( Buffer, "closesocket(%d)", iAccept );
          ShowStatus( hDlg, Buffer );

          closesocket( gsAccepted[ iAccept ] ); // cl�ture la Socket
          gsAccepted[ iAccept ]=INVALID_SOCKET; // et la rend r�utilisable
        break;
      }
    }
    break;
    case WM_COMMAND:                    // message de bouton de commande
      switch(LOWORD(wP)) 
      {
        case IDCANCEL:                           // Annulation du dialogue
          EndDialog(hDlg, 0);
        break;
      }
    break;
    case WM_DESTROY:                           // Fermeture de la fen�tre
    {
      int i;

      // En cas de fin pr�matur�e de l'application
      // il faut interrompre les op�rations asynchrones
      // qui pourraient �tre en cours
      if( hAsync )
        WSACancelAsyncRequest( hAsync );

      // Cl�ture les Sockets ouvertes. D�clenche le message
      // FD_CLOSE chez le correspondant
      if( gsListen != INVALID_SOCKET ) closesocket( gsListen );

      for( i = 0; i < MAX_CONNECTIONS; i++ )    // Fin des clients
        if( gsAccepted[i] != INVALID_SOCKET )
           closesocket( gsAccepted[i] );
    }
    break;
  }

  return FALSE;
}

/**********************************************************************/
/* WinMain: Point d'entr�e principal                                  */
/*--------------------------------------------------------------------*/
/* Param�tres:    standard                                            */
/* Valeur renvoy�e: 0                                                 */
/**********************************************************************/
int WINAPI WinMain(HINSTANCE hInstance, 
                   HINSTANCE hPrevInstance, 
                   LPSTR     lpCmdLine,
                   int       nShowCmd)
{
  WSADATA wsadata;

  // Utilise la version 1.1 de la DLL Winsock
  if(WSAStartup(MAKEWORD(1,1), &wsadata) == 0)
  {
    DialogBox(hInstance,                   // Affiche la bo�te de dialogue
               MAKEINTRESOURCE(IDD_WSSERVER), 
               NULL, 
               WSServerProc);
    WSACleanup();                              // Nettoyage final
  }
  else MessageBox(0, 
                  "Erreur � l'initialisation de WINSOCK",
                  "WSServer.EXE", 
                  0);
  return 0;
}


