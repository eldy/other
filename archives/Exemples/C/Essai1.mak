# Microsoft Developer Studio Generated NMAKE File, Based on Essai1.dsp
!IF "$(CFG)" == ""
CFG=Essai1 - Win32 Debug
!MESSAGE No configuration specified. Defaulting to Essai1 - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Essai1 - Win32 Release" && "$(CFG)" != "Essai1 - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Essai1.mak" CFG="Essai1 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Essai1 - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Essai1 - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 

CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Essai1 - Win32 Release"

OUTDIR=.\Release
INTDIR=.\Release
# Begin Custom Macros
OutDir=.\Release
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\Essai1.exe"

!ELSE 

ALL : "$(OUTDIR)\Essai1.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\Essai1.obj"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(OUTDIR)\Essai1.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D\
 "_MBCS" /Fp"$(INTDIR)\Essai1.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD /c 
CPP_OBJS=.\Release/
CPP_SBRS=.
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Essai1.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)\Essai1.pdb" /machine:I386 /out:"$(OUTDIR)\Essai1.exe" 
LINK32_OBJS= \
	"$(INTDIR)\Essai1.obj"

"$(OUTDIR)\Essai1.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Essai1 - Win32 Debug"

OUTDIR=.\Debug
INTDIR=.\Debug
# Begin Custom Macros
OutDir=.\Debug
# End Custom Macros

!IF "$(RECURSE)" == "0" 

ALL : "$(OUTDIR)\Essai1.exe"

!ELSE 

ALL : "$(OUTDIR)\Essai1.exe"

!ENDIF 

CLEAN :
	-@erase "$(INTDIR)\Essai1.obj"
	-@erase "$(INTDIR)\vc50.idb"
	-@erase "$(INTDIR)\vc50.pdb"
	-@erase "$(OUTDIR)\Essai1.exe"
	-@erase "$(OUTDIR)\Essai1.ilk"
	-@erase "$(OUTDIR)\Essai1.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

CPP_PROJ=/nologo /MLd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE"\
 /D "_MBCS" /Fp"$(INTDIR)\Essai1.pch" /YX /Fo"$(INTDIR)\\" /Fd"$(INTDIR)\\" /FD\
 /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.
BSC32=bscmake.exe
BSC32_FLAGS=/nologo /o"$(OUTDIR)\Essai1.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)\Essai1.pdb" /debug /machine:I386 /out:"$(OUTDIR)\Essai1.exe"\
 /pdbtype:sept 
LINK32_OBJS= \
	"$(INTDIR)\Essai1.obj"

"$(OUTDIR)\Essai1.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_OBJS)}.obj::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.c{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cpp{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<

.cxx{$(CPP_SBRS)}.sbr::
   $(CPP) @<<
   $(CPP_PROJ) $< 
<<


!IF "$(CFG)" == "Essai1 - Win32 Release" || "$(CFG)" == "Essai1 - Win32 Debug"
SOURCE=.\Essai1.c

"$(INTDIR)\Essai1.obj" : $(SOURCE) "$(INTDIR)"



!ENDIF 

