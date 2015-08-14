//---------------------------------------------------------------------------
// GetMess
//
// Get mails of POP3 account from command line or from a HTTP form (use CGI GET or POST method)
// It applies to the RFC 821 and RFC 822 specs 
// It supports MIME 1.0 encoding of European national characters.
//
// Tested with :
// VC++ 4.0		(WIN32)
// GCC 2.8.1	(WIN32)
// GCC 2.7.3	(Aix 4.x)
// GCC 2.9		(Linux 2.0.x)
//---------------------------------------------------------------------------
// 08/01/99	1.1		Laurent Destailleur	Creation
// 15/10/99	1.2		Allow to delete several messages in action command
// 29/12/99	1.8		Use now good fonctions base64_decode and quoted_decode
//---------------------------------------------------------------------------
// Required field if used as a CGI-BIN application:
// HOST    = POP3 Server name
// USER    = EMail POP3 account
// PASSWD  = EMail POP3 password
//
// Optionnal fields if used as a CGI-BIN application:
// ACTION  = Action to do (l,g,d)
// LANG	   = Language of messages
//---------------------------------------------------------------------------
#define PROG	"GetMess"
#define VERSION	"1.9"

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
#define SOCKET int			// Non defini sous Unix
#define INVALID_SOCKET (SOCKET)(~0)	// Non defini sous Unix
#define SOCKADDR_IN struct sockaddr_in	// Non defini sous Unix
#define LPHOSTENT struct hostent *	// Non defini sous Unix
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
//#include <sockets.h>	// Fichier a modifier sous GCC WIN32 pour contourner bug !!!
//#include <functions.h>
#endif
#endif

#include "misc.h"
#include "CLogMsg.h"
#include "crypt.h"
#include "macros.h"


#define MAX_ENTRIES 10					// SUBJECT, HOST, USER, PASSWD
#define MAX_MAILS 	100					// Nb max of mails managed
#define FILEINI "awmess.conf"
#define SIZE_RECEIVE_BUFFER 4096		// Ko
#define SIZE_BLOCK_FILELIST 256			// Size of block used to extend by alloc/realloc files list string

#define UNKNOWN_ERROR 1
#define BAD_ACTION 2
#define BAD_PASSWORD  3
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
#define NB_OF_MAILS 14
#define SIZE_OF_MAILS 15
#define BAD_USER 16
#define BAD_HOST 17
#define TO_MANY_MAILS 18
#define MAIL_UNKNOWN 19
#define BAD_CGIEXE 20
#define MAIL_DELETED 21
#define BAD_FORMAT_MAIL 22

#define SIZE_TEXT 23
#define FROM_TEXT 24
#define SUBJECT_TEXT 25
#define ATTACHED_FILE_TEXT 26
#define NONE_TEXT 27
#define DELETE_TEXT 28


// Types
typedef struct {
	char *mail;
	unsigned long int size;
	char *received_time;
	char *subject;
	char *return_path;
	char *from;
	char *status;
	char *mime_version;
	char *files;
} mailentry;

typedef struct {
    char *name;
    char *val;
} entry;


// Variables
entry entries[MAX_ENTRIES];				// Tab of CGI entries		First=0
mailentry tabmails[MAX_MAILS+1];		// Tab of mails entries		First=1
char *Messages[][2] = { 
	{{"Mail successfully sent.\n"},			{"Mail envoyé avec succès.\n"}},
	{{"Error: UNKNOWN ERROR\n"},			{"Erreur: Erreur inconnue.\n"}},
	{{"Error: Unknown action command\n"},	{"Erreur: Parametre 'Action' inconnu.\n"}},
	{{"Error: Bad password.\n"},			{"Erreur: Mot de passe incorrect.\n"}},
	{{"Error: FAILED_TO_START_SOCKETS\n"},	{"Erreur: Echec de la fonction WSAStartup.\n"}},
	{{"Error: FAILED_TO_RESOLVE_HOST\n"},	{"Erreur: Echec de la resolution DNS du nom du serveur POP.\n"}},
	{{"Error: FAILED_TO_OBTAIN_SOCKET_HANDLE\n"},{"Erreur: Echec de la creation de la socket.\n"}},
	{{"Error: FAILED_TO_CONNECT\n"},		{"Erreur: Echec de la connexion au serveur.\n"}},
	{{"Error: FAILED_TO_SEND\n"},			{"Erreur: Echec de l'envoi paquet.\n"}},
	{{"Error: FAILED_TO_RECEIVE\n"},		{"Erreur: Echec en reception d'un paquet.\n"}},
	{{"Error: SERVER_ERROR\n"},				{"Erreur: Pas de reponse du serveur a l'initialisation du protocol POP.\n"}},
	{{"Error: Failed to get my own IP address\n"},{"Erreur: Echec a la recuperation du mon propre hostname.\n"}},
	{{"Error: Out of memory\n"},			{"Erreur: Memoire insuffisante.\n"}},
    {{"Error: Bad arguments from CGI form.\n"},	{"Erreur: Ligne de commande CGI incorrecte ou incomplète.\n"}},
    {{"Number of mails : "},	{"Nombre de messages : "}},
	{{"byte"},{"octet"}},
	{{"Error: 'Login' field is required.\n"},	{"Erreur: Le champ 'LOGIN' est obligatoire.\n"}},
	{{"Error: 'POP Server' field is required.\n"},{"Erreur: Le champ 'SERVEUR POP' est obligatoire.\n"}},
	{{"Error: To many mails in mailbox.\n"},{"Erreur: Trop de messages en boite aux lettres.\n"}},
	{{"Error: Mail doesn't exist.\n"},{"Erreur: Mail inexistant.\n"}},
	{{"Error: Unable to get name of CGI Script (SCRIPT_NAME).\n"},{"Erreur: Impossible de récupérer le nom du script CGI (SCRIPT_NAME).\n"}},
	{{"deleted."},{"effacé(s)."}},
	{{"Error: Mail has a bad format. Mail was sended from a bad software.\n"},{"Erreur: Format de mail incorrect. Mail envoyé par un logiciel non conforme. Informer webmaster@partenor.com sans effacer vos mails pour debugage.\n"}},
	{{"Size   "},{"Taille"}},
	{{"From   "},{"De    "}},
	{{"Subject"},{"Sujet "}},
	{{"Joined file(s)"},{"Fichier(s) joint(s)"}},
	{{"None"},{"Aucun"}},
	{{"Delete"},{"Effacer"}}
};

BOOL CGIon=FALSE;
char Lang[2]="E";					// Use English by default
int  LangNb;						// 0, 1, 2...
int  iRet;
int  iNbUnread;						// Nb of unread mails
unsigned long int lSizeUnread;		// Size of all unread mails
char ficini[MAX_PATH];
int  Port;							// POP3 Host port
char User[128];						// Login
char Password[128];					// Password
char Host[MAXHOSTNAMELEN];			// POP3 Host IP name
char CGIExe[256];					// Chemin + nom script CGI pour inclusion dans page reponse
char CGIRep[256];					// Chemin script CGI
char Action[128]="l";				// POP3 action to do (list, get, delete...)
char DoMime[4];
char HTMLhead[1024];
char HTMLend[1024];
#ifdef _WIN32
WSADATA Data;
#endif

