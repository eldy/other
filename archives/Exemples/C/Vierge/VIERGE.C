//***************************************************************************
//                  PROJET XXX 1.0   (c-1994)
//***************************************************************************
// Laurent Destailleur
//***************************************************************************
// Fichiers sources de programe
// xxx.c         Fichier Source programe principal
// xxx.rc        Fichier Resource
// xxx.h         Fichier déclaratif des constantes ressources
// hardware.h    Fichier Header de fonctions diverses (Matériel)
// generalw.h    Fichier Header de fonctions diverses (General)
// classes.h     Fichier Header de déclarations des classes
//***************************************************************************


// Inclusion fichiers Header généraux
#include <dos.h>
#include <stdio.h>
#include <io.h>
#include <dir.h>
#include <string.h>
#include <windows.h>
#include <windowsx.h>
#include <commdlg.h>

#define Nom_logiciel "XXX"          // Nom du logiciel
#define NOIR RGB(0,0,0)             //=BLACK_BRUSH
#define GRIS RGB(128,128,128)       //=GRAY_BRUSH
#define GRIS_CLAIR RGB(192,192,192) //=LTGRAY_BRUSH
#define BLANC RGB(255,255,255)      //=WHITE_BRUSH

BYTE verwin1,verwin2,verdos1,verdos2; // Pour versions Windows et DOS
char path[MAXPATH],path2[MAXPATH];      //
char nom[MAXFILE-1+MAXEXT];             //  Variables pour la gestion des
char drive[MAXDRIVE];                   //
char dir[MAXDIR];                       //  noms de fichiers, répertoires
char name[MAXFILE];                     //
char ext[MAXEXT];                       //
char erreurstring[513]; // Chaine pour affichage de MessageBox
struct date datep; // Structure pour date
struct time timep; // Structure pour heure
MINMAXINFO *lpmmi=NULL; // Pointeur pour dimensionnement fenêtres
POINT point;            // Structure pour points
RECT rect1,rect2;       // Structure pour rectangles
WNDCLASS wc_1,wc_2;     // Structure pour classes
MSG msg;                // Structure des messages Windows
HINSTANCE hinst;        // Handler pour Instance principale
HWND hwnd1,hwnd2;       // Handler pour fenetres
DLGPROC dlgprc;         // Handler pour boites de dialogues
HMENU hmenu1,hmenu2;    // Handler pour menu
HDC hdc1,hdc2;          // Handler pour Device Context (fenetre principale hwnd1)
HRGN hrgn1,hrgn2;       // Handler pour Region
HBRUSH hbr1,hbr2;       // Handlers pour Brush
HPEN hpen1,hpen2;       // Handlers pour Pen
HFONT hfont1,hfont2;    // Handlers pour Font
HCURSOR hcur1,hcur2;    // Handlers pour curseurs
HICON hicon1,hicon2;    // Handlers pour icones
// variables pour transferts temporaires, utilisées par toutes procédures
int erreur=0,retour=0;
int i,j,k;
BOOL b;
WORD w;
DWORD dw;
char s[513];
FILE *f;


// Inclusions des fichiers Header personnels
#include <hardware.h> // Bibliothèque personnelle (Matériel)
#include <generalw.h> // Bibliothèque personnelle (Général)
#include "testdll.h"  // Fichier definition constantes utilisées dans fichier ressource



LRESULT FAR PASCAL DIALOG_NOMDUMENU(HWND fenetre,UINT message,WPARAM wParam,LPARAM lParam)
//***************************************************************************
// Entrée: fenetre=HwndDlg,message,wParam,lParam
//***************************************************************************
{
RECT rect;
switch(message) {
  case WM_INITDIALOG:
	 CENTRE(fenetre,hwnd1);
	 break;
  case WM_GETMINMAXINFO:
	 lpmmi=MK_FP(HIWORD(lParam),LOWORD(lParam));
	 GetWindowRect(fenetre,&rect);
	 (*lpmmi).ptMinTrackSize.x=(*lpmmi).ptMaxTrackSize.x=(rect.right-rect.left);
	 (*lpmmi).ptMinTrackSize.y=(*lpmmi).ptMaxTrackSize.y=(rect.bottom-rect.top);
	 break;
  case WM_COMMAND:
	 switch(wParam)
		{
		case IDC_OK:
		  EndDialog(fenetre,0);
		  break;}
	 break;}
return(0);
}





