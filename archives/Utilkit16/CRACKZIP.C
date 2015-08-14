//********************************************************************
// Crack a Zip file encrypted with -s option
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"CrackZip"
#define VERSION	"3.0"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <dos.h>

#include "misc.h"
#include "hardware.h"
#include "macros.h"


/* Types */
unsigned long crc_32_tab[] =
{
    0x00000000L, 0x77073096L, 0xee0e612cL, 0x990951baL, 0x076dc419L,
    0x706af48fL, 0xe963a535L, 0x9e6495a3L, 0x0edb8832L, 0x79dcb8a4L,
    0xe0d5e91eL, 0x97d2d988L, 0x09b64c2bL, 0x7eb17cbdL, 0xe7b82d07L,
    0x90bf1d91L, 0x1db71064L, 0x6ab020f2L, 0xf3b97148L, 0x84be41deL,
    0x1adad47dL, 0x6ddde4ebL, 0xf4d4b551L, 0x83d385c7L, 0x136c9856L,
    0x646ba8c0L, 0xfd62f97aL, 0x8a65c9ecL, 0x14015c4fL, 0x63066cd9L,
    0xfa0f3d63L, 0x8d080df5L, 0x3b6e20c8L, 0x4c69105eL, 0xd56041e4L,
    0xa2677172L, 0x3c03e4d1L, 0x4b04d447L, 0xd20d85fdL, 0xa50ab56bL,
    0x35b5a8faL, 0x42b2986cL, 0xdbbbc9d6L, 0xacbcf940L, 0x32d86ce3L,
    0x45df5c75L, 0xdcd60dcfL, 0xabd13d59L, 0x26d930acL, 0x51de003aL,
    0xc8d75180L, 0xbfd06116L, 0x21b4f4b5L, 0x56b3c423L, 0xcfba9599L,
    0xb8bda50fL, 0x2802b89eL, 0x5f058808L, 0xc60cd9b2L, 0xb10be924L,
    0x2f6f7c87L, 0x58684c11L, 0xc1611dabL, 0xb6662d3dL, 0x76dc4190L,
    0x01db7106L, 0x98d220bcL, 0xefd5102aL, 0x71b18589L, 0x06b6b51fL,
    0x9fbfe4a5L, 0xe8b8d433L, 0x7807c9a2L, 0x0f00f934L, 0x9609a88eL,
    0xe10e9818L, 0x7f6a0dbbL, 0x086d3d2dL, 0x91646c97L, 0xe6635c01L,
    0x6b6b51f4L, 0x1c6c6162L, 0x856530d8L, 0xf262004eL, 0x6c0695edL,
    0x1b01a57bL, 0x8208f4c1L, 0xf50fc457L, 0x65b0d9c6L, 0x12b7e950L,
    0x8bbeb8eaL, 0xfcb9887cL, 0x62dd1ddfL, 0x15da2d49L, 0x8cd37cf3L,
    0xfbd44c65L, 0x4db26158L, 0x3ab551ceL, 0xa3bc0074L, 0xd4bb30e2L,
    0x4adfa541L, 0x3dd895d7L, 0xa4d1c46dL, 0xd3d6f4fbL, 0x4369e96aL,
    0x346ed9fcL, 0xad678846L, 0xda60b8d0L, 0x44042d73L, 0x33031de5L,
    0xaa0a4c5fL, 0xdd0d7cc9L, 0x5005713cL, 0x270241aaL, 0xbe0b1010L,
    0xc90c2086L, 0x5768b525L, 0x206f85b3L, 0xb966d409L, 0xce61e49fL,
    0x5edef90eL, 0x29d9c998L, 0xb0d09822L, 0xc7d7a8b4L, 0x59b33d17L,
    0x2eb40d81L, 0xb7bd5c3bL, 0xc0ba6cadL, 0xedb88320L, 0x9abfb3b6L,
    0x03b6e20cL, 0x74b1d29aL, 0xead54739L, 0x9dd277afL, 0x04db2615L,
    0x73dc1683L, 0xe3630b12L, 0x94643b84L, 0x0d6d6a3eL, 0x7a6a5aa8L,
    0xe40ecf0bL, 0x9309ff9dL, 0x0a00ae27L, 0x7d079eb1L, 0xf00f9344L,
    0x8708a3d2L, 0x1e01f268L, 0x6906c2feL, 0xf762575dL, 0x806567cbL,
    0x196c3671L, 0x6e6b06e7L, 0xfed41b76L, 0x89d32be0L, 0x10da7a5aL,
    0x67dd4accL, 0xf9b9df6fL, 0x8ebeeff9L, 0x17b7be43L, 0x60b08ed5L,
    0xd6d6a3e8L, 0xa1d1937eL, 0x38d8c2c4L, 0x4fdff252L, 0xd1bb67f1L,
    0xa6bc5767L, 0x3fb506ddL, 0x48b2364bL, 0xd80d2bdaL, 0xaf0a1b4cL,
    0x36034af6L, 0x41047a60L, 0xdf60efc3L, 0xa867df55L, 0x316e8eefL,
    0x4669be79L, 0xcb61b38cL, 0xbc66831aL, 0x256fd2a0L, 0x5268e236L,
    0xcc0c7795L, 0xbb0b4703L, 0x220216b9L, 0x5505262fL, 0xc5ba3bbeL,
    0xb2bd0b28L, 0x2bb45a92L, 0x5cb36a04L, 0xc2d7ffa7L, 0xb5d0cf31L,
    0x2cd99e8bL, 0x5bdeae1dL, 0x9b64c2b0L, 0xec63f226L, 0x756aa39cL,
    0x026d930aL, 0x9c0906a9L, 0xeb0e363fL, 0x72076785L, 0x05005713L,
    0x95bf4a82L, 0xe2b87a14L, 0x7bb12baeL, 0x0cb61b38L, 0x92d28e9bL,
    0xe5d5be0dL, 0x7cdcefb7L, 0x0bdbdf21L, 0x86d3d2d4L, 0xf1d4e242L,
    0x68ddb3f8L, 0x1fda836eL, 0x81be16cdL, 0xf6b9265bL, 0x6fb077e1L,
    0x18b74777L, 0x88085ae6L, 0xff0f6a70L, 0x66063bcaL, 0x11010b5cL,
    0x8f659effL, 0xf862ae69L, 0x616bffd3L, 0x166ccf45L, 0xa00ae278L,
    0xd70dd2eeL, 0x4e048354L, 0x3903b3c2L, 0xa7672661L, 0xd06016f7L,
    0x4969474dL, 0x3e6e77dbL, 0xaed16a4aL, 0xd9d65adcL, 0x40df0b66L,
    0x37d83bf0L, 0xa9bcae53L, 0xdebb9ec5L, 0x47b2cf7fL, 0x30b5ffe9L,
    0xbdbdf21cL, 0xcabac28aL, 0x53b39330L, 0x24b4a3a6L, 0xbad03605L,
    0xcdd70693L, 0x54de5729L, 0x23d967bfL, 0xb3667a2eL, 0xc4614ab8L,
    0x5d681b02L, 0x2a6f2b94L, 0xb40bbe37L, 0xc30c8ea1L, 0x5a05df1bL,
    0x2d02ef8dL
}; /* end crc_32_tab[] */

