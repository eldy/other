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

include ("lib.inc.php3");
?>


<table border=1 cellpadding=8>
<tr>
<td>3eme Mercredi</td>
<td>2eme Jeudi</td>
<td>1er Samedi</td>
<td>Dernier Lundi</td>
</tr>

<tr>
<td valign="top"><?PHP print_date(3,3); ?></td>
<td valign="top"><?PHP print_date(4,2); ?></td>
<td valign="top"><?PHP print_date(6,1); ?></td>
<td valign="top"><?PHP print_date(1,5); ?></td>
</tr>


<tr>
<td>3eme vendredi</td>
<td>2eme mardi</td>
<td>4eme dimanche</td>
</tr>
<td valign="top"><?PHP print_date(5,3); ?></td>
<td valign="top"><?PHP print_date(2,2); ?></td>
<td valign="top"><?PHP print_date(0,4); ?></td>
</tr>
</table>



