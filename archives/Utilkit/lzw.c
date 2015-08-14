//********************************************************************
// Compress/Uncompress a file using Lempel Ziv Welch algorithm
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Lzw"
#define VERSION	"3.0"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>

#include "compress.h"
#include "hardware.h"
#include "macros.h"

#define EXTC  ".lzw"
#define EXTC2 "lzw"		// Must be EXTC without "."
#define EXTD  ".lzd"
int i;


int main(int argc,char *argv[])
/*******************************************************************/
/* RETURN:  0  Ok                                                  */
/*          1  Mauvaise ligne de commande ou argument non valide   */
/*          2  Impossible d'ouvrir le fichier source               */
/*          3  Impossible d'ouvrir le fichier destination          */
/*          4  Memoire insuffisante                                */
/*          5  Erreur autre                                        */
/*          6  Format invalide                                     */
/*          7  Erreur d'integrite                                  */
/*******************************************************************/
{
char ext[MAXEXT]="";
char path1[MAXPATH]="";
char path2[MAXPATH]="";

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
    if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    switch (argv[noarg][1] | 0x20) {
      case '?':
	  case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else {
    if (path1[0]==0) strcpy(path1,argv[noarg]);
    else strcpy(path2,argv[noarg]);
    }
  }

/* Affiche en-tete */
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage: %s  source_file.ext                          to compress\n",PROG);
	printf("       %s  source_file%s [destination_file]       to uncompress\n",PROG,EXTC);
	printf("\n");
	printf("After compressing, the resulting file has the %s extension.\n",EXTC);
	printf("After uncompressing, the resulting file has the %s extension if not specified.",EXTD);
	printf("\n");
	printf("%s is a simple compress/uncompress program using just the Lempel-Ziv-Welch\n",PROG);
	printf("algorithm.\n");
	printf("Note: This utility goal is not to be as powerful as ARJ or ZIP, but is to offer\n");
	printf("a simple and free way to add compression in softwares, by using its C sources \n");
	printf("with only 2 functions, one to compress and one to uncompress.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

// Recherche extension
for (i=strlen(path1);i>0;i--) {
	if (path1[i]=='\\') break;
	if (path1[i]=='.') {
		path1[i]=0;
		strcpy(ext, path1+i+1);
		break;
	}
}

if (strcmp(ext,EXTC2)) {
/************************/
/* Cas de compression   */
/************************/
  printf("Compression in progress...");
  strcpy(path2,path1);strcat(path2,EXTC);
  switch (Compression_LZW(path1,path2)) {
    case 0:printf("\rCompression finished.                   \n");
      break;
    case 1:fprintf(stderr,"\rError: Enable to open the source file %s\n",path1);
      exit(2);
      break;
    case 2:fprintf(stderr,"\rError: Enable to open the destination file %s%s.\n",path1,ext);
      exit(3);
      break;
    case 3:fprintf(stderr,"\rError: Not enough memory.\n");
      remove(path2);
      exit(4);
      break;
    case 4:fprintf(stderr,"\rError: Unknown error.\n");
      remove(path2);
      exit(5);
      break;
    }
  }
else {
/************************/
/* Cas de decompression */
/************************/
  printf("Uncompressing in progress...");
  if (path2[0]==0) strcpy(path2,path1);strcat(path2,EXTD);
  strcat(path1,EXTC);	// On remet son extension
  switch (DeCompression_LZW(path1,path2)) {
    case 0:printf("\rUncompression finished.                      \n");
      break;
    case 1:fprintf(stderr,"\rError: Enable to open the source file %s\n",path1);
      exit(2);
      break;
    case 2:fprintf(stderr,"\rError: Enable to open the destination file.\n");
      exit(3);
      break;
    case 3:fprintf(stderr,"\rError: Not enough memory.\n");
      remove(path2);
      exit(4);
      break;
    case 4:fprintf(stderr,"\rError: Compressed file format is not valid.\n");
      remove(path2);
      exit(6);
      break;
    case 5:fprintf(stderr,"\rError: Bad integrity of compressed file.\n");
      remove(path2);
      exit(7);
      break;
    }
  }
return(0);
}
