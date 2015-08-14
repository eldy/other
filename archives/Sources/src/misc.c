//-------------------------------------------------------------------
// Miscellanous functions library          
//-------------------------------------------------------------------
// 30/11/98		3.0		Laurent Destailleur		Creation
//-------------------------------------------------------------------
// <<< All OS >>>
// Hex2Dec
// Hex2Byte
// Byte2Hex
// IsDigits
// StrStr
// strupr/strlwr
// strnicmp
// stricmp
// <<< Windows >>>
// CenterWindow
// Delay
// Rect3D
// <<< Unix >>>
// GetPrivateProfileInt
// GetPrivateProfileString
//-------------------------------------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "misc.h"
#include "macros.h"


unsigned char Hex2Dec(unsigned char c)
//-------------------------------------------------------------------
// Conversion Hex->Decimale
// Entree: '0'..'F'(majuscule)
// Retour: Octet (Nombre entre 0 et 15)
//-------------------------------------------------------------------
{
if ((c>=0x41) && (c<=0x46)) return((unsigned char) (c-55)); /* A..F */
else return((unsigned char) (c-48));                        /* 0..9 */
}


unsigned char Hex2Byte(char *s)
//-------------------------------------------------------------------
// Conversion Hex->Byte
// Entree: s=chaine hexadecimale a deux chiffres
// Retour: Octet (Nombre entre 0 et 255)
//-------------------------------------------------------------------
{
return(Hex2Dec((unsigned char) (s[0]<<4))|Hex2Dec((unsigned char) (s[1]&0xDF)));
}


void Byte2Hex(unsigned char b,char *s)
//-------------------------------------------------------------------
// Conversion Byte->Hex
// Entree: b=octet a convertir
// Retour: chaine hexadecimale a deux chiffres
//-------------------------------------------------------------------
{
char HexDigits[17]="0123456789ABCDEF";
s[0]=HexDigits[b>>4];   /* Transforme les deux */
s[1]=HexDigits[b&0x0F]; /* quartets en Hex     */
s[2]=0;
}


int IsDigits(char *s)
//-------------------------------------------------------------------
// Retour:  -1=TRUE si s!="" et s n'a que des chiffres
//-------------------------------------------------------------------
{
int i,b;
if ((int) s[0]==0) return(0);
for (i=0,b=-1;i<(int) strlen(s);i++) {
  if (((int) isdigit(s[i])) == 0) { b=0; break; }
  }
return(b);
}


char * StrStr(const char * string1, const char * string2)
//-------------------------------------------------------------------
// Search p2 string in p1 string
// (differs from strstr because is uncase sensitive)
//-------------------------------------------------------------------
{
	const char *p1,*p2;
	const char *q1,*q2;
	int differ;
	p1=string1;p2=string2;

	if ((p1==NULL) || (p2==NULL)) return(NULL);
	while (*p1) {
		if (toupper(*p1) == toupper(*p2)) {
			differ=0;
			q1=p1;q2=p2;
			while (*q2) {
				if (toupper(*q1) != toupper(*q2)) {differ=1;break;}
				q1++;q2++;
			}
			if (differ==0) {return((char *) p1);}
		}
		++p1;
	}
	return(NULL);
}


char * strupr(char * string1)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
{
	return(string1);
}

char * strlwr(char * string1)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
{
	return(string1);
}

int stricmp(const char * string1, const char * string2)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
{
	return(strcmp(string1,string2));
}

int strnicmp(const char * string1, const char * string2,size_t n)
//-------------------------------------------------------------------
//-------------------------------------------------------------------
{
	return(strncmp(string1,string2,n));
}



#ifdef _Windows
#include <windows.h>

void CenterWindow(HWND fenetre1,HWND fenetre2)
//-------------------------------------------------------------------
// Centre fenetre1 par rapport a fenetre2
//-------------------------------------------------------------------
{
RECT rect1,rect2;
GetWindowRect(fenetre2,&rect1);
GetWindowRect(fenetre1,&rect2);
SetWindowPos(fenetre1,(HWND) NULL,((rect1.right+rect1.left-rect2.right+rect2.left)>>1)
  ,((rect1.bottom+rect1.top-rect2.bottom+rect2.top)>>1)
  ,(rect2.right-rect2.left),(rect2.bottom-rect2.top)
  ,SWP_NOZORDER|SWP_NOACTIVATE);
}


