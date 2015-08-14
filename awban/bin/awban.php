<?php
$PROG="awban";
$TraceFile="../../../logs/awban.trc";
$FileConfig="./awban.conf";
$COUNTMAX=20;
$MINDELAY=30000;
$DEFAULTDELAY=45000;

$DEBUGFILE="$PROG.log";		# Debug output (A log file name or "screen" to have debug on screen)
#$DEBUGFILE="screen";		# Debug output (A log file name or "screen" to have debug on screen)
$REPLOG="../../../logs";
$DEBUG=0;

$COUNT=isset($_GET["count"])?$_GET["count"]:1;
$NO=isset($_GET["no"])?$_GET["no"]:0;
$GROUP=isset($_GET["group"])?$_GET["group"]:'DEFAULT';
$grouparray=split('_',$GROUP);
$GROUP=$grouparray[0];
$NOREFRESH=isset($_GET["norefresh"])?$_GET["norefresh"]:0;

$GROUPSTRING=($GROUP!=''?"group=$GROUP":"");
$NOSTRING=($NO!=''?"no=$NO":"");
$COUNTSTRING=($COUNT!=''?"count=$COUNT":"");


Read_Config_File();


# NEXTACTION can be overwritten
if (isset($_GET["action"])) { $NEXTACTION[$NO]=$_GET["action"]; }

# Test if new ban is qualified
$qualified=0;
while (! $qualified && isset($NEXTACTION[$NO])) { 
	$qualified=1;
	# Check if entry qualified
	if ($DEBUG) { debug("Check if entry is qualified: CONDITION=$CONDITION[$NO] URL=$URL[$NO]",3); }
	if (! $URL[$NO]) { $qualified=0; }
	if ($qualified && isset($CONDITION[$NO]) && $CONDITION[$NO] != '-') {
		if (eregi('H(\d\d)-(\d\d)',$CONDITION[$NO],$reg)) {
			# There is a condition on hour
			$hourstart=$reg[1]; $hourend=$reg[2];
			if ($hourstart < $hourend) {
				if ($nowhour < $hourstart || $nowhour >= $hourend) { $qualified=0; }
			} else {
				if ($nowhour >= $hourend && $nowhour < $hourstart) { $qualified=0; }
			}
		}
	}

	# If not qualified we check with next entry
	if (! $qualified) {
		if ($NEXTACTION[$NO] == 'KEEP') {
			# No next entry to replace the not qualified one, so definitly not qualified
			if ($DEBUG) { debug("Record not qualified. 'NEXTACTION' is KEEP so discarded.",3); }
			$NEXTACTION[$NO]='';
		}
		elseif ($NEXTACTION[$NO] == 'NEXT') {
			# We try with next number
			if ($DEBUG) { debug("Record not qualified. We check next one NO=$NO+1.",3); }
			$NEXTACTION[$NO]='';
			$NO++;
		}
		else {
			# We try with next number
			if ($DEBUG) { debug("Record not qualified. We check next one NO=$NEXTACTION{$NO}.",3); }
			$nosav=$NEXTACTION[$NO];
			$NEXTACTION[$NO]='';
			$NO=$nosav;
		}
	}
}

if ($qualified) {
	$NEWURL=$URL[$NO];
	$NEWIMAGE=$IMAGE[$NO];
}
else {
	$NEWURL="QUALIFIED_URL_FOR_GROUP_${GROUP}_NO_${NO}_NOT_FOUND_IN_CONFIG_FILE";
	$NEWIMAGE="QUALIFIED_URL_FOR_GROUP_${GROUP}_NO_${NO}_NOT_FOUND_IN_CONFIG_FILE";
}


# Create TAG value
if (eregi('^http',$NEWURL)) {
	# Tag is URL + IMAGE
	$TAG="<A HREF=\"$NEWURL\" target=\"_parent\"><img name=\"pubImg\" SRC=\"$NEWIMAGE\" width=\"468\" height=\"60\" border=\"0\"></a>";
}
else {
	# Tag is CODE
	$TAG="$NEWURL";
}

# Redefine NEXTACTION
if ($NEXTACTION[$NO] == 'NEXT') { $NEXTACTION[$NO]=$NO; $NEXTACTION[$NO]++; }

# On trace
if ($LOGHIT[$NO] == 'LOG') {
	# Trace accès dans fichier
	if ($DEBUG) { debug("Open trace file and write new ban",2); }
//	open(FICTRACE,">>$TraceFile") || print "Error: Failed to open file $TraceFile for writing: $!";
//	print FICTRACE "$nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\t$GROUP\t$NO\t(next will be $NEXTACTION{$NO})\n";
//	close(FICTRACE);
}

