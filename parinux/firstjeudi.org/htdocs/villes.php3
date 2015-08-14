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
 * $Id: first.php3,v 1.3 2002/08/02 12:55:53 rodolphe Exp $
 * $Source: /cvsroot/firstjeudi/firstjeudi/htdocs/first.php3,v $
 *
 */

include ("mysql.lib.php3");
include ("lib.inc.php3");
setlocale("LC_TIME","fr_FR");

$db = new Db($dbhost,$dbuser,$dbpass);

print "<table border=1 cellpadding=8>";

$sql = "SELECT * FROM ville order by nom asc ";



if ( $db->query($sql) ) {
  $nump = $db->num_rows(); 
  $i = 0;
  while ($i < $nump) {
    $objville = $db->fetch_object(0);

    print "<tr>";
    print "<td>" . $objville->nom . "</td>";
    print "<td>" . $objville->numweek . "</td>";
    print "<td>" . $objville->numday . "</td>";
    print "<td>";
    print_date($objville->numweek,$objville->numday) . "</td>";

    print "</tr>";


    $i++;

  }
} else {
  print "Db failed";
  exit;
}



?>



</table>