void Delay(WORD delai)
//-------------------------------------------------------------------
// Attend delai millisecondes
//-------------------------------------------------------------------
{
DWORD dw1,dw2;
dw1=GetTickCount();
do dw2=GetTickCount();
while ((dw2-dw1)<(DWORD) delai);
}


void Rect3D(HDC hdc,HPEN hpen1,HPEN hpen2,int x1,int y1,int x2,int y2)
//-------------------------------------------------------------------
// Affiche rectangle avec effet 3D
//-------------------------------------------------------------------
{
POINT point;
SelectObject(hdc,hpen2);
MoveToEx(hdc,x2,y1,&point);LineTo(hdc,x2,y2);LineTo(hdc,x1,y2);
SelectObject(hdc,hpen1);
LineTo(hdc,x1,y1);LineTo(hdc,x2,y1);
}

#endif



#ifndef __MSDOS__
#ifndef _Windows
#ifndef _WIN32
// Unix

int GetPrivateProfileInt(const char *topic,const char *entry,int default_value,const char *filename)
//-------------------------------------------------------------------
// Unix version of GetPrivateProfileInt
//-------------------------------------------------------------------
{
	FILE *hIniFile;
	BOOL FoundTopic=FALSE;
	char line[256];
	char search[256];
	int value=default_value;	// Return value
	
	if ((hIniFile=fopen(filename,"rt"))==NULL) return(value);
	while (TRUE) {
		if (fgets(line,sizeof(line),hIniFile)==NULL) break;
		if (strlen(line)>0) if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
		if (strlen(line)>0) if (line[strlen(line)-1]=='\r') line[strlen(line)-1]=0;
		if (line[0]=='[') {	// Topic found
			strcpy(search,"[");strcat(search,topic);strcat(search,"]");
			if (strstr(strupr(line),strupr(search))==line) {
				FoundTopic=TRUE;	// The good one
			}
			else {
				FoundTopic=FALSE;	// Not the good one
			}
			continue;
		}
		if (! FoundTopic) continue;
		// We are in the good topic
		strcpy(search,entry);strcat(search,"=");
		if (strstr(strupr(line),strupr(search))==line) {
			// We found good entry
			value=atoi(line+strlen(search));
			break;
		}
	}
	fclose(hIniFile);
	return(value);
}


void GetPrivateProfileString(const char *topic,const char *entry,const char *default_string,char *buf,int length,char *filename)
//-------------------------------------------------------------------
// Unix version of GetPrivateProfileString
//-------------------------------------------------------------------
{
	FILE *hIniFile;
	BOOL FoundTopic=FALSE;
	char line[256];
	char search[256];

	strncpy(buf,default_string,length);
	if ((hIniFile=fopen(filename,"rt"))==NULL) return;
	while (TRUE) {
		if (fgets(line,sizeof(line),hIniFile)==NULL) break;
                if (strlen(line)>0) if (line[strlen(line)-1]=='\n') line[strlen(line)-1]=0;
                if (strlen(line)>0) if (line[strlen(line)-1]=='\r') line[strlen(line)-1]=0;
		if (line[0]=='[') {	// Topic found
			strcpy(search,"[");strcat(search,topic);strcat(search,"]");
			if (strstr(strupr(line),strupr(search))==line) {
				FoundTopic=TRUE;	// The good one
			}
			else {
				FoundTopic=FALSE;	// Not the good one
			}
			continue;
		}
		if (! FoundTopic) continue;
		// We are in the good topic
		strcpy(search,entry);strcat(search,"=");
		if (strstr(strupr(line),strupr(search))==line) {
			// We found good entry
			strncpy(buf,line+strlen(search),length);
			break;
		}
	}
	fclose(hIniFile);
	return;
}


#endif
#endif
#endif

