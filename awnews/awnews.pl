#!/usr/bin/perl
#-------------------------------------------------------
# Get news from differents web site sources to
# create a news file and to generate a js module.
#-------------------------------------------------------
#use strict;

use CGI;
use URI::Escape;
use Fcntl;
use Time::Local;
#use File::Copy;
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Request;
use HTTP::Response;


#-------------------------------------------------------
# Defines
#-------------------------------------------------------
$VERSION="1.4";
$Lang=0;
$DEBUG=0;
$KEYWORDS=();
$NBOFNEWS=3;
$TIMEOUT=60;		# Timeout used for GET HTTP access (in seconds)
$MAXSIZE=50000;		# Max Size in bytes of response
$USERAGENT='Mozilla/4.0 (compatible; MSIE 5.5; Windows 98; Win 9x 4.90; KITV4.7 Wanadoo)';
$USER='';

#$TEXTHEADER="<b>Actualité/News canines</b><br><hr>";



#-------------------------------------------------------
# Fonctions
#-------------------------------------------------------

sub error {
   	print "<font color=#880000>$_[0].</font><br>\n";
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "<br><b>\n"; }
	print "Setup ($FileConfig file, web server or logfile permissions) may be wrong.\n";
	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</b><br>\n"; }
	print "See README.TXT for informations on how to setup $PROG.\n";
   	if ($ENV{"GATEWAY_INTERFACE"} ne "") { print "</BODY>\n</HTML>\n"; }
	die;
}

