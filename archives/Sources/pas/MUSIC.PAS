UNIT MUSIC;

INTERFACE

Procedure note(f,t:integer);


IMPLEMENTATION


PROCEDURE NOTE(f,t:integer); assembler;
{*******************************************************}
{f=frequency above 20 Hz
{t=nbre of clock ticks=t/18 s
{*******************************************************}
Asm
mov ax,1019h
mov bx,f
mov cx,t
int 15h
end;


end.