/*Essai2*/
#define __DOS__

#include <dos.h>
#include <conio.h>
#include <string.h>
#include "hardware.h"
#include "config.h"
#include "video.h"


int i,k,l;
char c;

void main(void)
{
clrscr();
k=5;
i=ISWINDOWS(&k,&l);
printf("%i\n",i);
printf("%i\n",k);
printf("%i\n",l);
}