sub Read_Existing_News {
	print "Scan for existing news in $DirNews\n";
	print LOGFILE "\nScan for existing news in $DirNews\n";

	# Get list of all News file
	opendir(DIR,"$DIR/$DirNews");
	@filearray = sort readdir DIR;
	close DIR;
	$noexistingnews=1;
	foreach $i (0..$#filearray) {
		if ("$filearray[$i]" =~ /^news.*\.txt$/) {
			# Get info for news $filearray[$i]
			print " Read news file numero $noexistingnews : $filearray[$i]\n";
			print LOGFILE " Read news file : $filearray[$i]\n";
			open(NEWSFILE,"$DIR/$DirNews/$filearray[$i]") || die("Error: Couldn't open news file $DirNews/$filearray[$i]: $!");
			binmode NEWSFILE;
			$ExistingNews{"FILE_NAME"}{$noexistingnews}=$filearray[$i];
			while (<NEWSFILE>) {
				chomp $_; s/\r//;
				$line=$_; 
				$line =~ s/#.*//; $line =~ s/	/¥/g; $line =~ s/ /¥/g;
				$param = $line; $value = $line; 
				if ($param =~ s/=.*//) {
					$value =~ s/$param=//;
					$value =~ s/^¥*//g; $value =~ s/¥*$//g; $value =~ s/¥/ /g; $value =~ s/^\"//; $value =~ s/\"$//;
					if ($line =~ /^NEWS_SOURCE/)       		{ $ExistingNews{"NEWS_SOURCE"}{$noexistingnews}=$value; next; }
					if ($line =~ /^NEWS_TITLE/)           	{ $ExistingNews{"NEWS_TITLE"}{$noexistingnews}=$value; next; }
					if ($line =~ /^NEWS_URL/)       		{ $ExistingNews{"NEWS_URL"}{$noexistingnews}=$value; next; }
					if ($line =~ /^NEWS_DATE/)           	{ $ExistingNews{"NEWS_DATE"}{$noexistingnews}=$value; next; }
					if ($line =~ /^NEWS_DELAY_PURGE/)      	{ $ExistingNews{"NEWS_DELAY_PURGE"}{$noexistingnews}=$value; next; }
				}
				$line =~ s/^¥*//g; $line =~ s/¥*$//g; $line =~ s/¥/ /g; $line =~ s/^\"//; $line =~ s/\"$//;
				$ExistingNews{"NEWS_TEXT"}{$noexistingnews}.=$line;
			}
			close NEWSFILE;

			# Check info for this news
			$corrupted_news_file=0;
			if ($ExistingNews{"NEWS_DATE"}{$noexistingnews} eq "") { $corrupted_news_file=1; }
			if ($ExistingNews{"NEWS_SOURCE"}{$noexistingnews} eq "") { $corrupted_news_file=1; }
			if ($corrupted_news_file) {
				print LOGFILE "  This news file seems to be corrupted. Forget it.\n";
				delete $ExistingNews{"FILE_NAME"}{$noexistingnews};
				delete $ExistingNews{"NEWS_SOURCE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_TITLE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_URL"}{$noexistingnews};
				delete $ExistingNews{"NEWS_DATE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_DELAY_PURGE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_TEXT"}{$noexistingnews};
				next;
				}
			if (! ($ExistingNews{"NEWS_DELAY_PURGE"}{$noexistingnews} =~ /[\d]*/)) {
				$ExistingNews{"NEWS_DELAY_PURGE"}{$i}=0;
			}

			# Change date on news
			my $fileday = $ExistingNews{"NEWS_DATE"}{$noexistingnews}; $fileday =~ s/\/.*$//;
			my $filemonth = $ExistingNews{"NEWS_DATE"}{$noexistingnews}; $filemonth =~ s/^..\///; $filemonth =~ s/\/..$//;
			my $fileyear = $ExistingNews{"NEWS_DATE"}{$noexistingnews}; $fileyear =~ s/^.*\///;
			print LOGFILE "  News file read: NEWS_TITLE=".$ExistingNews{"NEWS_TITLE"}{$noexistingnews}.", NEWS_DATE=$fileday/$filemonth/$fileyear\n";
			my $filetime = timelocal(0,0,12,$fileday,$filemonth-1,$fileyear);
			my $filetimetodelete = $filetime + ($ExistingNews{"NEWS_DELAY_PURGE"}{$noexistingnews} * 24 * 60 * 60);
			
			# Delete news if necessary (move into purge)
#			($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat(NEWSFILE);
			$currenttime=time;
			if ($currenttime > $filetimetodelete) {
				print "  News is obsolete so removed (DATE TO DELETE = $filetimetodelete)\n";
				print LOGFILE "  News is obsolete so removed (DATE TO DELETE = $filetimetodelete)\n";
				unlink "$DirNews/$filearray[$i]";
				delete $ExistingNews{"FILE_NAME"}{$noexistingnews};
				delete $ExistingNews{"NEWS_SOURCE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_TITLE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_URL"}{$noexistingnews};
				delete $ExistingNews{"NEWS_DATE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_DELAY_PURGE"}{$noexistingnews};
				delete $ExistingNews{"NEWS_TEXT"}{$noexistingnews};
				next;
			}

			# News is OK
#			utime $filetime, $filetime, NEWSFILE;
			$FileTimeToDelete{$noexistingnews}=$filetimetodelete;

			$noexistingnews++;
		}
	}
}