// Functions
void chartospace(char *str,char c);
void unescape_url(char *url,char escape);
char *makeword(char *line,char stop);
char *fmakeword(FILE *f,char stop,int *len);
int ind(char *s,char c);
int ParseCgiInfo();
int mail_connect();
BOOL Post(SOCKET sc,const char *msg);
int Ack(SOCKET sc);
int Ack_Stat(SOCKET sc,int *iNbUnread,unsigned long int *lSizeUnread);
int Ack_Mail(SOCKET sc,int mailcpt,const unsigned long int liMailSize);
int DoQuit(int iRet);
char *cgiLookup(char *tag,char *default_tag);

// Classes
CLogMsg LogMsg(PROG".log");




void chartospace(char *str,char c)
//---------------------------------------------------------------------------
// Replace c char by space char in str string
//---------------------------------------------------------------------------
{
    register int x;
    for (x=0;str[x];x++) if(str[x] == c) str[x] = ' ';
}

char x2c(const char *what) 
//---------------------------------------------------------------------------
// Convert a string "XX" in a the char with XX ASCII value
//---------------------------------------------------------------------------
{
    register char digit;
    digit = (what[0] >= 'A' ? ((what[0] & 0xDF) - 'A')+10 : (what[0] - '0'));
    digit = digit << 4;
    digit += (what[1] >= 'A' ? ((what[1] & 0xDF) - 'A')+10 : (what[1] - '0'));
    return(digit);
}

void unescape_url(char *url,char escape)
//---------------------------------------------------------------------------
// Change "escapeXX" in the char with XX ASCII value
//---------------------------------------------------------------------------
{
    register int x,y;
    for (x=0,y=0;url[y];++x,++y) {
        if ((url[x] = url[y]) == escape) {
            url[x] = x2c((const char *) &url[y+1]);
            y+=2;
        }
    }
    url[x] = '\0';
}

void escape_url(char *url) 
//---------------------------------------------------------------------------
// Function	: Code an url with URL escape sequences
// Input	: url = url to code
// Ouput	: url = coded url 
//---------------------------------------------------------------------------
{
    register int x,y;
    for (x=0;url[x];x++) {
        if (ind(" &;`'\"|*?~<>^()[]{}$\\",url[x]) != -1) { // Found a char to escape
            for (y=(int) strlen(url);y>x;y--) url[y+2] = url[y];
            url[x+2]=((url[x] & 0x0F)+48);url[x+1]=((url[x]>>4)+48);url[x] = '%';
            x+=2;
        }
    }
}

int DecodeHeaderField(char *data)
//---------------------------------------------------------------------------
// Function : Decode a MIME coded POP header field (Subject, Comments, X-...)
//         	  Applies to RFC 1521 and 1522
// Input	: data = coded string
//			         =?iso-8859-X?C?zzzz?=
// 	          		 ...=20...
// Output	: data = decoded string
// Return	: 0 = Ok, >0 = Bad format of coded data
//---------------------------------------------------------------------------
{
	int i,pos;
	char *p,*q,*r;	// p=1st coded string pointer, q=2nd coded string pointer
	char *bufdecoded;
	int sizedecoded;

	while ((r=strstr(data,"=?"))!=NULL) { 		// Search all coded parts
		p=r+strlen("=?");
		if (StrStr(p,"iso-8859-")==p) {			// MIME encoded as ISO-8859-X
			if ((pos=ind(p,'?')) < 0) return(1);
			p=p+pos+1;
			if ((pos=ind(p,'?')) < 0) return(2); 
			// MIME encoded in Quoted printable format
			if (!strnicmp(p,"Q",pos)) {			
				p=p+pos+1;
				if ((q=strstr(p,"?="))==NULL) return(3);
				q[0]=0;q=q+2;
				unescape_url(p,'=');
				chartospace(p,'_');
				for (i=0;p[i];i++) data[r-data+i]=p[i];	 // data = decoded part
 				data[r-data+i]=0;
				strcat(data,q);					// data = data + rest
			}
			// MIME encoded in Base64
			if (!strnicmp(p,"B",pos)) {
				p=p+pos+1;
				if ((q=strstr(p,"?="))==NULL) return(3);
				q[0]=0;q=q+2;					// q = rest
				if ((bufdecoded=(char *) malloc(strlen(p)+4)) == NULL) return(OUT_OF_MEMORY);
				sizedecoded=base64_decode(p,(void *) bufdecoded);	// Decode
				for (i=0;bufdecoded[i];i<sizedecoded) data[r-data+i]=bufdecoded[i++];	 // data = decoded part
				free(bufdecoded);
 				data[r-data+i]=0;
				strcat(data,q);					// data = data + rest
			}
		}
												// MIME encode US-ASCII

	}
	LogMsg.Write(3,"Decoded field     :",data);
	return(0);
}


int SaveFile(void * data, int datasize, char * filename)
//---------------------------------------------------------------------------
// Input  : data
//          datasize
//          filename =	Name of file to write
// Output : filename =  New filename if file already exist and CGI
//			filename = "Error, can't open file xxx" if error
// Return :	0 	= Success
//			>0 	= Error
//---------------------------------------------------------------------------
{
FILE *hFile;
char s[256];
if (CGIon) {
	// Create CGIRep
	strcpy(s,CGIRep);strcat(s,"/");strcat(s,filename);
}
else {
	strcpy(s,filename);
}

// Check if already exist
if (1==2) {
	// Ask to overwrite
	if (CGIon) {
			// Change filename


			LogMsg.Write(3,"File renamed to:",filename);
	}
	else {
		
			LogMsg.Write(3,"File wil be overwritted");
	}
}

// Open, write an close file
LogMsg.Write(2,"Write file name:",s);
if ((hFile=fopen(s,"wb"))==NULL) {
	sprintf(filename,"Error: Failed to open file %s",s);
	if (!CGIon) printf("%s",filename);
	return(1);
}
LogMsg.Write(2,"Write file size:",datasize);
fwrite(data,(size_t) datasize,(size_t) 1,hFile);
fclose(hFile);
return(0);
}


