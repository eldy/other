//*************************************************************************
// Création de DLL Win32 sous VC
//*************************************************************************
// Compilation: VC 4.0		VC 5.0
// Target:      Win32		-
//*************************************************************************

#include <windows.h>
#include <math.h>



int Signe(int x)
{
	if (x>=0) return(1);
	else return(-1);
}


double Puissance(double x,double y)
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
	/*    if odd(round(y)) then puissance:=signe(x)*exp(y*ln(abs(x)))
		else puissance:=-signe(x)*exp(y*ln(abs(x))); */
	}
}




BOOL WINAPI DllEntryPoint (HINSTANCE hDLL, DWORD dwReason, LPVOID Reserved)
{
	switch (dwReason)
	{
	case DLL_PROCESS_ATTACH:
		{
			break;
		}
	case DLL_PROCESS_DETACH:
		{
			break;
		}
	}
	return TRUE;
}
