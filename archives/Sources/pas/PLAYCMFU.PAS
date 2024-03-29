UNIT playcmfu;
{
 ********************************************************************
 *Unit� pour controler les cartes Sound Blaster en  Turbo-Pascal 6.0*
 *             en utilisant le Driver SBFMDRV.COM.                  *
 ********************************************************************
 *                 (C) 1992 MICRO APPLICATION                       *
 *                    Auteur : Axel Stolz                           *
 ********************************************************************
}

INTERFACE

USES Dos;

TYPE
  CMFFileTyp = FILE;
  CMFDataTyp = Pointer;
  CMFHeader = RECORD  { Structure d'un CMF-File-Headers }
    CMFFileID         : ARRAY[0..3] OF CHAR;  { CMF file ID = 'CTMF'      }
    CMFVersion        : WORD;                 { Num�ro de version         }
    CMFInstrBlockOfs  : WORD;                 { Offset pour Instrument    }
    CMFMusicBlockOfs  : WORD;                 { Offset Titre musical      }
    CMFTickPerBeat    : WORD;                 { "Ticks" pro Beat          }
    CMFClockTicksPS   : WORD;                 { Timer-Clock-Rate          }
    CMFFileTitleOfs   : WORD;                 { Offset Titre musical      }
    CMFComposerOfs    : WORD;                 { Offset Music composer     }
    CMFMusicRemarkOfs : WORD;                 { Offset Remarques musicales}
    CMFChannelsUsed   : ARRAY[0..15] OF CHAR; { Nombre de canaux utilis�s }
    CMFInstrNumber    : WORD;                 { Nombre d'instruments      }
    CMFBasicTempo     : WORD;                 { Tempo musical de base     }
  END;

CONST
   CMFToolVersion       = 'v1.0';

VAR
   CMFStatusByte      : BYTE;       { Variable pour CMF-Status           }
   CMFErrStat         : WORD;       { Variable pour CMF-Num�ro d'erreur  }
   CMFDriverInstalled : BOOLEAN;    { Flag, driver install,              }
   CMFDriverIRQ       : WORD;       { Num�ros d'interruptions utilis�s    }
   CMFSongPaused      : BOOLEAN;    { Flag, son stop,                    }
   OldExitProc        : Pointer;    { Pointeur sur l'ancienne  ExitProc  }

PROCEDURE PrintCMFErrMessage;
FUNCTION  CMFGetSongBuffer(VAR CMFBuffer : Pointer; CMFFile : STRING):BOOLEAN;
FUNCTION  CMFFreeSongBuffer (VAR CMFBuffer : Pointer):BOOLEAN;
FUNCTION  CMFInitDriver : BOOLEAN;
FUNCTION  CMFGetVersion : WORD;
PROCEDURE CMFSetStatusByte;
FUNCTION  CMFSetInstruments(VAR CMFBuffer : Pointer):BOOLEAN;
FUNCTION  CMFSetSingleInstruments(VAR CMFInstrument:Pointer; No:WORD):BOOLEAN;
PROCEDURE CMFSetSysClock(Frequency : WORD);
PROCEDURE CMFSetDriverClock(Frequency : WORD);
PROCEDURE CMFSetTransposeOfs (Offset : INTEGER);
FUNCTION  CMFPlaySong(VAR CMFBuffer : Pointer) : BOOLEAN;
FUNCTION  CMFStopSong : BOOLEAN;
FUNCTION  CMFResetDriver:BOOLEAN;
FUNCTION  CMFPauseSong : BOOLEAN;
FUNCTION  CMFContinueSong : BOOLEAN;

IMPLEMENTATION

TYPE
   TypeCastTyp = ARRAY [0..6000] of Char;

VAR
   Regs : Registers;
   CMFIntern : ^CMFHeader; { Pointeur interne sur la structure CMF }

PROCEDURE PrintCMFErrMessage;
{
 * ENTREE  : aucune
 * SORTIE  : aucune
 * FONCTION : Affiche � l'�cran sous forme texte, l'erreur SB venant
 *          de se produire sans modifier la valeur du Status.
}
BEGIN
   CASE CMFErrStat OF
      100 : Write(' Driver son SBFMDRV non trouv� ');
      110 : Write(' Driver Reset sans succ�s ');

      200 : Write(' FichierCMF non trouv� ');
      210 : Write(' Espace m�moire insuffisant pour le fichier CMF ');
      220 : Write(' Le fichier n''est pas au format CMF ');

      300 : Write(' Erreur d''impl�mentation en m�moire ');

      400 : Write(' Trop d''instruments d�finis ');

      500 : Write(' Les donn�es CMF ne peuvent pas �tre diffus�es');
      510 : Write(' Les donn�es CMF ne peuvent pas �tre stopp�es ');
      520 : Write(' Les donn�es CMF ne peuvent pas �tre interrompues ');
      530 : Write(' Les donn�es CMF ne peuvent pas �tre reprises ');
   END;
END;

FUNCTION Exists (Filename : STRING):BOOLEAN;
{
 * ENTR�E  : Nom de fichier sous forme cha�ne de caract�res
 * SORTIE  : TRUE si le fichier est pr�sent, FALSE si non.
 * FONCTION : V�rifie qu'un fichier est pr�sent et retourne la valeur
              bool�enne correspondante.
}
VAR
   F : File;
BEGIN
   Assign(F,Filename);
{$I-}
   Reset(F);
   Close(F);
{$I+}
   Exists := (IoResult = 0) AND (Filename <> '');
END;

PROCEDURE AllocateMem (VAR Pt : Pointer; Size : LongInt);
{
 * ENTR�E  : Pointeur sur le buffer,taille du buffer sous forme entier
              long.
 * SORTIE  : Pointeur sur le buffer, ou NIL.
 * FONCTION : R�serve autant d'octets qu'indiqu� dans la taille, et
              positionne le pointeur sur le buffer ainsi constitu�.
              S'il n'y a pas suffisamment de m�moire, positionne le
              pointeur sur NIL.
}
VAR
   SizeIntern : WORD;     { Taille du buffer pour calcul interne}
BEGIN
   Inc(Size,15);                 { Augmenter la taille du buffer de 15  }
   SizeIntern := (Size shr 4);   { et diviser ensuite par 16            }
   Regs.AH := $48;               { Charger la fonction MSDOS $48 dans AH}
   Regs.BX := SizeIntern;        { Charger la taille interne dans BX    }
   MsDos(Regs);                  { R�server la m�moire                  }
   IF (Regs.BX <> SizeIntern) THEN Pt := NIL
   ELSE Pt := Ptr(Regs.AX,0);
END;

FUNCTION  CheckFreeMem (VAR CMFBuffer : Pointer; CMFSize : LongInt):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer, longueur d�sir�e sous forme d'entier
             long.
 * SORTIE  : Pointeur sur le buffer, TRUE/FALSE suivant AllocateMem.
 * FONCTION : V�rifie qu'il y a suffisamment de m�moire pour un fichier
              CMF.
}
BEGIN
   AllocateMem(CMFBuffer,CMFSize);
   CheckFreeMem := CMFBuffer <> NIL;
END;

FUNCTION  CMFGetSongBuffer(VAR CMFBuffer : Pointer; CMFFile : STRING):BOOLEAN;
{
 * ENTR�E  :  Pointeur sur le buffer, nom de fichier sous forme cha�ne de
               caract�res.
 * SORTIE  : Pointeur sur le buffer contenant des donn�es CMF, TRUE/FALSE
 * FONCTION : Charge un fichier en m�moire et retourne le valeur TRUE en
              cas de succ�s, ou sinon FALSE.

}
CONST
   FileCheck : STRING[4] = 'CTMF';
VAR
   CMFFileSize : LongInt;
   FPresent    : BOOLEAN;
   VFile       : CMFFileTyp;
   Segs        : WORD;
   Read        : WORD;
   Checkcount  : BYTE;

BEGIN
   FPresent := Exists(CMFFile);

{ Le fichier CMF n'a pas �t� trouv� }
   IF Not(FPresent) THEN BEGIN
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 200;
      EXIT
   END;

   Assign(VFile,CMFFile);
   Reset(VFile,1);
   CMFFileSize := Filesize(VFile);
   AllocateMem(CMFBuffer,CMFFileSize);

{ Espace m�moire insuffisant pour le fichier CMF }
   IF (CMFBuffer = NIL) THEN BEGIN
      Close(VFile);
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 210;
      EXIT;
   END;

   Segs := 0;
   REPEAT
      Blockread(VFile,Ptr(seg(CMFBuffer^)+4096*Segs,Ofs(CMFBuffer^))^,$FFFF,Read);
      Inc(Segs);
      UNTIL Read = 0;
   Close(VFile);

{ Le fichier n'est pas au format CMF }
   CMFIntern := CMFBuffer;
   CheckCount := 1;
   REPEAT
      IF FileCheck[CheckCount] = CMFIntern^.CMFFileID[CheckCount-1]
         THEN Inc(CheckCount)
         ELSE CheckCount := $FF;
      UNTIL CheckCount >= 3;
   IF NOT(CheckCount = 3) THEN BEGIN
      CMFGetSongBuffer := FALSE;
      CMFErrStat   := 220;
      EXIT;
   END;

{ Le chargement a �t� correctement effectu� }
   CMFGetSongBuffer := TRUE;
   CMFErrStat   := 0;
END;

FUNCTION CMFFreeSongBuffer (VAR CMFBuffer : Pointer):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer
 * SORTIE  : aucune
 * FONCTION : Lib�re � nouveau la m�moire occup�e par les donn�es CMF.
}
BEGIN
   Regs.AH := $49;              { MS-DOS Fonction $49 charg� dans AH  }
   Regs.ES := seg(CMFBuffer^);  { Charger le segment dans ES          }
   MsDos(Regs);                 { Lib�rer la m�moire                  }
   CMFFreeSongBuffer := TRUE;
   IF (Regs.AX = 7) OR (Regs.AX = 9) THEN BEGIN
      CMFFreeSongBuffer := FALSE;
      CMFErrStat := 300      { Lors de la lib�ration, est apparue  }
   END;                      { une erreur DOS                      }
END;


FUNCTION CMFInitDriver : BOOLEAN;
{
 * ENTR�E  : aucune
 * SORTIE  : TRUE, si le driver a �t� trouv� et install�, FALSE sinon
 * FONCTION : V�rifie que, SBFMDRV.COM est en m�moire, et effectue un Reset
 *              du driver
}

CONST
   DriverCheck :STRING[5] = 'FMDRV'; { cha�ne de caract�re cherch�e dans SBFMDRV }
VAR
   ScanIRQ,
   CheckCount  : BYTE;
   IRQPtr,
   DummyPtr    : Pointer;

BEGIN
{ Les interruptions possibles pour SBFMDRV vont de $80 � $BF }
   FOR ScanIRQ := $80 TO $BF DO BEGIN
      GetIntVec(ScanIRQ, IRQPtr);
      DummyPtr := Ptr(Seg(IRQPtr^), $102);

{ V�rifie que la cha�ne FMDRV est pr�sente dans le programme d'interruption }
{ Il s'agit alors de SBFMDRV              }
      CheckCount := 1;
      REPEAT
         IF DriverCheck[CheckCount] = TypeCastTyp(DummyPtr^)[CheckCount]
            THEN Inc(CheckCount)
            ELSE CheckCount := $FF;
         UNTIL CheckCount >= 5;

      IF (CheckCount = 5) THEN BEGIN
{ La cha�ne de caract�res a �t� trouv�e, maintenant Reset sera effectu� }
         Regs.BX := 08;
         CMFDriverIRQ := ScanIRQ;
         Intr(CMFDriverIRQ, Regs);
         IF Regs.AX = 0 THEN
            CMFInitDriver := TRUE
         ELSE BEGIN
            CMFInitDriver := FALSE;
            CMFErrStat    := 110;
         END;
         Exit;
       END
      ELSE BEGIN
{ La cha�ne de caract�res n'a pas �t� trouv�e }
         CMFInitDriver := FALSE;
         CMFErrStat := 100;
         END;
      END;
   END;

FUNCTION CMFGetVersion : WORD;
{
 * ENTR�E  : aucune
 * SORTIE  : Premier num�ro de version dans l'octet de poids fort, second num�ro
 *           l'octet de poids faible.
 * FONCTION : Lit le num�ro de version du driver SBFMDRV.
}

BEGIN
   Regs.BX := 0;
   Intr(CMFDriverIRQ,Regs);
   CMFGetVersion := Regs.AX;
   END;


PROCEDURE CMFSetStatusByte;
{
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Copie la valeur du Status du driver dans la variable 
 *            CMFStatusByte. .
}

BEGIN
   Regs.BX:= 1;
   Regs.DX:= Seg(CMFStatusByte);
   Regs.AX:= Ofs(CMFStatusByte);
   Intr(CMFDriverIRQ, Regs);
   END;

FUNCTION CMFSetInstruments(VAR CMFBuffer : Pointer):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer de donn�es CMF
 * SORTIE  : TRUE/FALSE, suivant que les instruments ont �t� positionn�s
 *           correctement ou non
 * FONCTION : Positionne les registres FM de la carte SB, sur les valeurs
              d'instruments se trouvant dans le fichier CMF charg�.
}

BEGIN
    CMFIntern := CMFBuffer;
    IF CMFIntern^.CMFInstrNumber > 128 THEN BEGIN
       CMFErrStat := 400;
       CMFSetInstruments := FALSE;
       Exit;
       END;
    Regs.BX := 02;
    Regs.CX := CMFIntern^.CMFInstrNumber;
    Regs.DX := Seg(CMFBuffer^);
    Regs.AX := Ofs(CMFBuffer^)+CMFIntern^.CMFInstrBlockOfs;
    Intr(CMFDriverIRQ, Regs);
    CMFSetInstruments := TRUE;
   END;

FUNCTION CMFSetSingleInstruments(VAR CMFInstrument:Pointer; No:WORD):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer des donn�es  CMFInstrument,
             nombre d'instruments sous forme WORD
 * SORTIE  : TRUE/FALSE, suivant que les instruments aient �t� positionn�s
 *           correctement ou non
 * FONCTION : Positionne les registres FM de la carte Sound Blaster sur les
              valeurs d'instruments, suivant la structure de donn�e rep�r�e
              par le pointeur CMFInstrument.
}

BEGIN
    IF No > 128 THEN BEGIN
       CMFErrStat := 400;
       CMFSetSingleInstruments := FALSE;
       Exit;
       END;
    Regs.BX := 02;
    Regs.CX := No;
    Regs.DX := Seg(CMFInstrument^);
    Regs.AX := Ofs(CMFInstrument^);
    Intr(CMFDriverIRQ, Regs);
    CMFSetSingleInstruments := TRUE;
END;

PROCEDURE CMFSetSysClock(Frequency : WORD);
{
 * ENTR�E  : System-Timer-Clock-Rate sous forme WORD
 * SORTIE  : aucune
 * FONCTION : Positionne la valeur standard du Timer 0 � une nouvelle
 *             valeur.
}

BEGIN
   Regs.BX := 03;
   Regs.AX := (1193180 DIV Frequency);
   Intr(CMFDriverIRQ, Regs);
END;

PROCEDURE CMFSetDriverClock(Frequency : WORD);
{
 * ENTR�E  : Timer-Clock-Rate sous forme WORD
 * SORTIE  : aucune
 * FONCTION : Positionne la fr�quence du Timer pour le driver � une 
 *            nouvelle valeur.
}

BEGIN
   Regs.BX := 04;
   Regs.AX := (1193180 DIV Frequency);
   Intr(CMFDriverIRQ, Regs);
END;

PROCEDURE CMFSetTransposeOfs (Offset : INTEGER);
{
 * ENTR�E  : Offset sous forme WORD. La valeur indique, de combien de 
 *           demi-tons doivent �tre transpos�es les notes

 * SORTIE  : aucune
 * FONCTION : Transpose toutes les notes d'une valeur �gale � "Offset",
 *            qui doivent �tre jou�es.
}

BEGIN
   Regs.BX := 05;
   Regs.AX := Offset;
   Intr(CMFDriverIRQ, Regs);
END;

FUNCTION CMFPlaySong(VAR CMFBuffer : Pointer) : BOOLEAN;
{
 * ENTR�E  : Pointeur sur les donn�es du morceau (Song)
 * SORTIE  : TRUE, lorsque cela a bien d�marr�, FALSE sinon
 * FONCTION : Initialise tous les param�tres importants, et d�marre la
 *            diffusion du morceau (Song).
}

VAR
   Check : BOOLEAN;
BEGIN
   CMFIntern := CMFBuffer;
{ Positionnement de la fr�quence d'horloge du driver }
   CMFSetDriverClock(CMFIntern^.CMFClockTicksPS);
{ Instrument }
   Check := CMFSetInstruments(CMFBuffer);
   IF Not(Check) THEN Exit;
   Regs.BX := 06;
   Regs.DX := Seg(CMFIntern^);
   Regs.AX := Ofs(CMFIntern^)+CMFIntern^.CMFMusicBlockOfs;
   Intr(CMFDriverIRQ, Regs);

   IF Regs.AX = 0 THEN BEGIN
      CMFPlaySong := TRUE;
      CMFSongPaused := FALSE;
      END
   ELSE BEGIN
      CMFPlaySong := FALSE;
      CMFErrStat := 500;
      END;
END;

FUNCTION CMFStopSong : BOOLEAN;
{
 * ENTR�E  : Aucune
 * SORTIE  : TRUE/FALSE, suivant que le morceau ait �t� bien stopp� ou non
 * FONCTION : Essaye de stopper un morceau (Song). 
}

BEGIN
   Regs.BX := 07;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN
      CMFStopSong := TRUE
   ELSE BEGIN
      CMFStopSong := FALSE;
      CMFErrStat  := 510;
   END;
END;

FUNCTION CMFResetDriver:BOOLEAN;
{
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Repositionne le driver dans l'�tat de d�part.
}

BEGIN
   Regs.BX := 08;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN
      CMFResetDriver := TRUE
   ELSE BEGIN
      CMFResetDriver := FALSE;
      CMFErrStat    := 110;
      END;
END;

FUNCTION CMFPauseSong : BOOLEAN;
{
 * ENTR�E  : Aucune
 * SORTIE  : TRUE/FALSE, suivant que le morceau ait �t� bien interrompu ou
             non
 * FONCTION : Essaye d'interrompre un morceau, si cela est possible, la
              variable globale CMFSongPaused sera positionn�e sur TRUE.
}

BEGIN
   Regs.BX := 09;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN BEGIN
      CMFPauseSong  := TRUE;
      CMFSongPaused := TRUE;
      END
   ELSE BEGIN
      CMFPauseSong := FALSE;
      CMFErrStat   := 520;
      END;
END;

FUNCTION CMFContinueSong : BOOLEAN;
{
 * ENTR�E  : Aucune
 * SORTIE  : TRUE/FALSE, suivant que la reprise du morceau a �t� correcte
             ou non.
 * FONCTION : Essaye de reprendre un morceau, quand cela est possible, la
              variable CMFSongPaused sera positionn�e sur FALSE.
}

BEGIN
   Regs.BX := 10;
   Intr(CMFDriverIRQ, Regs);
   IF Regs.AX = 0 THEN BEGIN
      CMFContinueSong  := TRUE;
      CMFSongPaused    := FALSE;
      END
   ELSE BEGIN
      CMFContinueSong := FALSE;
      CMFErrStat      := 530;
   END;
END;

{$F+}
PROCEDURE CMFToolsExitProc;
{$F-}
{
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Repositionnement de l'adresse du StatusByte, afin d'emp�cher
              d'�crire n'importe o� en m�moire � la fin du programme
              du driver.
}
BEGIN
   Regs.BX:= 1;
   Regs.DX:= 0;
   Regs.AX:= 0;
   Intr(CMFDriverIRQ, Regs);
   ExitProc := OldExitProc;
END;


BEGIN
{ D�place l'ancien ExitProc sur la nouvelle Tool-Unit }
   OldExitProc := ExitProc;
   ExitProc := @CMFToolsExitProc;
{ Initialisation des Variables }
   CMFErrStat := 0;
   CMFSongPaused := FALSE;
{ Initialisation du Driver }
   CMFDriverInstalled := CMFInitDriver;
   IF CMFDriverInstalled THEN BEGIN
      CMFStatusByte := 0;
      CMFSetStatusByte;
   END;
END.