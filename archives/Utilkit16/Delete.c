//********************************************************************
// Delete all files in argument line (better than DEL)
//********************************************************************
// 19/08/98	3.0	Laurent Destailleur		Creation
//********************************************************************
#define PROG    "Delete"
#define VERSION "3.0"


#ifndef __SMALL__
#error Memory model must be: Small
#endif


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <dos.h>

#include "misc.h"
#include "hardware.h"
#include "macros.h"


/* Types */
typedef struct { // Structure DIR des fonctions 4Eh et 4Fh
		BYTE          Reserve[21];
		BYTE          Attribut;
		unsigned int  Time;
		unsigned int  Date;
		unsigned long Size;
		char          Name[13];
	       } DIRSTRUCT;

/* Variables */
int hide=0,rea=0,sys=0,sub=0,toujours=0;
char argument[MAXPATH];
char path[MAXPATH];
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
unsigned int nbrefichiers=0;
unsigned long taillefichiers=0;
DIRSTRUCT Saisie;
struct dfree diskdispo;
unsigned long avail;


int efface(char *chaine)
//***********************************************************************
//
//***********************************************************************
{
_dos_setfileattr(chaine,Saisie.Attribut & 0xF4);
return(remove(chaine));
}


BYTE findf(char *Chemin, BYTE Attribut)
//***********************************************************************
// FINDF : Lire la premiŠre entr‚e de r‚pertoire
// Entr‚e: CHEMIN  =Ptr sur chemin de rech. avec masque fichier
//         ATTRIBUT=Attributs de recherche
// Retour: TRUE, si une entr‚e a ‚t‚ trouv‚e sinon FALSE
// Rem   : L'entr‚e est lue dans le DTA
//***********************************************************************
{
union REGS   regs;
struct SREGS Segments;
segread(&Segments);     // Lire le contenu des registres de segment
regs.h.ah=0x4E;         // Num‚ro de fonction pour FindFirst
regs.x.cx=Attribut;              // Attributs recherch‚s
regs.x.dx=(unsigned int) Chemin; // Offset du chemin de rech.
intdosx(&regs,&regs,&Segments);  // Interruption DOS 21h
return(!regs.x.cflag);  // Carry-Flag = 0: Un fichier trouv‚
}


BYTE findn(void)
//***********************************************************************
// FINDN : Lire l'entr‚e de r‚pertoire suivante
// Entr‚e: Aucune
// Retour: TRUE, si une entr‚e a ‚t‚ trouv‚e sinon FALSE
// Rem   : L'entr‚e est lue dans le DTA
//***********************************************************************
{
union REGS regs;
regs.h.ah=0x4F;        // Num‚ro de fonction pour FindNext
intdos(&regs,&regs);   // Appeler l'interruption DOS 21h
return(!regs.x.cflag); // Carry=0: Un fichier trouv‚
}


void SetDTA(unsigned int Offset)
//***********************************************************************
// SETDTA : Place le DTA sur une variable du segment de donn‚es
// Entr‚e : OFFSET = Offset du DTA dans le segment de donn‚es
// Sortie : Aucune
//***********************************************************************
{
union REGS   regs;
struct SREGS Segments;
segread(&Segments); // Lire le contenu des registres de segment
regs.h.ah=0x1A;     // D‚finir le num‚ro de fonction pour le DTA
regs.x.dx=Offset;   // Adresse d'offset dans le registre DX
intdosx(&regs,&regs,&Segments); // Interruption DOS 21h
}



