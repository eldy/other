#!/usr/bin/perl
#-------------------------------------------------------
# Script to choose a ban to show from config file
#-------------------------------------------------------
use strict;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
my $REVISION='$Revision: 1.001 $'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.2 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
$Lang
$DirConfig
$FileConfig
$TraceFile
$DEBUG $DEBUGFILE $DEBUGRESET $REPLOG
$COUNTMAX $COUNT
$NO $GROUP
/;
$TraceFile="../../../logs/awban.trc";
$COUNTMAX=20; $COUNT=1;
$NO=0; $GROUP="DEFAULT";

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DEBUG=0;					# Debug level
$DEBUGFILE="$PROG.log";		# Debug output (A log file name or "screen" to have debug on screen)
#$DEBUGFILE="screen";		# Debug output (A log file name or "screen" to have debug on screen)
$REPLOG="../../../logs";

use vars qw/
%REGIE
%CONDITION
%NEXTACTION
%DELAY_FOR_NEXT
%LOGHIT
%URL
%IMAGE
$TAG
$NEWURL
$NEWIMAGE
/;

my $nowtime = my $nowweekofmonth = my $nowdaymod = my $nowsmallyear = 0;
my $nowsec = my $nowmin = my $nowhour = my $nowday = my $nowmonth = my $nowyear = my $nowwday = 0;



#-------------------------------------------------------
# Fonctions
#-------------------------------------------------------

sub debug {
	if ($DEBUGFILE !~ /screen/i) {
		if (! $DEBUGRESET && $DEBUG) {	open(LOGFILE,">$REPLOG/$DEBUGFILE"); close LOGFILE; chmod 0666,"$REPLOG/$DEBUGFILE"; $DEBUGRESET=1; }
		if ($DEBUG) {
			open(LOGFILE,">>$REPLOG/$DEBUGFILE");
			print LOGFILE time." $DEBUG $_[0]\n";
			close LOGFILE;
		}
	}
	else {
		if ($DEBUG) { print time." $DEBUG $_[0]".($ENV{"GATEWAY_INTERFACE"} ne ""?"<br>\n":"\n"); }
	}
}

sub Read_Config_File {
	$FileConfig="";$DirConfig=$DIR;if ($DirConfig && (!($DirConfig =~ /\/$/)) && (!($DirConfig =~ /\\$/)) ) { $DirConfig .= "/"; }
	if (! $FileConfig) { if (open(CONFIG,"$DirConfig$PROG.conf"))  { $FileConfig="$DirConfig$PROG.conf"; } }
	if (! $FileConfig) { $FileConfig="$PROG.conf"; error("Error: Couldn't open config file $PROG.conf: $!"); }
	if ($DEBUG) { debug("Call to Read_Config_File $FileConfig (GROUP=$GROUP, NO=$NO, COUNT=$COUNT)",1); }
	open(CONFIG,"$FileConfig");
	while (<CONFIG>) {
		chomp $_; $_ =~ s/\r//;
		if ($_ =~ /^\s*$/) { next; }
		if ($_ =~ /^#/) { next; }
		my $line=$_;
		my @param=split(/\t/,$line);
		if ($param[1] !~ /$GROUP/i) { next; }
		# We found good config line
		$REGIE{$param[0]}=$param[2];
		$CONDITION{$param[0]}=$param[3];
		$NEXTACTION{$param[0]}=$param[4];
		$DELAY_FOR_NEXT{$param[0]}=$param[5]; if ($DELAY_FOR_NEXT{$param[0]} !~ /^\d+$/) { $DELAY_FOR_NEXT{$param[0]}=30000; }
		$LOGHIT{$param[0]}=$param[6];
		$URL{$param[0]}=$param[7];
		$IMAGE{$param[0]}=$param[8];
		if ($DEBUG) {
			debug("NO=$param[0]",2);
			debug("NEXTACTION{$param[0]}=$NEXTACTION{$param[0]}",2);
			debug("DELAY_FOR_NEXT{$param[0]}=$DELAY_FOR_NEXT{$param[0]}",2);
			debug("LOGHIT{$param[0]}=$LOGHIT{$param[0]}",2);
			if ($URL{$param[0]}!~/iframe/i) { debug("URL{$param[0]}=$URL{$param[0]}",2); }
			else { debug("URL{$param[0]}='IFRAME'",2); }
			debug("IMAGE{$param[0]}=$IMAGE{$param[0]}",2);
		}
	}
	close CONFIG;
}



#--------------------------------------------------------#
# MAIN
#--------------------------------------------------------#

# Usage awban.pl [group=DEFAULT] [no=0] [count=0] [action=NEXT|KEEP|no]
my $STRING = $ENV{"QUERY_STRING"};
$STRING = "$STRING $ARGV[0] $ARGV[1] $ARGV[2] $ARGV[3]";

if ($STRING =~ /group=([^& ]+)/i) { $GROUP="$1"; }
if ($STRING =~ /no=(\d+)/i)       { $NO=$1; }
if ($STRING =~ /count=(\d+)/i)    { $COUNT=$1; }

# Get current time
$nowtime=time;
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday) = localtime($nowtime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }

# Read config file
&Read_Config_File;
# NEXTACTION can be overwritten
if ($STRING =~ /action=([^& ]+)/i) { $NEXTACTION{$NO}="$1"; }

