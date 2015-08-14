//********************************************************************
// Show a lot of disk system informations
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"DiskInfo"
#define VERSION	"3.0"

#ifndef __SMALL__
#error Memory model must be: Small
#endif
#include <ctype.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include <bios.h>
#include <dos.h>

#include "misc.h"
#include "ansi.h"
#include "hardware.h"
#include "macros.h"

//#define DEBUG
#define bl textcolor(15)
#define gr textcolor(7)

// Variables
int i,j,k,passage=0,nosys=-1,multicolonne=0,sub=0,m=0,b=0,f=0,r=0,se=0;
BOOL bo;
BYTE head=0,secteur=1; // Nbre de secteur appelable = 1 … 64 (6 bits)
WORD piste_cyl=0;      // Nbre cylindre max = 1024 (10 bits)
BYTE head1,secteur1,head2,secteur2;
WORD piste_cyl1,piste_cyl2;
BYTE descripteur=0,nbre_disque=0,nbre_tete=0,nbre_secteur=0,nbre_fat=0;
WORD nbre_piste_cyl=0;
DWORD nbre_cluster=0;
WORD taille_cluster=0,taille_fat=0,taille_racine=0,type_fat=12;
unsigned long taille_total=0;
WORD w;
char c;
int resboot,resbootsector,resfat,res;
char argument[512],s[512];
int drv_master=3; /* Disque avec Master boot */
int drv_actif=3;  /* Disque avec Secteur boot actif */
int drv;
char drvlet;

typedef struct {
    BYTE etat_activation;
    BYTE tete_debut;
    WORD seccyl_debut;
    BYTE type;
    BYTE tete_fin;
    WORD seccyl_fin;
    DWORD distance;
    DWORD taille;} entree_partition;
typedef struct {
    BYTE code[446];
    entree_partition entree[4];
    WORD identification;} SecteurMasterBoot;
typedef struct {
    BYTE junk1[3];
    char sysid[8];
    WORD sectsize;
    BYTE clustsize;
    WORD resvsects;
    BYTE FATcopies;
    WORD rootdirentries;
    WORD totalsects;
    BYTE idbyte;
    WORD FATsects;
    WORD trksects;
    WORD heads;
    WORD resvspecial;} SecteurBoot;
struct direntry {
    char fname[8];
    char ext[3];
    BYTE attrib;
    BYTE resvd[10];
    WORD xtime;
    WORD xdate;
    WORD startFAT;
    long fsize; };
char *type_partition[15] = {"Not used","DOS 12","XENIX","XENIX","DOS 16","DOS (ext.)","DOS (Prin.)","DOS special","Other"};
char *system_exp[3] = {"MSDOS","IBM DOS","Unknown"};
BYTE masterbootrec[512],bootrec[512];
BYTE fat_buffer[512],fat_buffer2[512],buf[512];
struct direntry directory[16]; // 16 Entr‚e de 32 octets par secteurs
union REGS rreg,sreg;
struct SREGS segs;



int pause(void) {
printf("\n\n");
printf("Press a key to get the next system area of the disk...");
WaitKey();
return(0);
}

int ReadSector (int drive, int cyl, int head, int sec, void far* buf) {
  /* read a 512 byte sector from phys location on disk */
  /* return TRUE if success */
  union REGS reg;
  struct SREGS sreg;
  int retry = 3;;
  do {
    reg.x.ax = 0x0201;
    reg.x.bx = FP_OFF(buf);
    sreg.es = FP_SEG(buf);
    reg.h.ch = cyl & 0xFF;
    /* top two bits (8 & 9) of cyl # hidden in bits 6 & 7 of sector */
    reg.h.cl = sec | ((cyl >> 2) & 0xC0);
    reg.h.dh = head;
    reg.h.dl = drive;
    int86x(0x13,&reg,&reg,&sreg);
    } while ((reg.x.cflag) && (retry-- > 0));
  return(reg.x.cflag == 0);
  }   /* ReadSector */



