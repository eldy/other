PROGRAM filetime;
{*******************************************************}
{* PROGRAM: Change date and time of files              *}
{*******************************************************}
{* 12/01/96      3.0    Laurent Destailleur   Creation *}
{*******************************************************}
{$M $4000,$4000,$4000} {16Ko pour tout}

uses dos,hardware,keyboard,time,video;
const VERSION='3.0';
      PROG='FileTime';
      attribut:integer=$30; {Modifie par defaut fichiers sans attributs ou avec
                                     attributs A et D mais pas R,H,S,V}
      nouvelle_date:boolean=false;
      nouvelle_heure:boolean=false;
      nbre_fichiers:integer=0;
var dt,new_dt:datetime;
    dayofweek,sec100:word;
    s:string;
    i,j:integer;
    codeerreur:integer;
    filename:string;
    c:char;
    dir:dirstr;
    name:namestr;
    ext:extstr;
    srec:searchrec;
    ftime:longint;
    f:file;


PROCEDURE ERREUR(i:shortint);
{*******************************************************}
{Fin du programme avec erreur
{*******************************************************}
begin
case i of
  1,4,5,6,7:begin
    writeln('Usage:  ',PROG,'  <[Directory][File(s)]>  /option');
    if i=4 then begin
      writeln;
      writeln('Error :  New date format is not valid.');
      end;
    if i=5 then begin
      writeln;
      writeln('Error :  New hour format is not valid.');
      end;
    if i=6 then begin
      writeln;
      writeln('Error:  Specify the change of date or of hour with the /d or /h option.');
      writeln('Type :  Filetime /? for help.');
      writeln('        Filetime /i for informations about sources and other UTILKIT utilities.');
      end;
    if i=1 then begin
      writeln;
      writeln('FileTime change the files date and/or hour attribut:');
      writeln('   /d          To replace the date of files with the current date.');
      writeln('   /dDD.MM.YY  To replace the date with DD.MM.YY where DD=Day,MM=Month,YY=Year.');
      writeln('   /h          To replace the hour with the current hour.');
      writeln('   /hHH.MM     To replace the hour with HH.MM where HH=Hour,MM=Minutes.');
      writeln('   /a          To include All files, even with R,H or S attribut.');
      writeln('   /?          To show this help screen.');
      writeln('   /i          For informations about sources and other utilities.');
      writeln;
      write(  'If no file names are put, all files in the directory will be processed.');
      writeln('FileTime doesn''t change the date and/or hour without changing files attributs.');
      write(  'Files with R attributs (Read only), H (Hidden) and S (Systems) can be processed');
      writeln('if the option /a is specified.');
      writeln;
      end;
    if i=7 then begin
      writeln;
      writeln('FileTime is an utility of the UTILKIT pack, available from its distributors');
      writeln('from the author for a registration fee of 6$ (or 40FF in France) sent to the');
      writeln('following address (Answer within 15 days):');
      writeln;
      writeln('Laurent DESTAILLEUR,     ');
      writeln('58 Rue Fran‡ois Mauriac,                  E-Mail address:');
      writeln('78180 Montigny-le-Bretonneux              101642.2125@compuserve.com');
      writeln('FRANCE.                  ');
      writeln;
      writeln('Note: All sources of the utilities of the UTILKIT pack (Pascal or C) will be');
      writeln('sent with the kit as well, on request.');
      writeln;
      end;
    end;
  2:writeln('No file found.');
  3:writeln('No TIME/DATE attribut changed.');
  end;
CURSORON;
halt(i);
end;


PROCEDURE CHANGETIMEDATE;
{*******************************************************}
{Lit attributs fichier et r‚‚crit les nouveaux
{*******************************************************}
begin
getftime(f,ftime);
unpacktime(ftime,dt);
if nouvelle_date then begin
  dt.year:=new_dt.year;
  dt.month:=new_dt.month;
  dt.day:=new_dt.day;
  end;
if nouvelle_heure then begin
  dt.hour:=new_dt.hour;
  dt.min:=new_dt.min;
  end;
packtime(dt,ftime);
setftime(f,ftime);
end;



{*******************************************************}
{                PROGRAMME PRINCIPAL
{*******************************************************}
begin
writeln('----- ',PROG,' V',VERSION,' (c)Laurent Destailleur (ld@writeme.com) -----');
getdate(new_dt.year,new_dt.month,new_dt.day,dayofweek);
gettime(new_dt.hour,new_dt.min,new_dt.sec,sec100);
for i:=paramcount downto 1 do begin
  s:=paramstr(i);
  if s[1]='/' then
    case upcase(s[2]) of
      'A':attribut:=$3F;
      '?':erreur(1);
      'I':erreur(7);
      'D':begin
        nouvelle_date:=true;
        if length(s)>2 then begin
          val(copy(s,3,2),new_dt.day,codeerreur);
          if codeerreur<>0 then begin
            val(copy(s,3,1),new_dt.day,codeerreur);
            j:=5;
            end
          else j:=6;
          if codeerreur<>0 then erreur(4);
          val(copy(s,j,2),new_dt.month,codeerreur);
          if codeerreur<>0 then begin
            val(copy(s,j,1),new_dt.month,codeerreur);
            j:=j+2;
            end
          else j:=j+3;
          if codeerreur<>0 then erreur(4);
          val(copy(s,j,2),new_dt.year,codeerreur);
          if codeerreur<>0 then erreur(4);
          new_dt.year:=new_dt.year+1900;
          if (new_dt.year<1980) or (new_dt.day>2100) then erreur(4);
          if (new_dt.month<1) or (new_dt.month>12) then erreur(4);
          if (new_dt.day<0) or (new_dt.day>NBREJOUR(new_dt.month,new_dt.year)) then erreur(4);
          end;
        end;
      'H':begin
        nouvelle_heure:=true;
        if length(s)>2 then begin
          val(copy(s,3,2),new_dt.hour,codeerreur);
          if codeerreur<>0 then begin
            val(copy(s,3,1),new_dt.hour,codeerreur);
            j:=5;
            end
          else j:=6;
          if codeerreur<>0 then erreur(5);
          val(copy(s,j,2),new_dt.min,codeerreur);
          if codeerreur<>0 then begin
            val(copy(s,j,1),new_dt.min,codeerreur);
            j:=j+2;
            end
          else j:=j+3;
          if codeerreur<>0 then erreur(5);
          val(copy(s,j,2),new_dt.sec,codeerreur);
          if codeerreur<>0 then begin
            val(copy(s,j,1),new_dt.sec,codeerreur);
            end;
          if (new_dt.hour<0) or (new_dt.hour>23) then erreur(5);
          if (new_dt.min<0) or (new_dt.month>59) then erreur(5);
          if (new_dt.sec<0) or (new_dt.sec>59) then erreur(5);
          end;
        end;
      end
  else filename:=paramstr(i);
  end;
filename:=fexpand(filename);
fsplit(filename,dir,name,ext);
if name='' then begin
  name:='*';
  ext:='.*';
  end;
srec.name:='';
srec.attr:=attribut;
if (not nouvelle_date) and (not nouvelle_heure) then erreur(6);
write('Change ');
if nouvelle_date then write('date ');
if nouvelle_heure then begin
  if nouvelle_date then write('and ');
  write('hour ');
  end;
write('of files ',dir+name+ext,'  (Y/N) : ');
c:=YES_NO;
writeln(c);
CURSOROFF;
if c='N' then erreur(3);
findfirst(dir+name+ext,srec.attr,srec);
{$I-}
if fileexist(dir+srec.name) then begin
  repeat
    filename:=dir+srec.name;
    assign(f,filename);
    if (srec.attr or attribut)=attribut then begin
      setfattr(f,$0); {Supprime attributs}
      reset(f);
      CHANGETIMEDATE;
      close(f);
      setfattr(f,srec.attr); {Restore attributs}
    end;
    srec.attr:=attribut;
    findnext(srec);s:=dir+srec.name;
    if ioresult=0 then inc(nbre_fichiers);
  until s=filename;
end;
{$I+}
if (ioresult<>0) then i:=0;
if (nbre_fichiers>0) then begin
  writeln('TIME/DATE attributs changed for ',nbre_fichiers,' files.');
end
else ERREUR(2);
CURSORON;
end.
