# Microsoft Developer Studio Generated NMAKE File, Format Version 40001
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=Genloto - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to Genloto - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "Loto - Win32 Release" && "$(CFG)" != "Loto - Win32 Debug" &&\
 "$(CFG)" != "Genloto - Win32 Release" && "$(CFG)" != "Genloto - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "Loto.mak" CFG="Genloto - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Loto - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Loto - Win32 Debug" (based on "Win32 (x86) Console Application")
!MESSAGE "Genloto - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "Genloto - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "Loto - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Loto - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Loto\Release"
# PROP Intermediate_Dir "Loto\Release"
OUTDIR=.\Loto\Release
INTDIR=.\Loto\Release

ALL : "$(OUTDIR)\Loto.exe"

CLEAN : 
	-@erase ".\Loto\Release\Loto.exe"
	-@erase ".\Loto\Release\Loto.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/Loto.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Loto\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Loto.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/Loto.pdb" /machine:I386 /out:"$(OUTDIR)/Loto.exe" 
LINK32_OBJS= \
	"$(INTDIR)/Loto.obj"

"$(OUTDIR)\Loto.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Loto - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Loto\Debug"
# PROP Intermediate_Dir "Loto\Debug"
OUTDIR=.\Loto\Debug
INTDIR=.\Loto\Debug

ALL : "$(OUTDIR)\Loto.exe"

CLEAN : 
	-@erase ".\Loto\Debug\Loto.exe"
	-@erase ".\Loto\Debug\Loto.obj"
	-@erase ".\Loto\Debug\Loto.ilk"
	-@erase ".\Loto\Debug\Loto.pdb"
	-@erase ".\Loto\Debug\vc40.pdb"
	-@erase ".\Loto\Debug\vc40.idb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/Loto.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Loto\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Loto.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/Loto.pdb" /debug /machine:I386 /out:"$(OUTDIR)/Loto.exe" 
LINK32_OBJS= \
	"$(INTDIR)/Loto.obj"

"$(OUTDIR)\Loto.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Genloto - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Genloto\Release"
# PROP BASE Intermediate_Dir "Genloto\Release"
# PROP BASE Target_Dir "Genloto"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Genloto\Release"
# PROP Intermediate_Dir "Genloto\Release"
# PROP Target_Dir "Genloto"
OUTDIR=.\Genloto\Release
INTDIR=.\Genloto\Release

ALL : "$(OUTDIR)\Genloto.exe"

CLEAN : 
	-@erase ".\Genloto\Release\Genloto.exe"
	-@erase ".\Genloto\Release\Genloto.obj"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/Genloto.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Genloto\Release/
CPP_SBRS=
# ADD BASE RSC /l 0x40c /d "NDEBUG"
# ADD RSC /l 0x40c /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Genloto.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/Genloto.pdb" /machine:I386 /out:"$(OUTDIR)/Genloto.exe" 
LINK32_OBJS= \
	"$(INTDIR)/Genloto.obj"

"$(OUTDIR)\Genloto.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "Genloto - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Genloto\Debug"
# PROP BASE Intermediate_Dir "Genloto\Debug"
# PROP BASE Target_Dir "Genloto"
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Genloto\Debug"
# PROP Intermediate_Dir "Genloto\Debug"
# PROP Target_Dir "Genloto"
OUTDIR=.\Genloto\Debug
INTDIR=.\Genloto\Debug

ALL : "$(OUTDIR)\Genloto.exe"

CLEAN : 
	-@erase ".\Genloto\Debug\vc40.pdb"
	-@erase ".\Genloto\Debug\vc40.idb"
	-@erase ".\Genloto\Debug\Genloto.exe"
	-@erase ".\Genloto\Debug\Genloto.obj"
	-@erase ".\Genloto\Debug\Genloto.ilk"
	-@erase ".\Genloto\Debug\Genloto.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MLd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE"\
 /Fp"$(INTDIR)/Genloto.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Genloto\Debug/
CPP_SBRS=
# ADD BASE RSC /l 0x40c /d "_DEBUG"
# ADD RSC /l 0x40c /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/Genloto.bsc" 
BSC32_SBRS=
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/Genloto.pdb" /debug /machine:I386 /out:"$(OUTDIR)/Genloto.exe" 
LINK32_OBJS= \
	"$(INTDIR)/Genloto.obj"

"$(OUTDIR)\Genloto.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "Loto - Win32 Release"
# Name "Loto - Win32 Debug"

!IF  "$(CFG)" == "Loto - Win32 Release"

!ELSEIF  "$(CFG)" == "Loto - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Loto.cpp

!IF  "$(CFG)" == "Loto - Win32 Release"


"$(INTDIR)\Loto.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "Loto - Win32 Debug"


"$(INTDIR)\Loto.obj" : $(SOURCE) "$(INTDIR)"


!ENDIF 

# End Source File
# End Target
################################################################################
# Begin Target

# Name "Genloto - Win32 Release"
# Name "Genloto - Win32 Debug"

!IF  "$(CFG)" == "Genloto - Win32 Release"

!ELSEIF  "$(CFG)" == "Genloto - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\Genloto.cpp

"$(INTDIR)\Genloto.obj" : $(SOURCE) "$(INTDIR)"


# End Source File
# End Target
# End Project
################################################################################
