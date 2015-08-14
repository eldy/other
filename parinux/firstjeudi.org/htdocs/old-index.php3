<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>FirstJeudi</title>
  </head>

  <body bgcolor="#e7E7E7">

<?PHP
include ("conf/conf.php3");

setlocale("LC_TIME","fr_FR");
$current_time = time();

$weekday = strftime("%w", $current_time);
$cdate = strftime("%d %m %Y", $current_time);

include ("mysql.lib.php3");

$db = new Db($dbhost,$dbuser,$dbpass);

$sql = "SELECT distinct(id) FROM photo WHERE active=1";
if ( $db->query($sql) ) {    
  $nump = $db->num_rows();
  if ($nump) {
    $i = 0;
    while ($i < $nump) {
      $obj = $db->fetch_object($i);
      $photos[$obj->id] = 1;
      $i++;
    }
  }
}

?>

<table border="0" cellpadding="3">
<tr><td valign="top">
<small>Archives&nbsp;:</small><br>
<?PHP
    
$dstart = mktime (2,0,0, "5","4","2000",-1);
$date = $dstart;
$i = 0;

while ($date < $current_time  ) {
  $i++;
  
  //  if ($i < 10) {print "&nbsp;$i-&nbsp;";}else{print "$i-&nbsp;";}
  //  print "<small>$i</small>&nbsp;";

  $a = strftime("%Y%m", $date);
  if ($photos[$a]) {
    print "<a href=\"?action=photo&id=$a\">";
    print strftime("%Y&nbsp;%b", $date) . "&nbsp;" . (strftime("%d", $date) * 1);
    print "</a>";
  } else {
    print strftime("%Y&nbsp;%b", $date) . "&nbsp;" . (strftime("%d", $date) * 1);
  }
  
  echo '<br>';

  $date = $date + (3600 * 24 * 20);
  
  while (strftime ("%d", $date) > 7 or strftime ("%w", $date) <> 4 ) {
    $date = $date + (3600 );
  }
}

//$date=mktime(0,0,0,4,4,2002);

//while (strftime ("%d", $date) > 7 or strftime ("%w", $date) <> 4 ) {
//  $date = $date + (3600 * 24);
//}

$ndate = strftime("%A %d %B %Y", $date);
$delta = mktime (20,0,0, strftime("%m", $date), strftime("%d", $date), strftime("%Y", $date)) - $current_time;
$ndate = ucfirst(strftime("%A", $date)) . " " . (strftime("%d", $date) * 1) . " " . ucfirst(strftime("%B %Y", $date)); 
$nnum =  strftime("%Y%m", $date);