# Affiche page
//print "Print ban output (with next action NEXTACTION[$NO]=$NEXTACTION[$NO],COUNT=$COUNT, DELAY_FOR_NEXT[$NO]=$DELAY_FOR_NEXT[$NO])\n";
if (isset($_GET["buildframe"])) {
    $tab=split(',',$_GET["buildframe"]);
    $image=$tab[0];
    $linkforclick=$tab[1];
    print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'."\n";
	print "<HTML>\n";
	print "<HEAD>\n";
    print "<title>Bandeau publicitaire</title>\n";
	print "<meta name=\"robots\" content=\"noindex,nofollow\">\n";
	print "<META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\">\n";
	print "</HEAD>\n";
	print "<BODY>\n";
    if (! $NOREFRESH) { Print_Refresh_Js(); }
	print "<a href=\"$linkforclick\" target=_new><img src=\"$image\" border=0></a>\n";
	print "</BODY>\n";
	print "</HTML>\n";
}
else {
    print '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">'."\n";
	print "<HTML>\n";
	print "<HEAD>\n";
    print "<title>Bandeau publicitaire</title>\n";
	print "<meta name=\"robots\" content=\"noindex,nofollow\">\n";
	print "</HEAD>\n";
	print '<BODY style="margin-width: 0; margin-height: 0; margin-top: 0; margin-left: 0;">'."\n";
    if (! $NOREFRESH) { Print_Refresh_Js(); }
    print "<!-- NO=$NO, COUNT=$COUNT -->\n";
	# Print the ban tag
	$tab=split("\n",$TAG);
	foreach ($tab as $line)
	{
		print "$line\n";
	}
	print "</BODY>\n";
	print "</HTML>\n";
}


function Print_Refresh_Js() {
    global $FileConfig,$GROUP,$REGIE,$CONDITION,$NEXTACTION,$DELAY_FOR_NEXT,$LOGHIT,$URL,$IMAGE,$DEBUG;
    global $MINDELAY,$DEFAULTDELAY;
    global $COUNT,$NO,$COUNTMAX;
    
    # Print refresh javascript code
    $COUNT++;
    if (ereg('[0-9]+',$NEXTACTION[$NO]) && ($COUNT <= $COUNTMAX) && $DELAY_FOR_NEXT[$NO] > 0) {
    	if ($DEBUG) { debug("Print ban output (with next action NEXTACTION[$NO]=$NEXTACTION[$NO],COUNT=$COUNT)",1); }
    	print "<SCRIPT LANGUAGE='JavaScript' type='text/javascript'>\n";
        print "function NewPage() {\n";
    	print "window.location.search=\"?group=$GROUP&no=".$NEXTACTION[$NO]."&count=".$COUNT."\"\n";
    	print "window.reload;\n";
    	print "return;\n";
        print "}\n";
        print "setInterval(\"NewPage()\", ".$DELAY_FOR_NEXT[$NO].");\n";
        print "</SCRIPT>\n";
    }
    else {
    	if ($DEBUG) { debug("Print ban output (with no next action NEXTACTION{$NO}=$NEXTACTION{$NO})",1); }
    }
}

function Read_Config_File() {
  global $FileConfig,$GROUP,$REGIE,$CONDITION,$NEXTACTION,$DELAY_FOR_NEXT,$LOGHIT,$URL,$IMAGE,$DEBUG;
  global $MINDELAY,$DEFAULTDELAY;

  if ($fp = fopen($FileConfig,"rt")) {
    $finded=0;
    while (($line = fgets($fp,4096)) && ($finded == 0)) {
		if (eregi('^\s*$',$line)) { continue; }
		if (eregi('^#',$line)) { continue; }
		$param=split("\t",$line);
		//print join(',',$param)."<br>\n";
		if (sizeof($param)<=1 || ! eregi('^'.$GROUP.'$',$param[1])) { continue; }

		# We found good config line, sanitize parameters
		$REGIE[$param[0]]=$param[2];
		$CONDITION[$param[0]]=$param[3];
		$NEXTACTION[$param[0]]=$param[4];
		$DELAY_FOR_NEXT[$param[0]]=$param[5];
		if (! ereg('^\d+$',$DELAY_FOR_NEXT[$param[0]])) { $DELAY_FOR_NEXT[$param[0]]=$DEFAULTDELAY; }
		if ($DELAY_FOR_NEXT[$param[0]] < $MINDELAY) { $DELAY_FOR_NEXT[$param[0]]=$MINDELAY; }
		$LOGHIT[$param[0]]=$param[6];
		$URL[$param[0]]=$param[7];
		$IMAGE[$param[0]]=isset($param[8])?$param[8]:'';
		if ($DEBUG) {
			debug("NO=".$param[0],2);
			debug("NEXTACTION[$param[0]]=".$NEXTACTION[$param[0]],2);
			debug("DELAY_FOR_NEXT[$param[0]]=".$DELAY_FOR_NEXT[$param[0]],2);
			debug("LOGHIT[$param[0]]=".$LOGHIT[$param[0]],2);
			if (! eregi('iframe',$URL[$param[0]])) { debug("URL[$param[0]]=".$URL[$param[0]],2); }
			else { debug("URL[$param[0]]='IFRAME'",2); }
			debug("IMAGE[$param[0]]=".$IMAGE[$param[0]],2);
		}
	}
	fclose($fp);
  }
}

?>

