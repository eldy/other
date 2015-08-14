UNIT HARDWARE;


INTERFACE

uses dos,general;
var int09save:procedure;


{Disques}
FUNCTION NUMDRIVES:byte;
FUNCTION GETDRIVE:byte;
PROCEDURE SETDRIVE(drive:byte);
FUNCTION DIREXIST(dir:string):Boolean;
PROCEDURE MAKEDIR(dir:string);
PROCEDURE DELDIR(dir:string);
FUNCTION FILEEXIST(filename:string):boolean;
PROCEDURE COPYFILE(source,destination:string;var codeerreur:byte);
{M‚moire}
FUNCTION GETFREEMEM:longint;
FUNCTION TAILLERAM:word;
FUNCTION TAILLERAMSUP:word;
{Config}
FUNCTION CODE_PAGE:integer;
FUNCTION TYPEPC:integer;
FUNCTION WINDOWS(var hversion,nversion:integer):integer;
{Divers}
PROCEDURE WARMBOOT;
PROCEDURE COLDBOOT;
{Clavier}
PROCEDURE RESETOFF;
PROCEDURE RESETON;
{Ports parallŠles}
PROCEDURE INITPRINTER(numero_lpt:integer);
PROCEDURE TESTPRINTER(numero_lpt:integer;var resultat:integer);


IMPLEMENTATION


