//---------------------------------------------------------------------------
// Send a mail from command line or from a HTTP form (use CGI GET or POST method)
// It can also send all fields of a HTTP form (MAX_ENTRIES fields)
// It applies to the RFC 821 and RFC 822 specs 
// It supports MIME 1.0 encoding of European national characters.
//
// Tested with :
// VC++ 4.0		(WIN32)
// GCC 2.8.1	(WIN32)
// GCC 2.7.3	(Aix 4.1.4 et 4.2)
// GCC 2.9		(Linux)
//---------------------------------------------------------------------------
// 02/10/98	1.0		Laurent Destailleur	Creation
// 19/10/98	1.2							Can be compiled with several compiler
// 15/11/98	1.4							Add CLogMsg class to log
// 19/11/98	1.5							Works with Unix (Aix & Linux)
// 20/11/98	1.6							Fix some bugs (free, ...)
// 22/11/98	1.7							Logs are cleaner, English and French
// 19/12/98 1.8							Can use REMOTE_USER cgi variable
//---------------------------------------------------------------------------
// Required field if used as a CGI-BIN application:
// HOST    = SMTP Server name
// SUBJECT = Subject field of the email.
// RCPT    = Receiver(s) of the email 	(Ex: toto@titi.com, tata@titi.com)
//           It can be a nickname defined in the sendmail.ini
//           Mails sending can be restricted to nicknames autorized.
//
// Optionnal fields if used as a CGI-BIN application:
// LANG	   = Language of messages
// FROM    = Sender email address		(Ex: "someone@somewhere.com")
//										(If "REMOTE_USER@somewhere.com", replace "REMOTE_USER"
//										 by CGI environment variable : REMOTE_USER)
// MESSAGE = The content of this form field is sent without the name of field
// XXXX	   = The contents of fields named something else than MESSAGE are sent preceded by the name of field
//---------------------------------------------------------------------------
#define PROG	"SendMess"
#define VERSION	"1.93"

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <time.h>
#include <malloc.h>
#include <memory.h>

#ifndef _WIN32
// Pour Unix
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#define SOCKET int					
#define INVALID_SOCKET (SOCKET)(~0)	
#define SOCKADDR_IN struct sockaddr_in
#define LPHOSTENT struct hostent *
#define MAXHOSTNAMELEN 256   
#endif
#ifdef _WIN32
#ifdef _MSC_VER
// Pour VC++
#include <direct.h>
#include <winsock.h>
#define MAXHOSTNAMELEN 256
#endif
#ifdef __GNUC__
// Pour GCC WIN32 CYGWIN
#include <winsock.h>
#include <mingw32/dir.h>
// Pour GCC WIN32 EGCS
//#include <base.h>
//#include <defines.h>
//#include <structures.h>
//#include <sockets.h>		// Fichier a modifier sous GCC WIN32 pour contourner bug !!!
//#include <functions.h>
#endif
#endif

#include "misc.h"
#include "CLogMsg.h"
#include "macros.h"


#define MAX_ENTRIES 50+5	// 50 fields + 5 system fields (LANG, HOST, FROM, MAILTO,SUBJECT)
#define FILEINI "awmess.conf"
#define UNKNOWN_ERROR 1
#define RECEIVE_BUF_SIZE 1024<<2
#define SIZEOFLINES	72		// Size max of lines in EMail header (if greater, lines need to be folded)

#define FAILED_TO_OPEN_MAILFILE 2
#define FAILED_TO_OPEN_ADDRESS_LIST 3
#define FAILED_TO_START_SOCKETS 4
#define FAILED_TO_RESOLVE_HOST 5
#define FAILED_TO_OBTAIN_SOCKET_HANDLE 6
#define FAILED_TO_CONNECT 7
#define FAILED_TO_SEND 8
#define FAILED_TO_RECEIVE 9
#define SERVER_ERROR 10
#define FAILED_TO_GET_HOSTNAME 11
#define OUT_OF_MEMORY 12
#define FAILED_TO_PARSE_CGI 13
#define SUBJECT_REQUIRED 14
#define SENDER_UNKNOWN 15
#define RECEIVER_UNKNOWN 16
#define HOST_REQUIRED 17
#define CLIENT_HOST_NOT_ALLOWED 18


// Types
typedef struct {
    char *name;
    char *val;
} entry;


