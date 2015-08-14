PROGRAM GADGETPC;
{***************************************}
{*             GADGETPC                *}
{***************************************}
{stack 32k,heap min 64k,heap max 256k}
{$M $8000,$10000,$40000}
{Active Force For Call option de compilation}
{$F+}

uses crt,dos,drivers,general,hardware,keyboard,math,time,video,perso;
label lGADGETPC;
label lGADGETPCGO;
const {Divers}
      enregistrement=false;
      version='3.1 ';
      compteurmax=17;
      nbrepage=13;
      {Mode}
      videoseg:word=$B800;
      nbre_lignes:integer=25;
      curseur_page:integer=221;
      {Position modules ‚cran}
      jour0:integer=803;
      jour1:integer=887;
      jour2:integer=2327;
      jour3:integer=3767;
      ligne:integer=32;
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

var f:text;
    regs:registers;
    indos:^byte;
    inbios:boolean;
    int1Csave:procedure;
    int13save:procedure;
    notbusy:boolean;
    count:integer;
    timer:integer;
    year,month,day,dayofweek:word;
    yearbis,monthbis,daybis:word;
    jourbis:integer;
    year_util,month_util,day_util,dayofweek_util:word;
    year_memos,month_memos,day_memos,dayofweek_memos:word;
    year_boite,month_boite,day_boite,dayofweek_boite:word;
    hour,minute,seconde,sec100:word;
    ancienne_seconde:word;
    mode:word;
    parametre:string;
    nbre_jours_utilisation:integer;
    nbre_tentatives:integer;
    autil,putil,qutil:tptrutil;
    amemo,pmemo,qmemo:tptrmemo;
    aboite,pboite,qboite:tptrboite;
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
    calendrier:integer;
    level1,level2,level3,level4:integer;
    choix:integer;
    niveau:longint;
    menu:tmenu;
    noboite:char;
    nbreenr,enrcur:integer;
    save:boolean;

    c:char;
    i,ii:integer;
    s,ss,sss:string;
    erreur:integer;
    codeerreur:byte;

    b:boolean;
    event:tevent;
    clavier:boolean;
    scan:byte;
    ascii:char;
    x,xx,y,yy:integer;


