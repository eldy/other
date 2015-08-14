PROGRAM FIN;
{*******************************************************}
{*                                                     *}
{*           Programme FIN de GadgetPC                 *}
{*                                                     *}
{*******************************************************}
{$M $8000,$10000,$40000} {32k,64k,256k}

uses crt,dos,general,hardware,math,time,video;
const version='3.1 ';
      videoseg:word=$B800;
type tmess=array[0..8] of string[80];
     tmenu=array[0..15] of record phrase:string[40];
                                  place:integer;
                                  end;
     tptrutil=^tutil;
     tutil=record year_util,month_util,day_util,hour_util,minute_util:word;
                  year_utilfin,month_utilfin,day_utilfin,hour_utilfin,minute_utilfin:word;
                  ptr:tptrutil;
                  end;
     tptrmemo=^tmemo;
     tmemo=record year_memos,month_memos,day_memos:word;
                  mess:tmess;
                  ptr:tptrmemo;
                  end;
     tptrboite=^tboite;
     tboite=record year_boite,month_boite,day_boite:word;
                  mess:tmess;
                  ptr:tptrboite;
                  end;
     tproprio=array['1'..'9'] of string[20];
     tcode=array['0'..'9'] of string[8];
     toptions=record mess:tmess;
                 optmemos:shortint;
                 proprio:tproprio;
                 code:tcode;
                 delai_eco:integer;
                 optcourrier:integer;
                 optboot:integer;
                 fond:integer;texte:integer;textebis:integer;
                 fond_barre_titre:integer;texte_barre_titre:integer;
                 fond_menu_titre:integer;texte_menu_titre:integer;
                 fond_menu:integer;texte_menu:integer;textebis_menu:integer;
                 texte_logo:integer;
                 parquage:integer;
                 son:integer;son_end:integer;
                 year_violation,month_violation,day_violation:word;
                 hour_violation,minute_violation:word;
                 fete:array[1..12] of array[1..31] of integer;
                 pause:integer;
                 filler:array[1..100] of byte;
                 end;
var autil,putil,qutil:tptrutil;
    amemo,pmemo,qmemo:tptrmemo;
    aboite,pboite,qboite:tptrboite;
    year,month,day,dayofweek:word;
    hour,minute,seconde,sec100:word;
    year_util,month_util,day_util,dayofweek_util:word;
    r:real;
    erreur:integer;
    options:toptions;
    fond,texte,textebis:integer;
    fond_barre_titre,texte_barre_titre:integer;
    fond_menu_titre,texte_menu_titre:integer;
    fond_menu,texte_menu,textebis_menu:integer;
    texte_logo:integer;
    attr_normal,attr_normalbis:integer;
    attr_barre_titre,attr_menu_titre:integer;
    attr_menu_normal,attr_menu_normalbis,attr_menu_invisible:integer;
    attr_inverse,attr_menu_inverse,attr_menu_inversebis:integer;
    attr_logo:integer;


