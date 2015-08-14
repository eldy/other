#ifndef __MISC_H
#define __MISC_H


#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif


unsigned char Hex2Dec(unsigned char c);
unsigned char Hex2Byte(char *s);
void Byte2Hex(unsigned char b,char *s);
int IsDigits(char *s);
char * StrStr(const char * string1, const char * string2);
char * strupr(char * string1);
char * strlwr(char * string2);
int stricmp(const char * string1, const char * string2);
int strnicmp(const char * string1, const char * string2, size_t n);


#ifdef _Windows
#include <windows.h>
// Windows
void CenterWindow(HWND fenetre1,HWND fenetre2);
void Delay(WORD delai);
void Rect3D(HDC hdc,HPEN hpen1,HPEN hpen2,int x1,int y1,int x2,int y2);
#endif


#ifdef _WIN32
#include <windows.h>
#endif
#ifndef _Windows
#ifndef _WIN32

int GetPrivateProfileInt(const char *topic,const char *entry,const int default_value,const char *filename);
void GetPrivateProfileString(const char *topic,const char *entry,const char *default_string,char *buf,int length,char *filename);

#endif
#endif


#ifdef __cplusplus
}
#endif


#endif /* End __MISC_H */

