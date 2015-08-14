<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<?PHP
/* Copyright (C) 2002 Rodolphe Quiedeville <rodolphe@quiedeville.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 * $Id: special.php3,v 1.9 2003/02/02 12:29:21 rodolphe Exp $
 * $Source: /cvsroot/firstjeudi/firstjeudi/htdocs/special.php3,v $
 *
 */

include_once('conf/conf.php3');
include ("mysql.lib.php3");
include ("lib.inc.php3");

setlocale("LC_TIME","fr_FR");

$db = new Db($dbhost,$dbuser,$dbpass);

$VILLE = "sl03";

$message = "
Lors du salon de Paris un repas spécial est prévu au Falm's 62 rue des Lombards 75001, ce repas est ouvert à tout le monde. Si vous souhaitez venir discuter de logiciel libre inscrivez-vous grâce au formulaire ci-dessous. L'inscription est nécessaire pour que nous puissions organiser le repas avec le restaurant.
<p>
Le rendez-vous est fixé à 20h.
<p>
Pour vous rendre au restaurant empruntez le métro ou RER station Les Halles.
";
$title = "Soirée du 4 Février 2003";
$date = mktime (20,0,0, 2, 4, 2003);
$nnum =  strftime("%y%m%d", $date);
?>
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title><?PHP echo $title ?></title>
    <?PHP include ("header.html"); ?>
  </head>

  <body>

<?PHP
  $debug = 1;


$i = 0;





if ($action=='add') {

  $nom=trim($nom);$prenom=trim($prenom);$email=trim($email);$asso=trim($asso);
  $id = md5(uniqid(rand()));

  if (strstr(strtolower($nom . $prenom . $email . $asso),"<script")) {

  } else {

    if (strlen($nom)+strlen($prenom)+strlen($email)) {
      $sql = "INSERT INTO user (id,nom,prenom,email,asso,nb,num,ip,ville) VALUES ('$id','$nom','$prenom','$email','$asso',$nb,'$nnum','$REMOTE_ADDR','$VILLE')";	  
      if ( $db->query($sql) ) {

	$subject = "$VILLE - Rencontre du " . strftime("%A %d %m %Y",$date);

	$mess = "Bonjour,";
	$mess .= "\n";
	$mess .= "Vous venez de vous inscrire pour la réunion logiciel libre du " . strftime("%A %d %m %Y",$date)."\n";
	$mess .= "\n";

	$mess .= "Ville       : Paris, restaurant Flam's, 62 r Lombards 75001 PARIS\n";
	$mess .= "Date        : ".strftime("%A %d %m %Y", $date)."\n";

	$mess .= "Prénom      : $prenom\n";
	$mess .= "Nom         : $nom\n";
	$mess .= "Email       : $email\n";
	$mess .= "Asso/Groupe : $asso\n";
	$mess .= "Nb          : $nb\n";
	$mess .= "IP          : $REMOTE_ADDR\n";
	$mess .= "\n\n";
	$mess .= "Pour supprimer cette inscription, cliquez sur : \n";
	$mess .= "http://www.firstjeudi.org/special.php3?action=del&id=$id";
	$mess .= "\n\n";
	$mess .= "\n\n\nLes IP ne sont loguées que dans le but de blacklister\nles petits plaisantins qui s'amusent avec le formulaire.";
	
	$return = mail("$email","$subject","$mess",
		       "From: webmaster@firstjeudi.org\r\n"
		       ."Cc: webmaster@firstjeudi.org\r\n"
		       ."X-Mailer: PHP/" . phpversion());
	
	$action = "added";
      } else {
	print $db->error();
      }
    } else {
      $action ="";
      print "<p><b>Vous devez indiquer un nom, prénom et un email !!</b>";
    }
  }
}

if ($action=='del' && $id ) {
  $sql = "DELETE FROM user WHERE id = '$id'";
  $db->query($sql);
}
?>

<table border="0" cellpadding="3">
<tr><td valign="top" width="100">

<?PHP 
// Menu gauche

include("liste.php3");

?>

</td>
<td valign="top">
<div class="date">
<?PHP 
print ucfirst(strftime("%A",$date))." ".(strftime("%d",$date)*1)." ".ucfirst(strftime("%B %Y",$date)); 
?>
</div>
<br>

