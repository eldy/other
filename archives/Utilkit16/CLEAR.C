//********************************************************************
// Delete all garbage files
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Clear"
#define VERSION	"3.0"

#ifndef __SMALL__
#error Memory model must be: Small
#endif
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <io.h>
#include <conio.h>
#include <dos.h>

#include "misc.h"
#include "hardware.h"
#include "macros.h"


// Types
typedef struct { // Structure DIR des fonctions 4Eh et 4Fh
		BYTE          Reserve[21];
		BYTE          Attribut;
		unsigned int  Time;
		unsigned int  Date;
		unsigned long Size;
		char          Name[13];
	       } DIRSTRUCT;

// Variables
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char path[MAXPATH];
int hide=-1,rea=-1,sys=0,nul=0,bak=0,old=0,syd=0,lo=0,all=0,toujours=0;
char argument[MAXPATH]="";
unsigned int nbrefichiers=0;
unsigned long taillefichiers=0;
DIRSTRUCT Saisie;
struct dfree diskdispo;
unsigned long avail;


int efface(char * drive2, char * dir2,char * chaine)
//***********************************************************************
//
//***********************************************************************
{
char s[MAXPATH];
strcpy(s,drive2);strcat(s,dir2);strcat(s,chaine);
_dos_setfileattr(s,Saisie.Attribut & 0xF4);
return(remove(s));
}


void DelData(char * drive2,char * dir2,DIRSTRUCT *Saisie)
//***********************************************************************
// Affiche ligne d'un fichier
// Entr‚e:Saisie = Ptr sur une structure Dir avec des informations
//***********************************************************************
{
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
fnsplit(Saisie->Name,drive,dir,name,ext);
if (Saisie->Attribut & 0x14) return;
// Demande confirmation
printf("\r                                               \rDelete %-8s%-4s [%c%c%c] (y/n/a): ",name,ext,Saisie->Attribut&0x20?'A':'-',
  Saisie->Attribut&0x01?'R':'-',Saisie->Attribut&0x02?'H':'-');
if (!toujours) {
switch (getch() | 0x20) {
  case 'a':
    toujours=-1;
    if (efface(drive2,dir2,Saisie->Name)) printf("Error\n");
    else {
      printf("Always\n");
      taillefichiers+=Saisie->Size;
      ++nbrefichiers;
      }
    break;
  case 'y':
    if (efface(drive2,dir2,Saisie->Name)) printf("Error\n");
    else {
      printf("Yes\n");
      taillefichiers+=Saisie->Size;
      ++nbrefichiers;
      }
    break;
  case 0x23:
    printf("Ctrl+Break\n");
    exit(0);
    break;
  case 'n':
    printf("No\n");
    break;
  default:
    printf("No\n");
    exit(0);
  }
}
else {
  if (efface(drive2,dir2,Saisie->Name)) printf("Error\n");
  else {
    printf("Yes\n");
    taillefichiers+=Saisie->Size;
    ++nbrefichiers;
    }
  }
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


void Set_DTA(unsigned int Offset)
//***********************************************************************
// SETDTA: Place le DTA sur une variable du segment de donn‚es
// Entr‚e: OFFSET = Offset du DTA dans le segment de donn‚es
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
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char chemin[MAXPATH];
// Recherche de sous r‚pertoires
strcpy(chemin,drive2);strcat(chemin,dir2);strcat(chemin,"*.*");
if (findf(chemin,0x10)) {
  do {
    fnsplit(Saisie.Name,drive,dir,name,ext);
    if ((Saisie.Attribut & 0x10) && (dir[0]!='.')) {
      strcpy(chemin,dir2);strcat(chemin,name);
      strcat(chemin,ext);strcat(chemin,"\\");
      // Sauve Saisie en variable locale
      saisie2=Saisie;
      // Appel r‚cursif pour sous r‚pertoire
      scan_rep(drive2,chemin,name2,ext2);
      // Replace variable locale dans Saisie
      Saisie=saisie2;
      }
    }
  while (findn());
  }
strcpy(chemin,drive2);strcat(chemin,dir2);
strcat(chemin,name2);strcat(chemin,ext2);
// Recherche fichier du r‚pertoire
if (findf(chemin,0x23) && (strcmp(Saisie.Name,"WIN386.SWP"))) {
  // Affiche nom des fichiers
  printf("\rDirectory %s%s                         \n",drive2,dir2);
  do DelData(drive2,dir2,&Saisie);while (findn());
  }
}

