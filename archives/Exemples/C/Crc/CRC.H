/**********************************************************************/
/* CRC 16 bits                                                        */
/*                                                                    */
/* Calcule le CRC d'un fichier:                                       */
/*                                                                    */
/* Fonction InitCRC() pour initialiser les variables                  */
/* Fonction nouveau CRC = UpdateCRC(Ancien CRC, octet suppl‚mentaire) */
/*                        ancien CRC vaut 0 si 1er octet              */
/**********************************************************************/


#ifndef _CRC__C
#define _CRC__C

#include <stdio.h>
#define POLY 0x1021


void InitCRC(void);
unsigned short CalcTable(unsigned short,unsigned short,unsigned short);
unsigned short UpdateCRC(unsigned short,unsigned char);
static unsigned short CRCtable[256];

void InitCRC(void)
/* initialize CRC table */
{int i;
 for(i=0;i<256;i++) CRCtable[i] = CalcTable(i,POLY,0);
}

unsigned short CalcTable(unsigned short data, unsigned short genpoly, unsigned short accum)
/* calculate CRC table entry */
{static int i;
 data <<= 8;
 for(i=8;i>0;i--)
	 {
	  if((data^accum) & 0x8000) accum = (accum << 1) ^ genpoly;
	  else accum <<= 1;
	  data <<= 1;
	 }
 return(accum);
}


unsigned short UpdateCRC(unsigned short crc, unsigned char byte)
/* compute updated CRC */
{
 return( (crc << 8) ^ CRCtable[ (crc >> 8) ^ byte ] );
}


#endif