sub Read_Config_File {
	$FileConfig="";$DirConfig=$DIR;if (($DirConfig ne "") && (!($DirConfig =~ /\/$/)) && (!($DirConfig =~ /\\$/)) ) { $DirConfig .= "/"; }
	if (open(CONFIG,"$DirConfig$PROG.$LocalSite.conf")) { $FileConfig="$DirConfig$PROG.$LocalSite.conf"; $FileSuffix=".$LocalSite"; }
	if (! $FileConfig) { if (open(CONFIG,"$DirConfig$PROG.conf"))  { $FileConfig="$DirConfig$PROG.conf"; $FileSuffix=""; } }
	if (! $FileConfig) { $FileConfig="$PROG.conf"; die("Error: Couldn't open config file [$PROG.$LocalSite.conf] nor [$PROG.conf]: $!"); }
	print "Read config file $FileConfig\n";
	$section=0;
	binmode CONFIG;
	while (<CONFIG>) {
		chomp $_; s/\r//;
		$line=$_; $line =~ s/#.*//; $line =~ s/	/¥/g; $line =~ s/ /¥/g;
		$param = $line; $param =~ s/=.*//;
		$value = $line; $value =~ s/$param=//;
		$value =~ s/¥*$//g; $value =~ s/^¥*//g; $value =~ s/¥/ /g; $value =~ s/^\"//; $value =~ s/\"$//;
		if ($line =~ /^DIRLOG/)               	{ $DirLog=$value; next; }
		if ($line =~ /^KEYWORDS/)				{ @KEYWORDS=split(/\s/,$value); next; }

		if ($line =~ /^DIRNEWS/)				{ $DirNews=$value; next; }
		if ($line =~ /^DIRJS/)               	{ $DirJS=$value; next; }
		if ($line =~ /^FILEJS/)					{ $FileJS=$value; next; }
		if ($line =~ /^NBOFNEWS/)				{ $NBOFNEWS=$value; next; }
		
		if ($line =~ /^SECTION/)               	{ $section=$value; next; }
		if ($line =~ /^USEKEYWORDS/)           	{ $USEKEYWORDS{$section}=$value; next; }
		if ($line =~ /^SOURCEISUTF8/)          	{ $SOURCEISUTF8{$section}=$value; next; }
		if ($line =~ /^SOURCE/)               	{ $SOURCE{$section}=$value; next; }
		if ($line =~ /^URL_TO_SCAN/)       		{ $URL_TO_SCAN{$section}=$value; next; }
		if ($line =~ /^URL_TO_LINK/)       		{ $URL_TO_LINK{$section}=$value; next; }
		if ($line =~ /^STARTDATA/)         		{ $STARTDATA{$section}=$value; next; }
		if ($line =~ /^ENDDATA/)            	{ $ENDDATA{$section}=$value; next; }
		if ($line =~ /^STARTRECORD/)         	{ $STARTRECORD{$section}=$value; next; }
		if ($line =~ /^ENDRECORD/)            	{ $ENDRECORD{$section}=$value; next; }
		if ($line =~ /^STARTSOURCEBIS/)	       	{ $STARTSOURCEBIS{$section}=$value; next; }
		if ($line =~ /^ENDSOURCEBIS/)          	{ $ENDSOURCEBIS{$section}=$value; next; }
		if ($line =~ /^STARTDATE/)	         	{ $STARTDATE{$section}=$value; next; }
		if ($line =~ /^FORMATDATE/)            	{ $FORMATDATE{$section}=$value; next; }
		if ($line =~ /^ENDDATE/)            	{ $ENDDATE{$section}=$value; next; }
		if ($line =~ /^TITLERECORDIS/)   		{ $TITLERECORDIS{$section}=$value; next; }
	}
	close CONFIG;
}


sub Get_Page()
{
	my $url = shift(@_); 

#	if ($url =~ /google/) {
#		my $key='IGcByytQFHKAgMRdu8ErL8eQxDTStjg2';
#		$url =~ /q=([^&]+)/;
#		my $kewords=$1;
#		use WWW::Search;
#		my $search = WWW::Search->new('Google', key => $key);
#		$search->native_query($keywords);
#		while (my $result = $search->next_result()) {
#    		print $result->title, "\n";
#    		print $result->url, "\n";
#    		print $result->description, "\n";
#    		print "\n";
#		}
#		return $result
#	}

	# Def of $HTTPheader $HTTPua $HTTPcookie
	my $HTTPua = LWP::UserAgent->new();
	my $HTTPcookie = HTTP::Cookies->new(file=>"cookies$$.dat");
	$HTTPua->agent('Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)');
	if ($TIMEOUT) { $HTTPua->timeout($TIMEOUT); }
	if ($MaxSize) { $HTTPua->max_size($MaxSize); }
	if ($PROXYSERVER) {
		# set proxy for access to external sites
		$HTTPua->proxy(["http","https"],$PROXYSERVER);
		# avoid proxy for these hosts
		$HTTPua->no_proxy(@HOSTSNOPROXY);
	}

	my $HTTPheader = new HTTP::Headers(
		Accept => '*/*',
		Accept-Language => 'fr,en-us;q=0.5',
		Accept-Encoding => 'gzip, deflate',
		User-Agent => 'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1)',
		Connection => 'Keep-Alive',
		Cookie => 'PREF=ID=01a4f5d1167a29cb:TB=2:LR=lang_en|lang_fr:LD=en:NR=30:NW=1:CR=1:TM=1064533436:LM=1067810537:S=YkTfGDlV5sTbvdcc'
	);  
	if ($USER) { $HTTPheader->authorization_basic($USER,$PASSWORD); }

	my $request; my $response;

	print LOGFILE "$url\n";
	$request = HTTP::Request->new(GET => $url, $HTTPheader);
	#print $request->as_string();
	$HTTPcookie->add_cookie_header($request);
	$response = $HTTPua->request($request);
	$HTTPcookie->extract_cookies($response);
	#print $response->as_string();

	if ($response->is_error())
	{
		$response->error_as_HTML();
		$HTTPResponseWithHeader=$HTTPResponse=$response->status_line;
		$HTTPResponse='';
		print LOGFILE "Error: $HTTPResponseWithHeader\n";
		return '';
	}

	$HTTPResponseWithHeader=$response->as_string();
	$HTTPResponse=$response->content();

	return $HTTPResponse;
}

