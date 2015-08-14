/**********************************************************************/
/* Creation de DLL en C sous Windows                                  */
/**********************************************************************/
// Compilateur: 	BC 5.0
// Modèle:		DLL Win32
/**********************************************************************/
#include <stdio.h>
#include <windows.h>
#include <windowsx.h>
#include <stdlib.h>

int FAR PASCAL _export f(int i)
//**********************************************************************
{
int j=1;
return(i+j);
}