int ParseCgiInfo(BOOL *CGIon)
//---------------------------------------------------------------------------
// Function	: Detect if we work in CGI Mode
// Input	: None
// Ouput  	: CGIon = TRUE or FALSE
//	          entries[] = tab of CGI parameters
// Return 	: 0	= OK, >0 = Error
//---------------------------------------------------------------------------
{
	register int x,cl;

	char *p = getenv("REQUEST_METHOD");
	if (!p || !*p) { *CGIon=FALSE; return(0); };

	*CGIon=TRUE;
	
	LogMsg.Write(3,"CGI REQUEST_METHOD:",p);
	if (stricmp(p,"GET") && stricmp(p,"POST")) {
		printf("This CGI script should be referenced with a METHOD of GET or POST.\n");
		return(1);
	}

	if (stricmp(p,"POST")==0) {	// Fill entrie tab with CGI arguments (POST METHOD = from stdin)
		cl = atoi(getenv("CONTENT_LENGTH"));
		LogMsg.Write(3,"CGI CONTENT_LENGTH:", cl);
		for (x=0;cl && (!feof(stdin)) && (x<MAX_ENTRIES);x++) {
			entries[x].val = fmakeword(stdin,'&',&cl);
			chartospace(entries[x].val,'+');
			unescape_url(entries[x].val,'%');
			entries[x].name = makeword(entries[x].val,'=');
		}
	}
	if (stricmp(p,"GET")==0) {	// Fill entrie tab with CGI arguments (GET METHOD = from QUERY_STRING)
		if (!(p=getenv("QUERY_STRING"))) return(2);
		LogMsg.Write(3,"CGI QUERY_STRING  :",p);
		for (x=0; x<(int) strlen(p) && (x<MAX_ENTRIES); x++) {
			entries[x].val = makeword(p,'&');	// p is changed by makeword
			chartospace(entries[x].val,'+');
			unescape_url(entries[x].val,'%');
			entries[x].name = makeword(entries[x].val,'=');
			LogMsg.Write(3,"val",entries[x].val);
			LogMsg.Write(3,"name",entries[x].name);
		}
	}

	return(0);
}


int printline(const char *s)
//---------------------------------------------------------------------------
// Print string s on stdout (Don't touch <> tags)
//---------------------------------------------------------------------------
{
	int taghtml=0;
	for (size_t i=0;i<strlen(s);i++) {
		if (s[i]=='<') ++taghtml;
		if (s[i]=='>') --taghtml;
		if ((s[i]==' ') && (CGIon) && (taghtml<1)) printf("&nbsp;");
		else printf("%c",s[i]);
		if ((s[i]=='\n') && (CGIon)) printf("<br>");
	}
	return(0);
}


int DoQuit(int iRet)
//---------------------------------------------------------------------------
// Show result
//---------------------------------------------------------------------------
{
	if (iRet) {	// Error
		printf(Messages[iRet>22?1:iRet][LangNb]);
		char info[256];
		sprintf(info,"%s",Messages[iRet>22?1:iRet][LangNb]);
		LogMsg.Write(1,info);
	}
	else {		// OK
		if (CGIon) {
			char info[256];
			sprintf(info,"%i message(s) for <%s>",iNbUnread,User);
			LogMsg.Write(1,info);
			}
	}
	return(iRet);
}


