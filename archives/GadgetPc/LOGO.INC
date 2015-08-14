{Fichier logo.inc}

{A besoin de l'unit‚ dos,crt}
{BUILDLOGO: Dessine Logo}
{RESETLOGO: Restaure caractŠres}


const EGAVGA_SEQUENCER=$3C4;   { Port adresses/donn‚es du s‚quenceur }
      EGAVGA_MONCTR   =$3D4;            { Adresse contr“leur d'‚cran }
      EGAVGA_GRAPHCTR =$3CE;{Port adr./donn‚e du contr“leur graphique}
      EV_STATC        =$3DA;       { Registre d'‚tat couleur EGA/VGA }
      EV_STATM        =$3BA;          { Registre d'‚tat mono EGA/VGA }
      EV_ATTR         =$3C0;         { Contr“leur d'attribut EGA/VGA }


procedure CLI; far;
begin
inline($FA);          { Inhibe les interruptions }
end;

procedure STI; far;
begin
inline($FB);          { r‚tablit les interruptions}
end;


procedure SetCharWidth(largeur:byte); far;
{***********************************************************************
*  SetCharWidth:Fixe la largeur des caractŠres … 8 ou 9 pixels
*               pour les cartes VGA.
*  Entr‚e      :LARGEUR = Largeur des caractŠres (8 ou 9)
***********************************************************************}
var Regs:Registers;         { Registres pour g‚rer les interruptions }
    x   :byte;                                 { Variable de travail }
begin
  if ( largeur = 8 ) then Regs.BX := $0001      { BH = Alignem. horiz. }
                     else Regs.BX := $0800;{ BL=valeur pour reg du s‚q }

  x := port[ $3CC ] and not(4+8);    { R‚solution horizontale de 720 … }
  if ( largeur = 9 ) then                   { 640 pixels ou vice-versa }
    x := x or 4;
  port[ $3C2 ] := x;

  CLI;                         { Programme le s‚quenceur en con‚quence }
  portw[ EGAVGA_SEQUENCER ] := $0100;
  portw[ EGAVGA_SEQUENCER ] := $01 + Regs.BL shl 8;
  portw[ EGAVGA_SEQUENCER ] := $0300;
  STI;

  Regs.AX := $1000;                                   { Ajuste l'‚cran }
  Regs.BL := $13;
  intr( $10, Regs );
end;


PROCEDURE BUILDLOGO(colonne,ligne,profondeur,couleur:byte;var buf); far;
{***********************************************************************
* BuildLogo: Dessine un logo compos‚ de diff‚rents caractŠres
*            red‚finis qui ne sont pas utilis‚s en fran‡ais
* Entr‚e:  COLONNE    = Colonne o— d‚bute le logo (1-80)
*          LIGNE      = Ligne o— d‚bute le logo (1-25)
*          PROFONDEUR = Hauteur en pixel du logo
*                       Rem: la largeur est impos‚e dans d‚finition du logo
*          COULEUR    = Couleur d'affichage du logo
*          BUF        = Pointeur sur un tableau de pointeurs
*                       qui r‚f‚rencent le motif du logo
* Le logo est centr‚ dans son bloc de caractŠres
***********************************************************************}
type BYTEAR = array[0..10000] of byte;             { Tableau d'octets  }
     BARPTR = ^BYTEAR;                        { pour le buffer du logo }
const Nbrecar=32;
      UseChars:array[1..Nbrecar] of byte =  { 27 caractŠres red‚finissables }
                  (128, 132, 134, 141, 142, 143, 144, 145, 146, 149,
                   152, 153, 154, 155, 156, 157, 158, 159, 160, 161,
                   162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173);
var Regs      : Registers;    { Registres pour g‚rer les interruptions }
    chardef   : array[0..15] of byte;   { Motif binaire d'un caractŠre }
    charhauteur,             { Nombre de lignes de trame par caractŠre }
    i,j,k,l,                               { Compteurs d'it‚rations }
    masque,                           { Masque pour une ligne de trame }
    largeur,                                    { Largeur de la chaŒne }
    index,                 { Indice pour parcourir le tableau UseChars }
    dx,                  { Largeur du bloc du logo (colonnes de texte) }
    dy,                { Profondeur du bloc de logo (lignes de texte ) }
    gauche,                                  { limite gauche en pixels }
    droite,                                  { limite droite en pixels }
    haut,                                       { limite sup en pixels }
    bas :byte;                              { limite inf en pixels }
    bptr:barptr;               { pour adresser le buffer du logo }


{Fonction imbriqu‚e IsSet: D‚termine si un pixel du logo est dessin‚}
function IsSet(ligne,colonne:byte):boolean; far;
begin
if (ligne<haut) or (ligne>bas) or          { Pixel en dehors }
   (colonne<gauche) or (colonne>droite) then  { de la zone ? }
  IsSet := false                             { Oui, n'est pas dessin‚ }
else                           { Non, regarde dans le buffer du logo }
  IsSet := bptr^[ (ligne-haut)*(largeur+1) +1+(colonne-gauche) ] <> Nbrecar;
end;

{Proc‚dure principale}
begin
{Un caractŠre a 8 pixels en largeur}
SetCharWidth(8);
{Et 8 lignes de trame par caractŠre en 80x50}
{Rem: Mettre 16 en 80x25}
charhauteur:=8;
bptr := @buf;                         { Pointe sur le buffer du logo }
largeur := bptr^[0];       { Longueur de la chaŒne = largeur du logo }
dx := ( largeur + 7 ) div 8;                  { Nombre de caractŠres }
dy := ( profondeur + charhauteur - 1 ) div charhauteur;
if ( dx*dy>Nbrecar) then writeln( 'Erreur: logo trop grand.' )
else begin
  haut   := ( dy*charhauteur-profondeur ) div 2;{ Calcule les lim. }
  bas  := profondeur + haut - 1;
  gauche  := ( dx*8-largeur ) div 2;
  droite := largeur + gauche - 1;
  TextColor(couleur and $0F);       { Fixe la couleur d'affichage }
  TextBackGround(couleur shr 4);
  index := 1;              { Premier caractŠre de le table UseChar }
  for i := 0 to dy-1 do             { Parcourt les lignes de texte }
    begin
    GotoXY(colonne,ligne+i);
    for j := 1 to dx do         { Parcourt les colonnes de texte }
      begin
      write(chr(UseChars[index]) ); { Affiche les caract. }
      {Calcule le nouveau motif pour le caractŠre affich‚}
      for k:=0 to charhauteur-1 do  { Parcourt les de trames }
        begin
        masque:=0;             { Pour l'instant masque nul }
        for l:=0 to 7 do { Chaque caract. 8 pixels de large }
          begin
          masque:=masque shl 1;{D‚cale masque vers gauche}
          if IsSet(i*charhauteur+k,(j-1)*8+l) then
            masque:=masque or 1;      { Dessine le pixel }
          end;
        chardef[k]:=masque;      { Motif binaire dans le }
        end;                           { buffer des caracteres }
      Regs.AX := $1100;        { Fixe le ,ouveau motif binaire }
      Regs.BH := charhauteur;       { … l'aide de l'option $00 }
      Regs.BL := 0;     { de la fonction $10 de l'interruption }
      Regs.CX := 1;                            { vid‚o du BIOS }
      Regs.DX := UseChars[ index ];
      Regs.ES := seg( chardef );
      Regs.BP := ofs( chardef );
      intr( $10, Regs );
      inc( index );           { CaractŠre suivant dans UseChar }
      end;
    end;
  end;
end;


PROCEDURE RESETLOGO; far;
{***********************************************************************
* ResetLogo: Recharge le jeu de caractŠres d'origine
* Entr‚e: n‚ant
***********************************************************************}
var Regs      : Registers;       { registres pour g‚rer l'interruption }
begin
SetCharWidth( 9 );{ Repr‚sente les caractŠres sur 9 pixel }
Regs.AX := $1104;                  { recharge le jeu 8*16 }
Regs.BL := 0;
intr( $10, Regs );
end;



{D‚fini le logo (Celui-ci sera centr‚}
const nbre_pixel_x=61;
const nbre_pixel_y=32;
const logo:array[1..nbre_pixel_y] of string[nbre_pixel_x]=
('                                                               ',
 '                                                               ',
 '                        ***************                        ',
 '                  ***************************                  ',
 '               *********               *********               ',
 '            ******                           ******            ',
 '          *****       *********                 *****          ',
 '        ****        ***    ****                    ****        ',
 '       ***        ***       **                       ***       ',
 '      ***        **         **                        ***      ',
 '     ***        ***         **                         ***     ',
 '    ***        ***                *  *****      *****   ***    ',
 '   ***         ***                *********   *** ***    ***   ',
 '   **         ***                  ***  ***  **   **      **   ',
 '  **          ***             **   ***  *** ***            **  ',
 '  **          ***         *****   **** ***  ***            **  ',
 '  **         ***    ********      ***  *** ***             **  ',
 '  **         ***  ***    ***      ***  **  ***             **  ',
 '  **         ***         ***     **** **   **** ***        **  ',
 '   **        ****        ***     ******    ******  *      **   ',
 '   ***       ****        **      ***               *     ***   ',
 '    ***      ****       **      ***              **     ***    ',
 '     ***  **  *****   ***  **** *** *** *** *****      ***     ',
 '      ***       ********        ***                   ***      ',
 '       ***                     ****                  ***       ',
 '        ****                   ***                 ****        ',
 '          *****              ***                *****          ',
 '            ******                           ******            ',
 '               *********               *********               ',
 '                  ***************************                  ',
 '                        ***************                        ',
 '                                                               ');

