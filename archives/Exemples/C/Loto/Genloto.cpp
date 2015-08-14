//**********************************************************************
// Génère un fichier de toutes les combinaisons de 6 dans un univers
// de N avec au maximum C éléments commun entre chaque
//**********************************************************************
// Compilation: 32 bits (nécessite 32 Mo de mémoire)
//**********************************************************************


#include "conio.h"
#include "stdio.h"
#include "string.h"
#include "windows.h"

#define N 49						// N nombre d'éléments de l'univers (N <= 49)
#define Commun 2					// C nombre d'éléments communs (1<=C<=6)
#define fichier "d:\\loto\\Liste_3_49.txt"


long a,i,j,k,l,m,n;
char s1[13983816+1][6];
char temp[6];
char line[128];
FILE *fic;


int isdouble(void) {
// Renvoi vrai si il y a 3 chiffres communs ou plus
short int k=0,n=0;
while (k<6) {
	if (memchr(s1[i],s1[j][k++],6) != NULL) {
		if (++n>Commun) return(TRUE);
	}
}
return(FALSE);
}

int isdouble2(void) {
// Renvoi vrai si il y a 3 chiffres communs ou plus
short int k=0,n=0;
while (k<6) {
	if (memchr(s1[i],s1[a][k++],6) != NULL) {
		if (++n>Commun) return(TRUE);
	}
}
return(FALSE);
}



void main( )
//**********************************************************************
// Programme principal
//**********************************************************************
{
cprintf("Génération du fichier %s\n",fichier);
cprintf("------------------------------------------------------------\n");
// Initialisation des combinaisons de 6 triés
a=0;
for (i=1;i<=N;i++) {
for (j=i+1;j<=N;j++) {
for (k=j+1;k<=N;k++) {
for (l=k+1;l<=N;l++) {
for (m=l+1;m<=N;m++) {
for (n=m+1;n<=N;n++) {
	a++;
	s1[a][0]=(char) i;
	s1[a][1]=(char) j;
	s1[a][2]=(char) k;
	s1[a][3]=(char) l;
	s1[a][4]=(char) m;
	s1[a][5]=(char) n;
}}}}}}
cprintf("Tableau des %i combinaisons de 6 générées.\n\n",a);


k=1;
fic=fopen(fichier,"w");
for (i=1;i<=a;i++) { // Pour toutes les combinaisons de 6
	fprintf(fic,"%02i %02i %02i %02i %02i %02i - %i\n",s1[i][0],s1[i][1],s1[i][2],s1[i][3],s1[i][4],s1[i][5],k);
	// Elimine tous les suivants qui inclus déjà la combinaison.
	for (j=i+1;j<=a;j++) {
		if (isdouble()) {
			while (isdouble2()) if ((--a)<=j) break;
			s1[j][0]=s1[a][0];s1[j][1]=s1[a][1];s1[j][2]=s1[a][2];
			s1[j][3]=s1[a][3];s1[j][4]=s1[a][4];s1[j][5]=s1[a][5];
			a--;
		}
	}
	cprintf("Solution no %i (i:%i a:%i %2.4f)\n",k++,i,a,(double) 100*(i+13983816-a)/13983816);
}
fclose(fic);
cprintf("Fichier %s générés.",fichier);
gets(line);
}
