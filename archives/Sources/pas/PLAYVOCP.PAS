PROGRAM PLAYVOCP;
{
 ****************************************************************************
 * Programme de d‚monstration pour l'Unit‚ VOCTOOL, (W) en Turbo-Pascal 6.0 *
 ****************************************************************************
 *                     (C) 1992 MICRO APPLICATION                            *
 *                         Auteur : Axel Stolz                              *
 ****************************************************************************
 * La limite haute de la m‚moire du programme principal doit ˆtre           *
 * diminu‚e sinon tout l'espace m‚moire disponible sera utilis‚ ne          *
 * laissant plus suffisamment de place pour le driver et l'‚chantillon      *
 * num‚rique                                                                *
 ****************************************************************************
}
{$M 16000,0,20000}

USES Crt,playvocu;

VAR
   Sound : Pointer; { Pointeur sur l'‚chantillon en m‚moire }
   Check : BOOLEAN; { Flag pour test bool‚en                }
   Ch    : CHAR;    { Buffer d'entr‚e                       }
   nomfichier:string;

PROCEDURE Erreur;
{
 * ENTREE  : aucune, les variables proviennent de la variable globale
 *           VOCErrStat
 * SORTIE  : aucune
 * FONCTION : Affiche le type d'erreur venant de se produire avec le
 *            num‚ro d'erreur. Termine le programme avec le niveau
 *            d'erreur correspondant au num‚ro.
}
BEGIN
   Write('Erreur #',VOCErrStat:3,' =');
   PrintVOCErrMessage;
   WriteLn;
   HALT(VOCErrStat);
   END;

BEGIN
  { Le driver n'a pas ‚t‚ install‚ }
  IF Not(VOCDriverInstalled) THEN Erreur;
  Write('CT-Voice-Driver Version : ');
  WriteLn(Hi(VOCDriverVersion),'.',Lo(VOCDriverVersion));
  writeln('Nom du fichier VOC … ‚couter : ');
  readln(nomfichier);
  { Charge le Fichier .VOC en m‚moire }
  Check := VOCGetBuffer(Sound,nomfichier);
  { Le fichier n'a pas pu ˆtre charg‚ }
  IF Not(Check) THEN Erreur;
  { Boucle principale du programme }
  WriteLn('Voulez vous ‚couter le son (u)ne ou (p)lusieurs fois ?');
  Ch := ReadKey;WriteLn;WriteLn;
  CASE UpCase(Ch) OF
   'U' : BEGIN
            Write('Frapper une touche pour interrompre le son ...');
            VOCOutput(Sound);
            REPEAT UNTIL KeyPressed OR (VOCStatusWord = 0);
            IF KeyPressed THEN VOCStop;
            END;
   'P' : BEGIN
            Ch := #0;
            Write('Appuyer sur <ESC> pour arrˆter...');
            REPEAT
               VOCOutputLoop(Sound);
               REPEAT UNTIL KeyPressed OR (VOCStatusWord = 0);
               IF KeyPressed THEN Ch := ReadKey;
               UNTIL Ch = #27;
            VOCStop;
            END;
   END;
  { Lib‚rer la m‚moire occup‚e par le fichier VOC }
  Check := VOCFreeBuffer(Sound);
  IF Not(Check) THEN Erreur;
END.


