//  TRI A BULLE

#include <macros.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#define Elements_Max 9
void tribulle (void);
void entree (void);
void sortie (void);
static int champ[Elements_Max];


main ()
{
entree();
sortie();
printf("Tri du champ achev‚ :\n");
tribulle();
sortie();
return(0);
}


void tribulle(void)
{
int i,j,echange;
for (i=Elements_Max;i>=0;i--)
  for (j=1;j<=i;j++)
	 if (champ[j-1]>champ[j])
		{
		echange = champ[j - 1];
		champ[j - 1] = champ[j];
		champ[j] = echange;
		}
}



void sortie(void)
{
int i1;
for (i1=0;i1<=Elements_Max;i1++)
  {
  printf("%i ",champ[i1]);
  }
N;
}


void entree(void)
{
int i1;
char s[128];
for (i1=0;i1<=Elements_Max;i1++)
  {
  printf("%i - Nombre : ",i1);
  strcpy(s,gets(s));
  champ[i1]=atoi(s);
  fflush(stdin);
  }
}