<?PHP
if ($action=='added') {
  print "Nous avons bien enregistr&eacute;(e)<p>";
  print "Prénom      : $prenom<br>";
  print "Nom         : $nom<br>";
  print "Email       : $email<br>";
  print "Asso/Groupe : $asso<br>";
  print "Nb          : $nb<br>";
  print "IP          : $REMOTE_ADDR<br>";
  print " Pour supprimer votre inscription <a href=\"http://www.firstjeudi.org/special.php3?action=del&id=$id\">cliquer ici</a><br><br>";
}

?>


<table width="100%" bgcolor="#cFcFcF" border="0" cellspacing="0" cellpadding="3" class="text">
<tr><td valign="top">
<?PHP 
print $message;
?>
</td>

</tr>
</table>


<br>

<?PHP
if ($action <> "add") {
?>
<u>Inscription</u> : <br>
<form action="special.php3" method="post">
<input type="hidden" name="action" value="add">
<table>
<tr>
  <td>Pr&eacute;nom :</td>
  <td><input type="text" size="30" maxlength="30" name="prenom"></td>
</tr>
<tr>
  <td>Nom :</td>
  <td><input type="text" size="30" maxlength="30" name="nom"></td>
</tr>
<tr>
  <td>email :</td>
  <td><input type="text" size="40" maxlength="255" name="email"></td>
</tr>
<tr>
  <td>Asso / Groupe :</td>
  <td><input type="text" size="30" maxlength="30" name="asso"></td>
</tr>
<tr>
  <td>Nombre :</td><td><select name="nb">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
<option value="4">4</option>
<option value="5">5</option>
</select>
</td></tr>
<tr><td colspan="2" align="center"><input type="submit" value="J'arrive"></td></tr>
</table>
</form>
Un mail de confirmation vous sera envoyé, celui-ci contient un id unique vous permettant de modifier votre inscription.

<?PHP
		  } else {
?>

<table>
<tr>
  <td>Pr&eacute;nom :</td><td><?PHP echo $prenom; ?></td>
</tr>
<tr>
  <td>Nom :</td><td><?PHP echo $nom; ?></td>
</tr>
<tr>
  <td>email :</td><td><?PHP echo $email; ?></td>
</tr>
<tr>
  <td>Asso / Groupe :</td><td><?PHP echo $asso; ?></td>
</tr>
<tr>
  <td>Nombre :</td><td><?PHP echo $nb; ?></td></tr>
</table>
<br>
Cette inscription a bien été enregistrée. Un mail contenant un id de modification vient de vous être envoyé sur votre email : <?PHP echo $email; ?>.

<?PHP
		  }
?>
<br>
<br>

</td><td width="25%" valign="top">
Inscrits : 
<hr>
<?PHP

$sql = "SELECT nom,prenom,email,asso,nb FROM user WHERE num = '$nnum' AND ville='$VILLE'";
$nbligne = 0;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    print '<table width="100%">';

    $i = 0;
    $j = 0;
    while ($i < $nump) {
      if ($j == 0 && $nbligne) {
	print "<tr>\n";
      } else {
        print "<tr>";
      }
      
      $obj = $db->fetch_object($i);
      print "  <td><small>[$obj->nb]&nbsp;$obj->prenom $obj->nom&nbsp;(<em>$obj->asso</em>)</small></td>\n";
      
      if ($j == $nbligne && $nbligne) {
	$j = -1;
	print "</tr>\n";
      }
      $i++;
 $j++;
      $numins = $numins + $obj->nb;
print "</tr>";
    }

    if ($j < ($nbligne+1) && $j > 0 && $nbligne) {
      print "</tr>\n";
    } 
    print "</table><br><b>Total inscrits : $numins</b>\n";
  }
}
$db->close();
?>

</td></tr>

<?PHP if (file_exists("pub.php3")){include("pub.php3");}; ?>


<tr><td>&nbsp;</td><td>
<small>firstjeudi.org est maintenu par <a href="http://rodolphe.quiedeville.org">Rodolphe Quiédeville</a> sur les serveurs de <a href="http://www.lolix.org/">Lolix</a> avec <a href="http://www.debian.org/">Debian GNU/Linux</a></small>
</td></tr>


</table>

</body>
</html>


