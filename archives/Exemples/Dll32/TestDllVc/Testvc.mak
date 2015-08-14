# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

!IF "$(CFG)" == ""
CFG=Testvc - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to Testvc - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Testvc - Win32 Release" && "$(CFG)" != "Testvc - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Testvc.mak" CFG="Testvc - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Testvc - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Testvc - Win32 Debug" (based on "Win32 (x86) Application")
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
# PROP Target_Last_Scanned "Testvc - Win32 Debug"
RSC=rc.exe
MTL=mktyplib.exe
CPP=cl.exe

!IF  "$(CFG)" == "Testvc - Win32 Release"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\Testvc.exe"

CLEAN : 
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\Testvc.obj"
	-@erase "$(INTDIR)\Testvc.pch"
	-@erase "$(INTDIR)\Testvc.res"
	-@erase "$(INTDIR)\TestvcDlg.obj"
	-@erase "$(OUTDIR)\Testvc.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/Testvc.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/" /c\
 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x40c /d "NDEBUG" /d "_AFXDLL"
RSC_PROJ=/l 0x40c /fo"$(INTDIR)/Testvc.res" /d "NDEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Testvc.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 /nologo /subsystem:windows /machine:I386
LINK32_FLAGS=/nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)/Testvc.pdb" /machine:I386 /out:"$(OUTDIR)/Testvc.exe" 
LINK32_OBJS= \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\Testvc.obj" \
	"$(INTDIR)\Testvc.res" \
	"$(INTDIR)\TestvcDlg.obj"

"$(OUTDIR)\Testvc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Testvc - Win32 Debug"

# PROP BASE Use_MFC 6
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 6
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\Testvc.exe" "$(OUTDIR)\Testvc.bsc"

CLEAN : 
	-@erase "$(INTDIR)\StdAfx.obj"
	-@erase "$(INTDIR)\StdAfx.sbr"
	-@erase "$(INTDIR)\Testvc.obj"
	-@erase "$(INTDIR)\Testvc.pch"
	-@erase "$(INTDIR)\Testvc.res"
	-@erase "$(INTDIR)\Testvc.sbr"
	-@erase "$(INTDIR)\TestvcDlg.obj"
	-@erase "$(INTDIR)\TestvcDlg.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\Testvc.bsc"
	-@erase "$(OUTDIR)\Testvc.exe"
	-@erase "$(OUTDIR)\Testvc.ilk"
	-@erase "$(OUTDIR)\Testvc.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /FR /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_AFXDLL" /D "_MBCS" /FR"$(INTDIR)/" /Fp"$(INTDIR)/Testvc.pch" /Yu"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x40c /d "_DEBUG" /d "_AFXDLL"
RSC_PROJ=/l 0x40c /fo"$(INTDIR)/Testvc.res" /d "_DEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Testvc.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\StdAfx.sbr" \
	"$(INTDIR)\Testvc.sbr" \
	"$(INTDIR)\TestvcDlg.sbr"

"$(OUTDIR)\Testvc.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 /nologo /subsystem:windows /debug /machine:I386
LINK32_FLAGS=/nologo /subsystem:windows /incremental:yes\
 /pdb:"$(OUTDIR)/Testvc.pdb" /debug /machine:I386 /out:"$(OUTDIR)/Testvc.exe" 
LINK32_OBJS= \
	"$(INTDIR)\StdAfx.obj" \
	"$(INTDIR)\Testvc.obj" \
	"$(INTDIR)\Testvc.res" \
	"$(INTDIR)\TestvcDlg.obj"

"$(OUTDIR)\Testvc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "Testvc - Win32 Release"
# Name "Testvc - Win32 Debug"

!IF  "$(CFG)" == "Testvc - Win32 Release"

!ELSEIF  "$(CFG)" == "Testvc - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Testvc.cpp
DEP_CPP_TESTV=\
	".\StdAfx.h"\
	".\Testvc.h"\
	".\TestvcDlg.h"\
	

!IF  "$(CFG)" == "Testvc - Win32 Release"


"$(INTDIR)\Testvc.obj" : $(SOURCE) $(DEP_CPP_TESTV) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"


!ELSEIF  "$(CFG)" == "Testvc - Win32 Debug"


"$(INTDIR)\Testvc.obj" : $(SOURCE) $(DEP_CPP_TESTV) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"

"$(INTDIR)\Testvc.sbr" : $(SOURCE) $(DEP_CPP_TESTV) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\TestvcDlg.cpp
DEP_CPP_TESTVC=\
	".\StdAfx.h"\
	".\Testvc.h"\
	".\TestvcDlg.h"\
	

!IF  "$(CFG)" == "Testvc - Win32 Release"


"$(INTDIR)\TestvcDlg.obj" : $(SOURCE) $(DEP_CPP_TESTVC) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"


!ELSEIF  "$(CFG)" == "Testvc - Win32 Debug"


"$(INTDIR)\TestvcDlg.obj" : $(SOURCE) $(DEP_CPP_TESTVC) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"

"$(INTDIR)\TestvcDlg.sbr" : $(SOURCE) $(DEP_CPP_TESTVC) "$(INTDIR)"\
 "$(INTDIR)\Testvc.pch"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\StdAfx.cpp
DEP_CPP_STDAF=\
	".\StdAfx.h"\
	

!IF  "$(CFG)" == "Testvc - Win32 Release"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/Testvc.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/" /c\
 $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Testvc.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "Testvc - Win32 Debug"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_AFXDLL" /D "_MBCS" /FR"$(INTDIR)/" /Fp"$(INTDIR)/Testvc.pch" /Yc"stdafx.h"\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\StdAfx.sbr" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\Testvc.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\Testvc.rc
DEP_RSC_TESTVC_=\
	".\res\Testvc.ico"\
	".\res\Testvc.rc2"\
	

"$(INTDIR)\Testvc.res" : $(SOURCE) $(DEP_RSC_TESTVC_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################
