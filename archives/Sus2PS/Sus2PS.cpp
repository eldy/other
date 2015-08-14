//---------------------------------------------------------
// Sus2PS
//---------------------------------------------------------
// This program simulates a mouse activity
//---------------------------------------------------------

#include <windows.h>
#include <stdio.h>

#define PROGCLASSNAME		"Sus2PS"
#define PROGWINDOWNAME		"Sus2PS (c) LD"
#define DELAYCHECK			2000	// En ms
#define DELAYACTION			10000	// En ms

TIMERPROC TimerProc;
UINT TimerSus2PSID;
long WINAPI WindowProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam);



void CALLBACK TimerSus2PSProc(HWND hwnd, UINT uMsg, UINT TimerID, DWORD dwTime)
//*************************************************************************
// Timer attendant la fin de client ou fincli
// hwnd est le hwnd de la fenetre
//*************************************************************************
{
    static long s_iTimeOut = 0;
    static int direction = 1;
    s_iTimeOut += DELAYCHECK;
	HWND hwndCaptMouse=GetCapture();
#ifdef _WIN32_WINNT
	MSEV sMSEV;
	POINT sPos;
#endif
	
    if (s_iTimeOut >= DELAYACTION) {
	    s_iTimeOut = 0;

		// Show Handle that capture the mouse (if any)
//		sprintf(s,"Handle Window GetCapture: %i",(UINT) hwndCaptMouse);
//		MessageBox(NULL,"XXX",PROGCLASSNAME,MB_SYSTEMMODAL);

		// Send WM_MOUSEMOVE (???)
//		PostMessage(HWND_BROADCAST,WM_MOUSEMOVE,(WORD) 200, (WORD) 200);

		// Synthetize mouse motions
#ifndef _WIN32_WINNT
		mouse_event(MOUSEEVENTF_MOVE,direction,0,NULL,NULL);
#else
		sPos.x=direction;sPos.y=0;
		sMSEV.pt=sPos;sMSEV.flags=MOUSEEVENTF_MOVE;
		MouseEventEx(&sMSEV,1,sizeof(sMSEV),MEF_IGNORETIME);
#endif		
		direction=-direction;
	}
}



int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR szCmdLine, int nCmdShow)
//-------------------------------------------------------------------------
// MAIN
//-------------------------------------------------------------------------
{
#ifndef _WIN32
	if (hPrevInstance) return(-1);
#else
	CreateMutex(NULL,NULL,PROGCLASSNAME);
	if (GetLastError()==ERROR_ALREADY_EXISTS) return(-1);
#endif

if (*szCmdLine) {
	// Create a class
	WNDCLASS wndclass;
	memset(&wndclass, 0, sizeof(WNDCLASS));				// let's clear the structure for fun
																								// keep it clean.. 
	wndclass.style = WS_DISABLED;	// Not 
	wndclass.lpfnWndProc = (WNDPROC)WindowProc;		// remember that prototype above?
	wndclass.hInstance = hInstance;								// set the instance of the application
	wndclass.hIcon = LoadIcon(NULL, IDI_APPLICATION);			// icon in the top right of the window
	wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);				// the arrow you see on your mouse
	wndclass.hbrBackground = GetStockObject(WHITE_BRUSH);	// background of the window
	wndclass.lpszMenuName = NULL;									// no menu in this program
	wndclass.lpszClassName = PROGCLASSNAME;				// name of class
	RegisterClass(&wndclass);

	// Create the window from the class
	HWND hWnd = CreateWindow(	
		PROGCLASSNAME,				// name of class from above
		PROGWINDOWNAME,				// name of window
		WS_OVERLAPPEDWINDOW,		// style of window
		0,											// X origin
		0,											// Y origin
		400,										// width of window
		200,										// height of window
		NULL,										// no parent window (Windows desktop is the parent)
		NULL,										// no menu, no children
		hInstance,							// tell it which app it belongs to
		NULL);									// no extra parameters

	// Now just show the window, and tell it to redraw itself
	ShowWindow(hWnd, nCmdShow);
	UpdateWindow(hWnd);			// force the window to redraw itself, otherwise you'll never 
								// see it.  A critical step when I started coding in windows
								// I'd always forget this.
}

	// Create a timer
    TimerProc = (TIMERPROC)MakeProcInstance((TIMERPROC)TimerSus2PSProc, hinst);
    if ((TimerSus2PSID = SetTimer(NULL,1,DELAYCHECK,TimerProc)) == NULL)
    {
        FreeProcInstance((TIMERPROC)TimerSus2PSProc);
        return FALSE;
    }

	// Main window messages loop
	MSG msg;
	while(GetMessage(&msg, NULL, 0, 0))	// get the message from the Windows message quene
		DispatchMessage(&msg);			// dispatch it to the appropriate local window

    KillTimer(NULL,TimerSus2PSID);

	return 0;
}



