//********************************************************************
// A better DIR function
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"D"
#define VERSION	"3.0"

#ifndef __SMALL__
#error Memory model must be: Small
#endif

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>

#include "macros.h"
#include "misc.h"
#include "hardware.h"


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
int nosys=-1,multicolonne=0,sub=0;
char s[80];
char c;
char argument[MAXPATH];
unsigned int nbrerepertoires=0;
unsigned int nbrefichiers=0;
unsigned long taillefichiers=0;
DIRSTRUCT Saisie;
struct dfree diskdispo;
int x;


void PrintData(DIRSTRUCT *Saisie)
//***********************************************************************
// Affiche ligne d'un fichier
// Entr‚e:Saisie = Ptr sur une structure Dir avec des informations                   de fichier
//***********************************************************************
{
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
fnsplit(Saisie->Name,drive,dir,name,ext);
// Passe outre si System et pas option /a
if ((Saisie->Attribut & 4) && nosys) return;
//Affiche nom ou . ou .. que ce soit r‚pertoire ou fichier
printf("%-8.8s ",(dir[0]=='.')?dir:name);
printf("%-3.3s ",(ext[0]=='.')?(ext+1):"    ");
if (Saisie->Attribut & 16) { //Repertoire
  printf("<DIR>");
  if (!multicolonne) printf("           ");
  ++nbrerepertoires;
  }
else {                       //Fichier
  printf(" ");
  printf((Saisie->Attribut & 32)?"A":"ú");
  printf((Saisie->Attribut & 1)?"R":"ú");
  printf((Saisie->Attribut & 2)?"H":"ú");
  if (!nosys) printf((Saisie->Attribut & 4)?"S":"ú");
  else printf(" ");
  if (!multicolonne) printf("%9lu  ",Saisie->Size);
  taillefichiers+=Saisie->Size;
  ++nbrefichiers;
  }
if (multicolonne) {
  switch (x) {
    case  1:x=21;printf("  ");break;
    case 21:x=41;printf("  ");break;
    case 41:x=61;printf("  ");break;
    case 61:x= 1;printf("\n");
    }
  }
else {
  printf("%02d/%02d/%02d  ",Saisie->Date & 31,((Saisie->Date >> 5) & 15),(Saisie->Date >> 9)+80);
  printf("%2d:%02d\n",Saisie->Time >> 11,(Saisie->Time >> 5) & 63 );
  }
}



BYTE findf(char *Chemin, BYTE Attribut)
//***********************************************************************
// FINDFIRST: Lire la premiŠre entr‚e de r‚pertoire
// Entr‚e : CHEMIN  =Ptr sur chemin de rech. avec masque fichier
//          ATTRIBUT=Attributs de recherche
// Sortie : TRUE, si une entr‚e a ‚t‚ trouv‚e sinon FALSE
// Infos  : L'entr‚e est lue dans le DTA
//***********************************************************************
{
union REGS   regs;
struct SREGS Segments;
segread(&Segments);      // Lire le contenu des registres de segment
regs.h.ah=0x4E;          // Num‚ro de fonction pour FindFirst
regs.x.cx=Attribut;              // Attributs recherch‚s
regs.x.dx=(unsigned int) Chemin; // Offset du chemin de rech.
intdosx(&regs,&regs,&Segments);  // Interruption DOS 21h
return(!regs.x.cflag); // Carry-Flag = 0: Un fichier trouv‚
}


BYTE findn(void)
//***********************************************************************
// FINDNEXT : Lire l'entr‚e de r‚pertoire suivante
// Entr‚e   : Aucune
// Sortie   : TRUE, si une entr‚e a ‚t‚ trouv‚e sinon FALSE
// Infos    : L'entr‚e est lue dans le DTA
//***********************************************************************
{
union REGS regs;
regs.h.ah = 0x4F;      // Num‚ro de fonction pour FindNext
intdos(&regs,&regs);   // Appeler l'interruption DOS 21h
return(!regs.x.cflag); // Carry=0: Un fichier trouv‚
}


void Set_DTA(unsigned int Offset)
//***********************************************************************
// SETDTA : Place le DTA sur une variable du segment de donn‚es
// Entr‚e : OFFSET = Offset du DTA dans le segment de donn‚es
// Sortie : Aucune
//***********************************************************************
{
union REGS   regs;
struct SREGS Segments;
segread(&Segments); // Lire le contenu des registres de segment
regs.h.ah = 0x1A;   // D‚finir le num‚ro de fonction pour le DTA
regs.x.dx = Offset; // Adresse d'offset dans le registre DX
intdosx(&regs, &regs, &Segments); // Interruption DOS 21h
}