void scan_rep0(char drive2[MAXDRIVE],char dir2[MAXDIR],char name2[MAXFILE],char ext2[MAXEXT])
//***********************************************************************
//
//***********************************************************************
{
DIRSTRUCT saisie2;
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char chemin[MAXPATH];
int b;
// Recherche de sous r‚pertoires si option sub
strcpy(chemin,drive2);strcat(chemin,dir2);strcat(chemin,"*.*");
if (findf(chemin,0x10)) {
  do {
    fnsplit(Saisie.Name,drive,dir,name,ext);
    if ((Saisie.Attribut & 0x10) && (dir[0]!='.')) {
      strcpy(chemin,dir2);strcat(chemin,name);
      strcat(chemin,ext);strcat(chemin,"\\");
      // Sauve Saisie en variable locale
      saisie2=Saisie;
      // Appel r‚cursif pour sous r‚pertoire
      scan_rep0(drive2,chemin,name2,ext2);
      // Replace variable locale dans Saisie
      Saisie=saisie2;
      }
    }
  while (findn());
  }
strcpy(chemin,drive2);strcat(chemin,dir2);
strcat(chemin,name2);strcat(chemin,ext2);
// Recherche fichier du r‚pertoire
b=-1;
if (findf(chemin,0x27)) {
  // Affiche nom des fichiers
  do if ((Saisie.Size==0) && (Saisie.Name[0]!='.')) {
    if (b) {printf("\rDirectory %s%s                          \n",drive2,dir2);b=0;}
    DelData(drive2,dir2,&Saisie);
    }
  while (findn());
  }
}


int main(int argc,char *argv[])
//*******************************************************************
// Return: 0  Ok
//         1  Bad Argument(s)
//*******************************************************************
{
// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'b':bak=-1;break;
      case 'o':old=-1;break;
      case 's':syd=-1;break;
      case 'a':all=-1;break;
      case '0':nul=-1;break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else {
    if (argument[0]==0) strcpy(argument,argv[noarg]);
    else invalide=-1;
    }
  }

/* Affiche en-tˆte */
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <drive:start_directory>  [/option]             (* and ? allowed)\n",PROG);
	printf("Options are:     /bak   To delete *.bak files too.\n");
	printf("                 /old   To delete *.old files too.\n");
	printf("                 /syd   To delete *.syd files too.\n");
	printf("                 /0     To delete files with Null size too.\n");
	printf("                 /all   To combine all previous options.\n");
	printf("CLEAR allows you to \"clear\" your hard disk from all rubish files (like files\n");
	printf("issued of a crash).  It scans all subdirectories from the start_directory and\n");
	printf("delete all those files *.$$$, *.tmp, *.swp, *.000 (and *.bak, *.old, *.syd if\n");
	printf("the right option is used, and even Hidden and Read-only files).\n");
	printf("If the start_directory is not specified, the root directory is used.\n");
	printf("\n");
	printf("CLEAR asks for confirmation before deleting:\n");
	printf("Delete FILE.EXT [ARH]  (y/n/a) ?\n");
	printf("-> Y for Yes, N for No, A for Always avoid pressing Y for all files.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

// Cr‚ation path complet
if (argument[strlen(argument)-1]!='\\') strcat(argument,"\\*.*");
else strcat(argument,"*.*");
FULLPATH(argument);
fnsplit(argument,drive,dir,name,ext);
// Path complet termin‚, argument=nom fichiers sources
// drive valide ?
if (DRIVE_STATUS(drive[0])==0) {
  printf("Drive is not valid.\n");
  exit(0);
  }
// dir existe et valide ?
strcpy(path,drive);
if (!DIREXIST(strcat(path,dir))) {
  printf("Directory or path not valid.\n");
  exit(0);
  }
// SAISIE=nouveau DTA
Set_DTA( (unsigned int) &Saisie );
// Lance recherche (r‚cursive) dans r‚pertoire de base
printf(  "Clearing *.$$$ files...");
scan_rep(drive,dir,name,".$??");
scan_rep(drive,dir,name,".??$");
printf("\rClearing *.tmp files...");
scan_rep(drive,dir,name,".tmp");
printf("\rClearing *.swp files...");
scan_rep(drive,dir,name,".swp");
//printf("\rNettoyage des fichiers ~*.*  en cours...");
//scan_rep(drive,dir,"~*",".*");
if (bak || all) {
  printf("\rClearing *.bak files...");
  scan_rep(drive,dir,name,".bak");
  }
if (old || all) {
  printf("\rClearing *.old files...");
  scan_rep(drive,dir,name,".old");
  }
if (syd || all) {
  printf("\rClearing *.syd files...");
  scan_rep(drive,dir,name,".syd");
  }
if (nul || all) {
  printf("\rClearing Null size files... ");
  scan_rep0(drive,dir,name,".*");
  }
// Fin de recherche
if (nbrefichiers==0) printf("\rNo file deleted.                         \n");
else {
  printf("\r-------------------------------------------------\n");
  printf("%i file(s) deleted: %10lu bytes freed. \n",nbrefichiers,taillefichiers);
  }
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
