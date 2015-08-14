#
# Tiger theme by David Harrison
# Last modified 1/10/2005
#
#
#####################################

my $_module_name = $module_name || '';
my $_confdir;

sub theme_header
{
$tb = "class='hidden'";
local $ll;
&load_theme_library();

print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n";
print "<html>\n";
local $os_type = $gconfig{'real_os_type'} ? $gconfig{'real_os_type'}
					  : $gconfig{'os_type'};
local $os_version = $gconfig{'real_os_version'} ? $gconfig{'real_os_version'}
					        : $gconfig{'os_version'};
print "<head>\n";
print "<meta http-equiv=\"Content-Type\" content=\"text/html; Charset=iso-8859-1\">\n"; 	
if (@_ > 0) {
	if ($gconfig{'sysinfo'} == 1) {
		printf "<title>%s : %s on %s (%s %s)</title>\n",
			$_[0], $remote_user, &get_display_hostname(),
			$os_type, $os_version;
		}
	elsif ($gconfig{'sysinfo'} == 4) {
		printf "<title>%s on %s (%s %s)</title>\n",
			$remote_user, &get_display_hostname(),
			$os_type, $os_version;
		}
	else {
		print "<title>$_[0]</title>\n";
		}	
		print $_[7] if ($_[7]);
	
	}	
	if ($ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi') {
		# Nothing - primary CSS file should not be loaded
    		;
    } else {	
		print "$tconfig{'headhtml'}\n" if ($tconfig{'headhtml'});
	}
if ($tconfig{'headinclude'}) {
	local $_;
	open(INC, "$theme_root_directory/$tconfig{'headinclude'}");
	while(<INC>) {
		print;
		}
	close(INC);
	}	
	if ($ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi') {
    		print "<style type='text/css'>\n<!--\n", slurp_file(_dirname(__FILE__) . '/login.css'), "\n-->\n</style>\n";
    } else {
    		# Favicon...
    		print "<link rel=\"shortcut icon\" href=\"/images/favicon.ico\"/>\n";
		# Rounded corners support
		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/theme.css\">\n";
		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/niftyCorners.css\">\n";
		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/niftyPrint.css\" media=\"print\">\n";
		print "<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/nifty.js\"></script>\n";
		print "<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/prototype.js\"></script>\n";
		print "<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/controls.js\"></script>\n";
		print "<script type=\"text/javascript\" src=\"$gconfig{'webprefix'}/theme-stressfree/effects.js\"></script>\n";
		
		print "<script type=\"text/javascript\">\n";
		print "var searchVisible = false;";
		print "function viewSearch(){";
		print "if(!searchVisible){";
		print "\$(\"searchbutton\").style.background = \"url($gconfig{'webprefix'}/theme-stressfree/images/searchselected.jpg)\";";
		print "\$(\"searchform\").style.display = \"block\";";
		print "\$(\"searchfield\").focus();";
		print "searchVisible = true;";
		print "} else {";
		print "\$(\"searchbutton\").style.background = \"url($gconfig{'webprefix'}/theme-stressfree/images/searchnotselected.gif)\";";
		print "\$(\"searchform\").style.display = \"none\";";
		print "searchVisible = false";
		print "} 	return false; } </script>";
		
		print "\n<!--[if IE]>\n";
		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"/theme_ie.css\" />\n";
		print "<![endif]-->\n";
	}
    if ($ENV{SCRIPT_NAME} =~ m'^/chooser.cgi') {    		
    		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/chooser.css\">";
    }
    elsif ($ENV{SCRIPT_NAME} =~ m'^/help\.cgi') {    		
    		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/help.css\">";
    }
    elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi') { 	
    		print "<link rel=\"stylesheet\" type=\"text/css\" href=\"$gconfig{'webprefix'}/theme-stressfree/fileupload.css\">";
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
local $dir = $current_lang_info->{'dir'} ? "dir=\"$current_lang_info->{'dir'}\""
					 : "";
print "<body ".$_[8].">\n";
print "<div id=\"container\">";
local $hostname = &get_display_hostname();
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
	local $_;
	open(INC, "$theme_root_directory/$tconfig{'prebodyinclude'}");
	while(<INC>) {
		print;
		}
	close(INC);
	}
	
	
