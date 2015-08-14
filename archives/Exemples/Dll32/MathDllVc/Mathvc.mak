# Microsoft Developer Studio Generated NMAKE File, Format Version 40001
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=Mathvc - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to Mathvc - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Mathvc - Win32 Release" && "$(CFG)" != "Mathvc - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Mathvc.mak" CFG="Mathvc - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Mathvc - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "Mathvc - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "Mathvc - Win32 Debug"
MTL=mktyplib.exe
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Mathvc - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\Mathvc.dll"

CLEAN : 
	-@erase ".\Release\Mathvc.dll"
	-@erase ".\Release\Mathvc.obj"
	-@erase ".\Mathvc.res"
	-@erase ".\Release\Mathvc.lib"
	-@erase ".\Release\Mathvc.exp"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/Mathvc.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /fo"Mathvc.res" /d "NDEBUG"
RSC_PROJ=/l 0x40c /fo"Mathvc.res" /d "NDEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Mathvc.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:windows /dll /incremental:no\
 /pdb:"$(OUTDIR)/Mathvc.pdb" /machine:I386 /def:".\Mathvc.def"\
 /out:"$(OUTDIR)/Mathvc.dll" /implib:"$(OUTDIR)/Mathvc.lib" 
DEF_FILE= \
	".\Mathvc.def"
LINK32_OBJS= \
	"$(INTDIR)/Mathvc.obj" \
	".\Mathvc.res"

"$(OUTDIR)\Mathvc.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Mathvc - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\Mathvc.dll"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\Mathvc.dll"
	-@erase ".\Debug\Mathvc.obj"
	-@erase ".\Mathvc.res"
	-@erase ".\Debug\Mathvc.ilk"
	-@erase ".\Debug\Mathvc.lib"
	-@erase ".\Debug\Mathvc.exp"
	-@erase ".\Debug\Mathvc.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/Mathvc.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /fo"Mathvc.res" /d "_DEBUG"
RSC_PROJ=/l 0x40c /fo"Mathvc.res" /d "_DEBUG" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Mathvc.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:windows /dll /incremental:yes\
 /pdb:"$(OUTDIR)/Mathvc.pdb" /debug /machine:I386 /def:".\Mathvc.def"\
 /out:"$(OUTDIR)/Mathvc.dll" /implib:"$(OUTDIR)/Mathvc.lib" 
DEF_FILE= \
	".\Mathvc.def"
LINK32_OBJS= \
	"$(INTDIR)/Mathvc.obj" \
	".\Mathvc.res"

"$(OUTDIR)\Mathvc.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "Mathvc - Win32 Release"
# Name "Mathvc - Win32 Debug"

!IF  "$(CFG)" == "Mathvc - Win32 Release"

!ELSEIF  "$(CFG)" == "Mathvc - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Mathvc.cpp

"$(INTDIR)\Mathvc.obj" : $(SOURCE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\Mathvc.def

!IF  "$(CFG)" == "Mathvc - Win32 Release"

!ELSEIF  "$(CFG)" == "Mathvc - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Mathvc.rc

"$(INTDIR)\Mathvc.res" : $(SOURCE) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################
