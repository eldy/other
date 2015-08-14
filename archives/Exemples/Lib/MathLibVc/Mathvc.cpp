//*****************************************************************************
// Création d'une librairie statique LIB Win32 en C par VC
//*****************************************************************************
// Compilation: VC 4.0
// Target:      Win32
//*****************************************************************************
// mathvc.cpp : Defines the initialization routines for the DLL.
//

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "mathvc.h"


CMathDll::CMathDll()
{

}


CMathDll::~CMathDll()
{

}


double CMathDll::Puissance(double x,double y)
{
	if (x==0) {
	  if (y==0)
		  return((double) 1);
	  else
		  return((double) 0);
	}
	else {
	  if (x>0)
		  return(exp(y*log(x)));
	  else
		  return((double) 0);
	/*    if odd(round(y)) then puissance:=SIGNE(x)*exp(y*ln(abs(x)))
		else puissance:=-SIGNE(x)*exp(y*ln(abs(x))); */
	}
}

