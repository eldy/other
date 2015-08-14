/********************************************************************/
/*                                                                  */
/*                   Hooker, trojan module v2.x                     */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#ifndef MY_RAS_
#define MY_RAS_

#include <ras.h>

#undef RasEnumConnections
#undef RasGetConnectStatus
#undef RasGetEntryProperties
#undef RasGetProjectionInfo

typedef DWORD (WINAPI *LPRASENUMCCONNECTIONS)(LPRASCONN,LPDWORD,LPDWORD);
typedef DWORD (WINAPI *LPRASGETCONNECTSTATUS)(HRASCONN,LPRASCONNSTATUS);
typedef DWORD (WINAPI *LPRASGETENTRYPROPERTIES)(LPTSTR,LPTSTR,LPRASENTRY,LPDWORD,LPBYTE,LPDWORD);
typedef DWORD (WINAPI *LPRASGETPROJECTIONINFO)(HRASCONN,RASPROJECTION,LPVOID,LPDWORD); 

#endif