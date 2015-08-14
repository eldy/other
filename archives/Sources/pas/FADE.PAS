UNIT FADE;

INTERFACE

uses crt;
type tpalette=array[0..255,1..3] of byte; { 256 Red/Green/Blue }
var oldpalette:tpalette;
procedure Fadeup;
procedure Fadedown;


IMPLEMENTATION


{*******************************************************}
Procedure GETPAL(var pal:tpalette);
{ Load Pal Structure with the 256 RGB palette values. }
var w:word;
begin
port[$3C7]:=0;
{ when a read is made on port $3C9 it increment port $3C7 so no changing }
{ of the register port ($3C7) needs to be performed here                 }
for w:=0 to 255 do begin
  pal[w,1]:=port[$3C9]; { Read red value   }
  pal[w,2]:=port[$3C9]; { Read green value }
  pal[w,3]:=port[$3C9]; { Read blue value  }
  end;
end;

Procedure SETPAL(var pal:tpalette);
{ SetPal86: Loads the palette Registers With the values in Pal.
  86/88 instructions. }
begin
Asm
  push  ds        { preserve segment Registers }
  push  es
  mov   cx,256*3  { 256 RBG values             }
  mov   dx,03DAh
  { by waiting For the retrace to end it avoids static }
  { when the palette is altered                        }
@retrace1:
  in    al,dx     { wait For no retrace        }
  and   al,8      { check For retrace          }
  jnz   @retrace1 { so loop Until it goes low  }
@retrace2:
  in    al,dx     { wait For retrace           }
  and   al,8      { check For retrace          }
  jz    @retrace2 { so loop Until it goes high }
  lds   si, Pal   { ds:si = @Pal               }
  mov   dx,3c8h   { set up For a blitz-white   }
  mov   al,0      { from this register         }
  cli             { disable interrupts         }
  out   dx,al     { starting register          }
  inc   dx        { set up to update DAC       }
  cld             { clear direction flag       }
@outnext:
  { the following code is what I have found to be the most    }
  { efficient way to emulate the "rep outsb" 286 instructions }
  { on the 8086/88.                                           }
  lodsb           { load al With ds:[si]       }
  out   dx,al     { out al to port in dx       }
  loop  @outnext  { loop cx times              }
  sti             { end of critical section    }
  pop   es
  pop   ds        { restore segment Registers  }
  end;
end;
{*******************************************************}


{*******************************************************}
PROCEDURE FADEDOWN;
{*******************************************************}
var plt  :tpalette;
    i,j,k:Integer;
begin
plt:=oldpalette;
for k:=0 to 63 do begin
  for j:=0 to 255 do
    for i:=1 to 3 do begin
      if plt[j,i]>0 then dec(plt[j,i]);
      if plt[j,i]>0 then dec(plt[j,i]);
      end;
  setpal(plt); { Gradually fade down the palette }
  end;
end;


{*******************************************************}
PROCEDURE FADEUP;
{*******************************************************}
var plt  :tpalette;
    i,j,k:Integer;
begin
getpal(plt); { Load current palette }
for k:=1 to 63 do begin
  for j:=0 to 255 do
    for i:=1 to 3 do begin
      if plt[j,i]<oldpalette[j,i] then inc(plt[j,i]);
      if plt[j,i]<oldpalette[j,i] then inc(plt[j,i]);
      end;
    setpal(Plt); { Gradually fades up the palette to the normal values }
  end;
end;


begin
getpal(oldpalette);
end.