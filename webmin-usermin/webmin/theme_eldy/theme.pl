#!/usr/bin/perl

#theme_prebody - called just before the main body of every page, so it can print any HTML it likes.
#theme_postbody - called just after the main body of every page.
#theme_header - called instead of the normal header function, with the same parameters. You could use this to re-write the header function in your own style with help and index links whereever you want them.
#theme_footer - called instead of the footer function with the same parameters.
#theme_error - called instead of the error function, with the same parameters.


sub theme_header {

print "<!doctype html public \"-//W3C//DTD HTML 3.2 Final//EN\">\n";
print "<html>\n";
local $os_type = $gconfig{'real_os_type'} ? $gconfig{'real_os_type'}
					  : $gconfig{'os_type'};
local $os_version = $gconfig{'real_os_version'} ? $gconfig{'real_os_version'}
					        : $gconfig{'os_version'};
print "<head>\n";
if ($charset) {
	print "<meta http-equiv=\"Content-Type\" ",
	      "content=\"text/html; Charset=$charset\">\n";
	}
if (@_ > 0) {
	if ($gconfig{'sysinfo'} == 1) {
		printf "<title>%s : %s on %s (%s %s)</title>\n",
			$_[0], $remote_user, &get_system_hostname(),
			$os_type, $os_version;
		}
	else {
		print "<title>$_[0]</title>\n";
		}
	print $_[7] if ($_[7]);
	if ($gconfig{'sysinfo'} == 0 && $remote_user) {
		print "<script language=JavaScript type=text/javascript>\n";
		printf
		"defaultStatus=\"%s%s logged into %s %s on %s (%s%s)\";\n",
			$ENV{'ANONYMOUS_USER'} ? "Anonymous user" :$remote_user,
			$ENV{'SSL_USER'} ? " (SSL certified)" :
			$ENV{'LOCAL_USER'} ? " (Local user)" : "",
			$text{'programname'},
			&get_webmin_version(), &get_system_hostname(),
			$os_type, $os_version eq "*" ? "" : " $os_version";
		print "</SCRIPT>\n";
		}
	}
print "$tconfig{'headhtml'}\n" if ($tconfig{'headhtml'});

if ($ENV{SCRIPT_NAME} =~ m'session_login\.cgi') {
        open(INC, "$root_directory/$current_theme/login.css");
        my $urldir=$gconfig{'webprefix'};
        if ($urldir && $urldir !~ /[\\\/]$/) { $urldir.='/'; }
        while(<INC>) {
        $_ =~ s/theme_eldy\/images/${urldir}theme_eldy\/images/g;
                print $_;
                }
        close(INC);
}
else
{
if ($tconfig{'headinclude'}) {
	open(INC, "$root_directory/$current_theme/$tconfig{'headinclude'}");
	my $urldir=$gconfig{'webprefix'};
	if ($urldir && $urldir !~ /[\\\/]$/) { $urldir.='/'; }
	while(<INC>) {
        $_ =~ s/theme_eldy\/images/${urldir}theme_eldy\/images/g;
		print $_;
		}
	close(INC);
}
}
print "</head>\n";
local $bgcolor = defined($tconfig{'cs_page'}) ? $tconfig{'cs_page'} :
		 defined($gconfig{'cs_page'}) ? $gconfig{'cs_page'} : "ffffff";
local $link = defined($tconfig{'cs_link'}) ? $tconfig{'cs_link'} :
	      defined($gconfig{'cs_link'}) ? $gconfig{'cs_link'} : "0000ee";
local $text = defined($tconfig{'cs_text'}) ? $tconfig{'cs_text'} : 
	      defined($gconfig{'cs_text'}) ? $gconfig{'cs_text'} : "000000";
local $bgimage = defined($tconfig{'bgimage'}) ? "background=$tconfig{'bgimage'}"
					      : "";
print "<body bgcolor=#$bgcolor link=#$link vlink=#$link text=#$text ",
      "$bgimage $tconfig{'inbody'} $_[8]>\n";
local $hostname = &get_system_hostname();
local $version = &get_webmin_version();
local $prebody = $tconfig{'prebody'};
if ($prebody) {
	$prebody =~ s/%HOSTNAME%/$hostname/g;
	$prebody =~ s/%VERSION%/$version/g;
	$prebody =~ s/%USER%/$remote_user/g;
	$prebody =~ s/%OS%/$os_type $os_version/g;
	print "$prebody\n";
	}
if ($tconfig{'prebodyinclude'}) {
	open(INC, "$root_directory/$current_theme/$tconfig{'prebodyinclude'}");
	while(<INC>) {
        my $line=$_;
        my $new=($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"");
        $line =~ s/$current_theme\/images/$new\/$current_theme\/images/g;
        print $line;
		}
	close(INC);
	}
if (defined(&theme_prebody)) {
	&theme_prebody(@_);
	}
if (@_ > 1) {
	print "<table width=100%><tr>\n";
	if ($gconfig{'sysinfo'} == 2 && $remote_user) {
		print "<td colspan=4 align=center>\n";			# ELDY
		printf "%s%s logged into %s %s on %s (%s%s)</td>\n",
			$ENV{'ANONYMOUS_USER'} ? "Anonymous user" : "<tt>$remote_user</tt>",
			$ENV{'SSL_USER'} ? " (SSL certified)" :
			$ENV{'LOCAL_USER'} ? " (Local user)" : "",
			$text{'programname'},
			$version, "<tt>$hostname</tt>",
			$os_type, $os_version eq "*" ? "" : " $os_version";
		print "</tr> <tr>\n";
		}
	if ($module_name) { print "<td wdith=48><img src=images/icon.gif></td>"; }	# ELDY
	print "<td width=15% valign=middle align=left>";	# ELDY
	if ($ENV{'HTTP_WEBMIN_SERVERS'}) {
		print "<a href='$ENV{'HTTP_WEBMIN_SERVERS'}'>",
		      "$text{'header_servers'}</a><br>\n";
		}
	if (!$_[5] && !$tconfig{'noindex'}) {
		local %acl;
		&read_acl(undef, \%acl);
		local $mc = @{$acl{$base_remote_user}} == 1;
		local $nolo = $ENV{'ANONYMOUS_USER'} ||
			      $ENV{'SSL_USER'} || $ENV{'LOCAL_USER'} ||
			      $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;
		if ($gconfig{'gotoone'} && $main::session_id && $mc == 1 &&
		    !$nolo) {
			print "<a href='".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"../")."session_login.cgi?logout=1'>",
			      "$text{'main_logout'}</a><br>";
			}
		elsif ($gconfig{'gotoone'} && $mc == 1 && !$nolo) {
			print "<a href=".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"../")."switch_user.cgi>",
			      "$text{'main_switch'}</a><br>";
			}
		else {
			print "<a target=_parent href='".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":($module_name?"../":""))."index.cgi?cat=$module_info{'category'}'>",	# ELDY Lien Webmin Index du haut
			      "$text{'header_webmin'}</a><br>\n";	
			}
		}
	if (!$_[4]) {
		local $mi = $module_index_link || "$module_name/";
		print "<a href=\"".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"../")."$mi\">",
		      "$text{'header_module'}</a><br>\n";
		}
	if (ref($_[2]) eq "ARRAY" && !$ENV{'ANONYMOUS_USER'}) {
		print &hlink($text{'header_help'}, $_[2]->[0], $_[2]->[1]),
		      "<br>\n";
		}
	elsif (defined($_[2]) && !$ENV{'ANONYMOUS_USER'}) {
		print &hlink($text{'header_help'}, $_[2]),"<br>\n";
		}
	if ($_[3]) {
		local %access = &get_module_acl();
		if (!$access{'noconfig'} && !$config{'noprefs'}) {
			local $cprog = $user_module_config_directory ?
					"uconfig.cgi" : "config.cgi";
			print "<a href=\"".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"../")."$cprog?$module_name\">",
			      $text{'header_config'},"</a><br>\n";
			}
		}
	print "</td>\n";
	local $title = $_[0];
	$title =~ s/&auml;/ä/g;
	$title =~ s/&ouml;/ö/g;
	$title =~ s/&uuml;/ü/g;
	$title =~ s/&nbsp;/ /g;
	if ($_[1]) {
		print "<td valign=middle align=center width=70%>",		# ELDY
		      "<img alt=\"$_[0]\" src=\"$_[1]\"></td>\n";
		}
	elsif ($current_lang_info->{'titles'} && !$gconfig{'texttitles'} &&
	       !$tconfig{'texttitles'}) {
		print "<td valign=middle align=center width=70%>";		# ELDY
		foreach $l (split(//, $title)) {
			$ll = ord($l);
			if ($ll > 127 && $current_lang_info->{'charset'}) {
				print "<img src=".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"")."images/letters/$ll.$current_lang_info->{'charset'}.gif alt=\"$l\" align=bottom>";
				}
			elsif ($l eq " ") {
				print "<img src=".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"")."images/letters/$ll.gif alt=\"\&nbsp;\" align=bottom>";
				}
			else {
				print "<img src=".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":"")."images/letters/$ll.gif alt=\"$l\" align=bottom>";
				}
			}
		print "<br>$_[9]\n" if ($_[9]);
		print "</td>\n";
		}
	else {
		print "<td valign=middle align=center width=70%>";
		if ($_[0]) { print "<font style=\"font-size:20px; font-weight: bold;\">$_[0]</font><br>\n"; }		# ELDY
		print "$_[9]\n" if ($_[9]);
		print "</td>\n";
		}
	print "<td width=15% valign=middle align=right>";	# ELDY
	print $_[6];
	print "</td></tr></table>\n";
	}
}


