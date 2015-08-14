<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<?PHP

$action=$_REQUEST["action"];
$id=$_REQUEST["id"];
$ville=$_REQUEST["ville"];


?>

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
    <title>FirstJeudi</title>
    <style type="text/css">
      table.ville { border: 1px dashed #c0c0c0 }
      table.menu { border: 1px dashed #c00000 }
    </style>
  </head>

  <body>
<table width="100%" class="menu">
<tr><td>
<a href="config.php3">Config</a>
</td></tr>
</table>
<br>
<?PHP

$current_time = time();

$weekday = strftime("%w", $current_time);
$cdate = strftime("%d %m %Y", $current_time);

include_once('../conf/conf.php3');
include("../mysql.lib.php3");

$db = new Db($dbhost,$dbuser,$dbpass);

if ($action == "delete") {
  $sql = "DELETE FROM user WHERE id = '$id'";
  $db->query($sql);
}

?>
<table width="100%" class="menu">
<tr>

<td valign="top" width="120">
<?PHP

$sql = "SELECT distinct(ville) FROM user ORDER BY ville";

$nbligne = 1;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    print '<table width="100%" class="ville">';

    $i = 0;
    while ($i < $nump) {
      
      $obj = $db->fetch_object($i);
      print '<tr><td>[<a href="http://'.$obj->ville.'.firstjeudi.org/">www</a>]</td>';
      print '<td><a href="index.php3?ville='.$obj->ville.'">'.$obj->ville.'</a></td></tr>';

      $i++;
      $numins = $numins + $obj->nb;
    }


    print "</table>";
  }
}

?>
</td>
<td valign="top" width="120">

<?PHP

$sql = "SELECT count(*) as cc, num FROM user WHERE ville = '$ville' group by num DESC";

$nbligne = 1;
$numins = 0;
if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  
  if ($nump) {
    print '<table width="100%" class="ville">';

    $i = 0;
    while ($i < $nump) {
      
      $obj = $db->fetch_object($i);
      print '<tr><td><a href="index.php3?ville='.$ville.'&num='.$obj->num.'">'.$obj->num.'</a></td>';
      print '<td><a href="index.php3?ville='.$ville.'&num='.$obj->num.'">'.$obj->cc.'</a></tr>';

      $i++;
      $numins = $numins + $obj->nb;
    }


    print "</table>";
  }
} else {
      print $db->error();
}

?>
</td>
<td valign="top">

<?PHP
if ($num && $ville) {
  $sql = "SELECT tms, nom, prenom, email, ip, id FROM user WHERE ville = '$ville' AND num = $num order by nom ASC";

  $nbligne = 1;
  $numins = 0;
  if ( $db->query($sql) ) {

    $nump = $db->num_rows();
  
    if ($nump) {
      print '<table width="100%" class="ville">';

      $i = 0;
      while ($i < $nump) {
	
	$obj = $db->fetch_object($i);
	print '<tr>';
	print '<td><a href="index.php3?ville='.$ville.'&num='.$num.'&action=delete&id='.$obj->id.'">del</a></td>';
	print '<td>'.$obj->prenom.'</td>';
	print '<td>'.$obj->nom.'</td>';
	print '<td>'.$obj->email.'</td>';
	print '<td>'.$obj->ip.'</td>';
	print '<td>'.$obj->tms.'</td>';
	
	print '</tr>';
	$i++;
	$numins = $numins + $obj->nb;
      }


      print "</table>";
    }
  } else {
    print $db->error();
  }
}
$db->close();
?>



</td>


</tr>
</table>







    <hr>
    <address><a href="mailto:rq@lolix.org">Rodolphe Quiedeville</a></address>
<!-- Created: Wed Jan 23 14:40:55 CET 2002 -->
<!-- hhmts start -->
Last modified: Wed May 29 13:33:53 CEST 2002
<!-- hhmts end -->
  </body>
</html>
