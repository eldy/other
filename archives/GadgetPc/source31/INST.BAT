@echo off
echo.
echo Installation de GadgetPC
echo ------------------------
if "%1"=="" goto erreur
if %1==a: goto inst
if %1==b: goto inst
if %1==c: goto inst
if %1==d: goto inst
:erreur
echo Tapez inst [Lecteur_destination]   (Ex inst a: ou inst c:)
goto fin
:inst
echo Cr‚ation r‚pertoire \gadgetpc
md %1\gadgetpc
cd %1\gadgetpc
echo Copie des fichiers *.exe
copy *.exe %1 /v
echo Copie du fichier aide.txt
copy *.txt %1 /v
echo Copie des fichiers *.voc
copy *.voc %1 /v
rem echo Copie de inst.bat
rem copy inst.bat %1 /v
echo Suppression de l'attribut Archive 
%1
attrib *.* -a
echo Installation termin‚e
:fin
echo.
