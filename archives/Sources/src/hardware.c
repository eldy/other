//--------------------------------------------------------------------
// Hardware & Mem & Dir functions library
//--------------------------------------------------------------------
// 30/10/99		3.0		Laurent Destailleur		Creation
//--------------------------------------------------------------------
// <<< Dos >>>
// IsBreakOn
// SetBreak
// MemAvailable
// WindowsVersion
// DRIVE_STATUS
// DRIVE_STATUS_AMOVIBLE
// WARMBOOT
// COLDBOOT
// <<< All OS >>>
// FULLPATH
// DIREXIST
// FILEEXIST
// MAKEDIR
// COPYFILE
//--------------------------------------------------------------------

#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#ifdef __GNUC__
#include <unistd.h>
#include <sys/types.h>
#endif
#ifdef _WIN32
#include <io.h>
#include <direct.h>
#endif
#ifdef __MSDOS__
// Dos
#include <io.h>
#include <dos.h>
#include <dir.h>
#endif


#include "macros.h"
#include "hardware.h"


#ifdef __MSDOS__

int IsBreakOn(void)
//--------------------------------------------------------------------
// Off=0, On=1
//--------------------------------------------------------------------
{
	union REGS regs;
	regs.x.ax=0x3300;
	intdos(&regs,&regs);
	return (int)regs.h.dl;
}

void SetBreak(int OnOff)
//********************************************************************
// Off=0, On=1
//********************************************************************
{
	union REGS regs;
	regs.x.ax=0x3301;
	regs.h.dl=OnOff;
	intdos(&regs,&regs);
}

long MemAvailable(void)
//********************************************************************
// Return available memory
//********************************************************************
{
	union REGS regs;
	/* Request impossibly large number of 16-byte paragraphs from DOS */
	regs.h.ah = 0x48;
	regs.x.bx = 0xFFFF;
	int86(0x21,&regs,&regs);
	return((long)regs.x.bx * 16L);
}


int int2fcall(void)
//********************************************************************
// Cette fonction remplace l'appel de intr($2F,Regs)
// Regs.ax = $1600 (Test d'installation du mode étendu)
// 0x2F = Nø interruption Multiplex
//********************************************************************
{
	struct REGPACK regs;
	regs.r_ax=0x1600;
	intr(0x2F,&regs);
	return(regs.r_ax);
}

int WindowsVersion(int * HVersion,int * NVersion)
//********************************************************************
// Funcion : Determine la version de Windows active
// Input   : None
// Output  : HVersion NVersion
// Return  : 0 = Windows non actif
//         : 1 = Windows/386 V2.? actif
//         : 2 = Windows en mode Reel
//         : 3 = Windows en mode Standard
//         : 4 = Windows Version Hver.NVer en mode Etendu(Protege)
// Ex      : iRet=WindowVersion(&j,&k);
//********************************************************************
{
	struct REGPACK regs;
	int res;
	*HVersion=0;
	*NVersion=0;
	// Identifie Windows x.y en mode étendu }
	res=int2fcall();  // Test d'installation du mode étendu }
	switch (res&0x00FF) {
		  case 0x01:
		  case 0xFF: {
		  	    *HVersion=2; // Version principale          }
		  	    *NVersion=0; // Version secondaire inconnue }
		  	    res=0x01;
		  	    break;
		  }
		  case 0x00:
		  case 0x80:{
		  	    regs.r_ax=0x4680; // Identifier les modes Réel et Standard
		  	    intr(0x2F,&regs);
		  	    if ((regs.r_ax&0x00FF)==0x80) res=0x00; // Windows ne fonctionne pas
		  	    else {            // Windows en mode Réel ou Standard
		  	    	regs.r_ax=0x1605; // Simule l'inst. d'un DOS-Extender
		  	    	regs.r_bx=0x0000;
		  	    	regs.r_si=0x0000;
		  	    	regs.r_cx=0x0000;
		  	    	regs.r_es=0x0000;
		  	    	regs.r_ds=0x0000;
		  	    	regs.r_dx=0x0001;
		  	    	intr(0x2F,&regs);
		  	    	if (regs.r_cx==0x0000) { // Windows en mode Réel }
		  	    		regs.r_ax=0x1606;
		  	    		intr(0x2F,&regs);
		  	    		res=0x02;
		  	    	}
		  	    	else res=0x03; // Windows en mode Standard
		  	    }
		  	    break;
		  }
		  default: { // Windows version xx.yy en mode Etendu
		      *HVersion=res&0x00FF;
		      *NVersion=(res&0xFF00)>>8;
		      res=0x4;
		  }
	}
	return(res);
}


