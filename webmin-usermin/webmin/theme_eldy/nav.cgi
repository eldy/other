#!/usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();

require 'theme_eldy/theme-lib.pl';
&init_theme2();

my $urldir=$gconfig{'webprefix'};
if ($urldir && $urldir !~ /[\\\/]$/) { $urldir.='/'; }


$hostname = &get_system_hostname();
$ver = &get_webmin_version();
if ($gconfig{'real_os_type'}) {
	$ostr = "$gconfig{'real_os_type'} $gconfig{'real_os_version'}";
	}
else {
	$ostr = "$gconfig{'os_type'} $gconfig{'os_version'}";
	}
&ReadParse();

# Redirect if the user has only one module
@modules = &get_available_module_infos()
	if (! @modules));
if (@modules == 1 && $gconfig{'gotoone'}) {
	&redirect("$modules[0]->{'dir'}/");
    exit;
    }

foreach $m (@modules) {
	$c = $m->{'category'};
	next if ($cats{$c});
	if ($text{"category_$c"}) {
		$cats{$c} = $text{"category_$c"};
		}
	else {
		# try to get category name from module ..
		local %mtext = &load_language($m->{'dir'});
		if ($mtext{"category_$c"}) {
			$cats{$c} = $mtext{"category_$c"};
			}
		else {
			$c = $m->{'category'} = "";
			$cats{$c} = $text{"category_$c"};
			}
		}
	}
@cats = sort { $b cmp $a } keys %cats;
$cats = @cats;
$per = $cats ? 100.0 / $cats : 100;
if (!defined($in{'cat'})) {
	# Use default category
	if (defined($gconfig{'deftab'})) {
		$in{'cat'} = $gconfig{'deftab'};
		}
	else {
		$in{'cat'} = $cats[0];
		}
	}
elsif (!$cats{$in{'cat'}}) {
	$in{'cat'} = "";
	}

# Pruefen ob CSS verwendet werden soll

$cssfile="<link href=\"theme_nav.css\" rel=\"stylesheet\" type=\"text/css\" />";

# Anzeigen lassen des Hauptmen�s
&PrintHeader();
print <<EOF;
<!doctype html public \"-//W3C//DTD HTML 3.2 Final//EN\">
<HTML>
<HEAD>
$cssfile
</HEAD>
EOF
 
print "<BODY class=\"BODYL\" topmargin=0 leftmargin=0 marginhight=0 marginwidth=0>\n";

my $logo="newlogo.gif";
if ($gconfig{'userconfig'}) { $logo="usermin.gif"; }	# usermin specific stuff

print "<center><br><a target=\"Hauptframe\" href=\"smartstart.cgi\"><IMG BORDER=0 SRC='images/$logo' width=80 /></a><br>\n";
if ($main::session_id)	{
	print "<a href='session_login.cgi?logout=1' target=\"_top\">","$text{'main_logout'}</a>\n";
			}
else {
	print "<a href=switch_user.cgi target=\"_top\">","$text{'main_switch'}</a>\n";
	}
print "</center>\n";
print "<br>\n";
print "\n";


#print "<TABLE BORDER=\"0\" CELLPADDING=\"0\" CELLSPACING=\"0\" WIDTH=\"100%\">\n";
#print "<TR><TD><b><a target=\"Hauptframe\" href=\"smartstart.cgi\">Main menu</a></td></tr>\n";  
print "<b><a target=\"Hauptframe\" href=\"smartstart.cgi\">Main menu</a><br>\n";  
my $catpos=0;
foreach $c (@cats) {
	if ($catpos == 0) {
		print "<img align=\"top\" src=\"${urldir}theme_eldy/images/lev2c.gif\" border=0><br>\n";
#		print "<TR><TD><img src=\"theme_eldy/images/lev2c.gif\" border=0></td></tr>\n";
	}
	$catpos++;
	if ($in{'cat'} eq $c) {
		if ($catpos < (scalar @cats)) {
			print "<img align=\"top\" src=\"${urldir}theme_eldy/images/lev2.gif\" border=0> <b>$cats{$c}</b><br>\n";
#			print "<TR><TD><img src=\"theme_eldy/images/lev2.gif\" border=0><b><FONT color=$namf>&nbsp; $cats{$c}</b></TD></TR>\n";
		}
		else {
			print "<img align=\"top\" src=\"${urldir}theme_eldy/images/lev2b.gif\" border=0> <b>$cats{$c}</b><br>\n";
#			print "<TR><TD><img src=\"theme_eldy/images/lev2b.gif\" border=0><b><FONT color=$namf>&nbsp; $cats{$c}</b></TD></TR>\n";
		}
		my $nbmod=0;
		foreach my $m (@modules) {
			if ($m->{'category'} eq $in{'cat'}) { $nbmod++; }
		}
		my $modpos=0;
		foreach $m (@modules) {
			next if ($m->{'category'} ne $in{'cat'});
			my $desc=$m->{'desc'};
			if (length($desc) > 24) { $desc=substr($desc,0,22)."..."; }
			my $img='';
			if ($modpos < ($nbmod-1)) { $img='lev3'; if ($catpos == (scalar @cats)) { $img='lev3d'; } }
			else { $img='lev3b'; if ($catpos == (scalar @cats)) { $img='lev3c'; } }
#				print "<TR><TD WIDTH=100% nowrap><A TARGET=Hauptframe HREF=/$m->{'dir'}/ ><FONT color=$nsfc><li> $m->{'desc'} </li></FONT></A></TD></tr>\n";
			print "<img align=\"top\" src=\"${urldir}theme_eldy/images/$img.gif\" border=0> <A TARGET=Hauptframe HREF=$m->{'dir'}/ >$desc</A><br>\n";
			$modpos++;
		}
	}
	else {
		if ($catpos < (scalar @cats)) {
			print "<img align=\"top\" src=\"${urldir}theme_eldy/images/lev2.gif\" border=0> <b><A TARGET=Inhalt HREF='nav.cgi?cat=$c'>$cats{$c}</A></b><br>\n";
#			print "<TR><TD><img src=\"theme_eldy/images/lev2.gif\" border=0><b><A TARGET=Inhalt HREF='nav.cgi?cat=$c'><FONT color=$nmmf> $cats{$c}</A></b></TD></TR>\n";
		}
		else {
			print "<img align=\"top\" src=\"${urldir}theme_eldy/images/lev2b.gif\" border=0> <b><A TARGET=Inhalt HREF='nav.cgi?cat=$c'><FONT color=$nmmf> $cats{$c}</A></b><br>\n";
#			print "<TR><TD><img src=\"theme_eldy/images/lev2b.gif\" border=0><b><A TARGET=Inhalt HREF='nav.cgi?cat=$c'><FONT color=$nmmf> $cats{$c}</A></b></TD></TR>\n";
		}
	}
}
#print "</TABLE>\n";

print <<EOF;

</BODY>
</HTML>
EOF