if (defined(&theme_prebody)) {
	&theme_prebody(@_);
	}
if (@_ > 1) {	
	print "<div id=\"content\">\n";
	print "<div id=\"header\">\n";
	if ($gconfig{'sysinfo'} == 2 && $remote_user) {
		print "<div id=\"headerinfo\">\n";
		printf "%s%s logged into %s %s on %s (%s%s)</td>\n",
			$ENV{'ANONYMOUS_USER'} ? "Anonymous user" : "<tt>$remote_user</tt>",
			$ENV{'SSL_USER'} ? " (SSL certified)" :
			$ENV{'LOCAL_USER'} ? " (Local user)" : "",
			$text{'programname'},
			$version, "<tt>$hostname</tt>",
			$os_type, $os_version eq "*" ? "" : " $os_version";
		print "</div>\n";
		}
	print "<div id=\"headerservers\">";
	if ($ENV{'HTTP_WEBMIN_SERVERS'}) {
		print "<li><a href='$ENV{'HTTP_WEBMIN_SERVERS'}'>",
		      "$text{'header_servers'}</a></li>\n";
		}
	if (!$_[5] && !$tconfig{'noindex'}) {
		local @avail = &get_available_module_infos(1);
		local $nolo = $ENV{'ANONYMOUS_USER'} ||
			      $ENV{'SSL_USER'} || $ENV{'LOCAL_USER'} ||
			      $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;
		if ($gconfig{'gotoone'} && $main::session_id && @avail == 1 &&
		    !$nolo) {
			print "<li><a href='$gconfig{'webprefix'}/session_login.cgi?logout=1'>",
			      "$text{'main_logout'}</a></li>";
			}
		elsif ($gconfig{'gotoone'} && @avail == 1 && !$nolo) {
			print "<li><a href=$gconfig{'webprefix'}/switch_user.cgi>",
			      "$text{'main_switch'}</a></li>";
			}
		elsif (!$gconfig{'gotoone'} || @avail > 1) {
			print "<li><a href='$gconfig{'webprefix'}/?cat=$module_info{'category'}'>",
			      "$text{'header_webmin'}</a></li>\n";
			}
		}
	if (!$_[4] && !$tconfig{'nomoduleindex'}) {
		local $idx = $module_info{'index_link'};
		local $mi = $module_index_link || "/$module_name/$idx";
		local $mt = $module_index_name || $text{'header_module'};
		print "<li><a href=\"$gconfig{'webprefix'}$mi\">$mt</a></li>\n";
		}
	if (ref($_[2]) eq "ARRAY" && !$ENV{'ANONYMOUS_USER'}) {
		print "<li>", &hlink($text{'header_help'}, $_[2]->[0], $_[2]->[1]),
		      "</li>\n";
		}
	elsif (defined($_[2]) && !$ENV{'ANONYMOUS_USER'}) {
		print "<li>",&hlink($text{'header_help'}, $_[2]),"</li>\n";
		}
	if ($_[3]) {
		local %access = &get_module_acl();
		if (!$access{'noconfig'} && !$config{'noprefs'}) {
			local $cprog = $user_module_config_directory ?
					"uconfig.cgi" : "config.cgi";
			print "<li><a href=\"$gconfig{'webprefix'}/$cprog?$module_name\">",
			      $text{'header_config'},"</a></li>\n";
			}
		}		
    if($_[6]) {
    		print "<li>";
    		local $links = $_[6];
    		local $find = "<br>";
    		local $replace = "</li><li>";
    		$links =~ s/$find/$replace/g;
    		print $links;
    		print "</li>";
    }
	print "</div>\n";
} else {
	print "<div id=\"content\">\n";
	print "<div id=\"header\">\n";	
}	
	
	# Title is just text
	print "<div id=\"headertitle\">";	
	print "<h1>$_[0]</h1>\n";					
	print "<p>$_[9]</p>\n" if ($_[9]);
	print "</div>\n";
		
	print "</div>\n";
	print "<div id=\"contentcontainer\">\n";
	print "<div id=\"maincontent\">\n";
		 
    if ($ENV{SCRIPT_NAME} =~ m'^/file/' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/')
    {
    		print "<div class=\"filemanager\">";
    } 
    

}



