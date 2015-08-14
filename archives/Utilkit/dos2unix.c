//********************************************************************
// Convert a DOS Text File into a Unix Text File
//********************************************************************
// 19/08/98     3.0     Laurent Destailleur		Creation
//********************************************************************
#define PROG    "Dos2unix"
#define VERSION "3.0"

#include <stdio.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <fcntl.h>
#ifdef __GNUC__
#include <unistd.h>
#endif
#ifndef _WIN32
#include <unistd.h>
#endif
#ifdef _WIN32
#include <io.h>
#endif

#include "misc.h"
#include "hardware.h"
#include "macros.h"


/* Variables */
int j=1,accent=0;
char reponse;
int handle1,handle2;
int idem;
char buf;
char dest[MAXPATH];
char s1[MAXPATH],s2[MAXPATH];

int main(int argc,char *argv[])
/*********************************************************************/
/* RETURN:  0  Ok                                                    */
/*          1  Mauvaise ligne de commande                            */
/*          2  Fichier source introuvable                            */
/*          3  Erreur lors de l'ecriture du fichier destination      */
/*          4  Impossible de renommer DOS2UNIX.TMP                   */
/*********************************************************************/
{
// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
    if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    switch (argv[noarg][1] | 0x20) {
      case 'a':accent=-1;break;
      case '?':
	  case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else {
    if (j==1) strcpy(s1,argv[noarg]);
    if (j==2) strcpy(s2,argv[noarg]);
    if (j>2) invalide=-1;
    j++;
    }
  }
/* Affiche en-tete */
if (help) {     
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  File_to_convert\n\n",PROG);
	printf("Dos2Unix converts a DOS text file (lines ended by CR+LF) into a UNIX text file\n");
	printf("(lines ended by LF only).\n");
	printf("Moreover, if you use the /a option, Dos2Unix changes all accentuated characters\n");;
	printf("of the French DOS page code (extended ASCII characters 128 to 255) into non\n");
	printf("accentuated characters.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

if (s2[0]==0) strcpy(s2,s1);
/* Si source n'existe pas */
if (!FILEEXIST(s1)) {
  fprintf(stderr,"Error: Source file %s can't be found.\n",s1);
  exit(2);
  }
/* Si destination = source */
FULLPATH(s1);FULLPATH(s2);
if (strcmp(s1,s2)==0) {
  idem=-1;strcpy(dest,"dos2unix.tmp");
  }
else {
  idem=0;strcpy(dest,s2);
  }
/* Si destination existe dÇjÖ */
if ((!idem) && (FILEEXIST(s2))) {
  printf("Warning: Destination file already exists.  Overwrite it (Y/N) ? ");
  reponse=fgetc(stdin);
  if ((reponse | 0x20)=='n') {
    fprintf(stderr,"Operation canceled.\n");
    exit(0);
    }
  }
handle1=open(s1,O_RDONLY|O_BINARY);
if ((handle2=open(dest,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE))==-1) {
  fprintf(stderr, "Error: Can't create the new destination file.\n");
  exit(3);
  }
printf("Processing is in progress...\n");
while (read(handle1,&buf,1)==1) {
  if (accent) {
  switch (buf) {
    case 'É':
    case 'Ñ':
    case 'Ö':
    case 'Ü':
    case '†':buf='a';break;
    case 'é':
    case 'è':buf='A';break;
    case 'Ç':
    case 'à':
    case 'â':
    case 'ä':buf='e';break;
    case 'ê':buf='E';break;
    case 'ã':
    case 'å':
    case 'ç':
    case '°':buf='i';break;
    case 'ì':
    case 'î':
    case 'ï':
    case '¢':buf='o';break;
    case 'ô':buf='O';break;
    case 'Å':
    case 'ñ':
    case 'ó':
    case '£':buf='u';break;
    case 'ö':buf='U';break;
    }
  }
  if (buf!='\r') {
    if (write(handle2,&buf,1)==-1) {
      fprintf(stderr, "Error: Failure during writing of file %s",dest);
      exit(3);
      }
    }
  }
close(handle1);
close(handle2);
if (idem) {
	if (COPYFILE("dos2unix.tmp",s2)) {
	    fprintf(stderr,"Error: Failure during copying dos2unix.tmp into file %s.\n",s2);
	    fprintf(stderr,"Destination file was created under the name dos2unix.tmp\n");
	    exit(4);
    }
}
if (idem) remove("dos2unix.tmp");
printf("Operation finished: File %s is %s.",s2,idem?"changed":"created");
return(0);
}
