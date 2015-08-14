#!/usr/bin/perl
#-------------------------------------------------------
# Script to choose a ban to show from config file
#-------------------------------------------------------
use strict;
use Net::FTP;

#-------------------------------------------------------
# Defines
#-------------------------------------------------------
use vars qw/ $REVISION $VERSION /;
my $REVISION='$Revision: 1.001 $'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
my $VERSION="1.2 (build $REVISION)";

use vars qw/
$DIR $PROG $Extension
$DEBUG $DEBUGFILE $DEBUGRESET $REPLOG
/;

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DEBUG=0;					# Debug level
#$DEBUGFILE="$PROG.log";		# Debug output (A log file name or "screen" to have debug on screen)
$DEBUGFILE="screen";		# Debug output (A log file name or "screen" to have debug on screen)
$REPLOG="/export/home/wwwroot/nicoboy/logs";

use vars qw/
$COMMANDTOFINDIP
$LINETOEXTRACTIP
$FILETOUPDATEFROM
$FILETOUPDATETO
$FILETOUPLOAD
$SERVERTOUPDATE
$USER
$PASSWORD
$CurrentIp $LastIp
$QueryString
/;

$COMMANDTOFINDIP='ipconfig /all';
$LINETOEXTRACTIP='Adresse IP[^:]*:\s*(80\.\d+\.\d+\.\d+)';
$FILETOUPDATEFROM='d:/Mes Sites/web/Perso/html/perso_adminref.htm';
$FILETOUPDATETO='d:/Mes Sites/web/Perso/html/perso_admin.htm';
$FILETOUPLOAD='perso_admin.htm';
$SERVERTOUPDATE='perso-ftp.wanadoo.fr';
$USER='l.destailleur';
$PASSWORD='QJIXRKPI';


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

#-----------------------------------------------------------
# Return $LastIp or 0 if not found
#-----------------------------------------------------------
sub Read_LastUpdateFile {
	my $lastupdatefile="$PROG.lock";
	if ($DEBUG) { debug("Call to Read_LastUpdateFile",1); }
	open(LASTUDATE,"<$lastupdatefile");
	while (<LASTUDATE>) {
		chomp $_; $_ =~ s/\r//;
		if ($_ =~ /^\s*$/) { next; }
		if ($_ =~ /^#/) { next; }
		my ($param,$value)=split(/\s+/,$_,2);
		if ($param eq 'LAST_IP') { $LastIp="$value"; last; }
	}
	close LASTUDATE;
	if ($DEBUG) { debug("LastIp=$LastIp",1); }
	return ($LastIp?"$LastIp":"0");
}

#-----------------------------------------------------------
# Save $LastIp in file
#-----------------------------------------------------------
sub Save_LastUpdateFile {
	my $lastupdatefile="$PROG.lock";
	if ($DEBUG) { debug("Call to Save_LastUpdateFile",1); }
	open(LASTUPDATE,">$lastupdatefile");
	print LASTUPDATE "LAST_DATE	$nowyear-$nowmonth-$nowday $nowhour:$nowmin:$nowsec\n";
	print LASTUPDATE "LAST_IP	$CurrentIp\n";
	close LASTUPDATE;
	return 0;
}

#-----------------------------------------------------------
# Return $LastIp or 0 if not found
#-----------------------------------------------------------
sub Get_IP {
	my $command="$COMMANDTOFINDIP";
	if ($DEBUG) { debug("Extract IP address with command: $command",1); }
	my $ret=`$command 2>&1`;
	if ($ret =~ /$LINETOEXTRACTIP/o) {
		$CurrentIp=$1;
	}
	if ($DEBUG) { debug("CurrentIp=$CurrentIp",1); }
	return $CurrentIp?"$CurrentIp":"0";
}



#--------------------------------------------------------#
# MAIN
#--------------------------------------------------------#

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

# Define QueryString (string with all parameters)
$QueryString=""; for (0..@ARGV-1) {
	#if ($_ > 0) { $QueryString .= "&"; }
	$QueryString .= "&";
	my $NewLinkParams=$ARGV[$_]; $NewLinkParams =~ s/^-+//; $NewLinkParams =~ s/\s/%20/g;
	$QueryString .= "$NewLinkParams";
}

# Get IP
if ($QueryString =~ /&debug=(\d+)/i)		{ $DEBUG=$1; }

# Read lastupdate file
&Read_LastUpdateFile();

# Get IP
&Get_IP();

# Update file from to
if ($DEBUG) { debug("Update/Create file '$FILETOUPDATETO' from '$FILETOUPDATEFROM'",1); }
open(FROMFILE,"<$FILETOUPDATEFROM") || error("Error: Can't open $FILETOUPDATEFROM for reading");
open(TOFILE,">$FILETOUPDATETO") || error("Error: Can't open $FILETOUPDATETO for writing");
while (<FROMFILE>) {
	$_ =~ s/Non connecté/$CurrentIp/g;
	$_ =~ s/\d\d\/\d\d\/\d+\s\d\d:\d\d:\d\d/$nowday\/$nowmonth\/$nowyear $nowhour:$nowmin:$nowsec/g;
	print TOFILE $_;
}
close FROMFILE;
close TOFILE;

# Send file
my $result="";
if (! $LastIp || ($CurrentIp ne $LastIp)) {
	if ($DEBUG) { debug("Send put '$FILETOUPDATETO' '$FILETOUPLOAD'",1); }
	my $ftp = Net::FTP->new("$SERVERTOUPDATE", Debug => $DEBUG?1:0);
	$ftp->login("$USER","$PASSWORD");
	$result=$ftp->put("$FILETOUPDATETO","$FILETOUPLOAD");
	$ftp->quit;
}

# Save lastupdate file
if ($result) {
	&Save_LastUpdateFile();
}

0;
