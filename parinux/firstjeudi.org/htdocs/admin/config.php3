<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>FirstJeudi</title>
    <style type="text/css">
      table.ville { border: 1px dashed #c0c0c0 }
      table.menu { border: 1px dashed #c00000 }
      td.message { border: 1px dashed #c00000; background-color: #f0f0f0 }
    </style>
  </head>

  <body>
<table width="100%" class="menu">
<tr>
<td><a href="index.php3">Home</a></td>
<td><a href="config.php3">Menu</a></td>
<td><a href="config.php3?action=new">Ajouter</a></td>

</tr>
</table>
<br>
<?PHP
include_once('../conf/conf.php3');
include("../lib.inc.php3");

$current_time = time();

print "current : ".strftime("%w", $current_time)."<br>"; 
print "Week : ".strftime("%w", $current_time)."<br>"; 
print "WeekDay :  ".strftime("%w", $current_time)."<br>"; 



if ($action == "new") {
  print '<br><table width="100%" class="menu">';
  print '<form action="config.php3" method="post">';
  print '<input type="hidden" name="action" value="add">';
  print '<tr><td>Nom</td><td>';
  print '<input type="text" name="nom" size="40"></td></tr><tr>';
  print '<td>Code</td><td><input size="20" type="text" name="code">';
  print '</td></tr><tr><td colspan="2"><input type="submit"></td></tr>';
  print '</form></table><br>';
}

$current_time = time();

$weekday = strftime("%w", $current_time);
$cdate = strftime("%d %m %Y", $current_time);

include ("../htdocs/mysql.lib.php3");

$db = new Db("localhost","root","");

if ($action == "delete") {
  $sql = "DELETE FROM user WHERE id = '$id'";
  $db->query($sql);
}

if ($action == "add") {
  $sql = "INSERT INTO ville (nom,code) values ('$nom','$code');";
  $db->query($sql);
}

if ($action == "update") {
  $sql = "UPDATE ville set message='$message',numweek=$numweek, numday=$numday WHERE code='$ville';";
  $db->query($sql);
}


if ($action == "param") {
  $sql = "DELETE FROM config WHERE param='$nom' AND ville='$ville';";
  $db->query($sql);
  $sql = "INSERT INTO config (param, value, ville) values ('$nom','$value','$ville');";
  $db->query($sql);
}

?>
<table width="100%">
<tr>
<td valign="top" width="200">
<?PHP

$sql = "SELECT rowid, nom, code FROM ville ";
if ($ville) {
  $sql .= " WHERE code='$ville'";
}
$sql .= "ORDER BY nom";
$nbligne = 1;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    print '<table width="100%" class="ville"><tr>';

    $i = 0;
    $j = 1 ;
    while ($i < $nump) {
      if ($j > 5) {
	$j = 1;
	print '</tr><tr>';
      }
      $obj = $db->fetch_object($i);
      print '<td width="20%"><a href="config.php3?ville='.$obj->code.'">'.$obj->nom.'</a> [';
      print '<a href="http://'.$obj->code.'.firstjeudi.org/">W</a>]</td>';

      $i++;
      $j++;
    }
    print "</tr></table>";
  }
}

?>
</td></tr>
<tr><td valign="top">

<?PHP

$sql = "SELECT * FROM ville WHERE code = '$ville' ";

$nbligne = 1;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    $obj = $db->fetch_object(0);

    if (is_today($obj->numday, $obj->numweek)) {
      print "Aujourd'hui<br>";
    }


    print '<table width="100%" class="ville">';
    print '<form action="config.php3?action=update&ville='.$ville.'" method="post">';

    print '<tr><td>'.$obj->nom.'</a></td>';

    print '<tr><td>Numday</td><td>'.$obj->numday.'</td>';
    print '<td><input type="text" name="numday" value="'.$obj->numday.'"></td></tr>';
    print '<tr><td>Numweek</td><td>'.$obj->numweek.'</td>';
    print '<td><input type="text" name="numweek" value="'.$obj->numweek.'"></td></tr>';

    print '<tr><td valign="top">Message</td><td valign="top" class="message">'.$obj->message.'</td>';
    print '<td><textarea name="message" wrap="soft" cols="60" rows="30">'.$obj->message.'</textarea></td></tr>';

    print '<td><a href="index.php3?ville='.$ville.'&num='.$obj->num.'">'.$obj->cc.'</a></td></tr>';
    print '<tr><td align="center" colspan="3"><input type="submit"></tr>';
    print "</form></table>";
  }
} else {
      print $db->error();
}
$db->close();
?>

</td>

</tr>
</table>


<ul>
<li>0 : dimanche
<li>1 : lundi
<li>2 : mardi
<li>3 : mercredi
<li>4 : jeudi
<li>5 : vendredi
<li>6 : samedi
</ul>




    <hr>
    <address><a href="mailto:rq@lolix.org">Rodolphe Quiedeville</a></address>
<!-- Created: Wed Jan 23 14:40:55 CET 2002 -->
<!-- hhmts start -->
Last modified: Wed May 29 13:33:53 CEST 2002
<!-- hhmts end -->
  </body>
</html>