{$I fetes.inc}
{*******************************************************}
{IntŠgre tableau des fˆtes.
{*******************************************************}

{$I logo.inc}
{*******************************************************}
{IntŠgre proc‚dure dessin logo.
{*******************************************************}


PROCEDURE ARRET; far;
{*******************************************************}
{Termine programme anormallement
{Restitue vecteurs interruption
{*******************************************************}
begin
setintvec($1C,addr(int1Csave));
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


PROCEDURE GADGECO; far;
{*******************************************************}
{Lance ‚conomiseur d'‚cran
{*******************************************************}
const retard=160;
var b:boolean;
    x1,y1,x2,y2,d,e:integer;
    r:real;
    event:tevent;
    color:word;
begin
setvideomode($13); {Mode 320*200*256}
d:=0;color:=448;b:=true;
repeat
  case b of
    false:getkeyevent(event);
    true:getmouseevent(event);
    end;
  b:=not b;
  inc(d);if d>3599 then d:=0;
  r:=(d*PI)/1800;
  x1:=round(sin(r*3)*110);x2:=x1+160;
  y1:=round(cos(r)*100);y2:=y1+100;
  inc(color);if color>800 then color:=448;
  asm
    mov cl,4
    sar x1,cl
    sar y1,cl
    end;
  line(160+x1,100+y1,x2,y2,color shr 4);
  e:=d-retard ;
  r:=(e*PI)/1800;
  x1:=round(sin(r*3)*110);x2:=x1+160;
  y1:=round(cos(r)*100);y2:=y1+100;
  asm
    mov cl,4
    sar x1,cl
    sar y1,cl
    end;
  line(160+x1,100+y1,x2,y2,0);
  delay(1);
  until (event.what=evkeydown) or (event.what=evmousedown);
textmode($103); {Retour au mode texte}
end;


PROCEDURE CLAVIERSOURIS(var clavier:boolean;var scan:byte;
                        var ascii:char;var x,y:integer); far;
{*******************************************************}
{Attend frappe d'une touche ou pression souris
{Si touche: clavier=true
{           scan=code scan de la touche
{           ascii=code ascii de la touche
{           x,y insignifiant
{Si souris: clavier=false
{           scan=num‚ro bouton souris (1 ou 2)
{           ascii=code ascii caratŠre cliqu‚
{           x,y position de la souris
{*******************************************************}
var b:boolean;
    event:tevent;
begin
SETMOUSE($FFFF,$7700);
showmouse;mem[videoseg:1]:=((attr_barre_titre) and $F0) or (attr_barre_titre shr 4); {Recache souris dans coin}
b:=true;
repeat
  if b then getmouseevent(event)
  else getkeyevent(event);
  b:=not b;
  if timer<1 then begin
    hidemouse;
    case options.son of
      0:delay(10);
      1:begin
        sound(5000);delay(10);nosound;
        end;
      end;
    SAUVEXY;
    CAPTURESCREEN(1,1,80,nbre_lignes,win);
    gadgeco;
    {Dessin logo}
    BUILDLOGO(17,22,nbre_pixel_y,attr_logo,logo);
    RESTORESCREEN(win);
    RESTAUREXY;
    CURSOROFF;
    showmouse;mem[videoseg:1]:=((attr_barre_titre) and $F0) or (attr_barre_titre shr 4); {Recache souris dans coin}
    timer:=options.delai_eco;
    end;
  until (event.what=evkeydown) or (event.what=evmousedown);
{Touche press‚e ou souris cliqu‚e}
timer:=options.delai_eco;
clavier:=b;
if b then begin
  scan:=event.scancode;
  ascii:=event.charcode;
  end
else begin
  x:=(event.where.x)+1;
  y:=(event.where.y)+1;
  scan:=event.buttons; {Normallement scan=0}
  ascii:=chr(mem[videoseg:(event.where.y*160+(event.where.x shl 1))]);
  end;
hidemouse;
end;


PROCEDURE pCHERCHEUTIL(var p:tptrutil;a:tptrutil;year,month,day:word); far;
{*******************************************************}
{ Nbreenr donne nombre de pr‚sence year/month/day dans la liste a
{ p=‚l‚ment de liste ou nil
{ si a=nil                  p pointe nil
{    trouv‚                 p pointe premier enr
{    pas trouv‚             p pointe enr suivant
{    pas trouv‚+date>liste  p pointe a
{    pas trouv‚+date<liste  p pointe nil
{*******************************************************}
begin
nbreenr:=0;
if a<>nil then begin
  if fCOMPUTIL(p,year,month,day)=-1 then p:=a;
  if fCOMPUTIL(p,year,month,day)>-1 then begin
    while fCOMPUTIL(p,year,month,day)=1 do p:=p^.ptr;
    if fCOMPUTIL(p,year,month,day)=0 then begin
      nbreenr:=1;qutil:=p;
      while qutil^.ptr^.day_util=day do begin
        inc(nbreenr);qutil:=qutil^.ptr;
        end;
      end;
    end;
  end
else p:=nil;
end;


PROCEDURE pCHERCHEMEMO(var p:tptrmemo;a:tptrmemo;year,month,day:word); far;
{*******************************************************}
{ Nbreenr donne nombre de pr‚sence year/month/day dans la liste a
{ p=‚l‚ment de liste ou nil
{ si a=nil                  p pointe nil
{    trouv‚                 p pointe premier enr
{    pas trouv‚             p pointe enr suivant
{    pas trouv‚+date>liste  p pointe a
{    pas trouv‚+date<liste  p pointe nil
{*******************************************************}
begin
nbreenr:=0;
if a<>nil then begin
  if fCOMPMEMO(p,year,month,day)=-1 then p:=a;
  if fCOMPMEMO(p,year,month,day)>-1 then begin
    while fCOMPMEMO(p,year,month,day)=1 do p:=p^.ptr;
    if fCOMPMEMO(p,year,month,day)=0 then begin
      nbreenr:=1;qmemo:=p;
      while qmemo^.ptr^.day_memos=day do begin
        inc(nbreenr);qmemo:=qmemo^.ptr;
        end;
      end;
    end;
  end
else p:=nil;
end;


PROCEDURE pCHERCHEBOITE(var p:tptrboite;a:tptrboite;year,month,day:word); far;
{*******************************************************}
{ Nbreenr donne nombre de pr‚sence year/month/day dans la liste a
{ p=‚l‚ment de liste ou nil
{ si a=nil                  p pointe nil
{    trouv‚                 p pointe premier enr
{    pas trouv‚             p pointe enr suivant
{    pas trouv‚+date>liste  p pointe a
{    pas trouv‚+date<liste  p pointe nil
{*******************************************************}
begin
nbreenr:=0;
if a<>nil then begin
  if fCOMPBOITE(p,year,month,day)=-1 then p:=a;
  if fCOMPBOITE(p,year,month,day)>-1 then begin
    while fCOMPBOITE(p,year,month,day)=1 do p:=p^.ptr;
    if fCOMPBOITE(p,year,month,day)=0 then begin
      nbreenr:=1;qboite:=p;
      while qboite^.ptr^.day_boite=day do begin
        inc(nbreenr);qboite:=qboite^.ptr;
        end;
      end;
    end;
  end
else p:=nil;
end;


PROCEDURE pINSEREMEMO(p:tptrmemo;var a:tptrmemo); far;
{*******************************************************}
{ p<>nil ne doit pas ˆtre dans la liste a
{*******************************************************}
begin
if a=nil then a:=p
else begin
  if fCOMPMEMO(p,a^.year_memos,a^.month_memos,a^.day_memos)=1 then begin   {p>a}
    p^.ptr:=a;a:=p;
    end
  else begin                                             {p<a}
    qmemo:=a;
    while fCOMPMEMO(qmemo^.ptr,p^.year_memos,p^.month_memos,p^.day_memos)=1 do
      qmemo:=qmemo^.ptr;
    p^.ptr:=qmemo^.ptr;qmemo^.ptr:=p;
    end;
  end;
end;


PROCEDURE pSUPPRIMEMEMO(p:tptrmemo;var a:tptrmemo); far;
{*******************************************************}
{ p<>nil doit ˆtre dans la liste a
{*******************************************************}
begin
if p=a then a:=a^.ptr
else begin
  qmemo:=a;
  while qmemo^.ptr<>p do qmemo:=qmemo^.ptr;
  qmemo^.ptr:=p^.ptr;
  end;
end;


PROCEDURE pLIGNE(s:string); far;
{*******************************************************}
{Trace ligne avec titre
{*******************************************************}
begin
textattr:=attr_normalbis;
write('ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');
gotoxy(1,wherey-1);writeln(s);
end;


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


FUNCTION MOT_DE_PASSE:string; far;
{*******************************************************}
{Demande code de 8 lettres … la position curseur.
{Tous les caractŠres entre ' '=#32 et '~'=#126 sont accept‚s.
{Renvoi ce code (8 caractŠres maximum ou une chaine vide.
{*******************************************************}
label BOUCLE;
var event:tevent;
    scan:integer;
    ascii:char;
    x,y:integer;
    i:integer;
    s:string[8];
begin
x:=wherex;y:=wherey;s:='';
BOUCLE:
textattr:=attr_normalbis;gotoxy(x,y);
for i:=1 to length(s) do write('.');
write('_');clreol;
repeat
  getkeyevent(event);
  if timer<1 then begin
    case options.son of
      0:delay(10);
      1:begin
        sound(5000);delay(10);nosound;
        end;
      end;
    SAUVEXY;
    CAPTURESCREEN(1,1,80,nbre_lignes,win);
    gadgeco;
    {Dessin logo}
    BUILDLOGO(17,22,nbre_pixel_y,attr_logo,logo);
    RESTORESCREEN(win);
    RESTAUREXY;
    CURSOROFF;
    timer:=options.delai_eco;
    end;
  until event.what=evkeydown;
timer:=options.delai_eco;
scan:=event.scancode;
ascii:=event.charcode;
if scan=$01 then begin {Escape}
  s:='';scan:=$1C
  end;
if scan=$1C then begin {Enter}
  textattr:=attr_normalbis;gotoxy(x,y);
  for i:=1 to length(s) do write('.');
  MOT_DE_PASSE:=s;
  exit;
  end;
if scan=$0E then s:=copy(s,1,length(s)-1);
if (ascii>' ') and (ascii<'~') and (length(s)<8) then s:=s+ascii;
goto BOUCLE;
end;


PROCEDURE pWAIT; far;
{*******************************************************}
{Bip suivie d'une attente de 2 secondes
{*******************************************************}
begin
case options.son of
  0:delay(2000);
  1:begin
    sound(500);delay(50);nosound;delay(2000);
    end;
  end;
end;


PROCEDURE pMENU(nbremenu:integer;var choix:integer); far;
{*******************************************************}
{Affiche page ‚cran en fonction du niveau
{Attend choix jusque sa validation
{*******************************************************}
label lDEBUTMENU;
var b:boolean;
    c:char;
    i,ii:integer;
    r:real;
    s:string;
    choixok:boolean;
begin
choixok:=false;
{Affiche menu}
window(1,(jour0 div 160)-3,40,ligne-11);textattr:=attr_normal;clrscr;
window(1,(jour0 div 160)-1,40,(jour0 div 160)-1);textattr:=attr_menu_titre;clreol;
gotoxy(20-round(length(menu[0].phrase)/2),1);write(menu[0].phrase);
FENETRE(attr_menu_normal,1,(jour0 div 160),40,(jour0 div 160)+nbremenu+1);
lDEBUTMENU:
if (scan<>$49) and (scan <>$51) then begin
  pCHERCHEUTIL(putil,autil,year_util,month_util,day_util);
  enrcur:=nbreenr;
  end;
{R‚‚cris lignes du menu}
window(2,(jour0 div 160)+1,39,(jour0 div 160)+nbremenu+1);
for i:=1 to nbremenu do begin
  if choix=i then begin textattr:=attr_menu_inverse;end
  else begin textattr:=attr_menu_normal;end;
  write(' ',menu[i].phrase);clreol;
  textcolor(textebis_menu);gotoxy(menu[i].place+1,i);
  writeln(menu[i].phrase[menu[i].place]);
  end;
{R‚‚cris jours du calendrier}
niveau:=level1*1000+level2*100+level3*10+level4;
if level1=0 then niveau:=niveau+choix*1000
else if level2=0 then niveau:=niveau+choix*100
  else if level3=0 then niveau:=niveau+choix*10
    else if level4=0 then niveau:=niveau+choix;
{Dessin calendriers}
for calendrier:=1 to 3 do begin
  case calendrier of
    1:begin
      jourbis:=jour1;
      yearbis:=year_util;monthbis:=month_util;daybis:=day_util;
      window(45,(jourbis div 160)-1,80,(jourbis div 160)-1);textattr:=attr_menu_titre;
      write(' ESPION: ',JOUR(dayofweek_util),' ',day_util,' ',MOIS(month_util),' ',year_util);clreol;
      end;
    2:begin
      jourbis:=jour2;
      yearbis:=year_memos;monthbis:=month_memos;daybis:=day_memos;
      window(45,(jourbis div 160)-3,80,(jourbis div 160)-3);textattr:=attr_menu_titre;
      write(' MEMOS : ',JOUR(dayofweek_memos),' ',day_memos,' ',MOIS(month_memos),' ',year_memos);clreol;
      end;
    3:begin
      jourbis:=jour3;
      yearbis:=year_boite;monthbis:=month_boite;daybis:=day_boite;
      window(45,(jourbis div 160)-3,80,(jourbis div 160)-3);textattr:=attr_menu_titre;
      write(' BOITE',noboite,': ',JOUR(dayofweek_boite),' ',day_boite,' ',MOIS(month_boite),' ',year_boite);clreol;
      end;
    end;
  for i:=1 to NBREJOUR(yearbis,monthbis) do begin
    nbreenr:=0;
    case calendrier of
      1:pCHERCHEUTIL(putil,autil,year_util,month_util,i);
      2:pCHERCHEMEMO(pmemo,amemo,year_memos,month_memos,i);
      3:pCHERCHEBOITE(pboite,aboite,year_boite,month_boite,i);
      end;
    if i<12 then ii:=jourbis
      else if i<23 then ii:=jourbis+94
        else ii:=jourbis+188;
    mem[videoseg:ii-2+i*6]:=attr_menu_invisible;
    mem[videoseg:ii+4+i*6]:=attr_menu_invisible;
    if nbreenr<1 then begin
      mem[videoseg:ii+i*6]:=attr_menu_normal;
      mem[videoseg:ii+2+i*6]:=attr_menu_normal;
      end
    else begin
      mem[videoseg:ii+i*6]:=attr_menu_normalbis;
      mem[videoseg:ii+2+i*6]:=attr_menu_normalbis;
      end;
    end;
  {Efface jours fin mois}
  if NBREJOUR(yearbis,monthbis)<31 then begin
    mem[videoseg:jourbis+186+31*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+188+31*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+190+31*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+192+31*6]:=attr_menu_invisible;
    end;
  if NBREJOUR(yearbis,monthbis)<30 then begin
    mem[videoseg:jourbis+186+30*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+188+30*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+190+30*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+192+30*6]:=attr_menu_invisible;
    end;
  if NBREJOUR(yearbis,monthbis)<29 then begin
    mem[videoseg:jourbis+186+29*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+188+29*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+190+29*6]:=attr_menu_invisible;
    mem[videoseg:jourbis+192+29*6]:=attr_menu_invisible;
    end;
  {Fond inverse pour daybis}
  if daybis<12 then ii:=jourbis
    else if daybis<23 then ii:=jourbis+94
      else ii:=jourbis+188;
  if mem[videoseg:ii+daybis*6]=attr_menu_normalbis then begin
    mem[videoseg:ii-2+daybis*6]:=attr_menu_inverse;
    mem[videoseg:ii-3+daybis*6]:=curseur_page;
    mem[videoseg:ii+daybis*6]:=attr_menu_inversebis;
    mem[videoseg:ii+2+daybis*6]:=attr_menu_inversebis;
    mem[videoseg:ii+4+daybis*6]:=attr_menu_normal;
    mem[videoseg:ii+3+daybis*6]:=curseur_page;
    end
  else begin
    mem[videoseg:ii-2+daybis*6]:=attr_menu_inverse;
    mem[videoseg:ii-3+daybis*6]:=curseur_page;
    mem[videoseg:ii+daybis*6]:=attr_menu_inverse;
    mem[videoseg:ii+2+daybis*6]:=attr_menu_inverse;
    mem[videoseg:ii+4+daybis*6]:=attr_menu_normal;
    mem[videoseg:ii+3+daybis*6]:=curseur_page;
    end;
  end;
{Affiche fˆte et propri‚taire boite}
window(45,(jour2 div 160)-1,79,(jour2 div 160));
textattr:=attr_menu_normal;write('³ FETE : ',fete[month_memos][day_memos]);clreol;
window(45,(jour3 div 160)-1,79,(jour3 div 160));
textattr:=attr_menu_normal;write('³ PROPRIETAIRE: ');clreol;
writeln(options.proprio[noboite]);
{Recherche calendrier actif}
calendrier:=0;
if level1=0 then case choix of
  1:calendrier:=1;
  4:calendrier:=2;
  5:calendrier:=3;
  end
else case level1 of
  1:calendrier:=1;
  4:calendrier:=2;
  5:calendrier:=3;
  end;
{Affiche notes}
window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
  case niveau of
  1000,1100,1200,1300:begin
    pLIGNE('ACTIVITE PC');
    pCHERCHEUTIL(putil,autil,year_util,month_util,day_util);
    if nbreenr>0 then begin
      if nbreenr>(nbre_lignes-ligne-3) then begin
        textattr:=attr_normal;gotoxy(67,2);write('(Page Up/Down)');gotoxy(1,2);
        end;
      textattr:=attr_normal;write('PC allum‚/reboot‚ ',nbreenr,' fois le ');
      writeln(JOUR(dayofweek_util)+' '+JMA(year_util,month_util,day_util),':');
      qutil:=putil;
      for i:=1 to (nbreenr-enrcur) do qutil:=qutil^.ptr;
      {qutil pointe dernier … visualiser=enrcur-ieme chronologiquement }
      for i:=(nbre_lignes-ligne-3) downto 1 do begin
        if enrcur-i>=0 then begin
          gotoxy(1,i+2);textattr:=attr_normalbis;
          if enrcur>(nbre_lignes-ligne-3) then write(FILLZERO(enrcur-(nbre_lignes-ligne-3)+i,2),'>')
          else write(FILLZERO(i,2),'>');
          textattr:=attr_normal;write('   DEBUT:');
          textattr:=attr_normalbis;write(FILLZERO(qutil^.hour_util,2),':',FILLZERO(qutil^.minute_util,2));
          textattr:=attr_normal;write('   FIN:');
          if qutil^.year_utilfin<>0 then begin
            textattr:=attr_normalbis;write(FILLZERO(qutil^.hour_utilfin,2),':',FILLZERO(qutil^.minute_utilfin,2));
            textattr:=attr_normal;write('   DUREE:');
            textattr:=attr_normalbis;
            pDUREE(qutil,r);
            if trunc(r)=0 then write(round(frac(r)*60),' mn')
            else write(trunc(r),' h ',FILLZERO(round(frac(r)*60),2),' mn');
            end
          else begin
            textattr:=attr_normalbis;
            if qutil=autil then write('En fonctionnement')
            else write('Non signal‚e');
            end;
          qutil:=qutil^.ptr;
          end;
        writeln;
        end;
      end
    else begin
      textattr:=attr_normal;write('PC non utilis‚ le ');
      writeln(JOUR(dayofweek_util)+' '+JMA(year_util,month_util,day_util),'.');
      end;
    end;
  2000,2100,2200,2300:begin
    pLIGNE('MESSAGE D''ACCUEIL');
    i:=fNBRELIGNE(options.mess);
    textattr:=attr_normal;
    if i>0 then begin
      for ii:=1 to i do begin
        gotoxy(1,ii+1);writeln(options.mess[ii]);
        end;
      gotoxy(1,ii+2);
      end
    else writeln('Aucun');
    end;
  3000:begin
    pLIGNE('MOT DE PASSE');
    textattr:=attr_normal;write('DerniŠre tentative violation: ');
    textattr:=attr_normalbis;
    if options.year_violation=0 then writeln('Aucune')
    else begin
      write(JMA(options.year_violation,options.month_violation,options.day_violation));
      writeln(' … ',HMS(options.hour_violation,options.minute_violation,60));
      end;
    if DECODE(options.code['0'],0)='' then s:='Non' else s:='Oui';
    textattr:=attr_normal;write('Mot de passe actif:           ');
    textattr:=attr_normalbis;writeln(s);
    end;
  4000,4100,4200,4300,4400:begin
    pLIGNE('MEMOS DU '+JMA(year_memos,month_memos,day_memos));
    pCHERCHEMEMO(pmemo,amemo,year_memos,month_memos,day_memos);
    textattr:=attr_normal;
    if nbreenr>0 then begin
      i:=fNBRELIGNE(pmemo^.mess);
      for ii:=1 to i do begin
        gotoxy(1,ii+1);write(pmemo^.mess[ii]);
        end;
      gotoxy(1,ii+2);
      end
    else writeln('Aucun');
    end;
  5000:begin
    pLIGNE('MESSAGERIE');
    for c:='1' to '9' do begin
      textattr:=attr_normal;write('La boite aux lettres ');
      case c of
        '1':begin
          textattr:=attr_normalbis;write('No 1');
          textattr:=attr_normal;write(' est une boite ');
          textattr:=attr_normalbis;writeln('publique');
          end;
        '2'..'9':begin
          if options.proprio[c]='' then writeln('No ',c,' est sans propri‚taire')
          else begin
            textattr:=attr_normalbis;write('No ',c);
            textattr:=attr_normal;write(' appartient  … ');
            textattr:=attr_normalbis;writeln(options.proprio[c]);
            end;
          end;
        end;
      end;
    end;
  5100,5200,5300,5400,5500,5600:begin
    pLIGNE('MESSAGERIE');
    textattr:=attr_normal;write('No boite ouverte : ');
    textattr:=attr_normalbis;writeln(noboite);
    textattr:=attr_normal;write('Nom Propri‚taire : ');
    textattr:=attr_normalbis;
    writeln(options.proprio[noboite]);
    pCHERCHEBOITE(pboite,aboite,year_boite,month_boite,day_boite);
    if nbreenr>0 then begin
      textattr:=attr_normalbis;write(nbreenr);
      textattr:=attr_normal;write(' courrier(s) d‚pos‚(s) le ');
      end
    else begin
      textattr:=attr_normal;write('Aucun courrier depos‚ le ');
      end;
    writeln(JOUR(dayofweek_boite)+' '+JMA(year_boite,month_boite,day_boite),'.');
    end;
  7000,7100,7200,7300,7400,7500,7510,7520,7530,7600,7610,7620,7630,7640,7650,7660,7670,7680,7690,7700,7710,7720,7730,7740:begin
    pLIGNE('OPTIONS');
    case options.optboot of
      1:s:='Type GadgetPC';
      2:s:='Type classique';
      else begin writeln('Erreur: Mauvaise option boot.');ARRET;end;
      end;
    textattr:=attr_normal;write('Option pr‚sentation boot: ');
    textattr:=attr_normalbis;writeln(s);
    if options.optmemos>0 then begin
      str(options.optmemos,s);
      s:='-'+s;end
    else s:='';
    textattr:=attr_normal;write('Option rappel m‚mos:      ');
    textattr:=attr_normalbis;writeln('Jour J',s);
    if options.optcourrier=0 then s:='Non' else s:='Oui';
    textattr:=attr_normal;write('Option rappel courrier:   ');
    textattr:=attr_normalbis;writeln(s);
    if options.pause=0 then s:='Non' else s:='Oui';
    textattr:=attr_normal;write('Pause aprŠs rappels:      ');
    textattr:=attr_normalbis;writeln(s);
    str(options.delai_eco,s);
    textattr:=attr_normal;write('D‚lai ‚conomiseur ‚cran:  ');
    textattr:=attr_normalbis;writeln(s,' s.');
    end;
  else begin end; {passage par ce cas pour mot de passe,...}
  end;

if choixok then exit;

CLAVIERSOURIS(clavier,scan,ascii,x,y);
case clavier of
  true:begin
    case scan of
      $1C:choixok:=true;                 {   Enter   }
      $01:if level1<>0  then begin       {   Break   }
            choix:=nbremenu;
            exit;
            end;
      $48:if choix>1 then dec(choix);    {   Haut    }
      $50:                               {   Bas     }
          if choix<nbremenu then inc(choix);
      $49:if nbreenr>(nbre_lignes-ligne-3) then begin      {  Page up  }
            dec(enrcur);
            if enrcur<(nbre_lignes-ligne-3) then enrcur:=(nbre_lignes-ligne-3);
            end;
      $51:if nbreenr>(nbre_lignes-ligne-3) then begin      { Page down }
            inc(enrcur);
            if enrcur>nbreenr then enrcur:=nbreenr;
            end;
      $4B:case calendrier of             {  Gauche   }
        1:JOURPRECEDANT(year_util,month_util,day_util,dayofweek_util);
        2:JOURPRECEDANT(year_memos,month_memos,day_memos,dayofweek_memos);
        3:JOURPRECEDANT(year_boite,month_boite,day_boite,dayofweek_boite);
        end;
      $4D:case calendrier of             {  Droite   }
        1:JOURSUIVANT(year_util,month_util,day_util,dayofweek_util);
        2:JOURSUIVANT(year_memos,month_memos,day_memos,dayofweek_memos);
        3:JOURSUIVANT(year_boite,month_boite,day_boite,dayofweek_boite);
        end;
      $73:case calendrier of             {CTRL+Gauche}
        1:begin
          MOISPRECEDANT(year_util,month_util);
          if day_util>NBREJOUR(year_util,month_util) then day_util:=NBREJOUR(year_util,month_util);
          dayofweek_util:=JOURDESEMAINE(year_util,month_util,day_util);
          end;
        2:begin
          MOISPRECEDANT(year_memos,month_memos);
          if day_memos>NBREJOUR(year_memos,month_memos) then day_memos:=NBREJOUR(year_memos,month_memos);
          dayofweek_memos:=JOURDESEMAINE(year_memos,month_memos,day_memos);
          end;
        3:begin
          MOISPRECEDANT(year_boite,month_boite);
          if day_boite>NBREJOUR(year_boite,month_boite) then day_boite:=NBREJOUR(year_boite,month_boite);
          dayofweek_boite:=JOURDESEMAINE(year_boite,month_boite,day_boite);
          end;
        end;
      $74:case calendrier of             {CTRL+Droite}
        1:begin
          MOISSUIVANT(year_util,month_util);
          if day_util>NBREJOUR(year_util,month_util) then day_util:=NBREJOUR(year_util,month_util);
          dayofweek_util:=JOURDESEMAINE(year_util,month_util,day_util);
          end;
        2:begin
          MOISSUIVANT(year_memos,month_memos);
          if day_memos>NBREJOUR(year_memos,month_memos) then day_memos:=NBREJOUR(year_memos,month_memos);
          dayofweek_memos:=JOURDESEMAINE(year_memos,month_memos,day_memos);
          end;
        3:begin
          MOISSUIVANT(year_boite,month_boite);
          if day_boite>NBREJOUR(year_boite,month_boite) then day_boite:=NBREJOUR(year_boite,month_boite);
          dayofweek_boite:=JOURDESEMAINE(year_boite,month_boite,day_boite);
          end;
        end;
      else for i:=1 to nbremenu do begin { Raccourci }
        if upcase(ascii)=upcase(menu[i].phrase[menu[i].place]) then begin
          choix:=i;choixok:=true;
          end;
        end;
      end;
    end;
  false:begin                            {  Souris   }
    if (x<40) and (y>(jour0 div 160)-3) and (y<(jour0 div 160)+nbremenu+1) then begin
      if choix=y-(jour0 div 160) then choixok:=true
      else choix:=y-(jour0 div 160);
      end;
    if ((level1=0) or (level1=1)) and (x>45) and (x<79) and (y>(jour1 div 160)) and (y<(jour1 div 160)+4) then begin
      if level1=0 then choix:=1;
      day_util:=(11*(y-(jour1 div 160))+trunc((x-46)/3)-10);
      if day_util>NBREJOUR(year_util,month_util) then day_util:=NBREJOUR(year_util,month_util);
      dayofweek_util:=JOURDESEMAINE(year_util,month_util,day_util);
      end;
    if ((level1=0) or (level1=4)) and (x>45) and (x<79) and (y>(jour2 div 160)) and (y<(jour2 div 160)+4) then begin
      if level1=0 then choix:=4;
      day_memos:=(11*(y-(jour2 div 160))+trunc((x-46)/3)-10);
      if day_memos>NBREJOUR(year_memos,month_memos) then day_memos:=NBREJOUR(year_memos,month_memos);
      dayofweek_memos:=JOURDESEMAINE(year_memos,month_memos,day_memos);
      end;
    if ((level1=0) or (level1=5)) and (x>45) and (x<79) and (y>(jour3 div 160)) and (y<(jour3 div 160)+4) then begin
      if level1=0 then choix:=5;
      day_boite:=(11*(y-(jour3 div 160))+trunc((x-46)/3)-10);
      if day_boite>NBREJOUR(year_boite,month_boite) then day_boite:=NBREJOUR(year_boite,month_boite);
      dayofweek_boite:=JOURDESEMAINE(year_boite,month_boite,day_boite);
      end;
    end;
  end;
goto lDEBUTMENU;
end;


PROCEDURE pEDITMESSAGE(var mess:tmess;var save:boolean); far;
{*******************************************************}
{ Entr‚e mess
{ Sortie mess
{        save
{*******************************************************}
label lEDITMESSAGE;
var b:boolean;
    i,ii,j,jj,k,kk:integer;
    dernier_ligne:integer;
    s:string[80];
    xcur,ycur:shortint;
begin
ii:=day;
jj:=month;
kk:=year;
{V‚rifie date ‚dition m‚mos}
if (level1=4) and (SIGNE((ii-day_memos)+31*((jj-month_memos)+12*(kk-year_memos)))=1) then begin
  writeln;
  textattr:=attr_normal;writeln('Attention: Vous ‚ditez des m‚mos pour un jour pass‚.');
  textattr:=attr_normalbis;write('Editer quand mˆme (O/N) ? ');
  CLAVIERSOURIS(clavier,scan,ascii,x,y);
  if upcase(ascii)='N' then begin level3:=0;exit;end;
  end;
{Affiche notes}
window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
case level1 of
  2:pLIGNE('EDITION MESSAGE D''ACCUEIL');
  4:pLIGNE('EDITION MEMOS DU '+JMA(year_memos,month_memos,day_memos));
  5:pLIGNE('EDITION COURRIER LE '+JMA(year_boite,month_boite,day_boite));
  end;
xcur:=1;ycur:=1;save:=false;

lEDITMESSAGE:
window(1,ligne+1,80,nbre_lignes);textattr:=attr_normal;clrscr;
dernier_ligne:=fNBRELIGNE(mess);
if dernier_ligne=0 then begin
  mess[1]:=' ';dernier_ligne:=1;
  end;
for i:=1 to dernier_ligne do begin
  gotoxy(1,i);write(mess[i]);
  end;
gotoxy(xcur,ycur);textattr:=attr_inverse;
if xcur>length(mess[ycur]) then write(' ')
else write(mess[ycur][xcur]);
gotoxy(1,dernier_ligne+1);pLIGNE('');write('ESCAPE pour finir...');
CLAVIERSOURIS(clavier,scan,ascii,x,y);
case clavier of
  true:begin
    case scan of
      $1C:begin                               {Enter }
        if dernier_ligne=8 then begin
          if ycur<8 then inc(ycur);
          end
        else begin
          for i:=dernier_ligne+1 downto ycur+2 do mess[i]:=mess[i-1];
          mess[ycur+1]:=copy(mess[ycur],xcur,80);
          mess[ycur]:=copy(mess[ycur],1,xcur-1);
          if mess[ycur]='' then mess[ycur]:=' ';
          if mess[ycur+1]='' then mess[ycur+1]:=' ';
          inc(ycur);
          save:=true;
          end;
        xcur:=1;
        end;
      $48:if (ycur>1) and (ascii=#0) then dec(ycur);         { haut }
      $50:if (ycur<dernier_ligne) and (ascii=#0) then inc(ycur); { Bas  }
      $4B:if ascii=#0 then begin              {Gauche}
        if xcur>1 then dec(xcur)
        else if ycur>1 then begin
          dec(ycur);
          xcur:=80;
          end;
        end;
      $4D:if ascii=#0 then begin              {Droite}
        if xcur<80 then inc(xcur)
        else if ycur<dernier_ligne then begin
          xcur:=1;
          inc(ycur);
          end;
        end;
      $0E:begin                            {BACKSPACE}
        if xcur>1 then begin
          delete(mess[ycur],xcur-1,1);
          if mess[ycur]='' then mess[ycur]:=' ';
          dec(xcur);
          end
        else
          if (ycur>1) and CHAINEVIERGE(mess[ycur]) then begin
            for i:=ycur to (dernier_ligne-1) do mess[i]:=mess[i+1];
            mess[dernier_ligne]:='';
            dec(ycur);
            end
          else
            if (ycur>1) and CHAINEVIERGE(mess[ycur-1]) then begin
              for i:=ycur-1 to (dernier_ligne-1) do mess[i]:=mess[i+1];
              mess[dernier_ligne]:='';
              dec(ycur);
              end;
        save:=true;
        end;
      $53:begin                               { DEL }
        if CHAINEVIERGE(copy(mess[ycur],xcur,80)) then begin
          if (CHAINEVIERGE(mess[ycur])) then begin
            if ycur<dernier_ligne then begin
              for i:=ycur to (dernier_ligne-1) do mess[i]:=mess[i+1];
              mess[dernier_ligne]:='';
              end
            else begin
              if ycur>1 then begin
                mess[dernier_ligne]:='';dec(ycur);
                end;
              end;
            end
          else begin
            if (ycur<dernier_ligne) and CHAINEVIERGE(mess[ycur+1]) then begin
              for i:=ycur+1 to (dernier_ligne-1) do mess[i]:=mess[i+1];
              mess[dernier_ligne]:='';
              end;
            end;
          end
        else begin
          delete(mess[ycur],xcur,1);
          if mess[ycur]='' then mess[ycur]:=' ';
          end;
        save:=true;
        end;
      $01:begin                               {Escape}
        b:=true;
        for i:=1 to 8 do b:=(b and CHAINEVIERGE(mess[i]));
        if b then for i:=1 to 8 do mess[i]:='';
        exit;
        end;
      end;
    if (ascii<>'-') or (xcur>1) then begin    { Char }
      if (ascii>=' ') and (ascii<='þ') then begin
        if (length(mess[ycur])>=xcur) then mess[ycur][xcur]:=ascii
        else begin
          for i:=length(mess[ycur])+1 to xcur-1 do mess[ycur]:=mess[ycur]+' ';
          mess[ycur]:=mess[ycur]+ascii;
          end;
        if xcur<80 then inc(xcur);
        save:=true;
        end;
      end;
    end;
  false:begin                                 {Souris}
    if (y>ligne) and (y<=ligne+dernier_ligne) then begin
      xcur:=x;ycur:=y-ligne;
      end
    else begin
      for i:=1 to 8 do b:=(b and CHAINEVIERGE(mess[i]));
      if b then save:=false;
      exit;
      end;
    end;
  end;
goto lEDITMESSAGE;
end;


PROCEDURE pSON; far;
{*******************************************************}
{Level1=6,Level 2=5
{Choix du son
{*******************************************************}
label lSON;
var save:boolean;
    choix:integer;
begin
choix:=1;
save:=false;
lSON:
menu[0].phrase:='SON';
menu[1].phrase:='Son du programme GADGETPC';menu[1].place:=18;
menu[2].phrase:='Son proc‚dure de fin END'; menu[2].place:=22;
menu[3].phrase:='Retour au menu pr‚c‚dent'; menu[3].place:=1;
{Choix level3}
level3:=0;
pMENU(3,choix);
case choix of
  1:begin
    case options.son of
      0:begin
        textattr:=attr_normalbis;writeln;writeln('Activer le son dans GADGETPC (O/N) ? ');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if upcase(ascii)='O' then begin
          save:=true;
          options.son:=1;
          textattr:=attr_normal;write('Son activ‚ !');
          pWAIT;
          end;
        end;
      1:begin
        textattr:=attr_normalbis;writeln;writeln('Supprimer le son dans GADGETPC (O/N) ? ');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if upcase(ascii)='O' then begin
          save:=true;
          options.son:=0;
          textattr:=attr_normal;write('Son neutralis‚ !');
          pWAIT;
          end;
        end;
      end;
    end;
  2:begin
    case options.son_end of
      0:begin
        textattr:=attr_normalbis;writeln;writeln('Activer le signal sonore de la proc‚dure de fin END (O/N) ? ');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if upcase(ascii)='O' then begin
          save:=true;
          options.son_end:=1;
          textattr:=attr_normal;write('Signal activ‚ !');
          pWAIT;
          end;
        end;
      1:begin
        textattr:=attr_normalbis;writeln;writeln('Supprimer le signal sonore de la proc‚dure de fin END (O/N) ? ');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if upcase(ascii)='O' then begin
          save:=true;
          options.son_end:=0;
          textattr:=attr_normal;write('Signal neutralis‚ !');
          pWAIT;
          end;
        end;
      end;
    end;
  3:begin if save then pECRIREOPTIONS;level3:=0;exit;end;
  end;
goto lSON;
end;




PROCEDURE pCOULEURS; far;
{*******************************************************}
{Level1=6,Level 2=6
{Choix des couleurs
{*******************************************************}
label lCOULEURS;
var save:boolean;
    choix:integer;
    s:string;
    i:integer;
begin
choix:=1;
save:=false;
lCOULEURS:
menu[0].phrase:= 'COULEURS';
menu[1].phrase:= 'Fond titre';              menu[1].place:=1;
menu[2].phrase:= 'Texte titre';             menu[2].place:=1;
menu[3].phrase:= 'Fond';                    menu[3].place:=2;
menu[4].phrase:= 'Texte';                   menu[4].place:=2;
menu[5].phrase:= 'Texte bis';               menu[5].place:=3;
menu[6].phrase:= 'Logo';                    menu[6].place:=1;
menu[7].phrase:= 'Fond titre menu';         menu[7].place:=7;
menu[8].phrase:= 'Texte titre menu';        menu[8].place:=13;
menu[9].phrase:= 'Fond menu';               menu[9].place:=8;
menu[10].phrase:='Texte menu';              menu[10].place:=10;
menu[11].phrase:='Texte menu bis';          menu[11].place:=12;
menu[12].phrase:='Couleurs par d‚faut';     menu[12].place:=14;
menu[13].phrase:='Retour au menu pr‚c‚dent';menu[13].place:=1;
{Choix level3}
level3:=0;
pMENU(13,choix);
case choix of
  1:begin
    save:=true;
    inc(fond_barre_titre,$10);
    if fond_barre_titre>$70 then fond_barre_titre:=0;
    end;
  2:begin
    save:=true;
    inc(texte_barre_titre);
    if texte_barre_titre>15 then texte_barre_titre:=0;
    if texte_barre_titre=fond_barre_titre shr 4 then inc(texte_barre_titre);
    if texte_barre_titre>15 then texte_barre_titre:=0;
    end;
  3:begin
    save:=true;
    inc(fond,$10);
    if fond>$70 then fond:=0;
    end;
  4:begin
    save:=true;
    inc(texte);
    if texte>7 then texte:=0;
    if texte=fond shr 4 then inc(texte);
    if texte>7 then texte:=0;
    end;
  5:begin
    save:=true;
    inc(textebis);
    if textebis>15 then textebis:=0;
    while (textebis=fond shr 4) or (textebis=texte) do inc(textebis);
    if textebis>15 then textebis:=0;
    end;
  6:begin
    save:=true;
    inc(texte_logo);
    if texte_logo>15 then texte_logo:=0;
    end;
  7:begin
    save:=true;
    inc(fond_menu_titre,$10);
    if fond_menu_titre>$70 then fond_menu_titre:=0;
    end;
  8:begin
    save:=true;
    inc(texte_menu_titre);
    if texte_menu_titre>15 then texte_menu_titre:=0;
    if texte_menu_titre=fond_menu_titre shr 4 then inc(texte_menu_titre);
    if texte_menu_titre>15 then texte_menu_titre:=0;
    end;
  9:begin
    save:=true;
    inc(fond_menu,$10);
    if fond_menu>$70 then fond_menu:=0;
    end;
  10:begin
    save:=true;
    inc(texte_menu);
    if texte_menu>7 then texte_menu:=0;
    if texte_menu=fond_menu shr 4 then inc(texte_menu);
    if texte_menu>7 then texte_menu:=0;
    end;
  11:begin
    save:=true;
    inc(textebis_menu);
    if textebis_menu>15 then textebis_menu:=0;
    while (textebis_menu=fond_menu shr 4) or (textebis_menu=texte_menu) do inc(textebis_menu);
    if textebis_menu>15 then textebis_menu:=0;
    end;
  12:begin
    save:=true;
    {Couleurs par d‚faut 1}
    fond:=$0;texte:=$07;textebis:=$0F;
    fond_barre_titre:=$30;texte_barre_titre:=$0;
    fond_menu_titre:=$10;texte_menu_titre:=$0F;
    fond_menu:=$70;texte_menu:=$0;textebis_menu:=$0F;
    texte_logo:=$08;
    end;
  13:begin if save then pECRIREOPTIONS;level3:=0;exit;end;
  end;
{Red‚finition des nouveaux attributs couleurs}
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
{Redessine ‚cran avec nouvelle couleur}
textattr:=attr_normal;window(1,1,80,nbre_lignes);clrscr;
{Dessin logo}
BUILDLOGO(17,22,nbre_pixel_y,attr_logo,logo);
{Dessin barre de titre}
BARRE_TITRE(attr_barre_titre,'GADGETPC',version);writeln;
window(60,1,80,1);write(JMA(year,month,day),'  ',HMS(hour,minute,seconde));
{Dessin permanent calendrier 1}
FENETRE(attr_menu_normal,45,(jour1 div 160),80,(jour1 div 160)+4);
window(47,(jour1 div 160)+1,79,(jour1 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(FILLZERO(i,2),' ');
{Dessin permanant calendrier 2}
FENETRE(attr_menu_normal,45,(jour2 div 160)-2,80,(jour2 div 160)+4);
window(45,(jour2 div 160),80,(jour2 div 160)+1);
textattr:=attr_menu_normal;write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
window(47,(jour2 div 160)+1,79,(jour2 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(FILLZERO(i,2),' ');
{Dessin permanant calendrier 3}
FENETRE(attr_menu_normal,45,(jour3 div 160)-2,80,(jour3 div 160)+4);
window(45,(jour3 div 160),80,(jour3 div 160)+1);
textattr:=attr_menu_normal;write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
window(47,(jour3 div 160)+1,79,(jour3 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(FILLZERO(i,2),' ');
goto lCOULEURS;
end;


PROCEDURE pMOTDEPASSE; far;
{*******************************************************}
{Demande mot de passe ou sa suppr‚ssion
{*******************************************************}
var s:string[8];
begin
if DECODE(options.code['0'],0)='' then begin
  textattr:=attr_normal;writeln;
  write('Attention: Si vous instaurez un mot de passe, il vous sera demand‚ … chaque fois');
  writeln('que vous allumerez votre ordinateur.');
  textattr:=attr_normalbis;writeln;write('Entrez le mot de passe … enregistrer (ESCAPE pour annuler): ');
  s:=MOT_DE_PASSE;
  if not CHAINEVIERGE(s) then begin
    options.code['0']:=CODE(s,0);
    pECRIREOPTIONS;
    textattr:=attr_normal;writeln;write('Mot de passe ‚tabli !');
    pWAIT;
    end;
  end
else begin
  textattr:=attr_normalbis;writeln;writeln('Supprimer le mot de passe (O/N) ?');
  CLAVIERSOURIS(clavier,scan,ascii,x,y);
  if upcase(ascii)='O' then begin
    gotoxy(wherex,wherey-1);textattr:=attr_normal;writeln('Supprimer le mot de passe (O/N) ?');
    textattr:=attr_normalbis;write('Entrez le mot de passe actuel pour autoriser sa suppression : ');
    s:=MOT_DE_PASSE;
    if (s=DECODE(options.code['0'],0)) or (s='101010') then begin
      options.code['0']:='';
      pECRIREOPTIONS;
      textattr:=attr_normal;writeln;write('Mot de passe supprim‚ !');
      pWAIT;
      end
    else begin
      textattr:=attr_normal;writeln;write('Mot de passe incorrect !  Sa suppression est interdite.');
      pWAIT;
      end;
    end;
  end;
end;


PROCEDURE pMESSAGEACCUEIL; far;
{*******************************************************}
{Propose menu Messageaccueil
{*******************************************************}
label lMESSAGE;
var choix:integer;
    b:boolean;
    i,ii:integer;
    mess:tmess;
begin
lMESSAGE:
i:=fNBRELIGNE(options.mess);
menu[0].phrase:='MESSAGE D''ACCUEIL';
if i=0 then begin
  menu[1].phrase:='Editer le message d''accueil';  menu[1].place:=1;
  menu[2].phrase:='- ';                            menu[2].place:=2;
  end
else begin
  menu[1].phrase:='Modifier le message d''accueil';menu[1].place:=1;
  menu[2].phrase:='Supprimer le message';          menu[2].place:=1;
  end;
menu[3].phrase:='Retour au menu principal';        menu[3].place:=1;
{Choix level3}
level2:=0;choix:=1;
pMENU(3,choix);
case choix of
  1:begin
    if i=0 then b:=true else b:=false;
    for i:=1 to 8 do
      if b then mess[i]:='' else mess[i]:=options.mess[i];
    pEDITMESSAGE(mess,save); {Dans pEDITMESSAGE un fenˆtre ligne+1 … nbre_lignes est d‚finie}
    i:=fNBRELIGNE(mess);
    if i>0 then begin
      textattr:=attr_normal;
      for ii:=1 to i do begin
        gotoxy(1,ii);clreol;write(mess[ii]);
        end;
      gotoxy(1,ii+4); {Place curseur deux crans sous la fin ‚dition message}
      if save=true then begin
        textattr:=attr_normalbis;
        if b then writeln('Instaurer message d''accueil (O/N) ? ')
        else writeln('Remplacer message d''accueil (O/N) ? ');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if upcase(ascii)='O' then begin
          for i:=1 to 8 do options.mess[i]:=mess[i];
          pECRIREOPTIONS;
          textattr:=attr_normal;
          if b then write('Message d''accueil instaur‚ !')
          else write('Message d''accueil remplac‚ !');
          pWAIT;
          end
        else begin
          textattr:=attr_normal;write('Op‚ration annul‚e !');
          pWAIT;
          end;
        end;
      end;
    end;
  2:if i>0 then begin
      textattr:=attr_normalbis;writeln;
      writeln('Supprimer le message d''accueil (O/N) ? ');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        for i:=1 to 8 do options.mess[i]:='';
        pECRIREOPTIONS;
        textattr:=attr_normal;write('Message supprim‚ !');
        pWAIT;
        end
      else begin
        textattr:=attr_normal;write('Op‚ration annul‚e !');
        pWAIT;
        end;
      end;
  3:begin level3:=0;exit;end;
  end;
goto lMESSAGE;
end;


PROCEDURE pMOUCHARD; far;
{*******************************************************}
{Propose menu Mouchard
{*******************************************************}
label lMOUCHARD;
var choix:integer;
    i,ii,j,jj,k,kk:integer;
    nbre_jours_utilisation:real;
    r,rr,rrr:real;
    s,ss:string;
begin
choix:=1;
lMOUCHARD:
menu[0].phrase:='MOUCHARD D''UTILISATION';
menu[1].phrase:='Supprimer fichier de sauvegarde';menu[1].place:=1;
menu[2].phrase:='Bilan des activit‚s du PC';      menu[2].place:=1;
menu[3].phrase:='Retour au menu principal';       menu[3].place:=1;
{Choix level2}
level2:=0;
pMENU(3,choix);
pCHERCHEUTIL(putil,autil,year_util,month_util,day_util);
case choix of
  1:if autil^.ptr<>nil then begin
      textattr:=attr_normal;
      window(1,ligne+1,80,nbre_lignes);clrscr;
      writeln;write('Attention:  Si vous effacez le fichier de sauvegarde des activit‚s du PC, toutes');
      writeln('les utilisations d‚tect‚es jusqu''aujourd''hui ne seront plus enregistr‚es.');
      textattr:=attr_normalbis;writeln;
      writeln('Supprimer fichier de sauvegarde (O/N) ? ');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        autil^.ptr:=nil;putil:=autil;
        pECRIREACTIVITE;
        textattr:=attr_normal;write('Fichier supprim‚ !');
        pWAIT;
        end;
      end;
  2:begin
    window(1,ligne,80,nbre_lignes);clrscr;
    pLIGNE('RESUME FICHIER ACTIVITE PC');
    putil:=autil;while putil^.ptr<>nil do putil:=putil^.ptr;
    textattr:=attr_normal;writeln;write('PremiŠre utilisation enregistr‚e le  ');
    textattr:=attr_normalbis;write(JMA(putil^.year_util,putil^.month_util,putil^.day_util));
    writeln('  '+FILLZERO(putil^.hour_util,2)+':'+FILLZERO(putil^.minute_util,2));
    textattr:=attr_normal;write('DerniŠre utilisation enregistr‚e le  ');
    textattr:=attr_normalbis;write(JMA(autil^.year_util,autil^.month_util,autil^.day_util));
    writeln('  '+FILLZERO(autil^.hour_util,2)+':'+FILLZERO(autil^.minute_util,2));
    writeln;
    i:=autil^.day_util  ;ii:=putil^.day_util;
    j:=autil^.month_util;jj:=putil^.month_util;
    k:=autil^.year_util ;kk:=putil^.year_util;
    if SIGNE(1+(i-ii)+31*((j-jj)+12*(k-kk)))<1 then begin
      writeln('Erreur: Fichier ACTIVITE.DAT non valide. Effacez le.');
      halt;
      end;
    nbre_jours_utilisation:=(1+(i-ii)+31*((j-jj)+12*(k-kk)));
    putil:=autil;i:=0;ii:=0;r:=0;rr:=0;rrr:=0;
    repeat
      inc(i);
      if putil^.year_utilfin<>0 then begin
        inc(ii);
        pDUREE(putil,rr);
        r:=r+rr;
        end;
      putil:=putil^.ptr;
      until putil=nil;
    str(i,s);rr:=i;
    str(ii,ss);rrr:=ii;
    { Affiche bilan }
    textattr:=attr_normal;write('PC allum‚/reboot‚    ');
    for i:=5 downto (length(s)-length(ss)) do write(' ');
    textattr:=attr_normalbis;write(s);
    textattr:=attr_normal;writeln(' fois');
    write('Fin d''utilisation signal‚e ');
    textattr:=attr_normalbis;write(ss);
    textattr:=attr_normal;writeln(' fois');
    write('Cumul des utilisations termin‚es par la proc‚dure END :  ');
    textattr:=attr_normalbis;
    if trunc(r)=0 then writeln(trunc(frac(r)*60),' mn')
    else writeln(trunc(r),' h ',FILLZERO(trunc(frac(r)*60),2),' mn');
    textattr:=attr_normal;
    write('Cumul de toutes les utilisations  (valeur statistique):  ');
    textattr:=attr_normalbis;
    if rrr<>0 then begin
      r:=r*rr/rrr; {r=cumul de toutes utilisations en minutes}
      if trunc(r)=0 then writeln(trunc(frac(r)*60),' mn')
      else writeln(trunc(r),' h ',FILLZERO(trunc(frac(r)*60),2),' mn');
      textattr:=attr_normal;
      writeln;
      write('Moyenne journaliŠre d''utilisation (valeur statistique):  ');
      r:=r/nbre_jours_utilisation; {r=moyenne journaliŠre en minute}
      textattr:=attr_normalbis;
      if trunc(r)=0 then writeln(trunc(frac(r)*60),' mn par jour')
      else writeln(trunc(r),' h ',FILLZERO(trunc(frac(r)*60),2),' mn  par jour');
      end
    else writeln('Incalculable');
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    end;
  3:begin level2:=0;exit;end;
  end;
goto lMOUCHARD;
end;


PROCEDURE pAGENDA; far;
{*******************************************************}
{*******************************************************}
label lAGENDA;
var choix:integer;
    i,ii:integer;
    s:string;
begin
choix:=1;
lAGENDA:
menu[0].phrase:='AGENDA';
menu[1].phrase:='Cr‚er/Modifier m‚mos';    menu[1].place:=1;
menu[2].phrase:='Supprimer m‚mos du jour'; menu[2].place:=1;
menu[3].phrase:='Supprimer vieux m‚mos';   menu[3].place:=11;
menu[4].phrase:='Retour au menu principal';menu[4].place:=1;
{Choix level2}
level2:=0;
pMENU(4,choix);
pCHERCHEMEMO(pmemo,amemo,year_memos,month_memos,day_memos);
{Ici nbreenr renvoy‚=0 ou 1}
i:=fNBRELIGNE(pmemo^.mess);
case choix of
  1:begin
    new(qmemo);
    if nbreenr>0 then begin
      qmemo^.year_memos:=pmemo^.year_memos;qmemo^.month_memos:=pmemo^.month_memos;
      qmemo^.day_memos:=pmemo^.day_memos;
      for i:=1 to 8 do qmemo^.mess[i]:=pmemo^.mess[i];
      end
    else begin
      qmemo^.year_memos:=year_memos;qmemo^.month_memos:=month_memos;
      qmemo^.day_memos:=day_memos;qmemo^.ptr:=nil;
      for i:=1 to 8 do qmemo^.mess[i]:='';
      end;
    pEDITMESSAGE(qmemo^.mess,save); {Dans pEDITMESSAGE un fenˆtre ligne+1 … nbre_lignes est d‚finie}
    i:=fNBRELIGNE(qmemo^.mess);
    if i>0 then begin
      for ii:=1 to i do begin
        textattr:=attr_normal;
        gotoxy(1,ii);clreol;write(qmemo^.mess[ii]);
        end;
      gotoxy(1,ii+4); {Place curseur deux crans sous la fin ‚dition message}
      if save then begin
        textattr:=attr_normalbis;
        if nbreenr>0 then writeln('Remplacer m‚mos du ',JMA(year_memos,month_memos,day_memos),' (O/N) ?')
        else writeln('Instaurer m‚mos pour le ',JMA(year_memos,month_memos,day_memos),' (O/N) ?');
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        if nbreenr>0 then begin
          if upcase(ascii)='O' then begin
            for i:=1 to 8 do pmemo^.mess[i]:=qmemo^.mess[i];
            pECRIREAGENDA;
            textattr:=attr_normal;write('M‚mos remplac‚s !');
            pWAIT;
            end
          else begin
            textattr:=attr_normal;write('Op‚ration annul‚e !');
            pWAIT;
            end;
          end
        else begin
          if upcase(ascii)='O' then begin
            pINSEREMEMO(qmemo,amemo);
            pECRIREAGENDA;
            textattr:=attr_normal;write('M‚mos instaur‚s !');
            pWAIT;
            end
          else begin
            textattr:=attr_normal;write('Op‚ration annul‚e !');
            pWAIT;
            end;
          end;
        end;
      end;
    end;
  2:if nbreenr>0 then begin
      textattr:=attr_normalbis;writeln;writeln('Supprimer les m‚mos du ',JMA(year_memos,month_memos,day_memos),' (O/N) ?');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        pSUPPRIMEMEMO(pmemo,amemo);
        pECRIREAGENDA;
        textattr:=attr_normal;write('M‚mos du ',JMA(year_memos,month_memos,day_memos),' supprim‚s !');
        pWAIT;
        end
      else begin
        textattr:=attr_normal;write('Op‚ration annul‚e !');
        pWAIT;
        end;
      end;
  3:if ((nbreenr>0) and (pmemo^.ptr<>nil))
      or ((nbreenr=0) and (pmemo<>nil)) then begin
      textattr:=attr_normalbis;writeln;
      writeln('Supprimer tous les m‚mos avant le ',JMA(year_memos,month_memos,day_memos),' (O/N) ?');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        case fCOMPMEMO(amemo,year_memos,month_memos,day_memos) of
          -1:begin amemo:=nil;pmemo:=nil;end;
          0:begin amemo^.ptr:=nil;pmemo:=amemo;end;
          1:begin
            pmemo:=amemo;
            while fCOMPMEMO(pmemo^.ptr,year_memos,month_memos,day_memos)>-1 do
              pmemo:=pmemo^.ptr;
            pmemo^.ptr:=nil;
            end;
          end;
        pECRIREAGENDA;
        textattr:=attr_normal;write('M‚mos supprim‚s !');
        pWAIT;
        end
      else begin
        textattr:=attr_normal;write('Op‚ration annul‚e !');
        pWAIT;
        end;
      end;
  4:begin level2:=0;exit;end;
  end;
goto lAGENDA;
end;


PROCEDURE pMESSAGERIE; far;
{*******************************************************}
{*******************************************************}
label lMESSAGERIE;
label ETIQUETTE;
var choix:integer;
    b:boolean;
    c:char;
    i,ii:integer;
    s:string;
begin
choix:=1;
noboite:='1';
lMESSAGERIE:
pLIREBOITE(noboite);
menu[0].phrase:='MESSAGERIE';
menu[1].phrase:='D‚poser un courrier dans une boite';  menu[1].place:=1;
menu[2].phrase:='Ouvrir une autre boite';              menu[2].place:=1;
menu[3].phrase:='Lire le(s) courrier(s) d‚pos‚(s)';    menu[3].place:=1;
menu[4].phrase:='Vider la boite de tous ses courriers';menu[4].place:=1;
menu[5].phrase:='Lib‚rer la boite de son propri‚taire';menu[5].place:=2;
menu[6].phrase:='Retour au menu principal';            menu[6].place:=1;
{Choix level2}
level2:=0;
pMENU(6,choix);
case choix of
  1:begin
    new(qboite);
    qboite^.year_boite:=year;qboite^.month_boite:=month;qboite^.day_boite:=day;
    for i:=1 to 8 do qboite^.mess[i]:='';
    pEDITMESSAGE(qboite^.mess,save); {pEDITMESSAGE cr‚e fenˆtre ligne+1 … nbre_lignes}
    i:=fNBRELIGNE(qboite^.mess);
    textattr:=attr_normal;writeln;
    if i>0 then begin
      for ii:=1 to i do begin
        gotoxy(1,ii);clreol;write(qboite^.mess[ii]);
        end;
      gotoxy(1,ii+1);
      writeln;
      write('D‚poser votre courrier dans quelle boite (');
      for c:='1' to '9' do begin
        textattr:=attr_normal;
        if options.proprio[c]<>'' then textattr:=attr_normalbis;
        write(c);
        textattr:=attr_normal;
        if c='9' then write(') ? ')
        else write(',');
        end;
      ETIQUETTE:
      repeat
        CLAVIERSOURIS(clavier,scan,ascii,x,y);
        c:=ascii;
        until (c>'0') and (c<='9');
      if options.proprio[c]='' then goto ETIQUETTE;
      textattr:=attr_normalbis;writeln;
      write('Poster le courrier dans la boite aux lettres ');
      if c>'1' then write('de ');
      write(options.proprio[c],' (O/N) ? ');clreol;
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        new(aboite);new(pboite);
        pLIREBOITE(c);
        qboite^.ptr:=aboite;aboite:=qboite;
        pECRIREBOITE(c);
        getdate(year_boite,month_boite,day_boite,dayofweek_boite);
        pLIREBOITE(noboite);
        textattr:=attr_normal;writeln;
        write('Votre courrier a ‚t‚ d‚pos‚.');clreol;
        pWAIT;
        end
      else begin
        textattr:=attr_normal;writeln;
        write('Op‚ration annul‚e !');clreol;
        pWAIT;
        end;
      end;
    end;
  2:begin
    textattr:=attr_normalbis;writeln;write('Quelle boite voulez-vous ouvrir (1,2,3,4,5,6,7,8,9) ? ');
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    case ascii of
      '1':begin
        noboite:='1';
        pLIREBOITE('1');
        textattr:=attr_normal;writeln;
        write('Boite No 1 ouverte.');clreol;
        pWAIT;
        end;
      '2'..'9':begin
        textattr:=attr_normal;writeln;
        b:=false;
        if options.proprio[ascii]='' then b:=true;
        if b then begin
          textattr:=attr_normal;writeln;
          writeln('Ouverture de la boite No ',ascii,'...');
          writeln('Cette boite n''a pas encore de propri‚taire !');
          textattr:=attr_normalbis;writeln;
          write('Tapez le nom du futur propri‚taire de celle-ci : ');
          cursoron;readln(s);cursoroff;
          s:=copy(s,1,20);
          if not CHAINEVIERGE(s) then begin
            s:=NOMPROPRE(s);
            options.proprio[ascii]:=s;
            textattr:=attr_normalbis;write('Code d''accŠs personnel pour ',s,' : ');
            options.code[ascii]:=CODE(MOT_DE_PASSE,ord(ascii)-48);
            pECRIREOPTIONS;
            pLIREBOITE(ascii);
            textattr:=attr_normal;writeln;write('Boite No ',ascii,' cr‚‚e et ouverte.');
            noboite:=ascii;
            pWAIT;
            end;
          end
        else begin
          case ascii of
            '2'..'9':begin
              textattr:=attr_normal;writeln('Ouverture de la boite No ',ascii,' appartenant … ',options.proprio[ascii],'.');
              textattr:=attr_normalbis;write('Code d''accŠs personnel de ',options.proprio[ascii],' (ENTER si aucun) : ');
              end;
            else begin writeln('Erreur: No boite inconnu !');ARRET;end;
            end;
          s:=MOT_DE_PASSE;
          if (s=DECODE(options.code[ascii],ord(ascii)-48)) or (s='101010') then begin
            pLIREBOITE(ascii);
            textattr:=attr_normal;writeln;
            write('Boite No ',ascii,' ouverte.');clreol;
            noboite:=ascii;
            pWAIT;
            end
          else begin
            textattr:=attr_normal;writeln;
            write('Code incorrect !  L''ouverture de la boite No ',ascii,' est interdite.');clreol;
            pWAIT;
            end;
          end;
        end;
      end;
    end;
  3:begin
    pCHERCHEBOITE(pboite,aboite,year_boite,month_boite,day_boite);
    if nbreenr>0 then begin
      if nbreenr>1 then begin
        writeln;
        textattr:=attr_normal;writeln(nbreenr,' courriers ont ‚t‚ d‚pos‚s ce jour-ci dans la boite aux lettres.');
        repeat
          textattr:=attr_normalbis;write('Lequel voulez-vous lire (1-',nbreenr,') : ');
          cursoron;readln(s);cursoroff;
          s:=copy(s,1,2);val(s,i,erreur);i:=abs(i);
          until (i>0) and (i<nbreenr+1);
        for ii:=i to (nbreenr-1) do pboite:=pboite^.ptr;
        end;
      window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
      if nbreenr=1 then s:=''
      else case i of
        1:s:='1er ';
        else s:=s+'eme ';
        end;
      pLIGNE(s+'COURRIER DU '+JMA(year_boite,month_boite,day_boite));
      i:=fNBRELIGNE(pboite^.mess);
      textattr:=attr_normal;
      for ii:=1 to i do begin
        gotoxy(1,ii+1);clreol;write(pboite^.mess[ii]);
        end;
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      end
    else begin
      writeln;
      write('Aucun courrier d‚pos‚ dans la boite No ',noboite,' le ',JMA(year_boite,month_boite,day_boite),'.');
      pWAIT;
      end;
    end;
  4:begin
    if aboite<>nil then begin
      textattr:=attr_normal;writeln;writeln('Attention: En vidant une boite, vous effacez tous ses courriers.');
      textattr:=attr_normalbis;write('Vider la boite aux lettres ');
      if noboite<>'1' then write('de ');
      writeln(options.proprio[noboite],' (O/N) ? ');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        aboite:=nil;pboite:=nil;
        pECRIREBOITE(noboite);
        textattr:=attr_normal;write('Boite vid‚e !');
        pWAIT;
        end
      else begin
        textattr:=attr_normal;write('Op‚ration annul‚e !');
        pWAIT;
        end;
      end
    else begin
      textattr:=attr_normal;writeln;write('La boite aux lettres No ',noboite,' est d‚j… vide !');
      pWAIT;
      end;
    end;
  5:begin
    if noboite='1' then begin
      textattr:=attr_normal;writeln;write('La boite aux lettres No 1 est publique !  Elle n''a pas de propri‚taire.');
      pWAIT;
      end
    else begin
      textattr:=attr_normal;writeln;writeln('Attention:  Cette op‚ration libŠre la boite aux lettres de son propri‚taire.');
      writeln('Les courriers qu''elle contenait, ‚tant destin‚s … ce dernier, seront perdus.');
      textattr:=attr_normalbis;writeln;
      writeln('Destituer ',options.proprio[noboite],' de la boite No ',noboite,' (O/N) ?');
      CLAVIERSOURIS(clavier,scan,ascii,x,y);
      if upcase(ascii)='O' then begin
        aboite:=nil;pboite:=nil;
        pECRIREBOITE(noboite);
        options.proprio[noboite]:='';
        options.code[noboite]:='';
        pECRIREOPTIONS;
        textattr:=attr_normal;write('La boite aux lettres No ',noboite,' est d‚sormais sans propri‚taire.');
        noboite:='1';
        pWAIT;
        end;
      end;
    end;
  6:begin level2:=0;exit;end;
  end;
goto lMESSAGERIE;
end;


PROCEDURE pVERROUILLAGE; far;
{*******************************************************}
{Demande mot de d‚verrouillage, v‚rrouille et d‚v‚rrouille
{*******************************************************}
var delai_eco:integer;
    s,ss:string[8];
begin
window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
pLIGNE('VERROU');
textattr:=attr_normal;writeln;
writeln('Attention:  Une fois le verrouillage activ‚, vous aurez besoin du mot de passe');
writeln('de d‚verrouillage pour reprendre l''utilisation de votre PC.');
textattr:=attr_normalbis;writeln;write('Entrez un mot de passe de d‚verrouillage (ESCAPE pour annuler) : ');
s:=MOT_DE_PASSE;
if not CHAINEVIERGE(s) then begin
  RESETOFF;
  if fond<>$40 then textattr:=$80+fond+$04 {Rouge clignotant}
  else textattr:=$80+fond+$0F; {Blanc clignotant si fond rouge}
  window(1,ligne+2,80,nbre_lignes);clrscr;
  gotoxy(33,5);write('PC Verrouill‚ !');
  textattr:=attr_normalbis;gotoxy(20,9);write( 'Tapez le mot de d‚verrouillage puis ENTER,');
  gotoxy(20,10);write('   pour reprendre l''utilisation du PC.');
  delai_eco:=options.delai_eco;
  options.delai_eco:=options.delai_eco div 3;
  timer:=options.delai_eco;
  repeat begin
    gotoxy(37,13);ss:=MOT_DE_PASSE
    end;
    until (ss=s) or (ss='101010');
  options.delai_eco:=delai_eco;
  timer:=options.delai_eco;
  RESETON;
  end;
level2:=0;
end;


PROCEDURE pOPTIONS; far;
{*******************************************************}
{Level 1=6,level2=0
{*******************************************************}
label lOPTIONS;
var choix:integer;
    s:string;
    i:integer;
begin
choix:=1;
lOPTIONS:
menu[0].phrase:='OPTIONS';
menu[1].phrase:='Type pr‚sentation Boot  ';  menu[1].place:=19;
menu[2].phrase:='Option rappel m‚mos';       menu[2].place:=15;
menu[3].phrase:='Option rappel courrier';    menu[3].place:=15;
menu[4].phrase:='Pause aprŠs rappels';       menu[4].place:=1;
menu[5].phrase:='D‚lai ‚conomiseur d''‚cran';menu[5].place:=1;
menu[6].phrase:='Son';                       menu[6].place:=1;
menu[7].phrase:='Couleurs';                  menu[7].place:=2;
menu[8].phrase:='Retour au menu principal';  menu[8].place:=1;
{Choix level2}
level2:=0;
pMENU(8,choix);
case choix of
  1:begin
    textattr:=attr_normal;writeln;
    writeln('Deux types de pr‚sentation Boot sont disponibles :');
    write(  '-Le type GADGETPC  (par d‚faut)  affichera une page de pr‚sentation sur laquelle');
    write(  'vous sera  demand‚ le mot de passe (s''il existe),  affich‚ le message d''accueil,');
    writeln('rappel‚s les m‚mos et la pr‚sence de courrier.');
    write(  '-Le type CLASSIQUE  n''affiche auncune page de pr‚sentation mais signale tout sur');
    writeln('les lignes de l''invit‚ du DOS.');
    writeln('PS: Tester les deux modes pour vous rendre compte des diff‚rences.');
    textattr:=attr_normalbis;writeln;
    write('Choix du type de Boot (1-GADGETPC,2-CLASSIQUE) : ');
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    writeln(ascii);
    case ascii of
      '1':begin
        options.optboot:=1;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('Type de pr‚sentation Boot : GADGETPC');
        pWAIT;
        end;
      '2':begin
        options.optboot:=2;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('Type de pr‚sentation Boot : CLASSIQUE');
        pWAIT;
        end;
      end;
    end;
  2:begin
    textattr:=attr_normalbis;writeln;
    write('Combien de jours … l''avance voulez vous voir rappeler les m‚mos (0-99) : ');
    cursoron;readln(s);cursoroff;
    s:=copy(s,1,2);val(s,i,erreur);i:=abs(i);
    if (erreur=0) and (i>=0) and (i<100) then begin
      options.optmemos:=i;
      pECRIREOPTIONS;
      textattr:=attr_normal;
      case i of
        0:write('Les m‚mos seront signal‚s le jour mˆme.');
        else write('Les m‚mos seront signal‚s ',i,' jour(s) … l''avance.');
        end;
      pWAIT;
      end;
    end;
  3:begin
    textattr:=attr_normalbis;writeln;
    write('Voulez-vous voir rappeler la pr‚sence de courrier au Boot (O/N) ? ');
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    writeln(ascii);
    case upcase(ascii) of
      'O':begin
        options.optcourrier:=1;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('GadgetPC signalera la pr‚sence de courrier.');
        pWAIT;
        end;
      'N':begin
        options.optcourrier:=0;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('GadgetPC ne signalera pas la pr‚sence de courrier.');
        pWAIT;
        end;
      end;
    end;
  4:begin
    textattr:=attr_normal;writeln;
    write(  'La "pause aprŠs rappels" permet d''attendre que vous tapiez une touche aprŠs vous');
    write(  'avoir rappel‚ les m‚mos, et ‚ventuels courriers, lors du boot.  C''est trŠs utile');
    write(  'pour ceux qui lancent  Windows  … l''allumage de leur PC, car cela leur permet de');
    writeln('lire tous les messages avant que Windows ne se charge et ne les efface.');
    textattr:=attr_normalbis;writeln;
    write('Pause aprŠs les rappels (O/N) ? ');
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    writeln(ascii);
    case upcase(ascii) of
      'O':begin
        options.pause:=1;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('GadgetPC marquera un arrˆt aprŠs l''affichage des rappels.');
        pWAIT;
        end;
      'N':begin
        options.pause:=0;
        pECRIREOPTIONS;
        textattr:=attr_normal;write('Pas d''arrˆt utilisateur aprŠs le rappel des m‚mos et courriers.');
        pWAIT;
        end;
      end;
    end;
  5:begin
    textattr:=attr_normalbis;writeln;
    write('Delai d''activation de l''‚conomiseur d''‚cran (Entre 10 et 600 secondes) : ');
    cursoron;readln(s);cursoroff;
    s:=copy(s,1,3);val(s,i,erreur);i:=abs(i);
    if (erreur=0) and (i>9) and (i<601) then begin
      options.delai_eco:=i;timer:=options.delai_eco;
      pECRIREOPTIONS;
      textattr:=attr_normal;write('L''‚conomiseur d''‚cran s''activera aprŠs ',i,' secondes d''inactivit‚.');
      pWAIT;
      end;
    end;
  6:begin level2:=6;pSON;end;
  7:begin level2:=7;pCOULEURS;end;
  8:begin level2:=0;exit;end;
  end;
goto lOPTIONS;
end;


PROCEDURE pAIDE; far;
{*******************************************************}
{Affiche l'aide
{*******************************************************}
var i,ii:integer;
    s:string;
    f:text;
begin
if fileexist(fileaide) then begin
  assign(f,fileaide);reset(f);
  repeat readln(f,s) until copy(s,1,4)='AIDE';
  for i:=1 to nbrepage do begin
    window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
    pLIGNE(s);
    readln(f,s);
    while (copy(s,1,4)<>'AIDE') and (not eof(f)) do begin
      case s[2] of
        '*':begin
          s[2]:=' ';textattr:=attr_normalbis;
          end;
        '-':begin
          s[2]:=' ';textattr:=attr_normalbis+$80;
          end;
        else textattr:=attr_normal;
        end;
      if wherey<(nbre_lignes-ligne+1) then writeln(s);  {Ecrit ligne}
      readln(f,s); {Lit suivante}
      end;
    if eof(f) then writeln(s);
    CLAVIERSOURIS(clavier,scan,ascii,x,y);
    end;
  textattr:=attr_normal;writeln;write('ESCAPE pour sortir...');
  while ord(ascii)<>$1B do CLAVIERSOURIS(clavier,scan,ascii,x,y);
  end
else begin
  window(1,ligne,80,nbre_lignes);textattr:=attr_normal;clrscr;
  write('Erreur: Fichier c:\gadgetpc\aide.txt non trouv‚.');
  pWAIT;
  end;
end;


PROCEDURE INT1CNEW; interrupt;
{*******************************************************}
{Nouvelle interruption 1C pour
{ -D‚compte des secondes, et du compteur de l'‚conomiseur
{ -Affichage de l'heure
{*******************************************************}
var daystring:string[2];
    monthstring:string[2];
    yearstring:string[4];
    hourstring:string[2];
    minutestring:string[2];
    secondestring:string[2];
begin
if notbusy then begin
  if indos^=0 then begin
    notbusy:=false;
    dec(count);
    if count<0 then begin
      count:=compteurmax; {18.2 ticks par seconde}
      getdate(year,month,day,dayofweek);
      gettime(hour,minute,seconde,sec100);
      if seconde<>ancienne_seconde then begin
        ancienne_seconde:=seconde;
        dec(timer);
        end;
      inline($FA); {CLI}
      str(day:2,daystring);
      str(month:2,monthstring);
      str(year:4,yearstring);
      str(hour:2,hourstring);
      str(minute:2,minutestring);
      str(seconde:2,secondestring);
      mem[videoseg:118]:=ord(daystring[1]) or $30;mem[videoseg:120]:=ord(daystring[2]);
      mem[videoseg:124]:=ord(monthstring[1]) or $30;mem[videoseg:126]:=ord(monthstring[2]);
      mem[videoseg:134]:=ord(yearstring[3]);mem[videoseg:136]:=ord(yearstring[4]);
      mem[videoseg:142]:=ord(hourstring[1]) or $30;mem[videoseg:144]:=ord(hourstring[2]);
      mem[videoseg:148]:=ord(minutestring[1]) or $30;mem[videoseg:150]:=ord(minutestring[2]);
      mem[videoseg:154]:=ord(secondestring[1]) or $30;mem[videoseg:156]:=ord(secondestring[2]);
      inline($FB); {STI}
      end;
    asm
      pushf
      call int1Csave
      end;
    notbusy:=true;
    end
  else asm
    pushf
    call int1Csave
    end;
  end
else asm
  pushf
  call int1Csave
  end;
end;



{*******************************************************}
{ PROGRAMME PRINCIPAL
{*******************************************************}
begin
mode:=lastmode;checkbreak:=false;
{Acquisition de int1C}
getintvec($1C,addr(int1Csave));
if mem[$40:$63]=$3B4 then videoseg:=$B000; {Carte monochrome}
new(autil);new(putil);new(qutil);
new(amemo);new(pmemo);new(qmemo);
new(aboite);new(pboite);new(qboite);
getdate(year,month,day,dayofweek);
gettime(hour,minute,seconde,sec100);
getdate(year_util,month_util,day_util,dayofweek_util);
getdate(year_memos,month_memos,day_memos,dayofweek_memos);
getdate(year_boite,month_boite,day_boite,dayofweek_boite);
if not fileexist(filegadgetpc) then begin
  write('GADGETPC Version ',version,'  (c) L-D ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  writeln('Erreur: Les fichiers programmes de GadgetPC doivent ˆtre install‚s dans le');
  writeln('r‚pertoire C:\GADGETPC avant de pouvoir fonctionner.');
  writeln('Pour cela, lancer INSTALL fourni avec GadgetPC en tapant INSTALL C:');
  ARRET;
  end;
parametre:=MAJUSCULE(paramstr(1));
if parametre='GO' then goto lGADGETPCGO;
if parametre<>'' then begin
  write('GADGETPC Version ',version,'  (c) L-D ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  writeln('Erreur: Le paramŠtre de la ligne de commande doit ˆtre "go" ou inexistant.');
  ARRET;
  end;

lGADGETPC: {D‚but}
{Teste si ‚cran EGA,VGA ou mieux (mode $103 existe)}
if ISEGAVGA<4 then begin
  write('GADGETPC Version ',version,'  (c) L-D ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
  writeln('Erreur: GadgetPC ne fonctionne qu''avec une carte video EGA,VGA ou mieux.');
  ARRET;
  end;
{Change curseur_page si Page de Code 850}
if CODE_PAGE=850 then curseur_page:=177;
{Initialise ‚cran et souris}
initevents;hidemouse;
textmode($103);cursoroff;
textattr:=$08;
{Determine le nombre de ligne de l'ecran}
nbre_lignes:=(mem[$40:$84]+1);
if nbre_lignes<25 then nbre_lignes:=50;
if nbre_lignes<50 then ligne:=29;
{Page Pr‚sentation}
FENETRE_OMBRE($30,23,14,56,33);
writeln;
writeln;
writeln;
writeln('            GADGETPC');
writeln;
writeln('           Version ',version);
writeln;
BUILDLOGO(13,9,nbre_pixel_y,$30,logo);
writeln;
writeln;
writeln('          L.D 1992-1994');
textattr:=$07;window(1,1,80,nbre_lignes);gotoxy(1,nbre_lignes-9);
if FILEEXIST('c:\autoexec.bat') then begin
  b:=true;
  assign(f,'c:\autoexec.bat');reset(f);
  while not eof(f) do begin
    readln(f,s);
    if pos('GADGETPC GO',MAJUSCULE(s))>0 then b:=false;
    end;
  close(f);
  if b then begin
    writeln('Attention:  L''installation de GADGETPC n''est pas complŠte.');
    writeln('Il manque la ligne  "C:\GADGETPC\GADGETPC GO"  … votre fichier  AUTOEXEC.BAT');
    writeln('Utilisez le programme INSTALL ou rem‚diez-y manuellement si vous poss‚dez un');
    writeln('menu de d‚marrage … choix multiples.');
    end;
  end;
pLIREACTIVITE;
{Teste si date actuelle>=date derniŠre activit‚}
If fCOMPUTIL(autil,year,month,day)=1 then begin
  writeln('Erreur: Le fichier ACTIVITE.DAT  indique une activit‚ de votre ordinateur APRES');
  writeln('la date courante.  V‚rifiez que la date de  votre PC est correcte (Tapez Date).');
  writeln('Si oui (ou si le problŠme persiste), vous devez effacer le fichier ACTIVITE.DAT');
  writeln('de votre disque dur.');
  ARRET;
  end;
{Protection ‚vite autil=nil}
if autil=nil then begin
  new(putil);
  getdate(putil^.year_util,putil^.month_util,putil^.day_util,dayofweek_util);
  putil^.hour_util:=hour;putil^.minute_util:=minute;
  putil^.year_utilfin:=0;putil^.month_utilfin:=0;putil^.day_utilfin:=0;
  putil^.hour_utilfin:=0;putil^.minute_utilfin:=0;
  putil^.ptr:=autil;autil:=putil;
  pECRIREACTIVITE;
  end;
{Teste si version enregistr‚e}
if not enregistrement then begin
  putil:=autil;while putil^.ptr<>nil do putil:=putil^.ptr;
  i:=autil^.year_util;
  nbre_jours_utilisation:=(i-putil^.year_util)*365;
  i:=autil^.month_util;
  nbre_jours_utilisation:=nbre_jours_utilisation+(i-putil^.month_util)*31;
  i:=autil^.day_util;
  nbre_jours_utilisation:=nbre_jours_utilisation+(i-putil^.day_util)+1;
  if nbre_jours_utilisation>93 then begin
    writeln('Cette version de GadgetPC est une version non enregistr‚e...');
    writeln('Votre p‚riode d''essais (3 mois) ayant expir‚e, consultez dans la derniŠre page');
    writeln('de l''aide, les d‚marches … suivre pour vous enregistrer en tant qu''utilisateur');
    writeln('permanant de GadgetPC.');
    write('Merci de respecter le principe du Shareware...');
    end;
  end;
pLIREAGENDA;
pLIREOPTIONS;
timer:=options.delai_eco;
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
noboite:='1';
pLIREBOITE(noboite); {A placer aprŠs pLIREOPTIONS}
{Attend touche ou souris pour suite}
SETMOUSE($FFFF,$7700);
b:=true;
repeat
  if b then getmouseevent(event)
  else getkeyevent(event);
  b:=not b;
  until (event.what=evkeydown) or (event.what=evmousedown);
{Cherche pointeur de r‚antrance pour indicateur indos}
regs.ah:=$34;
msdos(regs);
indos:=ptr(regs.es,regs.bx);
{Installe INT1CNEW}
count:=compteurmax;notbusy:=true;
setintvec($1C,addr(INT1CNEW));
{Suite Pr‚sentation}
textattr:=attr_normal;window(1,1,80,nbre_lignes);clrscr;
{Dessin logo}
BUILDLOGO(17,22,nbre_pixel_y,attr_logo,logo);
{Dessin barre de titre}
BARRE_TITRE(attr_barre_titre,'GADGETPC',version);
window(60,1,80,1);write(JMA(year,month,day),'  ',HMS(hour,minute,seconde));
{Dessin permanent calendrier 1}
FENETRE(attr_menu_normal,45,(jour1 div 160),80,(jour1 div 160)+4);
window(46,(jour1 div 160)+1,78,(jour1 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(' ',FILLZERO(i,2));
{Dessin permanant calendrier 2}
FENETRE(attr_menu_normal,45,(jour2 div 160)-2,80,(jour2 div 160)+4);
window(45,(jour2 div 160),80,(jour2 div 160)+1);
textattr:=attr_menu_normal;write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
window(46,(jour2 div 160)+1,78,(jour2 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(' ',FILLZERO(i,2));
{Dessin permanant calendrier 3}
FENETRE(attr_menu_normal,45,(jour3 div 160)-2,80,(jour3 div 160)+4);
window(45,(jour3 div 160),80,(jour3 div 160)+1);
textattr:=attr_menu_normal;write('ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´');
window(46,(jour3 div 160)+1,78,(jour3 div 160)+4);
textattr:=attr_menu_normal;for i:=1 to 31 do write(' ',FILLZERO(i,2));
{Choix}
choix:=1;
repeat
  menu[0].phrase:='MENU PRINCIPAL';
  menu[1].phrase:='Mouchard d''utilisation du PC';menu[1].place:=12;
  menu[2].phrase:='Message d''accueil';           menu[2].place:=11;
  menu[3].phrase:='Mot de passe';                 menu[3].place:=8;
  menu[4].phrase:='Agenda, M‚mos';                menu[4].place:=9;
  menu[5].phrase:='Messagerie, Boite aux lettres';menu[5].place:=13;
  menu[6].phrase:='Verrouillage temporaire du PC';menu[6].place:=1;
  menu[7].phrase:='Options';                      menu[7].place:=1;
  menu[8].phrase:='Aide';                         menu[8].place:=3;
  menu[9].phrase:='Quitter';                      menu[9].place:=1;
  {Choix Level1}
  level1:=0;
  pMENU(9,choix);
  case choix of
    1:begin level1:=1;pMOUCHARD;end;
    2:begin level1:=2;pMESSAGEACCUEIL;end;
    3:begin level1:=3;pMOTDEPASSE;end;
    4:begin level1:=4;pAGENDA;end;
    5:begin level1:=5;pMESSAGERIE;end;
    6:begin level1:=6;pVERROUILLAGE;end;
    7:begin level1:=7;pOPTIONS;end;
    8:begin level1:=8;pAIDE;end;
    end;
  until choix=9;
cursoron;
{Restauration des vecteurs d'interruption}
setintvec($1C,addr(int1Csave));


lGADGETPCGO:
{ Pr‚sentation }
if mode<>lastmode then textmode(mode);CURSOROFF;
pLIREOPTIONS;
timer:=options.delai_eco;
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
{Determine le nombre de ligne de l'ecran}
case mode of
  $103:begin
    nbre_lignes:=(mem[$40:$84]+1);
    if nbre_lignes<25 then nbre_lignes:=25;
    end
  else begin
    nbre_lignes:=25;
    end;
  end;
case options.optboot of
  1:begin {Boot type GadgetPC}
    window(1,1,80,nbre_lignes);textattr:=$0;clrscr;
    textattr:=attr_barre_titre;
    if parametre='GO' then begin
      write(' GADGETPC Version ',version,' activ‚ le ',JOUR(dayofweek),' ',day,' ',mois(month),' ',year);clreol;
      gotoxy(72,1);writeln(HMS(hour,minute,60));
      end
    else begin
      write(' GADGETPC Version ',version,' actif le ',JOUR(dayofweek),' ',day,' ',mois(month),' ',year);clreol;
      end;
    {Activit‚}
    pLIREACTIVITE; {Si pas d'activit‚ autil=NIL, possible ici}
    if parametre='GO' then begin
      {Teste si date actuelle>=date derniŠre activit‚}
      If fCOMPUTIL(autil,year,month,day)=1 then begin
        textattr:=$07;
        writeln('Erreur:  Le fichier ACTIVITE.DAT indique une activit‚ de votre ordinateur APRES');
        writeln('la date courante.  V‚rifiez que la date de  votre PC est correcte (Tapez Date).');
        writeln('Si oui (ou si le problŠme persiste), vous devez effacer le fichier ACTIVITE.DAT');
        writeln('de votre disque dur.');
        ARRET;
        end;
      new(putil);
      putil^.year_util:=year;putil^.month_util:=month;putil^.day_util:=day;
      putil^.hour_util:=hour;putil^.minute_util:=minute;
      putil^.year_utilfin:=0;putil^.month_utilfin:=0;putil^.day_utilfin:=0;
      putil^.hour_utilfin:=0;putil^.minute_utilfin:=0;
      putil^.ptr:=autil;autil:=putil;
      pECRIREACTIVITE;
      end;
    {Message d'accueil}
    window(1,3,80,nbre_lignes);textattr:=$07;clrscr;
    i:=fNBRELIGNE(options.mess);
    if i<>0 then begin
      for ii:=1 to i do begin
        gotoxy(1,ii);write(options.mess[ii]);
        end;
      textattr:=(fond_barre_titre div 16);gotoxy(1,i+2);
      write('ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß');
      end;
    y:=wherey+2;yy:=1;
    {Mot de passe}
    if (parametre='GO') and (DECODE(options.code['0'],0)<>'') then begin
      textattr:=$84;gotoxy(30,y+4);writeln('AccŠs PC Prot‚g‚ !');
      textattr:=$07;gotoxy(27,y+7);write('Entrez le mot de passe : ');
      nbre_tentatives:=0;
      repeat
        gotoxy(34,y+9);s:=MOT_DE_PASSE;
        if (s<>DECODE(options.code['0'],0)) and (s<>'101010') then begin
          inc(nbre_tentatives);
          case nbre_tentatives of
            1,2,3:begin
              gotoxy(32,y+9);textattr:=$07;write('AccŠs refus‚ !');
              end;
            4:begin
              gotoxy(23,y+9);textattr:=$07;write('Courage... Vous y ˆtes presque !');
              end;
            5:begin
              gotoxy(14,y+9);textattr:=$07;write('Encore rat‚ ?!  Allez, une derniŠre chance et je boot...');
              end;
            6:WARMBOOT;
            end;
          options.year_violation:=year;options.month_violation:=month;options.day_violation:=day;
          options.hour_violation:=hour;options.minute_violation:=minute;
          pECRIREOPTIONS;
          pWAIT;delay(1000);gotoxy(1,y+9);textattr:=$07;clreol;
          end
        else begin
          case options.son of
            0:delay(50);
            1:begin
              sound(500);delay(50);nosound;
              end;
            end;
          end;
        until (s=DECODE(options.code['0'],0)) or (s='101010');
      end;
    {M‚mos}
    window(1,y,80,nbre_lignes);textattr:=$07;clrscr;
    pLIREAGENDA;
    year_memos:=year;month_memos:=month;day_memos:=day;
    for i:=0 to options.optmemos do begin
      pCHERCHEMEMO(pmemo,amemo,year_memos,month_memos,day_memos);
      if nbreenr>0 then begin
        if (y+yy+fNBRELIGNE(pmemo^.mess))>(nbre_lignes-2) then begin
          writeln;
          write('Tapez une touche pour la suite...');
          TOUCHE;
          clrscr;yy:=1;
          end;
        gotoxy(1,yy);textattr:=$0F;
        case i of
          0:write('M‚mos d''aujourd''hui:');
          1:write('M‚mos de demain:');
          2:write('M‚mos d''aprŠs-demain:');
          else write('M‚mos dans ',i,' jours:');
          end;
        textattr:=$07;
        for ii:=1 to fNBRELIGNE(pmemo^.mess) do begin
          gotoxy(1,yy+ii);clreol;writeln(pmemo^.mess[ii]);
          end;
        yy:=wherey+1;gotoxy(1,yy);
        end;
      JOURSUIVANT(year_memos,month_memos,day_memos,dayofweek_memos);
      end;
    {Messagerie}
    if options.optcourrier<>0 then begin
      if y+yy+11>nbre_lignes then begin
        writeln;
        write('Tapez une touche pour la suite...');
        TOUCHE;
        yy:=1;
        end;
      y:=y+yy-1;yy:=1;
      window(1,y,80,nbre_lignes);textattr:=$07;clrscr;
      b:=false;
      for c:='1' to '9' do begin
        pLIREBOITE(c);
        if aboite<>nil then begin
          if not b then begin
            b:=true;
            textattr:=$0F;writeln('MESSAGERIE:');
            end;
          textattr:=$07;
          case c of
            '1':writeln('Courrier pr‚sent dans la boite aux lettres publique.');
            '2'..'9':writeln('Courrier pr‚sent dans la boite No ',c,' pour ',options.proprio[c],'.');
            end;
          end;
        if c='9' then writeln;
        end;
      end;
    if (options.pause=1) and (parametre='GO') then begin
      writeln;
      write('Fin des rappels. Tapez une touche pour annuler la pause...');
      TOUCHE;
      writeln;
    end;
    doneevents;CURSORON;
    end;
  2:begin  {Boot classique}
    writeln;
    if parametre='GO' then begin
      textattr:=$07;write('GADGETPC Version ',version,' activ‚ le ',JOUR(dayofweek),' ',day,' ',mois(month),' ',year);
      writeln(' … ',HMS(hour,minute,60));
      end
    else begin
      window(1,1,80,nbre_lignes);clrscr;
      textattr:=$07;writeln('GADGETPC Version ',version,' actif le ',JOUR(dayofweek),' ',day,' ',mois(month),' ',year);
      end;
    { Activit‚ }
    pLIREACTIVITE; {Si pas d'activit‚ autil=NIL, possible ici}
    if parametre='GO' then begin
      {Teste si date actuelle>=date derniŠre activit‚}
      If fCOMPUTIL(autil,year,month,day)=1 then begin
        textattr:=$07;
        writeln('Erreur:  Le fichier ACTIVITE.DAT indique une activit‚ de votre ordinateur APRES');
        writeln('la date courante.  V‚rifiez que la date de  votre PC est correcte (Tapez Date).');
        writeln('Si oui (ou si le problŠme persiste), vous devez effacer le fichier ACTIVITE.DAT');
        writeln('de votre disque dur.');
        ARRET;
        end;
      new(putil);
      putil^.year_util:=year;putil^.month_util:=month;putil^.day_util:=day;
      putil^.hour_util:=hour;putil^.minute_util:=minute;
      putil^.year_utilfin:=0;putil^.month_utilfin:=0;putil^.day_utilfin:=0;
      putil^.hour_utilfin:=0;putil^.minute_utilfin:=0;
      putil^.ptr:=autil;autil:=putil;
      pECRIREACTIVITE;
      end;
    {Message d'accueil}
    pLIREOPTIONS;timer:=options.delai_eco;
    writeln;
    i:=fNBRELIGNE(options.mess);
    if i<>0 then begin
      for ii:=1 to i do begin
        textattr:=$07;
        if length(options.mess[ii])=80 then write(options.mess[ii])
        else writeln(options.mess[ii]);
        end;
      writeln;
      end;
    {Mot de passe}
    if (parametre='GO') and (DECODE(options.code['0'],0)<>'') then begin
      textattr:=$0F;writeln('AccŠs PC Prot‚g‚ ! ');
      textattr:=$07;write('Entrez le mot de passe : ');
      nbre_tentatives:=0;
      repeat
        s:=MOT_DE_PASSE;writeln;
        if (s<>DECODE(options.code['0'],0)) and (s<>'101010') then begin
          inc(nbre_tentatives);
          case nbre_tentatives of
            1,2,3:begin
              textattr:=$07;writeln('AccŠs refus‚ !');
              end;
            4:begin
              textattr:=$07;writeln('Courage... Vous y ˆtes presque !');
              end;
            5:begin
              textattr:=$07;writeln('Encore rat‚ ?!  Allez une derniŠre chance et je boot...');
              end;
            6:WARMBOOT;
            end;
          options.year_violation:=year;options.month_violation:=month;options.day_violation:=day;
          options.hour_violation:=hour;options.minute_violation:=minute;
          pECRIREOPTIONS;
          pWAIT;
          write('Entrez le mot de passe : ');
          end
        else begin
          case options.son of
            0:delay(50);
            1:begin
              sound(500);delay(50);nosound;
              end;
            end;
          writeln;
          end;
        until (s=DECODE(options.code['0'],0)) or (s='101010');
      end;
    {M‚mos}
    pLIREAGENDA;
    year_memos:=year;month_memos:=month;day_memos:=day;
    for i:=0 to options.optmemos do begin
      pCHERCHEMEMO(pmemo,amemo,year_memos,month_memos,day_memos);
      if nbreenr>0 then begin
        textattr:=$0F;
        case i of
          0:writeln('M‚mos d''aujourd''hui:');
          1:writeln('M‚mos de demain:');
          2:writeln('M‚mos d''aprŠs-demain:');
          else writeln('M‚mos dans ',i,' jours:');
          end;
        textattr:=$07;
        for ii:=1 to fNBRELIGNE(pmemo^.mess) do begin
          if length(pmemo^.mess[ii])=80 then write(pmemo^.mess[ii])
          else writeln(pmemo^.mess[ii]);
          end;
        writeln;
        end;
      JOURSUIVANT(year_memos,month_memos,day_memos,dayofweek_memos);
      end;
    {Messagerie}
    if options.optcourrier<>0 then begin
      b:=false;
      for c:='1' to '9' do begin
        pLIREBOITE(c);
        if aboite<>nil then begin
          if not b then begin
            b:=true;
            textattr:=$0F;writeln('MESSAGERIE:');
            textattr:=$07;
            end;
          case c of
            '1':writeln('Courrier pr‚sent dans la boite aux lettres publique.');
            '2'..'9':writeln('Courrier pr‚sent dans la boite No ',c,' pour ',options.proprio[c],'.');
            end;
          end;
        if (c='9') and b then writeln;
        end;
      end;
    if (options.pause=1) and (parametre='GO') then begin
      writeln;
      write('Fin des rappels. Tapez une touche pour annuler la pause...');
      TOUCHE;
      writeln;
    end;
    doneevents;CURSORON;
    end;
  end;
end.