void scan_rep(char drive2[MAXDRIVE],char dir2[MAXDIR],char name2[MAXFILE],char ext2[MAXEXT])
//***********************************************************************
//***********************************************************************
{
DIRSTRUCT saisie2;
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char chemin[MAXPATH];
// Recherche de sous r‚pertoires si option sub
if (sub) {
  strcpy(chemin,drive2);strcat(chemin,dir2);strcat(chemin,"*.*");
  if (findf(chemin,0x10)) {
    do {
      fnsplit(Saisie.Name,drive,dir,name,ext);
      if ((Saisie.Attribut & 0x10) && (dir[0]!='.')) { // Si r‚pertoire
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
  }
else printf("Directory %s%s\n\n",drive2,dir2);
x=1;
strcpy(chemin,drive2);strcat(chemin,dir2);
strcat(chemin,name2);strcat(chemin,ext2);
// Recherche fichier du r‚pertoire
if (findf(chemin,0x37)) {
  // Affiche nom des fichiers
  if (sub) printf("Directory %s%s\n",drive2,dir2);
  do PrintData(&Saisie);
  while (findn());
  if (x>>1) printf("\n");if (sub) printf("\n");
  }
}


int main(int argc,char *argv[])
//*******************************************************************
// RETURN: 0  Ok
//         1  Bad Argument(s)
//         2  Source file or drive is not valid
//*******************************************************************
{
char drive[MAXDRIVE];
char dir[MAXDIR];
char name[MAXFILE];
char ext[MAXEXT];
char path[MAXPATH];
int status;

// Exploite parametres
int noarg,help=((argc==1)?0:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'a': if (argv[noarg][2]=='s') nosys=0;
		else invalide=-1;
		break;
      case 'w': multicolonne=-1;break;
      case 's': sub=-1;break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else strcpy(argument,argv[noarg]);
  }

if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  [dir or files]  [/as]  [/w]  [/s]  [/?]            (* and ? allowed)\n",PROG);
	printf("\n");
	printf("D.EXE replaces the 'Dir' command of the DOS.  Faster, D is more complete and\n");
	printf("shows, on the other hand, files attributs, and details the number of directories");
	printf("and files listed, like do the 'Dir' in Windows95.\n");
	printf("\n");
	printf("Options are:     /as  Shows, as well, files with System Attribut.\n");
	printf("                 /w   Shows only names and attributs on 4 columns.\n");
	printf("                 /s   Shows contents of subdirectories as well.\n");
	printf("                 /?   Shows this help screen.\n");
	printf("Note: The options /aa /ah /ar of the Dir command are now useless.\n");
	printf("      The option  /as is however kept.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  [dir or files]  [/as]  [/w]  [/s]  [/?]            (* and ? allowed)\n",PROG);
	printf("Error:  Bad argument(s).\n");
	exit(1);
	}

// Cr‚ation path complet
c=argument[0];
FULLPATH(argument);
fnsplit(argument,drive,dir,name,ext);
// Si pas d'argument
// Si nom sans . et argument sans ? et argument sans *
if ((c==0) || ((ext[0]==0) && (strchr(argument,'?')==0) && (strchr(argument,'*')==0)))
  strcat(argument,(argument[strlen(argument)-1]!='\\')?"\\*.*":"*.*");
fnsplit(argument,drive,dir,name,ext);
// Path complet termin‚, argument=nom fichiers sources
// drive valide ?
if ((status=DRIVE_STATUS(drive[0]))==0) {
  printf("Drive is not valid.\n");
  exit(2);
  }
// dir existe et valide ?
strcpy(path,drive);
if (!DIREXIST(strcat(path,dir))) {
  printf("Directory or path is not valid.\n");
  exit(2);
  }
// SAISIE=nouveau DTA
Set_DTA( (unsigned int) &Saisie );
// Recherche nom volume
strcpy(path,drive);strcat(path,"\\*.*");
printf("\nVolume in drive %c ",drive[0]);
if (findf(path,0x08)) {
  memcpy(path,Saisie.Name,sizeof(Saisie.Name));
  path[8]=0;path[12]=0;
  printf("is %s%s",path,path+9);
  }
else printf("has no name.");
switch (status) {
  case 2:printf(" (Subst volume)\n");break;
  case 3:printf(" (CDROM or Network volume)\n");break;
  default: printf("\n");
  }
if (sub) printf("\n");
// Lance recherche (r‚cursive) dans r‚pertoire de base
scan_rep(drive,dir,name,ext);
// Fin de recherche
if (nbrerepertoires || nbrefichiers) {
  if (multicolonne) printf("-----------------------------------");
  printf("--------------------------------------------\n");
  sprintf(s,"%i directories, %i file(s)",nbrerepertoires,nbrefichiers);
  printf(s);
  for (x=0;x++<(28-strlen(s));printf(" "));
  printf("%10lu bytes\n",taillefichiers);
  }
else printf("No matched file or directory.\n");
// Recherche espace libre
getdfree(drive[0]-64,&diskdispo);
printf("Free                      %12lu bytes\n",
    (unsigned long) diskdispo.df_avail * (unsigned long) diskdispo.df_bsec * (unsigned long) diskdispo.df_sclus);
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
