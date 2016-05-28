#!/usr/bin/perl

BEGIN { push(@INC, ".."); };
use WebminCore;
&init_config();
require 'theme_eldy/theme-lib.pl';
&init_theme2();

my $urldir=$gconfig{'webprefix'};
if ($urldir && $urldir !~ /[\\\/]$/) { $urldir.='/'; }


&init_config();
$hostname = &get_system_hostname();
$ver = &get_webmin_version();
if ($gconfig{'real_os_type'}) {
	$ostr = "$gconfig{'real_os_type'} $gconfig{'real_os_version'}";
	}
else {
	$ostr = "$gconfig{'os_type'} $gconfig{'os_version'}";
	}
&ReadParse();

local $smart_user = $ENV{'REMOTE_USER'};
local $smart_ip = $ENV{'HTTP_X_FORWARDED_FOR'} ? $ENV{'HTTP_X_FORWARDED_FOR'} : $ENV{'REMOTE_ADDR'};
my ($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear,$nowwday,$nowyday) = localtime();
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
my $nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
++$nowmonth;
local $smart_time = sprintf("%04d-%02d-%02d %02d:%02d",$nowyear,$nowmonth,$nowday,$nowhour,$nowmin);

# Redirect if the user has only one module
@modules = &get_available_module_infos()
	if (! @modules);
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


&header(undef,undef,undef,0,1,1);

my $cpuname=`egrep "^model name" /proc/cpuinfo`;
$cpuname =~ s/model\sname\s+:\s+//i;
my $cpuspeed=`egrep "^cpu MHz" /proc/cpuinfo`;
$cpuspeed =~ s/cpu\sMHz\s+:\s+//i;
my $totalmem=`egrep "^MemTotal" /proc/meminfo`;
$totalmem =~ s/MemTotal:\s+//i;
my $uptime=`w 2>/dev/null`;
$uptime =~ s/up\s+([\w,:]+\s+[\w,:]+\s+[\w:]+)//i;
$uptime = $1;

# Affichage bandeau infos
my $appli='Webmin';
if ($gconfig{'userconfig'}) { $appli="Usermin"; }	# usermin specific stuff

print <<EOF;
<table border="0" width="100%">
<tr $tb>
<td $tb colspan="4" width="66%"><b>System Information</b></td>
<td $tb colspan="2" width="34%"><b>User Info</b></td>
</tr>
<tr $cb>
<td $cb nowrap><b>OS:</b></td>
<td $cb>$ostr</td>
<td $cb nowrap><b>CPU type</b></td>
<td $cb>$cpuname</td>
<td $cb nowrap><b>User:</b></td>
<td $cb>$smart_user</td>
</tr>
<tr $cb>
<td $cb nowrap><b>$appli&nbsp;version:</b></td>
<td $cb>$ver</td>
<td $cb nowrap><b>CPU speed</b></td>
<td $cb>$cpuspeed</td>
<td $cb nowrap><b>Remote IP:</b></td>
<td $cb>$smart_ip</td>
</tr>
<tr $cb>
<td $cb><b>Hostname:</b></td>
<td $cb>$hostname</td>
<td $cb><b>Memory</b></td>
<td $cb>$totalmem</td>
<td $cb>&nbsp;</td>
<td $cb>&nbsp;</td>
</tr>
<tr $cb>
<td $cb><b>Time:</b></td>
<td $cb>$smart_time</td>
<td $cb><b>Up time</b></td>
<td $cb>$uptime</td>
<td $cb>&nbsp;</td>
<td $cb>&nbsp;</td>
</tr>
</table>
<br>
EOF


print <<EOF;
<center>
<TABLE border="0" width="100%">
EOF


foreach $c (@cats) {
	print "<tr $tb align=\"center\"><td colspan=\"3\" $tb><b>$cats{$c}</b></td></tr>\n";
	$pos = 0;
	$cols = $gconfig{'nocols'} ? $gconfig{'nocols'} : 3;
	$per = 100.0 / $cols;
	foreach $m (@modules) {
		next if ($m->{'category'} ne $c);
		if ($pos % $cols == 0) { print "<tr $cb>\n"; }
		print "<td $cb align=left width=33%><img src=$m->{'dir'}/images/icon.gif alt=\"\" border=0 width=\"24\" height=\"24\"></a> &nbsp; <A TARGET=Hauptframe HREF=$m->{'dir'}/ >$m->{'desc'}</A></td>\n";
		if ($pos++ % $cols == $cols - 1) { print "</tr>\n"; }
	}
	if ($pos % $cols != 0 ) {
		foreach my $i (1..($cols - ($pos % $cols))) { print "<td $cb>&nbsp;</td>\n"; }
		print "</tr>\n";
	}
}


print <<EOF;
</table>
<br>
EOF

print <<EOF;
</blockquote>
</BODY>
</HTML>
EOF