int diskread(int drive,int head,int dossectr,int PisCyl,int nsectrs,char buffer[])
/********************************************************/
/* Utilise interruption BIOS No 0x13
/********************************************************/
/* Drive   : 1  A
/*           2  B etc..
/* Head    : 0  1ere tˆte
/* Dossectr: 1  1er secteur
/* PisCyl  : 0  1ere piste/cylindre
/* nsectrs : Nombre de secteurs
/********************************************************/
{
union REGS rreg,sreg;
struct SREGS segregs;
int i;
int retry=3;
unsigned retval;
for (i=0; i < 512 * nsectrs; i++) buffer[i] = 0;
do {
  sreg.h.ah= 0x02;
  sreg.h.ch= PisCyl; /* Cylindre 0 = 1er cylindre */
		     /* Piste 0    = 1ere piste   */
  sreg.h.cl= dossectr; /* Secteur */
  sreg.h.dh= head;   /* Master boot = tete 0, secteur boot = tete 1 */
		     /* secteur boot = tete 0 si disquette          */
  if ((drive==1) || (drive==2))  /* Drive A=0, B=1, C=0x80, D=0x81 */
    sreg.h.dl = drive-1;
  else
    sreg.h.dl = 0x7D+drive;
  sreg.h.al = nsectrs;
  sreg.x.bx = FP_OFF(buffer);
  segregs.es = FP_SEG(buffer);
  retval=int86x(0x13,&sreg,&rreg,&segregs);
  }
while ((rreg.x.cflag) && (retry-- > 0));
return(!(retval));
}



WORD getFATentry(int clus,BYTE *fat_buffer)
/*********************************************************/
/* Retourne la valeur de l'entr‚e no clus dans la FAT    */
/* Retour: 0x(0)000 cluster libre                        */
/*         0x(F)FF0 … 0x(F)FF6 cluster r‚serv‚           */
/*         0x(F)FF8 … 0x(F)FFF dernier cluster           */
/*         sinon prochain cluster du fichier             */
/*********************************************************/
{
int index;
WORD p,q;
if (type_fat==16) index=(clus<<1); // Si FAT 16 bits
else index=((clus*3)>>1);            // Si FAT 12 bits
p = * ((WORD *) & fat_buffer[index]);
if (type_fat==12) q=(clus%2)?(p >> 4):(p & 0x0FFF);
else  q=p;
return(q);
}



int setFATentry(int clus,BYTE *fat_buffer,BYTE val)
/*****************************************************************/
/*****************************************************************/
{
int index;
WORD *p;
if (type_fat==16) index=(clus<<1); // Si FAT 16 bits
else index=((clus*3)>>1);            // Si FAT 12 bits
/* Primary copy of FAT */
p = (WORD *) & fat_buffer[index];
*p = (clus%2)? (*p & 0xF) | (val << 4) : (*p & 0xF000) | (val & 0xFFF);
/* Secondary copy of FAT */
index = clus*3/2 + 512*2;
p = (WORD *) &fat_buffer[index];
*p = (clus%2)? (*p & 0xF) | (val << 4) : (*p & 0xF000) | (val & 0xFFF);
return(0);
}


int str_scan(char *start,int len,char * str)
{
int found=0,i=0;
char * p=start;
while (!found) {
  while (( *p != str[ 0 ]) && ( p < (start + len ))) p++;
  if (p==(start+len)) return(FALSE);
  while (( *(++p) == str[ ++i ]) && ( i < strlen( str ))) {}
  if ( i == strlen( str )) return(TRUE);
  i=0;
  }
return(FALSE);
}


int findlabel(void)
{
int i;
for (i=0; i<taille_racine; i++) {
  if (!directory[i].fname[0]) break;
  }
return(FALSE);
}


int displayraw(BYTE buffer[],int nsectrs)
/*****************************************************************/
/* Affiche contenu d'un buffer                                   */
/*****************************************************************/
{
int p,i;
char ascstr[80],ch;
for (i=0; i<(512*nsectrs); i++) {
  if (!(i%16)) {
    if (i) printf("|%s|",ascstr);
    printf("\r\n%3X: ",i);
    ascstr[p=0]='\0';
    }
  printf("%02X ",buffer[i]);
  ch=(buffer[i]>=' ' && buffer[i]<='~') ? buffer[i] : '.';
  ascstr[p++]=ch;
  ascstr[p]=0x0;
  }
printf("|%s|",ascstr);
printf("\r\n\r\n");
return(0);
}