PROCEDURE ARRET;
{*******************************************************}
{Termine programme anormallement
{Rem: appel‚ par proc‚dures dans LIREECR.INC
{*******************************************************}
begin
halt;
end;


FUNCTION fCOMPUTIL(p:tptrutil;year,month,day:word):integer; far;
{*******************************************************}
{ Renvoi  1 si p>date
{         0 si p=date
{        -1 si p<date
{        -1 si p=nil
{*******************************************************}
var i,j,k:integer;
begin
if p=nil then fcomputil:=-1
else begin
  i:=p^.day_util;
  j:=p^.month_util;
  k:=p^.year_util;
  fcomputil:=SIGNE((i-day)+31*((j-month)+12*(k-year)));
  end;
end;


FUNCTION fCOMPMEMO(p:tptrmemo;year,month,day:word):integer; far;
{*******************************************************}
{ Renvoi  1 si p>date
{         0 si p=date
{        -1 si p<date
{        -1 si p=nil
{*******************************************************}
var i,j,k:integer;
begin
if p=nil then fcompmemo:=-1
else begin
  i:=p^.day_memos;
  j:=p^.month_memos;
  k:=p^.year_memos;
  fcompmemo:=SIGNE((i-day)+31*((j-month)+12*(k-year)));
  end;
end;


FUNCTION fCOMPBOITE(p:tptrboite;year,month,day:word):integer; far;
{*******************************************************}
{ Renvoi  1 si p>date
{         0 si p=date
{        -1 si p<date
{        -1 si p=nil
{*******************************************************}
var i,j,k:integer;
begin
if p=nil then fcompboite:=-1
else begin
  i:=p^.day_boite;
  j:=p^.month_boite;
  k:=p^.year_boite;
  fcompboite:=SIGNE((i-day)+31*((j-month)+12*(k-year)));
  end;
end;


FUNCTION fNBRELIGNE(mess:tmess):integer; far;
{*******************************************************}
{Renvoi le nbre de ligne de mess
{*******************************************************}
var i:integer;
begin
i:=8;
while ((i<>0) and (mess[i]='')) do dec(i);
fnbreligne:=i;
end;


{$I LIREECRI.INC}
{*******************************************************}
{IntŠgre proc‚dure de lecture et ‚criture des fichiers.
{*******************************************************}


PROCEDURE pDUREE(p:tptrutil;var r:real); far;
{*******************************************************}
{Renvoi en r la dur‚e d'utilisation PC enregistr‚ dans p
{*******************************************************}
var i,j,k,l,m:integer;
begin
i:=p^.minute_utilfin;
j:=p^.hour_utilfin;
k:=p^.day_utilfin;
l:=p^.month_util;
m:=p^.year_util;
r:=0;
while l<>p^.month_utilfin do begin
  r:=r+NBREJOUR(m,l)*24;
  inc(l);if l>12 then begin l:=1;inc(m);end;
  end;
r:=r+(k-p^.day_util)*24+(j-p^.hour_util)+(i-p^.minute_util)/60;
end;



{*******************************************************}
{PROGRAMME PRINCIPAL
{*******************************************************}
begin
checkbreak:=false;
cursoroff;
if mem[$40:$63]=$3B4 then videoseg:=$B000; {Carte monochrome}
new(autil);new(putil);new(qutil);
getdate(year,month,day,dayofweek);
gettime(hour,minute,seconde,sec100);
writeln;
pLIREOPTIONS;
fond:=options.fond;texte:=options.texte;textebis:=options.textebis;
fond_barre_titre:=options.fond_barre_titre;texte_barre_titre:=options.texte_barre_titre;
fond_menu_titre:=options.fond_menu_titre;texte_menu_titre:=options.texte_menu_titre;
fond_menu:=options.fond_menu;texte_menu:=options.texte_menu;textebis_menu:=options.textebis_menu;
texte_logo:=options.texte_logo;
attr_normal:=fond+texte;
attr_normalbis:=fond+textebis;
attr_inverse:=(texte shl 4)+(fond shr 4);
attr_barre_titre:=fond_barre_titre+texte_barre_titre;
attr_menu_titre:=fond_menu_titre+texte_menu_titre;
attr_menu_normal:=fond_menu+texte_menu;
attr_menu_normalbis:=fond_menu+textebis_menu;
attr_menu_inverse:=(texte_menu shl 4)+(fond_menu shr 4);
attr_menu_inversebis:=(texte_menu shl 4)+textebis_menu;
attr_menu_invisible:=fond_menu+(fond_menu shr 4);
attr_logo:=fond+texte_logo;
textattr:=attr_barre_titre;write(' GADGETPC Version ',version,' -  RAPPORT D''UTILISATION');clreol;
textattr:=$07;writeln;
pLIREACTIVITE;
{Teste si date actuelle>=date derniŠre activit‚}
If fCOMPUTIL(autil,year,month,day)=1 then begin
  writeln('Erreur:  Le fichier ACTIVITE.DAT indique une activit‚ de votre ordinateur APRES');
  writeln('la date courante.  V‚rifiez que la date de  votre PC est correcte (Tapez Date).');
  writeln('Si oui (ou si le problŠme persiste), vous devez effacer le fichier ACTIVITE.DAT');
  writeln('de votre disque dur.');
  halt;
  end;
{Protection ‚vite autil=nil}
if autil=nil then begin
  new(putil);
  getdate(putil^.year_util,putil^.month_util,putil^.day_util,dayofweek_util);
  putil^.hour_util:=hour;putil^.minute_util:=minute;
  putil^.year_utilfin:=0;putil^.month_utilfin:=0;putil^.day_utilfin:=0;
  putil^.hour_utilfin:=0;putil^.minute_utilfin:=0;
  putil^.ptr:=autil;autil:=putil;
  end;
autil^.year_utilfin:=year;
autil^.month_utilfin:=month;
autil^.day_utilfin:=day;
autil^.hour_utilfin:=hour;
autil^.minute_utilfin:=minute;
pECRIREACTIVITE;
writeln;write('DEBUT:           FIN:           TEMPS D''UTILISATION:');
textattr:=$0F;
gotoxy(8,wherey);
write(FILLZERO(autil^.hour_util,2),':',FILLZERO(autil^.minute_util,2));
gotoxy(23,wherey);
write(FILLZERO(autil^.hour_utilfin,2),':',FILLZERO(autil^.minute_utilfin,2));
gotoxy(54,wherey);
pDUREE(qutil,r);
if trunc(r)=0 then writeln(round(frac(r)*60),' mn')
else writeln(trunc(r),' h ',FILLZERO(round(frac(r)*60),2),' mn');
writeln;
{ Force ‚criture du cache (Suce … Smartdrive) }
swapvectors;
exec('c:\dos\smartdrv.exe','/c');
swapvectors;
write('Vous pouvez ‚teindre votre PC ...');
case options.son_end of
  0:begin
    delay(50);
    end;
  1:begin
    sound(2500);
    end;
  end;
if options.parquage>0 then begin
  end;
repeat until false;
end.