LRESULT FAR PASCAL DIALOG_APROPOS(HWND fenetre,UINT message,WPARAM wParam,LPARAM lParam)
//************************************************************************
// Reçois messages de Boite de dialogue APROPOS (modale)
// Entrée: fenetre=HwndDlg,message,wParam,lParam
//************************************************************************
{
RECT rect;
switch(message) {
  case WM_INITDIALOG:
	 CENTRE(fenetre,GetDesktopWindow());
	 dw=GetWinFlags();
	 if (dw & WF_ENHANCED) strcpy(s,"386 protégé");
	 else if (dw & WF_STANDARD) strcpy(s,"Mode Standard");
		else strcpy(s,"Inconnu");
	 SetDlgItemText(fenetre,IDC_WINDOWS_MODE,s);
	 dw=GetFreeSpace(w);
	 sprintf(s,"%lu octets",dw);
	 SetDlgItemText(fenetre,IDC_MEMOIRE_LIBRE,s);
	 w=GetFreeSystemResources(GFSR_SYSTEMRESOURCES);
	 sprintf(s,"%u\%",w);
	 SetDlgItemText(fenetre,IDC_RESSOURCES_LIBRES,s);
	 break;
  case WM_GETMINMAXINFO:
	 lpmmi=MK_FP(HIWORD(lParam),LOWORD(lParam));
	 GetWindowRect(fenetre,&rect);
	 (*lpmmi).ptMinTrackSize.x=(*lpmmi).ptMaxTrackSize.x=(rect.right-rect.left);
	 (*lpmmi).ptMinTrackSize.y=(*lpmmi).ptMaxTrackSize.y=(rect.bottom-rect.top);
	 break;
  case WM_COMMAND:
	 switch(wParam) {
		case IDC_OK:
		  EndDialog(fenetre,0);
		  break;}
		break;}
return(0);
}




LRESULT FAR PASCAL WINDOW_1(HWND hwnd1,UINT message,WPARAM wParam,LPARAM lParam)
//***************************************************************************
// Reçois messages de fenêtre principale = hwnd1
// Entrée: hwnd1,message,wParam,lParam
//***************************************************************************
{
RECT rect;
PAINTSTRUCT ps;
HDC hdc;
switch (message) {
  case WM_CREATE: // Message: appel à la création
	 break;
  case WM_GETMINMAXINFO:
	 lpmmi=MK_FP(HIWORD(lParam),LOWORD(lParam));
	 (*lpmmi).ptMinTrackSize.x=rect1.right-rect1.left;(*lpmmi).ptMinTrackSize.y=rect1.bottom-rect1.top;
	 break;
  case WM_PAINT:
	 GetClientRect(hwnd1,&rect);
	 hdc=BeginPaint(hwnd1,&ps);
	 i=TextOut(hdc,0,0,"aaa",3);
	 EndPaint(hwnd1,&ps);
	 break;
  case WM_COMMAND: // Message: signale sélection du menu
	 switch(wParam) {
		case MENU_NOMDUMENU:
		  dlgprc=(DLGPROC) MakeProcInstance((FARPROC) DIALOG_NOMDUMENU,hinst);
		  DialogBox(hinst,"NOMDUMENU",hwnd1,dlgprc);
		  break;
		case MENU_QUITTER: // Annule CreateWindows, envoye message WM_QUIT
		  DestroyWindow(hwnd1);
		  break;
		case MENU_APROPOS: // Affiche Boite de Dialogue "APROPOS"
		  dlgprc=(DLGPROC) MakeProcInstance((FARPROC) DIALOG_APROPOS,hinst);
		  DialogBox(hinst,"APROPOS",hwnd1,dlgprc);
		  break;}
	 break;
  case WM_QUIT:    // Message: Fenêtre va être détruite
  case WM_DESTROY: // Message: Fenêtre va être détruite
	 PostQuitMessage(0); // La fonction GetMessage renvoye alors 0
	 break;
  default: // Traite tous les autres messages
	 return(DefFrameProc(hwnd1,NULL,message,wParam,lParam));}
return(0);
}