FUNCTION NUMDRIVES:byte; assembler;
{*******************************************************}
{Retourne nombre de drives
{*******************************************************}
asm
call GetDrive { Find out the current drive, Returns drive in AL }
mov AH,$0E    { Function to change drives                       }
mov DL,AL     { Change to current drive                         }
int $21       { Call Dos, Number of drives is returned in AL    }
end;


FUNCTION GETDRIVE:byte; assembler;
{*******************************************************}
{D‚termine Drive courant
{Retourne 0=A,1=B,2=C,etc
{=GETDISK en C
{*******************************************************}
asm
mov AX,$1900  { Function to determine drive       }
int $21       { Call Dos, Drive is returned in AL }
end;


PROCEDURE SETDRIVE(drive:byte); assembler;
{*******************************************************}
{Change Drive courant
{0=A,1=B,2=C,etc
{=SETDISK en C
{*******************************************************}
Asm
mov AH,$0E    { Function to change Drives }
mov DL,drive  { Drive to change to        }
int $21       { Call Dos Int 21h          }
end;


FUNCTION DIREXIST(dir:string):boolean;
{*******************************************************}
{Renvoie True si dir existe
{*******************************************************}
var attr:word;
    f:file;
begin
assign(f,dir);
getfattr(f,attr);
if (doserror<>0) then direxist:=false
else direxist:=((attr and $10)<>0);
end;


PROCEDURE MAKEDIR(dir:string);
{*******************************************************}
{Cr‚e dir avec sa chaine si inexistant
{Attention !
{Runtime erreur (003) si dir non valide (CaractŠres non valides)
{*******************************************************}
var i,ii:integer;
    tempdir:string;
    slash:array[1..40] of integer;
begin
if dir[length(dir)]<>'\' then dir:=dir+'\';
i:=0;
{ Rep‚rage des \ }
for ii:=1 to length(dir) do begin
  if dir[ii]='\' then begin
    inc(i);slash[i]:=ii;
    end;
  end;
{ Cr‚ation de l'arbre }
for ii:=1 to i do begin
  tempdir:=copy(dir,1,slash[ii]-1);
  if (length(tempdir)=2) and (tempdir[2]=':') then continue;
  if not direxist(tempdir) then begin
    mkdir(tempdir); {r‚pertoire courant si non sp‚cifi‚ }
    end;
  end;
end;


PROCEDURE DELDIR(dir:string);
{*******************************************************}
{Efface dir si dir existe, si non vide et si non courant
{*******************************************************}
begin
{$I-}
rmdir(dir);
{$I+}
end;


FUNCTION FILEEXIST(filename:string):boolean;
{*******************************************************}
{Renvoie True si filename existe en recherchant dans le
{r‚pertoire sp‚cifi‚ dans filename sinon courant.
{*******************************************************}
var srec:searchrec;
begin
findfirst(filename,anyfile,srec);
fileexist:=(doserror=0)
end;


PROCEDURE COPYFILE(source,destination:string;var codeerreur:byte);
{*******************************************************}
{Copy fichier source vers destination
{Codeerreur: 0 successful
{            1 copy source on destination
{            2 cannot open source
{            3 unable to create destination
{            4 error during copy
{*******************************************************}
Var f1,f2:file;
    bread,bwrite:word;
    filebuf:array[1..2048] of char;
begin
source:=fexpand(source);
destination:=fexpand(destination);
if source=destination then begin
  codeerreur:=1;exit;
  end;
assign(f1,source);
{$I-}
reset(f1,1);
{$I+}
if ioresult<>0 then begin
  codeerreur:=2;exit;
  end;
assign(f2,destination);
{$I-}
rewrite(f2,1);
{$I+}
if ioresult<>0 then begin
  codeerreur:=3;exit;
  end;
{I-}
repeat
  blockread(f1,filebuf,sizeof(filebuf),bread);
  blockwrite(f2,filebuf,bread,bwrite);
  until (bread=0) or (bread<>bwrite);
close(f1);close(f2);
{I+}
if (bread<>bwrite) or (ioresult<>0) then codeerreur:=4
else codeerreur:=0;
end;


FUNCTION GETFREEMEM:longint;
{*******************************************************}
{Renvoi m‚moire libre
{*******************************************************}
Var
w:word;
begin
asm
  mov ah,$48
  mov bx,$FFFF
  int $21
  mov w,bx
  end;
getfreemem:=longint(w)*16;
end;


FUNCTION TAILLERAM:word;
{*******************************************************}
{Renvoie taille RAM (en de‡… de 1 Mo)
{*******************************************************}
var regs:registers;
begin
intr($12,regs); { Interruption 12h }
tailleram:=regs.ax; { =Ko sous 1 Mo }
end;


FUNCTION TAILLERAMSUP:word;
{*******************************************************}
{Renvoi taille RAM (au del… de 1 Mo)
{*******************************************************}
var regs:registers;
begin
regs.ah:=$88;   { Fonction 88h     }
intr($15,regs); { Interruption 15h }
tailleramsup:=regs.ax { =Ko au dessus 1 Mo }
end;



FUNCTION CODE_PAGE:integer;
{*******************************************************}
{Renvoi page de code en cours
{*******************************************************}
var regs:registers;
begin
regs.ah:=$66;
regs.al:=$01;
intr($21,regs);
code_page:=regs.bx;
end;



FUNCTION TYPEPC:integer;
{*******************************************************}
{Renvoi 0 si machine=PC
{       1 si machine=XT
{       2 si machine=AT ou sup‚rieur
{*******************************************************}
begin
case Mem[$F000:$FFFE] of
  $FF:typepc:=0;
  $FE:typepc:=1;
  else typepc:=2;
  end;
end;


FUNCTION WINDOWS(var HVersion,NVersion:integer):integer;
{*******************************************************}
{D‚termine si windows actif
{Renvoi $00: Windows non actif
{       $01: Windows/386 V2.? actif
{       $81: Windows en mode R‚el
{       $82: Windows en mode Standard
{       $83: Windows Version Hver.NVer en mode Etendu(Prot‚g‚)
{Infos: Le num‚ro de version ne peut ˆtre obtenu que dans le mode ‚tendu de Windows 3
{*******************************************************}
const MULTIPLEX =$2F; { Nø interruption Multiplex }
var regs:registers;
    res :integer;
{ Cette fonction remplace l'appel de intr($2F,Regs)            }
{ Regs.ax = $1600 (Test d'installation du mode ‚tendu),        }
{ l'appel avec la fonction Pascal renvoie des valeurs erron‚es }
function int2fcall:integer;
begin
inline($b8/$00/$16/  { mov ax,1600h  }
       $cd/$2f/      { int 2Fh       }
       $89/$46/$FE); { mov [bp-2],ax }
{ A cet endroit, le compilateur rajoute "mov ax, [bp-2]" pour       }
{ charger la variable de fonction locale dans le registre de retour }
end;
begin
HVersion:=0;
NVersion:=0;
{ Identifie Windows x.y en mode ‚tendu }
res:=int2fcall;  { Test d'installation du mode ‚tendu }
case (lo(Res)) of
  $01,
  $FF:begin
    HVersion:=2; { Version principale          }
    NVersion:=0; { Version secondaire inconnue }
    Windows:=$01;
    end;
  $00,
  $80:begin
    regs.ax:=$4680; { Identifier les modes R‚el et Standard }
    intr(MULTIPLEX,regs);
    if (regs.al=$80) then windows:=$00 { Windows ne fonctionne pas }
    else begin        { Windows en mode R‚el ou Standard }
      regs.ax:=$1605; { Simule l'inst. d'un DOS-Extender }
      regs.bx:=$0000;
      regs.si:=$0000;
      regs.cx:=$0000;
      regs.es:=$0000;
      regs.ds:=$0000;
      regs.dx:=$0001;
      intr(MULTIPLEX,regs);
      if (regs.cx=$0000) then begin { Windows en mode R‚el }
	regs.ax:=$1606;
	intr(MULTIPLEX,regs);
	Windows:=$81;
	end
      else windows:=$82;
      end;
    end;
{ Windows en mode Etendu, ax contient le num‚ro de version }
  else begin
    HVersion:=lo(res); { Afficher la version de Windows }
    NVersion:=hi(res);
    windows:=$83;      { Windows en mode Etendu }
    end;
  end;
end;


PROCEDURE WARMBOOT;
{*******************************************************}
{Reset … chaud=CTRL+ALT+SUP
{*******************************************************}
begin
inline($BB/$00/$01/$B8/$40/$00/$8E/$D8/
       $89/$1E/$72/$00/$EA/$00/$00/$FF/$FF);
end;


PROCEDURE COLDBOOT;
{*******************************************************}
{Reset … froid=Bouton reset
{*******************************************************}
begin
inline($BB/$38/$12/$B8/$40/$00/$8E/$D8/
       $89/$1E/$72/$00/$EA/$00/$00/$FF/$FF);
end;


PROCEDURE INTERCEPT09h; interrupt;
{*******************************************************}
{Est appel‚ par RESETOFF.
{Pression sur clavier envoie code MAKE/BREAK dans port[60] puis
{active Int09h=IRQ1 qui range code SCAN+ASCII dans buffer.
{Cette proc‚dure est le d‚tour de IRQ1 de sa tache habituelle
{quand (CTRL)+ALT+DEL a ‚t‚ frapp‚.
{*******************************************************}
begin
if (port[$60]=$53) and ((Mem[$0040:$0017] and $8)=$8) then begin
  inline($FA); {CLI}
  Port[$20]:=$20;
  inline($FB); {STI}
  end
else begin
  asm
    pushf {Inline($9C}
    end;
  int09save;
  end;
end;


PROCEDURE RESETOFF;
{*******************************************************}
{Neutralise CTRL+ALT+SUP
{*******************************************************}
begin
getintvec($09,@int09save);
setintvec($09,@intercept09h);
end;


PROCEDURE RESETON;
{*******************************************************}
{Restaure la possibilit‚ d'initialiser avec CTRL+ALT+SUP
{*******************************************************}
begin
setintvec($09,@int09save);
end;


PROCEDURE INITPRINTER(numero_lpt:integer);
{*******************************************************}
{Initialise imprimante lpt-numero_port
{*******************************************************}
var regs:registers;
begin
regs.ah:=1;
regs.dx:=numero_lpt;
dec(regs.dx);
intr($17,regs);
end;


PROCEDURE TESTPRINTER(numero_lpt:integer;var resultat:integer);
{*******************************************************}
{Lit DERNIER ETAT de l'imprimante lpt-numero_lpt.
{Renvoi 0 si ok
{       1 si plus de papier (PE=1)
{       2 si imprimante occup‚ (!BUSY=0)
{       3 si imprimante non connect‚e (ON LINE=0)
{*******************************************************}
var regs:registers;
begin
regs.ah:=2;
regs.dx:=numero_lpt;
dec(regs.dx);
intr($17,regs);
resultat:=0;
if (regs.ah and $80)=$0 then
  resultat:=2
else begin
  if (regs.ah and $10)=$0 then resultat:=3;
  if (regs.ah and $20)=$20 then resultat:=1;
  end;
end;


end.