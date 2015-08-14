//-------------------------------------------------------------------
// Ansi functions library
//-------------------------------------------------------------------
// 30/10/98		3.0		Laurent Destailleur		Creation
//-------------------------------------------------------------------
// <<< MSDOS, Unix >>>
// WaitKey
// IsAnsi
// ANSI_cup(a,b)
// ANSI_up(a)
// ANSI_down(a)
// ANSI_right(a)
// ANSI_left(a)
// ANSI_locate(a,b)
// ANSI_savecurs()
// ANSI_restcurs()
// ANSI_cls()
// ANSI_cleol()
// ANSI_margins(a,b)
// ANSI_attrib(a)
// ANSI_fg_color(a)
// ANSI_bg_color(a)
//-------------------------------------------------------------------

#include <stdio.h>
#include <string.h>
#ifdef __MSDOS__
#include <conio.h>
#endif

#include "ansi.h"


#ifndef _Windows


int WaitKey(void)
//-------------------------------------------------------------------
// Attend frappe d'une touche sans clignotement curseur
//-------------------------------------------------------------------
{
#ifdef __MSDOS__
while (kbhit()) getch(); /* Clear buffer */
while (kbhit()==0);      /* Wait a key   */
return(getch());         /* Clear buffer */
#else
#ifdef _WIN32
#ifndef __GNUC__
while (kbhit()) getch(); /* Clear buffer */
while (kbhit()==0);      /* Wait a key   */
return(getch());         /* Clear buffer */
#else
return(getchar());

#endif
#else
return(getchar());
#endif
#endif
}


#ifdef _CONSOLE

void print(char *p)
{
while(*p) putchar(*p++);
fflush(stdout); /* necessary for ZTC */
}

#ifndef __GNUC__

int IsAnsi(void)
//-------------------------------------------------------------------
// Cherche si gestionnaire ANSI.SYS charge
// Retour: -1 TRUE  oui
//          0 FALSE non
//-------------------------------------------------------------------
{
char buffer [31];               /* temporary buffer                   */
int  nr=0;                      /* counter                            */
print("\x1b[6n\r      \r");     /* ask for ansi device report         */
while (kbhit() && (nr<30))      /* read whatever input is present     */
  buffer[nr++] = (char) getch();
buffer[nr]='\0';                /* zero terminate string              */
if (strstr(buffer, "\x1b["))    /* check precense of device report    */
  return(-1);                   /* signal ANSI.SYS present            */
else
  return(0);                    /* signal ANSI.SYS not present        */
}

#endif
#endif


#endif

