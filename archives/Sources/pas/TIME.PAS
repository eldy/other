UNIT TIME;

INTERFACE

uses crt,dos,general;
function JOUR(dayofweek:word):string;
function MOIS(month:word):string;
function HMS(hour,minute,seconde:word):string;
function JMA(year,month,day:word):string;
function NBREJOUR(year,month:word):integer;
function JOURDESEMAINE(year,month,day:word):word;
procedure JOURPRECEDANT(var year,month,day,dayofweek:word);
procedure JOURSUIVANT(var year,month,day,dayofweek:word);
procedure MOISPRECEDANT(var year,month:word);
procedure MOISSUIVANT(var year,month:word);


IMPLEMENTATION


FUNCTION JOUR(dayofweek:word):string;
{*******************************************************}
{ Renvoie jour de semaine en lettres
{*******************************************************}
begin
case dayofweek of
  0:jour:='Dimanche';
  1:jour:='Lundi';
  2:jour:='Mardi';
  3:jour:='Mercredi';
  4:jour:='Jeudi';
  5:jour:='Vendredi';
  6:jour:='Samedi';
  end;
end;


FUNCTION MOIS(month:word):string;
{*******************************************************}
{ Renvoie mois de l'ann‚e en lettres
{*******************************************************}
begin
case month of
  1:mois:='Janvier';
  2:mois:='F‚vrier';
  3:mois:='Mars';
  4:mois:='Avril';
  5:mois:='Mai';
  6:mois:='Juin';
  7:mois:='Juillet';
  8:mois:='Aout';
  9:mois:='Septembre';
  10:mois:='Octobre';
  11:mois:='Novembre';
  12:mois:='D‚cembre';
  end;
end;


FUNCTION HMS(hour,minute,seconde:word):string;
{*******************************************************}
{Renvoie chaine dans format HH:MM, HH:MM,SS, MM:SS
{selon la valeur de HH,MM,SS (Heure/Minute/Seconde)
{*******************************************************}
var s:string;
begin
if hour<24 then s:=FILLZERO(hour,2)+':';
s:=s+FILLZERO(minute,2);
if seconde<60 then s:=s+':'+FILLZERO(seconde,2);
hms:=s;
end;


FUNCTION JMA(year,month,day:word):string;
{*******************************************************}
{ Renvoie chaine avec DD/MM/YYYY (Jour/Mois/Ann‚e)
{*******************************************************}
begin
jma:=FILLZERO(day,2)+'/'+FILLZERO(month,2)+'/'+FILLZERO(year,4);
end;


FUNCTION NBREJOUR(year,month:word):integer;
{*******************************************************}
{ Renvoie nombre de jours dans month de year
{*******************************************************}
begin
case month of
  1,3,5,7,8,10,12:nbrejour:=31;
  4,6,9,11:nbrejour:=30;
  2:begin
    if year mod 4=0 then nbrejour:=29
    else nbrejour:=28;
    end;
  end;
end;


FUNCTION JOURDESEMAINE(year,month,day:word):word;
{*******************************************************}
{ Renvoie jourdesemain(0-6) du day/month/year
{ Jour de r‚f‚rence:1 janvier 0000=vendredi
{ Ann‚e 0=ann‚e bissextile
{*******************************************************}
var i,j:longint;

function decalagebi(year,month:word):integer;
begin
if (year mod 4=0) and (month<3) then
 decalagebi:=(year div 4)
else decalagebi:=1+(year div 4);
end;

begin
if (day<1) or (day>NBREJOUR(year,month)) then begin
  writeln('Erreur: Le ',day,'/',month,'/',year,' n''existe pas.');
  halt;
  end;
{ i=nbre jours d‚calage/1 janvier 0000 }
case month of
    1:i:=0;
    2:i:=31;
    3:i:=59;
    4:i:=90;
    5:i:=120;
    6:i:=151;
    7:i:=181;
    8:i:=212;
    9:i:=243;
    10:i:=273;
    11:i:=304;
    12:i:=334;
    end;
j:=year;
i:=j*365+i+day-1+decalagebi(year,month);
i:=i mod 7;
jourdesemaine:=(5+i) mod 7
end;


PROCEDURE JOURPRECEDANT(var year,month,day,dayofweek:word);
{*******************************************************}
{*******************************************************}
begin
dec(day);
if day<1 then begin
  dec(month);
  if month<1 then begin
    dec(year);month:=12;day:=31;
    end
  else day:=NBREJOUR(year,month);
  end;
dayofweek:=JOURDESEMAINE(year,month,day);
end;


PROCEDURE JOURSUIVANT(var year,month,day,dayofweek:word);
{*******************************************************}
{*******************************************************}
begin
inc(day);
if day>NBREJOUR(year,month) then begin
  day:=1;inc(month);
  if month>12 then begin
    inc(year);month:=1;
    end;
  end;
dayofweek:=JOURDESEMAINE(year,month,day);
end;


PROCEDURE MOISPRECEDANT(var year,month:word);
{*******************************************************}
{*******************************************************}
begin
dec(month);
if month<1 then begin
  dec(year);month:=12;
  end;
end;


PROCEDURE MOISSUIVANT(var year,month:word);
{*******************************************************}
{*******************************************************}
begin
inc(month);
if month>12 then begin
  inc(year);month:=1;
  end;
end;


end.