void scan_rep(char drive2[MAXDRIVE],char dir2[MAXDIR],char name2[MAXFILE],char ext2[MAXEXT])
//***********************************************************************
//
//***********************************************************************
{
DIRSTRUCT saisie2;
char drive3[MAXDRIVE];
char dir3[MAXDIR];
char name3[MAXFILE];
char ext3[MAXEXT];
char chemin3[MAXPATH];
char s[MAXPATH];
int b;
// Recherche de sous r‚pertoires si option sub
if (sub) {
  strcpy(chemin3,drive2);strcat(chemin3,dir2);strcat(chemin3,"*.*");
  if (findf(chemin3,0x10)) {
    do {
       fnsplit(Saisie.Name,drive3,dir3,name3,ext3);
       if ((Saisie.Attribut & 0x10) && (dir3[0]!='.')) {
	 strcpy(chemin3,dir2);strcat(chemin3,name3);
	 strcat(chemin3,ext3);strcat(chemin3,"\\");
	 // Sauve Saisie en variable locale
	 saisie2=Saisie;
	 // Appel r‚cursif pour sous r‚pertoire
	 scan_rep(drive2,chemin3,name2,ext2);
	 // Replace variable locale dans Saisie
	 Saisie=saisie2;
	 }
       }
    while (findn());
    }
  }
strcpy(chemin3,drive2);strcat(chemin3,dir2);
strcat(chemin3,name2);strcat(chemin3,ext2);
// Recherche fichiers du r‚pertoire
if (findf(chemin3,0x37)) {
  b=TRUE; //Premier passage
  do {
    // Passe outre si r‚pertoire
    if (Saisie.Attribut & 0x10) continue;
    // Attributs
    if (Saisie.Attribut & 0x04)
      if (!sys) continue;
    if (Saisie.Attribut & 0x01)
      if (!rea) continue;
    if (Saisie.Attribut & 0x02)
      if (!hide) continue;
    // Si *.*
    if (b && (strcmp(name,"*")==0) && (strcmp(ext,".*")==0)) {
      b=FALSE;
      printf("Warning, do you really want to delete all files in directory %s%s (y/n) ? ",drive2,dir2);
      fflush(stdin);
      if ((getch() | 0x20) != 'y') {printf("N\n");break;}
      printf("Y\n");
      }
    strcpy(s,drive2);strcat(s,dir2);strcat(s,Saisie.Name);
    if (efface(s)) printf("Unable to delete %s\n",s);
    else {
      taillefichiers+=Saisie.Size;
      ++nbrefichiers;
      }
    }
  while (findn());
  }
}


int main(int argc,char *argv[])
//*******************************************************************
// RETURN:  0  Ok
//          1  Bad argument(s)
//          2  Mauvaise ligne de commande
//          3  Disque ou r‚pertoire non valide
//*******************************************************************
{
// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
    if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    switch (argv[noarg][1] | 0x20) {
      case 'a':
	switch (argv[noarg][2] | 0x20) {
	  case 'h': hide=-1;break;
	  case 'r': rea=-1;break;
	  case 's': sys=-1;break;
	  default: invalide=-1;
	  }
	switch (argv[noarg][3] | 0x20) {
	  case 'h': hide=-1;break;
	  case 'r': rea=-1;break;
	  case 's': sys=-1;break;
	  }
	switch (argv[noarg][4] | 0x20) {
	  case 'h': hide=-1;break;
	  case 'r': rea=-1;break;
	  case 's': sys=-1;break;
	  }
	break;
      case 's':
	sub=-1;break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else strcpy(argument,argv[noarg]);
  }

/* Affiche en-tˆte */
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  [file_names]  [/s] [/ah|r|s]\n\n",PROG);
	printf("DELETE is a 'Del' improved with options (like the Dos 'Dir' command):\n");
	printf("      /s    Go down in subdirectories too.\n");
	printf("      /ah   Delete files with Hide Attribut too.\n");
	printf("      /ar   Delete files with Read-Only Attribut too.\n");
	printf("      /as   Delete files with System Attribut too.\n");
	printf("      /ahrs Combine the three previous options.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad argument(s).\n");
	exit(1);
	}

/* Cr‚ation path complet */
fnsplit(argument,drive,dir,name,ext);
FULLPATH(argument);
fnsplit(argument,drive,dir,name,ext);
// Path complet termin‚, argument=nom fichiers sources
// drive valide ?
if (DRIVE_STATUS(drive[0])==0) {
  printf("Drive is not valid.\n");
  exit(3);
  }
// dir existe et valide ?
strcpy(path,drive);
if (!DIREXIST(strcat(path,dir))) {
  printf("Directory or path not valid.\n");
  exit(3);
  }
// SAISIE=nouveau DTA
SetDTA( (unsigned int) &Saisie );
// Lance recherche (r‚cursive) dans r‚pertoire de base
scan_rep(drive,dir,name,ext);
// Fin de recherche
if (nbrefichiers) {
  printf("\nDeleted file(s): %i",nbrefichiers);
  if (taillefichiers) printf(" %10lu byte freed.\n",taillefichiers);
  else printf(" 0 byte freed (All files had a null size).\n");
  }
else printf("No files found or deleted.\n");
return(0);
}


// Valeurs attributs fichiers
// 0x00 Normal file, no attributes
// 0x01 Read only attribute
// 0x02 Hidden file
// 0x04 System file
// 0x08 Volume label
// 0x10 Directory
// 0x20 Archive
