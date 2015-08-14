/**********************************************************************/
/*                       W S S E R V E R . C                          */
/*--------------------------------------------------------------------*/
/* Fonction: Implémentation d'un serveur d'écho sous TCP/IP           */
/*--------------------------------------------------------------------*/
/* Auteurs:       Michael Tischer et Bruno Jennrich                   */
/* développé le : 1.4.97                                              */
/**********************************************************************/
#include <winsock.h>                        // inclut également windows.h 
#include "resource.h"           // constantes pour zones de dialogue

#include <stdio.h>

#define MAX_CONNECTIONS 20               // max. 20 clients simultanés
#define SERVER_PORT 5001                // numéro de port arbitraire

SOCKET gsListen;                          //  Socket à l'écoute des clients
SOCKET gsAccepted[ MAX_CONNECTIONS ];     // connexions prises en charge

#define WM_LISTEN     (WM_USER + 1)    // messages de la Socket à l'écoute
#define WM_CONNECTION (WM_USER + 2)      // messages de la connexion

#define WM_ASYNCGETHOSTBYNAME (WM_USER+1023)
char HostentBuffer[ MAXGETHOSTSTRUCT ];
HANDLE hAsync = NULL;

/**********************************************************************/
/* ShowStatus: Ecrit un message de statut dans la zone de liste       */
/*--------------------------------------------------------------------*/
/* Paramètres:    hDlg  - handle de la boîte de dialogue              */
/*               lpMsg -  message à afficher                          */
/* Valeur renvoyée: néant                                             */
/**********************************************************************/
void ShowStatus(HWND hDlg, LPSTR lpMsg)
{
  int iEntries;
  SendMessage(GetDlgItem(hDlg, IDC_STATUS), 
               LB_ADDSTRING, 
               (WPARAM)-1, 
               (LPARAM)lpMsg);

  // affiche le dernier élément ajouté
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
/* WSServerProc: Procédure de fenêtre principale                      */
/*--------------------------------------------------------------------*/
/* Paramètres: Standard pour boîte de dialogue                        */
/* Valeur renvoyée: dépend du message                                 */
/**********************************************************************/
BOOL WINAPI WSServerProc(HWND hDlg, UINT msg, LPARAM wP, WPARAM lP)
{
  switch(msg)
  {
    case WM_ASYNCGETHOSTBYNAME:
    {
      hAsync = NULL; // opération asynchrone terminée 
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

    // Initialisation de la boîte de dialogue------------------------------
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
            
      // Crée la Socket pour Listen()--------------------------------
      ShowStatus( hDlg, "socket()" );
      gsListen = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP );      
     
      if( gsListen != INVALID_SOCKET )           // Erreur à l'appel de Socket()?
      {
        // Définit les notifications de la Socket. La Socket est
        // mise en mode non bloquant par WSAAsyncSelect()
        ShowStatus( hDlg, "WSAAsyncSelect()" );      
        if( WSAAsyncSelect(gsListen,hDlg,WM_LISTEN,FD_ACCEPT)  
           != SOCKET_ERROR)
        {  
          // Prépare une structure d'adresse. Toutes les demandes de connexion
          // seront prises en compte
          memset( &sin, 0, sizeof( sin ) );
          sin.sin_family = AF_INET;
          sin.sin_port = htons( SERVER_PORT );     
          sin.sin_addr.s_addr = INADDR_ANY;

          // Associe une adresse à la Socket
          ShowStatus( hDlg, "bind()" );
          if(bind(gsListen,(SOCKADDR *)&sin,sizeof(sin))!=SOCKET_ERROR)
          {
            // Association réussie, on se met à l'écoute
            //  du port 
            ShowStatus( hDlg, "listen()" );
            if( listen( gsListen, SOMAXCONN ) != SOCKET_ERROR )
            {
              ShowStatus( hDlg, "Attente..." );
              return TRUE;
            }
            else ShowStatus(hDlg, "Erreur à l'appel de listen()");
          }
          else ShowStatus(hDlg, "Erreur à l'appel de bind()");
        }
        else ShowStatus(hDlg, "Erreur à l'appel de WSAAsnycSelect()");
      }
      else ShowStatus(hDlg, "Erreur à l'appel de Socket()");

      // Erreur de création de la Socket
      if( gsListen != INVALID_SOCKET )
      {
        ShowStatus( hDlg, "closesocket()" );
        closesocket( gsListen );
      }
      ShowStatus(hDlg, "Connexion impossible");
      ShowStatus(hDlg, "Vérifiez votre configuration ");
      ShowStatus(hDlg, "et relancez le serveur !");
      MessageBeep( 0 );
      return TRUE;
    }
    break;
    case WM_LISTEN:  // Traite le message de la Socket à l'écoute
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
            ShowStatus(hDlg, "Erreur à l'appel d'accept()");
          else
          {
            int i;
            // Cherche une Socket libre ---------------------------------
            for(i = 0; i < MAX_CONNECTIONS; i++)
            {
              if(gsAccepted[i] == INVALID_SOCKET)
              {
                char Buffer[ 80 ];
                
                gsAccepted[ i ] = s; // mémorise la connexion

                wsprintf(Buffer, // affiche l'adresse du client
                          "(%d) connecté à 0x%08lx, port n° : %5d", 
                          i, 
                          ntohl(addr_accept.sin_addr.s_addr), 
                          ntohs(addr_accept.sin_port));
                ShowStatus(hDlg, Buffer);

                // La Socket de prise en charge
                // a les mêmes attributs que la Socket à l'écoute
                // et gère notamment les mêmes messages. Mais ceux-ci
                // doivent être modifiés pour que la Socket connectée
                // ne reçoive plus de notification FD_ACCEPT
                // tout en réagissant à READ/CLOSE

                WSAAsyncSelect( s, 
                                hDlg,
                                WM_CONNECTION, 
                                FD_READ | FD_CLOSE );
                return 0;                                      // Terminé
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
      
      actSocket = (SOCKET)wP;         // Socket renseignée par WPARAM

      iAccept = -1;
      for(i = 0; i < MAX_CONNECTIONS; i++)
        if(gsAccepted[i] == actSocket)
        {
          iAccept = i;
          break;
        }

      switch(WSAGETSELECTEVENT(lP))        // Quel message ?
      {
        case FD_READ:                    // Le client envoie des données
        {
          char readbytes[ 255 ];
          char sendbytes[ 512 ];
      
          int iReadLen;
          int i, j;

          wsprintf(Buffer, "FD_READ(%d)", iAccept);
          ShowStatus(hDlg, Buffer);

          iReadLen = recv(actSocket,               // Lecture des données
                          readbytes,
                          sizeof(readbytes), 
                          0);
  
          if(iReadLen > 0)
          {
            wsprintf(Buffer, "echo-send(%d)", iAccept);
            ShowStatus(hDlg, Buffer);

            // Convertit la chaîne reçue en majuscules -----
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
        case FD_CLOSE:                   // le client clôture la liaison
          wsprintf( Buffer, "FD_CLOSE(%d)", iAccept );
          ShowStatus( hDlg, Buffer );

          wsprintf( Buffer, "closesocket(%d)", iAccept );
          ShowStatus( hDlg, Buffer );

          closesocket( gsAccepted[ iAccept ] ); // clôture la Socket
          gsAccepted[ iAccept ]=INVALID_SOCKET; // et la rend réutilisable
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
    case WM_DESTROY:                           // Fermeture de la fenêtre
    {
      int i;

      // En cas de fin prématurée de l'application
      // il faut interrompre les opérations asynchrones
      // qui pourraient être en cours
      if( hAsync )
        WSACancelAsyncRequest( hAsync );

      // Clôture les Sockets ouvertes. Déclenche le message
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
/* WinMain: Point d'entrée principal                                  */
/*--------------------------------------------------------------------*/
/* Paramètres:    standard                                            */
/* Valeur renvoyée: 0                                                 */
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
    DialogBox(hInstance,                   // Affiche la boîte de dialogue
               MAKEINTRESOURCE(IDD_WSSERVER), 
               NULL, 
               WSServerProc);
    WSACleanup();                              // Nettoyage final
  }
  else MessageBox(0, 
                  "Erreur à l'initialisation de WINSOCK",
                  "WSServer.EXE", 
                  0);
  return 0;
}