#define crc32(c, b) (crc_32_tab[((int)(c) ^ (b)) & 0xff] ^ ((c) >> 8))
#define max_file 5
#define max_length 5

char password[256];



int c_break(void)
{
printf("\nSearch was stopped to %s.\n",password);
return(0);
}


int main(int argc,char **argv)
//******************************************************************
// RETURN:  0  Ok or CTRL-BREAK used to stop
//          1  Wrong command line
//          2  Source file not valid
//          3  Extension not valid
//          4  Dictionnary file not found
//          5  No encyphered files in archive
//******************************************************************
{
int i,j=1,all=0,dico=-1,lon=0,br=-1;
char argument1[MAXPATH];
char argument2[MAXPATH];
char drive1[MAXDRIVE];
char dir1[MAXDIR];
char name1[MAXFILE];
char ext1[MAXEXT];
FILE *zip_file;
FILE *dictionnary;
unsigned char header[max_file][12];
unsigned char target[max_file];
long compressed_size;
int extra_field_length;
char file_name[max_file][1024];
int file_name_length;
int file_num;
int flags;
unsigned long signature;
int num_enciphered;
BYTE password_length,fin;
char *password_ptr;
int possibility_found;
register unsigned long key0;
register unsigned long key1;
register unsigned long key2;
register unsigned short tem;
register int byte;
register int byte_num;
register char *pc;

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if ((argv[noarg][0])=='/') {
    switch (argv[noarg][1] | 0x20) {
      case 'a': all=-1;break;
      case 'f': dico=0;break;
      case 'b': br=0;break;
      case 'l': lon=atoi(&argv[noarg][2]);break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else {
    if (j==1) {
	strcpy(argument1,argv[noarg]);
	strcpy(argument1,strupr(argument1));
	}
    if (j++>1) invalide=-1;
    }
  }

// Affiche en-tˆte
if (help) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <file[.zip]>  [/f]     [/a] [/lx] [/b]\n\n",PROG);
	printf("CrackZip will find passwords used to encyphered file in a ZIP archive created.\n");
	printf("by PKZIP v2.04 or more (and its -s option).  Two methods are possible:\n");
	printf(" - Dictionnary cracking=Use solutions from a file:  BY DEFAULT\n");
	printf(" - Brute force cracking=Try all solutions:          /F OPTION\n");
	printf("Rem: ZIP file coding is case sensitive.\n");
	printf("\n");
	printf("Other options are: /a   To search passwords common to all encyphered files.\n");
	printf("                   /lx  To search only passwords with a length of x\n");
	printf("                   /b   No break (Ctrl+Pause) are allowed (a little faster)\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

// Cr‚ation path complet
fnsplit(argument1,drive1,dir1,name1,ext1);
if (ext1[0]==0) strcpy(ext1,".ZIP");
if (strcmp(ext1,".ZIP")!=0) {
  printf("Error :  File extension must be .ZIP\n");
  exit(3);
  }
strcpy(argument1,drive1);strcat(argument1,dir1);
strcat(argument1,name1);strcat(argument1,ext1);

if ((zip_file=fopen(argument1,"rb")) == NULL) {
  printf("Error :  Zip file %s is not valid.\n",argument1);
  exit(2);
  }
// Find encrypted files
// Info is put in target and header
num_enciphered=0;
while ((num_enciphered<max_file) && fread((void *) &signature,4,1,zip_file)
  && (signature == 0x04034b50L)) {
  fseek(zip_file,2L,SEEK_CUR);
  fread((void *) &flags,2,1,zip_file);
  if (((int) flags) & 1) {
    fseek(zip_file,9L,SEEK_CUR);
    fread((void *) &(target[num_enciphered]),1,1,zip_file);
    fread((void *) &compressed_size,4,1,zip_file);
    fseek(zip_file,4L,SEEK_CUR);
    fread((void *) &file_name_length,2,1,zip_file);
    fread((void *) &extra_field_length,2,1,zip_file);
    fread((void *) &file_name[num_enciphered],1,file_name_length,zip_file);
    file_name[num_enciphered][file_name_length]='\0';
    fseek(zip_file,(long) extra_field_length,SEEK_CUR);
    fread((void *) &(header[num_enciphered++][0]),1,12,zip_file);
    compressed_size-=12L;
    #ifdef DEBUG
    printf("%s is enciphered.\n",&file_name[num_enciphered-1]);
    #endif
    }
  else {
    fseek(zip_file,10L,SEEK_CUR);
    fread((void *) &compressed_size,4,1,zip_file);
    fseek(zip_file,4L,SEEK_CUR);
    fread((void *) &file_name_length,2,1,zip_file);
    fread((void *) &extra_field_length,2,1,zip_file);
    compressed_size+=(file_name_length+extra_field_length);
    }
  fseek(zip_file,compressed_size,SEEK_CUR);
  }
fclose(zip_file);
// Show number of enciphered files
if (num_enciphered == 0) {
  printf("%s has no files enciphered.\n",argument1);
  exit(5);
  }
printf("%s has %i files enciphered.\n",argument1,num_enciphered);
// Install CTRL-BREAK Handler
ctrlbrk(c_break);
if (dico) { // Dictionnary cracking
  printf("Enter the name of the file to use as dictionnary file: ");
  scanf("%s",argument2);
  if ((dictionnary=fopen(argument2,"r")) == NULL) {
    printf("Error:  Dictionnary file %s not found.\n",argument2);
    exit(4);
    }
  if (all==0) {
    if (num_enciphered>=3) {
      num_enciphered=3; // Search only 1st encyphered file
      printf("Searching common password to the first 3 encyphered files");
      }
    else {
      printf("Searching common password to encyphered files");
      }
    }
  else {
    printf("Searching common password to all encyphered files");
    }
  if (br) printf(" (Ctrl+Pause to stop)\n");
  else printf("...\n");
  // Try all passwords in file
  possibility_found=FALSE;
  byte_num=0;
  while (fgets(&password[0],255,dictionnary) != NULL) {
    password[strlen(&password[0])-1]=0;
    // Try one password
    file_num=0;
    while (file_num<num_enciphered) {
      // Initialisation de Key0,1,2 pour un mot de passe donn‚
      key0=305419896L;
      key1=591751049L;
      key2=878082192L;
      password_ptr=&password[0];
      while (*password_ptr != '\0') {
	key0=crc32(key0,(int) *(password_ptr++));
	key1+=key0 & 0xff;
	key1*=134775813L;
	key2=crc32(key2,(int)((++key1)>> 24));
	}
      // Fin initialisation, d‚but recherche
      for (byte_num=0; byte_num < 12; byte_num++) {
	tem=(unsigned short) key2 | 2;
	byte=(int) header[file_num][byte_num] ^ ((int) (((unsigned short) (tem*(tem^1)) >> 8) & 0xff));
	key0=crc32(key0,byte);
	key1+=key0 & 0xff;
	key1*=134775813L;
	key2=crc32(key2,(int) ((++key1)>> 24));
	}
      if (byte==(int) target[file_num]) {
	if (++file_num == num_enciphered) {// Key is Ok for current crypted file
	  if (possibility_found==FALSE) {
	    printf("\nPossible key(s) found:\n");
	    possibility_found=TRUE;
	    }
	  printf("%s\n",&password[0]);
	  }
	}
      else file_num=num_enciphered; // All files, even not encrypted were found, try next password
      }
    // Now, try next password.
    }
  if (! possibility_found)
    printf("No key were found in dictionnary file %s.\n",dictionnary);
  fclose(dictionnary);
  }
else { // Brute Force cracking
  if (all==0) {
    if (num_enciphered>=3) {
      num_enciphered=3;
      printf("Searching password common to the first 3 encyphered files");
      }
    else {
      printf("Searching password common to the %i encyphered files",num_enciphered);
      }
    }
  else {
    printf("Searching password common to all encyphered files");
    }
  if (br) printf(" (CTRL+Pause to stop)\n");
  else printf("...\n");
  password_length=lon;
  if (password_length==0) fin=max_length-1;
  else fin= --password_length;
  // Try all password of length password_length to fin
  possibility_found=FALSE;
  for (i=password_length;i<=fin;i++) {
    // Init first password string
    for (j=0;j<=i;j++) password[j]='a';
    password[j]=0;
    pc=password;
    // Try all password of password_length
    debut_boucle:
    // Try one password
    file_num=0;
    while (file_num<num_enciphered) {
      // Initialisation de Key0,1,2 pour un mot de passe donn‚
      key0=305419896L;
      key1=591751049L;
      key2=878082192L;
      password_ptr=&password[0];
      while (*password_ptr != '\0') {
	byte=(int) *(password_ptr++);
	key0=crc32(key0,byte);
	key1+= key0 & 0xff;
	key1=key1*134775813L+1;
	key2=crc32(key2,(int)(key1>> 24));
	}

      // Fin initialisation, d‚but recherche
      for (byte_num=0; byte_num < 12; byte_num++) {
	tem=(unsigned short) key2 | 2;
	byte=(int) header[file_num][byte_num] ^((int) (((unsigned short) (tem*(tem^1)) >> 8) & 0xff));
	key0=crc32(key0,byte);
	key1+=key0 & 0xff;
	key1=key1*134775813L+1;
	key2=crc32(key2,(int) (key1>> 24));
	}
      if (byte==(int) target[file_num]) {
	if (++file_num == num_enciphered) {// Key is Ok for current crypted file
	  if (possibility_found==FALSE) {
	    printf("\nPossible key(s) found:\n");
	    possibility_found=TRUE;
	    }
	  printf("%s\n",&password[0]);
	  #ifdef DEBUG
	  exit(0);
	  #endif
	  }
	}
      else file_num=num_enciphered; // All files, even not encrypted were found
      }

    // Now, try next password.
    if ((++ *pc)<=122) goto debut_boucle; // Char > (z=122)
    do {
      *pc='a';
      pc++;
      }
    while ((++ *pc) > 122); // Char <= (z=122)
    if (*pc>='a') {
      pc=password;
      if (br) printf("\r");
      goto debut_boucle;
      }
    }
  }
return(0);
}
