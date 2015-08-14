//  RECHERCHE PAR DICHOTOMIE DANS UN TABLEAU

#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>
#define Elements_Max 9
int cherche(int element);
void sortie(void);
int champ[Elements_Max];


void entree (void)
//  Entr‚e d'un tableau dans lequel doit s'effectuer la recherche
{
int i1;
char s[128];
for (i1=0;i1<=(Elements_Max-1);i1++)
  {
  printf("%i) Nombre : ",i1);
  strcpy(s,gets(s));
  champ[i1]=atoi(s);
  fflush(stdin);
  }
}


int main (void)
{
int trouve = 0;
int element = -1;
char s[128];
entree ( );
sortie ( );
printf("Saisie d'un ‚l‚ment :\n");
strcpy(s,gets(s));
element=atoi(s);
trouve=cherche(element);
if ( trouve == -1 )
  {
  printf("El‚ment non trouv‚.\n");
  exit (1);
  }
else
  {
  printf("L'‚l‚ment %i a ‚t‚ trouv‚ … la position ",element);
  printf("%i\n",trouve);
  }
return(0);
}


int cherche(int element)
{
int HMilieu = 0;
int gauche = 0;
int droite = Elements_Max - 1;
while ( droite >= gauche )
  {
  // Recherche du milieu du tableau
  HMilieu = ( gauche + droite ) / 2;
  if ( element < champ[HMilieu] )
    droite = HMilieu - 1;
  else
    gauche = HMilieu + 1;
  // Si l'‚l‚ment est trouv‚
  // HMilieu est renvoy‚ en guise de position.
  if (element == champ[HMilieu] )
    return(HMilieu);
  }
//  Si aucun ‚l‚ment n'est trouv‚,
//  la valeur renvoy‚e est -1.
return(-1);
}


void sortie(void)
//  Affichage du tableau dans lequel doit avoir lieu la recherche
{
int i1=0;
for (i1=0;i1<=(Elements_Max-1);i1++)
  {
  printf("%i\n",champ[i1]);
  }
}


