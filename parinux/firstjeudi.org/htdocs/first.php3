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
 * $Id: first.php3,v 1.5 2003/02/26 16:14:00 rodolphe Exp $
 * $Source: /cvsroot/firstjeudi/firstjeudi/htdocs/first.php3,v $
 */

include_once('conf/conf.php3');
include ("mysql.lib.php3");
include ("lib.inc.php3");

setlocale(LC_ALL,"fr_FR");

$VILLE=$_SERVER["VILLE"];
$action=$_REQUEST["action"];

$nom=$_REQUEST["nom"];
$prenom=$_REQUEST["prenom"];
$email=$_REQUEST["email"];
$nb=$_REQUEST["nb"];


$db = new Db($dbhost,$dbuser,$dbpass);

$sql = "SELECT * FROM ville WHERE code = '".addslashes($VILLE)."' ";

if ( $db->query($sql) ) {
  $nump = $db->num_rows(); 
  if ($nump) {
    $objville = $db->fetch_object();
  } else {
    print "La ville '$VILLE' est inconnue dans la base de donnee";
    exit ;
  }
} else {
  print "Db failed";
  exit;
}

$title = "Rendez-vous Logiciel Libre - " . $objville->nom;

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

$current_time = time();
$weekday = strftime("%w", $current_time);
$cdate = strftime("%d %m %Y", $current_time);

$date = $dstart;

$i = 0;

$ndate = strftime("%A %d %B %Y", $date);
$delta = mktime (20,0,0, 
		 strftime("%m", $date),
		 strftime("%d",$date),
		 strftime("%Y", $date)) - $current_time;

$ndate = ucfirst(strftime("%A",$date))." ".(strftime("%d",$date)*1)." ".ucfirst(strftime("%B %Y",$date)); 

$nnum =  strftime("%Y%m%d", calcul_date($objville->numday, $objville->numweek,$debug));

if ($action=='add') {

  $nom=trim($nom);$prenom=trim($prenom);$email=trim($email);
  $id = md5(uniqid(rand()));

  if (strstr(strtolower($nom . $prenom . $email . $asso),"<script")) {

  } else {

    if (strlen($nom)+strlen($prenom)+strlen($email)) {
      $sql = "INSERT INTO user (id,nom,prenom,email,asso,nb,num,ip,ville) VALUES ('$id','$nom','$prenom','$email','$asso',$nb,'$nnum','$REMOTE_ADDR','$VILLE')";	  
      if ( $db->query($sql) ) {

	$subject = "$VILLE - Rencontre du " . strftime("%A %d %m %Y",calcul_date($objville->numday, $objville->numweek));

	$mess = "Bonjour,";
	$mess .= "\n";
	$mess .= "Vous venez de vous inscrire pour la réunion logiciel libre\n";
	$mess .= "\n";

	$mess .= "Ville       : $VILLE\n";
	$mess .= "Date        : ".strftime("%A %d %m %Y",calcul_date($objville->numday, $objville->numweek))."\n";

	$mess .= "Prénom      : $prenom\n";
	$mess .= "Nom         : $nom\n";
	$mess .= "Email       : $email\n";
	$mess .= "Nb          : $nb\n\n";
	$mess .= "IP          : $REMOTE_ADDR\n";
	$mess .= "\n\n";
	$mess .= "Pour supprimer cette inscription, cliquez sur: \n";
	$mess .= "http://$VILLE.firstjeudi.org/?action=del&id=$id";
	$mess .= "\n\n";
	$mess .= "\n\n\nVotre IP a été loggué dans un but de supervision des abus.";
	
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

$id=$_REQUEST["id"];
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
<?PHP print_date($objville->numday, $objville->numweek); ?>
</div>
<br>

<?PHP
if ($action=='added') {
  print "Nous avons bien enregistr&eacute;(e)<p>";
  print "Prénom : $prenom<br>";
  print "Nom         : $nom<br>";
  print "Email       : $email<br>";
  print "Nb          : $nb<br>";
  print "IP          : $REMOTE_ADDR<br>";
  print " Pour supprimer votre inscription <a href=\"http://$VILLE.firstjeudi.org?action=del&id=$id\">cliquer ici</a><br><br>";
}

?>


<table width="100%" bgcolor="#cFcFcF" border="0" cellspacing="0" cellpadding="3" class="text">
<tr><td valign="top">
<?PHP 
print $objville->message;
?>
</td>

</tr>
</table>


<br>

<?PHP
if ($action <> "add") {
?>
<u>Inscription</u> : <br>
<form action="first.php3" method="post">
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
  <td>Email :</td>
  <td><input type="text" size="40" maxlength="255" name="email"></td>
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
//print $nnum;
$sql = "SELECT nom,prenom,email,nb FROM user WHERE num = '$nnum' AND ville='$VILLE'";
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
      
      $obj = $db->fetch_object();
      print "  <td><small>[$obj->nb]&nbsp;$obj->prenom $obj->nom</small></td>\n";
      
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
<small>firstjeudi.org est maintenu par <a href="http://parinux.org">Parinux</a>.</small>
</td></tr>


</table>

</body>
</html>


