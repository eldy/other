//********************************************************************
// Update target directory with source files
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Update"
#define VERSION	"3.0"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <sys/stat.h>

#include "misc.h"
#include "hardware.h"
#include "ansi.h"
#include "macros.h"


/* Variables */
int ajout=0,sub=0;
int status;
char argument1[MAXPATH];
char argument2[MAXPATH];
char path[MAXPATH];
char s1[MAXPATH];
char s2[MAXPATH];
int attribut=0x20; // Recherche fichiers Normaux et Archives
unsigned int nbrefichiers=0;
char drive1[MAXDRIVE];
char dir1[MAXDIR];
char name1[MAXFILE];
char ext1[MAXEXT];
char path1[MAXPATH];
char drive2[MAXDRIVE];
char dir2[MAXDIR];
char name2[MAXFILE];
char ext2[MAXEXT];
char path2[MAXPATH];
struct ftime ft;
struct ftime ft2;
int bread,bwrite;
int handle1,handle2;
char filebuf[32750L]; /* Attention, ce buffer prend 32ko, il ne reste donc que       */
		      /* que 32ko de donn‚es de disponible pour les autres variables */


void Mise_a_jour(char *path1,char *path2,int Attribut)
//***********************************************************************
// Entr‚e:path source et path destination, et struct sur fichier source
// Sortie:Aucune
//***********************************************************************
{
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char s[MAXPATH];
// Get Date for both files
if ((handle1=open(path1,O_RDONLY|O_BINARY,S_IREAD))!=-1) { // Ouvre mode mise … jour
  getftime(handle1,&ft);
  if ((handle2=open(path2,O_RDONLY|O_BINARY,S_IREAD))!=-1) { // Target file already exist.
    getftime(handle2,&ft2);
    if (((ft.ft_year<<9)+(ft.ft_month<<5)+ft.ft_day)>((ft2.ft_year<<9)+(ft2.ft_month<<5)+ft2.ft_day)) {
      close(handle2);
      printf("Update %-12s to %s",path1,path2);
      handle2=open(path2,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD);
      do {
	bwrite=write(handle2,filebuf,(bread=read(handle1,filebuf,sizeof(filebuf))));
	}
      while ((bread) && (bread==bwrite));
      close(handle1);
      if (bread!=bwrite) {
	printf("  - Error\n");
	close(handle2);
	}
      else {
	setftime(handle2,&ft);
	close(handle2);
	_dos_setfileattr(path1,Attribut&0xDF); // Supprime attribut Archive
	_dos_setfileattr(path2,Attribut&0xDF); // Supprime attribut Archive
	printf("  - Ok\n");
	++nbrefichiers;
	}
      return;
      }
    if ((ft.ft_year==ft2.ft_year) && (ft.ft_month==ft2.ft_month) && (ft.ft_day==ft2.ft_day)) {
      if (((ft.ft_hour<<11)+(ft.ft_min<<5)+ft.ft_tsec)>((ft2.ft_hour<<11)+(ft2.ft_min<<5)+ft2.ft_tsec)) {
	close(handle2);
	printf("Update %-12s to %s",path1,path2);
	handle2=open(path2,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD);
	do {
	  bwrite=write(handle2,filebuf,(bread=read(handle1,filebuf,sizeof(filebuf))));
	  }
	while ((bread) && (bread==bwrite));
	close(handle1);
	if (bread!=bwrite) {
	  close(handle2);
	  printf("  - Error\n");
	  }
	else {
	  setftime(handle2,&ft);
	  close(handle2);
	  _dos_setfileattr(path1,Attribut&0xDF); // Supprime attribut Archive
	  _dos_setfileattr(path2,Attribut&0xDF); // Supprime attribut Archive
	  printf("  - Ok\n");
	  ++nbrefichiers;
	  }
	return;
	}
      }
    close(handle1);close(handle2);
    }
  else {                           // Target file doesn't exist.
    if (ajout) {
      // Test if dir exist, if not, ask to create it
      if (!DIREXIST(argument2)) {
	printf("Directory %s doesn't exist. Do you want to create it (Y/N) ? ",argument2);
	if ((WaitKey() | 0x20)=='y')  MAKEDIR(argument2);
	else {
	  printf("\n\rUpdate canceled.\n");
	  exit(5);
	  }
	printf("\n");
	}
      // Test if subdir exist, if not, create it
      fnsplit(path2,drive,dir,name,ext);
      strcpy(s,drive);strcat(s,dir);
      if (!DIREXIST(s)) MAKEDIR(s);
      printf("Add    %-12s to %s",path1,path2);
      handle2=open(path2,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD);
      do {
	bwrite=write(handle2,filebuf,(bread=read(handle1,filebuf,sizeof(filebuf))));
	}
      while ((bread) && (bread==bwrite));
      if (bread!=bwrite) {
	close(handle2);
	remove(path2); // Supprime copie rat‚e
	printf("  - Error\n");
	}
      else {
	setftime(handle2,&ft);
	close(handle2);
	_dos_setfileattr(path1,Attribut&0xDF); // Supprime attribut Archive
	_dos_setfileattr(path2,Attribut&0xDF); // Supprime attribut Archive
	printf("  - Ok\n");
	++nbrefichiers;
	}
      }
    close(handle1);
    }
  }
}