/* A modified this message handling function so that it creates a directdraw surface
	out of the primary buffer (which is the screen).  Basically it creates a handle to the
	screen that we are looking at.  Now we are able to draw anywhere we want on the screen
	by writing to that single dimensional array. 

	static is an identifier whichs means that the scope of the variable is global.  Basically
	the variable retains its value as the function gets continually executed. 

	DirectX using the COM object model (Component Object Model).  I don't know too much about
	the COM model other than that it is quite similar to C++.  Simple press F1 when hightlighting
	the word "COM" and you will obtain a description.

	To see the list of messages use the InfoView tab on the bottom of the workspace
	(on the bottom left of your screen where it says ClassView, FileView, InfoView)
	Click "Platform, SDK, and DDK Documentation"->"Platform SDK"->Reference->
	"Messages"->"Win32 Messages".  Please play with the help file extensively. 
	It took me while a while to master the MSDN help file and figure out how to
	retrive relative info.  Most of the info you need is located in:
		"Platform, SDK, and DDK Documentation"->"Platform SDK"
	don't bother searching in other places.
	*/


long WINAPI WindowProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
	switch(msg)					
	{
		case WM_CREATE:		// message is sent only once when the window is created
											// press F1 on WM_CREATE to learn more about it
			// we won't do anything here, but be prepared to using this message
			// it is a useful one
			break;

		case WM_MOUSEMOVE:	// this message is cool, it is posted to your message quene
												// (which is handled by GetMessage/DispatchMessage) and ends
												// up here.  Every time mouse moves, we receive this message
			// let's output the coordinates of the mouse.  It'll be fun.  Hmmmm.. let's
			// output it to the debugger
			
			{									// we put a brace bracket here because C++ doesn't allow us to 
												// declare variables inside a switch case statement, so we
												// artifically nest it <grin>
				char szString[128];		// a temporary string, sz denotes zero terminated string
															// it is the well known Hungarian notation
												// wsprintf is EXACTLY like sprintf except that it is dynamically
												// linked
				wsprintf(szString, "(%3d, %3d)", LOWORD(lParam), HIWORD(lParam));
												// the bottom WORD of the 32-bit lParam contains the xPosition
												// the top WORD contains the yPosition
												// press F1 on WM_MOUSEMOVE for more info
				OutputDebugString(szString);	// output the info to the debugger output
				// we may as well find out which buttons are being pressed.  The flags are 
				// stored in wParam.  F1 on WM_MOUSEMOVE for the info.

				// if the bit MK_CONTROL ANDed to wParam returns a one, the if statement is TRUE
				// equivalent to if(wParam&MK_CONTROL == MK_CONTROL) then ...
				// equivalent to check if the MK_CONTROL bit in wParam is on or not
				OutputDebugString(":");
				if(wParam & MK_CONTROL) OutputDebugString("Control:");
				if(wParam & MK_LBUTTON) OutputDebugString("Left Button:");
				if(wParam & MK_MBUTTON) OutputDebugString("Middle Button:");
				if(wParam & MK_RBUTTON) OutputDebugString("Right Button:");
				if(wParam & MK_SHIFT) OutputDebugString("Shift:");
				OutputDebugString("\n");
			}
			break;

		case WM_DESTROY:				// someone wants to kill the window, tell windows to kill
			PostQuitMessage(-1);	// ok, QUIT NOW, return -1 
			break;
		
		default:	// let windows process all of the messages which we don't 
			return DefWindowProc(hWnd, msg, wParam, lParam);	// care about
	}

	return 0;		// once a message has been processed, return 0 to tell windows WE processed the message
}


// obviously simple a prototype, see below for specifics on the function
// UINT is the same as unsigned int which is from 0 to 65538
// versus a regular int which is from -32768 to 32767
// WPARAM is a WORD which is two BYTEs which finally ends up translating to
// an unsigned int (in 16-bit).  But when compiling under Win95/98/NT
// the unsigned int is 32-bit and therefore the WPARAM is 32-bit, losing
// its meaning.
// the LPARAM is a long int, 32-bit in length
// WINAPI is a define for __far __pascal which is the calling convention
// that windows uses.  No need to bother understanding that now.

/*
	Remember int main(int argc, char **argv)?  That was the "constructor" or the 
	function which initiated your program.  Well, with windows, it is WinMain.
	main() is still embedded somewhere, but it now has code in the function which
	calls WinMain, which in turn intiates your program. 

	The parameters are very obscure, they mean nothing as of yet.  Please look up 
	these variables in the help (F1).

	My definitions are:
	hInstance		an instance of an application.  A unique number which defines each
							and every application running on Windows.  eg. Two Netscapes running
							simultaneously each have their own instance, yet the same code.
	hPrevInst		need not bother, something to do with 16-bit Windows 3.1 programming
							it used to contain the hInstance of a copy of the same app already 
							running.  If it was NULL, you knew that this is the only copy of
							the app running currently.
	szCmdLine		Remember argv, and argc.  Well the compiler parsed the command 
							line info for you.  Here you are giving the RAW string that follows
							the execution of your program.
	nCmdShow		Ever noticed when you create a shortuct, you can make the program
							run maximized, normal, or minimized.  Same in Windows 3.1?  Well,
							this parameter specifies which mode you wanted the program to run
							it.  
*/
