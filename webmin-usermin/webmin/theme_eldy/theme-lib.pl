# theme-lib.pl
# Common functions and definitions for web admin programs

#*******************************************************
# Initialiseren von Libraries
# init()
# Wichtig: Dies muss in jeder Subprozedur aufgerufen werden!
use Socket;

sub init
{
if ( -e 'web-lib.pl' )
{
do 'web-lib.pl';
&init_config();
}
else
{
do '../web-lib.pl';
&init_config();
}
}


#**********************************************************
# init_theme()
# old version
sub init_theme
{
#Datei oeffnen
open(THEME ,"< theme.config");
my(@temp,%theme);

while(<FILE>)
 {
  chomp;
  next if $_ eq '';
  @temp = split(/\s*=\s*/,$_);
  $theme{$temp[0]} = $temp[1];
 }
	  
$aaa = $theme{alex};

close(THEME);

return 1;
}


#***********************************************************
# init_theme2()
# 

sub init_theme2
{
# &init();

if ( -e '../theme_eldy/theme.config')
{
$theme_path = '../theme_eldy/theme.config';
}
else
{
$theme_path = 'theme_eldy/theme.config';
} 

open(THEME ,"< $theme_path");
my @temp = <THEME>;
close (THEME);

chomp @temp;

my $zeile = "";
my $name = "";
my $wert = "";
my %hash = ();
foreach $zeile (@temp)
{
  ($name, $wert) = split "=", $zeile;
    $hash{$name} = $wert;
}
    
$nbc = $hash{nav_backcolor};
$nfc = $hash{nav_fontcolor};
$nlc = $hash{nav_linkcolor};
$nalc = $hash{nav_alinkcolor};
$nvlc = $hash{nav_vlinkcolor};
$nff = $hash{nav_fontface};
$ncm = $hash{nav_cssmode};
$nl = $hash{nav_logo};
$nbg = $hash{nav_bkgrd};
$np = $hash{nav_position};
$namc = $hash{nav_ammenuc};
$namf = $hash{nav_ammenuf};
$nmmc = $hash{nav_mmenuc};
$nmmf = $hash{nav_mmenuf};
$nsc = $hash{nav_subcolor};
$nsfc = $hash{nav_subfcolor};
$nan = $hash{nav_admname};
$nam = $hash{nav_admmail};
$nhtp = $hash{nav_http};
$mh1 = $hash{main_h1color};
$mbgcolor = $hash{main_backc};
$mtext = $hash{main_fcolor};
$mlink = $hash{main_linkc};
$mbgimage = $hash{main_bgimage};
$mhr = $hash{main_hrcolor};
$mtbh = $hash{main_tbheaderc};
$mtbhf = $hash{main_tbfcolor};
$mcb = $hash{main_tbcolor};
# neue Variable
$nhr = $hash{nav_hrcolor};
# Startseite (z.B. smartstart )
$mst_1 = $hash{main_start};
$mstn_1 = $hash{main_startn};

if($mstn_1 ne ''){$mst = "<a target=Hauptframe href=$mst_1><font color=$nfc>$mstn_1</font></a>\n";}


($nam_1, $nam_2) = split '@', $nam;

if($nl eq 'logo_skin.gif')
{
$nl_1 = 'checked';
}
else
{
$nl_1 = ' ';
}

if($nbg eq 'bkgrd_skin.gif')
{
$nbg_1 = 'checked';
}
else
{
$nbg_1 = ' ';
}

if($ncm eq 'theme.css')
{
$ncm1='checked';
}
else
{
$ncm1='';
}

# return 1;
}

#***********************************************************
# init_theme3()
# Auslesen der Daten aus config

sub init_theme3
{
# &init();

if ( -e '../theme_eldy/config')
{
$theme_path = '../theme_eldy/config';
}
else
{
$theme_path = 'theme_eldy/config';
} 

open(THEME ,"< $theme_path");
my @temp = <THEME>;
close (THEME);


chomp @temp;

my $zeile = "";
my $name = "";
my $wert = "";
my %hash = ();
foreach $zeile (@temp)
{
  ($name, $wert) = split "=", $zeile;
    $hash{$name} = $wert;
    }
    
$mbgcolor = '#'.$hash{cs_page};
$mtext = '#'.$hash{cs_text};
$mlink = $hash{cs_link};
$mbgimage = $hash{bgimage};
$mtbh = '#'.$hash{cs_header};
$mcb = '#'.$hash{cs_table};
$mcss = $hash{headinclude};


if ($mcss eq 'config.css')
{
$mcss_1='checked';
$mcss_2='';
}
else
{
$mcss_2='checked';
$mcss_1='';
}

if ($mbgimage eq '/configurator/mbkgrd_skin.gif') {$mbgimage_1='checked';} else {$mbgimage_1='';}
# $test = $hash{test};
# return 1;
}



