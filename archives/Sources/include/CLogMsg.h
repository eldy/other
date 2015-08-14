#ifndef __LOGMSG_H
#define __LOGMSG_H

#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif

#include "macros.h"


class CLogMsg
{
public:
	CLogMsg(char *nomfichier);              // Constructor
	void Reset(void);
	void Write(int Level,const char *msg);
	void Write(int Level,const char *msg,const char *value);
	void Write(int Level,const char value);
	void Write(int Level,const char *msg,long int value);
	~CLogMsg();                             // Destructor
	int ErrorLevel;
private:
	int ErrorLevelBE;
	char logfile[MAXPATH];
};


#ifdef __cplusplus
}
#endif

#endif /* End __LOGMSG_H */

