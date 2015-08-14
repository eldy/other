//********************************************************************
// Make a PC Boot (cold or warm)
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG	"Boot"
#define VERSION	"3.0"

#include <io.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "macros.h"
#include "hardware.h"

int  warm=0,cold=0;
int  version;
char s1[MAXPATH];


int main(int argc,char *argv[])
//******************************************************************
// RETURN: Nothing (boot) or
//         0  Help is displayed
//         1  Bad Argument(s)
//         2  Windows is active
//******************************************************************
{

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if (((argv[noarg][0])=='/') || ((argv[noarg][0])=='-')) {
    switch (argv[noarg][1] | 0x20) {
      case 'c': cold=-1;break;
      case 'w': warm=-1;break;
      case '?':
      case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  else invalide=-1;
  }


if (help) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  [/c] [/w]\n",PROG);
  printf("\n");
  printf("BOOT perform a cold (/c option) or a warm (/w option) of your computer.\n");
  printf("Note: A cold boot is equivalent to a power shutdown.\n");
  printf("      A warm boot is equivalent to CTRL+ALT+SUP key.\n");
  printf("      A protection prevents you to boot if Windows is running.\n");
  exit(0);
  }

if (invalide) {
  printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
  printf("Usage:  %s  [/c] [/w]\n",PROG);
  printf("Error:  Bad argument(s).\n");
  exit(1);
  }

// Debut du programme
if (((warm) || (cold)) && (WindowsVersion(&version,&version))) {
  printf("Error: Windows is running.\n");
  return(2);
  }
if (warm) WARMBOOT();
if (cold) COLDBOOT();

return(1);
}