// Variables
entry entries[MAX_ENTRIES];
char *Messages[][2] = { 
	{{"Mail successfully sent.\n"},			{"Mail envoye avec succes.\n"}},
	{{"Error: Unknown error\n"},			{"Erreur: Erreur inconnue.\n"}},
	{{"Error: Unable to open mailfile for read.\n"},{"Erreur: Impossible d'ouvrir le fichier de mail a envoyer.\n"}},
	{{"Error: Unable to open file with EMail addresses for read.\n"},{"Erreur: Impossible d'ouvrir le fichier des adresses Email des destinataires.\n"}},
	{{"Error: FAILED_TO_START_SOCKETS\n"},	{"Erreur: Echec de la fonction WSAStartup.\n"}},
	{{"Error: FAILED_TO_RESOLVE_HOST\n"},	{"Erreur: Echec de la resolution DNS du nom du serveur SMTP.\n"}},
	{{"Error: FAILED_TO_OBTAIN_SOCKET_HANDLE\n"},{"Erreur: Echec de la creation de la socket.\n"}},
	{{"Error: FAILED_TO_CONNECT\n"},		{"Erreur: Echec de la connexion au serveur.\n"}},
	{{"Error: FAILED_TO_SEND\n"},			{"Erreur: Echec de l'envoi paquet.\n"}},
	{{"Error: FAILED_TO_RECEIVE\n"},		{"Erreur: Echec en reception d'un paquet.\n"}},
	{{"Error: SERVER_ERROR\n"},				{"Erreur: Pas de reponse du serveur a l'identification SMTP.\n"}},
	{{"Error: Failed to get my own IP address\n"},{"Erreur: Echec a la recuperation du mon propre hostname.\n"}},
	{{"Error: Out of memory\n"},			{"Erreur: Memoire insuffisante.\n"}},
    {{"Error: Bad arguments from CGI form.\n"},	{"Erreur: Ligne de commande CGI incorrecte ou incomplète.\n"}},
    {{"Error: Subject required.\n"},		{"Erreur: Champs sujet requis.\n"}},
	{{"Error: Sender name/address is incorrect or not allowed.\n"},{"Erreur: Adresse EMail emetteur incorrecte ou non autorisee.\n"}},
	{{"Error: Receiver EMail address is incorrect or not allowed.\n"},{"Erreur: Adresse EMail destinataire incorrecte ou non autorisee.\n"}},
    {{"Error: Host required.\n"},			{"Erreur: Nom serveur SMTP requis.\n"}},
    {{"Error: Client Host not allowed.\n"},	{"Erreur: Utilisation du serveur STMP par un client hote non autorisé.\n"}}
};
#ifdef _WIN32
#define CHARSTOP "^Z (CTRL+Z +ENTER)"
#else
#define CHARSTOP "^D (CTRL+D)"
#endif
char *MessageTypeText[2]= {
	{"Type your message text and press "CHARSTOP" when done...\n"},
	{"Tapez votre message puis "CHARSTOP" pour terminer.\n"}};

BOOL CGIon=FALSE;
char Lang[2]="E";					// Use English by default
int  LangNb;						// 0, 1, 2...
int  iRet;
char ficini[MAX_PATH];
// To use SMTP protocol
#ifdef _WIN32
WSADATA Data;
#endif
int  Port;							// SMPT Host port
char Host[MAXHOSTNAMELEN];			// SMTP Host IP name
char LocalHost[MAXHOSTNAMELEN];		// LocalHost name
char *MailTo;						// EMail list
// To send data
char Rpath[SIZEOFLINES];			// EMail return adress		Field of EMail header
char From[SIZEOFLINES];				// EMail return name		Field of EMail header
char Subject[SIZEOFLINES];			// Subject					Field of EMail header
char mailFile[MAX_PATH];			// File to send				EMail data
// Options
char DeleteFileWhenUsed[4]; 		// Boolean yes or no. If Yes, delete the mailfile when processed
char DoMime[4];						// Code Mail in MIME
char UseIIS[8];						// Use IIS header
char RestrictEmail[4];				// If "Yes" only accept email receivers defined in .ini file (Usefull for CGI)
char HTMLhead[1024];
char HTMLend[1024];

// Functions
char *ParseRCTP(char * toWho);
char *makeword(char *line, char stop);
char *fmakeword(const char *paramstring, char stop, int *len, int x);
char *fgetstring(FILE *f, int *len);
int getline(char *s, int n, FILE *f);
void send_fd(FILE *f, FILE *fd);
int ind(char *s, char c);
char *MyGetEnv(char *tag);
int mail_connect();
int Post(SOCKET sc, const char * msg);
int Ack(SOCKET sc);
int DoQuit(int iRet);
char *cgiLookup(char *tag, char *default_tag);

// Classes
CLogMsg LogMsg(PROG".log");


void chartospace(char *str,char c)
//---------------------------------------------------------------------------
// Change char c in space in a string
//---------------------------------------------------------------------------
{
    register int x;
    for (x=0;str[x];x++) if(str[x] == c) str[x] = ' ';
}


char x2c(char *what) 
//---------------------------------------------------------------------------
// Convert a string "XX" in a the char with XX ASCII value
//---------------------------------------------------------------------------
{
    register char digit;
    digit = (what[0] >= 'A' ? ((what[0] & 0xdf) - 'A')+10 : (what[0] - '0'));
    digit = digit << 4;
    digit += (what[1] >= 'A' ? ((what[1] & 0xdf) - 'A')+10 : (what[1] - '0'));
    return(digit);
}

void unescape_url(char *url,char escape) 
//---------------------------------------------------------------------------
// Change %XX or =XX in the char with XX ASCII value
//---------------------------------------------------------------------------
{
    register int x,y;
    for(x=0,y=0;url[y];++x,++y) {
        if((url[x] = url[y]) == escape) {
            url[x] = x2c(&url[y+1]);
            y+=2;
        }
    }
    url[x] = '\0';
}

