//********************************************************************
// Send a file to printer and return an error code to DOS
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Print2"
#define VERSION	"3.0"

#include <bios.h>
#include <dos.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>

#include "misc.h"
#include "hardware.h"
#include "macros.h"


/* Variables */
int handle,status;
char buf;
char source[MAXPATH]="";
int b=0;


int Init_printer(void)
/* Initialise imprimante */
/* Vide son buffer       */
{
return(biosprint(1,0,0));
}


void Init_fin(int retour)
/* Termine avec code erreur */
{
switch (retour) {
  case 1:printf("\rError: No or no more answer of printer (Time Out).\n");break;
  case 2:printf("\rError: Printer not active (Off Line).\n");break;
  case 3:printf("\rError: Error during transmission (I/O Error).\n");break;
  case 4:printf("\rError: No paper (Out of paper).\n");break;
  case 5:printf("\rError: Printer badly connected (I/O Error).\n");break;
  case 6:printf("\rError: Printer busy (Busy).\n");break;
  case 7:fprintf(stderr,"Error: Source file %s can't be found.\n",source);break;
  case 8:fprintf(stderr,"Error: Source file %s can't be opened.\n",source);break;
  case 9:break;
  }
exit(retour);
}


int main(int argc,char *argv[])
/*********************************************************************/
/* PROGRAMME PRINCIPAL                                               */
/* Retour:  0 Ok
/*          1 Time Out
/*          2 I/O Erreur
/*          3 Selected
/*          4 Out of paper
/*          5 No Acknowledge
/*          6 Busy
/*          7 Fichier source inexistant
/*          8 Impossible d'ouvrir le fichier source
/*          9 Bad argument(s)
/*********************************************************************/
{

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0,reset=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'r': reset=-1;break;
      default: invalide=-1;
      }
    }
  else strcpy(source,argv[noarg]);
  }

if (help) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  <file_name>  [/r]\n",PROG);
  printf("\n");
  printf("Print2 allow you to print a file from the prompt or in batch files and to get a\n");
  printf("return code even when an error occur: You are not stopped by the following\n");
  printf("message: Error, Abandon, Retry ? \n");
  printf("The printing begin and last until the end.  If an error occur, the process is\n");
  printf("stopped and the following code is returned:\n");
  printf("          0 - Printing Ok.\n");
  printf("          1 - Error: No or no more answer (Time Out).\n");
  printf("          2 - Error: Printer not active (Off Line).\n");
  printf("          3 - Error: Error during transmission (I/O Error).\n");
  printf("          4 - Error: No paper (Paper Out).\n");
  printf("          5 - Error: Printer badly connected (I/O Error).\n");
  printf("          6 - Error: Printer busy (Busy).\n");
  printf("          7 - Error: Source file can't be found.\n");
  printf("          8 - Error: Source file can't be opened.\n");
  printf("          9 - Error: Bad argument(s)\n");
  printf("\n");
  printf("The option /r (reset) make an initialization of the printer before starting.\n");
  printf("\n");
  Init_fin(0);
  }
if (invalide) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  <file_name>  [/r]\n",PROG);
  printf("Error:  Bad argument(s).\n");
  exit(9);
  }

/* Si source n'existe pas */
if (source[0]) if (!FILEEXIST(source)) Init_fin(7);
if (source[0]) if ((handle=open(source,O_RDONLY|O_BINARY))==-1) Init_fin(8);
/* Initialise imprimante */
if (reset) {
  printf("Initialization in progress...");
  status=Init_printer();delay(5000);
  printf("\r");
  #ifdef DEBUG
  printf("Printer status after (during) init: %xh\n",status);
  #endif
  if (status & 0x01) Init_fin(1);         /* Time Out         */
  /* Le code suivant n'est pas exploitable … l'initialisation */
  /* if (status & 0x20) Init_fin(4);      /* Plus de papier   */
  if (status & 0x08) Init_fin(5);         /* I/O Erreur       */
  /* Le code suivant n'est pas exploitable … l'initialisation */
  /* if ((status & 0x10)==0) Init_fin(2); /* Off Line         */
  }
/* Si pas de source sp‚cifi‚, on voulait juste reseter */
if (source[0]==0) Init_fin(0);
b=0x10; /* On suppose imprimante On Line */
printf("Printing in progress...");
while ((b==0x10) && (read(handle,&buf,1)==1)) {
  status=biosprint(0,(int) buf,0);
  b=status&0x39; /* Masque bits 6 et 7 (Acknowledge et Not busy) pour continuer */
		 /* Masque aussi les bits 1 et 2 */
  #ifdef DEBUG
  printf("\nStatus during printing: %xh",status);
  #endif
  }		 /* boucle si reception signal Not busy ou Acknowledge */
close(handle);
/* Teste retour etat imprimante */
#ifdef DEBUG
printf("\nLast status: %xh\n",status);
#endif
if (b & 0x01) Init_fin(1);      /* Time Out         */
if (b & 0x20) Init_fin(4);      /* Plus de papier   */
if (b & 0x08) Init_fin(3);      /* I/O Erreur       */
if ((b & 0x10)==0) Init_fin(2); /* Off Line         */
/* Eventuellement rajoute un saute de page */
printf("\rPrinting is finished.\n");
return(0);                           /* Aucune erreur                */
}

/**********************************/
/* Status d'imprimante:           */
/*                                */
/* Bit:    7 6 5 4 3 2 1 0        */
/*                                */
/* Ligne:  7 = Not busy           */
/*         6 = Acknowledge        */
/*         5 = Out of paper       */
/*         4 = On Line            */
/*         3 = I/O error          */
/*         2 = ?                  */
/*         1 = ?                  */
/*         0 = Time out           */
/**********************************/
