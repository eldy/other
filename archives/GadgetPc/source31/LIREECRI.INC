{Fichier LIREECRI.INC … inclure}


const {Fichiers}
      fileinstall='c:\gadgetpc\install.exe';
      fileend='c:\gadgetpc\end.exe';
      filegadgetpc='c:\gadgetpc\gadgetpc.exe';
      fileaide='c:\gadgetpc\aide.txt';
      fileoptions='c:\gadgetpc\options.dat';
      fileactivite='c:\gadgetpc\activite.dat';
      fileagenda='c:\gadgetpc\agenda.dat';
      fileboite='c:\gadgetpc\boite';


PROCEDURE pLIREACTIVITE; far;
{*******************************************************}
{putil est red‚fini =autil
{qutil non modifi‚
{*******************************************************}
label lNONVALIDE;
type te=record year,month,day,hour,minute:word;
               yearfin,monthfin,dayfin,hourfin,minutefin:word;
               end;
var f:file of te;
    e:te;
begin
{$I-}
autil:=nil;putil:=nil;
if fileexist(fileactivite) then begin
  assign(f,fileactivite);reset(f);
  if filesize(f)<1 then goto lNONVALIDE; {filesize(f)=x enregistrements de type tutil}
  while not eof(f) do begin
    read(f,e);
    new(putil);
    putil^.year_util:=e.year;
    putil^.month_util:=e.month;
    putil^.day_util:=e.day;
    putil^.hour_util:=e.hour;
    putil^.minute_util:=e.minute;
    putil^.year_utilfin:=e.yearfin;
    putil^.month_utilfin:=e.monthfin;
    putil^.day_utilfin:=e.dayfin;
    putil^.hour_utilfin:=e.hourfin;
    putil^.minute_utilfin:=e.minutefin;
    putil^.ptr:=autil;autil:=putil;
    end;
  close(f);
  { Teste si date actuelle>=date derniŠre activit‚ }
  If fCOMPUTIL(autil,year,month,day)=1 then begin
    textattr:=$07;
    writeln('Erreur:  Le fichier ACTIVITE.DAT indique une activit‚ de votre ordinateur aprŠs');
    writeln('la date courante.  V‚rifiez que la date de votre PC est correcte (Tapez Date).');
    writeln('Si oui, votre fichier ACTIVITE.DAT n''est plus valide (Effacez le).');
    cursoron;
    ARRET;
    end;
  end;
{$I+}
if ioresult=0 then exit;
lNONVALIDE:
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Fichier ACTIVITE.DAT non valide ou incompatible avec ancienne version.');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pECRIREACTIVITE; far;
{*******************************************************}
{ autil<>nil
{ putil ressord =autil
{*******************************************************}
type te=record year,month,day,hour,minute:word;
               yearfin,monthfin,dayfin,hourfin,minutefin:word;
               end;
var f:file of te;
    e:te;
begin
{$I-}
assign(f,fileactivite);rewrite(f);
new(qutil);qutil:=nil;
while qutil<>autil do begin
  putil:=autil;
  while putil^.ptr<>qutil do putil:=putil^.ptr;
  e.year:=putil^.year_util;
  e.month:=putil^.month_util;
  e.day:=putil^.day_util;
  e.hour:=putil^.hour_util;
  e.minute:=putil^.minute_util;
  e.yearfin:=putil^.year_utilfin;
  e.monthfin:=putil^.month_utilfin;
  e.dayfin:=putil^.day_utilfin;
  e.hourfin:=putil^.hour_utilfin;
  e.minutefin:=putil^.minute_utilfin;
  write(f,e);
  qutil:=putil;
  end;
close(f);
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('smartdrv.exe','/c');
swapvectors;
{$I+}
if ioresult=0 then exit;
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Impossible d''‚crire ou r‚‚crire le fichier ACTIVITE.DAT');
writeln('Ses attributs ont du ˆtre malencontreuseument modifi‚s...');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pLIREAGENDA; far;
{*******************************************************}
{ pmemo est red‚fini =amemo
{ qmemo non modifi‚
{*******************************************************}
label lnonvalide;
var i,ii:integer;
    s:string[80];
    f:text;
begin
{$I-}
amemo:=nil;pmemo:=nil;
if fileexist(fileagenda) then begin
  assign(f,fileagenda);reset(f);
  readln(f,s);
  while copy(s,1,2)<>'--' do begin
    new(pmemo);
    val(copy(s,2,2),pmemo^.day_memos,erreur);
    if erreur<>0 then goto lnonvalide;
    val(copy(s,5,2),pmemo^.month_memos,erreur);
    if erreur<>0 then goto lnonvalide;
    val(copy(s,8,4),pmemo^.year_memos,erreur);
    if erreur<>0 then goto lnonvalide;
    i:=1;readln(f,s);
    while copy(s,1,1)<>'-' do begin
      if i=9 then goto lNONVALIDE;
      pmemo^.mess[i]:=s;
      readln(f,s);
      inc(i);
      end;
    for ii:=i to 8 do pmemo^.mess[ii]:='';
    pmemo^.ptr:=amemo;amemo:=pmemo;
    end;
  close(f);
  end;
{$I+}
if ioresult=0 then exit;
lNONVALIDE:
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Fichier AGENDA.DAT non valide.');
writeln('Possibilit‚ d''une mauvaise syntaxe ou incompatibilit‚ avec ancienne version.');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pECRIREAGENDA; far;
{*******************************************************}
{ pmemo ressord =amemo
{*******************************************************}
var i:integer;
    f:text;
begin
{$I-}
assign(f,fileagenda);
if amemo=nil then begin
  if fileexist(fileagenda) then erase(f);
  pmemo:=amemo;
  end
else begin
  rewrite(f);
  new(qmemo);qmemo:=nil;
  while qmemo<>amemo do begin
    pmemo:=amemo;
    while pmemo^.ptr<>qmemo do pmemo:=pmemo^.ptr;
    writeln(f,'-'+JMA(pmemo^.year_memos,pmemo^.month_memos,pmemo^.day_memos)+'-');
    for i:=1 to fNBRELIGNE(pmemo^.mess) do writeln(f,pmemo^.mess[i]);
    qmemo:=pmemo;
    end;
  writeln(f,'------------');
  close(f);
  end;
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('smartdrv.exe','/c');
swapvectors;
{$I+}
if ioresult=0 then exit;
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Impossible d''‚crire ou r‚‚crire le fichier AGENDA.DAT');
writeln('Ses attributs ont du ˆtre malencontreuseument modifi‚s...');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pLIREBOITE(noboite:char); far;
{*******************************************************}
{pboite est red‚fini =aboite
{qboite non modifi‚
{*******************************************************}
label lNONVALIDE;
type te=record year,month,day:word;
               mess:tmess;
               end;
var fileboitex:string;
    f:file of te;
    e:te;
    b:boolean;
begin
{$I-}
fileboitex:=fileboite+noboite+'.dat';
aboite:=nil;pboite:=nil;
b:=false;
if (noboite>'0') and (noboite<'6') and (options.proprio[noboite]<>'') then b:=true;
if (noboite>'5') and (noboite<='9') and (options.proprio[noboite]<>'') then b:=true;
if b and fileexist(fileboitex) then begin
  assign(f,fileboitex);reset(f);
  if filesize(f)<1 then goto lNONVALIDE; {filesize(f)=x enregistrements de type tboite}
  while not eof(f) do begin
    read(f,e);
    new(pboite);
    pboite^.year_boite:=e.year;
    pboite^.month_boite:=e.month;
    pboite^.day_boite:=e.day;
    pboite^.mess:=e.mess;
    pboite^.ptr:=aboite;aboite:=pboite;
    end;
  close(f);
  end;
{$I+}
if ioresult=0 then exit;
lNONVALIDE:
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Fichier BOITE',noboite,'.DAT non valide ou incompatible avec ancienne version..');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pECRIREBOITE(noboite:char); far;
{*******************************************************}
{pboite ressord =aboite
{*******************************************************}
type te=record year,month,day:word;
               mess:tmess;
               end;
var fileboitex:string;
    f:file of te;
    e:te;
begin
{$I-}
fileboitex:=fileboite+noboite+'.dat';
assign(f,fileboitex);
if aboite=nil then begin
  if fileexist(fileboitex) then erase(f);
  pboite:=aboite;
  end
else begin
  rewrite(f);
  new(qboite);qboite:=nil;
  while qboite<>aboite do begin
    pboite:=aboite;
    while pboite^.ptr<>qboite do pboite:=pboite^.ptr;
    e.year:=pboite^.year_boite;
    e.month:=pboite^.month_boite;
    e.day:=pboite^.day_boite;
    e.mess:=pboite^.mess;
    write(f,e);
    qboite:=pboite;
    end;
  close(f);
  end;
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('smartdrv.exe','/c');
swapvectors;
{$I+}
if ioresult=0 then exit;
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Impossible d''‚crire ou r‚‚crire le fichier '+fileboitex);
writeln('Ses attributs ont du ˆtre malencontreuseument modifi‚s...');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
cursoron;
ARRET;
end;


PROCEDURE pLIREOPTIONS; far;
{*******************************************************}
{ Format du fichier: options.mess[0..8]
{                    options.optmemos (0-99)
{                    options.proprio['1'..'9']
{                    options.code['0'..'9']
{                    options.delai_eco (10-600)
{                    options.optcourrier (0 ou 1)
{                    options.optboot (1 ou 2)
{                           .fond             .texte             .textebis
{                           .fond_barre_titre .texte_barre_titre
{                           .fond_menu_titre  .texte_menu_titre
{                           .fond_menu        .texte_menu        .textebis_menu
{                           .texte_logo
{                           .parquage
{                           .son              .son_end
{                           .year_violation   .month_violation   .day_violation
{                           .hour_violation   .minute_violation
{                    options.pause (0 ou 1)
{                    options.filler
{*******************************************************}
label lNONVALIDE;
var c:char;
    i:integer;
    f:file of toptions;
begin
{ Initialisation par d‚faut }
for i:=0 to 8 do options.mess[i]:='';
options.optmemos:=5;
options.proprio['1']:='publique';
for c:='2' to '9' do options.proprio[c]:='';
options.delai_eco:=60;
options.optcourrier:=1;
options.optboot:=1;
options.fond:=$0;options.texte:=$07;options.textebis:=$0F;
options.fond_barre_titre:=$30;options.texte_barre_titre:=$0;
options.fond_menu_titre:=$10;options.texte_menu_titre:=$0F;
options.fond_menu:=$70;options.texte_menu:=$0;options.textebis_menu:=$0F;
options.texte_logo:=$08;
options.parquage:=0;
options.son:=1;options.son_end:=1;
options.year_violation:=0;options.month_violation:=0;options.day_violation:=0;
options.hour_violation:=0;options.minute_violation:=0;
options.pause:=0;
{ Initialisation par fichier sauvegarde }
{$I-}
if fileexist(fileoptions) then begin
  assign(f,fileoptions);reset(f);
  if filesize(f)<>1 then goto lNONVALIDE; {filesize(f)=1 enregistrement de type toptions}
  read(f,options);
  close(f);
  end;
{$I+}
if ioresult=0 then exit;
lNONVALIDE:
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur:  Fichier OPTIONS.DAT non valide ou incompatible avec ancienne version.');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
CURSORON;
ARRET;
end;


PROCEDURE pECRIREOPTIONS; far;
{*******************************************************}
{ Format du fichier: options.mess[0..8]
{                    options.optmemos (0-99)
{                    options.proprio['1'..'9']
{                    options.code['0'..'9']
{                    options.delai_eco (10-600)
{                    options.optcourrier (1 ou 0)
{                    options.optboot (1 ou 2)
{                            .fond             .texte             .textebis
{                            .fond_barre_titre .texte_barre_titre
{                            .fond_menu_titre  .texte_menu_titre
{                            .fond_menu        .texte_menu        .textebis_menu
{                            .texte_logo
{                            .parquage
{                            .son              .son_end
{                            .year_violation   .month_violation   .day_violation
{                            .hour_violation   .minute_violation
{                    options.pause (0 ou 1)
{                    options.filler
{*******************************************************}
var c:char;
    i:integer;
    f:file of toptions;
begin
{$I-}
options.fond:=fond;options.texte:=texte;options.textebis:=textebis;
options.fond_barre_titre:=fond_barre_titre;options.texte_barre_titre:=texte_barre_titre;
options.fond_menu_titre:=fond_menu_titre;options.texte_menu_titre:=texte_menu_titre;
options.fond_menu:=fond_menu;options.texte_menu:=texte_menu;options.textebis_menu:=textebis_menu;
options.texte_logo:=texte_logo;
assign(f,fileoptions);rewrite(f);
write(f,options);
close(f);
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('smartdrv.exe','/c');
swapvectors;
{$I+}
if ioresult=0 then exit;
textattr:=$07; {Couleur du DOS}
writeln;
writeln('Erreur: Impossible d''‚crire ou r‚‚crire le fichier OPTIONS.DAT');
writeln('Ses attributs ont du ˆtre malencontreuseument modifi‚s...');
writeln('Effacez le ou retirez le du r‚pertoire C:\GADGETPC');
CURSORON;
ARRET;
end;
