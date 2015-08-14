//********************************************************************
// Boost your floppy drive.
// Using a new definition of the DDPT.
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"TurboDisk"
#define VERSION	"3.0"

#ifndef __SMALL__
#error Memory model must be: Small
#endif
#include <conio.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <dos.h>

#include "macros.h"


/* Types */
typedef unsigned char DDPT_Typ[11];

/* Variables */
DDPT_Typ far *DDPT;
int valeurs_par_defaut;
int rotation_avant;
int rotation_apres;
int montee_tete;
int descente_tete;
int passage_piste;
int stabilisation;
int demande_valeur;
int nouvelle_valeur;
char option_v[7];
char option_p[7];
char option_m[7];
char option_d[7];
char option_i[7];
char option_s[7];
char a[10];



void far *GetIntVec(int Numero)
//*********************************************************************
// GetIntVec lit un vecteur d'interruption.
// Entr‚e: Num‚ro d'interruption
// Sortie: Vecteur d'interruption=ptr type far
//*********************************************************************
{
return(*(void far * far *) (MK_FP(0,Numero<<2)));
}


int RAM_DDPT(void)
//*********************************************************************
// Teste si DDPT se trouve dans la RAM ou la ROM.
// La fonction inscrit une valeur dans la DDPT, la relit puis compare
// si la valeur a ‚t‚ inscrite, la DDPT se trouve donc dans la RAM.
// Sortie: Renvoie 0=false si DDPT dans la ROM.
//*********************************************************************
{
unsigned char c;
int i;
c=(*DDPT)[0];
(*DDPT)[0]=(c^0xFF);
i=((*DDPT)[0]==(c^0xFF));
*DDPT[0]=c;   // Restaurer l'ancienne valeur
return(i);
}



int main(int argc,char *argv[])
/*********************************************************************/
/* RETURN:  0  Ok                                                    */
/*          1  Bad argument(s).e                                     */
/*          2  DDPT en ROM                                           */
/*********************************************************************/
{

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case '0':
	valeurs_par_defaut=-1;
	strcpy(option_v,"/v1000");strcpy(option_p,"/p2035");
	strcpy(option_m,"/m240"); strcpy(option_d,"/d2");
	strcpy(option_i,"/a3");   strcpy(option_s,"/s15");
	break;
      case '1':
	demande_valeur=-1;
	strcpy(option_v,"/v625");strcpy(option_p,"/p660");
	strcpy(option_m,"/m192");strcpy(option_d,"/d2");
	strcpy(option_i,"/a3");  strcpy(option_s,"/s15");
	break;
      case 'v':memcpy(option_v,strlwr(argv[noarg]),7);option_v[6]=0;if (option_v[2]==0) demande_valeur=-1;
	break;
      case 'p':memcpy(option_p,strlwr(argv[noarg]),7);option_p[6]=0;if (option_p[2]==0) demande_valeur=-1;
	break;
      case 'm':memcpy(option_m,strlwr(argv[noarg]),7);option_m[6]=0;if (option_m[2]==0) demande_valeur=-1;
	break;
      case 'd':memcpy(option_d,strlwr(argv[noarg]),7);option_d[6]=0;if (option_d[2]==0) demande_valeur=-1;
	break;
      case 'a':memcpy(option_i,strlwr(argv[noarg]),7);option_i[6]=0;if (option_i[2]==0) demande_valeur=-1;
	break;
      case 's':memcpy(option_s,strlwr(argv[noarg]),7);option_s[6]=0;if (option_s[2]==0) demande_valeur=-1;
	break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else invalide=-1;
  }

/* Affiche en-tˆte */
if (help) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage: TurboDsk /1 or /0 or /v[?] or /p[?] or /m[?] or /d[?] or /a[?] or /s[?]\n");
  printf("\n");
  printf("TurboDisk allow you to modify the default parameters (not optimized) used to\n");
  printf("access your floppy disk, like that, you benefit by all capabilities of recent\n");
  printf("3\"1/2 drives (drives on 486 or better).");
  printf("\n");
  printf("Here are the default values of the 6 parameters you can boost (v,p,m,d,a et s):\n");
  printf("Rotation before disk access /v:1000 ms   Rotation after disk access  /p: 2035 ms");
  printf("Time to upper head          /m: 240 ms   Time to lower head          /d:    2 ms");
  printf("Time to change tracks       /a:   3 ms   Time to stabilize head      /s:   15 ms");
  printf("\n");
  printf("Type  TURBODSK /1   TurboDisk boosts your drive with advised values.\n");
  printf("                    LAUNCH \"TurboDsk /1\" FROM YOUR AUTOEXEC.BAT for exemple.\n\r");
  printf("               /0   Restores all old DOS default values.\n");
  printf("               /v   (/p,/m,/d,/a or /s), TurboDisk ask you the new value for the");
  printf("                    parameter v (or p,m,d,a,s).\n");
  printf("               /v?  (/p?,/m?,/d?,/a? ou /s?), TurboDisk change the value of the\n");
  printf("                    parameter v (or p,m,d,a,s) with the ? value.\n");
  printf("               /?   To show this help screen.\n");
  printf("               /i   Informations about sources and other UTILKIT utilities.\n");
  exit(0);
  }
