//  QUICKSORT

#include <macros.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <string.h>

void TriRapide (int gauche,int droite);
void entree(void);
void sortie(void);
static int tableau[9];


main()
{
entree();
sortie();
printf("Tri du tableau achev‚ :\n");
TriRapide(0,8);
sortie();
return(0);
}


void TriRapide(int gauche,int droite )
{
int element, i, j, echange;
if (droite>gauche) {
  element = tableau[droite];
  i = gauche - 1;
  j = droite;
  for ( ; ; )
    {
    while ( tableau[++i] < element );
    while ( tableau[--j] > element);
    if ( i >= j ) break;
    echange = tableau[i];
    tableau[i] = tableau[j];
    tableau[j] = echange;
    }
  echange = tableau[i];
  tableau[i] = tableau[droite];
  tableau[droite] = echange;
  TriRapide(gauche,i-1);
  TriRapide(i+1,droite);
  }
}



void sortie(void)
{
int i1;
for (i1=0;i1<=8;i1++)
  {
  printf("%i ",tableau[i1]);
  }
	printf("\n");
}


void entree(void)
{
int i1;
char s[128];
for (i1=0;i1<=8;i1++)
  {
  printf("%i) Nombre : ",i1);
  strcpy(s,gets(s));
  tableau[i1]=atoi(s);
  fflush(stdin);
  }
}