const char *MimeEncode(const char *line)
//---------------------------------------------------------------------------
// Function	: Map european characters. Use MIME 1.0 encoding (+Code .<CRLF> into ..<CRLF>)
// Input 	: line = string ended with '\r\n\0'
// Output	: A buf pointer created by new (and deleted by next call to function)
//---------------------------------------------------------------------------
{
	static char *buf;
	char *p;
	const char *q;
	int size_line=strlen(line);

	if (buf) delete buf;
	buf=new char[size_line*3];
	p=buf;q=line;
	if ((q[0]=='.') && (q[1]=='\r') && (q[2]=='\n')) {	// To change .<CRLF> into ..<CRLF>
		*p++ = '.';
	}
	while (q[0]) {
		if ((*DoMime|0x20) == 'y') {					// Mime encode
			if ((((unsigned int) q[0])>127) || (q[0]=='=')) {
				strcpy(p++,"=");
				char s[9];
				sprintf(s,"%02X",(char) q[0]);
				strcpy(p,&s[strlen(s)-2]);				// Ne pas mettre strcpy(p,s) car bug GCC
				p+=2;q++;
				continue;
			}
		}
		*p++ = *q++;									// Normal char
		continue;
	}
	*p = 0;
	return buf;
}


int ParseCgiInfo(BOOL *CGIon)
//---------------------------------------------------------------------------
// Function	: Detect if we work in CGI Mode
// Ouput  	: CGIon = TRUE or FALSE
// Return 	: 0	OK
//			  >0  Error
//---------------------------------------------------------------------------
{
	register int x,cl;

	char *p = getenv("REQUEST_METHOD");
	if (!p || !*p) { *CGIon=FALSE; return(0); }
	*CGIon=TRUE;

	LogMsg.Write(2,"CGI REQUEST_METHOD :",p);
	if (stricmp(p,"GET") && stricmp(p,"POST")) {
		printf("This CGI script should be referenced with a METHOD of GET or POST.\n");
		return(1);
	}

	if (stricmp(p,"POST")==0) {	// Fill entrie tab with CGI arguments (POST METHOD = from stdin)
		cl = atoi(getenv("CONTENT_LENGTH"));
		LogMsg.Write(2,"CGI CONTENT_LENGTH :", cl);
		char *paramstring=fgetstring(stdin,&cl);
		LogMsg.Write(4,"PARAM STRING (may be truncated if string is in binary with a byte ASCII 0) :", paramstring);
		cl = atoi(getenv("CONTENT_LENGTH"));
		for (x=0;cl && (x<MAX_ENTRIES);x++) {
			entries[x].val = fmakeword(paramstring,'&',&cl,x);
			LogMsg.Write(3,"Parameter found :", entries[x].val);
			chartospace(entries[x].val,'+');
			unescape_url(entries[x].val,'%');
			entries[x].name = makeword(entries[x].val,'=');
			if (cl) { cl = atoi(getenv("CONTENT_LENGTH")); }	// We didn't reach end of paramstring so we will tsearch another parameter
		}
	}
	if (stricmp(p,"GET")==0) {	// Fill entrie tab with CGI arguments (GET METHOD = from QUERY_STRING)
		if (!(p=getenv("QUERY_STRING"))) return(2);
		LogMsg.Write(2,"CGI QUERY_STRING   :",p);
		for (x=0; x<(int) strlen(p) && (x<MAX_ENTRIES); x++) {
			entries[x].val = makeword(p,'&');
			chartospace(entries[x].val,'+');
			unescape_url(entries[x].val,'%');
			entries[x].name = makeword(entries[x].val,'=');
			LogMsg.Write(3,"val",entries[x].val);
			LogMsg.Write(3,"name",entries[x].name);
		}
	}

	return(0);
}



char * ParseRCTP(char * toWho)
//---------------------------------------------------------------------------
// Function	: Read receiver address from command line or from file (not used in CGI)
// Output	: NULL	Error
//			  rcpt	OK		(with malloc, "xxx@xxx.xxx, yyy@yyy.yyy, ...")
//---------------------------------------------------------------------------
{
	FILE *toFile;
	long s;
	char *rctp, *next;

	if (!toWho || !*toWho) return((char *) NULL);

	if (*toWho == '@')	// File with list of Email
	{
		if ((toFile = fopen(toWho + 1,"rt")) == NULL)
		{
			DoQuit(FAILED_TO_OPEN_ADDRESS_LIST);
			return((char *) NULL);
		}
		fseek(toFile, 0, SEEK_END);
		s = ftell(toFile);
		fseek(toFile, 0, SEEK_SET);
		if ((rctp = (char *)malloc(s)) == NULL)
		{
			DoQuit(OUT_OF_MEMORY);
			return((char *) NULL);
		}
		next = rctp;
		while (!feof(toFile))
		{
			fgets(next, 256, toFile);
			next += strlen(next) - 1;
			if (*next == '\n')
				*next = ',';
			next++;
		}
		next--;
		if (*next == ',')
			*(next) = '\0';
		fclose(toFile);
	}
	else
	{
		if ((rctp = (char *)malloc(strlen(toWho)+1)) == NULL)
		{
			DoQuit(OUT_OF_MEMORY);
			return(toWho);
		}
		strcpy(rctp, toWho);
	}

	return(rctp);
}


int DoQuit(int iRet)
//---------------------------------------------------------------------------
// Show result
//---------------------------------------------------------------------------
{
	if (iRet) {	// Error
        switch(iRet) {
            case 451:
		  	case 550:   iRet=RECEIVER_UNKNOWN;break;
			case 551:	iRet=SENDER_UNKNOWN;break;
			case 554:	iRet=CLIENT_HOST_NOT_ALLOWED;break;
            default: 	break;
		}
		printf(Messages[iRet>17?1:iRet][LangNb]);
		char info[256];
		sprintf(info,"%s",Messages[iRet>17?1:iRet][LangNb]);
		LogMsg.Write(1,info);
	}
	else {		// OK
        printf(Messages[0][LangNb]);
		char info[sizeof(From)+sizeof(Rpath)+sizeof(Subject)+33];
		sprintf(info,"From <%s> - Rpath <%s> - Subject <%s>",From,Rpath,Subject);
		LogMsg.Write(1,"Message successfuly sent : ",info);
	}
	return(iRet);
}