int check_master_boot_rec(SecteurMasterBoot *masterbootrec)
/*********************************************************/
/* V‚rifie si la zone bootrec est un master boot         */
/* Retour:  0  Non master boot                           */
/*         -1  Master boot                               */
/*********************************************************/
{
if (masterbootrec->identification==0xAA55) return(-1);
return(0);
}


int check_boot_rec(BYTE *bootrec)
/*********************************************************/
/* V‚rifie si la zone bootrec est un secteur boot        */
/* Retour:  0  Non secteur boot                          */
/*          1  Secteur boot MSDOS                        */
/*          2  Secteur boot IBM                          */
/*          3  Secteur boot Autre                        */
/*********************************************************/
{
if (( bootrec[0] != 0xE9) && (( bootrec[0] != 0xEB) || (bootrec[2] != 0x90))) return(0);
/* Search string */
if (str_scan((char *) bootrec,512,"IBMBIO  COMIBMDOS  COM")) return(2);
if (str_scan((char *) bootrec,512,"IO      SYSMSDOS   SYS")) return(1);
return(3);
}


int check_fat_rec(BYTE *fat_buffer)
{
WORD f1,f2;
f1=getFATentry(0,fat_buffer);
f2=getFATentry(1,fat_buffer);
//f3=getFATentry(2,fat_buffer);
if (type_fat==12) {
  if (f1!=0xF8F && f2!=0xFFF) return(0);
  }
else {
  if (f1!=0xFFF8 && f2!=0xFFFF) return(0);
  }
return (-1);
}


int AfficheSecteurMasterBoot(SecteurMasterBoot *pointeur)
/**********************************************************************/
/* Affiche info Secteur boot
/**********************************************************************/
{
int i,j;
printf(" 00h - 1BDh: Start code\r\n");
for (i=0;i<4;i++) {
  if ((j=pointeur->entree[i].type)==0xDB) j=0x07;
  if (j) {
    printf("%3Xh - %3Xh: Partition %i info : Partition %-13s     = %Xh\r\n",0x1BE+(i<<4),0x1BE+(i<<4),i+1,(pointeur->entree[i].etat_activation==0x80?"ACTIVE (Boot)":"NOT ACTIVE"),pointeur->entree[i].etat_activation);
    printf("%3Xh - %3Xh:                  : Start head                  = %d\r\n",0x1BF+(i<<4),0x1BF+(i<<4),pointeur->entree[i].tete_debut);
    printf("%3Xh -     :                  : Start sector                = %d\r\n",0x1C0+(i<<4),pointeur->entree[i].seccyl_debut & 0x003F);
    printf("     - %3Xh:                  : Start cylinder              = %d\r\n",0x1C1+(i<<4),(pointeur->entree[i].seccyl_debut>>8) | ((pointeur->entree[i].seccyl_debut<<2) & 0x0300));
    printf("%3Xh - %3Xh:                  : Partition type: %-11s = %d\r\n",0x1C2+(i<<4),0x1C2+(i<<4),type_partition[j],pointeur->entree[i].type);
    printf("%3Xh - %3Xh:                  : End head                    = %d\r\n",0x1C3+(i<<4),0x1C3+(i<<4),pointeur->entree[i].tete_fin);
    printf("%3Xh -     :                  : End sector                  = %d\r\n",0x1C4+(i<<4),pointeur->entree[i].seccyl_fin & 0x003F);
    printf("     - %3Xh:                  : End cylinder                = %d\r\n",0x1C5+(i<<4),(pointeur->entree[i].seccyl_fin>>8) | ((pointeur->entree[i].seccyl_fin<<2) & 0x0300));
    printf("%3Xh - %3Xh:                  : Distance to first sector    = %ld sectors\r\n",0x1C6+(i<<4),0x1C9+(i<<4),pointeur->entree[i].distance);
    printf("%3Xh - 1CDh:                  : Size                        = %ld sectors\r\n",0x1CA+(i<<4),pointeur->entree[i].taille);
    }
  else {
    printf("%3Xh - %3Xh: Partition %i info : Not used\r\n",0x1BE+(i<<4),0x1CD+(i<<4),i+1);
    }
  }
printf("1FEh - 1FFh: Master Boot identification (AA55h)             = %Xh\r\n",pointeur->identification);
return(-1);
}


