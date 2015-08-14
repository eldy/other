#ifndef __HARDWARE_H
#define __HARDWARE_H

#ifdef __cplusplus
extern "C" {  // only need to export C interface if used by C++ source code
#endif

#ifdef __MSDOS__
int DRIVE_STATUS(char drive);
int DRIVE_STATUS_AMOVIBLE(char drive);
void WARMBOOT(void);
void COLDBOOT(void);
int WindowsVersion(int * HVersion,int * NVersion);
#else
#ifdef _WIN32
int WindowsVersion(int * HVersion,int * NVersion);
#endif
#endif

      
void FULLPATH(char *chaine);
int DIREXIST(char *path);
int FILEEXIST(char *fichier);
int MAKEDIR(char *directory);
int COPYFILE(char *source,char *destination);

#ifdef __cplusplus
}
#endif

#endif  /* Fin __HARDWARE_H */
