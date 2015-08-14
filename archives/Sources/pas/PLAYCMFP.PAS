Program playcmfp;
{***************************************************************************
 * Programme de dÇmonstration pour l'UnitÇ CMFTOOL, (W) en Turbo-Pascal 6.0*
 ***************************************************************************
 *                    (C) 1992 MICRO APPLICATION                           *
 *                        Auteur : Axel Stolz                              *
 ***************************************************************************
 * La limite haute de la mÇmoire du programme principal doit àtre          *
 * diminuÇe sinon tout l'espace mÇmoire disponible sera utilisÇ, ne        *
 * laissant plus suffisamment de place pour le driver et l'Çchantillon     *
 * numÇrique                                                               *
 ***************************************************************************
}


{$M 16384,0,65535}

Uses CMFTool,Crt;

VAR
   Check      : BOOLEAN;    { flag pour test boolÇen }
   SongName   : String;     { nom du fichier CMF sous forme string }
   SongBuffer : CMFDataTyp; { buffer de donnÇes pour le fichier CMF }

PROCEDURE Erreur;
{
 * ENTRêE  : aucune, les donnÇes proviennent de la variable globale
 *           CMFErrStat
 * SORTIE  : aucune
 * FONCTION : Affiche le type d'erreur venant de se produire avec le
 *            numÇro d'erreur. Termine le programme avec le niveau
 *            d'erreur correspondant au numÇro.
}
BEGIN
   Write('Erreur #',CMFErrStat:3,' =');
   PrintCMFErrMessage;
   WriteLn;
   HALT(CMFErrStat);
   END;

BEGIN
   ClrScr;
{ sortir une erreur lorsque le driver SBFMDRV n'est pas installÇ }
   IF Not (CMFDriverInstalled) THEN Erreur;

   GotoXY(25,5);
   Write  (' SBFMDRV Version ',Hi(CMFGetVersion):2,'.');
   WriteLn(Lo(CMFGetVersion):2,' est chargÇ.');

{ transmet le numÇro de version utilisÇ }
   GotoXY(15,8);
   Write  ('Le driver utilise l''interruption systäme (IRQ) n¯. ');
   WriteLn(CMFDriverIRQ:3);
   writeln;writeln;
   write('Nom du fichier CMF Ö Çcouter : ');
   readln(SongName);


{ Chargement du fichier du morceau dÇsirÇ }
   Check := CMFGetSongBuffer(SongBuffer,SongName);
   IF NOT(Check) THEN Erreur;

{Ici vous pouvez transposer le morceau chargÇ vers le haut ou le bas,
 suivant que la valeur transmise est positive ou nÇgative. La valeur
 0 indique que le morceau doit àtre jouÇ avec la tonalitÇ d'origine.
}
   CMFSetTransposeOfs(0); { vous pouvez expÇrimenter avec des valeurs }

{ diffusion du morceau }
   Check := CMFPlaySong(SongBuffer);
   IF NOT(Check) THEN Erreur;

   GotoXY(37,16);
   WriteLn('Song-Status');
{ Pendant la diffusion du morceau, transmet en permanence le status-byte }
   REPEAT
      GotoXY(41,17);Write(CMFStatusByte:3);
      UNTIL (KeyPressed OR (CMFStatusByte = 0));

{ Si une touche a ÇtÇ appuyÇe, alors interrompre le morceau }
   IF KeyPressed THEN BEGIN
      Check := CMFStopSong;
      ClrScr;
      IF NOT(Check) THEN Erreur;
      END;

{ Remettre le driver dans son Çtat de mise en service }
   Check := CMFResetDriver;
   IF NOT(Check) THEN Erreur;

{ LibÇrer Ö nouveau la mÇmoire occupÇe par le fichier du morceau }
   Check := CMFFreeSongBuffer(SongBuffer);
   IF NOT(Check) THEN Erreur;
END.