int AfficheSecteurBoot(SecteurBoot *pointeur)
/**********************************************************************/
/* Affiche info Secteur boot
/**********************************************************************/
{
/* check JMP instruction */
if (( pointeur->junk1[0] == 0xe9) || (( pointeur->junk1[0] == 0xeb) && (pointeur->junk1[2] == 0x90)))
  printf(" 00h -  02h: JMP instruction                                = %X %X %X\r\n", pointeur->junk1[0],pointeur->junk1[1],pointeur->junk1[2]);
else
  printf(" 00h -  02h: JMP instruction                                = %X %X %X - Error\r\n", pointeur->junk1[0],pointeur->junk1[1], pointeur->junk1[2]);
/* check OEM info */
printf(" 03h -  0Ah: Manufacturer info                              = %s\r\n", pointeur->sysid);
/* check  sector size ... has to be greater than 128 */
if ( pointeur->sectsize < 128)
  printf(" 0Bh -  0Ch: Sector size                                    = %d bytes - Error\r\n",pointeur->sectsize);
else
  printf(" 0Bh -  0Ch: Sector size                                    = %d bytes\r\n",pointeur->sectsize );
/* check cluster size ... for floppy 0 < x < 3 */
if (pointeur->clustsize == 0)
  printf(" 0Dh -  0Dh: Cluster size                                   = %d sectors - Error\r\n",pointeur->clustsize );
else
  printf(" 0Dh -  0Dh: Cluster size                                   = %d sectors\r\n",pointeur->clustsize );
/* check number of reserved sectors */
printf(" 0Eh -  0Fh: Number of sectors for boot (include this one)  = %d\r\n", pointeur->resvsects);
/* check number of FATs */
if (( pointeur->FATcopies == 0) || ( pointeur->FATcopies > 4))
  printf(" 10h -  10h: Number of FATs                                 = %d - Error\r\n", pointeur->FATcopies);
else
  printf(" 10h -  10h: Number of FATs                                 = %d\r\n", pointeur->FATcopies);
/* check rootdir entries */
if (pointeur->rootdirentries < 32 )
  printf(" 11h -  12h: Number of root entries                         = %d - Error\r\n",pointeur->rootdirentries);
else
  printf(" 11h -  12h: Number of root entries                         = %d\r\n",pointeur->rootdirentries);
/* check number of sectors in the volume */
printf(" 13h -  14h: Number of sectors (if <=65535, else 0)         = %d\r\n", pointeur->totalsects);
/* check media descripter BYTE */
if ( pointeur->idbyte<0xF0 )
  printf(" 15h -  15h: Media descriptor                               = %XH - Error\r\n",pointeur->idbyte );
else
  printf(" 15h -  15h: Media descriptor                               = %XH\r\n",pointeur->idbyte );
printf(" 16h -  17h: FAT size                                       = %d sectors\r\n", pointeur->FATsects);
printf(" 18h -  19h: Track/Cylinder size for one side (head)        = %d sectors\r\n", pointeur->trksects);
printf(" 1Ah -  1Bh: Number of heads                                = %d\r\n", pointeur->heads);
printf(" 1Ch -  1Dh: Distance to 1st sector                         = %d\r\n", pointeur->totalsects);
printf(" 1Eh - %3Xh: Boot code\r\n",pointeur->resvsects*pointeur->sectsize-1);
return(-1);
}


