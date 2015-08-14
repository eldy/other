@echo off
echo Script de restauration des fichiers COM
echo ---------------------------------------
xcopy c:\*.cov c:\*.com /s /c
xcopy d:\*.cov d:\*.com /s /c