int mail_connect()
//---------------------------------------------------------------------------
// Function	: Init socket, send message
//---------------------------------------------------------------------------
{
	SOCKET sc;
	char s[256];
	FILE *fp = stdin;
	char *p;

	//***** Get mailfile
	if (!CGIon && *mailFile) {
		if ((fp = fopen(mailFile,"r")) == NULL) return(DoQuit(FAILED_TO_OPEN_MAILFILE));
	}

#ifdef _WIN32
	if (WSAStartup(MAKEWORD(1, 1), &Data) != 0)	return(DoQuit(FAILED_TO_START_SOCKETS));
#endif

	//***** Create Socket
	LogMsg.Write(2,"Create socket : socket(PF_INET,SOCK_STREAM)");
	if ((sc = socket(PF_INET,SOCK_STREAM,0)) == INVALID_SOCKET)	{
		return(DoQuit(FAILED_TO_OBTAIN_SOCKET_HANDLE));
	}
	//***** Resolve the servers IP
	LogMsg.Write(2,"Resolve IP address for : ",Host);
	struct hostent *adr;
	adr = gethostbyname(Host);
	if (!adr) {
		return(DoQuit(FAILED_TO_RESOLVE_HOST));
	}
	
	//***** Connect to server
	SOCKADDR_IN sin;
	sin.sin_port = htons((u_short) Port);
	sin.sin_family = adr->h_addrtype;
	memcpy((char *) &sin.sin_addr, adr->h_addr, adr->h_length);
	char AddrHexa[9];
	sprintf(AddrHexa,"%08lX",* (unsigned long *) &sin.sin_addr);
	AddrHexa[8]=0;
	LogMsg.Write(2,"Connect socket to : ",AddrHexa);
#ifdef _WIN32
	if (connect(sc,(LPSOCKADDR) &sin,sizeof(sin)))
#else
	if (connect(sc,(const struct sockaddr *) &sin,sizeof(sin))) 
#endif
	{
		return(DoQuit(FAILED_TO_CONNECT));
	}

	//***** Server welcome message
	if ((iRet=Ack(sc))) {
		return(DoQuit(SERVER_ERROR));
	}

	//***** Get our own host name
	if (gethostname(LocalHost,sizeof(LocalHost)))	{
#ifdef _WIN32
		LogMsg.Write(1,"Failed to get my own hostname", WSAGetLastError());
#else
		LogMsg.Write(1,"Failed to get my own hostname");
#endif
		return(DoQuit(FAILED_TO_GET_HOSTNAME));
	}
	LogMsg.Write(2,"Get my own hostname : ",LocalHost);

	//***** Say Hello
	sprintf(s,"HELO %s\r\n", LocalHost); Post(sc,s); 
	if ((iRet=Ack(sc))) {
		return(DoQuit(iRet));
	}
	
	//***** Tell who is the sender
	sprintf(s,"MAIL FROM:<%s>\r\n", Rpath); Post(sc,s);
    if ((iRet=Ack(sc))) {
		Post(sc,"QUIT\r\n");
		return(DoQuit(iRet));
    }

	//***** List all receivers
	char *addrcursor, *addrbuf;
	int addrLen=1024<<2;						// addrbuf is 4K buffer (used for "To:" header field)
	addrbuf = addrcursor = new char[addrLen];
	addrcursor += sprintf(addrcursor,"To:");
	if (CGIon)
	{
		BOOL bFoundRCPT=FALSE;
		char mybuf[128];
		int i;
		char tostr[] = "RCPT";
		for(i = 0; (i < MAX_ENTRIES) && entries[i].name; i++)
		{
			if (stricmp(entries[i].name,tostr)) continue;
			if (!entries[i].val) continue;
			// Get the nick from .ini file
			GetPrivateProfileString("Nicknames",entries[i].val,"",mybuf,sizeof(mybuf),ficini);
			if (!*mybuf)
			{
				if (toupper(*RestrictEmail) == 'Y')
				{
					printf("Receiver %s is not the list of autorized receiver nicknames.<br>\n", entries[i].val);
					continue;
				}
				strcpy(mybuf,entries[i].val); // Accept it
			}
			// We found a new receiver
			bFoundRCPT=TRUE;
			sprintf(s,"RCPT TO:<%s>\r\n", mybuf); Post(sc,s); 
			if ((iRet=Ack(sc))) {
				Post(sc,"QUIT\r\n");
				return(DoQuit(iRet));
			}
			addrcursor += sprintf(addrcursor," %s\r\n", mybuf);
		}
		if (!bFoundRCPT) {
			Post(sc,"QUIT\r\n");
			return(DoQuit(RECEIVER_UNKNOWN));
			}
	}
	else
	{
		// MailTo= someone1@somewhere.com, someone2@somewhere.com, ...
		char *next, *toNext = MailTo;
		while ((next = strchr(toNext, ',')) != NULL) {		// There is yet 2 or more receivers
			// Enum a new receiver
			*next = '\0';
			sprintf(s,"RCPT TO:<%s>\r\n", toNext);
			addrcursor += sprintf(addrcursor," %s\r\n", toNext);toNext = next+1;
			Post(sc,s);
			Ack(sc);
			if ((addrcursor - addrbuf) > (addrLen - 512))  	// There's less then 512 bytes free in addrbuf
			{
				addrLen += (1024<<2); 						// Increase buffer size of 4K
				unsigned long i = addrcursor - addrbuf;
				if ((addrbuf = (char *) realloc(addrbuf,addrLen)) == NULL) {
					return(DoQuit(OUT_OF_MEMORY));
				}
				addrcursor = addrbuf + i;
			}
		}
		// Enum the last receiver
		sprintf(s,"RCPT TO:<%s>\r\n", toNext);
		addrcursor += sprintf(addrcursor," %s\r\n", toNext);
		Post(sc,s); 	
		if ((iRet=Ack(sc))) {
			Post(sc,"QUIT\r\n");
			return(DoQuit(iRet));
		}
	}

	//***** Send header
	LogMsg.Write(2,"Send EMail (Header)");
	Post(sc,"DATA\r\n"); 
	if ((iRet=Ack(sc))) {
		Post(sc,"QUIT\r\n");
		return(DoQuit(iRet));
	}
	// Print message header according to RFC 822
	// Return-path, Received, Date, From, Subject, Sender, To, cc
	char *pheader, *pheadercursor;
	pheadercursor = pheader = new char[1024<<3]; // 8K for header (except "To:")
	time_t tNow;
	time(&tNow);
	struct tm *tm = localtime(&tNow);
	char *days[] = {"Sun", "Mon","Tue", "Wed", "Thu", "Fri", "Sat"};
	char *months[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
#ifdef _WIN32
	extern long _timezone;
#else
	long _timezone=0;
#endif
	int zoneh = abs(_timezone);
	int zonem;

	zoneh /= (60 * 60);
	zonem = (abs(_timezone) / 60) - (zoneh * 60);

	pheadercursor += sprintf(pheadercursor,"Return-Path: <%s>\r\n", Rpath);
	if (CGIon) {	// Web server is like a Mail server so has to trace route
		pheadercursor += sprintf(pheadercursor,"Received: from %s (%s)\r\n\tby %s\r\n\twith SMTP (%s %s); %s, %02d %s %04d %02d:%02d:%02d %s%02d%02d\r\n",
			MyGetEnv("REMOTE_HOST"),
			MyGetEnv("REMOTE_ADDR"),
			MyGetEnv("SERVER_NAME"),
			PROG, VERSION,
			days[tm->tm_wday],
			tm->tm_mday,
			months[tm->tm_mon],
			tm->tm_year + 1900,
			tm->tm_hour,
			tm->tm_min,
			tm->tm_sec,
			(_timezone > 0) ? "+" : (_timezone < 0) ? "-" : "",
			zoneh,
			zonem);
	}
	pheadercursor += sprintf(pheadercursor,"X-Mailer: %s %s\r\n", PROG, VERSION);
	if ((*DoMime|0x20) == 'y')
	{
		pheadercursor += sprintf(pheadercursor,"Mime-Version: 1.0\r\n");
		pheadercursor += sprintf(pheadercursor,"Content-Type: text/plain; charset=\"iso-8859-1\"\r\n");
		pheadercursor += sprintf(pheadercursor,"Content-Transfer-Encoding: quoted-printable\r\n");
	}
	else
	{
		pheadercursor += sprintf(pheadercursor,"Content-Type: text/plain; charset=us-ascii\r\n");
	}
	// Date of Mail
	pheadercursor += sprintf(pheadercursor, "Date: %s, %02d %s %04d %02d:%02d:%02d %s%02d%02d\r\n",
		days[tm->tm_wday],
		tm->tm_mday,
		months[tm->tm_mon],
		tm->tm_year + 1900,
		tm->tm_hour,
		tm->tm_min,
		tm->tm_sec,
		(_timezone > 0) ? "+" : (_timezone < 0) ? "-" : "",
		zoneh,
		zonem);
	pheadercursor += sprintf(pheadercursor,"From: %s<%s>\r\n", From, Rpath);
	// If subject is US-ASCII, need to be encoded
	int isnotusascii=0;
	for (int i=0;i<(int) strlen(Subject);i++) if (((unsigned char) Subject[i])>127) {isnotusascii=-1;break;}
	pheadercursor += sprintf(pheadercursor,"Subject: %s%s%s\r\n",(isnotusascii&&((*DoMime|0x20)=='y'))?"=?iso-8859-1?Q?":"",isnotusascii?MimeEncode(Subject):Subject,(isnotusascii&&((*DoMime|0x20)=='y'))?"?=":"");

	Post(sc,pheader);delete pheader;
	Post(sc,addrbuf);delete addrbuf;
	// Empty line to indicate end of header
	Post(sc,"\r\n"); 

	//***** Send message	
	LogMsg.Write(2,"Send EMail (Message)");
	if (CGIon) // CGI mode
	{
		for (int i = 0; (i < MAX_ENTRIES) && entries[i].name; i++)
		{
			if (!*entries[i].name)	continue; 					// Avoyd extra blank lines in the message body
			if (!stricmp(entries[i].name,"Submit")) continue;	// May be the name of form
			// Reserved fields
			if (!stricmp(entries[i].name,"LANG")) continue;
			if (!stricmp(entries[i].name,"HOST")) continue;
			if (!stricmp(entries[i].name,"RCPT")) continue;
			if (!stricmp(entries[i].name,"FROM")) continue;
			if (!stricmp(entries[i].name,"SUBJECT")) continue;
			if (stricmp(entries[i].name,"MESSAGE")) {  
				// Send name of field except for MESSAGE field
				Post(sc,"\r\n");Post(sc,MimeEncode(entries[i].name));Post(sc,"\r\n");
			}
			Post(sc,MimeEncode(entries[i].val));Post(sc,"\r\n");
		}
	}
	else // Command line mode
	{
		if (fp == stdin) printf(MessageTypeText[LangNb]);
		// Add text file to message text
		while (fgets(s,sizeof(s) - 3, fp)) {
			p = s + strlen(s) - 1;
			if (*p == '\n') {*p++ = '\r';*p++ = '\n';*p = 0;}	// Change \n in \r\n
			Post(sc,MimeEncode(s));
		}
		// Delete file
		if (fp != stdin)
		{
			fclose(fp);
			if ((*DeleteFileWhenUsed == 'Y') || (*DeleteFileWhenUsed == 'y'))
			remove(mailFile);		// Pour _WIN32
		}
	}
	Post(sc,".\r\n"); // Flag for end of message
	Post(sc,"QUIT\r\n");

	//***** Send end 
	if ((iRet=Ack(sc))) {
		return(DoQuit(iRet));
	}
	return(DoQuit(0));
}


int Post(SOCKET sc, const char * msg)
//********************************************************************
//
//********************************************************************
{
	int len = strlen(msg);
	int slen;
	int index = 0;

	LogMsg.Write(3,"SMTP Posting  : ", msg);
	while (len > 0) {
		if ((slen = send(sc,msg + index,len,0)) < 1) return(DoQuit(FAILED_TO_SEND));
		len -= slen;
		index += slen;
	}
	return(0);
}


int Ack(SOCKET sc)
//********************************************************************
// Get the response from the server. We only want to know if the
// last command was successful. If any error occurs, we just shut down.
// Output:  0 	OK
//			>0	Error
//********************************************************************
{
	static char *buf;
	int sizemail=RECEIVE_BUF_SIZE;
	int rlen;
	int Received = 0;

	if (!buf)
		if ((buf = (char *) malloc(sizemail+1)) == NULL) 	// The first time, create buf
			exit(DoQuit(OUT_OF_MEMORY));
again:
	if ((rlen = recv(sc,buf+Received,sizemail-Received,0)) < 1) return(DoQuit(FAILED_TO_RECEIVE));
	buf[Received+rlen] = 0;LogMsg.Write(3,"SMTP Received : ", buf+Received);
	Received += rlen;

	// Check for newline
	if ((buf[Received-2] != '\r') || (buf[Received-1] != '\n'))	{
		if (! CGIon) LogMsg.Write(3,"Incomplete server message. Awaiting CRLF");
		goto again; // Incomplete data. Line must be terminated by CRLF
	}

	if (buf[0] > '3') { // Return SMTP Error 
		buf[3]=0;
		return(atoi(buf));
	}
	return(0);
}


char *makeword(char *line, char stop) 
//********************************************************************
//
//********************************************************************
{
    int x = 0,y;
    char *word = (char *) malloc(sizeof(char) * (strlen(line) + 1));

    for (x=0;((line[x]) && (line[x] != stop));x++)
        word[x] = line[x];

    word[x] = '\0';
    if (line[x]) ++x;
    y=0;

    while ((line[y++]=line[x++]));
    return word;
}

char *fmakeword(const char *paramstring, char stop, int *cl, int x)
//********************************************************************
//
//********************************************************************
{
    char *word;
    int i,j,nb;
    i=j=nb=0;
    while (1) {
        --(*cl);
        if ((paramstring[i] == stop) || (!(*cl))) {
        	// We found a stop
			LogMsg.Write(2,"Found end of param number",nb);
            LogMsg.Write(2,"Found begin at position",j);
            if ((paramstring[i] != stop) && (paramstring[i] != 0 )) {
	            LogMsg.Write(2,"We reach end of paramstring");
            	// We reach end of paramstring (cl==0), so force end of search
            	i++; nb=x;
            	}
            LogMsg.Write(2,"Found end at position",i);
            if (nb>=x) {
			    word = (char *) malloc(sizeof(char) * (i-j+1));
				strncpy(word,(char *) &paramstring[j],sizeof(char) * (i-j));
				word[i-j]=0;
            	return word;
            }
            else {
            	j=i;j++;nb++;	
            }
        }
        i++;
    }
}

char *fgetstring(FILE *f, int *cl)
//********************************************************************
//
//********************************************************************
{
    int wsize;
    char *word;
    int i;

    wsize = 8192;
    i=0;
    word = (char *) malloc(sizeof(char) * (wsize+1));

    while (1) {
        word[i] = (char) fgetc(f);
        if (i==wsize) {
            wsize+=8192;
            word = (char *) realloc(word,sizeof(char) * (wsize+1));
        }
        --(*cl);
        if (feof(f) || (!(*cl))) {
			i++; word[i] = 0;
            return word;
        }
        ++i;
    }
}


int getline(char *s, int n, FILE *f) 
//********************************************************************
//
//********************************************************************
{
    register int i=0;
	#define LF 10
	#define CR 13
    while (1) {
        s[i] = (char)fgetc(f);
        if (s[i] == CR) s[i] = fgetc(f);
        if((s[i] == 0x4) || (s[i] == LF) || (i == (n-1))) {
            s[i] = '\0';
            return (feof(f) ? 1 : 0);
        }
        ++i;
    }
	return(0);
}

void send_fd(FILE *f, FILE *fd)
//********************************************************************
//
//********************************************************************
{
    char c;

    while (1) {
        c = fgetc(f);
        if (feof(f)) return;
        fputc(c,fd);
    }
}


int ind(char *s, char c) 
//********************************************************************
//
//********************************************************************
{
    register int x;
    for(x=0;s[x];x++) {
        if(s[x] == c) return x;
	}
    return -1;
}


char *cgiLookup(char *tag, char *default_tag)
//********************************************************************
// Return value of parameter tag from CGI list of parameters 
// Output:	found value or default_tag if tag not found
//********************************************************************
{
	for (int i=0; (i<MAX_ENTRIES) && entries[i].name; i++)
	{
		if (!strcmp(entries[i].name,tag))
			return (entries[i].val && *entries[i].val) ? entries[i].val : default_tag;
	}
	return default_tag;
}


char *MyGetEnv(char *tag)
//---------------------------------------------------------------------------
// Return value off the tag environment variable
//---------------------------------------------------------------------------
{
	char *p = getenv(tag);
	if (!p) return "(NULL)";
	char *rval = new char[strlen(p)+1];
	strcpy(rval,p);
	return rval;
}



int main(int argc, char **argv)
//---------------------------------------------------------------------------
// MAIN
//---------------------------------------------------------------------------
{

// Exploite parametres
//--------------------
int noarg,curseurarg,help=0,invalide=0;
char option;
getcwd(ficini,sizeof(ficini));
// Compense bug de getcwd
if ((ficini[0] == '/') && (ficini[1] == '/') && (ficini[3] == '/')) {
	ficini[0]=ficini[2];ficini[1]=':';ficini[2]='/';
	}

strcat(ficini,"/"FILEINI);
for (noarg=1;noarg<argc;noarg++) {
	if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
		option=(argv[noarg][1] | 0x20);
		curseurarg=2;
		if (strlen(argv[noarg]) < 3) { ++noarg; curseurarg=0; }
		switch (option) {
			case 'u': MailTo = ParseRCTP(argv[noarg]+curseurarg); break;				// EMail receiver list
			case 'c': break;															// EMail CC
			case 's': strncpy(Host,argv[noarg]+curseurarg,sizeof(Host)); break;			// SMTP server hostname
			case 't': strncpy(Subject,argv[noarg]+curseurarg,sizeof(Subject)); break;	// Topic/Subject
			case 'f': strncpy(Rpath,argv[noarg]+curseurarg,sizeof(Rpath)); break;		// From (EMail address used for "Return-Path")
			case 'g': strncpy(From,argv[noarg]+curseurarg,sizeof(From)); break;			// From (Text used for "From")
			case 'm': strcpy(DoMime,"Yes"); break;										// Use MIME encoding
			case 'd': LogMsg.Reset();
					  LogMsg.ErrorLevel=max((int) (argv[noarg][curseurarg])-48,0);
					  break;													// Debug on
			case 'l': strncpy(Lang,argv[noarg]+curseurarg,sizeof(Lang));break;	// Language
			case '?': help=-1; break;											// Help
			case 'h': help=-1;break;											// Help
			case 'v': help=-1;break;											// Help
			default: invalide=-1;break;
		}
	}
	else {
		strcpy(mailFile,argv[noarg]);											// Mail file to send
	}
}

// Affiche en-tete
//----------------
Usage:
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("%s is a freeware that allow you to send Mail from the command line\n",PROG);
	printf("or from your WWW Browser (%s works as a CGI).\n",PROG);
	printf("%s can also send WWW forms with up to %i fields.\n",PROG,MAX_ENTRIES-5);
	printf("%s sources can be compiled for WIN32 (VC++ or GCC) or for Unix/Linux (GCC)\n",PROG);
}
if (help|invalide) {
	if (invalide) printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage: %s params [options] message\n",PROG);
	printf("Params:\n");
	printf("  -uEMail | -u@EMailFile         EMail address or file of EMail addresses\n");
	printf("  -sSMTPServerHostname           SMTP Server Adress\n");
	printf("Options (if not specified, are read from %s):\n",FILEINI);
	printf("  -tTopic/Subject                Subject of the Mail\n");
	printf("  -fFrom                         EMail Address of sender for reply\n");
	printf("  -gFrom                         Full name of sender\n");
	printf("  -mime                          Code Mail in Mime\n");
	printf("  -lF                            Language is French\n");
	printf("  -dX                            Show level X debug info\n");
	printf("Message:\n");
	printf("  message_file | <message        Message in file or from pipe\n");
	printf("\n");
	exit(0);
	}


