#include <stdio.h>
#include <windows.h>
#include <winnetwk.h>


char s[256];
DWORD dw;
int i;

void main(void)
{

strcpy(s,"a");
dw=WNetGetUser(NULL,(LPTSTR) s,(LPDWORD) sizeof(s));
switch (dw) {
	case ERROR_NOT_CONNECTED:
		i=1;
		break;
	case ERROR_MORE_DATA:
		i=2;
		break;
	case ERROR_NO_NETWORK:
		i=3;
		break;
	case ERROR_EXTENDED_ERROR:
		i=4;
		break;
	case ERROR_NO_NET_OR_BAD_PATH:
		i=5;
		break;
	case ERROR_INVALID_ADDRESS:
		i=6;
		break;
}




printf("%d - %s\n",i,s);

}