if ($action=='add') {

  $nom=trim($nom);$prenom=trim($prenom);$email=trim($email);$asso=trim($asso);
  $id = md5(uniqid(rand()));

  if (strstr(strtolower($nom . $prenom . $email . $asso),"<script")) {

  } else {

    if (strlen($nom)+strlen($prenom)+strlen($email)) {
      $sql = "INSERT INTO user (id,nom,prenom,email,asso,nb,num,ip) VALUES ('$id','$nom','$prenom','$email','$asso',$nb,'$nnum','$REMOTE_ADDR')";	  
      if ( $db->query($sql) ) {
	$subject = "First Jeudi du $ndate";
	$mess = "Bonjour,\n\n";
	$mess .= "*Attention !! Changement d'adresse !*";
	$mess .= "\n\n";
	$mess .= "Vous venez de vous inscrire pour le First Jeudi du $ndate.\n";
	$mess .= "\n\n";
	$mess .= "Prénom      : $prenom\n";
	$mess .= "Nom         : $nom\n";
	$mess .= "Email       : $email\n";
	$mess .= "Asso/Groupe : $asso\n";
	$mess .= "Nb          : $nb\n";
	$mess .= "IP          : $REMOTE_ADDR\n";
	$mess .= "\n\n";
	$mess .= "Pour supprimer cette incsription, cliquez sur : \n";
	$mess .= "http://www.firstjeudi.org/?action=del&id=$id";
	$mess .= "\n\n";
	$mess .= "Attention !! Changement d'adresse !";
	$mess .= "\n\n";
	$mess .= "La réunion se tient à Paris a La Taverne des Halles, 12 rue de La Cossonerie (75001), métro Chatelets les Halles. La Taverne des Halles est a 50m du Hall's Beer (ancien lieu).";
	$mess .= "\n\nA Jeudi !\n";

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
<p>
<small>Voir&nbsp;aussi&nbsp;:</small><br>
<a href="http://www.lastjeudi.org/">LastJeudi</a>

</td><td valign="top">

<center>Prochain First Jeudi :<b> <?PHP echo $ndate; ?></b><br><small>dans exactement 
<?PHP 

//  $delta = 1 + ( 1 * 60 ) + ( 1 * 3600 ) + ( 1 * 3600 * 24 );

$djour = ($delta - ( $delta % 86400 )) /86400 ;
$delta = $delta - ($djour * 86400);
$dhour = ($delta  - ( $delta % 3600 )) /3600 ;
$delta = $delta - ($dhour * 3600);
$dmin = ($delta - ( $delta % 60 )) /60 ;
$dsec = $delta % 60 ;

if ($djour) { if ($djour>1) { echo "$djour jours&nbsp;"; } else { echo "$djour jour&nbsp;"; } }
if ($dhour) { if ($dhour>1) { echo "$dhour heures&nbsp;"; } else { echo "$dhour heure&nbsp;"; } }
if ($dmin) { if ($dmin>1) { echo "$dmin minutes&nbsp;"; } else { echo "$dmin minute&nbsp;"; } }
if ($dsec) { echo "$dsec&nbsp;" ; if ($dsec > 1 ) { echo "secondes&nbsp;"; } else {echo "seconde&nbsp;"; }}

?></small></center>
<br>

<?PHP
if ($action=='added') {
  print "Nous avon bien enregistr&eacute;(e)<p>";
  print "Prénom : $prenom<br>";
  print "Nom         : $nom<br>";
  print "Email       : $email<br>";
  print "Asso/Groupe : $asso<br>";
  print "Nb          : $nb<br>";
  print "IP          : $REMOTE_ADDR<br><br><br>";
}

if ($action == "photo") {

  if ($id) {

    $sql = "SELECT url FROM photo WHERE id = '$id' AND active=1";
    $nbligne = 0;
    $numins = 0;
    if ( $db->query($sql) ) {
      $nump = $db->num_rows();
      if ($nump) {
	print "Les prog&egrave;s de la technique nous permettent aujourd'hui de nous souvenir de ces grands moments au travers de quelques photos :<ul>";
	
	$i = 0;
	while ($i < $nump) {
	  $obj = $db->fetch_object($i);
	  print "<li><a href=\"" . $obj->url . "\">$obj->url</a>";
	  $i++;
	}
	print "</ul>";
      }
    }
    $db->free();
  } else {
    $sql = "SELECT id, url FROM photo WHERE active=1 ORDER BY id DESC";
    $nbligne = 0;
    $numins = 0;
    if ( $db->query($sql) ) {
      $nump = $db->num_rows();
      if ($nump) {
	print "Les prog&egrave;s de la technique nous permettent aujourd'hui de nous souvenir de ces grands moments au travers de quelques photos :<ul>";
	
	$i = 0;
	$old = 0;
	while ($i < $nump) {
	  $obj = $db->fetch_object($i);
	  if ($old <> $obj->id) {
	    if ($i > 0) {
	      print "</ul>";
	    }
	    $old = $obj->id;
	    print "<li>" . ucfirst(strftime("%B %Y", mktime(0,0,0,substr("$obj->id",4,2) ,1, substr("$obj->id",0,4) )));
	    print "<ul>";
	  }

	  print "<li><a href=\"" . $obj->url . "\">$obj->url</a>";
	    
	  $i++;
	}
	print "</ul></ul>";
      }
    }
    $db->free();

  }
}

?>


<table width="100%" bgcolor="#000000" border="0" cellspacing="0" cellpadding="1">
<tr><td>
<table width="100%" bgcolor="#cFcFcF" border="0" cellspacing="0" cellpadding="3">
<tr><td>
Depuis le 4 mai 2000 les utilisateurs de <a href="http://www.gnu.org/philosophy/free-sw.fr.html">logiciel libre</a> et de <a href="http://www.gnu.org/gnu/linux-and-gnu.fr.html">GNU/Linux</a>, <a href="http://www.gnu.org/software/hurd/hurd.html">Hurd</a>, *BSD et tous les systèmes libres se retouvent tous les premier jeudi de chaque mois pour boire un verre, manger un morceaux et surtout discuter de vive voix.
<p align="center">
<h2>Changement d'adresse !</h2>
</p><p>
Cette réunion se tient à Paris &agrave <b>La Taverne des Halles, 12 rue de la Cossonerie</b> (75001), métro Chatelets les Halles . Le rendez-vous est fixé à 20h00, mais vous pouvez arriver tout au long de la soirée.<br>La Taverne des Halles se trouve a 50m du Hall's Beer, l'ancien lieu des firstjeudi.<p>
Tous les utilisateurs de logiciel libre sont les bienvenus (*BSD, Hurd, Linux, etc) ainsi que toutes les associations.
<p>

Pour l'instant les associations/groupes qui "parrainent" cette bouffe sont :<p>

&nbsp;-&nbsp; <a HREF="http://www.april.org/">April</a><br>
&nbsp;-&nbsp; <a HREF="http://www.gcu-squad.org/">GCU-Squad</a><br>
&nbsp;-&nbsp; <a HREF="http://www.lsfn.net/">Libre Software French Network</a><br>
&nbsp;-&nbsp; <a HREF="http://www.linuxfr.org/">LinuxFR</a><br>
&nbsp;-&nbsp; <a HREF="http://www.lolix.org/">Lolix</a><br>
&nbsp;-&nbsp; <a HREF="http://www.parinux.org/">Parinux</a><br>
<p>
(On attend les autres, manifestez-vous ! :)
<p>
Afin d'évaluer approximativement le nombre de personnes qui viendront, nous vous demandons de bien vouloir vous inscrire par l'intermédiaire du formulaire suivant.
<p>
Attention, il faut s'inscrire <b>tous les mois</b> !
</td></tr>
</table>
</td></tr>
</table>


<br>

<?PHP
if ($action <> "add") {
?>
<u>Inscription</u> : <br>
<form action="index.php3" method="post">
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
<p>
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
Cette inscription a bien été enregistrée. Un mail contenant un id de modification vient de vous être envoyé à l'adresse : <?PHP echo $email; ?>.

<?PHP
		  }
?>
<br><br>

</td><td width="25%" valign="top">
Inscrits : <!-- pour le prochain <b>First Jeudi</b> du <?PHP echo $ndate; ?> -->
<hr>
<?PHP

$sql = "SELECT nom,prenom,email,asso,nb FROM user WHERE num = '$nnum'";
$nbligne = 0;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    print "<table width=\"100%\">\n";

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
      $i++; $j++;
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

<?PHP
	if (file_exists("pub.php3")){include("pub.php3");};

	if (file_exists("patent.php3")){include("patent.php3");};
?>


</table>



  </body>
</html>