// Get CGI Info
//-------------
if (ParseCgiInfo(&CGIon)) return(DoQuit(FAILED_TO_PARSE_CGI));
if (CGIon) {
        strncpy(Lang,cgiLookup("LANG",Lang),sizeof(Lang));
        strncpy(Host,cgiLookup("HOST",Host),sizeof(Host));
        strncpy(Rpath,cgiLookup("FROM",Rpath),sizeof(Rpath));
        strncpy(From,cgiLookup("FROM2",From),sizeof(From));
        strncpy(Subject,cgiLookup("SUBJECT",Subject),sizeof(Subject));
}

// Get .ini file data
//-------------------
Port=GetPrivateProfileInt("Config","PortSMTP",25,ficini);
if (Host[0]==0)		GetPrivateProfileString("Config","Host","",Host,sizeof(Host),ficini);
if (Subject[0]==0)	GetPrivateProfileString("Config","Subject","",Subject,sizeof(Subject),ficini);
if (Rpath[0]==0)	GetPrivateProfileString("Config","Return Path","",Rpath,sizeof(Rpath),ficini);
if (From[0]==0)		GetPrivateProfileString("Config","From","",From,sizeof(From),ficini);
if (DoMime[0]==0)	GetPrivateProfileString("Config","Mime Encoding","Yes",DoMime,sizeof(DoMime),ficini);
GetPrivateProfileString("Config","Delete File When Used","No",DeleteFileWhenUsed,sizeof(DeleteFileWhenUsed),ficini);
GetPrivateProfileString("Config","Restrict Email","No",RestrictEmail,sizeof(RestrictEmail),ficini);
GetPrivateProfileString("CGI","IIS header","No",UseIIS,sizeof(UseIIS),ficini);
GetPrivateProfileString("CGI","HTML Head Send","<HTML><BODY leftmargin=20 topmargin=10>",HTMLhead,sizeof(HTMLhead),ficini);
GetPrivateProfileString("CGI","HTML End Send","</BODY></HTML>",HTMLend,sizeof(HTMLend),ficini);

