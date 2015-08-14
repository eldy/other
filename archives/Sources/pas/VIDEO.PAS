UNIT VIDEO;


INTERFACE

uses dos,crt;
const videoseg:word=$B800;
type twin=array[0..8003] of byte;
var win:twin;


FUNCTION ISEGAVGA:byte;
PROCEDURE GETVIDEOMODE(var modevideo,nbrecol,page:byte);
PROCEDURE SETVIDEOMODE(mode:word);
PROCEDURE SCREENOFF;
PROCEDURE SCREENON;
{Mode TEXTE seuleument}
Procedure Setpage(page:shortint);
PROCEDURE GETXYPOS(var x:integer;var y:integer);
PROCEDURE SETXYPOS(x,y:integer);
PROCEDURE SAUVEXY;
PROCEDURE RESTAUREXY;
PROCEDURE CAPTURESCREEN(x1,y1,x2,y2:integer;var win:twin);
PROCEDURE RESTORESCREEN(win:twin);
PROCEDURE CURSOROFF;
PROCEDURE CURSORON;
PROCEDURE SETMOUSE(et,ou_exclusif:word);
PROCEDURE SCROLLUP(nombre,couleur,x1,y1,x2,y2:byte);
FUNCTION CHARLOC(x,y:byte):Char;
{Mode GRAPHIQUE seuleument}
Procedure Putpixel(X,Y:word;color:byte);
Procedure Line(X1,Y1,X2,Y2,color:longint);


IMPLEMENTATION


