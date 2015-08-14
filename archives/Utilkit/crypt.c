//********************************************************************
// Reverse Encrypting/Decrypting soft
/*********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation                                                */
//********************************************************************
#define PROG    "Crypt"
#define VERSION "3.0"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <misc.h>
#include <hardware.h>
#include <macros.h>


/* Variables */
char *cryptext;       /* The actual encryption/decryption key */
int crypt_ptr = 0;    /* Circular pointer to elements of key  */
int crypt_length;     /* Set externally to strlen(cryptext)   */
char source[MAXPATH];
char destination[MAXPATH];

/* The encryption is both reversible - to decrypt data, pass it back through crypt()
   using the original key and original initial value of crypt_ptr - and multiple passes are commutative. */



void Init_fin(int retour)
/* Termine avec code erreur */
{
switch (retour) {
  case 1:fprintf(stderr,"Erreur: Le fichier source %s est introuvable.\n",source);break;
  case 2:fprintf(stderr,"Erreur: Impossible d'ouvrir le fichier source.\n");break;
  case 3:fprintf(stderr,"Erreur: Impossible d'ouvrir le fichier destination.\n");break;
  case 4:fprintf(stderr,"Erreur: Argument invalide\n");break;
  case 5:break;
  }
exit(retour);
}


void Crypt(unsigned char *buf)
/* Encrypt/decrypt buffer data */
{
*buf ^= cryptext[crypt_ptr] ^ (cryptext[0] * crypt_ptr);
  cryptext[crypt_ptr] += ((crypt_ptr < (crypt_length - 1)) ?
  cryptext[crypt_ptr + 1] : cryptext[0]);
if (!cryptext[crypt_ptr]) cryptext[crypt_ptr] += 1;
if (++crypt_ptr >= crypt_length) crypt_ptr = 0;
}




int main(int argc, char *argv[])
/****************************************************************/
/* RETURN:  0   Ok                                              */
/*          1   Fichier source introuvable                      */
/*          2   Erreur ouverture fichier source                 */
/*          3   Erreur ouverture fichier destination            */
/*          4   Argument invalide                               */
/*          5   Mauvaise ligne de commande                      */
/****************************************************************/
{
static unsigned char buf[16384];
int j=0;
size_t len,k;
FILE *in, *out;

/* Exploite parametres */
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
    if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
	    switch (argv[noarg][1] | 0x20) {
    	  	case '?':
	  		case 'h': help=-1;break;
 	     	default: invalide=-1;
      	}
    }
  	else {
    	switch (j++) {
      		case 0:cryptext=argv[noarg];break;
      		case 1:strcpy(source,argv[noarg]);break;
      		case 2:strcpy(destination,argv[noarg]);break;
   		}
   	}
}

/* Affiche en-tete */
if (help) {     
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Usage:  %s  <password>  <source_file>  <destination_file>\n",PROG);
	printf("\n");
	printf("Protocole de cryptage:	S-Coder\n");
	printf("CRYPT est un programme de cryptographie qui permet donc de coder un fichier …\n");
	printf("partir d'un mot de passe afin de rendre ce fichier incompr‚hensible … toute \n");
	printf("personne d‚munie du mot de passe pour d‚crypter le fichier.\n");
	printf("\n");
	printf("Rem: Les fonctions de cryptage et d‚cryptage ‚tant les mˆmes (commutatives),\n");
	printf("l'utilisation de CRYPT sur un fichier d'origine va le crypter alors que \n");
	printf("l'utilisation sur un fichier crypt‚ va le d‚crypter.\n");
	exit(0);
	}
if (invalide) {
	printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
	printf("Error:  Bad command line\n");
	exit(1);
	}

/* Si source n'existe pas */
if (!FILEEXIST(source)) Init_fin(1);
crypt_length = strlen(cryptext);
if (NULL == (in = fopen(argv[2], "rb"))) Init_fin(2);
if (NULL == (out = fopen(argv[3], "wb"))) Init_fin(3);
printf("Cryptage/Decryptage en cours...");
do {
  if (0!=(len=fread(buf,1,16384,in))) {
    for (k=0;k<len;k++) Crypt(&buf[k]);
    fwrite(buf,1,len,out);
    }
  }
while (len);
fclose(in);
fclose(out);
printf("\rCryptage/Decryptage termin‚.\n");
printf("Le fichier %s a ‚t‚ g‚n‚r‚ … partir du fichier %s\n",destination,source);
return(0);
}