#***********************************************************
# init_theme_o()
# Auslesen der orginal Themevariablen aus der Datei theme.config.o
# 

sub init_theme_o
{
# &init();

if ( -e '../theme_eldy/theme.config.o')
{
$theme_path = '../theme_eldy/theme.config.o';
}
else
{
$theme_path = 'theme_eldy/theme.config.o';
} 

open(THEME ,"< $theme_path");
my @temp = <THEME>;
close (THEME);


chomp @temp;

my $zeile = "";
my $name = "";
my $wert = "";
my %hash = ();
foreach $zeile (@temp)
{
  ($name, $wert) = split "=", $zeile;
    $hash{$name} = $wert;
}
    
$nbc = $hash{nav_backcolor};
$nfc = $hash{nav_fontcolor};
$nlc = $hash{nav_linkcolor};
$nalc = $hash{nav_alinkcolor};
$nvlc = $hash{nav_vlinkcolor};
$nff = $hash{nav_fontface};
$ncm = $hash{nav_cssmode};
$nl = $hash{nav_logo};
$nbg = $hash{nav_bkgrd};
$np = $hash{nav_position};
$namc = $hash{nav_ammenuc};
$namf = $hash{nav_ammenuf};
$nmmc = $hash{nav_mmenuc};
$nmmf = $hash{nav_mmenuf};
$nsc = $hash{nav_subcolor};
$nsfc = $hash{nav_subfcolor};
$nan = $hash{nav_admname};
$nam = $hash{nav_admmail};
$nhtp = $hash{nav_http};
$mh1 = $hash{main_h1color};
$mbgcolor = $hash{main_backc};
$mtext = $hash{main_fcolor};
$mlink = $hash{main_linkc};
$mbgimage = $hash{main_bgimage};
$mhr = $hash{main_hrcolor};
$mtbh = $hash{main_tbheaderc};
$mtbhf = $hash{main_tbfcolor};
$mcb = $hash{main_tbcolor};
# neue Variable
$nhr = $hash{nav_hrcolor};
# Startseite (z.B. smartstart )
$mst_1 = $hash{main_start};
$mstn_1 = $hash{main_startn};

if($mstn_1 ne ''){$mst = "<a target=Hauptframe href=$mst_1><font color=$nfc>$mstn_1</font></a>\n";}

($nam_1, $nam_2) = split '@', $nam;

if($nl ne 'logo_orginal.gif')
{
$nl_1 = 'checked';
}
else
{
$nl_1 = ' ';
}

if($nbg eq '' || $nbg eq 'bgimage_orginal.gif')
{
$nbg_1 = ' ';
}
else
{
$nbg_1 = 'checked';
}

if($ncm eq 'theme.css')
{
$ncm1='checked';
}
else
{
$ncm1='';
} 

# return 1;
}

#***********************************************************
# init_theme3_o()
# Auslesen der orginal Daten aus config.o

sub init_theme3_o
{
# &init();

if ( -e '../theme_eldy/config')
{
$theme_path = '../theme_eldy/config';
}
else
{
$theme_path = 'theme_eldy/config';
} 

open(THEME ,"< $theme_path");
my @temp = <THEME>;
close (THEME);


chomp @temp;

my $zeile = "";
my $name = "";
my $wert = "";
my %hash = ();
foreach $zeile (@temp)
{
  ($name, $wert) = split "=", $zeile;
    $hash{$name} = $wert;
    }
    
$mbgcolor = '#'.$hash{cs_page};
$mtext = '#'.$hash{cs_text};
$mlink = $hash{cs_link};
$mbgimage = $hash{bgimage};
$mtbh = '#'.$hash{cs_header};
$mcb = '#'.$hash{cs_table};
$mcss = $hash{headinclude};

if ($mcss eq 'config.css')
{
$mcss_1='checked';
$mcss_2='';
}
else
{
$mcss_2='checked';
$mcss_1='';
}

# $test = $hash{test};

# return 1;
}




#***********************************************************
# theme_help()
# Speichert Hilfelinks in einer Variablen

sub theme_help
{
&init();
$css_help = &hlink("(CSS)", "css");

}




#**********************************************************
# theme_version()
# Auslesen der Versionsnummer

sub theme_version
{
if ( -e '../theme_eldy/theme.version')
{
$theme_path = '../theme_eldy/theme.version';
}
else
{
$theme_path = 'theme_eldy/theme.version';
}

open(THEME ,"< $theme_path");
my @temp = <THEME>;
close (THEME);


chomp @temp;

my $zeile = "";
my $name = "";
my $wert = "";
my %hash = ();
foreach $zeile (@temp)
{
  ($name, $wert) = split "=", $zeile;
      $hash{$name} = $wert;
}

$themever = $hash{themeversion};

}


return 1;