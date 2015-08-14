//********************************************************************
// Add several files making one.
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Merge"
#define VERSION	"3.0"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <io.h>
#include <sys/stat.h>
#ifdef __GNUC__
#include <unistd.h>
#endif
#ifndef _WIN32
#include <unistd.h>
#endif

#include "macros.h"


/* Variables */
int i;
char buf[BUFSIZ];
int r;
int partnum;
int outf, f;


int p_open(char *ob, int p)
{
char partname[MAXPATH];
sprintf(partname, "%s.%03d", ob, p);
return open(partname,O_RDONLY|O_BINARY);
}


int main(int argc, char *argv[])
/*********************************************************************/
/* RETURN:  0  Ok                                                    */
/*          1  Bad argument(s)                                       */
/*          2  Erreur lors de la lecture premier fichier source      */
/*          3  Erreur lors de l'‚criture du fichier destination      */
/*********************************************************************/
{
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
  }

/* Affiche en-tˆte */
if (help) {	
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <source_files_names>  <destination_file>\n",PROG);
	printf("\n");
	printf("MERGE  is an utility to merge the files called <source_files_name>.xxx, into the");
	printf("file <destination_file>. \n");
	printf("All files  <source_files_name>.xxx  (where xxx is a number from 001 to 999) will");
	printf("be used to create the file <destination_file>.\n");
	printf("So, a maximum of 999 files can be concatenated.\n");
	printf("\n");
	printf("Ex:  MERGE  PROGRAM  PROGRAM.EXE\n");
	printf("This example create the file PROGRAM.EXE from the files PROGRAM.001,PROGRAM.002,");
	printf("PROGRAM.003 etc...\n");
	printf("\n");
	printf("MERGE make the opposite action of SPLIT that cut a file in several files.\n");
	printf("\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

/* Test files */
partnum=1;
if ((f=p_open(argv[1],partnum))==-1) {
  fprintf(stderr, "Error: Failure during the reading of first file %s.001\n",argv[1]);
  exit(2);
  }
outf=open(argv[2],O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
while (1) {
  r=read(f,buf,(unsigned int) BUFSIZ);
  if (r<=0) { /* Erreur lecture ou fin fichier */
    close(f);
    partnum++;
    if ((f=p_open(argv[1],partnum))==-1) { /* Ouvre suivant */
      /* Si erreur */
      printf("Process finished:  file %s is created.\n",argv[2]);
      exit(0);
      }
    }
  else {
    if (write(outf,buf,r)==-1) {
      fprintf(stderr, "Error: Failure during writing of file %s.\n",argv[2]);
      exit(3);
      }
    }
  }
return(0);
}
