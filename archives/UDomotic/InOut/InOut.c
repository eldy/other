/**********************************************************************/
/* Creation de DLL en C sous Windows                                  */
/**********************************************************************/
/* Compilateur: 	BC 5.0                                              */
/* Modèle:			DLL Win16														 */
/* ou             DLL Win32														 */
/**********************************************************************/
#include <conio.h>
#include <windows.h>


int FAR PASCAL _export InByte(int p)
//**********************************************************************
{
#ifdef WIN32
return(0);
#else
return(inp(p));
#endif
}


int FAR PASCAL _export OutByte(unsigned int p,int b)
//**********************************************************************
{
#ifdef WIN32
return(0);
#else
return(outp(p,b));
#endif
}


int FAR PASCAL _export InWord(int p)
//**********************************************************************
{
#ifdef WIN32
return(0);
#else
return(inpw(p));
#endif
}


int FAR PASCAL _export OutWord(unsigned int p,int w)
//**********************************************************************
{
#ifdef WIN32
return(0);
#else
return(outpw(p,w));
#endif
}

