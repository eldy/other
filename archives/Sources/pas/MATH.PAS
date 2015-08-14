UNIT MATH;

INTERFACE

function Signe(x:real):integer;
function Diraczero(x:integer):integer;
function Puissance(x,y:real):real;
function Puis_entiere(x,y:integer):longint;
function Factorielle(n:word):word;

IMPLEMENTATION


{*******************************************************}
FUNCTION SIGNE(x:real):integer;
{*******************************************************}
begin
if x=0 then signe:=0 else
  if x>0 then signe:=1 else signe:=-1;
end;


{*******************************************************}
FUNCTION DIRACZERO(x:integer):integer;
{*******************************************************}
begin
if x=0 then diraczero:=1 else diraczero:=0;
end;


{*******************************************************}
FUNCTION PUISSANCE(x,y:real):real;
{*******************************************************}
begin
if x=0 then
  if y=0 then puissance:=1
  else puissance:=0
else
  if x>0 then puissance:=exp(y*ln(x))
  else
    if odd(round(y)) then puissance:=SIGNE(x)*exp(y*ln(abs(x)))
    else puissance:=-SIGNE(x)*exp(y*ln(abs(x)));
end;


{*******************************************************}
FUNCTION PUIS_ENTIERE(x,y:integer):longint;
{*******************************************************}
var i,ii:longint;
begin
i:=1;
for ii:=1 to y do i:=i*x;
puis_entiere:=i;
end;


{*******************************************************}
FUNCTION FACTORIELLE(n:word):word;
{*******************************************************}
label boucle;
begin
asm
  mov cx,n;
  mov ax,1h;
boucle:
  mul cx;
  loop boucle;
  mov n,ax
  end;
factorielle:=n;
end;

end.