if (invalide) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage: TurboDsk /1 or /0 or /v[?] or /p[?] or /m[?] or /d[?] or /a[?] or /s[?]\n");
  printf("Error: Bad argument(s)\n");
  exit(1);
  }
// Lecture et affichage DDP si demande de nouvelles valeurs
DDPT=GetIntVec(0x1E); // Lit le pointeur sur la DDPT
if (RAM_DDPT()==0) {  // DDPT se trouve dans la ROM, impossible de modifier
  printf("Error:  Enable to modify the DDPT (Disk-Drive-Parameter-Table) with TurboDisk\n");
  printf("because it's in ROM (and not in RAM).  TurboDisk is useless on this hardware.\n");
  exit(2);
  }
if (demande_valeur) {
  rotation_avant=125*(*DDPT)[10];     // 125-1000
  rotation_apres=55*(*DDPT)[2];       // 55-2035
  montee_tete=16*((*DDPT)[0] & 0x0F); // 16-240
  descente_tete=2*((*DDPT)[1]>>1);    // 2-10
  passage_piste=16-((*DDPT)[0]>>4);   // 1-15
  stabilisation=(*DDPT)[9];           // (1)5-15
  printf("Rotation before disk access /v:%4d ms   Rotation after disk access  /p: %4d ms",rotation_avant,rotation_apres);
  printf("Time to upper head          /m:%4d ms   Time to lower head          /d: %4d ms",montee_tete,descente_tete);
  printf("Time to change tracks       /a:%4d ms   Time to stabilize head      /s: %4d ms",passage_piste,stabilisation);
  printf("\n");
  }
if (option_v[0]) {
  if (strlen(option_v)>2) {
    if ((atoi(option_v+2)<125)||(atoi(option_v+2)>1000))
      printf("ParamŠtre /v non valide. Il doit ˆtre choisi entre 125ms et 1000ms.\n\n");
    else (*DDPT)[10]=(atoi(option_v+2)/125);
    }
  else {
    printf("->CHANGEMENT PARAMETRE /v:  (Valeurs admises entre 125 et 1000)\n");
    printf("Une nouvelle dur‚e de 'Rotation du moteur aVant' permet de commencer … lire ou …");
    printf("‚crire sur le lecteur plus t“t aprŠs sa mise en rotation.  Ce temps sert donc au");
    printf("disque pour atteindre sa vitesse de croisiŠre.  La valeur par d‚faut est 1000ms,");
    printf("mais peut ˆtre facilement diminu‚e de moiti‚ (Conseill‚: 500).");
    do {
      printf("\nEntrez la nouvelle dur‚e rotation moteur avant : ");
      a[0]=5;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<125)||(atoi(a)>1000));
    if (atoi(a)) (*DDPT)[10]=(atoi(a)/125);
    printf("\n\n");
    }
  }
if (option_p[0]) {
  if (strlen(option_p)>2) {
    if ((atoi(option_p+2)<55)||(atoi(option_p+2)>2035))
      printf("ParamŠtre /p non valide. Il doit ˆtre choisi entre 55ms et 2035ms.\n\n");
    else (*DDPT)[2]=(atoi(option_p+2)/55);
    }
  else {
    printf("->CHANGEMENT PARAMETRE /p:  (Valeurs admises entre 55 et 2035)\n");
    printf("Une nouvelle dur‚e de 'Rotation du moteur aPrŠs'  lecture ou ‚criture  permet de");
    printf("ne pas devoir attendre que  le lecteur ait atteint sa vitesse de croisiŠre  lors");
    printf("d'un accŠs suivant imm‚diatement l'accŠs pr‚c‚dent (Le disque continue … tourner");
    printf("en pr‚vision d'un autre accŠs imm‚diatement cons‚cutif). Compte tenu du mat‚riel");
    printf("d'aujourd'hui, la valeur de ce paramŠtre est  un gaspillage monstrueux  de votre");
    printf("temps. Gardez cependant une valeur sup‚rieur … 300ms, la valeur par d‚faut ‚tant");
    printf("de 2035ms (Conseill‚: 660).");
    do {
      printf("\nEntrez la nouvelle dur‚e rotation moteur aprŠs : ");
      a[0]=5;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<55)||(atoi(a)>2035));
    if (atoi(a)) (*DDPT)[2]=(atoi(a)/55);
    printf("\n\n");
    }
  }
if (option_m[0]) {
  if (strlen(option_m)>2) {
    if ((atoi(option_m+2)<16)||(atoi(option_m+2)>240))
      printf("ParamŠtre /m non valide. Il doit ˆtre choisi entre 16ms et 240ms.\n\n");
    else (*DDPT)[0]=((((*DDPT)[0])&0xF0)|(atoi(option_m+2)/16));
    }
  else {
    printf("->CHANGEMENT PARAMETRE /m:  (Valeurs admises entre 16 et 240)\n");
    printf("Indique le temps  que met la tˆte de lecture  pour  'reMonter'  aprŠs lecture ou");
    printf("‚criture.  La valeur par d‚faut de 240ms laisse une marge qui permet de diminuer");
    printf("raisonnablement ce temps (Conseill‚: 176).");
    do {
      printf("\nEntrez la nouvelle dur‚e de mont‚e de la tˆte : ");
      a[0]=4;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<16)||(atoi(a)>240));
    if (atoi(a)) (*DDPT)[0]=((((*DDPT)[0])&0xF0)|(atoi(a)/16));
    printf("\n\n");
    }
  }
