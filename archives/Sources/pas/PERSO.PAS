UNIT PERSO;

INTERFACE

uses crt,drivers;
const videoseg:word=$B800;

PROCEDURE BARRE_TITRE(textattribut:word;logiciel,version:string);
PROCEDURE FENETRE(textattribut,x1,y1,x2,y2:word);
PROCEDURE FENETRE_OMBRE(textattribut,x1,y1,x2,y2:word);
FUNCTION MOT_DE_PASSE:string;


IMPLEMENTATION


Procedure BARRE_TITRE(textattribut:word;logiciel,version:string);
{*******************************************************}
{Affiche Barre de Titre
{*******************************************************}
begin
gotoxy(1,1);textattr:=textattribut;clreol;
write(' ',logiciel,' Version ',version,'    (C) L.D 92-96');
end;


Procedure FENETRE(textattribut,x1,y1,x2,y2:word);
{*******************************************************}
{ Dessine et initialise fenˆtre avec ligne sur les bords
{ Rem: Mode TEXTE
{*******************************************************}
var i:integer;
begin
textattr:=textattribut;
window(x1,y1,x2,y2);clrscr;
mem[videoseg:(80*y1+x1-81) shl 1]:=218;
for i:=(x1+1) to (x2-1) do mem[videoseg:(80*y1+i-81) shl 1]:=196;
mem[videoseg:(80*y1+x2-81) shl 1]:=191;
mem[videoseg:(80*y2+x1-81) shl 1]:=192;
for i:=(x1+1) to (x2-1) do mem[videoseg:(80*y2+i-81) shl 1]:=196;
mem[videoseg:(80*y2+x2-81) shl 1]:=217;
for i:=(y1+1) to (y2-1) do begin
  mem[videoseg:(80*i+x1-81) shl 1]:=179;
  mem[videoseg:(80*i+x2-81) shl 1]:=179;
  end;
end;


Procedure FENETRE_OMBRE(textattribut,x1,y1,x2,y2:word);
{*******************************************************}
{ Dessine et initialise fenˆtre avec ligne sur les bords et ombre
{ Rem: Mode TEXTE
{*******************************************************}
var i:integer;
begin
FENETRE(textattribut,x1,y1,x2,y2);
{Genere l'ombre}
for i:=x1 to x2 do begin
  mem[videoseg:((80*y2+i) shl 1)]:=177;
  mem[videoseg:((80*y2+i) shl 1)+1]:=textattribut;
  end;
for i:=y1 to y2 do begin
  mem[videoseg:(80*i+x2) shl 1]:=177;
  mem[videoseg:((80*i+x2) shl 1)+1]:=textattribut;
  end;
window(x1+1,y1+1,x2-1,y2-1);
end;


FUNCTION MOT_DE_PASSE:string;
{*******************************************************}
{Demande code de 8 lettres … la position curseur.
{Tous les caractŠres entre '!'=#33 et 'z'=#122 sont accept‚s.
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
gotoxy(x,y);
for i:=1 to length(s) do write('.');
write('_');clreol;
repeat
  getkeyevent(event);
  until event.what=evkeydown;
scan:=event.scancode;
ascii:=event.charcode;
if scan=$01 then begin {Escape}
  s:='';scan:=$1C
  end;
if scan=$1C then begin {Enter}
  gotoxy(x,y);
  for i:=1 to length(s) do write('.');
  mot_de_passe:=s;exit;
  end;
if scan=$0E then s:=copy(s,1,length(s)-1);
if (ascii>='!') and (ascii<='z') and (length(s)<8) then s:=s+ascii;
goto BOUCLE;
end;

begin
if mem[$40:$63]=$3B4 then videoseg:=$B000; {Carte monochrome}
end.