//********************************************************************
// Change C++ comments to C comments
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Cpp2Ccom"
#define VERSION	"3.0"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "macros.h"


/* Variables */
int i;
char destination[MAXPATH];



int main (int argc, char **argv)
//********************************************************************
// Return: 0  Ok
//         1  Bad Argument(s)
//         2  Source file is not valid
//         3  Can't open destination file
//********************************************************************
{
int Char,Char2,cpp_comment=0,c_comment=0,in_string=0,cpp_multiline=0;
FILE *InFile,*OutFile;

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
	printf("Usage:  %s  <source_file_with_c++_comment>  [destination_file]\n\n",PROG);
	printf("CPP2CCOM is for \"C++ to C Comments\".  This utility converts comments from a C++\n");
	printf("file (begining with //) into C comments (Between /*   */).\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}


if ((InFile=fopen(argv[1],"rt"))==NULL) {
  printf("Error:  Source file %s can't be found.\n",argv[1]);
  exit(2);
  }
if (argc==3) strcpy(destination,argv[2]);
else strcpy(destination,"cpp2ccom.tmp");
if ((OutFile=fopen(destination,"wt")) == NULL) {
  printf("Error:  Can't open destination file %s.\n",argv[2]);
  exit(3);
  }

while ((Char = fgetc (InFile)) != EOF) {
	    fputc (Char, OutFile);
	    if (Char == '\"')
	    {
		  Char2 = fgetc (InFile);       /* check next char      */
		  if (Char2 != '\'')            /* character constant?  */
			in_string = ! in_string;/* no, toggle flag      */
		  fputc (Char2, OutFile);
	    }

	    if (in_string)                /* we are in a string now     */
		  continue;

	    if (Char == '/')
	    {
		  Char = fgetc (InFile);  /* check next char            */
		  if (Char == '/')        /* is it start of C++ comment */
		  {
			Char = '*';       /* change it to C comment     */
			cpp_comment = 1;
		  }
		  else if (Char == '*')   /* is it start of C comment   */
			c_comment = 1;

		  fputc (Char, OutFile);
	    }
	    else if (Char == '*' && c_comment)
	    {
		  Char = fgetc (InFile);
		  if (Char == '/')        /* is it end of C comment     */
			c_comment = 0;
		  fputc (Char, OutFile);
	    }

	    if (c_comment || cpp_comment) /* inside C or C++ comment    */
	    {
		  /* check the rest of the line       */

		  while ((Char = fgetc (InFile)) != '\n')
		  {
			if (Char == '\\' && cpp_comment)
			      cpp_multiline = 1;
			if (Char == '*')
			{
			      Char2 = fgetc (InFile); /* check next char   */
			      ungetc (Char2, InFile); /* put it back       */
			      if (Char2 == '/')       /* end of C comment? */
			      {
				    c_comment = 0;
				    /* end of C comment inside C++ comment?*/
				    if (cpp_comment)
				    {
					  fputs ("* ", OutFile);
					  Char = fgetc (InFile);
				    }
			      }
			}
			fputc (Char, OutFile);
		  }
		  if (cpp_comment && cpp_multiline == 0)
		  {
			/* put ending C comment mark */
			fputs (" */", OutFile);
			cpp_comment = 0;
		  }
		  fputc ('\n', OutFile);
		  /* clear flag for the next round. if it is still clear after
		     next C++ comment line is processed, multiline C++ comment
		     is ended.
		  */
		  cpp_multiline = 0;
	    }
      } /* while end */
/* Fermeture des fichiers et affichage r‚sultat */
fclose(OutFile);
fclose(InFile);
if (argc==3) printf("Conversion finished: file %s made.\n",destination);
else {
  remove(argv[1]);
  if (rename("cpp2ccom.tmp",argv[1])==0)
    printf("Conversion finished: file %s modified.\n",argv[1]);
  else {
    printf("Error: File CPP2CCOM.TMP couldn't be renamed in %s.\n",argv[1]);
    }
  }
return(0);
}
