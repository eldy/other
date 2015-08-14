
<div 
class="cadreout" 
onMouseOver="changeclass(this,'cadreover')" 
onMouseOut="changeclass(this,'cadreout')" 
onClick="document.location='http://www.firstjeudi.org/'">

<a class="link" onMouseOver="changeclass(this,'linkover')" onMouseOut="changeclass(this,'link')" href="http://www.firstjeudi.org/">Accueil</a>

</div>

<br>


<?PHP

$sql = "SELECT nom, code FROM ville WHERE active=1 ORDER by nom ASC";

if ( $db->query($sql) ) {

  $nump = $db->num_rows();
  $i = 0;

  while ($i < $nump) {

    $obj = $db->fetch_object($i);

    if ($VILLE == $obj->code) {

      $class = "cadreselect";


    } else {
      $class = "cadreout";
    }


    print '<div class="'.$class.'" onMouseOver="changeclass(this,\'cadreover\')" onMouseOut="changeclass(this,\''.$class.'\')" onClick="document.location=\'http://'.$obj->code.'.firstjeudi.org/\'">';
    
    print '<a class="link" onMouseOver="changeclass(this,\'linkover\')" onMouseOut="changeclass(this,\'link\')" href="http://'.$obj->code.'.firstjeudi.org/">'.$obj->nom.'</a></div>';
 
    $i++;
  }
  $db->free();
}
?>