#------------------------------------------------------------------------------
# Function:     Prend une chaine date en parametre et la retourne au format "DD/MM/YYYY"
# Parameters:	date string (Ex: 1 jan 02, 1 janvier 2002, 31/12 31/12/2002, 31-12-2002, 2002-12-31, ...)
# Input:        None
# Output:		None
# Return:		date with format "DD/MM/YYYY" or "" if error
#------------------------------------------------------------------------------
sub CorrigeDate {
	my $date=shift;
	$date =~ tr/ \t\\\/\./\-\-\-\-\-/s;
	$date =~ tr/O/0/;		# Replace "O" by "0"
	my ($date1,$date2,$date3)=split(/-/,$date,3);
	# Correct date parts
	my %MonthNumLong = ("janvier","01","fevrier","02","mars","03","avril","04","mai","05","juin","06","juillet","07","aout","08","septembre","09","octobre","10","novembre","11","decembre","12");
	my %MonthNumShort = ("jan","01","fev","02","mar","03","avr","04","mai","05","jui","06","jui","07","aou","08","sep","09","oct","10","nov","11","dec","12");
	if ($date2 !~ /^\d+$/) {
		if ($MonthNumLong{lc($date2)}) { $date2=$MonthNumLong{lc($date2)}; }
		elsif ($MonthNumShort{lc(substr($date2,0,3))}) { $date2=$MonthNumShort{lc(substr($date2,0,3))}; }
	}
	if (! $date3) { $date3="$nowyear"; }

	if ($date1 !~ /^\d{1,4}$/)  { return ""; }
	if ($date2 !~ /^\d{1,2}$/) { return ""; }
	if ($date3 !~ /^\d{1,4}$/) { return ""; }

	if ($date1 > 1900) { return sprintf("%02s/%02s/%04s",$date3,$date2,$date1); };

	if ($date3 < 50) { $date3="20$date3"; }
	if ($date3 >= 50 && $date3 < 100) { $date3="19$date3"; }
	return sprintf("%02s/%02s/%04s",$date1,$date2,$date3);
}



#-------------------------------------------------------
# MAIN
#-------------------------------------------------------