// Si "REMOTE_USER" dans Rpath, on le remplace par valeur de REMOTE_USER
//----------------------------------------------------------------------
if ((strstr(Rpath,"REMOTE_USER")==Rpath) && (strcmp(MyGetEnv("REMOTE_USER"),"(NULL)")!=0)) {
	LogMsg.Write(3,"Substitute REMOTE_USER in Rpath = ",Rpath);
	LogMsg.Write(3,"Substitute REMOTE_USER in Rpath with ",MyGetEnv("REMOTE_USER"));
	// Use LocalHost as temporary variable
	strncpy(LocalHost,Rpath,min(sizeof(LocalHost),sizeof(Rpath)));
	strcpy(Rpath,MyGetEnv("REMOTE_USER"));
	strcat(Rpath,LocalHost+strlen("REMOTE_HOST"));
	}


switch(Lang[0] | 0x20) {
	case 'f': LangNb=1;break;
	default : LangNb=0;break;
}

// If HTMLxxx is a file
//---------------------
if (HTMLhead[0]=='@') {
	FILE *hFile;
	if ((hFile=fopen(HTMLhead+1,"rt"))==NULL) {
		strcpy(HTMLhead,"<HTML><BODY leftmargin=20 topmargin=10>");
	}
	else {
		HTMLhead[0]=0;
		while (fgets(HTMLhead+strlen(HTMLhead),sizeof(HTMLhead)-strlen(HTMLhead),hFile));
		fclose(hFile);
	}
}
if (HTMLend[0]=='@') {
	FILE *hFile;
	if ((hFile=fopen(HTMLend+1,"rt"))==NULL) {
		strcpy(HTMLend,"</HTML></BODY>");
	}
	else {
		HTMLend[0]=0;
		while (fgets(HTMLend+strlen(HTMLend),sizeof(HTMLend)-strlen(HTMLend),hFile));
		fclose(hFile);
	}
}