int PASCAL WinMain(HINSTANCE hinstance,HINSTANCE hPrevInstance,LPSTR lpCmdLine,int nCmdShow)
//**************************************************************
// PROGRAMME PRINCIPAL
// hinstance=Instance du programme principal en cours
// hPrevInstance=Valeur de l'instance précédente
// lpCmdLine=Chaine contenant la ligne de commande
// nCmdShow=Etat de l'application (Icon,maximized,...)
//**************************************************************
{
if (hPrevInstance) return(-1);
//********** Initialisations
hinst=hinstance;               // Sauve hinstance en variable statique hinst.
hbr1=GetStockObject(WHITE_BRUSH);hbr2=GetStockObject(LTGRAY_BRUSH);
hpen1=CreatePen(PS_SOLID,1,NOIR);hpen2=CreatePen(PS_SOLID,1,BLANC);
hcur1=LoadCursor(NULL,IDC_ARROW);hcur2=LoadCursor(NULL,IDC_WAIT);
hicon1=LoadIcon(hinst,"icon1");
//********** Teste si versions MSDOS et Windows correctes
dw=GetVersion();
verwin1=LOBYTE(LOWORD(dw));verwin2=HIBYTE(LOWORD(dw));
verdos1=HIBYTE(HIWORD(dw));verwin2=LOBYTE(HIWORD(dw));
if (verwin1<3) {
  MessageBox(NULL,Nom_logiciel " a besoin de la version Windows 3.0 ou supérieure.",Nom_logiciel,MB_OK|MB_ICONASTERISK|MB_APPLMODAL);
  return(-2);} // Termine si version Windows < 3.0
//********** Définition des classes pour fenetres
wc_1.style=0; // Style de la classe
wc_1.lpfnWndProc=(long (FAR PASCAL*)()) WINDOW_1; // Nom de procédure appelée par messages
wc_1.cbClsExtra=0;
wc_1.cbWndExtra=0;
wc_1.hInstance=hinstance; // Classe associée à hinstance=instance en cours
wc_1.hIcon=LoadIcon(hinstance, "icon1");
wc_1.hCursor=hcur1; // Curseur par défaut=flêche
wc_1.hbrBackground=GetStockObject(WHITE_BRUSH);
wc_1.lpszMenuName="MENU_1";   // Nom du menu (dans fichier .RC)
wc_1.lpszClassName="classe_1"; // Nom de la classe créée
if (!RegisterClass(&wc_1)) return (-6); // Valide la classe créée et test résultat
//********** Crée fenêtre hwnd1 selon classe_1
GetWindowRect(GetDesktopWindow(),&rect1); // Enregistre dans rect1 les caractéristique de l'écran.
hwnd1=CreateWindow(    // Crée la fenêtre hwnd1
  "classe_1",          // Nom de la class structure utilisée
  NULL,                // Barre de titre
  WS_OVERLAPPEDWINDOW|WS_CLIPCHILDREN|WS_VISIBLE, // Style de la fenêtre
  rect1.left+5,         // Position horizontale
  rect1.top+5,          // Position verticale
  250,                  // Largeur
  250,                  // Hauteur
  NULL,                 // Pas de parents car fenetre principale
  NULL,
  hinst,                // Instance propriétaire de la fenêtre=hinst
  NULL);
//********** Sauvegarde parametres divers en variables statiques
hmenu1=GetMenu(hwnd1);
hdc1=GetDC(hwnd1);
SetMapMode(hcur1,MM_TEXT);
//********** Boucle principale: Attend et distribue messages
while (GetMessage(&msg,(HWND) NULL,0,0)) {
  TranslateMessage(&msg); // Traduit les 'virtual key codes' en messages
  DispatchMessage(&msg);  // Dispatche les messages vers les fenêtres
  }
return(0); // Fin du programme
}