if ($ENV{"GATEWAY_INTERFACE"} ne "") {
	print("Content-type: text/html\n\n\n");
	$QueryString = $ENV{"QUERY_STRING"};
	$QueryString =~ s/<script.*$//i;					# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $LocalSite=$QueryString; $LocalSite =~ s/.*site=//; $LocalSite =~ s/&.*//; $LocalSite =~ s/ .*//; }
	if ($QueryString =~ /conf=/) { $LocalSite=$QueryString; $LocalSite =~ s/.*conf=//; $LocalSite =~ s/&.*//; $LocalSite =~ s/ .*//; }
	}
else {
	$QueryString=""; for (0..@ARGV-1) { $QueryString .= "$ARGV[$_] "; }
	$QueryString =~ s/<script.*$//i;					# This is to avoid 'Cross Site Scripting attacks'
	if ($QueryString =~ /site=/) { $LocalSite=$QueryString; $LocalSite =~ s/.*site=//; $LocalSite =~ s/&.*//; $LocalSite =~ s/ .*//; }
	if ($QueryString =~ /conf=/) { $LocalSite=$QueryString; $LocalSite =~ s/.*conf=//; $LocalSite =~ s/&.*//; $LocalSite =~ s/ .*//; }
	}
($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$LocalSite =~ tr/A-Z/a-z/;
$LocalSiteWithoutwww = $LocalSite; $LocalSiteWithoutwww =~ s/www\.//;
if (($ENV{"GATEWAY_INTERFACE"} eq "") && ($LocalSite eq "")) {
	print "----- $PROG $VERSION -----\n";
	print "Usage: $PROG conf=configid [section=x]\n";
	exit 0;
}

# Get current time
($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday,$nowisdst) = localtime(time);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }

# Read config file
#----------------------------
$DirConfig="$DIR"; $DirLog="."; $DirNews=".";	# Default values
&Read_Config_File;
if ($QueryString =~ /section=/i) { $Section=$QueryString; $Section =~ s/.*section=//; $Section =~ s/&.*//;  $Section =~ s/ .*//; }

open(LOGFILE,">$DIR/$DirLog/$PROG.log");
binmode LOGFILE;
print LOGFILE "----- $PROG $VERSION -----\n";


# Init array of existing news
#----------------------------
&Read_Existing_News;	


# Get news for each section in one news array
#--------------------------------------------
$i=0;
foreach $section (sort keys %URL_TO_SCAN) {
	if ($Section && ($section ne $Section)) { next; }
	print LOGFILE "\n";
	print LOGFILE "PROCESSING SECTION $section - SOURCE=$SOURCE{$section} URL=$URL_TO_SCAN{$section}\n";
	print LOGFILE "URL_TO_SCAN=$URL_TO_SCAN{$section}\n";
	print LOGFILE "URL_TO_LINK=$URL_TO_LINK{$section}\n";
	print LOGFILE "STARTDATA=$STARTDATA{$section}\n";
	print LOGFILE "ENDDATA=$ENDDATA{$section}\n";
	print LOGFILE "STARTRECORD=$STARTRECORD{$section}\n";
	print LOGFILE "ENDRECORD=$ENDRECORD{$section}\n";
	if ($URL_TO_SCAN{$section} eq "NA") { print LOGFILE "Not authorized source\n"; next; }	
	print "Processing Section $section - SOURCE=$SOURCE{$section} URL=$URL_TO_SCAN{$section}\n";

	# Download page
	$content = &Get_Page($URL_TO_SCAN{$section});
	if (! $content) { print LOGFILE "Error in downloading page $URL_TO_SCAN{$section}\n"; next; }
	if ($SOURCEISUTF8{$section}) {
		#print LOGFILE "Decode UTF8 content\n";
		#use Encode;
		#$content=decode_utf8($content);
	}
	print LOGFILE "Content of return page:\n$content\n";

	# Traitement de la page
	$content =~ tr/ \t/  /s;
	$content =~ tr/\n/ /s;
	$content =~ tr/\r/ /s;
	# Supprime le début de page inutile
	if ($STARTDATA{$section}) {
		if ($content !~ s/.*$STARTDATA{$section}//gi) {
			print " Error: Enable to find STARTDATA section in page.\n";		
			print LOGFILE " Error: Enable to find STARTDATA section in page.\n";
            next;
		}
	}
	# Supprime la fin de page inutile
	if ($ENDDATA{$section}) {
		$content =~ s/$ENDDATA{$section}.*//gi;
	}			
	# Marque les débuts et fin d'enregistrement
	$content =~ s/($STARTRECORD{$section})/\n¥R\[¥$1/gi;
	if ($ENDRECORD{$section}) {
		$content =~ s/($ENDRECORD{$section})/$1¥\]R¥\n/gi;
	}

	# Marque les débuts et fin de date
	if ($STARTDATE{$section}) {
		$content =~ s/($STARTDATE{$section})/$1¥D\[¥/gi;
		if ($ENDDATE{$section}) {
			$content =~ s/($ENDDATE{$section})/¥\]D¥$1/gi;
		}
	}

	# Marque les débuts et fin de source bis
	if ($STARTSOURCEBIS{$section}) {
		$content =~ s/($STARTSOURCEBIS{$section})/$1¥S\[¥/gi;
		if ($ENDSOURCEBIS{$section}) {
			$content =~ s/($ENDSOURCEBIS{$section})/¥\]S¥$1/gi;
		}
	}
	
	# Replace link <a href= by ¥% and </a> by %¥
	$content =~ s/"//g;
	$content =~ s/<a href=/¥L\[¥/gi; $content =~ s/<\/a>/¥\]L¥/gi;

	# Remove all HTML start and end tags
	$content =~ s/<[ -=|?-~]*>//g;		
	$content =~ s/<\/[A-z]*>//g;
	$content =~ tr/ \t/  /s;

	print LOGFILE "HTML Page extracted and reformated is:\n";
	print LOGFILE "$content\n";

	# Loop on each news record in downloaded page
	@felter=split(/¥R\[¥/,$content);
	my $firstpart=1; my $i=1;
	foreach my $elem (@felter) {
		if ($firstpart) { $firstpart=0; next; }		# Ignore first part (before the ¥R\[¥)
		chomp $elem;
		$elem =~ s/¥\]R¥.*//g;
		my $newsisok=0;
		# Check if news is qualified
		if ($USEKEYWORDS{"$section"}) {
			# News doit respecter un critère de recherche
			foreach $keyword (@KEYWORDS) { 
				if ($elem !~ /$keyword/i) { next; }
				else { $newsisok=1; }
			}
		}
		else { $newsisok=1; }
		# If news is qualified
		if ($newsisok) {
			print " Record is qualified (news nb $i).\n";
			# Define source
			$newssource{"$i"}=$SOURCE{"$section"};
			$newssource{"$i"} =~ s/^ *//; $newssource{"$i"} =~ s/ *$//;
			if ($STARTSOURCEBIS{$section} && $ENDSOURCEBIS{$section}) {
				$newssource{"$i"}=$elem; $newssource{"$i"} =~ s/.*¥S\[¥//g; $newssource{"$i"} =~ s/¥\]S¥.*//g;
				$newssource{"$i"} =~ s/^ *//; $newdate{"$i"} =~ s/ *$//;
			}
			# Define link
			$newslink{"$i"}=$elem; $newslink{"$i"} =~ s/.*¥L\[¥//g; $newslink{"$i"} =~ s/[ |>].*//g; $newslink{"$i"}=$URL_TO_LINK{"$section"}.$newslink{"$i"};
			$newslink{"$i"} =~ s/^ *//; $newslink{"$i"} =~ s/ *$//;
			# Define desc
			$newsdesc{"$i"}=$elem; $newsdesc{"$i"} =~ s/¥L\[¥.*¥\]L¥//g;
			if ($STARTDATE{$section} && $ENDDATE{$section}) { $newsdesc{"$i"}=~s/($STARTDATE{$section})?¥D\[¥.*¥\]D¥($ENDDATE{$section})?//g; }
			if ($STARTSOURCEBIS{$section} && $ENDSOURCEBIS{$section}) { $newsdesc{"$i"}=~s/($STARTSOURCEBIS{$section})?¥S\[¥.*¥\]S¥($ENDSOURCEBIS{$section})?//g; }
			$newsdesc{"$i"} =~ s/^ *//; $newsdesc{"$i"} =~ s/ *$//;
 			if ($newsdesc{"$i"} !~ /\.\.\.$/) { $newsdesc{"$i"} .= "..."; }
 			# Define title
			$newstitre{"$i"}=$elem;	$newstitre{"$i"} =~ s/.*>//g; $newstitre{"$i"} =~ s/¥\]L¥.*//g;
			$newstitre{"$i"} =~ s/^ *//; $newstitre{"$i"} =~ s/ *$//;
			if (! $newstitre{"$i"} || ($TITLERECORDIS{$section} eq 'url')) {
				$newstitre{"$i"}=$elem;	$newstitre{"$i"} =~ s/.*¥L\[¥.*>//g; $newstitre{"$i"} =~ s/¥\]L¥.*//g;
				$newstitre{"$i"} =~ s/^ *//; $newstitre{"$i"} =~ s/ *$//;
			}
			if (! $newstitre{"$i"} || ($TITLERECORDIS{$section} eq 'desc')) {
				$newstitre{"$i"}=$newsdesc{"$i"};
				$newstitre{"$i"} =~ s/^(........................................).*/$1/;
				$newstitre{"$i"} .= "...";
			}
			# Define date
			if ($STARTDATE{$section} && $ENDDATE{$section}) {
				$newsdate{"$i"}=$elem; $newsdate{"$i"} =~ s/.*¥D\[¥//g; $newsdate{"$i"} =~ s/¥\]D¥.*//g;
				$newsdate{"$i"} =~ s/^ *//; $newdate{"$i"} =~ s/ *$//;
				if ($FORMATDATE{$section}) {
					$newsdate{"$i"} =~ /($FORMATDATE{$section})/;
					$newsdate{"$i"} = &CorrigeDate($1);
				}
			}
			$newsdate{"$i"}||="$nowday/$nowmonth/$nowyear";
			# Define delai
			$newsdelai{"$i"}="30";
			print "  For i=$i, Date='".$newsdate{"$i"}."' Titre='".$newstitre{"$i"}."'\n";
			$i++;
		}
	}
}

# Write news files from new news array
#----------------------------------------
print "Writing news files.\n";
print LOGFILE "\nWriting news files.\n";
foreach my $cpt (keys %newslink) {
	# Check if news $newsxxx{$cpt} already exists
	my $newsalreadyexist=0;
	foreach my $cpt2 (keys %{$ExistingNews{"NEWS_TITLE"}} ) {
		#print "X $cpt2 ".$ExistingNews{"NEWS_TITLE"}{$cpt2}." - $cpt $newslink{$cpt} $newstitre{$cpt} X\n";
		if (($newstitre{$cpt} eq $ExistingNews{"NEWS_TITLE"}{$cpt2}) ||
			 (length($newstitre{$cpt}) > 20 && $ExistingNews{"NEWS_TITLE"}{$cpt2} =~ /$newstitre{$cpt}/)) {
			print " News with title '$newstitre{$cpt}' already exists.\n";
			$newsalreadyexist=1;
			last;
		}
		if ($newsdesc{$cpt} eq $ExistingNews{"NEWS_TEXT"}{$cpt2}) {
			print " News with text '$newstitre{$cpt}' already exists.\n";
			$newsalreadyexist=1;
			last;
		}
	}
	if ($newsalreadyexist) { next; }

	$newsdate{$cpt} =~ /(\d\d)\/(\d\d)\/(\d\d\d\d)/;
	my ($ye,$mo,$da)=($3,$2,$1);

	# Get a not used prefix value
	my $prefix=1;
	TOTO:
	foreach my $cpt2 (keys %{$ExistingNews{"FILE_NAME"}} ) {
		if ($ExistingNews{"FILE_NAME"}{$cpt2} eq "news$ye$mo${da}_$prefix.txt") { $prefix++; goto TOTO; }
	}
	# Save new news to a file and add it to ExistingNews and FileTimeToDelete hash array
	my $max=0; foreach my $key (scalar keys %FileTimeToDelete) { if ($max < $key) { $max=$key; } }
	$newnews=$max+1;
	print " Building News file numero $newnews : news$ye$mo${da}_$prefix.txt, TITLE=$newstitre{$cpt}\n";
	print LOGFILE " Building News file numero $newnews : news$ye$mo${da}_$prefix.txt, TITLE=$newstitre{$cpt}\n";
	open(NEWSFILE,">$DIR/$DirNews/news$ye$mo${da}_$prefix.txt") || error("Couldn't open file $DirNews/news$ye$mo${da}_$prefix.txt: $!");
	binmode NEWSFILE;
	print NEWSFILE "NEWS_SOURCE=$newssource{$cpt}\n"; $ExistingNews{"NEWS_SOURCE"}{$newnews}=$newssource{$cpt};
	print NEWSFILE "NEWS_TITLE=$newstitre{$cpt}\n"; $ExistingNews{"NEWS_TITLE"}{$newnews}=$newstitre{$cpt};
	print NEWSFILE "NEWS_URL=$newslink{$cpt}\n"; $ExistingNews{"NEWS_URL"}{$newnews}=$newslink{$cpt};
	print NEWSFILE "NEWS_DATE=$newsdate{$cpt}\n"; $ExistingNews{"NEWS_DATE"}{$newnews}=$newsdate{$cpt};
	print NEWSFILE "NEWS_DELAY_PURGE=$newsdelai{$cpt}\n"; $ExistingNews{"NEWS_DELAY_PURGE"}{$newnews}=$newsdelai{$cpt};
	print NEWSFILE "$newsdesc{$cpt}\n"; $ExistingNews{"NEWS_TEXT"}{$newnews}=$newsdesc{$cpt};
	$ExistingNews{"FILE_NAME"}{$newnews}="news$ye$mo${da}_$prefix.txt";
	$FileTimeToDelete{$newnews}="99999999999";
	close(NEWSFILE);
}

# Choose last news (sorted on delete time) and generate news module
#-------------------------------------------------------------------
print "Building $DirJS/$FileJS (Choose $NBOFNEWS news maximum)\n";
print LOGFILE "\nBuilding $DirJS/$FileJS (Choose $NBOFNEWS news maximum)\n";

open(NEWSMODULE,">$DIR/$DirJS/$FileJS") || error("Couldn't open file $DirJS/$FileJS: $!");
binmode NEWSMODULE;
print NEWSMODULE "var urlstring=String(window.location);\n\n";

if ($TEXTHEADER) {
	print NEWSMODULE "document.writeln('$TEXTHEADER');\n";
}

$cpt=0;
foreach my $i (sort { $FileTimeToDelete{$b} <=> $FileTimeToDelete{$a} } keys ( %FileTimeToDelete )) {
	print " Choosed news numero $i - ".$ExistingNews{"FILE_NAME"}{$i}." - TITLE=".$ExistingNews{"NEWS_TITLE"}{$i}."\n";
	print LOGFILE " Choosed news numero $i - ".$ExistingNews{"FILE_NAME"}{$i}." - TITLE=".$ExistingNews{"NEWS_TITLE"}{$i}."\n";
	my $title=$ExistingNews{"NEWS_TITLE"}{$i}; $title =~ s/'/\\'/g;
	my $source=$ExistingNews{"NEWS_SOURCE"}{$i}; $source=~ s/'/\\'/g;
	my $text=$ExistingNews{"NEWS_TEXT"}{$i}; $text =~ s/'/\\'/g;
	
	print NEWSMODULE "document.writeln('<div class=\"CNewsTitle\"><font style=\"color: #5D466F; font: 14px verdana,arial; font-weight:bold; font-family: sans-serif; }\">');\n";
	print NEWSMODULE "document.writeln('<a href=\"".$ExistingNews{"NEWS_URL"}{$i}."\" target=news>$title</a></font><br>');\n";
	print NEWSMODULE "document.writeln('$source - ".$ExistingNews{"NEWS_DATE"}{$i}."</div>');\n";
	print NEWSMODULE "document.writeln('<div class=\"CNewsBody\">$text</div>');\n";
	if ((++$cpt) >= $NBOFNEWS) { last; }
}
if (! $cpt) {
	print NEWSMODULE "document.writeln('Aucune nouvelle récente.');";
}

close(NEWSMODILE);
close(LOGFILE);

0;
