Program playcmfp;
{***************************************************************************
 * Programme de d�monstration pour l'Unit� CMFTOOL, (W) en Turbo-Pascal 6.0*
 ***************************************************************************
 *                    (C) 1992 MICRO APPLICATION                           *
 *                        Auteur : Axel Stolz                              *
 ***************************************************************************
 * La limite haute de la m�moire du programme principal doit �tre          *
 * diminu�e sinon tout l'espace m�moire disponible sera utilis�, ne        *
 * laissant plus suffisamment de place pour le driver et l'�chantillon     *
 * num�rique                                                               *
 ***************************************************************************
}


{$M 16384,0,65535}

Uses CMFTool,Crt;

VAR
   Check      : BOOLEAN;    { flag pour test bool�en }
   SongName   : String;     { nom du fichier CMF sous forme string }
   SongBuffer : CMFDataTyp; { buffer de donn�es pour le fichier CMF }

PROCEDURE Erreur;
{
 * ENTR�E  : aucune, les donn�es proviennent de la variable globale
 *           CMFErrStat
 * SORTIE  : aucune
 * FONCTION : Affiche le type d'erreur venant de se produire avec le
 *            num�ro d'erreur. Termine le programme avec le niveau
 *            d'erreur correspondant au num�ro.
}
BEGIN
   Write('Erreur #',CMFErrStat:3,' =');
   PrintCMFErrMessage;
   WriteLn;
   HALT(CMFErrStat);
   END;

BEGIN
   ClrScr;
{ sortir une erreur lorsque le driver SBFMDRV n'est pas install� }
   IF Not (CMFDriverInstalled) THEN Erreur;

   GotoXY(25,5);
   Write  (' SBFMDRV Version ',Hi(CMFGetVersion):2,'.');
   WriteLn(Lo(CMFGetVersion):2,' est charg�.');

{ transmet le num�ro de version utilis� }
   GotoXY(15,8);
   Write  ('Le driver utilise l''interruption syst�me (IRQ) n�. ');
   WriteLn(CMFDriverIRQ:3);
   writeln;writeln;
   write('Nom du fichier CMF � �couter : ');
   readln(SongName);


{ Chargement du fichier du morceau d�sir� }
   Check := CMFGetSongBuffer(SongBuffer,SongName);
   IF NOT(Check) THEN Erreur;

{Ici vous pouvez transposer le morceau charg� vers le haut ou le bas,
 suivant que la valeur transmise est positive ou n�gative. La valeur
 0 indique que le morceau doit �tre jou� avec la tonalit� d'origine.
}
   CMFSetTransposeOfs(0); { vous pouvez exp�rimenter avec des valeurs }

{ diffusion du morceau }
   Check := CMFPlaySong(SongBuffer);
   IF NOT(Check) THEN Erreur;

   GotoXY(37,16);
   WriteLn('Song-Status');
{ Pendant la diffusion du morceau, transmet en permanence le status-byte }
   REPEAT
      GotoXY(41,17);Write(CMFStatusByte:3);
      UNTIL (KeyPressed OR (CMFStatusByte = 0));

{ Si une touche a �t� appuy�e, alors interrompre le morceau }
   IF KeyPressed THEN BEGIN
      Check := CMFStopSong;
      ClrScr;
      IF NOT(Check) THEN Erreur;
      END;

{ Remettre le driver dans son �tat de mise en service }
   Check := CMFResetDriver;
   IF NOT(Check) THEN Erreur;

{ Lib�rer � nouveau la m�moire occup�e par le fichier du morceau }
   Check := CMFFreeSongBuffer(SongBuffer);
   IF NOT(Check) THEN Erreur;
END.


