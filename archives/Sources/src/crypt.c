//--------------------------------------------------------
// Cryptographic functions
//--------------------------------------------------------
// 11/11/99	1.0	Laurent Destailleur	Creation
//--------------------------------------------------------
// <<< All OS >>>
// base64_endecode
// base64_decode
// quoted_decode
//--------------------------------------------------------

#include <stdlib.h>
#include <string.h>
#include "crypt.h"



static char base64[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static int pos(char c)
//---------------------------------------------------------------------------
// Return pos of char c in base64 string
//---------------------------------------------------------------------------
{
  char *p;
  for(p = base64; *p; p++)
    if(*p == c)
      return p - base64;
  return -1;
}


int base64_encode(const void *data, int size, char **str)
//--------------------------------------------------------
// Input	: str to decode
// Output	: data
// Return	: size of new data
//--------------------------------------------------------
{
	char *s, *p;
	int i;
	int c;
	unsigned char *q;
	
	p = s = (char*) malloc(((size<<2)/3)+4);
	q = (unsigned char*) data;
	i=0;
	for (i = 0; i < size;) {
		c=q[i++];
		c<<=8;
		if (i < size)
		  	c+=q[i];
		i++;
		c<<=8;
		if (i < size)
		  	c+=q[i];
		i++;
		p[0]=base64[(c&0x00fc0000) >> 18];
		p[1]=base64[(c&0x0003f000) >> 12];
		p[2]=base64[(c&0x00000fc0) >> 6];
		p[3]=base64[(c&0x0000003f) >> 0];
		if (i > size)
		  	p[3]='=';
		if (i > size+1)
		  	p[2]='=';
		p+=4;
	}
	*p=0;
	*str = s;
	return strlen(s);
}


int base64_decode(const char *str, void *data)
//--------------------------------------------------------
// Input	: string to decode
// Output	: data
// Return	: size of new data
//--------------------------------------------------------
{
	const char *p;		// To point to str to decode
	unsigned char *q;	// To point to result data
	int c;
	int x;
	int done = 0;
	q=(unsigned char*)data;
	for (p=str; *p && !done; p+=4) {
		if ((p[0]=='\r') || (p[0]=='\n')) p++;
		if ((p[0]=='\r') || (p[0]=='\n')) p++;

		x = pos(p[0]);
		if (x >= 0)
		  	c = x;
		else {
		  	done = 3;
		  	break;
		}
		c<<=6;
		
		x = pos(p[1]);
		if (x >= 0)
		  	c += x;
		else
		  	return -1;
		c<<=6;
		
		if (p[2] == '=')
		  	done++;
		else {
		  	x = pos(p[2]);
		  	if(x >= 0)
				c += x;
		  	else
				return -1;
			}
		c<<=6;
		
		if(p[3] == '=')
		  	done++;
		else {
		  	if (done)
				return -1;
		  	x = pos(p[3]);
		  	if (x >= 0)
				c += x;
		  	else
				return -1;
			}
		if (done < 3)
		  *q++=(c&0x00ff0000)>>16;
		if (done < 2)
		  *q++=(c&0x0000ff00)>>8;
		if (done < 1)
		  *q++=(c&0x000000ff)>>0;
	}
	return (q - (unsigned char*) data);
}


int quoted_decode(const char *str, void *data)
//--------------------------------------------------------
// Input	: string to decode
// Output	: data
// Return	: size of new data
//--------------------------------------------------------
{
	const char *p;		// To point to str to decode
	char *q;			// To point to result data
	for (p=str,q=(char *) data; *p; p++) {
		if ((*q = *p) == '=') {
			// Found a new line (=\r\n) ?	
			if ((*(p+1)=='\r') && (*(p+2)=='\n')) {	*q=0;p+=2; continue; }
			// Found a coded char
		    *q = (*(p+1) >= 'A' ? ((*(p+1) & 0xDF) - 'A')+10 : (*(p+1) - '0'));
    		*q = *q << 4;
    		*q += (*(p+2) >= 'A' ? ((*(p+2) & 0xDF) - 'A')+10 : (*(p+2) - '0'));
			p+=2;
		}
		q++;
	}
	*q=0;
	return (q - (char *) data);
}