FUNCTION ISEGAVGA:byte;
{*******************************************************}
{ Renvoie $00: Pas de carte vid‚o
{         $01: MDA monochrome
{         $02: CGA ‚cran CGA
{         $04: EGA ‚cran EGA
{         $05: EGA ‚cran monochrome
{         $07: VGA ‚cran monochrome
{         $08: VGA ‚cran couleur
{*******************************************************}
var regs:registers;
begin
regs.ax:=$1A00;    { La fonction 1Ah n'existe que pour VGA }
intr($10,regs);
if (regs.al=$1A) then  { La fonction est-elle disponible ? }
  Isegavga:=regs.bl    { Oui, une carte VGA est install‚e  }
else begin                { Pas de VGA, mais peut-ˆtre EGA }
  regs.ah:=$12;           { Appelle option 10h             }
  regs.bl:=$10;           { de la fonction 12h             }
  intr($10,regs);         { Interruption vid‚o             }
  if (regs.bl<>$10) then  { Est-ce une carte EGA ?         }
    begin                 { Oui, recherche l'‚cran associ‚ }
    if regs.bh=$00 then IsEgaVga:=$04 { EGA Mono    }
    else IsEgaVga:=$05;               { EGA Couleur }
    end
  else IsEgaVga:=$00;
  end;
end;


PROCEDURE GETVIDEOMODE(var modevideo,nbrecol,page:byte);
{*******************************************************}
{ Lit mode vid‚o:
{ $00: 40*25 car  monochrome
{ $01: 40*25 car  couleur
{ $02: 80*25 car  monochrome
{ $03: 80*25 car  couleur    Mode TEXTE par d‚faut
{ $04: 320*200*4             CGA
{ $06: 640*200*2             CGA
{ $0D: 320*200*16            EGA 2 pages (64K)
{ $0E: 640*200*16            EGA 4 pages (64K)
{ $0F: 640*350    monochrome EGA 2 pages
{ $10: 640*350*16            EGA 2 pages (128K)
{ $11: 640*480*2             VGA 4 pages (256K)
{ $12: 640*480*16            VGA 1 page  (256K)
{ $13: 320*200*256           VGA 4 pages (256K)
{*******************************************************}
var regs:registers;
begin
regs.ah:=$0F;       { Fonction $0F: Lecture mode vid‚o }
intr($10,Regs);     { Interruption vid‚o du BIOS       }
modevideo:=regs.al; { Mode vid‚o                       }
nbrecol:=regs.ah;   { Nombre colonnes par ligne        }
page:=regs.bh;      { Num‚ro page ‚cran courante       }
end;


PROCEDURE SETVIDEOMODE(mode:word);
{*******************************************************}
{ S‚lectionne mode video:
{ $00: 40*25 car  monochrome
{ $01: 40*25 car  couleur
{ $02: 80*25 car  monochrome
{ $03: 80*25 car  couleur    Mode TEXTE par d‚faut
{ $04: 320*200*4             CGA
{ $06: 640*200*2             CGA
{ $0D: 320*200*16            EGA 2 pages (64K)
{ $0E: 640*200*16            EGA 4 pages (64K)
{ $0F: 640*350    monochrome EGA 2 pages
{ $10: 640*350*16            EGA 2 pages (128K)
{ $11: 640*480*2             VGA 4 pages (256K)
{ $12: 640*480*16            VGA 1 page  (256K)
{ $13: 320*200*256           VGA 4 pages (256K)
{*******************************************************}
var regs:registers;
begin
regs.ax:=mode; { Fonction AH=$00, AL=mode video }
intr($10,Regs);      { Interruption vid‚o du BIOS     }
end;


PROCEDURE SCREENOFF;
{*******************************************************}
{ Eteint ‚cran
{*******************************************************}
const EGAVGA_C=$3DA; { Registre d'‚tat couleur EGA/VGA }
      EGAVGA_M=$3BA; { Registre d'‚tat mono EGA/VGA    }
      EGAVGA_A=$3C0; { Contr“leur d'attribut EGA/VGA   }
var savebyte:byte;   { Pour m‚moriser les contenus des registres }
begin
inline($FA);              { CLI inhibe les interruptions }
savebyte:=port[EGAVGA_M]; { Reset du registre d'‚tat mono }
savebyte:=port[EGAVGA_C]; { Reset du registre d'‚tat couleur }
port[EGAVGA_A]:=$00;      { Efface le bit 5 ce qui supprime la liaison avec le contr“leur d'‚cran }
inline($FB);              { STI r‚tablit les interruptions }
end;


PROCEDURE SCREENON;
{*******************************************************}
{ Rallume ‚cran
{*******************************************************}
const EGAVGA_C=$3DA; { Registre d'‚tat couleur EGA/VGA }
      EGAVGA_M=$3BA; { Registre d'‚tat mono EGA/VGA    }
      EGAVGA_A=$3C0; { Contr“leur d'attribut EGA/VGA   }
var savebyte:byte;
begin
inline($FA);              { CLI Inhibe les interruptions }
savebyte:=port[EGAVGA_M]; { Reset du registre d'‚tat mono }
savebyte:=port[EGAVGA_C]; { Reset du registre d'‚tat couleur }
port[EGAVGA_A]:=$20;      { Active le bit 5 ce qui r‚tablit la liaison avec le contr“leur d'‚cran}
inline($FB);              { STI r‚tablit les interruptions }
end;


{ En mode Texte uniquement }


FUNCTION GETPAGE:shortint;
{*******************************************************}
{ S‚lectionne nouvelle page d'‚cran
{*******************************************************}
var regs:registers;
begin
regs.ah:=$0F;       { Fonction $0F: Lecture mode vid‚o }
intr($10,Regs);     { Interruption vid‚o du BIOS       }
GETPAGE:=regs.bh;   { Num‚ro page ‚cran courante       }
end;


PROCEDURE SETPAGE(page:shortint);
{*******************************************************}
{ S‚lectionne nouvelle page d'‚cran
{*******************************************************}
var regs:registers;
begin
regs.ah:=$05;   { Fonction 05h: Set Page                 }
regs.al:=page;  { Page d'‚cran                           }
intr($10,regs); { D‚clenche l'interruption vid‚o du BIOS }
end;


PROCEDURE GETXYPOS(var x,y:integer);
{*******************************************************}
{Retourne position absolue du curseur (x:1-80,y:1-25,1-43,1-50)
{*******************************************************}
begin
x:=wherex+lo(windmin);
y:=wherey+hi(windmin);
end;


PROCEDURE SETXYPOS(x,y:integer);
{*******************************************************}
{Positionne curseur aux coordonn‚es absolues x,y (x:1-80,y:1-25,1-43,1-50)
{*******************************************************}
var i,j:integer;
begin
i:=lo(windmin);j:=hi(windmin);
if (x>=i) and (y>=j) then gotoxy(x-i,y-i);
end;


var wmin,wmax,x,y:word;


PROCEDURE SAUVEXY;
{*******************************************************}
{Sauve configuration de windmin,windmax,wherex,wherey.
{*******************************************************}
begin
wmin:=windmin;wmax:=windmax;
x:=wherex;y:=wherey;
end;


PROCEDURE RESTAUREXY;
{*******************************************************}
{Restaure configuration de windmin,windmax,wherew,wherey.
{A appeler aprŠs SAUVEXY.
{*******************************************************}
begin
windmin:=wmin;windmax:=wmax;
gotoxy(x,y);
end;


PROCEDURE CAPTURESCREEN(x1,y1,x2,y2:integer;var win:twin);
{*******************************************************}
{Enregistre m‚moire vid‚o pour ‚cran jusque 80x50
{x1,x2 compris entre 1 et 80
{y1,y2 compris entre 1 et 50
{*******************************************************}
var x,y,i:integer;
begin
win[8000]:=x1;
win[8001]:=y1;
win[8002]:=x2;
win[8003]:=y2;
i:=0;
inline ($FA);
for y:=y1 to y2 do
  for x:=x1 to x2 do begin
    win[i]:=mem[videoseg:(160*(y-1)+2*(x-1))];
    win[i+1]:=mem[videoseg:(160*(y-1)+2*(x-1))+1];
    inc(i,2);
    end;
inline($FB);
end;


PROCEDURE RESTORESCREEN(win:twin);
{*******************************************************}
{x1,x2 compris entre 1 et 80
{y1,y2 compris entre 1 et 50
{*******************************************************}
var x1,y1,x2,y2,x,y,i:integer;
begin
x1:=win[8000];
y1:=win[8001];
x2:=win[8002];
y2:=win[8003];
i:=0;
inline($FA);
for y:=y1 To y2 do
  for x:=x1 To x2 do begin
    mem[$B800:(160*(y-1)+2*(x-1))]:=win[i];
    mem[$B800:(160*(y-1)+2*(x-1))+1]:=win[i+1];
    inc(i,2);
    end;
inline($FB);
end;


PROCEDURE CURSOROFF;
{*******************************************************}
{D‚sactive curseur clignotant
{*******************************************************}
begin
end;


PROCEDURE CURSORON;
{*******************************************************}
{R‚active curseur clignotant
{*******************************************************}
var regs:registers;
begin
regs.ch:=$06;
regs.cl:=$07;
regs.ah:=$01;
intr($10,regs);
end;


PROCEDURE SETMOUSE(et,ou_exclusif:word);
{*******************************************************}
{S‚lectionne type curseur souris
{Valeurs par d‚faut: et=$FFFF,ou_exclusif:=$7700
{*******************************************************}
var regs:registers;
begin
regs.ax:=$000A;
regs.bx:=0;
regs.cx:=et;
regs.dx:=ou_exclusif;
intr($33,regs);
end;



PROCEDURE SCROLLUP(nombre,couleur,x1,y1,x2,y2:byte);
{*******************************************************}
{ Fait avancer une zone fenetr‚e d'une ou plusieurs lignes
{ vers le haut ou l'efface
{ Entr‚e: NOMBRE  = Nombre de lignes … faire d‚filer
{         COULEUR = Couleur ou Attribut des lignes vides
{         COLSG   = Colonne du coin sup‚rieur gauche de la zone
{         LIGNSG  = Ligne du coin sup‚rieur gauche de la zone
{         COLID   = Colonne du coin inf‚rieur droit de la zone
{         LIGNID  = Ligne du coin inf‚rieur droit de la zone
{ Sortie: Aucune
{ Infos : Si nombre=0, la zone est alors compl‚t‚e par des espaces
{*******************************************************}
var regs:registers;
begin
regs.ah:=$06;
regs.al:=nombre;
regs.bh:=couleur;
regs.cl:=x1;
regs.ch:=y1;
regs.dl:=x2;
regs.dh:=y2;
intr($10,regs);
end;


FUNCTION CHARLOC(x,y:byte):char;
{*******************************************************}
{ Retourne le char aux coordonn‚es (x,y) absolues sans
{ changer position du curseur
{*******************************************************}
begin
charloc:=chr(mem[videoseg:(80*y+x-81) shl 1])
end;


{ En mode Graphique uniquement }


PROCEDURE PUTPIXEL(x,y:word;color:byte);
{*******************************************************}
{ Allume pixel en (x,y)
{*******************************************************}
begin
mem[$A000:y*320+x]:=color;
end;


PROCEDURE SWITCH(Var First,Second:integer);
{ Echange valeur premier et second }
Var i:integer;
begin
i:=first;
first:=second;
second:=i;
end;

PROCEDURE LINE(X1,Y1,X2,Y2,color:longint);
{*******************************************************}
{ Dessine ligne avec algorithme de Bresenham
{*******************************************************}
Var LgDelta,ShDelta,LgStep,ShStep,Cycle:integer;
begin
LgDelta:=X2-X1;
ShDelta:=Y2-Y1;
if LgDelta<0 then begin
  LgDelta:=-LgDelta;
  LgStep:=-1;
  end
else LgStep:=1;
if ShDelta<0 then begin
  ShDelta:=-ShDelta;
  ShStep:=-1;
  end
else ShStep:=1;
if LgDelta>ShDelta then begin
  Cycle:=LgDelta shr 1; { LgDelta/2 }
  While X1<>X2 do begin
    mem[$A000:Y1*320+X1]:=Color; { PutPixel(X1,Y1,Color); }
    inc(X1,LgStep);
    inc(Cycle,ShDelta);
    if Cycle>LgDelta then begin
      Inc(Y1,shstep);
      dec(cycle,lgdelta);
      end;
    end;
  end
else begin
  Cycle:=ShDelta shr 1; { ShDelta/2 }
  Switch(LgDelta,shdelta);
  Switch(LgStep,shstep);
  While Y1<>Y2 do begin
    mem[$A000:Y1*320+X1]:=color; { PutPixel(X1,Y1,Color); }
    inc(Y1,LgStep);
    inc(Cycle,ShDelta);
    if cycle>LgDelta then begin
      inc(X1,shstep);
      dec(cycle,lgdelta);
      end;
    end;
  end;
end;



begin
if mem[$40:$63]=$3B4 then videoseg:=$B000; {Carte monochrome}
end.
