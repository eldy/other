/********************************************************************/
/*                                                                  */
/*                 Hooker, trojan module v2.x                       */
/*                          ACrazzi, 1999                           */
/*                                                                  */
/********************************************************************/

#ifndef LOGFUNC_H_
#define LOGFUNC_H_

#ifndef HOOKER_H_
#include "hooker.h"
#endif

void LogInit(void);
void LogAdd(char*);
void LogFlush(void);
void LogEmailing(SYSTEMTIME&,bool&);
void HttpDownloading(SYSTEMTIME&,bool&);

#endif