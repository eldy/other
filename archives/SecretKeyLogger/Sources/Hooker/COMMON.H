/********************************************************************/
/*                                                                  */
/*                   Hooker, trojan module v2.x                     */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/
#ifndef COMMON_H_
#define COMMON_H_

#ifndef HOOKER_H_ 
#include "hooker.h"
#endif

#include "ras.h"

extern const char *Product,*Months[12],*Days[7];
extern _StartupInfo sti;
extern CRITICAL_SECTION gcs;
extern LPRASENUMCCONNECTIONS RasEnumConnections;
extern LPRASGETCONNECTSTATUS RasGetConnectStatus;
extern LPRASGETENTRYPROPERTIES RasGetEntryProperties;
extern LPRASGETPROJECTIONINFO RasGetProjectionInfo;
extern bool bRASDLL;

void SysTimePrint(char*, SYSTEMTIME&);
int SysTimeComp(SYSTEMTIME&,SYSTEMTIME&);
void SysTimeSum(SYSTEMTIME&,SYSTEMTIME);

#ifdef _DEBUG

void ShowMessage(char*);

#endif

#endif