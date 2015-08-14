#!/usr/bin/perl
# /index.cgi
# Theme "eldy"

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



if ( $np eq 'right' )
{
&PrintHeader();
print "<!doctype html public \"-//W3C//DTD HTML 3.2 Final//EN\">\n";
print "<html><head><title>",&text('main_title', $ver, $hostname, $ostr),"</title></head>\n";
print "<frameset framespacing=0 border=0 cols=*,230 frameborder=0>\n";
print "<frame name=Hauptframe src=smartstart.cgi>\n";
print "<frame name=Inhalt target=Hauptframe src=nav.cgi>\n";
print "</frameset></html>\n";
}
else
{
&PrintHeader();
print "<html><head><title>",&text('main_title', $ver, $hostname, $ostr),"</title></head>\n";
print "<frameset framespacing=0 border=0 cols=230,* frameborder=0>\n";
print "<frame name=Inhalt target=Hauptframe src=nav.cgi>\n";
print "<frame name=Hauptframe src=smartstart.cgi>\n";
print "</frameset></html>\n";
}

