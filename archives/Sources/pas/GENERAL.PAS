UNIT GENERAL;

INTERFACE

FUNCTION FILLZERO(x,l:integer):string;
FUNCTION FILLSPACE(s:string;l:integer):string;
FUNCTION BYTE_HEX(b:byte):string;
FUNCTION WORD_HEX(w:word):string;
FUNCTION MAJUSCULE(s:string):string;
FUNCTION NOMPROPRE(s:string):string;
FUNCTION CLEARSPACE(s:string):string;
FUNCTION CHAINEVIERGE(s:string):boolean;
FUNCTION CODE(s:string;i:integer):string;
FUNCTION DECODE(s:string;i:integer):string;


IMPLEMENTATION


FUNCTION FILLZERO(x,l:integer):string;
{*******************************************************}
{ Transforme  x en  000x avec l=nbre chiffres
{ Transforme -x en -000x avec l=nbre chiffres
{*******************************************************}
var s:string;
    i:integer;
begin
str(x,s);
if s[1]='-' then begin
  for i:=1 to (l-length(s)) do
    s:=s[1]+'0'+copy(s,2,length(s)-1)
  end
else begin
  for i:=1 to (l-length(s)) do
    s:='0'+s
  end;
fillzero:=s;
end;


FUNCTION FILLSPACE(s:string;l:integer):string;
{*******************************************************}
{Transforme 's' en '  s' avec l=nbre char
{*******************************************************}
begin
while length(s)<l do s:=' '+s;
end;


FUNCTION SWAP_BYTE(b:byte):byte;
{*******************************************************}
{Swap un byte
{*******************************************************}
var w:word;
begin
w:=0;
w:=b shl 4;
SWAP_BYTE:=lo(w)+hi(w);
end;


FUNCTION SWAP_WORD(w:word):word;
{*******************************************************}
{Swap un word
{*******************************************************}
begin
SWAP_WORD:=hi(w)+(lo(w) shl 8);
end;


FUNCTION BYTE_HEX(b:byte):string;
{*******************************************************}
{Conversion Byte->Hex
{*******************************************************}
const hexchars:array[0..15] of char='0123456789ABCDEF';
begin
Byte_Hex[0]:=#2;
Byte_Hex[1]:=hexchars[b shr 4];
Byte_Hex[2]:=hexchars[b and 15];
end;


FUNCTION WORD_HEX(w:word):string;
{*******************************************************}
{Conversion Word->Hex
{*******************************************************}
begin
word_hex:=byte_hex(hi(w))+byte_hex(lo(w));
end;


FUNCTION MAJUSCULE(s:string):string;
{*******************************************************}
{Renvoi chaine s en chaine majuscule
{*******************************************************}
var i:integer;
begin
for i:=1 to length(s) do s[i]:=upcase(s[i]);
majuscule:=s;
end;


FUNCTION NOMPROPRE(s:string):string;
{*******************************************************}
{Renvoi chaine s avec premiŠre lettre en majuscule
{*******************************************************}
begin
s[1]:=upcase(s[1]);
nompropre:=s;
end;


FUNCTION CLEARSPACE(s:string):string;
{*******************************************************}
{Renvoi la chaine sans espaces
{*******************************************************}
var b:boolean;
    i:integer;
begin
while pos(' ',s)>0 do delete(s,pos(' ',s),1);
clearspace:=s;
end;


FUNCTION CHAINEVIERGE(s:string):boolean;
{*******************************************************}
{Renvoi True si la chaine s n'a que des espaces
{*******************************************************}
var b:boolean;
    i:integer;
begin
b:=true;
for i:=1 to length(s) do b:=(b and (s[i]=' '));
chainevierge:=b;
end;


FUNCTION CODE(s:string;i:integer):string;
{*******************************************************}
{Transforme chaine s en chaine cod‚e
{*******************************************************}
var t:string;
    j:integer;
begin
t:='';
for j:=1 to length(s) do begin
  t:=t+chr(SWAP_BYTE(i xor ord(s[j])))
  end;
code:=t;
end;


FUNCTION DECODE(s:string;i:integer):string;
{*******************************************************}
{Transforme chaine s en chaine cod‚e
{*******************************************************}
var t:string;
    j:integer;
begin
t:='';
for j:=1 to length(s) do begin
  t:=t+chr(i xor SWAP_BYTE(ord(s[j])))
  end;
decode:=t;
end;

end.