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
 * $Id: lib.inc.php3,v 1.6 2002/10/31 16:45:57 rodolphe Exp $
 * $Source: /cvsroot/firstjeudi/firstjeudi/htdocs/lib.inc.php3,v $
 *
 */


function is_today($pday, $pweek) {

  $current_time = time();

  $numday = strftime("%w", $current_time);
  $day = strftime("%d", $current_time);

  if ($day <= 7) {
    $numweek = 1;
  } elseif ($day > 7 && $day <= 14) {
    $numweek = 2;
  } elseif ($day > 14 && $day <= 21) {
    $numweek = 3;
  } elseif ($day > 21 && $day <= 28) {
    $numweek = 4;
  } else {
    $numweek = 5;
  }


  if ($pday == $numday && $pweek == $numweek) {
    return 1;
  } else {
    return 0;
  }
}


function print_date($numday, $pnumweek, $debug=0) {

  if (is_today($numday, $pnumweek)) {

    print "Aujourd'hui";

  } else {
    $date = calcul_date($numday, $pnumweek, $debug);
    print ucfirst(strftime("%A",$date))." ".(strftime("%d",$date)*1)." ".ucfirst(strftime("%B %Y",$date)); 
  }

}


function old_calcul_date($numday, $pnumweek, $debug=0) {

  if ($pnumweek == 5) {
    $numweek = 4;
  } else {
    $numweek = $pnumweek;
  }
  
  $current_time = time();
  
  $date = mktime (0,0,0, 5, 4, 2000);
  
  if ($debug)
    print "DEBUG cur : ".strftime("%Y%m%d",$current_time) ."<br>";

  while (strftime("%Y%m%d",$date) < strftime("%Y%m%d",$current_time)  ) {
    $date = $date + (3600 * 24 * 26);

    if ($debug>5)
      print "DEBUG -- " .strftime("%A %Y&nbsp;%b", $date) . "&nbsp;" . (strftime("%d", $date) * 1) ."<br>";

  }
  
  $date = time();

  while (strftime ("%d", $date)+7 <= (7 * $numweek  ) or 
	 strftime ("%d", $date)+7 > (7 * ($numweek+1 ) ) or 
	 strftime ("%w", $date) <> $numday ) {
      
    $date = $date + ( 3600 * 24 );
    
    if ($debug)
      print "DEBUG2 -- " .strftime("%A %Y&nbsp;%b", $date) . "&nbsp;" . (strftime("%d", $date) * 1) ."<br>";

  }

  if ($pnumweek == 5)    {

    $ndate = $date + ( 7 * 24 * 3600 );
    
    if (strftime("%m", $ndate) == strftime("%m", $date)) {
      $date = $ndate;
    }
  }
  

  return $date;
  
}

function calcul_date($numday, $numweek, $debug=0) 
{

  $current_time = time();
  
  $year = strftime("%Y", $current_time);
  $month = strftime("%m", $current_time);
  $day = strftime("%d", $current_time);

  $current_time = mktime (12,0,0, $month, $day, $year);
  
  $date = mktime (12,0,0, $month, 1, $year);

  $date = get_date($date, $month, $numday, $numweek, $debug=0);

  if (strftime("%Y%m%d", $date) < strftime("%Y%m%d", $current_time)) 
    {
      if ($month == 12) 
	{
	  $date = mktime (12,0,0, 1, 1, $year + 1);
	  
	} 
      else 
	{
	  $date = mktime (12,0,0, $month + 1, 1, $year);
	}
      
      $date = get_date($date, $month, $numday, $numweek, $debug=0);
    }

  return $date;
  
}

function get_date($date, $month, $numday, $numweek, $debug=0) 
{

  if ($numweek == 5) 
    {
      $date = last_date($numday, $date, $month, $debug=0);
    }
  else 
    {
      $date = normal_date($numday, $numweek, $date, $debug=0);
    }
		 
  return $date;

}

function normal_date($numday, $numweek, $date, $debug=0) 
{
  while (strftime ("%w", $date) <> $numday ) 
    {
      $date = $date + ( 3600 * 24 );
    }
    
  $date = $date + ( 3600 * 24 * 7 * ($numweek - 1) ) ;
  
  return $date;
}

function last_date($numday, $date, $month, $debug=0) 
{
  while (strftime ("%m", $date) == $month ) 
    {
      if (strftime ("%w", $date) == $numday) 
	{
	  $datei = $date;
	}

      $date = $date + ( 3600 * 24 );
    }
  
  return $datei;
}



function print_dans($numweek, $numday) 
{
  $date = calcul_date($numday, $pnumweek);
  
}



?>
