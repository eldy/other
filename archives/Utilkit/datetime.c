//********************************************************************
// Dos   Show Date and time (with milliseconds)
// Win32 Unix Date like command
//********************************************************************
// 19/08/98		3.0		Laurent Destailleur		Creation
//********************************************************************
#define PROG    "DateTime"
#define VERSION "3.0"

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <sys/timeb.h>


#ifdef __DOS__
#include <dir.h>
struct time_b now;
struct time t;   // Pour fonction unixtodos
struct date d;   // Pour fonction unixtodos
#else
struct tm *p_tm;
time_t now;
char s[50];
#endif

int main(int argc,char *argv[])
//********************************************************************
// RETURN:  0  Ok
//          1  Mauvaise ligne de commande
//********************************************************************
{

// Exploite parametres
int noarg,help=((argc==1)?-1:0),invalide=0;
for (noarg=1;noarg<argc;noarg++) {
  if ((argv[noarg][0])=='/' || (argv[noarg][0])=='-') {
    switch (argv[noarg][1] | 0x20) {
      case '?':
	  case 'h': help=-1;break;
      default: invalide=-1;
      }
    }
  }

#ifdef __DOS__
	// Affiche en-tête
	if (help) {
		printf("----- %s V%s ©Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
		printf("Usage:  %s  \"Date_format\"\n\n",PROG);
		printf("DateTime is a small utility made for batch files. It just show current date and\n");
		printf("time but unlike TIME or DATE of the DOS, it doesn't wait you to type a new date\n");
		printf("or time to come back to the prompt.  This allow you to use it in Shell scripts.\n");
		printf("On the other hand, DateTime show milliseconds... This is very useful to measure\n");
		printf("performances in command files.\n");
		exit(0);
		}
	if (invalide) {
		printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
		printf("Error:  Bad command line\n");
		exit(1);
		}
	ftime(&now);
	unixtodos(now.time,&d,&t);
	printf("%02d/%02d/%02d  %02d:%02d:%02d %02d'''",d.da_day,d.da_mon,d.da_year,t.ti_hour,t.ti_min,t.ti_sec,now.millitm);
#else
	// Affiche en-tête
	if (help) {
		printf("----- %s V%s ©Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
		printf("Usage:  %s  \"Date_format\"\n\n",PROG);
		printf("Date_format is:\n");
		printf("%%a    abbreviated weekday name (Sun)\n");
		printf("%%A    full weekday name (Sunday)\n");
		printf("%%b    abbreviated month name (Dec)\n");
		printf("%%B    full month name (December)\n");
		printf("%%c    date and time (09/31/79 06:55:15)\n");
		printf("%%d    day of the month (02)\n");
		printf("%%H    hour of the 24-hour day (06)\n");
		printf("%%I    hour of the 12-hour day (06)\n");
		printf("%%j    day of the year, from 001 (335)\n");
		printf("%%m    month of the year, from 01 (12)\n");
		printf("%%M    minutes after the hour (55)\n");
		printf("%%p    AM/PM indicator (AM)\n");
		printf("%%S    seconds after the minute (15)\n");
		printf("%%U    Sunday week of the year, from 00 (48)\n");
		printf("%%w    day of the week, from 0 for Sunday to 6 for Saturday (0)\n");
		printf("%%W    Monday week of the year, from 00 (47)\n");
		printf("%%x    date (08/31/79)\n");
		printf("%%X    time (06:55:15)\n");
		printf("%%y    year of the century, from 00 (79)\n");
		printf("%%Y    year (1979)\n");
		printf("%%Z    time zone name, if any (EST)\n");
		printf("%%%%    percent character %%\n");
		exit(0);
		}
	if (invalide) {
		printf("----- %s V%s (c)Laurent Destailleur (ld@writeme.com) -----\n",PROG,VERSION);
		printf("Error:  Bad command line\n");
		exit(1);
		}
	time(&now);
	p_tm=localtime(&now);
	strftime(s,(size_t) s,argv[1],p_tm);
	printf("%s",s);
#endif

return(0);
}