sub theme_footer {
	local $i;
	for($i=0; $i+1<@_; $i+=2) {
		local $url = $_[$i];

        local $target='';                   # ELDY
        if ($url ne '/' || !$tconfig{'noindex'}) {
#print "$gconfig{'webprefix'} url=$url module_name=$module_name";
            if ($module_name) {
                # if we are inside a module page
                if ($url eq '/') {                      # return must be on home
                    $target='target=_parent';           # ELDY
                    $url = "index.cgi?cat=$module_info{'category'}";
                    }
                elsif ($url && $url!~/$module_name/) {  # stay inside module
                    $url=$module_name."/";
                }
                elsif (! $url) {
                    $url = "$module_name";
                }
            }
            # if module path is not a relative path, we change this to relative path
            if ($url =~ /^\/$module_name/) {
                $url =~ s/^\///;
                }
            
            # build path
            $url=($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":($module_name?"../":""))."$url";
            
            # show left arraow
			if ($i == 0) {
				print "<a $target href=\"$url\"><img alt=\"<-\" align=middle border=0 src=".($gconfig{'webprefix'}?"$gconfig{'webprefix'}/":($module_name?"../":""))."images/left.gif></a>\n";
				}
			else {
				print "&nbsp;|\n";
				}
			# show link
			print "&nbsp;<a $target href=\"$url\">",&text('main_return', $_[$i+1]),"</a>\n";	# ELDY Bouton Return to index du bas de page
			}
		}
	print "<br>\n";
	if (!$_[$i]) {
		local $postbody = $tconfig{'postbody'};
		if ($postbody) {
			local $hostname = &get_system_hostname();
			local $version = &get_webmin_version();
			local $os_type = $gconfig{'real_os_type'} ?
					$gconfig{'real_os_type'} : $gconfig{'os_type'};
			local $os_version = $gconfig{'real_os_version'} ?
					$gconfig{'real_os_version'} : $gconfig{'os_version'};
			$postbody =~ s/%HOSTNAME%/$hostname/g;
			$postbody =~ s/%VERSION%/$version/g;
			$postbody =~ s/%USER%/$remote_user/g;
			$postbody =~ s/%OS%/$os_type $os_version/g;
			print "$postbody\n";
			}
		if ($tconfig{'postbodyinclude'}) {
			open(INC,
			 "$root_directory/$current_theme/$tconfig{'postbodyinclude'}");
			while(<INC>) {
				print;
				}
			close(INC);
			}
		if (defined(&theme_postbody)) {
			&theme_postbody(@_);
			}
		print "</body></html>\n";
		}
}


1;

