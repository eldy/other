PROGRAM TESTPRINT;
{***************************************}
{* PROGRAM: TestPrinter                *}
{***************************************}
{* LAST REVISION: 12/09/96             *}
{***************************************}
{$M 1024,$4000,$4000}

uses dos,crt,printer,hardware,keyboard;

const version='2.5 ';
var invalide,help:integer;
    i,port:integer;
    s:string;
    nbre_lpt:integer;
    resultat:integer;
    adresse:array[1..4] of word;

begin
writeln;
write('TESTPRINT Version ',version,'  (c) L-D ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
port:=1;help:=0;invalide:=0;
if paramcount<1 then help:=-1;
for i:=paramcount downto 1 do begin
  s:=paramstr(i);
  if s[1]='/' then
    case upcase(s[2]) of
      '?','H':help:=-1;
      'I':begin
        writeln('Usage:  TestPrin  /1 or /2 or /3      [/?]  [/i]');
        writeln;
        writeln('TestPrint is an utility of the pack UTILKIT, available from its distributors');
        writeln('from the author for a registration fee of 6$ (or 40FF in France) sent to the');
        writeln('following address (Answer within 15 days):');
        writeln;
        writeln('Laurent DESTAILLEUR,     ');
        writeln('58 Rue Fran‡ois Mauriac,                  E-Mail address:');
        writeln('78180 Montigny-le-Bretonneux              101642.2125@compuserve.com');
        writeln('FRANCE.                  ');
        writeln;
        writeln('Note: All sources of the utilities of the UTILKIT pack (Pascal or C) will be');
        writeln('sent with the kit as well, on request.');
        writeln;
        writeln;
        halt;
        end;
    '1':port:=1;
    '2':port:=2;
    '3':port:=3;
    else invalide:=-1;
    end
  end;
if (help=-1) then begin
        writeln('Usage:  TestPrin  /1 or /2 or /3      [/?]  [/i]');
        writeln;
        write(  'TestPrint  permet de v‚rifier la compatibilit‚ de la configuration de la page de');
        writeln('code ASCII (Page 437,850,... selon le fichier Config.sys et Autoexec.bat), avec');
        writeln('la configuration d''une imprimante (standard IBM <> EPSON, configuration de la');
        writeln('police d''impression, etc... ).');
        writeln;
        writeln('Les options sont:    /1    pour r‚aliser le test avec l''imprimante en LPT1.');
        writeln('                     /2    pour r‚aliser le test avec l''imprimante en LPT2.');
        writeln('                     /3    pour r‚aliser le test avec l''imprimante en LPT3.');
        writeln('                     /?    affiche cette page d''aide.');
        writeln('                     /i    pour info sur les sources et autres utilitaires.');
        writeln;
  halt;
  end;
if invalide=-1 then begin
  writeln('Error: Bad parameter(s).');
  halt;
  end;
nbre_lpt:=0;
for i:=1 to 4 do begin
  adresse[i]:=mem[$40:$06+i*2];
  if adresse[i]<>0 then begin
    inc(nbre_lpt);
    end;
  end;
if nbre_lpt=0 then begin
  writeln('Erreur: Aucun port LPT d‚tect‚.  Le test ne fonctionne que pour les imprimantes');
  writeln('parallŠles.');
  halt;
  end;
if port>nbre_lpt then begin
  writeln('Error: LPT port ',port,' is not valid.');
  halt;
  end;
write(nbre_lpt,' port(s) LPT d‚tect‚s.');
writeln('Le test de l''imprimante s''effectuera sur le port LPT',port,'.');
writeln;
writeln('Tapez une touche pour commencer...');
TOUCHE;

writeln('OPERATION: Initialisation.');
INITPRINTER(port);
delay(8000);
TESTPRINTER(port,resultat);

case (resultat) of
  0:writeln('REPONSE: Initialisation Ok...');
  1:begin
    writeln('REPONSE: Plus de papier...');
    writeln('Introduisez une nouvelle feuille et recommencez le test.');
    exit;
    end;
  2:begin
    writeln('REPONSE: Imprimante occup‚e...');
    writeln('Recommencez le test lorsque l''imprimante sera libre.');
    exit;
    end;
  3:begin
    writeln('REPONSE: Imprimante introuvable (non connect‚e ou non allum‚e).');
    writeln('R‚solvez le problŠme pour effectuer la suite du test.');
    exit;
    end;
end;
writeln;
writeln('Tapez une touche pour continuer...');
TOUCHE;
writeln('Essai impression code ASCII de 32 … 255 (Sortie ‚cran en 80 colonnes): ');
writeln(lst,'Essai impression code ASCII de 32 … 255 (Sortie imprimante en 80 colonnes): ');
for i:=32 to 255 do begin
  write(chr(i));write(lst,chr(i));
  if ((i-31) mod 80)=0 then write(lst,#13,#10);
  end;
{ Fin de page }
writeln;write(lst,#10,#13,#12);
writeln;
writeln('=> Comparez maintenant la sortie sur l''imprimante avec l''‚cran.');
writeln('S''il y a des diff‚rences, votre imprimante n''est pas configur‚e avec la mˆme');
writeln('page de code que votre PC ou est mal configur‚e (Mauvaise police, mauvaise');
writeln('option ou autre).');
end.

