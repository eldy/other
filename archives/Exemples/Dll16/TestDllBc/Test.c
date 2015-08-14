/********************************************************************************/
/* Executable Windows en C utilisant une DLL
/********************************************************************************/
/* Compilation: BC 3.1 ou 5.0
/* Target:      Windows
/********************************************************************************/
// Tapez sur la ligne de commande DOS:
// IMPLIB fichier.lib fichier.dll pour générer le fichier .lib, s'il
// n'existe pas, à inclure dans le projet afin d'utiliser le fichier .dll

#include <stdio.h>
#include <windows.h>
#include <windowsx.h>
#include <string.h>
#include "general.h"

int i,j;


extern int PASCAL DIRACZERO(int i);
extern int PASCAL FACTORIELLE(int i);


int PASCAL WinMain()
{
i=20000;
j=4;
if (FACTORIELLE(j)>3) {
  TextOut(GetWindowDC(GetDesktopWindow()),0,0,"XXX",3);
  }
j=DIRACZERO(i);
return(0);
}