int mail_get()
//---------------------------------------------------------------------------
// Init socket, get list of mails
//---------------------------------------------------------------------------
{
	SOCKET sc;
	char bold[4],unbold[5];
	char s[2048],t[256];
	int i,firstmail,lastmail,mailcpt;
	
	// Check if all parameters are known
	if (CGIon) {
		if (User[0]==0) return(DoQuit(BAD_USER));
		if (Password[0]==0) return(DoQuit(BAD_PASSWORD));
		if (Host[0]==0) return(DoQuit(BAD_HOST));
		if (CGIExe[0]==0) return(DoQuit(BAD_CGIEXE));
	}

	if (CGIon) { strcpy(bold,"<b>");strcpy(unbold,"</b>"); }
	else { strcpy(bold,"");strcpy(unbold,""); }

startgetmess:

	//***** Get mailfile
#ifdef _WIN32
	if (WSAStartup(MAKEWORD(1, 1), &Data) != 0) return(DoQuit(FAILED_TO_START_SOCKETS));
#endif

	//***** Create Socket
	LogMsg.Write(2,"Create socket: socket(PF_INET,SOCK_STREAM)");
	if ((sc = socket(PF_INET,SOCK_STREAM,0)) == INVALID_SOCKET)
	{
		return(DoQuit(FAILED_TO_OBTAIN_SOCKET_HANDLE));
	}

	//***** Resolve the servers IP
	LogMsg.Write(2,"Resolve IP address for:",Host);
	struct hostent *adr;
	adr = gethostbyname(Host);
	if (!adr)
	{
		return(DoQuit(FAILED_TO_RESOLVE_HOST));
	}
	
	//***** Connect to server
	SOCKADDR_IN sin;
	sin.sin_port = htons((u_short) Port);
	sin.sin_family = adr->h_addrtype;
	memcpy((char *) &sin.sin_addr, adr->h_addr, adr->h_length);
	char AddrHexa[9];
	sprintf(AddrHexa,"%08lX",* (unsigned long int *) &sin.sin_addr);
	AddrHexa[8]=0;
	LogMsg.Write(2,"Connect socket to:",AddrHexa);
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
		return(DoQuit(iRet));
	}

	//***** Send user
	sprintf(s,"USER %s\r\n", User);
	Post(sc,s);
    if ((iRet=Ack(sc))) {
		Post(sc,"QUIT\r\n");	// Disconnect
		return(DoQuit(BAD_USER));
    }
	//***** Send password
	sprintf(s,"PASS %s\r\n", Password);
	Post(sc,s);
    if ((iRet=Ack(sc))) {
		return(DoQuit(BAD_PASSWORD));
    }

	//***** Step 1 : Parse action command
	switch(Action[0]|0x20) {
		case 'd':		// Delete
			firstmail=abs(atoi(&Action[1]));lastmail=firstmail;
			if (strstr(&Action[1],"-")) {
				lastmail=abs(min(atoi(strstr(&Action[1],"-")+1),MAX_MAILS));
				LogMsg.Write(3,"No of firstmail to delete:",firstmail);
				LogMsg.Write(3,"No of lastmail  to delete:",lastmail);
			}
			//***** Send DELE command
			for (mailcpt=firstmail;mailcpt<=lastmail;mailcpt++) {
				sprintf(s,"DELE %i\r\n", mailcpt);
				Post(sc,s);
			    if ((iRet=Ack(sc))) break;
			}
			if ((mailcpt-firstmail)==0) { 	// No mail deleted
					Post(sc,"QUIT\r\n");
					return(DoQuit(MAIL_UNKNOWN));
			    }
			// Show result
			if (!CGIon)	{
				if ((mailcpt-firstmail)==1) sprintf(t,"%i",firstmail);	// One mail deleted
				else sprintf(t,"%i-%i",firstmail,mailcpt-1);			// Several mails deleted
				sprintf(s,"%s%i%s message(s) %s (No %s%s%s)\n",bold,(mailcpt-firstmail),unbold,Messages[MAIL_DELETED][LangNb],bold,t,unbold);
				printline(s);
				break;
			}
			else {
				Action[0]='l';
				Post(sc,"QUIT\r\n");		// To end session and validate deleting
				Ack(sc);
				goto startgetmess;
			}

		case 'p':		// Purge from black list
		case 'l':		// List
			//***** Send STAT command
			Post(sc,"STAT\r\n"); 
			if ((iRet=Ack_Stat(sc,&iNbUnread,&lSizeUnread))) {
				Post(sc,"QUIT\r\n");
				return(DoQuit(iRet));
			}
			LogMsg.Write(2,"Number of mails:",iNbUnread);
			LogMsg.Write(2,"Total Size     :",lSizeUnread);

			strcpy(s,Messages[NB_OF_MAILS][LangNb]);
			sprintf(t," %s%i%s",bold,iNbUnread,unbold);strcat(s,t);
			sprintf(t,"  (%s%li%s %s%s)\n\n",bold,lSizeUnread,unbold,Messages[SIZE_OF_MAILS][LangNb],(iNbUnread==0?"":"s"));strcat(s,t);
			printline(s);
			if (CGIon) printline("</center>");
			firstmail=1;lastmail=((iNbUnread>MAX_MAILS)?MAX_MAILS:iNbUnread);
			break;
		case 'g':		// Get
			//***** Send STAT command
			Post(sc,"STAT\r\n"); 
			if ((iRet=Ack_Stat(sc,&iNbUnread,&lSizeUnread))) {
				Post(sc,"QUIT\r\n");
				return(DoQuit(iRet));
			}
			LogMsg.Write(2,"Number of mails:",iNbUnread);
			LogMsg.Write(2,"Total Size     :",lSizeUnread);
			firstmail=atoi(&Action[1]);lastmail=atoi(&Action[1]);
			if ((firstmail<1) || (firstmail>iNbUnread)) {
				Post(sc,"QUIT\r\n");
				return(DoQuit(MAIL_UNKNOWN));
				}
			sprintf(s,"Message %s%i/%i%s\n\n",bold,firstmail,iNbUnread,unbold);
			printline(s);
			if (CGIon) printline("</center>");
			if (firstmail>MAX_MAILS) {
				Post(sc,"QUIT\r\n");
				return(DoQuit(TO_MANY_MAILS));
				}
			break;
		default :
			Post(sc,"QUIT\r\n");
			return(DoQuit(BAD_ACTION));
	}

	//***** Step 2 : Format table
	if (CGIon) printline("<table BORDER=\"0\" CELLPADDING=\"0\" CELLSPACING=\"0\" WIDTH=\"100%\">");
	for (mailcpt=firstmail;mailcpt<=lastmail;mailcpt++) {
		switch(Action[0]|0x20) {
			case 'd':		// Delete
				LogMsg.Write(1,"Deleting mail(s):",lastmail-firstmail+1);

					//***** Do nothing (everythinghas already be done)
				break;

			case 'p':		// Purge from black list
			case 'l':		// List
				LogMsg.Write(1,"Listing mail(s):",lastmail-firstmail+1);

				//***** Send LIST command
				sprintf(s,"LIST %i\r\n",mailcpt);
				Post(sc,s);
				if ((iRet=Ack_Stat(sc,&mailcpt,&tabmails[mailcpt].size))) {
					Post(sc,"QUIT\r\n");
					return(DoQuit(iRet));
				}
				LogMsg.Write(2,"Size of mail:",tabmails[mailcpt].size);

				//***** Send TOP command
				sprintf(s,"TOP %i 0\r\n",mailcpt);
				Post(sc,s);		
				if ((iRet=Ack_Mail(sc,mailcpt,SIZE_RECEIVE_BUFFER))) {	// Get Header
					Post(sc,"QUIT\r\n");								// Disconnect
					return(DoQuit(iRet));
				}

				if (CGIon) printf(mailcpt&0x1?"<tr bgcolor=#FFEFC6><td nowrap><font face=\"Courier\" size=2>":"<tr><td nowrap><font face=\"Courier\" size=2>");
				sprintf(s,"%s%3i%s - %s: %s%li%s ko %s%40s%s \n",bold,mailcpt,unbold,Messages[SIZE_TEXT][LangNb],bold,(tabmails[mailcpt].size>>10)+1,unbold,bold,tabmails[mailcpt].received_time,unbold);
				printline(s);
				sprintf(s,"%s   %s   %s: %s",bold,unbold,Messages[FROM_TEXT][LangNb],bold);
				printline(s);
				for (i=0;i<(int) strlen(tabmails[mailcpt].from);i++) {
					if ((tabmails[mailcpt].from[i]=='<') && CGIon) {printf("&lt;");continue;}
					if ((tabmails[mailcpt].from[i]=='>') && CGIon) {printf("&gt;");continue;}
					printf("%c",tabmails[mailcpt].from[i]);
				}			
				sprintf(s,"%s\n",unbold);
				printline(s);
				if (CGIon) {
					sprintf(s,"%s   %s   %s: %s",bold,unbold,Messages[SUBJECT_TEXT][LangNb],bold);
					printline(s);
					sprintf(s,"<a href=%s?LANG=%c&ACTION=g%i&USER=%s&HOST=%s&PASSWORD=%s>",CGIExe,Lang[0],mailcpt,User,Host,Password);
					printline(s);
					if (strlen(tabmails[mailcpt].subject)<1) sprintf(s,"%s</a>%s\n",Messages[NONE_TEXT][LangNb],unbold);
					else sprintf(s,"%s</a>%s\n",tabmails[mailcpt].subject,unbold);
					printline(s);
				}
				else {
					sprintf(s,"      Subject: %s\n",tabmails[mailcpt].subject);
					printline(s);
				}
				if (CGIon) {	
					printline("</td>");
					// Add row with 'delete' button
					printline("<td align=\"center\">");
					sprintf(s,"<form action=\"%s\" method=\"POST\">",CGIExe);
					printline(s);
					sprintf(s,"<input type=\"hidden\" name=\"LANG\" value=\"%s\">",Lang);
					printline(s);
					sprintf(s,"<input type=\"hidden\" name=\"ACTION\" value=\"d%i\">",mailcpt);
					printline(s);
					sprintf(s,"<input type=\"hidden\" name=\"USER\" value=\"%s\">",User);
					printline(s);
					sprintf(s,"<input type=\"hidden\" name=\"PASSWORD\" value=\"%s\">",Password);
					printline(s);
					sprintf(s,"<input type=\"hidden\" name=\"HOST\" value=\"%s\">",Host);
					printline(s);
					sprintf(s,"<input type=\"submit\" value=\"%s\">",Messages[DELETE_TEXT][LangNb]);
					printline(s);
					printline("</form></td>");
					printline("</tr>");
					printf("\n");
					}
				break;

			case 'g':		// Get
				LogMsg.Write(1,"Getting mail no:",lastmail-firstmail+1);

				//***** Send LIST command (to know size)
				sprintf(s,"LIST %i\r\n",mailcpt);
				Post(sc,s);
				if ((iRet=Ack_Stat(sc,&mailcpt,&tabmails[mailcpt].size))) {
					Post(sc,"QUIT\r\n");
					return(DoQuit(iRet));
				}
				LogMsg.Write(2,"Size of mail:",tabmails[mailcpt].size);

				//***** Send RETR command
				sprintf(s,"RETR %i\r\n",mailcpt);
				Post(sc,s);		
				if ((iRet=Ack_Mail(sc,mailcpt,tabmails[mailcpt].size))) {
					Post(sc,"QUIT\r\n");	// Disconnect
					return(DoQuit(iRet));
				}
				// Write header
				LogMsg.Write(3,"Write header to stdout");
				sprintf(s,"%s: %s%li%s ko %s%40s%s \n",Messages[SIZE_TEXT][LangNb],bold,(tabmails[mailcpt].size>>10)+1,unbold,bold,tabmails[mailcpt].received_time,unbold);
				printline(s);
				sprintf(s,"%s: %s",Messages[FROM_TEXT][LangNb],bold);
				printline(s);
				for (int i=0;i<(int) strlen(tabmails[mailcpt].from);i++) {
					if ((tabmails[mailcpt].from[i]=='<') && CGIon) {printf("&lt;");continue;}
					if ((tabmails[mailcpt].from[i]=='>') && CGIon) {printf("&gt;");continue;}
					printf("%c",tabmails[mailcpt].from[i]);
				}			
				sprintf(s,"%s\n",unbold);
				printline(s);
				sprintf(s,"%s: %s%s%s\n",Messages[SUBJECT_TEXT][LangNb],bold,tabmails[mailcpt].subject,unbold);
				printline(s);
				// Write message
				LogMsg.Write(3,"Write message to stdout");
				if (CGIon) printline("\n<form><textarea name=\"MESSAGE\" rows=\"8\" cols=\"72\">");
				else printf("-------------------------------------------------------------");
				printf("\n");
				for (unsigned long int li=0;li<(unsigned long int) strlen(tabmails[mailcpt].mail);li++) {
					if (tabmails[mailcpt].mail[li]!='\r') {
						printf("%c",tabmails[mailcpt].mail[li]);
					}
				}
				if (CGIon) printline("</textarea></form>\n");
				else printf("\n-------------------------------------------------------------\n");
				// Write joined file(s)
				sprintf(s,"%s: ",Messages[ATTACHED_FILE_TEXT][LangNb]);
				printline(s);
				if (tabmails[mailcpt].files[0]==0) {	// No joined file
					sprintf(s,"%s%s%s\n",bold,Messages[NONE_TEXT][LangNb],unbold);
				}
				else {									// At least, on joined file
					char *p,*q;char c;				
					p=tabmails[mailcpt].files;
					
					strcpy(s,bold);
					if (CGIon) strcat(s,"<br>");
					while (*p) {
						q=p;while (*q && (*q!=',')) q++;
						c=*q;	// Save char
						q[0]=0;	// p is now a null terminated string
						if (CGIon) {
							strcpy(t,p);escape_url(t);
							strcat(s,"<a href=\"http:/files/");strcat(s,t);strcat(s,"\">"); 
							}
						strcat(s,p);
						if (CGIon) strcat(s,"</a></br>");
						q[0]=c;
						p=q;
						if (p[0]==',') p++;
						if (p[0]==' ') {
							p++;
							if (!CGIon) strcat(s," ");
							}
					}
					strcat(s,unbold);strcat(s,"\n");
				}
				printline(s);
				
				break;
		}
	}
	if (CGIon) printline("</table>");

	//***** Disconect
	Post(sc,"QUIT\r\n");
	return(DoQuit(0));
}


