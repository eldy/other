#-------------------------------------------------------------------#
# Makefile
#-------------------------------------------------------------------#
#       1.0     Laurent Destailleur     Creation 
#       1.1     Works with VC++ and gcc, Windows and Unix
#-------------------------------------------------------------------#


# Project options
#-----------------

# "GCC" to use GNU C++ compiler, "VC" to use Microsoft Visual C+
COMP=GCC
DEBUG=1                 # DEBUG=1 for debug

# Directories
SRCDIR  = ./
RUNDIR  = ../run/
INCDIR  = ../include/
LIBDIR  = ../lib/
INCLUDES= -I$(INCDIR) -I../include -I/mnt/d/sources/include -Id:/sources/include
#LIBS   = -L$(LIBDIR) -L../lib

# Program files to build        (Ex: $(RUNDIR)prog)
PROGRAM = 

# Object files to build         (Ex: $(LIBDIR)yyy.o $(LIBDIR)zzz.o ...)
OBJLIST = $(LIBDIR)hardware.o$(BJ) $(LIBDIR)CLogMsg.o$(BJ) $(LIBDIR)crypt.o$(BJ) $(LIBDIR)misc.o$(BJ) $(LIBDIR)ansi.o$(BJ) $(LIBDIR)maths.o$(BJ) $(LIBDIR)compress.o$(BJ)

# Archive file for o files      (Ex: $(LIBDIR)libxxx.a)
ARCHIVE = $(LIBDIR)libperso.a


# Compiler options
#-----------------
# Compilation par gcc
ifeq "$(COMP)" "GCC"
CC              = gcc
CPP             = g++
RSC             = g++
AR              = ar r
COPTIONS= -Wall -g
#COPTIONS= -O3 -m486
ifeq "$(OS)" "Windows_NT"
LOPTIONS=-m486 -lwsock32
else
LOPTIONS=-m486
endif
OUT=-o
endif

# Compilation par vc
ifeq "$(COMP)" "VC"
CC              = cl.exe
CPP             = cl.exe
RSC             = rc.exe
AR              = ar r
COPTIONS= /nologo /ML /W3 /O2 /Yd /D "DEBUG" /D "_CONSOLE" /c
#COPTIONS= /nologo /G4 /D "NDEBUG" /D "_CONSOLE" /c
LOPTIONS= /nologo kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib wsock32.lib
BJ              = bj
OUT=/Fo
endif



# New rules
#-----------------
ifeq "$(OS)" "Windows_NT"
RM              = rm -f
CFLAGS  = $(COPTIONS) $(INCLUDES)
else
RM              = rm -f
CFLAGS  = $(COPTIONS) $(INCLUDES)
endif
LDFLAGS = $(LOPTIONS) $(LIBS)


$(LIBDIR)%.o: %.cpp
	@echo ----- Compilation C++ par $(COMP) - $@
	$(CPP) -c $(CFLAGS) $(SRCDIR)$< $(OUT)$@
	@echo ----- Archivage en $(ARCHIVE)
	$(AR) $(ARCHIVE) $@

$(LIBDIR)%.obj: %.cpp
	@echo ----- Compilation C++ par $(COMP) - $@
	$(CPP) -c $(CFLAGS) $(SRCDIR)$< $(OUT)$@
	@echo ----- Archivage en $(ARCHIVE)
	$(AR) $(ARCHIVE) $@
 
$(LIBDIR)%.o: %.c
	@echo ----- Compilation C   par $(COMP) - $@
	$(CC) -c $(CFLAGS) $(SRCDIR)$< $(OUT)$@
	@echo ----- Archivage en $(ARCHIVE)
	$(AR) $(ARCHIVE) $@

$(LIBDIR)%.obj: %.c
	@echo ----- Compilation C   par $(COMP) - $@
	$(CC) -c $(CFLAGS) $(SRCDIR)$< $(OUT)$@
	@echo ----- Archivage en $(ARCHIVE)
	$(AR) $(ARCHIVE) $@



# Targets
#-----------------

# Default target
all:    $(OBJLIST)
	

# Program (if PROGRAM is just one exe)
$(PROGRAM): $(OBJLIST)
	@echo ----- Link - $@
	rm -f $(RUNDIR)$@
	$(CC) -o $(RUNDIR)$@ $(OBJLIST) $(LDFLAGS) $(ARCHIVE)

# Program (if PROGRAM are several exe)
#$(PROGRAM): $(OBJLIST)
#       @echo ----- Link - $@
#       rm -f $(RUNDIR)$@
#       $(CC) -o $(RUNDIR)$@ $(LIBDIR)$@.o$(BJ) $(LDFLAGS) $(ARCHIVE)

# Clean
clean:
	@echo ----- Clean
	$(RM) $(LIBDIR)*.a $(LIBDIR)*.o $(LIBDIR)*.obj $(RUNDIR)core $(OBJLIST)


# Dependencies $(LIBDIR)xxx.o: $(SRCDIR)xxx.c $(INCDIR)xxx1.h $(INCDIR)xxx2.h