if (option_d[0]) {
  if (strlen(option_d)>2) {
    if ((atoi(option_d+2)<2)||(atoi(option_d+2)>10))
      printf("ParamŠtre /d non valide. Il doit ˆtre choisi entre 2ms et 10ms.\n\n");
    else (*DDPT)[1]=((((*DDPT)[1])&0x1)|((atoi(option_d+2)/2)<<1));
    }
  else {
    printf("->CHANGEMENT PARAMETRE /d:  (Valeurs admises entre 2 et 10)\n");
    printf("Indique le temps  que met la tˆte de lecture  pour  'Descendre'  afin de lire ou");
    printf("‚crire.  La valeur par d‚faut de 2ms  (ou 4ms selon les BIOS) est d‚j… minimale.");
    printf("Vous ne pouvez qu'augmenter ce paramŠtre,  ce qui ralentirait inutillement votre");
    printf("lecteur (Conseill‚: 2). ");
    do {
      printf("\nEntrez la nouvelle dur‚e de descente de la tˆte : ");
      a[0]=3;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<2)||(atoi(a)>10));
    if (atoi(a)) (*DDPT)[1]=((((*DDPT)[1])&0x1)|((atoi(a)/2)<<1));
    printf("\n\n");
    }
  }
if (option_i[0]) {
  if (strlen(option_i)>2) {
    if ((atoi(option_i+2)<1)||(atoi(option_i+2)>15))
      printf("ParamŠtre /a non valide: Il doit ˆtre choisi entre 1ms et 15ms.\n\n");
    else (*DDPT)[0]=((((*DDPT)[0])&0x0F)|((16-atoi(option_i+2))<<4));
    }
  else {
    printf("->CHANGEMENT PARAMETRE /a:  (Valeurs admises entre 1 et 15)\n");
    printf("Cette option  correspond  au temps que met  la tˆte de lecture  pour se d‚placer");
    printf("d'une 'pIste … une autre'. La valeur par d‚faut est 3ms, ce qui est raisonnable,");
    printf("une diminution de ce paramŠtre n'apporte rien d'int‚ressant (Conseill‚: 3).");
    do {
      printf("\nEntrez la nouvelle dur‚e de passage de piste … piste : ");
      a[0]=3;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<1)||(atoi(a)>15));
    if (atoi(a)) (*DDPT)[0]=((((*DDPT)[0])&0x0F)|((16-atoi(a))<<4));
    printf("\n\n");
    }
  }
if (option_s[0]) {
  if (strlen(option_s)>2) {
    if ((atoi(option_s+2)<5)||(atoi(option_s+2)>15))
      printf("ParamŠtre /s non valide. Il doit ˆtre choisi entre 5ms et 15ms.\n\n");
    else (*DDPT)[9]=atoi(option_s+2);
    }
  else {
    printf("->CHANGEMENT PARAMETRE /s:  (Valeurs admises entre 5 et 15)\n");
    printf("La 'Stabilisation' est le temps  que passe le lecteur … attendre  que sa tˆte ne");
    printf("vibre plus, aprŠs un passage  d'une piste vers une autre.   La valeur par d‚faut");
    printf("de 15ms est raisonnable, laissez la telle qu'elle (Conseill‚ 15).");
    do {
      printf("\nEntrez la nouvelle dur‚e de stabilisation de la tˆte : ");
      a[0]=3;strcpy(a,cgets(a));
      if (!atoi(a)) break;
      }
      while ((atoi(a)<5)||(atoi(a)>15));
    if (atoi(a)) (*DDPT)[9]=atoi(a);
    printf("\n\n");
    }
  }
// Lecture et affichage DDP finale
rotation_avant=125*((*DDPT)[10]);     // 125-1000
rotation_apres=55*((*DDPT)[2]);       // 55-2035
montee_tete=(((*DDPT)[0] & 0x0F)<<4); // 16-240
descente_tete=(((*DDPT)[1]>>1)<<1);   // 2-10
passage_piste=16-((*DDPT)[0]>>4);     // 1-15
stabilisation=(*DDPT)[9];             // (1)5-15
if (demande_valeur) printf("                              NEW VALUES OF THE DDPT:\n");
printf("Rotation before disk access /v:%4d ms   Rotation after disk access  /p: %4d ms",rotation_avant,rotation_apres);
printf("Time to upper head          /m:%4d ms   Time to lower head          /d: %4d ms",montee_tete,descente_tete);
printf("Time to change tracks       /a:%4d ms   Time to stabilize head      /s: %4d ms",passage_piste,stabilisation);
printf("\n");
if (valeurs_par_defaut)
  printf("DOS default values of floppy disk access times are restored.\n");
return(0);
}