void scan_rep(char drive2[MAXDRIVE],char dir2[MAXDIR],char name2[MAXFILE],char ext2[MAXEXT])
//***********************************************************************
//
//***********************************************************************
{
struct ffblk ffblk;
char drive3[MAXDRIVE];
char dir3[MAXDIR];
char name3[MAXFILE];
char ext3[MAXEXT];
char chemins[MAXPATH];
char chemind[MAXPATH];
char s[MAXPATH];
char s2[MAXPATH];
int i;
// Recherche de sous r‚pertoires si option sub
if (sub) {
  strcpy(chemins,drive2);strcat(chemins,dir2);strcat(chemins,"*.*");
  if (!findfirst(chemins,&ffblk,0x10)) {
    do {
       fnsplit(ffblk.ff_name,drive3,dir3,name3,ext3);
       if ((dir3[0]!='.') && (ffblk.ff_attrib&0x10)) { // Si rep
	 strcpy(chemins,dir2);strcat(chemins,name3);
	 strcat(chemins,ext3);strcat(chemins,"\\");
	 // Appel r‚cursif pour sous r‚pertoire
	 scan_rep(drive2,chemins,name2,ext2);
	 }
       }
    while (!findnext(&ffblk));
    }
  }
strcpy(chemins,drive2);strcat(chemins,dir2);
i=0;
while ((chemins[i]==path[i]) && (chemins[i]!=0)) {i++;};
strcpy(chemind,chemins+i);
if (chemind[0] == '\\') strcpy(chemind,chemind+1);
strcat(chemins,name2);strcat(chemins,ext2);
// Recherche fichiers du r‚pertoire
if (!findfirst(chemins,&ffblk,0x21)) {
  do {
    strcpy(s,drive2);strcat(s,dir2);strcat(s,ffblk.ff_name);
    strcpy(s2,argument2);strcat(s2,chemind);strcat(s2,ffblk.ff_name);
    Mise_a_jour(s,s2,ffblk.ff_attrib);
    }
  while (!findnext(&ffblk));
  }
}



int main(int argc,char *argv[])
//******************************************************************
// RETURN:  0  Ok
//          1  Bad argument(s)
//          2  Disque ou r‚pertoire source non valide
//          3  Disque ou r‚pertoire destination non valide
//          4  Source=Destination
//          5  Update canceled
//******************************************************************
{

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'a': ajout=-1;break;
      case 's': sub=-1;break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else {
    if (argument1[0]==0) {strcpy(argument1,argv[noarg]);continue;}
    if (argument2[0]==0) {strcpy(argument2,argv[noarg]);continue;}
    invalide=-1;
    }
  }
if (argument2[0]==0) invalide=-1;

/* Affiche en-tˆte */
if (help) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage: %s  <source_files> <destination_dir>  [/a] [/s]    (* and ? allowed)\n",PROG);
  printf("\n");
  printf("UpDate copies source file(s) in the destination_directory, on the condition that");
  printf("they are more recent  (they overwrite the previous versions).\n");
  printf("If the /a option is used,  source file(s) that didn't exist in the destination\n");
  printf("will be added.\n");
  printf("If the /s option is used, the subdirectories tree will be included in updating.\n");
  printf("After the update, the Archive attribut of the source and destination file(s)\n");
  printf("will be set off.\n");
  printf("\n");
  printf("This program is mostly interesting for the regular backup of projects:\n");
  printf("By indicating in the source, the project directory and in the destination, the\n");
  printf("directory where to backup, UpDate saves only the files which were modified since");
  printf("the last update (detected by the date).\n");
  printf("Drives are less used and time is saved.  Also, it's needless to remember the\n");
  printf("files that were modified,  Update detects them by their date.\n");
  printf("\n");
  printf("Options are:    /a   To add All files even if they didn't exist in destination.\n");
  printf("                /s   To execute Update in Subdirectories too.\n");
  exit(0);
  }
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage: %s  <source_files> <destination_dir>  [/a] [/s]    (* and ? allowed)\n",PROG);
	printf("Error: Bad argument(s).\n");
	exit(1);
	}

// Cr‚ation path complet
fnsplit(argument1,drive1,dir1,name1,ext1);
if (*name1==0) strcat(argument1,"*.*");
else if (*ext1==0) strcat(argument1,"\\*.*");
FULLPATH(argument1);
fnsplit(argument1,drive1,dir1,name1,ext1);
strcpy(path,drive1);strcat(path,dir1);
// Path1 et Path complet termin‚, argument1=nom(s) fichier(s)
FULLPATH(argument2);
if (argument2[strlen(argument2)-1]!='\\') strcat(argument2,"\\");
fnsplit(argument2,drive2,dir2,name2,ext2);
// Path2 complet termin‚, argument2=nom r‚pertoire
// drive valide ?
if ((status=DRIVE_STATUS(drive1[0]))==0) {
  fprintf(stderr,"Source drive is not valid.\n");
  exit(2);
  }
if ((status=DRIVE_STATUS(drive2[0]))==0) {
  fprintf(stderr,"Destination drive is not valid.\n");
  exit(3);
  }
// dir existe et valide ?
strcpy(s1,drive1);strcat(s1,dir1);
if (!DIREXIST(s1)) {
  fprintf(stderr,"Source path is not valid.\n");
  exit(2);
  }
strcpy(s2,drive2);strcat(s2,dir2);
if (strcmp(s1,s2)==0) {
  fprintf(stderr,"Source and destination can't be the same.\n");
  exit(4);
  }

// Lance recherche (r‚cursive) dans r‚pertoire de base
scan_rep(drive1,dir1,name1,ext1);

if (nbrefichiers) printf("%i file(s) updated.\n",nbrefichiers);
else printf("No file from %s updated.\n",s1);
return(0);
}

// Valeurs attribut fichiers
// 0x00 Normal file, no attributes
// 0x01 Read only attribute
// 0x02 Hidden file
// 0x04 System file
// 0x08 Volume label
// 0x10 Directory
// 0x20 Archive


