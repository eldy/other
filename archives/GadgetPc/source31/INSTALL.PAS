PROGRAM INSTALL;
{*******************************************************}
{*                                                     *}
{*         Programme Installation pour GadgetPC        *}
{*                                                     *}
{*******************************************************}
{$M $4000,$1000,$1000} {16k,4k,4k Rem:Moins de 16k de pile=>RunTime Error}


uses crt,dos,general,hardware,keyboard,video;
const {divers}
      version='3.1 ';
      nbrepage=13;
      {Fichier}
      fileinstall='c:\gadgetpc\install.exe';
      fileend='c:\gadgetpc\end.exe';
      filegadgetpc='c:\gadgetpc\gadgetpc.exe';
      fileaide='c:\gadgetpc\aide.txt';
      fileoptions='c:\gadgetpc\options.dat';
      fileactivite='c:\gadgetpc\activite.dat';
      fileagenda='c:\gadgetpc\agenda.dat';
      fileboite='c:\gadgetpc\boite';
var auto,b:boolean;
    lancement_windows:boolean;
    c:char;
    codeerreur:byte;
    i,ii:integer;
    path:string;
    s:string;
    f,g:text;


PROCEDURE ERREUR(erreur:integer);
{*******************************************************}
{Quitte le programme d'installation avec erreur
{*******************************************************}
begin
case erreur of
  1:writeln('Tapez INSTALL C:');
  2:begin
    writeln;
    writeln('Erreur: Le fichier C:\AUTOEXEC.BAT n''a pu ˆtre modifi‚.');
    write('Vous devez rajouter manuellement la ligne "c:\gadgetpc\gadgetpc go"  … la fin de');
    writeln('de votre fichier C:\AUTOEXEC.BAT pour terminer l''installation.');
    end;
  3:begin
    write('Erreur: Placez vous dans le r‚pertoire d''installation de GadgetPC AVANT de taper');
    writeln('INSTALL C:');
    end;
  end;
cursoron;
halt;
end;


{*******************************************************}
{ PROGRAMME PRINCIPAL
{*******************************************************}
begin
CURSOROFF;
writeln;
writeln('*********************************************************');
writeln('**       Installation de  GadgetPC sur le disque       **');
writeln('**        dur C: dans le r‚pertoire C:\GADGETPC        **');
writeln('*********************************************************');
writeln;
if not FILEEXIST('install.exe') then ERREUR(3);
if MAJUSCULE(paramstr(1))<>'C:' then ERREUR(1);
{Cr‚ation du r‚pertoire GadgetPC}
writeln('- Cr‚ation du r‚pertoire C:\GADGETPC');
if DIREXIST('c:\gadgetpc') then begin
  writeln('R‚pertoire d‚j… existant.');
  end
else begin
  MAKEDIR('c:\gadgetpc');
  writeln('R‚pertoire cr‚‚.');
  end;
writeln;
{Copie des 4 fichiers}
writeln('- Copie du fichier  INSTALL.EXE  dans C:\GADGETPC');
copyfile('install.exe',fileinstall,codeerreur);
if codeerreur=0 then writeln('Fichier copi‚.');
if codeerreur=1 then writeln('Ne peut ˆtre copi‚ sur lui-mˆme.');
if codeerreur=2 then writeln('Fichier non trouv‚.');
writeln('- Copie du fichier  AIDE.TXT     dans C:\GADGETPC');
copyfile('aide.txt',fileaide,codeerreur);
if codeerreur=0 then writeln('Fichier copi‚.');
if codeerreur=1 then writeln('Ne peut ˆtre copi‚ sur lui-mˆme.');
if codeerreur=2 then writeln('Fichier non trouv‚.');
writeln('- Copie du fichier  END.EXE      dans C:\GADGETPC');
copyfile('end.exe',fileend,codeerreur);
if codeerreur=0 then writeln('Fichier copi‚.');
if codeerreur=1 then writeln('Ne peut ˆtre copi‚ sur lui-mˆme.');
if codeerreur=2 then writeln('Fichier non trouv‚.');
writeln('- Copie du fichier  GADGETPC.EXE dans C:\GADGETPC');
copyfile('gadgetpc.exe',filegadgetpc,codeerreur);
if codeerreur=0 then writeln('Fichier copi‚.');
if codeerreur=1 then writeln('Ne peut ˆtre copi‚ sur lui-mˆme.');
if codeerreur=2 then writeln('Fichier non trouv‚.');
writeln;
{Effacement des fichiers.dat}
if fileexist(fileactivite) then begin
  assign(f,fileactivite);
  erase(f);
  end;
if fileexist(fileoptions) then begin
  assign(f,fileoptions);
  erase(f);
  end;
if fileexist(fileagenda) then begin
  assign(f,fileagenda);
  erase(f);
  end;
for c:='1' to '9' do begin
  if fileexist(fileboite+c+'.dat') then begin
    assign(f,fileboite+c+'.dat');
    erase(f);
    end;
  end;
writeln('- ATTENTION:');
writeln('Afin que  GadgetPC  s''active  … l''allumage  de votre  PC,  il faut le lancer …');
writeln('partir  du fichier  AUTOEXEC.BAT.   Pour cela,  il  est  n‚cessaire  d''ajouter');
writeln('l''instruction  "C:\GADGETPC\GADGETPC GO"  … votre fichier AUTOEXEC.BAT');
writeln('Si vous ne poss‚dez pas un menu de d‚marrage multiple ( = choix lors du Boot),');
writeln('GagdetPC peut faire ces modifications automatiquement...   sinon vous devez le');
writeln('faire manuellement...');
write('- Configuration automatique du fichier C:\AUTOEXEC.BAT pour GadgetPC  (O/N) ? ');
if OUI_NON='O' then auto:=true else auto:=false; {Auto=Configuration automatique}
writeln;
if auto then begin
if FILEEXIST('c:\autoexec.bat') then begin
    b:=true; {Oui pour ajout de la ligne c:\gadgetpc\gadgetpc go}
    lancement_windows:=false; {Ligne win non pr‚sente dans l'Autoexec}
    assign(f,'c:\autoexec.bat');reset(f);
    assign(g,'c:\autoexec.bis');rewrite(g);
    while not eof(f) do begin
      readln(f,s);
      if pos('GADGETPC GO',MAJUSCULE(s))>0 then b:=false;
      if MAJUSCULE(copy(s,1,4))='PATH' then begin
        if pos('C:\GADGETPC',MAJUSCULE(s))=0 then begin
          s:=CLEARSPACE(s);
          if s[length(s)]<>';' then s:=s+';';
          s:=s+'C:\GADGETPC';
          s:='PATH '+copy(s,5,length(s)-4);
          end;
        end;
      if (pos('WIN',MAJUSCULE(copy(s,1,3)))>0) then
        lancement_windows:=true
      else writeln(g,s);
      end;
    close(f);
    {Ajout de la ligne c:\gadgetpc\gadgetpc go}
    if b then writeln(g,'C:\gadgetpc\GadgetPC Go');
    {Ajout de la ligne win}
    if lancement_windows then writeln(g,'win');
    close(g);
    {Ici, le fichier autoexec.bis est cr‚‚}
    COPYFILE('c:\autoexec.bat','c:\autoexec.bak',codeerreur);
    if codeerreur=0 then writeln('L''ancien fichier AUTOEXEC.BAT est sauvegard‚ sous AUTOEXEC.BAK')
    else begin
      erase(g);
      ERREUR(2);
      end;
    COPYFILE('c:\autoexec.bis','c:\autoexec.bat',codeerreur);
    if codeerreur=0 then begin
      erase(g);
      writeln('Le chemin  "C:\GADGETPC"  a ‚t‚ rajout‚ … votre PATH.');
      writeln('La ligne  "C:\GADGETPC\GADGETPC GO"  a ‚t‚ rajout‚e au fichier C:\AUTOEXEC.BAT');
      end
    else begin
      erase(g);
      ERREUR(2);
      end;
    end
  else ERREUR(2);
  end;
writeln;
writeln('- Le fichier AIDE qui va vous ˆtre affich‚ pourra ‚galement ˆtre visualis‚ …');
writeln('partir de GadgetPC dans le menu Aide.');
writeln('Tapez une touche...');
TOUCHE;
{Affiche le fichier AIDE.TXT}
if FILEEXIST(fileaide) then begin
  assign(f,fileaide);reset(f);
  repeat readln(f,s) until copy(s,1,4)='AIDE';
  clrscr;
  for i:=1 to nbrepage do begin
    writeln(s);
    readln(f,s);
    while (copy(s,1,4)<>'AIDE') and (not eof(f)) do begin
      case s[2] of
        '*':begin
          s[2]:=' ';
          end;
        '-':begin
          s[2]:=' ';
          end;
        else begin end;
        end;
      writeln(s);  {Ecrit ligne}
      readln(f,s); {Lit suivante}
      end;
    if eof(f) then writeln(s);
    TOUCHE;
    clrscr;
    end;
  end
else write('Erreur: Fichier c:\gadgetpc\aide.txt non trouv‚.');
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('c:\dos\smartdrv.exe','/c');
swapvectors;
textcolor(15);
writeln;
writeln('Installation de GadgetPC Version ',version,' termin‚e.');
writeln;
textcolor(7);
if auto then begin
  writeln('Le programme GadgetPC se trouve dans le r‚pertoire C:\GADGETPC');
  writeln;
  writeln('Votre PC sera r‚initialis‚ et prˆt … l''emploi en tapant Espace (sinon ECHAP).');
  repeat c:=readkey until (ord(c)=$20) or (ord(c)=$1B);
  if ord(c)=$20 then WARMBOOT;
  end
else begin
  writeln('Modifiez votre fichier C:\AUTOEXEC.BAT en ajoutant la ligne');
  writeln('C:\GADGETPC\GADGETPC GO');
  writeln('en derniŠre instruction, puis rebootez.');
  writeln('Rem: Il est utile, pour appeler la fonction END de n''importe o—, d''ajouter de');
  writeln('plus le r‚pertoire C:\GADGETPC … votre PATH.');
  end;
CURSORON;
end.