BOOL Post(SOCKET sc, const char * msg)
//---------------------------------------------------------------------------
// Function	: Send a POP message to a socket
// Input 	: sc
// Return	: O = Ok, >0 = Error
//---------------------------------------------------------------------------
{
	int len = strlen(msg);
	int slen;
	int index = 0;

	LogMsg.Write(2,"POP sending:", msg);
	while(len > 0)
	{
		if ((slen = send(sc,msg + index,len,0)) < 1)
		{
			return(DoQuit(FAILED_TO_SEND));
		}
		len -= slen;
		index += slen;
	}
	return TRUE;
}


int Ack(SOCKET sc)
//---------------------------------------------------------------------------
// Function	: Get POP response from the server.
// Input 	: sc
// Return	: O = Ok, >0 = Error
//---------------------------------------------------------------------------
{
	static char *buf;
	unsigned long int liSizeOfMail=SIZE_RECEIVE_BUFFER;
	int rlen;
	int Received = 0;

	if (!buf) 
		if ((buf = (char *) malloc(liSizeOfMail+1)) == NULL) // The first time, create buf
			return(OUT_OF_MEMORY);
again:
	if ((rlen = recv(sc,buf+Received,liSizeOfMail-Received,0)) < 1) {
		return(FAILED_TO_RECEIVE);	// Possible when pop server refuses client
	}

	buf[Received+rlen] = 0;LogMsg.Write(2,"POP Received:", buf+Received);
	Received += rlen;

	// Check for newline
	if ((buf[Received-2] != '\r') || (buf[Received-1] != '\n'))	{
		LogMsg.Write(3,"POP Incomplete server message. Awaiting CRLF");
		goto again; 		// Incomplete data. Line must be terminated by CRLF
	}
	return((buf[0] == '-')?1:0);
}


int Ack_Stat(SOCKET sc, int *iNbUnread, unsigned long int *liSizeUnread)
//---------------------------------------------------------------------------
// Function	: Get the POP response from the server. Used after STAT or LIST
// Input 	: sc
// Output	: iNbUnread
//			  liSizeUnread
// Return	: O = Ok, >0 = Error
//---------------------------------------------------------------------------
{
	static char *buf;
	unsigned long int liSizeOfMail=SIZE_RECEIVE_BUFFER;
	unsigned long int Received = 0;
	int rlen;

	if (!buf) 
		if ((buf = (char *) malloc(liSizeOfMail+1)) == NULL) // The first time, create buf
			return(OUT_OF_MEMORY);
again:
	if ((rlen = recv(sc,buf+Received,liSizeOfMail-Received,0)) < 1) return(FAILED_TO_RECEIVE);
	buf[Received+rlen] = 0;LogMsg.Write(2,"POP Received:", buf+Received);
	Received += rlen;

	// Check for newline
	if ((buf[Received-2] != '\r') || (buf[Received-1] != '\n'))	{
		LogMsg.Write(3,"POP Incomplete server message. Awaiting CRLF");
		goto again; 		// Incomplete data. Line must be terminated by CRLF
	}
	if (buf[0] == '-') return(UNKNOWN_ERROR);	// Return POP Error 
	*iNbUnread=atol(strchr(buf,' ')+1);
	*liSizeUnread=atol(strchr(strchr(buf,' ')+1,' ')+1);
	return(0);
}


