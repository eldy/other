@echo off
echo Test Invisibilit‚ virus dans r‚pertoire courant aux Anti-Virus
echo --------------------------------------------------------------
smartdrv /C
if "%1"=="" goto erreur
if "%1"=="fp" goto fp
if "%1"=="f" goto fp
if "%1"=="avp" goto avp
if "%1"=="a" goto avp
c:\virus\tbav\tbscan . batch nomem nosub
goto fin
:fp
c:\virus\fprot\f-prot . /command /file /analyse /nomem /nosub
goto fin
:avp
c:\virus\avp\avp . /Y /Q /T
goto fin
:erreur
echo Syntaxe: test  tbav  fp  avp  
:fin
echo.