# Test if new ban is qualified
my $qualified=0;
while (! $qualified && exists $NEXTACTION{$NO}) { 
	$qualified=1;
	# Check if entry qualified
	if ($DEBUG) { debug("Check if entry is qualified: CONDITION=$CONDITION{$NO} URL=$URL{$NO}",3); }
	if (! $URL{$NO}) { $qualified=0; }
	if ($qualified && $CONDITION{$NO} && $CONDITION{$NO} ne '-') {
		if ($CONDITION{$NO} =~ /H(\d\d)-(\d\d)/i) {
			# There is a condition on hour
			my $hourstart=int($1); my $hourend=int($2);
			if ($hourstart < $hourend) {
				if ($nowhour < $hourstart || $nowhour >= $hourend) { $qualified=0; }
			} else {
				if ($nowhour >= $hourend && $nowhour < $hourstart) { $qualified=0; }
			}
		}
	}

	# If not qualified we check with next entry
	if (! $qualified) {
		if ($NEXTACTION{$NO} eq 'KEEP') {
			# No next entry to replace the not qualified one, so definitly not qualified
			if ($DEBUG) { debug("Record not qualified. 'NEXTACTION' is KEEP so discarded.",3); }
			delete $NEXTACTION{$NO};
		}
		elsif ($NEXTACTION{$NO} eq 'NEXT') {
			# We try with next number
			if ($DEBUG) { debug("Record not qualified. We check next one NO=$NO+1.",3); }
			delete $NEXTACTION{$NO};
			$NO++;
		}
		else {
			# We try with next number
			if ($DEBUG) { debug("Record not qualified. We check next one NO=$NEXTACTION{$NO}.",3); }
			my $nosav=int($NEXTACTION{$NO});
			delete $NEXTACTION{$NO};
			$NO=$nosav;
		}
	}
}

if ($qualified) {
	$NEWURL=$URL{$NO};
	$NEWIMAGE=$IMAGE{$NO};
}
else {
	$NEWURL="QUALIFIED_URL_FOR_GROUP_${GROUP}_NO_${NO}_NOT_FOUND_IN_CONFIG_FILE";
	$NEWIMAGE="QUALIFIED_URL_FOR_GROUP_${GROUP}_NO_${NO}_NOT_FOUND_IN_CONFIG_FILE";
}


# Create TAG value
if ($NEWURL =~ /^http/i) {
	# Tag is URL + IMAGE
	$TAG="<A HREF=\"$NEWURL\" target=\"_parent\"><img name=\"pubImg\" SRC=\"$NEWIMAGE\" width=\"468\" height=\"60\" border=\"0\"></a>";
}
else {
	# Tag is CODE
	$TAG="$NEWURL";
}

# Redefine NEXTACTION
if ($NEXTACTION{$NO} eq 'NEXT') { $NEXTACTION{$NO}=int($NO); $NEXTACTION{$NO}++; }

# On trace
if ($LOGHIT{$NO} eq 'LOG') {
	# Trace accès dans fichier
	debug("Open trace file and write new ban",2);
	open(FICTRACE,">>$TraceFile") || print "Error: Failed to open file $TraceFile for writing: $!";
	print FICTRACE "$nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\t$GROUP\t$NO\t(next will be $NEXTACTION{$NO})\n";
	close(FICTRACE);
}

# Print refresh javascript code
$COUNT++;
if ($NEXTACTION{$NO} =~ /[\d]+/ && ($COUNT <= $COUNTMAX) && $DELAY_FOR_NEXT{$NO} > 0) {
	if ($DEBUG) { debug("Print ban output (with next action NEXTACTION{$NO}=$NEXTACTION{$NO},COUNT=$COUNT)",1); }
	print <<EOF;
<SCRIPT LANGUAGE="JavaScript">
function NewPage() {
	window.location.search="?group=$GROUP&no=$NEXTACTION{$NO}&count=$COUNT";
	window.reload;
	return;
}
setInterval("NewPage()", $DELAY_FOR_NEXT{$NO});
</SCRIPT>
EOF

}
else {
	if ($DEBUG) { debug("Print ban output (with no next action NEXTACTION{$NO}=$NEXTACTION{$NO})",1); }
}

if ($STRING =~ /buildframe=(.*)$/i) {
	my ($image,$linkforclick)=split(/,/,$1);
	# Print HTML Page
	print "<HTML>\n";
	print "<HEAD>\n";
	print "<META HTTP-EQUIV=\"PRAGMA\" CONTENT=\"NO-CACHE\">\n";
#	if ($NEXTACTION{$NO} =~ /[\d]+/ && ($COUNT <= $COUNTMAX) && $DELAY_FOR_NEXT{$NO} > 0) {
#		print "<META HTTP-EQUIV=Refresh CONTENT=\"$DELAY_FOR_NEXT{$NO}; URL=/cgi-bin/awban.pl?group=$GROUP&no=$NEXTACTION{$NO}&count=$COUNT\">";
#	}
	print "</HEAD>\n";
	print "<BODY>\n";
	print "<a href=\"$linkforclick\" target=_new><img src=\"$image\" border=0></a>\n";
	print "</BODY>\n";
	print "</HTML>\n";

}
else {
	print "<BODY marginwidth=\"0\" marginheight=\"0\" topmargin=\"0\" leftmargin=\"0\">\n";
	
	# Print the ban tag
	foreach my $line (split(/\\n/,$TAG)) {
		print "$line\n";
	}
	
	print "</BODY>\n";
}

0;