// Log parameters
//---------------
LogMsg.Write(2,"Option file : ",ficini);
LogMsg.Write(2,"Debug level : ",LogMsg.ErrorLevel);
LogMsg.Write(2,"Language : ",LangNb);
if ((!CGIon) && (MailTo)) LogMsg.Write(2,"Mail To  : ",MailTo);	// Never defined in CGI
LogMsg.Write(2,"Host     : ",Host);
LogMsg.Write(2,"Port     : ",Port);
LogMsg.Write(2,"Rpath    : ",Rpath);
LogMsg.Write(2,"From     : ",From);
LogMsg.Write(2,"Subject  : ",Subject);
LogMsg.Write(2,"MIME     : ",DoMime);
LogMsg.Write(2,"Delete   : ",DeleteFileWhenUsed);
LogMsg.Write(2,"Restrict : ",RestrictEmail);
LogMsg.Write(2,"HTMLhead : ",HTMLhead);
LogMsg.Write(2,"HTMLend  : ",HTMLend);

// Check parameters
//-----------------
if ((!CGIon) && ((Host[0]==0) || (!MailTo))) {
	invalide=-1;
	goto Usage;
}

// Print HTML Header
//------------------
if (CGIon) {
 	printf("Content-type: text/html%c%c\n\n",10,10);
 	printf("%s",HTMLhead);
	if (Subject[0]==0) return(DoQuit(SUBJECT_REQUIRED));
	if (Host[0]==0) return(DoQuit(HOST_REQUIRED));
}


// Envoi du mail
iRet=mail_connect();

// Print HTML Ender
//-----------------
if (CGIon) printf("%s",HTMLend);

if (MailTo != NULL) free(MailTo);

return(iRet);
}


// Most important RFC spec
// 1) Line size is 72 char max (use folder)
// 2) CRLF+CRLF = end of header
// 2) CRLF+'.'+CRLF = end of message
// x) etc...
