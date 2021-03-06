UNIT PLAYVOCU;
{********************************************************************
 *   Unit� pour piloter la Carte Sound Blaster avec Turbo-Pascal    *
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
   VOCToolVersion  = 'v1.5';  { Num�ro de version de l'unit� VOCTOOL   }
   VOCBreakEnd     = 0;       { Constante pour l'interruption de boucle }
   VOCBreakNow     = 1;       { Constante pour l'interruption de boucle }

VAR
   VOCStatusWord        : WORD;   { Variable pour Sound-Blaster-Status  }
   VOCErrStat           : WORD;   { Variable n� d'erreur driver }
   VOCFileHeader        : STRING; { Variable ent�te du format CT }
   VOCFileHeaderLength  : BYTE;     { Longueur de l'ent�te du format CT }
   VOCPaused            : BOOLEAN;  { Flag Voice-Pause       }
   VOCDriverInstalled   : BOOLEAN;  { Flag Driver install�       }
   VOCDriverVersion     : WORD;     { Num�ro de version du Driver     }
   VOCPtrToDriver       : Pointer;  { Pointeur sur le Driver en m�moire }
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
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : affiche � l'�cran, sous forme texte, l'erreur Sound Blaster
 *            venant de se produire, sans modifier la valeur du status.
}
BEGIN
   CASE VOCErrStat OF
      100 : Write(' Erreur: Driver CT-VOICE.DRV non trouv� ');
      110 : Write(' Erreur: Place m�moire insuffisante pour le driver ');
      120 : Write(' Erreur: Driver incorrect');
      200 : Write(' Erreur: Fichier VOC non trouv� ');
      210 : Write(' Erreur: Espace m�moire insuffisant pour le Fichier VOC ');
      220 : Write(' Erreur: Le Fichier n''est pas au format VOC');
      300 : Write(' Erreur: Erreur d''impl�mentation en m�moire ');
      400 : Write(' Erreur: Carte Sound Blaster non trouv�e ');
      410 : Write(' Erreur: Adresse de port incorrecte ');
      420 : Write(' Erreur: Utilisation d''une interruption erron�e ');
      500 : Write(' Erreur: Pas de boucle en cours ');
      510 : Write(' Erreur: Aucun �chantillon en cours de diffusion ');
      520 : Write(' Erreur: Pas d''�chantillon interrompu ');
      END;
   END;


FUNCTION Exists (Filename : STRING):BOOLEAN;
{ * ENTR�E  : Nom de fichier sous forme cha�ne de caract�re
  * SORTIE  : TRUE, au cas o� un fichier existe, FALSE sinon
  * FONCTION : v�rifie si un fichier existe et retourne une valeur
  *             bool�enne }
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
 * ENTR�E  : Entr�e pointeur sur le buffer,
 *            Taille du buffer sous forme d'entier long
 * SORTIE  : Pointeur sur le buffer
 * FONCTION : R�serve un buffer � l'adresse indiqu�e de la taille donn�e
 *            Si la m�moire pr�sente ne suffit pas, le pointeur pointera
 *            sur NIL

}
VAR
   SizeIntern : WORD;     { taille du buffer r�serv� au calcul interne }
BEGIN
   Inc(Size,15);                 { augmenter la taille du buffer de 15 }
   SizeIntern := (Size shr 4);   { et diviser ensuite par 16 }
   Regs.AH := $48;               { charger la fonction $48 de MSDOS dans AH }
   Regs.BX := SizeIntern;        { charger la taille interne dans BX }
   MsDos(Regs);                  { r�server la m�moire }
   IF (Regs.BX <> SizeIntern) THEN Pt := NIL
   ELSE Pt := Ptr(Regs.AX,0);
   END;


FUNCTION  CheckFreeMem (VAR VoiceBuff : Pointer; VoiceSize : LongInt):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer, taille d�sir�e en entier format long
 * SORTIE  : Pointeur sur le buffer, TRUE/FALSE, suivant AllocateMem
 * FONCTION : V�rifie, qu'il y a suffisamment de m�moire pour charger un fichier VOC.
}
BEGIN
AllocateMem(VoiceBuff,VoiceSize);
CheckFreeMem := VoiceBuff <> NIL;
END;


FUNCTION  VOCGetBuffer (VAR VoiceBuff : Pointer; Voicefile : STRING):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer, nom de fichier sous forme cha�ne de
             caract�re
 * SORTIE  : Pointeur sur le buffer avec des donn�es VOC, TRUE/FALSE
 * FONCTION : Charge un fichier en m�moire, et retourne la valeur TRUE
              si le fichier a �t� correctement charg�
}
VAR
   SampleSize : LongInt;
   FPresent   : BOOLEAN;
   VFile      : VOCFileTyp;
   Segs       : WORD;
   Read       : WORD;

BEGIN
   FPresent := Exists(VoiceFile);
{ Le fichier VOC n'a pas �t� trouv� }
   IF Not(FPresent) THEN BEGIN
      VOCGetBuffer := FALSE;
      VOCErrStat   := 200;
      EXIT
      END;
   Assign(VFile,Voicefile);
   Reset(VFile,1);
   SampleSize := Filesize(VFile);
   AllocateMem(VoiceBuff,SampleSize);
{ Espace m�moire insuffisant pour le fichier VOC }
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
{ Le chargement a �t� correctement effectu� }
   VOCGetBuffer := TRUE;
   VOCErrStat   := 0;
{ Lire la longueur de l'en-t�te dans le fichier }
   VOCFileHeaderLength := Ord(TypeCastType(VoiceBuff^)[20]);
   END;


FUNCTION VOCFreeBuffer (VAR VoiceBuff : Pointer):BOOLEAN;
{
 * ENTR�E  : Pointeur sur le buffer
 * SORTIE  : aucune
 * FONCTION : Lib�re la m�moire occup�e par les donn�es VOC
}
BEGIN
   Regs.AH := $49;              { Charger la fonction MSDOS $49 dans AH }
   Regs.ES := seg(VoiceBuff^);  { Charger le segment de la m�moire dans ES }
   MsDos(Regs);                 { Lib�rer la m�moire }
   VOCFreeBuffer := TRUE;
   IF (Regs.AX = 7) OR (Regs.AX = 9) THEN BEGIN
      VOCFreeBuffer := FALSE;
      VOCErrStat := 300         { Erreur DOS au cours de la lib�ration de
                                 m�moire}
      END; 
   END;


FUNCTION VOCGetVersion:WORD;
{
 * ENTR�E  : aucune
 * SORTIE  : Num�ro de version du driver
 * FONCTION : Transmet le num�ro de version du driver
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
 * ENTR�E  : Num�ro d'adresse du port
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
 * ENTR�E  : Num�ro d'interruption
 * SORTIE  : aucune
 * FONCTION : Fixe le num�ro d'interruption avant initialisation
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
 * ENTR�E  : aucune
 * SORTIE  : Num�ro d'erreur suivant le r�sultat de l'initialisation
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
{ Le driver CT-VOICE.DRV est cherch� dans le r�pertoire
  dans lequel a �t� trouv� le programme qui doit utiliser le driver  }
Pdir := ParamStr(0);
Fsplit(ParamStr(0),Pdir,Pnam,Pext);
Drivername := Pdir+'CT-VOICE.DRV';

VOCInitDriver := TRUE;

{ Driver non trouv� }
IF Not Exists(Drivername) THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 100;
      EXIT;
      END;

{ Chargement du driver }
   Assign(F,Drivername);
   Reset(F,1);
   AllocateMem(VOCPtrToDriver,Filesize(F));

{ Espace m�moire insuffisant pour le driver }
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

{ Transmettre le num�ro de version, et charger dans la variable globale }
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

{ Carte Sound Blaster non trouv�e  }
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

{ Utilisation d'un num�ro d'interruption incorrect }
IF Out = 3 THEN BEGIN
      VOCInitDriver := FALSE;
      VOCErrStat    := 420;
      EXIT;
      END;

   END;


PROCEDURE VOCDeInstallDriver;
{
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : D�sactivation du driver et lib�ration de la m�moire
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
 * ENTR�E  : TRUE pour l'activation du haut-parleur et FALSE pour la d�sactivation
 * SORTIE  : aucune
 * FONCTION : ON/OFF - Active ou d�sactive le haut-parleur
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
 * ENTR�E  : Pointeur sur les donn�es de l'�chantillon num�rique
 * SORTIE  : Aucune
 * FONCTION : Diffusion d'un �chantillon
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
 *    Diff�rence avec VOCOutput :
 *    Le haut-parleur ne sera pas activ� avant chaque diffusion d'un
 *    �chantillon, afin d'�viter les bruits en r�sultant.

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
{ * ENTR�E  : aucune
  * SORTIE  : aucune
  * FONCTION : Stoppe un �chantillon }
BEGIN
  ASM
  MOV       BX,8
  CALL      VOCPtrToDriver
  END;
END;


PROCEDURE VOCPause;
{
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Interrompt un �chantillon
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
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Reprend un �chantillon interrompu
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
 * ENTR�E  : Mode d'interruption
 * SORTIE  : aucune
 * FONCTION : Interrompt une boucle dans un �chantillon
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
 * ENTR�E  : aucune
 * SORTIE  : aucune
 * FONCTION : Dans la nouvelle ExitProc, le driver Voice sera a nouveau
              install� � la fin du programme
}
BEGIN
VOCDeInstallDriver;
ExitProc := OldExitProc;
END;





BEGIN
{
 * Les instructions suivantes seront automatiquement ex�cut�es d�s que
 * l'Unit� sera reli�e � un programme et que celui-ci sera ex�cut�
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
 * Contient apr�s l'installation soit TRUE ou FALSE suivant que le driver
 * a �t� install� correctement ou pas
}
VOCDriverInstalled := VOCInitDriver;
END.