int DRIVE_STATUS(char drive)
//********************************************************************
// Renvoi le status d'un lecteur physique ou logique
// Includes drive letters assigned with DOS SUBST command and network
// drives for Novell Netware (and probably other networks).
//
// Entree: drive='A'...'Z'... 	(Les Shells TSRs Novell autorisent 32 lettres)
// Retour: 0 invalide           (Erreur)
//         1 local              (Disquette, Disque dur, ZIP)
//         2 subst              (Disque assigne)
//         3 reseau ou CD       (Disque reseaux ou CDROM)
//********************************************************************
{
union REGS in,out;
in.x.ax=0x4409;  /* IOCTL function, Check if block device remote */
in.h.bl=((drive | 0x20)-0x60); /* 'a'=0x61   bl=1 pour a:, 2 pour b:, etc */
intdos(&in,&out);
if (!out.x.cflag) /* carry flag set on error: bit 15 = subst, bit 12 = remote */
  return((out.x.dx & 0x8000)?2:((out.x.dx & 0x1000)?3:1));
return(0);
}


int DRIVE_STATUS_AMOVIBLE(char drive)
//********************************************************************
// Renvoi le status amovible d'un lecteur physique
// Includes drive letters assigned with DOS SUBST command and network
// drives for Novell Netware (and probably other networks).
//
// Entree: drive='A'...'Z'... 	(Les Shells TSRs Novell autorisent 32 lettres)
// Retour: 0 amovible           (Disquette ou ZIP)
//         1 inamovible         (Disque dur ou ZIP)
//         2 autre              (Lecteur CD)
//         3 invalide           (Disque non physique ou erreur)
//********************************************************************
{
union REGS in,out;
in.x.ax=0x4408;  /* IOCTL function, Check if block device remote */
in.h.bl=((drive | 0x20)-0x60); /* 'a'=0x61   bl=1 pour a:, 2 pour b:, etc */
out.x.ax=0x0;
intdos(&in,&out);
if (out.x.cflag) /* carry flag set on error */
  return((out.x.ax & 0x000E)?3:2);
return(out.x.ax);
}


short far *bios_post=(short far *) 0x00400072L;
void (far * boot)(void) = (void (far *) ()) 0xFFFF0000L;

void WARMBOOT(void)
//********************************************************************
// Reset a chaud=CTRL+ALT+SUP
//********************************************************************
{
*bios_post=0x1234;
boot();
}

void COLDBOOT(void)
//********************************************************************
// Reset a froid=Bouton reset
//********************************************************************
{
*bios_post=0;
boot();
}

#endif



void FULLPATH(char *chaine)
//********************************************************************
// Retour: Transforme chaine avec son chemin complet
//********************************************************************
{
#ifdef __MSDOS__
_fullpath(chaine,chaine,MAXPATH);
#else
#ifdef _Windows
_fullpath(chaine,chaine,MAXPATH);
#else
#ifdef _WIN32
#ifndef __GNUC__	// GCC function _fullpath doesn't work
_fullpath(chaine,chaine,MAXPATH);
#endif			
#endif
#endif
#endif
}



