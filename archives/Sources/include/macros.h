//--------------------------------------------------------------------
// Macros functions library
//--------------------------------------------------------------------
// 30/10/98		3.0		Laurent Destailleur		Creation
//--------------------------------------------------------------------
// Si compil pour Dos     (16 bits, Console)             __MSDOS__
// Si compil pour Console (16 ou 32 bits, Console)       _CONSOLE
// Si compil pour Windows (16 ou 32 bits, Windows)       _Windows
// Si compil pour WIN32   (32 bits, Console ou Windows)	 _WIN32
// Si compil DLL                                         _DLL
// Si compil C++                                         __cplusplus
// Si compil DEBUG                                       _DEBUG
//
// Si compil par GNU C++                                 __GNUC__
// Si compil par VC++                                    _MSC_VER
// Si compil par Borland C++                             __BORLANDC__
//--------------------------------------------------------------------
#ifndef __MACROS_H
#define __MACROS_H


/* Definition de constantes pour acces directories */
#define OPTION "/"
#define SEPARATEUR '\\'
#ifdef __MSDOS__
// DOS
#include <dir.h>
#else
#define MAXPATH 256
#define MAXDIR 256
#define MAXDRIVE 3
#define MAXFILE 256
#define MAXEXT 256
#endif

#ifndef __MSDOS__
#ifndef _Windows
#ifndef _WIN32
// Unix
#undef OPTION
#define OPTION "-"
#undef SEPARATEUR
#define SEPARATEUR '/'
#define O_BINARY 0
#define MAX_PATH 256
#endif
#endif
#endif

/* Definition de types universels */
#ifndef _Windows
#ifndef BYTE
#define BYTE unsigned char
#endif
#ifndef WORD
#define WORD unsigned int
#endif
#ifndef DWORD
#define DWORD unsigned long
#endif
#ifndef BOOL
#define BOOL signed char
#endif
#undef TRUE
#define TRUE -1
#undef FALSE
#define FALSE 0
#endif

#ifndef max
#define max(a,b)               ((a)<(b) ? (b) : (a))
#endif
#ifndef min
#define min(a,b)               ((a)>(b) ? (b) : (a))
#endif
#ifndef abs
#define abs(x)                 ((x)>=0 ? (x) : -(x))
#endif


#endif /* End __MACRO_H */