sub theme_prebody
{
   if ($ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi')
    {
        # Nothing
        ;
    }   
    elsif ($ENV{SCRIPT_NAME} =~ m'^/chooser.cgi')
    {
        # Nothing
        ;
    } 
    elsif ($ENV{SCRIPT_NAME} =~ m'^/help\.cgi')
    {
    		print "<div id=\"helptitle\"><span>Webmin Help</span></div>";
    	    print "<div id=\"printoption\">";
    	    print "<ul>";          	    
        print "<li class=\"printbutton\"><a href=\"javascript:self.print()\">Print</a></li>"; 
        print "<li class=\"printclose\"><a href=\"javascript:self.close()\">Close</a></li>";
        print "</ul></div>";

    }
    elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi')
    {
    		print "<div id=\"uploadtitle\"><span>Webmin File Upload</span></div>";
    	    print "<div id=\"uploadoption\">";
    	    print "<ul>";          	     
        print "<li class=\"uploadclose\"><a href=\"javascript:self.close()\">Close</a></li>";
        print "</ul></div>";

    }
    else
    {    		
		print "<script type=\"text/javascript\">\n";
		print "var prev_onload = window.onload;\n";		
		print "window.onload = function() { \n";
		print "if(prev_onload!=null){ prev_onload(); }\n"; 
		print "if(!NiftyCheck())\n";
		print "	return;\n";
		print "Rounded(\"div#container\",\"tr tl\",\"#476DAB\",\"#FFF\",\"smooth\");\n";	
		print "Rounded(\"div#contentcontainer\",\"tr tl\",\"#000\",\"#FFF\",\"smooth\");\n";
		print "}\n";
		print "</script>\n";	
    	
        my $_webmin_version = get_webmin_version();

        get_miniserv_config(\%miniserv) unless %miniserv;

        $_confdir = $miniserv{'env_WEBMIN_CONFIG'} . "/theme-stressfreestyle-config" if $miniserv{'env_WEBMIN_CONFIG'};

        #@modules =();
        unless (@modules)
        {
            if ($gconfig{'product'} eq 'webmin' and $_webmin_version >= 1.14)
            {
                eval '   @modules = &get_visible_module_infos(); ';
            }
            else
            {
                @modules = &get_available_module_infos(1);
            }
        }

        &ReadParse() unless %in;


        my $_in_cat = (defined($in{'cat'}) ? $in{'cat'} : $gconfig{'deftab'} || '');

        print '<div id="menu"><ul>';

        $_in_cat = '__GET_FROM_MODULE__' if $_module_name;



        if (   $gconfig{"notabs_${base_remote_user}"} == 2
            || $gconfig{"notabs_${base_remote_user}"} == 0 && $gconfig{'notabs'})
        {
            $_in_cat = '__NO_MODS__';
        }

        # $_in_cat = $gconfig{'deftab'} if $gconfig{'deftab'} and not defined($_in_cat);

        $_in_cat = "" if $_in_cat eq '_OTHERS_';

        if ($ENV{SCRIPT_NAME} eq "/config.cgi" || ($gconfig{'product'} eq 'usermin' && $ENV{SCRIPT_NAME} eq "/uconfig.cgi"))
        {
            (undef, $_module_name) = split(/\?/, $ENV{'REQUEST_URI'}, 2);
            $_in_cat = '__GET_FROM_MODULE__';
        }

        print __catmods($_in_cat, \@modules);
        my $nolo = $ENV{'ANONYMOUS_USER'}
          || $ENV{'SSL_USER'}
          || $ENV{'LOCAL_USER'}
          || $ENV{'HTTP_USER_AGENT'} =~ /webmin/i;

        
        print "\n<li style=\"background: url($gconfig{'webprefix'}/theme-stressfree/images/searchnotselected.gif);\" id=\"searchbutton\"><a href=\"#\" onclick=\"viewSearch()\">Search</a></li>";
       
        if ($main::session_id and !$nolo)
        {
            print
              "\n<li id=\"logout\"><a href='".$gconfig{'webprefix'}."/session_login.cgi?logout=1'>",
              $text{'main_logout'}, "</a></li>";
        }
        elsif (!$nolo)
        {
            print
              "\n<li id=\"logout\"><a href='/switch_user.cgi'>",
              $text{'main_switch'}, '</a></li>';
        } 
        print "</ul></div>\n\n";
        print "<div style=\"display: none;\" id=\"searchform\"><ul>";
        print "<li class=\"searchbox\"><input autocomplete=\"off\" type=\"text\" id=\"searchfield\" name=\"searchfield\" size=\"25\"/></li>";
        print "<li class=\"searchtext\"><p>Search:</p></li></ul></div>";
        print "<div class=\"autocomplete\" id=\"searchfield_choices\"></div>";
        print "<script language=\"javascript\">\n";
        print "<!--\n";
        print "new Ajax.Autocompleter(\"searchfield\", \"searchfield_choices\", \"/search.cgi\", {paramName: \"Search\", minChars: 2, afterUpdateElement: openUrl});\n";
        print "function openUrl() {\n";
        print "var url = '/' + \$('searchfield').value;\n";
        print "document.location.href = url; }\n";
        print "\n-->\n";
        print "</script>";
    }   
}

sub theme_postbody
{

    if (
	    ($ENV{SCRIPT_NAME} =~ m'^/session_login\.cgi'))
    {
        #nothing
        ;
    }
    elsif (
	    ($ENV{SCRIPT_NAME} =~ m'^/chooser.cgi'))
    {
        #nothing
        ;
    }
    elsif ($ENV{SCRIPT_NAME} =~ m'^/help\.cgi')
    {
        print '</div>';
    }
    elsif ($ENV{SCRIPT_NAME} =~ m'^/file/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upform\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/upload\.cgi' || $ENV{SCRIPT_NAME} =~ m'^/file/upload\.cgi')
    {
        print '</div>';
    }
    else
    {    		 
    		if ($ENV{SCRIPT_NAME} =~ m'^/file/' || $ENV{SCRIPT_NAME} =~ m'^/filemanager/'){
    			print "</div>"; 
    		} 
    		
    		print slurp_file(_dirname(__FILE__) . '/message.html');
    		
	   	print "\n</div></div>";
        	print "\n<div id=\"footer\">"
          . $ENV{'REMOTE_USER'}
          . ($gconfig{nohostname} ? '' : '@' . get_display_hostname())
          . "</div>\n";
        	print "</div></div>";
    		print "\n \n";
    }
}


sub theme_popup_header
{
	print "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n";
	print "<html>\n";
	print "<head>\n";
	print "<title>$_[0]</title>\n";
	print $_[1];
	print "$tconfig{'headhtml'}\n" if ($tconfig{'headhtml'});
	if ($tconfig{'headinclude'}) {
        local $_;
        open(INC, "$theme_root_directory/$tconfig{'headinclude'}");
        while(<INC>) { 
                print;
        }
        close(INC);
    }
    print "<link rel='stylesheet' href='/popup.css' type='text/css' />";
	print "</head>\n";
	print "<body ".$_[8].">\n";
}








sub __catmods
{
    my ($cat, $mods_ar) = @_;
    my ($icon_map, $is_cat, $_dump, $catname);

    #  our(%catnames);

    unless ($_icons)
    {
        my $_iconmap = _dirname(__FILE__) . '/icon_map' . ($gconfig{'product'} eq 'usermin' ? '_usermin' : '');
        do $_iconmap;
        do $_confdir . '/icon_map' if $_confdir;
    }

    my $default_icon = $_icons->{_DEFAULT_} || 'default16x16.png';

    &read_file("$config_directory/webmin.catnames", \%catnames) unless %catnames;

    my ($mods, $gotos, %xpcats, %saw_cat);
    
    my %menucategories = ();
    my %listedmodules = ();

  MOD: foreach my $m (@{$mods_ar})
    {

        $m->{'category'} = 'usermin' if $gconfig{'product'} eq 'usermin' and $m->{'category'} eq 'webmin';
        $m->{'category'} = ''        if $m->{'category'}    eq 'others';

        if ($_module_name and $_module_name eq $m->{'dir'})
        {
            $is_cat = $m->{'category'};
        }        	

        my $_catname = $m->{'category'};

        $_catname = "\xa0" if $cat eq '__NO_MODS__';       
		
		# Check if module has been listed yet
		my $moduleindex = $_catname . "-" . $m->{'name'};
		# Commented out this section to check for duplicates as it resulted in certain menu options not showing
        #if(exists $listedmodules{$moduleindex}){
        	# Module alreay exists, skip
        #} else {        
        	my $categorytext = $menucategories{$_catname};

        	$catname ||= $_catname;

		#my $icon = $_icons->{$m->{dir}} || $default_icon;
		my $icon = $default_icon;
		if(exists($_icons->{$m->{dir}})){
  			$icon = $_icons->{$m->{dir}};
		} else {
  			if(-e "$root_directory/$m->{dir}/images/icon.gif" ){
    				$icon = "../".$m->{dir}."/images/icon.gif' width='16' height='16'";
  			}
		}

        	my $newcategorytext =
			"<li><a title=\""
			. htmlify2($m->{'longdesc'} || $m->{'desc'} || $m->{'name'} || '')
			. "\" href=\"$gconfig{webprefix}/$m->{'dir'}/$m->{index_link}\">"
			. "<img class='modicon' src='$gconfig{webprefix}/icons/$icon' alt=\""
			. htmlify2($m->{'longdesc'} || $m->{'desc'} || $m->{'name'} || '')
			."\" border='0'><span class=\"menuitem\">"
			. ($m->{'desc'} || $m->{'name'} || '')
			. "</span></a></li>\n";
		
			$menucategories{$_catname} = $categorytext . $newcategorytext;	
			
			$listedmodules{$moduleindex} = "true";
		#}
    }

    
	$is_cat =~ s/\b(\w)/\U$1/g;
    
    while ( my ($key, $value) = each(%menucategories) ) {
		if($key eq 'webmin' || $key eq 'usermin'){ 
		
		my $_catname = $catnames{$key}        
          || $text{"category_" . $key}
          || htmlify2($key || 'Others');
				
       	if($key eq $is_cat){
       		$mods .= "<li class=\"menuopen\" style=\"font-weight: bold;\">";
       	} else {
       		$mods .= "<li class=\"menuclosed\" style=\"font-weight: bold;\">";
       	}
       	$mods .= "<a href=/?cat=" . $key . ">" . $_catname . "</a>";
       	$mods .= "<ul>" . $value . "</ul></li>";
		}
    }
    
	while ( my ($key, $value) = each(%menucategories) ) {
		if($key ne 'webmin' && $key ne 'usermin'){ 
		
		my $_catname = $catnames{$key}        
          || $text{"category_" . $key}
          || htmlify2($key || 'Others');
				
       	if($key eq $is_cat){
       		$mods .= "<li class=\"menuopen\">";
       	} else {
       		$mods .= "<li class=\"menuclosed\">";
       	}
       	$mods .= "<a href=/?cat=" . $key . ">" . $_catname . "</a>";
       	$mods .= "<ul>" . $value . "</ul></li>";
		}
    }

    return $mods;

}

sub htmlify2
{
    my ($str) = @_;
    return '' unless $str;
    $str =~ s/</&lt\;/g;
    $str =~ s/>/&gt\;/g;
    $str =~ s/\"/&quot\;/g;
    $str =~ s/'/&\#39\;/g;
    return $str;
}

sub _dirname
{

    # replacement for File::Basename::dirname
    my ($str) = @_;
    return undef unless defined $str;
    return '.'   unless $str;
    $str =~ tr/\/\\/\//s if $^O and $^O =~ /mswin|win32/i;
    return $str if $str =~ s@/([^/]+)$@@;
    return '.';
}

sub slurp_file 
{ 
	my $fh = undef; 
	local $/ = undef; 
 
	if (open($fh, $_[0])) 
	{ 
		binmode $fh; 
		local $_ = <$fh>; 
		close $fh; 
		return $_; 
	} 
	return undef; 
}

