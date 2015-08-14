//**********************************************************************
// Etude de résultats tirage Loto
//**********************************************************************
// Compilation: 32 bits
//**********************************************************************

#include "conio.h"
#include "stdio.h"
#include "string.h"
#include "windows.h"

#define N 49								// N nombre d'éléments de l'univers (N <= 49)
#define Commun 2							// C nombre d'éléments communs (1<=C<=6)
#define fichier "d:\\loto\\Liste_3_49.txt"	// C nombre de N <= 49


long a,b,i,j,k,l,m,n;
char s1[13983816+1][6];
char s2[500][6];
char temp[6];
char line[128];
FILE *fic;


int isdouble(void) {
// Renvoi vrai si il y a 3 chiffres communs ou plus
short int k=0,n=0;
while (k<6) {
	if (memchr(s1[i],s2[j][k++],6) != NULL) {
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
cprintf("Teste fichier %s\n",fichier);
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
cprintf("Tableau des %i combinaisons de 6 générées.\n",a);
// Initialisation des combinaisons avec fichier
b=0;
if ((fic=fopen(fichier,"r"))==NULL) {
	cprintf("Erreur à l'ouverture du fichier %s",fichier);	
}
else {
	while (fgets(line,sizeof(line),fic)!=NULL) { // Pour chaque ligne
		++b;
		for (i=0;i<6;i++) {
			temp[0]=line[i*3];temp[1]=line[i*3+1];temp[2]=0;
			s2[b][i]=(char) atoi(temp);
		}
	}
	cprintf("Tableau des %i combinaisons jouées (fichier %s) généré.\n",b,fichier);
	fclose(fic);
}
// Teste pour chaque combinaison
k=0; // Nbre de combinaisons non jouées
for (i=1;i<=a;i++) {
	for (j=1;j<=b;j++) {
		if (isdouble()) break;		
	}
	if (j>b) k++;
}
cprintf("Nbre de combinaisons sortantes non gagnantes %i.\n",k);
gets(line);
}
