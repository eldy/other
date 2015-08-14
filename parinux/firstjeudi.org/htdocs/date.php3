<?PHP


function print_next() {

$current_time = time();
$weekday = strftime("%w", $current_time);
$cdate = strftime("%d %m %Y", $current_time);

$date = time();





while (strftime("%Y%m%d",$date) < strftime("%Y%m%d",$current_time)  ) {
  if ($debug) {
    print "-- " .strftime("%A %Y&nbsp;%b", $date) . "&nbsp;" . (strftime("%d", $date) * 1) ."<br>";
  }
  $date = $date + (3600 * 24 * 26);
  
  while (strftime ("%d", $date)+7 < (7 * $objville->numweek  ) or 
	 strftime ("%d", $date)+7 > (7 * ($objville->numweek+1 ) ) or 
	 strftime ("%w", $date) <> $objville->numday ) {

    $date = $date + ( 3600 * 24 );
  }
}



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


print '<br>';
print $objville->numday;
print '<br>';
print $objville->numweek;
}
?>
