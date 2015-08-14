# Microsoft Developer Studio Generated NMAKE File, Format Version 40001
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

!IF "$(CFG)" == ""
CFG=TestVc - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to TestVc - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "TestVc - Win32 Release" && "$(CFG)" != "TestVc - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "TestVc.mak" CFG="TestVc - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "TestVc - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "TestVc - Win32 Debug" (based on "Win32 (x86) Application")
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
# PROP Target_Last_Scanned "TestVc - Win32 Debug"
RSC=rc.exe
MTL=mktyplib.exe
CPP=cl.exe

!IF  "$(CFG)" == "TestVc - Win32 Release"

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

ALL : "$(OUTDIR)\TestVc.exe"

CLEAN : 
	-@erase ".\Release\TestVc.exe"
	-@erase ".\Release\StdAfx.obj"
	-@erase ".\Release\TestVc.obj"
	-@erase ".\Release\TestVc.pch"
	-@erase ".\Release\TestVcDlg.obj"
	-@erase ".\Release\TestVc.res"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/TestVc.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/" /c\
 
CPP_OBJS=.\Release/
CPP_SBRS=
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "NDEBUG" /d "_AFXDLL"
# ADD RSC /l 0x40c /d "NDEBUG" /d "_AFXDLL"
RSC_PROJ=/l 0x40c /fo"$(INTDIR)/TestVc.res" /d "NDEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/TestVc.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /machine:I386
# ADD LINK32 /nologo /subsystem:windows /machine:I386
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=/nologo /subsystem:windows /incremental:no\
 /pdb:"$(OUTDIR)/TestVc.pdb" /machine:I386 /out:"$(OUTDIR)/TestVc.exe" 
LINK32_OBJS= \
	"$(INTDIR)/StdAfx.obj" \
	"$(INTDIR)/TestVc.obj" \
	"$(INTDIR)/TestVcDlg.obj" \
	"$(INTDIR)/TestVc.res" \
	"..\MathVc\Debug\Mathvc.lib"

"$(OUTDIR)\TestVc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "TestVc - Win32 Debug"

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

ALL : "$(OUTDIR)\TestVc.exe"

CLEAN : 
	-@erase ".\Debug\vc40.pdb"
	-@erase ".\Debug\TestVc.pch"
	-@erase ".\Debug\vc40.idb"
	-@erase ".\Debug\TestVc.exe"
	-@erase ".\Debug\TestVc.obj"
	-@erase ".\Debug\TestVcDlg.obj"
	-@erase ".\Debug\StdAfx.obj"
	-@erase ".\Debug\TestVc.res"
	-@erase ".\Debug\TestVc.ilk"
	-@erase ".\Debug\TestVc.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_AFXDLL" /D "_MBCS" /Yu"stdafx.h" /c
CPP_PROJ=/nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/TestVc.pch" /Yu"stdafx.h" /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x40c /d "_DEBUG" /d "_AFXDLL"
# ADD RSC /l 0x40c /d "_DEBUG" /d "_AFXDLL"
RSC_PROJ=/l 0x40c /fo"$(INTDIR)/TestVc.res" /d "_DEBUG" /d "_AFXDLL" 
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/TestVc.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 /nologo /subsystem:windows /debug /machine:I386
# ADD LINK32 /nologo /subsystem:windows /debug /machine:I386
# SUBTRACT LINK32 /nodefaultlib
LINK32_FLAGS=/nologo /subsystem:windows /incremental:yes\
 /pdb:"$(OUTDIR)/TestVc.pdb" /debug /machine:I386 /out:"$(OUTDIR)/TestVc.exe" 
LINK32_OBJS= \
	"$(INTDIR)/TestVc.obj" \
	"$(INTDIR)/TestVcDlg.obj" \
	"$(INTDIR)/StdAfx.obj" \
	"$(INTDIR)/TestVc.res" \
	"..\MathVc\Debug\Mathvc.lib"

"$(OUTDIR)\TestVc.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "TestVc - Win32 Release"
# Name "TestVc - Win32 Debug"

!IF  "$(CFG)" == "TestVc - Win32 Release"

!ELSEIF  "$(CFG)" == "TestVc - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\TestVc.cpp
DEP_CPP_TESTV=\
	".\StdAfx.h"\
	".\TestVc.h"\
	".\TestVcDlg.h"\
	".\..\MathVc\Mathvc.h"\
	

"$(INTDIR)\TestVc.obj" : $(SOURCE) $(DEP_CPP_TESTV) "$(INTDIR)"\
 "$(INTDIR)\TestVc.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\TestVcDlg.cpp
DEP_CPP_TESTVC=\
	".\StdAfx.h"\
	".\TestVc.h"\
	".\TestVcDlg.h"\
	".\..\MathVc\Mathvc.h"\
	

"$(INTDIR)\TestVcDlg.obj" : $(SOURCE) $(DEP_CPP_TESTVC) "$(INTDIR)"\
 "$(INTDIR)\TestVc.pch"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\StdAfx.cpp
DEP_CPP_STDAF=\
	".\StdAfx.h"\
	

!IF  "$(CFG)" == "TestVc - Win32 Release"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MD /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /D\
 "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/TestVc.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/" /c\
 $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\TestVc.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ELSEIF  "$(CFG)" == "TestVc - Win32 Debug"

# ADD CPP /Yc"stdafx.h"

BuildCmds= \
	$(CPP) /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS"\
 /D "_AFXDLL" /D "_MBCS" /Fp"$(INTDIR)/TestVc.pch" /Yc"stdafx.h" /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c $(SOURCE) \
	

"$(INTDIR)\StdAfx.obj" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\TestVc.pch" : $(SOURCE) $(DEP_CPP_STDAF) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\TestVc.rc
DEP_RSC_TESTVC_=\
	".\res\TestVc.ico"\
	".\res\TestVc.rc2"\
	

"$(INTDIR)\TestVc.res" : $(SOURCE) $(DEP_RSC_TESTVC_) "$(INTDIR)"
   $(RSC) $(RSC_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=\Prog\Dll\MathVc\Debug\Mathvc.lib

!IF  "$(CFG)" == "TestVc - Win32 Release"

!ELSEIF  "$(CFG)" == "TestVc - Win32 Debug"

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################