int DIREXIST(char *path)
//********************************************************************
// Cherche existance d'un repertoire
// Retour: -1 TRUE  path existant
//          0 FALSE path introuvable
// Rem:Cherche dans path specifie sinon courant.
//********************************************************************
{
char s[MAXPATH];
strcpy(s,path);
if (s[strlen(s)-1]==SEPARATEUR) {
	strcat(s,".");
	}
else {
	strcat(s,"X.");
	s[strlen(s)-2]=SEPARATEUR;
//  if ((strlen(s)>3) || ((s[1]!=':') && (s[1]!=0))) s[strlen(s)-1]=0;
	}
return(access(s,2)==0);
}


int FILEEXIST(char *fichier)
//********************************************************************
// Cherche existance d'un fichier
// Retour: -1 TRUE  fichier existant
//          0 FALSE fichier introuvable
// Rem: Cherche dans le chemin specifie sinon repertoire courant
//********************************************************************
{
return(access(fichier,0)==0);
}


int MAKEDIR(char *directory)
//********************************************************************
// Make directory (with its full path)
// Return: 0 ok
//         1 permission denied
//         2 string too large
//         3 other error
// Warning, Runtime error if dir is not valid (bad characters)
//********************************************************************
{
int i=0,j;
int retour=1;
char tempdir[MAXPATH];
int slash[MAXPATH];
char dir[MAXPATH+1];

strcpy(dir,directory);
j=strlen(dir);
if (dir[--j]!=SEPARATEUR) {dir[++j]=SEPARATEUR;dir[j]=0;}
if (strlen(directory)>MAXPATH) return(2);
/* Reperage des separateur */
for (j=1;j<(int) strlen(dir);j++) /* Peut commencer a la deuxieme lettre */
  if (dir[j]==SEPARATEUR) slash[++i]=j;
if (dir[--j]!=SEPARATEUR) slash[++i]=j;

/* Création du chemin */
for (j=1;j<=i;j++) {
  strcpy(tempdir,dir);tempdir[slash[j]]=0;
  #ifdef __MSDOS__
  if ((strlen(tempdir)==2) && (tempdir[1]==':')) continue;
  retour=mkdir(tempdir); /* repertoire courant si non specifie */
  #else
  #ifdef _Windows
  if ((strlen(tempdir)==2) && (tempdir[1]==':')) continue;
  retour=mkdir(tempdir); /* repertoire courant si non specifie */
  #else
  #ifdef _WIN32
  if ((strlen(tempdir)==2) && (tempdir[1]==':')) continue;
  #ifndef __GNUC__
  retour=mkdir(tempdir); /* repertoire courant si non specifie */
  #else
  retour=mkdir(tempdir,S_IREAD|S_IWRITE|S_IEXEC); /* repertoire courant si non specifie */
  #endif
  #else
  retour=mkdir(tempdir,S_IREAD|S_IWRITE|S_IEXEC); /* repertoire courant si non specifie */
  #endif
  #endif
  #endif

  if (retour) {
    if (errno==EACCES) retour=1;
    else retour=3;
    }
  }
return(retour);
}


int COPYFILE(char *source,char *destination)
//********************************************************************
// Copie fichier source vers destination
// Retour: 0 ok
//         1 source=destination
//         2 cannot open source
//         3 unable to create destination
//         4 erreur durant copie
//********************************************************************
{
unsigned int bread,bwrite;
FILE *f1,*f2;
//int handle1,handle2;
char filebuf[20480L]; /* Attention, cette variable prend 32ko */
FULLPATH(source);FULLPATH(destination);
if (strcmp(source,destination)==0) return(1);
if ((f1=fopen(source,"rb"))==NULL) return(2);
if ((f2=fopen(destination,"wb"))==NULL) return(3);
do {
  bwrite=fwrite(filebuf,1,(bread=fread(filebuf,1,sizeof(filebuf),f1)),f2);
  }
while ((bread) && (bread==bwrite));
fclose(f2);
fclose(f1);
return((bread!=bwrite)?4:0);
}

