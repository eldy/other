UNIT KEYBOARD;

INTERFACE

uses crt,dos,video;
const videoseg:word=$B800;
type tbuffer=Array[30..62] of Byte;
var head   :integer absolute $0000:$041A; { Location of head of buffer  }
    tail   :integer absolute $0000:$041C; { Location of tail of buffer  }
    keybbuf:tbuffer absolute $0000:$041E; { Absolute location of buffer }

FUNCTION TESTCLAVIERETENDU:boolean;
PROCEDURE TOUCHE;
FUNCTION OUI_NON:char;
FUNCTION YES_NO:char;
PROCEDURE CLAVIER(var scan:byte;var ascii:char);
PROCEDURE CLAVIERSOURIS(var clavier:boolean;var scan:byte;
                        var ascii:char;var x,y:integer);
Procedure Getlocks(var num,caps,scroll,ins:boolean);
Procedure Setlocks(num,caps,scroll,ins:boolean);
Procedure Clearkeyb;
Procedure Fillkeyb(scan:byte;ascii:char);


IMPLEMENTATION


FUNCTION TESTCLAVIERETENDU:boolean;
{**********************************************************************}
{ Teste si les fonctions ‚tendues du BIOS pour lire un ‚tendu sont disponibles
{ Sortie: TRUE, si les fonctions sont disponibles, sinon FALSE
{**********************************************************************}
var regs:registers;
begin
regs.AX:=$1200; { Fonction d'‚tat ‚tendue pour les claviers ‚tendu }
intr($16,regs);
testclavieretendu:=(regs.AX<>$1200); { AX=$1200: Fonction absente  }
end;


PROCEDURE TOUCHE;
{*******************************************************}
{Attend frappe d'une touche sans clignotement curseur.
{*******************************************************}
var c:char;
begin
CURSOROFF;
repeat c:=readkey until c<>#0;
CURSORON;
end;


FUNCTION OUI_NON:char;
{*******************************************************}
{Attend frappe de o,O ou n,N et renvoi O ou N
{Laisse curseur clignoter.
{*******************************************************}
var c:char;
begin
repeat c:=upcase(readkey) until (c='O') or (c='N');
oui_non:=c;
end;


FUNCTION YES_NO:char;
{*******************************************************}
{Wait for y,Y or n,N Key end return Y or N
{Let the cursor blink.
{*******************************************************}
var c:char;
begin
repeat c:=upcase(readkey) until (c='Y') or (c='N');
yes_no:=c;
end;


PROCEDURE CLAVIER(var scan:byte;var ascii:char);
{*******************************************************}
{*******************************************************}
var event:tevent;
begin
repeat
  getkeyevent(event);
  until event.what=evkeydown;
scan:=event.scancode;
ascii:=event.charcode;
end;


PROCEDURE CLAVIERSOURIS(var clavier:boolean;var scan:byte;
                        var ascii:char;var x,y:integer);
{*******************************************************}
{Attend frappe d'une touche ou pression souris
{Si touche: clavier=true
{           scan=code scan de la touche
{           ascii=code ascii de la touche
{           x,y insignifiant
{Si souris: clavier=false
{           scan=num‚ro bouton souris (1 ou 2)
{           ascii=code ascii caratŠre cliqu‚
{           x,y position de las souris
{*******************************************************}
var b:boolean;
    event:tevent;
begin
showmouse;
b:=true;
repeat
  case b of
    true:getmouseevent(event);
    false:getkeyevent(event);
    end;
  if b then b:=false else b:=true;
  until (event.what=evkeydown) or (event.what=evmousedown);
clavier:=b;
if b then begin
  scan:=event.scancode;
  ascii:=event.charcode;
  end
else begin
  x:=(event.where.x)+1;
  y:=(event.where.y)+1;
  scan:=event.buttons; {Normallement scan=0}
  ascii:=chr(mem[videoseg:(event.where.y*160+event.where.x*2)]);
  end;
hidemouse;
end;


PROCEDURE GETLOCKS(var num,caps,scroll,ins:boolean);
{*******************************************************}
{*******************************************************}
var alt,ctrl,left_shift,right_shift:boolean;
begin
num   :=((mem[$0040:$0017] and $20)=$20);
caps  :=((mem[$0040:$0017] and $40)=$40);
scroll:=((mem[$0040:$0017] and $10)=$10);
ins   :=((mem[$0040:$0017] and $80)=$80);
end;


PROCEDURE SETLOCKS(num,caps,scroll,ins:boolean);
{*******************************************************}
{*******************************************************}
var b:byte;
begin
b:=(mem[$0040:$0017] and $0f);
if num then b:=b or $20;
if caps then b:=b or $40;
if scroll then b:=b or $10;
if ins then b:=b or $80;
memw[$0040:$0017]:=b;
end;


PROCEDURE CLEARKEYB;
{*******************************************************}
{ Vide Buffer clavier du controleur clavier
{*******************************************************}
begin
inline($FA); { CLI, inhibe interruptions mat‚rielles }
memw[$40:$1A]:=memw[$40:$1C]; { Flush keyboard buffer }
inline($FB); { STI, r‚tablit interruptions mat‚rielles }
end;


PROCEDURE FILLKEYB(scan:byte;ascii:char); assembler;
{*******************************************************}
{ Remplie Buffer clavier avec scan,ascii
{*******************************************************}
asm
mov ah,05h
mov ch,scan
mov cl,ascii
int $16
end;

begin
if mem[$40:$63]=$3B4 then videoseg:=$B000; {Carte monochrome}
end.
