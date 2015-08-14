//********************************************************************
// Cut one file in several files
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Split"
#define VERSION	"3.0"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <io.h>
#include <math.h>

#ifdef __GNUC__
#include <unistd.h>
#endif
#ifndef _WIN32
#include <unistd.h>
#endif

#include "macros.h"
#include "hardware.h"


/* Variables */
int i;
char buf[BUFSIZ];
double d;
unsigned long left, chunksize;
int r;
int partnum;
int inf, f;
char *endp;
struct stat statbuf;


int p_open(char *ob,int p)
{
char partname[MAXPATH];
sprintf(partname, "%s.%03d", ob, p);
return open(partname,O_WRONLY|O_BINARY|O_CREAT|O_TRUNC,S_IREAD|S_IWRITE);
}


int main(int argc,char *argv[])
/*********************************************************************/
/* RETURN:  0  Ok                                                    */
/*          1  Bad argument(s)                                       */
/*          2  Fichier source introuvable                            */
/*          3  Erreur lors de la lecture du fichier source           */
/*          4  Valeur du paramŠtre de coupe non valide               */
/*          5  Impossible d'ouvrir le fichier destination            */
/*          6  Erreur lors de l'‚criture du fichier destination      */
/*          7  Trop de fichiers g‚n‚r‚s                              */
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
	printf("Usage:  %s  <source_file>  <cutting_size>  <destination_name>\n",PROG);
	printf("\n");
	printf("SPLIT  is an utility to split a <source_file> into several smallest files with\n");
	printf("a size of <size_of_cut> .\n");
	printf("Those files, created by the cut, has the name <destination_name>.xxx where xxx\n");
	printf("is a number: The 1st file has the extension .001, the next one .002, etc...\n");
	printf("\n");
	printf("A maximum of 999 files can be obtained by this way. So the size_of_cut specified");
	printf("can't be less than the size of <source_file> diviede by 999.\n");
	printf("This <size_of_cut> is by default in bytes unit.  Add 'K' or 'M' to the number\n");
	printf("to use a size in Kbytes ou Mbytes.\n");
	printf("\n");
	printf("Ex:  SPLIT  PROGRAM.EXE  100K  PROGRAM\n");
	printf("This example split the file PROGRAM.EXE into PROGRAM.001, PROGRAM.002, etc...\n");
	printf("Each piece of the file has a size of 100Kbytes (or less for the last piece).\n");
	printf("\n");
	printf("SPLIT make the opposite action of MERGE that merge several files into one.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

/* Test files */
if (!FILEEXIST(argv[1])) {
  fprintf(stderr,"Error: Source file can't be found.\n");
  exit(2);
  }
if (FILEEXIST(argv[2])) {
  fprintf(stdout,"Warning: Destination file already exist.  Overwrite (Y/N) ? ");
  if ((fgetc(stdin) | 0x20)=='n') {
    fprintf(stderr,"Processing canceled.\n");
    exit(0);
    }
  }
if ((inf=open(argv[1],O_RDONLY|O_BINARY))==-1) {
  fprintf(stderr,"Error: Enable to open the source file.\n");
  exit(3);
  }
d=strtod(argv[2],&endp);
switch (argv[2][strlen(argv[2])-1]) {
  case 'k':
  case 'K':
    d *= 1024L;
    break;
  case 'm':
  case 'M':
    d *= 1000 * 1024L;
    break;
  }
if (d<1) {
  fprintf(stderr,"Error: <Cutting size> parameter is not valid.\n");
  exit(4);
  }
if (ceil(d)!=d) {
  fprintf(stderr,"Error: <Cutting size> parameter must be a number of bytes.\n");
  exit(4);
  }
chunksize=(unsigned long) ceil(d);
/* Teste si taille source / chunksize < 999 */
fstat(inf,&statbuf);
if ((statbuf.st_size/chunksize)+1>999) {
  fprintf(stderr,"Error: Split can't split a file into more than 999 files.\n");
  exit(7);
  }
partnum=1;
left=chunksize;
if ((f=p_open(argv[3],partnum))==-1) {
  fprintf(stderr,"Error: Can't open destination file %s.%03d.\n",argv[3],partnum);
  exit(5);
  }
printf("Splitting in progress...\n");
while (1) {
  if (left<BUFSIZ)
    r=_read(inf,buf,(unsigned int) left);
  else
    r=_read(inf,buf,(unsigned int) BUFSIZ);
  if (r<=0) {
    printf("Process finished:  %d files created.\n",partnum);
    _close(f);
    exit(0);
    }
  if (_write(f,buf,r)==-1) {
    fprintf(stderr,"Error: Failure during the writing of file %s,%03d.\n",argv[3],partnum);
    _close(f);
    exit(6);
    }
  left-=(unsigned long) r;
  if (left==0) {
    _close(f);
    partnum++;
    if ((f=p_open(argv[3],partnum))==-1) {
      fprintf(stderr,"Error: Can't open destination filet %s.%03d.\n",argv[3],partnum);
      exit(5);
      }
    left=chunksize;
    }
  }

return (0);
}