int Ack_Mail(SOCKET sc,int mailcpt,const unsigned long int liMailSize)
//---------------------------------------------------------------------------
// Function	: Get the POP response from the server. Used after GET
// Input 	: sc
// Output	: iNbUnread
//			  liSizeUnread
// Return	: O = Ok, >0 = Error
//---------------------------------------------------------------------------
{
	unsigned long int liSizeOfMail=(liMailSize+SIZE_RECEIVE_BUFFER); // A mail is always greater than size returned by LIST
	unsigned long int liSizeOfFileList=SIZE_BLOCK_FILELIST;
	unsigned long int Received=0;
	char *mail;
	int rlen;
	char *p,*q,*beginmes,*endmes,*beginpart,*endpart;
	char contenttype[256],contenttransfer[256],boundary[256],filename[256];
	int multipart=0;
	
	//********** Get mail from server
	// Alloc mail pointer
	// Put mail in mail pointer

	if ((mail = (char *) malloc(liSizeOfMail+1)) == NULL) return(OUT_OF_MEMORY);
	again:	// Loop
	if ((rlen = recv(sc,mail+Received,liSizeOfMail-Received,0)) < 1) { 
		free(mail);	
		return(FAILED_TO_RECEIVE);
	}
	mail[Received+rlen] = 0;	// mail is now a null terminated string
	LogMsg.Write(3,"POP Received:", mail+Received);
	Received += rlen;
	// Check for end of message
	q=mail+(Received-3); 		// here, Received should always be greater than 3
	if ((q[0]!='.') || (q[1] != '\r') || (q[2] != '\n'))	{
		LogMsg.Write(3,"POP Incomplete server message. Awaiting CRLF");
		goto again; 			// Incomplete data. Line must be terminated by CRLF
	}

	//********** Here, mail is get, now read it
	// Begin of message is after first null line \r\n\r\n
	// End of message is \r\n.\r\n
	// Fields required 			"Date: ","From: ","To: "
	// Fields found sometines	"Return-Path: ", "Subject: ", "Status: ", "MIME-Version: "

	if ((beginmes=strstr(mail,"\r\n\r\n"))==NULL) { free(mail);return(UNKNOWN_ERROR); }
	beginmes[3]=0;beginmes+=4;
	if ((endmes=strstr(beginmes,"\r\n.\r\n"))==NULL) {
		// This case is not regular but can arrive with some mail sender
		endmes=beginmes+strlen(beginmes);
		}
	else {
		// Regular case
		endmes[2]=0;endmes+=2;
	}
	
	if ((p=StrStr(mail,"\nDate: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: Date:",p+sizeof("Date: "));
		tabmails[mailcpt].received_time=strdup(p+sizeof("Date: "));q[0]='\r';
	}
	else {
		free(mail);
		return(BAD_FORMAT_MAIL);
	}
	if ((p=StrStr(mail,"\nReturn-Path: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: Return-Path:",p+sizeof("Return-Path: "));
		tabmails[mailcpt].return_path=strdup(p+sizeof("Return-Path: "));q[0]='\r';
	}
	if ((p=StrStr(mail,"\nFrom: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: From:",p+sizeof("From: "));
		tabmails[mailcpt].from=strdup(p+sizeof("From: "));q[0]='\r';
	}
	else {					// From is not found
		if (tabmails[mailcpt].return_path!=NULL) {	// But Return-Path was
			tabmails[mailcpt].from=strdup(tabmails[mailcpt].return_path);
		}
		else {
			free(mail);
			return(BAD_FORMAT_MAIL);
		}
	}
	DecodeHeaderField(tabmails[mailcpt].from);
	if ((p=StrStr(mail,"\nSubject: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: Subject:",p+sizeof("Subject: "));
		tabmails[mailcpt].subject=strdup(p+sizeof("Subject: "));q[0]='\r';
		DecodeHeaderField(tabmails[mailcpt].subject);
	}
	if ((p=StrStr(mail,"\nStatus: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: Status:",p+sizeof("Status: "));
		tabmails[mailcpt].status=strdup(p+sizeof("Status: "));q[0]='\r';
	}
	if ((p=StrStr(mail,"\nMIME-Version: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: MIME-Version:",p+sizeof("MIME-Version: "));
		tabmails[mailcpt].mime_version=strdup(p+sizeof("MIME-Version: "));q[0]='\r';
	}
	
	//********** Malloc tabmails[mailcpt].mail and tabmails[mailcpt].files
	if ((tabmails[mailcpt].mail = (char *) malloc(liSizeOfMail+1)) == NULL) return(OUT_OF_MEMORY);
	if ((tabmails[mailcpt].files= (char *) malloc(liSizeOfFileList+1)) == NULL) return(OUT_OF_MEMORY);
	tabmails[mailcpt].mail[0]=0;tabmails[mailcpt].files[0]=0;

	// Get contenttype and contenttransfer
	if ((p=StrStr(mail,"\nContent-Type: "))) {
		q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
		LogMsg.Write(2,"Header field found: Content-Type:",p+sizeof("Content-Type: "));
		strncpy(contenttype,p+sizeof("Content-Type: "),sizeof(contenttype));q[0]='\r';

		if (StrStr(contenttype,"multipart")==contenttype) {
			// Multipart mail
			multipart=1;
			strcpy(boundary,"--");strcat(boundary,StrStr(contenttype,"boundary=")+strlen("boundary=")+1);boundary[strlen(boundary)-1]=0;
			LogMsg.Write(2,"Mail multipart, boundary:",boundary);
		}
		else {
			// Not a multipart mail
			if ((p=StrStr(mail,"\nContent-Transfer-Encoding: "))==NULL) {
				strcpy(contenttransfer,"");	
			}
			else {
				q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
				LogMsg.Write(2,"Header field found: Content-Transfer-Encoding:",p+sizeof("Content-Transfer-Encoding: "));
				strncpy(contenttransfer,p+sizeof("Content-Transfer-Encoding: "),sizeof(contenttransfer));q[0]='\r';
			}
		}
	}
	else {
		strcpy(contenttype,"text/plain");strcpy(contenttransfer,"");
	}
		

	// ********** Decode message
	beginpart=beginmes;endpart=endmes;
	do {
		LogMsg.Write(2,"Begin loop no",multipart);
		if (multipart) {
			contenttype[0]=0;contenttransfer[0]=0;
			if ((beginpart=strstr(beginpart,boundary))==NULL) break;	// Should not happened
			beginpart+=strlen(boundary);
			if (strstr(beginpart,"--")==beginpart) break;				// End of loop
			if ((p=StrStr(beginpart,"\nContent-Type: "))!=NULL) {
				q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
				LogMsg.Write(2,"Part field found: Content-Type:",p+sizeof("Content-Type: "));
				strncpy(contenttype,p+sizeof("Content-Type: "),sizeof(contenttype));q[0]='\r';
			}
			if ((p=StrStr(beginpart,"\nContent-Transfer-Encoding: "))!=NULL) {
				q=p+1;while ( ! (q[0]=='\r' && q[1]=='\n' && q[2]!=' ' && q[2]!='\t') ) { q=q+1; };q[0]=0;
				LogMsg.Write(2,"Part field found: Content-Transfer-Encoding:",p+sizeof("Content-Transfer-Encoding: "));
				strncpy(contenttransfer,p+sizeof("Content-Transfer-Encoding: "),sizeof(contenttransfer));q[0]='\r';
			}
			// Set beginpart
			beginpart=strstr(beginpart,"\r\n\r\n");
			if ((endpart=strstr(beginpart,boundary))==NULL) { endpart=endmes; }
			else { endpart--; }
			beginpart[3]=0;beginpart+=4;endpart[0]=0;
			multipart++;
		}

		void *data;
		int sizeofdata;
	
		// MIME text/plain
		//****************
		if (StrStr(contenttype,"text/plain")==contenttype) {
			LogMsg.Write(2,"Text found, contenttype    :",contenttype);
			LogMsg.Write(2,"Text found, contenttransfer:",contenttransfer);
			// Decode and Save if ""
			if (contenttransfer[0]==0) {
				if (multipart<=1) strcpy(tabmails[mailcpt].mail,beginpart);
				else strcat(tabmails[mailcpt].mail,beginpart);
			}
			// Decode and Save if "7bit"
			if (StrStr(contenttransfer,"7bit")==contenttransfer) {
				if (multipart<=1) strcpy(tabmails[mailcpt].mail,beginpart);
				else strcat(tabmails[mailcpt].mail,beginpart);
			}
			// Decode and Save if "8bit"
			if (StrStr(contenttransfer,"8bit")==contenttransfer) {
				if (multipart<=1) strcpy(tabmails[mailcpt].mail,beginpart);
				else strcat(tabmails[mailcpt].mail,beginpart);
			}
			// Decode and Save if Base64
			if (StrStr(contenttransfer,"base64")==contenttransfer) {
				if ((data=malloc(strlen(beginpart)+4)) == NULL) return(OUT_OF_MEMORY);
				sizeofdata=base64_decode(beginpart,data);			// Decode
				if (multipart<=1) strcpy(tabmails[mailcpt].mail,(char *) data);		//strncpy( , ,sizeofdata) should be better
				else strcat(tabmails[mailcpt].mail,(char *) data);
				free(data);
			}
			// Decode and Save if Quoted-printable
			if (StrStr(contenttransfer,"quoted-printable")==contenttransfer) {
				if ((data=malloc(strlen(beginpart))) == NULL) return(OUT_OF_MEMORY);
				sizeofdata=quoted_decode(beginpart,data);			// Decode
				if (multipart<=1) strcpy(tabmails[mailcpt].mail,(char *) data);		//strncpy( , ,sizeofdata) should be better
				else strcat(tabmails[mailcpt].mail,(char *) data);
				free(data);
			}
		}

		// MIME application,image...
		//**************************
		int file=0;
		if (StrStr(contenttype,"application")==contenttype) file=1;
		if (StrStr(contenttype,"image")==contenttype) file=1;
		if (StrStr(contenttype,"audio")==contenttype) file=1;
		if (StrStr(contenttype,"video")==contenttype) file=1;
		if (file) {
			LogMsg.Write(2,"File found, contenttype    :",contenttype);
			LogMsg.Write(2,"File found, contenttransfer:",contenttransfer);
			strcpy(filename,StrStr(contenttype,"name=")+sizeof("name="));filename[strlen(filename)-1]=0;
			// Decode and Save if "7bit" (Do nothing)
			// Decode and Save if "8bit" (Do nothing)
			// Decode and Save if Base64
			if (StrStr(contenttransfer,"base64")==contenttransfer) {
				if ((data=malloc(strlen(beginpart)+4)) == NULL) return(OUT_OF_MEMORY);
				sizeofdata=base64_decode(beginpart,data);			// Decode
				SaveFile(data,sizeofdata,filename);					// Save
				free(data);
			}
			// Decode and Save if Quoted-printable
			if (StrStr(contenttransfer,"quoted-printable")==contenttransfer) {
				if ((data=malloc(strlen(beginpart))) == NULL) return(OUT_OF_MEMORY);
				sizeofdata=quoted_decode(beginpart,data);			// Decode
				SaveFile(data,sizeofdata,filename);					// Save
				free(data);
			}

			// Add to joined file list
			if (strlen(tabmails[mailcpt].files)+strlen(filename)+1 > liSizeOfFileList) {
				// Extend tabmails[mailcpt].files
				liSizeOfFileList+=SIZE_BLOCK_FILELIST;
				tabmails[mailcpt].files=(char *) realloc(tabmails[mailcpt].files,liSizeOfFileList+1);
			}
			if (tabmails[mailcpt].files[0]!=0) strcat(tabmails[mailcpt].files,", ");
			strcat(tabmails[mailcpt].files,filename);
		}

		LogMsg.Write(2,"End loop");
		if (multipart) beginpart=endpart+1;
	}
	while (multipart);




	free(mail);
	return(0);
}


char *makeword(char *line, char stop)
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
{
    int x = 0,y;
    char *word = (char *) malloc(sizeof(char) * (strlen(line) + 1));

    for (x=0;((line[x]) && (line[x] != stop));x++)
        word[x] = line[x];

    word[x] = '\0';
    if(line[x]) ++x;
    y=0;

    while ((line[y++]=line[x++]));
    return word;
}

char *fmakeword(FILE *f, char stop, int *cl) 
//---------------------------------------------------------------------------
//---------------------------------------------------------------------------
{
    int wsize;
    char *word;
    int ll;

    wsize = 2048;
    ll=0;
    word = (char *) malloc(sizeof(char) * (wsize + 1));

    while(1) {
        word[ll] = (char)fgetc(f);
        if (ll==wsize) {
            word[ll+1] = '\0';
            wsize+=2048;
            word = (char *)realloc(word,sizeof(char)*(wsize+1));
        }
        --(*cl);
				if ((signed char) word[ll] < 0)
				{
					// Something is wrong. Stop reading from stdin. 
					printf("Warning: Error reading from server pipe. %d bytes left to read<br>\n", *cl);
					word[ll] = 0;
					*cl = 0;
				}
        if((word[ll] == stop) || (feof(f)) || (!(*cl))) {
            if(word[ll] != stop) ll++;
            word[ll] = '\0';
            return word;
        }
        ++ll;
    }
}



int ind(char *s, char c) 
//---------------------------------------------------------------------------
// Return first pos of char c in string s (0 à n-1)
// Return -1 if not found
//---------------------------------------------------------------------------
{
    register int x;
    for (x=0;s[x];x++) {
        if (s[x] == c) return x;
	}
    return -1;
}


char *cgiLookup(char *tag, char *default_tag)
//---------------------------------------------------------------------------
// Function	: Return value of parameter tag from CGI list of parameters 
// Output	: Found value or default_tag if tag not found
//---------------------------------------------------------------------------
{
	for (int i=0; (i<MAX_ENTRIES) && entries[i].name; i++)
	{
		if (!strcmp(entries[i].name,tag))
			return (entries[i].val && *entries[i].val) ? entries[i].val : default_tag;
	}
	return default_tag;
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
// Get ini filename
getcwd(ficini,sizeof(ficini));		// getcwd must return dir of exe file (doesn't work under ISS, return cgi root dir)
if ((ficini[0] == '/') && (ficini[1] == '/') && (ficini[3] == '/')) {
	ficini[0]=ficini[2];ficini[1]=':';ficini[2]='/';
	}

strcat(ficini,"/"FILEINI);
LogMsg.Write(3,"Nbre parametres:",argc);
for (noarg=1;noarg<argc;noarg++) {
	if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
		option=(argv[noarg][1] | 0x20);
		curseurarg=2;
		if (strlen(argv[noarg]) < 3) { ++noarg; curseurarg=0; }
		switch (option) {
			case 'u': strncpy(User,argv[noarg]+curseurarg,sizeof(User)); break;			// User
			case 'p': strncpy(Password,argv[noarg]+curseurarg,sizeof(Password)); break;	// Password
			case 's': strncpy(Host,argv[noarg]+curseurarg,sizeof(Host)); break;			// POP3 server
			case 'a': strncpy(Action,argv[noarg]+curseurarg,sizeof(Action));break;		// Action
			case 'd': LogMsg.Reset();
					  LogMsg.ErrorLevel=max((int) (argv[noarg][curseurarg])-48,0);
					  break;													// Debug on
			case 'l': strncpy(Lang,argv[noarg]+curseurarg,sizeof(Lang));break;	// Language
			case '?': help=-1;break;											// Help
			case 'h': help=-1;break;											// Help
			case 'v': help=-1;break;											// Help
			default: invalide=-1;break;
		}
	}
}

// Affiche en-tete
//----------------
Usage:
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("%s is a freeware that allows you to get your Mails from the command line\n",PROG);
	printf("or from your WWW Browser (%s works as a CGI).\n",PROG);
	printf("%s sources can be compiled for WIN32 (VC++ or GCC) or for Unix/Linux (GCC)\n",PROG);
	printf("\n");
}

if (help|invalide) {
	if (invalide) printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage: %s params [action] [options]\n",PROG);
	printf("Params:\n");
	printf("  -u User                POP3 User account\n");
	printf("  -p Password            POP3 User password\n");
	printf("  -s HostPOPServer       POP3 Server hostname\n");
	printf("Action:\n");
	printf("  -a l                   To list mails (default action)\n");
	printf("  -a dx                  To delete mail no x | mails no x to y\n");
	printf("  -a dx-y                To delete mail no x | mails no x to y\n");
	printf("  -a gx                  To get mail no x\n");
	printf("  -a p                   To purge mails sent by users/domains from black list\n");
	printf("Options:\n");
	printf("  -d X                   Show level X debug info\n");
	printf("  -l F                   Language is French\n");
	printf("  -v                     Print version and help information\n");
	printf("  -help                  Print version and help information\n");
	printf("More options are available in %s file",FILEINI);
	printf("\n");
	exit(0);
}
	
// Get .ini file data
//-------------------
Port=GetPrivateProfileInt("Config","PortPOP",110,ficini);
if (Host[0]==0)		GetPrivateProfileString("Config","Host","",Host,sizeof(Host),ficini);
if (User[0]==0)		GetPrivateProfileString("Config","User","",User,sizeof(User),ficini);
GetPrivateProfileString("CGI","HTML Head Get","<HTML><BODY leftmargin=20 topmargin=10>",HTMLhead,sizeof(HTMLhead),ficini);
GetPrivateProfileString("CGI","HTML End Get","</BODY></HTML>",HTMLend,sizeof(HTMLend),ficini);

// Get CGI Info
//-------------
if (ParseCgiInfo(&CGIon)) return(DoQuit(FAILED_TO_PARSE_CGI));
if (CGIon) {
	// DOCUMENT_ROOT not defined with all servers
	if (getenv("DOCUMENT_ROOT")==NULL) {
		#ifdef _WIN32
			strncpy(CGIRep,"c:/temp",sizeof(CGIRep));
		#else
			strncpy(CGIRep,"/tmp",sizeof(CGIRep));
		#endif
	}
	else {
		strncpy(CGIRep,getenv("DOCUMENT_ROOT"),sizeof(CGIRep));strcat(CGIRep,"/files");
	}
	strncpy(CGIExe,getenv("SCRIPT_NAME"),sizeof(CGIExe));
	strncpy(Lang,cgiLookup("LANG",Lang),sizeof(Lang));
	strncpy(User,cgiLookup("USER",User),sizeof(User));
	strncpy(Password,cgiLookup("PASSWORD",Password),sizeof(Password));
	strncpy(Host,cgiLookup("HOST",Host),sizeof(Host));
	strncpy(Action,cgiLookup("ACTION",Action),sizeof(Action));
}


// Define language
//----------------
switch(Lang[0] | 0x20) {
	case 'f': LangNb=1;break;
	default : LangNb=0;break;
}

// Make host conversion to resolve firewall constraint
//----------------------------------------------------
if (Host[0]!=0)		{
	GetPrivateProfileString("Host conversion",Host,Host,Host,sizeof(Host),ficini);
}

// If HTMLxxx is a file
//---------------------
LogMsg.Write(4,"HTMLhead:",HTMLhead);
LogMsg.Write(4,"HTMLend :",HTMLend);
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
LogMsg.Write(2,"Action  :",Action);
LogMsg.Write(2,"Option file:",ficini);
LogMsg.Write(2,"Debug level:",LogMsg.ErrorLevel);
LogMsg.Write(2,"Language:",LangNb);
LogMsg.Write(2,"Port    :",Port);
LogMsg.Write(2,"Host    :",Host);
LogMsg.Write(2,"User    :",User);
LogMsg.Write(3,"Password:",Password);
if (CGIon) {
	LogMsg.Write(2,"CGIExe  :",CGIExe);
	LogMsg.Write(2,"CGIRep  :",CGIRep);
	LogMsg.Write(3,"HTMLhead:",HTMLhead);
	LogMsg.Write(3,"HTMLend :",HTMLend);
}

// Check parameters
//-----------------
if ((!CGIon) && ((User[0]==0) || (Password[0]==0) || (Host[0]==0) || (Action[0]==0))) {
	invalide=-1;
	goto Usage;
}

// Print HTML Header
//------------------
if (CGIon) {
   	printf("Content-type: text/html%c%c",10,10);
	printf(HTMLhead);
	printf("<font face=\"Courier\">\n");
}

// Action
//-------
iRet=mail_get();

// Print HTML Ender
//-----------------
if (CGIon) printf(HTMLend);

return(iRet);
}
