//--------------------------------------------------------------------
// Log management class          
//--------------------------------------------------------------------
// 30/10/98	3.0	Laurent Destailleur		Creation
//--------------------------------------------------------------------
// <<< Methods >>>
// Constructeur(NomFichier)
// Reset                Reset File
// Write                Write in log
// <<< Properties >>>
// ErrorLevel           -2=Error,-1=Warning,>=0=Ok
//--------------------------------------------------------------------
// Pour forcer niveau log, créer un fichier LogMsg.ini :
// [ErrorLevel]
// Default=x                            #Niveaux log visible par defaut
// nomfichierlog=x                      #Niveaux log visible pour nomfichier.log
// [LogFile]							
// Default=nomfichier.log               #Fichier log par defaut
// nomfichierlog=xxx                    #Reroutage fichier log (si xxx="", trace à l'écran)
//--------------------------------------------------------------------

#include <string.h>
#include <stdio.h>
#include <time.h>

#ifndef __MSDOS__
#ifdef  __GNUC__
#include <unistd.h>
#include <sys/types.h>
#endif
#endif
#ifdef __MSDOS__
// Dos
#include <dir.h>
#endif
#ifdef _WIN32
// Windows
#include <direct.h>
#endif

#include "misc.h"
#include "CLogMsg.h"
#include "macros.h"


#define LOGINIFILE "LogMsg.ini"
#define LEVEL_BEGIN_END 1



void WriteFormatedTime(FILE *hfile)
{
    time_t tNow;
	time(&tNow);
    struct tm *lt = localtime(&tNow);
	fprintf(hfile,"%04i%02i%02i-%02i:%02i:%02i",lt->tm_year+1900,lt->tm_mon+1,lt->tm_mday,lt->tm_hour,lt->tm_min,lt->tm_sec);
	return;
}



CLogMsg::CLogMsg(char *filename="")
//--------------------------------------------------------------------
// Constructor
//--------------------------------------------------------------------
{
	char ficini[MAXPATH];
	getcwd(ficini,sizeof(ficini));
	strcat(ficini,"/"LOGINIFILE);
	// Compense bug de getcwd
	if ((ficini[0] == '/') && (ficini[1] == '/') && (ficini[3] == '/')) {
		ficini[0]=ficini[2];ficini[1]=':';ficini[2]='/';
		}

	ErrorLevel=ErrorLevelBE=GetPrivateProfileInt("ErrorLevel",((filename[0]==0)?"Default":filename),0,ficini);
	GetPrivateProfileString("LogFile",((filename[0]==0)?"Default":filename),filename,logfile,sizeof(logfile),ficini);
	if (LEVEL_BEGIN_END<=ErrorLevelBE) Write(LEVEL_BEGIN_END,"----- BEGIN -----");
	return;
}


CLogMsg::~CLogMsg()
//--------------------------------------------------------------------
// Destructor
//--------------------------------------------------------------------
{
	if (LEVEL_BEGIN_END<=ErrorLevelBE) Write(LEVEL_BEGIN_END,"-----  END  -----");
	return;
}


void CLogMsg::Reset(void)
//--------------------------------------------------------------------
// Clear the log file, so need to set ErrorLevelBE to 0
//--------------------------------------------------------------------
{
	if (logfile[0]!=0) fclose(fopen(logfile,"w"));
	ErrorLevelBE=0;
	return;
}


void CLogMsg::Write(int Level,const char value)
//--------------------------------------------------------------------
// Write
//--------------------------------------------------------------------
{
	if (Level<=max(ErrorLevel,ErrorLevelBE)) {
		FILE *hFile;
		if (logfile[0]!=0) {
			if ((hFile=fopen(logfile,"at"))==NULL) {
				fprintf(stderr,"Error: CLogMsg:Write failed [%c]\n",value);
				return;
			}
		}
		else { 
			hFile=stdout;
		}
		WriteFormatedTime(hFile);
		fprintf(hFile," %3i %02X",Level,value);
		fprintf(hFile,"\n");
		if (logfile[0]!=0) fclose(hFile);
	}
	return;
}


void CLogMsg::Write(int Level,const char *msg)
//--------------------------------------------------------------------
// Write
//--------------------------------------------------------------------
{
	if (Level<=max(ErrorLevel,ErrorLevelBE)) {
		FILE *hFile;
		if (logfile[0]!=0) {
			if ((hFile=fopen(logfile,"at"))==NULL) {
				fprintf(stderr,"Error: CLogMsg:Write failed [%s]\n",(msg==NULL?"NULL\n":msg));
				return;
			}
		}
		else {
			hFile=stdout;
		}
		WriteFormatedTime(hFile);
		fprintf(hFile," %3i %s",Level,(msg==NULL?"NULL\n":msg));
		if (msg!=NULL) {
			if ((strlen(msg)==0) || ((msg[strlen(msg)-1]!='\r') && (msg[strlen(msg)-1]!='\n'))) fprintf(hFile,"\n");
		}
		if (logfile[0]!=0) fclose(hFile);
	}
	return;
}


void CLogMsg::Write(int Level,const char *msg,const char *value)
//--------------------------------------------------------------------
// Write
//--------------------------------------------------------------------
{
	if (Level<=max(ErrorLevel,ErrorLevelBE)) {
		FILE *hFile;
		if (logfile[0]!=0) {
			if ((hFile=fopen(logfile,"at"))==NULL) {
				fprintf(stderr,"Error: CLogMsg:Write failed [%s] [%s]\n",(msg==NULL?"NULL":msg),(value==NULL?"NULL\n":value));
				return;
			}
		}
		else { 
			hFile=stdout;
		}
		WriteFormatedTime(hFile);
		fprintf(hFile," %3i %s %s",Level,(msg==NULL?"NULL":msg),(value==NULL?"NULL\n":value));
		if (value!=NULL) {
			if ((strlen(value)==0) || ((value[strlen(value)-1]!='\r') && (value[strlen(value)-1]!='\n'))) fprintf(hFile,"\n");
		}
		if (logfile[0]!=0) fclose(hFile);
	}
	return;
}


void CLogMsg::Write(int Level,const char *msg,const long int value)
//--------------------------------------------------------------------
// Write
//--------------------------------------------------------------------
{
	if (Level<=max(ErrorLevel,ErrorLevelBE)) {
		FILE *hFile;
		if (logfile[0]!=0) {
			if ((hFile=fopen(logfile,"at"))==NULL) {
				fprintf(stderr,"Error: CLogMsg:Write failed [%s] [%li]\n",(msg==NULL?"NULL":msg),value);
				return;
			}
		}
		else {
			hFile=stdout;
		}
		WriteFormatedTime(hFile);
		if (msg!=NULL) {
			fprintf(hFile," %3i %s %li\n",Level,(msg==NULL?"NULL":msg),value);
		}
		if (logfile[0]!=0) fclose(hFile);
	}
	return;
}
