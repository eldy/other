UNIT PLAYVOCU;
{********************************************************************
 *   UnitÇ pour piloter la Carte Sound Blaster avec Turbo-Pascal    *
 *              en utilisant le Driver CT-VOICE.DRV.                *
 ********************************************************************
 *                 (C) 1992 MICRO APPLICATION                       *
 *                    Auteur : Axel Stolz                           *
 ********************************************************************
}
INTERFACE

TYPE
   VOCFileTyp = File;

CONST
   VOCToolVersion  = 'v1.5';  { NumÇro de version de l'unitÇ VOCTOOL   }
   VOCBreakEnd     = 0;       { Constante pour l'interruption de boucle }
   VOCBreakNow     = 1;       { Constante pour l'interruption de boucle }

VAR
   VOCStatusWord        : WORD;   { Variable pour Sound-Blaster-Status  }
   VOCErrStat           : WORD;   { Variable nß d'erreur driver }
   VOCFileHeader        : STRING; { Variable entàte du format CT }
   VOCFileHeaderLength  : BYTE;     { Longueur de l'entàte du format CT }
   VOCPaused            : BOOLEAN;  { Flag Voice-Pause       }
   VOCDriverInstalled   : BOOLEAN;  { Flag Driver installÇ       }
   VOCDriverVersion     : WORD;     { NumÇro de version du Driver     }
   VOCPtrToDriver       : Pointer;  { Pointeur sur le Driver en mÇmoire }
   OldExitProc          : Pointer;  { Pointeur sur l'ancienne Unit-ExitProc }


PROCEDURE PrintVOCErrMessage;
FUNCTION  VOCGetBuffer(VAR VoiceBuff : Pointer; Voicefile : STRING):BOOLEAN;
FUNCTION  VOCFreeBuffer(VAR VoiceBuff : Pointer):BOOLEAN;
FUNCTION  VOCGetVersion:WORD;
PROCEDURE VOCSetPort(PortNumber : WORD);
PROCEDURE VOCSetIRQ(IRQNumber : WORD);
FUNCTION  VOCInitDriver:BOOLEAN;
PROCEDURE VOCDeInstallDriver;
PROCEDURE VOCSetSpeaker(OnOff:BOOLEAN);
PROCEDURE VOCOutput(BufferAddress : Pointer);
PROCEDURE VOCOutputLoop (BufferAddress : Pointer);
PROCEDURE VOCStop;
PROCEDURE VOCPause;
PROCEDURE VOCContinue;
PROCEDURE VOCBreakLoop(BreakMode : WORD);

IMPLEMENTATION

USES DOS,Crt;

TYPE TypeCastType = ARRAY [0..6000] of Char;

VAR Regs : Registers;


PROCEDURE PrintVOCErrMessage;
{
 * ENTRêE  : aucune
 * SORTIE  : aucune
 * FONCTION : affiche Ö l'Çcran, sous forme texte, l'erreur Sound Blaster
 *            venant de se produire, sans modifier la valeur du status.
}
BEGIN
   CASE VOCErrStat OF
      100 : Write(' Erreur: Driver CT-VOICE.DRV non trouvÇ ');
      110 : Write(' Erreur: Place mÇmoire insuffisante pour le driver ');
      120 : Write(' Erreur: Driver incorrect');
      200 : Write(' Erreur: Fichier VOC non trouvÇ ');
      210 : Write(' Erreur: Espace mÇmoire insuffisant pour le Fichier VOC ');
      220 : Write(' Erreur: Le Fichier n''est pas au format VOC');
      300 : Write(' Erreur: Erreur d''implÇmentation en mÇmoire ');
      400 : Write(' Erreur: Carte Sound Blaster non trouvÇe ');
      410 : Write(' Erreur: Adresse de port incorrecte ');
      420 : Write(' Erreur: Utilisation d''une interruption erronÇe ');
      500 : Write(' Erreur: Pas de boucle en cours ');
      510 : Write(' Erreur: Aucun Çchantillon en cours de diffusion ');
      520 : Write(' Erreur: Pas d''Çchantillon interrompu ');
      END;
   END;


FUNCTION Exists (Filename : STRING):BOOLEAN;
{ * ENTRêE  : Nom de fichier sous forme chaåne de caractäre
  * SORTIE  : TRUE, au cas oó un fichier existe, FALSE sinon
  * FONCTION : vÇrifie si un fichier existe et retourne une valeur
  *             boolÇenne }
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
 * ENTRêE  : EntrÇe pointeur sur le buffer,
 *            Taille du buffer sous forme d'entier long
 * SORTIE  : Pointeur sur le buffer
 * FONCTION : RÇserve un buffer Ö l'adresse indiquÇe de la taille donnÇe
 *            Si la mÇmoire prÇsente ne suffit pas, le pointeur pointera
 *            sur NIL

}
VAR
   SizeIntern : WORD;     { taille du buffer rÇservÇ au calcul interne }
BEGIN
   Inc(Size,15);                 { augmenter la taille du buffer de 15 }
   SizeIntern := (Size shr 4);   { et diviser ensuite par 16 }
   Regs.AH := $48;               { charger la fonction $48 de MSDOS dans AH }
   Regs.BX := SizeIntern;        { charger la taille interne dans BX }
   MsDos(Regs);                  { rÇserver la mÇmoire }
   IF (Regs.BX <> SizeIntern) THEN Pt := NIL
   ELSE Pt := Ptr(Regs.AX,0);
   END;


FUNCTION  CheckFreeMem (VAR VoiceBuff : Pointer; VoiceSize : LongInt):BOOLEAN;
{
 * ENTRêE  : Pointeur sur le buffer, taille dÇsirÇe en entier format long
 * SORTIE  : Pointeur sur le buffer, TRUE/FALSE, suivant AllocateMem
 * FONCTION : VÇrifie, qu'il y a suffisamment de mÇmoire pour charger un fichier VOC.
}
BEGIN
AllocateMem(VoiceBuff,VoiceSize);
CheckFreeMem := VoiceBuff <> NIL;
END;


FUNCTION  VOCGetBuffer (VAR VoiceBuff : Pointer; Voicefile : STRING):BOOLEAN;
{
 * ENTRêE  : Pointeur sur le buffer, nom de fichier sous forme chaåne de
             caractäre
 * SORTIE  : Pointeur sur le buffer avec des donnÇes VOC, TRUE/FALSE
 * FONCTION : Charge un fichier en mÇmoire, et retourne la valeur TRUE
              si le fichier a ÇtÇ correctement chargÇ
}
VAR
   SampleSize : LongInt;
   FPresent   : BOOLEAN;
   VFile      : VOCFileTyp;
   Segs       : WORD;
   Read       : WORD;

BEGIN
   FPresent := Exists(VoiceFile);
{ Le fichier VOC n'a pas ÇtÇ trouvÇ }
   IF Not(FPresent) THEN BEGIN
      VOCGetBuffer := FALSE;
      VOCErrStat   := 200;
      EXIT
      END;
   Assign(VFile,Voicefile);
   Reset(VFile,1);
   SampleSize := Filesize(VFile);
   AllocateMem(VoiceBuff,SampleSize);
{ Espace mÇmoire insuffisant pour le fichier VOC }
   IF (VoiceBuff = NIL) THEN BEGIN
      Close(VFile);
      VOCGetBuffer := FALSE;
      VOCErrStat   := 210;
      EXIT;
      END;
   Segs := 0;
   REPEAT
      Blockread(VFile,Ptr(seg(VoiceBuff^)+4096*Segs,Ofs(VoiceBuff^))^,$FFFF,Read);
      Inc(Segs);
      UNTIL Read = 0;
   Close(VFile);
{ Le fichier n'est pas au format VOC }
   IF (TypeCastType(VoiceBuff^)[0]<>'C') OR
      (TypeCastType(VoiceBuff^)[1]<>'r') THEN BEGIN
      VOCGetBuffer := FALSE;
      VOCErrStat := 220;
      EXIT;
      END;
{ Le chargement a ÇtÇ correctement effectuÇ }
   VOCGetBuffer := TRUE;
   VOCErrStat   := 0;
{ Lire la longueur de l'en-tàte dans le fichier }
   VOCFileHeaderLength := Ord(TypeCastType(VoiceBuff^)[20]);
   END;


FUNCTION VOCFreeBuffer (VAR VoiceBuff : Pointer):BOOLEAN;
{
 * ENTRêE  : Pointeur sur le buffer
 * SORTIE  : aucune
 * FONCTION : Libäre la mÇmoire occupÇe par les donnÇes VOC
}
BEGIN
   Regs.AH := $49;              { Charger la fonction MSDOS $49 dans AH }
   Regs.ES := seg(VoiceBuff^);  { Charger le segment de la mÇmoire dans ES }
   MsDos(Regs);                 { LibÇrer la mÇmoire }
   VOCFreeBuffer := TRUE;
   IF (Regs.AX = 7) OR (Regs.AX = 9) THEN BEGIN
      VOCFreeBuffer := FALSE;
      VOCErrStat := 300         { Erreur DOS au cours de la libÇration de
                                 mÇmoire}
      END; 
   END;


FUNCTION VOCGetVersion:WORD;
{
 * ENTRêE  : aucune
 * SORTIE  : NumÇro de version du driver
 * FONCTION : Transmet le numÇro de version du driver
}
VAR
   VDummy : WORD;
BEGIN
   ASM
      MOV       BX,0
      CALL      VOCPtrToDriver
      MOV       VDummy, AX
      END;
   VOCGetVersion := VDummy;
   END;


PROCEDURE VOCSetPort(PortNumber : WORD);
{
 * ENTRêE  : NumÇro d'adresse du port
 * SORTIE  : aucune
 * FONCTION : Fixe l'adresse du port avant initialisation
}
BEGIN
   ASM
      MOV    BX,1
      MOV    AX,PortNumber
      CALL   VOCPtrToDriver
      END;
   END;


PROCEDURE VOCSetIRQ(IRQNumber : WORD);
{
 * ENTRêE  : NumÇro d'interruption
 * SORTIE  : aucune
 * FONCTION : Fixe le numÇro d'interruption avant initialisation
}
BEGIN
   ASM
      MOV    BX,2
      MOV    AX,IRQNumber
      CALL   VOCPtrToDriver
      END;
   END;


FUNCTION  VOCInitDriver: BOOLEAN;
{
 * ENTRêE  : aucune
 * SORTIE  : NumÇro d'erreur suivant le rÇsultat de l'initialisation
 * FONCTION : Initialisation du driver
}
VAR
   Out, VSeg, VOfs : WORD;
   F   : File;
   Drivername,
   Pdir        : DirStr;
   Pnam        : NameStr;
   Pext        : ExtStr;
BEGIN
{ Le driver CT-VOICE.DRV est cherchÇ dans le rÇpertoire
  dans lequel a ÇtÇ trouvÇ le programme qui doit utiliser le driver  }
Pdir := ParamStr(0);
Fsplit(ParamStr(0),Pdir,Pnam,Pext);
Drivername := Pdir+'CT-VOICE.DRV';

VOCInitDriver := TRUE;

{ Driver non trouvÇ }
IF Not Exists(Drivername) THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 100;
      EXIT;
      END;

{ Chargement du driver }
   Assign(F,Drivername);
   Reset(F,1);
   AllocateMem(VOCPtrToDriver,Filesize(F));

{ Espace mÇmoire insuffisant pour le driver }
IF VOCPtrToDriver = NIL THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 110;
      EXIT;
      END;

   Blockread(F,VOCPtrToDriver^,Filesize(F));
   Close(F);

{ Driver incorrect, ne commence pas par "CT" }
IF (TypeCastType(VOCPtrToDriver^)[3]<>'C') OR
      (TypeCastType(VOCPtrToDriver^)[4]<>'T') THEN BEGIN
         VOCInitDriver := FALSE;
         VOCErrStat    := 120;
         EXIT;
         END;

{ Transmettre le numÇro de version, et charger dans la variable globale }
VOCDriverVersion := VOCGetVersion;

{ Lancer le Driver }
Vseg := Seg(VOCStatusWord);
VOfs := Ofs(VOCStatusWord);
   ASM
      MOV       BX,3
      CALL      VOCPtrToDriver
      MOV       Out,AX
      MOV       BX,5
      MOV       ES,VSeg
      MOV       DI,VOfs
      CALL      VOCPtrToDriver
      END;

{ Carte Sound Blaster non trouvÇe  }
IF Out = 1 THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 400;
      EXIT;
      END;

{ Utilisation d'une adresse de port incorrecte }
IF Out = 2 THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 410;
      EXIT;
      END;

{ Utilisation d'un numÇro d'interruption incorrect }
IF Out = 3 THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 420;
      EXIT;
      END;

   END;


PROCEDURE VOCDeInstallDriver;
{
 * ENTRêE  : aucune
 * SORTIE  : aucune
 * FONCTION : DÇsactivation du driver et libÇration de la mÇmoire
}
VAR
   Check : BOOLEAN;
BEGIN
   IF VOCDriverInstalled THEN
   ASM
      MOV       BX,9
      CALL      VOCPtrToDriver
      END;
   Check := VOCFreeBuffer(VOCPtrToDriver);
   END;


PROCEDURE VOCSetSpeaker(OnOff:BOOLEAN);
{
 * ENTRêE  : TRUE pour l'activation du haut-parleur et FALSE pour la dÇsactivation
 * SORTIE  : aucune
 * FONCTION : ON/OFF - Active ou dÇsactive le haut-parleur
}
VAR
   Switch : BYTE;
BEGIN
   Switch := Ord(OnOff) AND $01;
   ASM
      MOV       BX,4
      MOV       AL,Switch
      CALL      VOCPtrToDriver
      END;
   END;

PROCEDURE VOCOutput (BufferAddress : Pointer);
{
 * ENTRêE  : Pointeur sur les donnÇes de l'Çchantillon numÇrique
 * SORTIE  : Aucune
 * FONCTION : Diffusion d'un Çchantillon
}
VAR
   VSeg, VOfs : WORD;
BEGIN
   VOCSetSpeaker(TRUE);
   VSeg := Seg(BufferAddress^);
   VOfs := Ofs(BufferAddress^)+VOCFileHeaderLength;
   ASM
      MOV       BX,6
      MOV       ES,VSeg
      MOV       DI,VOfs
      CALL      VOCPtrToDriver
      END;
   END;

PROCEDURE VOCOutputLoop (BufferAddress : Pointer);
{
 *    DiffÇrence avec VOCOutput :
 *    Le haut-parleur ne sera pas activÇ avant chaque diffusion d'un
 *    Çchantillon, afin d'Çviter les bruits en rÇsultant.

}
VAR
   VSeg, VOfs : WORD;
BEGIN
   VSeg := Seg(BufferAddress^);
   VOfs := Ofs(BufferAddress^)+VOCFileHeaderLength;
   ASM
      MOV       BX,6
      MOV       ES,VSeg
      MOV       DI,VOfs
      CALL      VOCPtrToDriver
      END;
   END;

PROCEDURE VOCStop;
{ * ENTRêE  : aucune
  * SORTIE  : aucune
  * FONCTION : Stoppe un Çchantillon }
BEGIN
  ASM
  MOV       BX,8
  CALL      VOCPtrToDriver
  END;
END;


PROCEDURE VOCPause;
{
 * ENTRêE  : aucune
 * SORTIE  : aucune
 * FONCTION : Interrompt un Çchantillon
}
VAR
   Switch : WORD;
BEGIN
   VOCPaused := TRUE;
   ASM
      MOV       BX,10
      CALL      VOCPtrToDriver
      MOV       Switch,AX
      END;
   IF (Switch = 1) THEN BEGIN
      VOCPaused := FALSE;
      VOCErrStat := 510;
      END;
   END;


PROCEDURE VOCContinue;
{
 * ENTRêE  : aucune
 * SORTIE  : aucune
 * FONCTION : Reprend un Çchantillon interrompu
}
VAR
   Switch : WORD;
BEGIN
   ASM
      MOV       BX,11
      CALL      VOCPtrToDriver
      MOV       Switch,AX
      END;
   IF (Switch = 1) THEN BEGIN
      VOCPaused := FALSE;
      VOCErrStat := 520;
      END;
   END;

PROCEDURE VOCBreakLoop(BreakMode : WORD);
{
 * ENTRêE  : Mode d'interruption
 * SORTIE  : aucune
 * FONCTION : Interrompt une boucle dans un Çchantillon
}
BEGIN
   ASM
      MOV       BX,12
      MOV       AX,BreakMode
      CALL      VOCPtrToDriver
      MOV       BreakMode,AX
      END;
   IF (BreakMode = 1) THEN VOCErrStat := 500;
   END;



{$F+}
PROCEDURE VoiceToolsExitProc;
{$F-}
{
 * ENTRêE  : aucune
 * SORTIE  : aucune
 * FONCTION : Dans la nouvelle ExitProc, le driver Voice sera a nouveau
              installÇ Ö la fin du programme
}
BEGIN
VOCDeInstallDriver;
ExitProc := OldExitProc;
END;





BEGIN
{
 * Les instructions suivantes seront automatiquement exÇcutÇes däs que
 * l'UnitÇ sera reliÇe Ö un programme et que celui-ci sera exÇcutÇ
}
{ Transpose l'ancienne ExitProc sur la nouvelle Tool-Unit }
OldExitProc := ExitProc;
ExitProc := @VoiceToolsExitProc;
{ Initialisation des valeurs de base }
VOCStatusWord := 0;
VOCErrStat    := 0;
VOCPaused     := FALSE;
VOCFileHeaderLength := $1A;
VOCFileHeader :=
      'Creative Voice File'+#$1A+#$1A+#$00+#$0A+#$01+#$29+#$11+#$01;
{
 * Contient apräs l'installation soit TRUE ou FALSE suivant que le driver
 * a ÇtÇ installÇ correctement ou pas
}
VOCDriverInstalled := VOCInitDriver;
END.

