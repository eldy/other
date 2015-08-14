@echo off

echo.
echo COMPILATION 32Bits
make

echo.
echo COMPILATION 16Bits Small
make -C c:\langages\bc\bin -f d:\developpement\utilkit\Makefile16
cp c:\langages\bc\bin\DELETE.EXE d:\developpement\utilkit\Delete.exe 2>NUL
cp c:\langages\bc\bin\CRACKZIP.EXE d:\developpement\utilkit\Crackzip.exe 2>NUL
cp c:\langages\bc\bin\CLEAR.EXE d:\developpement\utilkit\Clear.exe 2>NUL
cp c:\langages\bc\bin\DISKINFO.EXE d:\developpement\utilkit\DiskInfo.exe 2>NUL
cp c:\langages\bc\bin\TURBODSK.EXE d:\developpement\utilkit\TurboDsk.exe 2>NUL
cp c:\langages\bc\bin\D.EXE d:\developpement\utilkit\D.exe 2>NUL
cp c:\langages\bc\bin\UPDATE.EXE d:\developpement\utilkit\Update.exe 2>NUL
cp c:\langages\bc\bin\BOOT.EXE d:\developpement\utilkit\Boot.exe 2>NUL
cp c:\langages\bc\bin\PRINT2.EXE d:\developpement\utilkit\Print2.exe 2>NUL
cp c:\langages\bc\bin\BAT2CSH.EXE d:\developpement\utilkit\Bat2csh.exe 2>NUL
del c:\langages\bc\bin\DELETE.* 2>NUL
del c:\langages\bc\bin\CRACKZIP.* 2>NUL
del c:\langages\bc\bin\CLEAR.* 2>NUL
del c:\langages\bc\bin\DISKINFO.* 2>NUL
del c:\langages\bc\bin\TURBODSK.* 2>NUL
del c:\langages\bc\bin\D.* 2>NUL
del c:\langages\bc\bin\UPDATE.* 2>NUL
del c:\langages\bc\bin\BOOT.* 2>NUL
del c:\langages\bc\bin\PRINT2.* 2>NUL
del c:\langages\bc\bin\BAT2CSH.* 2>NUL

echo.