int AfficheFat(BYTE *pointeur)
/**********************************************************************/
/* Affiche info Secteur boot
/**********************************************************************/
{
printf(" 00h -  xxh: FAT Entry 0            : Id %1s+Media           = %Xh\r\n",(type_fat==16?"FF":"F "),getFATentry(0,pointeur));
printf("             FAT Entry 1            : Id %4s               = %Xh\r\n",(type_fat==16?"FFFF":"FFF "),getFATentry(1,pointeur));
printf("             FAT Entry 2 (cluster 0): Next entry            = ");
if ((type_fat==16) && (getFATentry(2,pointeur)>0xFFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else if ((type_fat==12) && (getFATentry(2,pointeur)>0xFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else printf("%u\r\n",getFATentry(2,pointeur));
printf("             FAT entry 3 (cluster 1): Next entry            = ");
if ((type_fat==16) && (getFATentry(3,pointeur)>0xFFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else if ((type_fat==12) && (getFATentry(3,pointeur)>0xFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else printf("%u\r\n",getFATentry(3,pointeur));
printf("             FAT entry 4 (cluster 2): Next entry            = ");
if ((type_fat==16) && (getFATentry(4,pointeur)>0xFFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else if ((type_fat==12) && (getFATentry(4,pointeur)>0xFF8)) printf("%4Xh-Chain end\r\n",getFATentry(2,pointeur));
else printf("%u\r\n",getFATentry(4,pointeur));
printf("             etc...\r\n");
return(-1);
}


int AfficheDirectory(struct direntry *pointeur)
/**********************************************************************/
/* Affiche info Secteur boot
/**********************************************************************/
{
char s[12],s1[9],s2[4];
memcpy(s1,pointeur->fname,8);s1[8]=0x0;
memcpy(s2,pointeur->ext,3);s2[3]=0x0;
switch (pointeur->fname[0]) {
  case 0xE5:strcpy(s,"(deleted)");break;
  case 0x2E:
    if (pointeur->fname[1]==0x2E) strcpy(s,"(parent dir)");
    else strcpy(s,"(current dir)");
    break;
  default: strcpy(s,"");break;
  }
printf(" 00h -  0Ah: Root entry 1 : name+extension %12s     = %8s%3s\r\n",s,s1,s2);
printf(" 0Bh -  0Bh:                attribut                        = %02Xh\r\n",pointeur->attrib);
printf(" 0Ch -  15h:                reserved\r\n");
printf(" 16h -  17h:                hour                            = %-5u = %02i:%02i:%02i\r\n",pointeur->xtime,pointeur->xtime>>12,(pointeur->xtime>>6)&0x3F,(pointeur->xtime&0x1F)<<1);
printf(" 18h -  19h:                date                            = %-5u = %02i/%02i/%02i\r\n",pointeur->xdate,pointeur->xdate&0x1F,(pointeur->xdate>>5)&0x0F,(pointeur->xdate>>9)+80);
printf(" 1Ah -  1Bh:                entry of head cluster           = entry %u\r\n",pointeur->startFAT);
printf(" 1Ch -  1Fh:                file size                       = %lu\r\n",pointeur->fsize);
printf("then the root entry 2 with the same format, then entry 3, etc...\r\n");
return(-1);
}



int AfficheSecteur(BYTE buffer[],int nsectrs)
/*****************************************************************/
/* Affiche contenu d'un buffer                                   */
/*****************************************************************/
{
int p,i;
char ascstr[80],ch;
for (i=0; i<(256*nsectrs); i++) {
  if (!(i%16)) {
    if (i) printf("|%s|",ascstr);
    printf("\r\n%3X: ",i);
    ascstr[p=0]='\0';
    }
  printf("%02X ",buffer[i]);
  ch=(buffer[i]>=' ' && buffer[i]<='~') ? buffer[i] : '.';
  ascstr[p++]=ch;
  ascstr[p]=0x0;
  }
printf("|%s|",ascstr);
printf("\r\netc...\r\n");
return(0);
}


void ecran(void) {
clrscr();
printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
printf("\n");
}


int main(int argc,char *argv[])
/*********************************************************************/
/* RETURN:  0  Ok                                                    */
/*********************************************************************/
{
// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'm': m=-1;break;
      case 'b': b=-1;break;
      case 'f': f=-1;break;
      case 'r': r=-1;break;
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

if (help) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  <drive:>   [/m] [/b] [/f] [/r] \n",PROG);
  printf("\n");
  printf("DISKINFO allow you to get informations about system sectors of a drive and their");
  printf("contents.\r\n");
  printf("\n");
  printf("Options are   /m    show only the Master Boot informations (Partitions table).\n");
  printf("              /b    show only the Boot sector informations.\n");
  printf("              /f    show only the FAT sector(s).\n");
  printf("              /r    show only the Root sector(s).\n");
  exit(0);
  }
if (invalide || (isalpha(argument[0])==0)) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  <drive:>   [/m] [/b] [/f] [/r] \n",PROG);
  printf("Error:  Bad argument(s).\n");
  exit(1);
  }

/* Si lecteur incorrect */
drvlet=argument[0];
drv=toupper(drvlet)-'A'+1; /* A: drv=1, B: drv=2, etc... */
switch (i=DRIVE_STATUS(drvlet)) {
  case 0:
    printf("Error: Not a physical disk.\r\n");
    exit(2);
  case 2:
    printf("Error: Not a physical disk (This drive may be a virtual drive).\r\n");
    exit(2);
  case 3:
    printf("Error: Not a valid physical disk (This drive may be a CDROM or a network disk).\r\n");
    exit(2);
  }
debut:





// D‚termine paramŠtres logiques du disque drv
sreg.h.ah=0x1C;
sreg.h.dl=drv;
intdos(&sreg,&sreg);
taille_cluster=sreg.h.al;
nbre_cluster=sreg.x.dx;
taille_total=(unsigned long) taille_cluster * (unsigned long) nbre_cluster * 512L;
// D‚termine paramŠtres physique SI disque dur
if ((drv!=1)&&(drv!=2)) {
  sreg.h.ah=0x08;
  sreg.h.dl=drv+0x7D;
  int86(0x13,&sreg,&sreg);
  nbre_disque=sreg.h.dl;
  nbre_tete=sreg.h.dh+1;
  nbre_secteur=sreg.h.cl&0x3F;
  nbre_piste_cyl=sreg.h.ch+((sreg.h.cl&0xC0)<<2)+1;
  }
// Informations Master boot
bo=(m) || !((b) || (f) || (r) || (se));
if (bo) printf("\rGetting Master Boot Record...                               ");
// Ici commence affichage info en commen‡ant avec un Master Boot
diskread(drv,head,secteur,piste_cyl,1,(char *) masterbootrec);
resboot=check_master_boot_rec((SecteurMasterBoot *) masterbootrec);
if ((drv==1) || (drv==2)) resboot=0; // Si disquette, il ne peut y avoir de Master boot
#ifdef DEBUG
displayraw((BYTE *) masterbootrec,1);
#endif
if (resboot && bo) { // Master Boot valide
  ecran();
  printf("Physical disk: %c\r\n",drvlet);
  printf("System area  : MASTER BOOT\r\n");
  printf("\n");
  printf("Head: ");bl;printf("%i",head);gr;printf(", Sector: ");bl;printf("%i",secteur);gr;printf(", Track/Cylinder: ");bl;printf("%i\r\n",piste_cyl);gr;
  printf("-------------------------------------------------------------------------------\r\n");
  AfficheSecteurMasterBoot((SecteurMasterBoot *) masterbootrec);
  pause();
  }
if ((resboot) && ((SecteurMasterBoot *) masterbootrec)->entree[passage].type) { // Pour les partitions utilis‚es
  head=((SecteurMasterBoot *) masterbootrec)->entree[passage].tete_debut;
  w=((SecteurMasterBoot *) masterbootrec)->entree[passage].seccyl_debut;
  secteur=w & 0x003F;
  piste_cyl=((w>>8) | ((w<<2) & 0x0300));
  }
// Informations secteur boot
bo=(b) || !((m) || (f) || (r) || (se));
if (bo) printf("\rGetting Boot Sector...                                      ");
diskread(drv,head,secteur,piste_cyl,1,(char *) bootrec);
resbootsector=check_boot_rec(bootrec);
if (bo) {
  ecran();
  printf("Physical disk: %c\r\n",drvlet);
  printf("System area  : BOOT SECTOR\r\n");
  printf("\n");
  }
switch (resbootsector) {
  case 0: /* Secteur boot invalide */
    if (bo) {
      printf("Not a system disk.\r\n\r\n");
      }
    break;
  case 1:
  case 2:
  case 3:
    if (bo) {
      printf("Head: %i, Sector: %i, Track/Cylinder: %i\r\n",head,secteur,piste_cyl);
      printf("-------------------------------------------------------------------------------\r\n");
      AfficheSecteurBoot((SecteurBoot *) bootrec);
      printf("  Note: The analyse of the boot code area show that the OS is %s\r\n",system_exp[res]);
      }
    descripteur=((SecteurBoot *) bootrec)->idbyte;
    switch (descripteur) { //On connait le descripteur
      case 0xF8: //Disque dur: ne rien faire
	break;
      case 0xF0:
	nbre_tete=2;
	nbre_secteur=18;
	nbre_piste_cyl=80;
	break;
      case 0xF9:
	nbre_tete=2;
	nbre_secteur=9;
	nbre_piste_cyl=80;
	break;
      default:
	printf("Media type %s of this disk is not managed by DiskInfo.\r\n",drvlet);
	exit(0);
      }
    taille_fat=((SecteurBoot *) bootrec)->FATsects;
    taille_racine=((SecteurBoot *) bootrec)->rootdirentries;
    secteur+=((SecteurBoot *) bootrec)->resvsects;
    head+=secteur/nbre_secteur;
    piste_cyl+=head/nbre_tete;
    secteur%=nbre_secteur;
    head%=nbre_tete;
    break;
  }
#ifdef DEBUG
displayraw((BYTE *) bootrec,1);
#endif
if (bo) pause();
// Lecture de la FAT
bo=(f) || !((m) || (b) || (r) || (se));
if (bo) printf("\rGetting FAT information...                                    ");
// Confirme le nombre de cluster pour connaitre type FAT
if ((drv!=1) && (drv!=2)) {
  if (taille_total<128L*1024L*1024L) {taille_cluster=4;goto fin;}
  if (taille_total<256L*1024L*1024L) {taille_cluster=8;goto fin;}
  if (taille_total<512L*1024L*1024L) {taille_cluster=16;goto fin;}
  if (taille_total<1024L*1024L*1024L) {taille_cluster=32;goto fin;}
  else {taille_cluster=64;goto fin;}
  fin:
  }
if ((nbre_cluster>4096) || (nbre_cluster==0)) type_fat=16;
diskread(drv,head,secteur,piste_cyl,1,(char *) fat_buffer);
#ifdef DEBUG
displayraw((BYTE *) fat_buffer,1);
#endif
resfat=check_fat_rec(fat_buffer);
if (bo) {
  ecran();
  printf("Physical disk: %c\r\n",drvlet);
  printf("System area  : FAT (FAT%i => 1 entry = %i bits)\r\n",type_fat,type_fat);
  printf("\n");
  printf("Head: %i, Sector: %i, Track/Cylinder: %i\r\n",head,secteur,piste_cyl);
  printf("-------------------------------------------------------------------------------\r\n");
  }
if (resfat) {
  descripteur=fat_buffer[0];
  switch (descripteur) {
    case 0xF8: //Disque dur: ne rien faire
      break;
    case 0xF0:
      nbre_tete=2;
      nbre_secteur=18;
      nbre_piste_cyl=80;
      taille_fat=9;
      taille_racine=16*14;
      break;
    case 0xF9:
      nbre_tete=2;
      nbre_secteur=9;
      nbre_piste_cyl=80;
      taille_fat=3;
      taille_racine=16*7;
      break;
    default:
      printf("Media type %s of this disk is not managed by DiskInfo.\r\n",drvlet);
      exit(0);
    }
  if (bo) {
    AfficheFat((BYTE *) fat_buffer);
    printf("\n");
    printf("Note: %u*%u/%i = %lu entries\r\n",taille_fat,((SecteurBoot *) bootrec)->sectsize,2,(DWORD) taille_fat * (DWORD) (((SecteurBoot *) bootrec)->sectsize >> 1),type_fat);
    }
  }
else {
  printf("FAT format is not valid.\r\n");
  exit(0);
  }
if (bo) pause();
piste_cyl1=piste_cyl;secteur1=secteur;head1=head;
secteur+=taille_fat;
head+=secteur/nbre_secteur;
piste_cyl+=head/nbre_tete;
secteur%=nbre_secteur;
head%=nbre_tete;
// Lecture des autres FAT
if (((SecteurBoot *) bootrec)->FATcopies>1) {
  if (bo) {
    ecran();
    printf("Physical disk: %c\r\n",drvlet);
    printf("System area  : FAT COPY\r\n");
    printf("\n");
    printf("Head: %i, Sector: %i, Track/Cylinder: %i\r\n",head1,secteur1,piste_cyl1);
    printf("-------------------------------------------------------------------------------\r\n");
    printf("Testing FAT differences...");
    }
  if (!(m|b|f|r|se) || (f|r|se)) {
  i=0;
  for (j=1;j<((SecteurBoot *) bootrec)->FATcopies;j++) {
    piste_cyl2=piste_cyl1;secteur2=secteur1;head2=head1;
    for (k=1;k<=taille_fat;k++) { // Read and compare one sector each time
      diskread(drv,head2,secteur2,piste_cyl2,1,(char *) fat_buffer2);
      diskread(drv,head,secteur,piste_cyl,1,(char *) fat_buffer);
      if (memcmp(fat_buffer,fat_buffer2,512)) i=j;
      secteur2++;
      head2+=secteur2/nbre_secteur;
      piste_cyl2+=head2/nbre_tete;
      secteur2%=nbre_secteur;
      head2%=nbre_tete;
      secteur++;
      head+=secteur/nbre_secteur;
      piste_cyl+=head/nbre_tete;
      secteur%=nbre_secteur;
      head%=nbre_tete;
      }
    if (i && bo) printf("\rThe %ith FAT is different from the first one.\r\n",j+1);
    }
  if ((i==0) && bo) printf("\rAll FAT copies are similar to the original.\r\n");
  }
  if (bo) pause();
  }
// Lecture zone racine
bo=(r) || !((m) || (b) || (f) || (se));
if (bo) printf("\rGetting Directory information...                            ");
diskread(drv,head,secteur,piste_cyl,1,(char *) directory);
if (taille_racine==0) taille_racine=112;
if (bo) {
  ecran();
  printf("Physical disk: %c\r\n",drvlet);
  printf("System area  : ROOT (1 entry = 32 bytes)\r\n");
  printf("\n");
  printf("Head: %i, Sector: %i, Track/Cylinder: %i\r\n",head,secteur,piste_cyl);
  printf("-------------------------------------------------------------------------------\r\n");
  #ifdef DEBUG
  displayraw((BYTE *) directory,1);
  #endif
  if (r) i=0; // changer cela
  for (j=0;j<=i;j++) AfficheDirectory(directory+j);
  printf("\n");
  printf("Note: %i entries.\r\n",taille_racine);
  pause();
  }
secteur+=(taille_racine * 32 / ((SecteurBoot *) bootrec)->sectsize);
head+=secteur/nbre_secteur;
piste_cyl+=head/nbre_tete;
secteur%=nbre_secteur;
head%=nbre_tete;
// Lecture zone donn‚es
bo=(se) || !((m) || (b) || (f) || (r));
if (bo) printf("\rReading Data sector...                                      ");
diskread(drv,head,secteur,piste_cyl,1,(char *) buf);
if (bo) {
  ecran();
  printf("Physical disk: %c\r\n",drvlet);
  printf("System area  : DATA/SUB-DIR SECTOR\r\n");
  printf("\n");
  printf("Head: %i, Sector: %i, Track/Cylinder: %i\r\n",head,secteur,piste_cyl);
  printf("-------------------------------------------------------------------------------\r\n");
  printf("From here, sectors are used to store your program or data files.\n");
  printf("You can use EDDISK from UTILKIT pack to see or edit the content of a particular\n");
  printf("sector.\n");
  }
if (se) {
//i=secteur+(head-1)*nbre_secteur+piste_cyl*nbre_tete*nbre_secteur;
  AfficheSecteur((BYTE *) buf,1);
  }
return(0);
}
