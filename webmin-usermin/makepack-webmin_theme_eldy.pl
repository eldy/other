#!/usr/bin/perl
use Cwd;

$PROJECT="theme_eldy";
$MAJOR="1";
$MINOR="5";

@LISTETARGET=("WBT");   # Possible packages
%REQUIREMENTTARGET=(                            # Tool requirement for each package
"WBT"=>"tar",
);
%ALTERNATEPATH=(
);


$SOURCE="git/other/webmin-usermin/webmin/$PROJECT";
$DESTI=$ENV{'DESTIMODULES'};		# ".../Mes Sites/Web/Admin1/wwwroot/files";

$FILENAMEWBT="$PROJECT-$MAJOR.$MINOR";
use vars qw/ $REVISION $VERSION /;
$REVISION='$Revision: 1.1 $'; $REVISION =~ /\s(.*)\s/; $REVISION=$1;
$VERSION="1.0 (build $REVISION)";

#------------------------------------------------------------------------------
# MAIN
#------------------------------------------------------------------------------
($DIR=$0) =~ s/([^\/\\]+)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DIR||='.'; $DIR =~ s/([^\/\\])[\\\/]+$/$1/;

# Test we are in correct directory
my $pwd = `pwd`;
$pwd=~s/\n//;
if ($pwd ne '/home/ldestailleur/git/other/webmin-usermin') { die("Must be ran from dir tools"); }

#$CURDIR="$DIR/..";
#if ($CURDIR !~ /^\//)
#{
#	print "Error: Launch the script $PROG.$Extension with its full path from /.\n";
#	print "$PROG.$Extension aborted.\n";
#	sleep 2;
#	exit 1;
#}

# Detect OS type
# --------------
if ("$^O" =~ /linux/i || (-d "/etc" && -d "/var" && "$^O" !~ /cygwin/i)) { $OS='linux'; $CR=''; }
elsif (-d "/etc" && -d "/Users") { $OS='macosx'; $CR=''; }
elsif ("$^O" =~ /cygwin/i || "$^O" =~ /win32/i) { $OS='windows'; $CR="\r"; }
if (! $OS) {
    print "makepack-dolbarr.pl was not able to detect your OS.\n";
	print "Can't continue.\n";
	print "makepack-dolibarr.pl aborted.\n";
    sleep 2;
	exit 1;
}

# Define buildroot
# ----------------
if ($OS =~ /linux/) {
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"/tmp";
}
if ($OS =~ /macos/) {
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"/tmp";
}
if ($OS =~ /windows/) {
    $TEMP=$ENV{"TEMP"}||$ENV{"TMP"}||"c:/temp";
    $PROGPATH=$ENV{"ProgramFiles"};
}
if (! $TEMP || ! -d $TEMP) {
    print "Error: A temporary directory can not be find.\n";
    print "Check that TEMP or TMP environment variable is set correctly.\n";
	print "makepack-dolibarr.pl aborted.\n";
    sleep 2;
    exit 2;
} 
$BUILDROOT="$TEMP/buildroot";
#$BUILDROOT="c:/temp/buildroot";

@LISTETARGET=("WBT");
@CHOOSEDTARGET=();


# Choose package targets
#-----------------------
print "Makepack version $VERSION (OS $OS)\n";
print "Building package for $PROJECT $MAJOR.$MINOR\n";
print "Source $SOURCE\n";
print "Desti  $DESTI\n";
my $found=0;
my $NUM_SCRIPT;
while (! $found) {
	my $cpt=0;
	printf(" %d - %3s    (%s)\n",$cpt,"All","Need ".join(",",values %REQUIREMENTTARGET));
	foreach my $target (@LISTETARGET) {
		$cpt++;
		printf(" %d - %3s    (%s)\n",$cpt,$target,"Need ".$REQUIREMENTTARGET{$target});
	}

	# On demande de choisir le fichier a passer
	print "Choose one package number or several separated with space: ";
	$NUM_SCRIPT=<STDIN>; 
	chomp($NUM_SCRIPT);
	if ($NUM_SCRIPT =~ s/-//g) {
		# Do not do copy	
		$copyalreadydone=1;
	}
	if ($NUM_SCRIPT !~ /^[0-$cpt\s]+$/)
	{
		print "This is not a valid package number list.\n";
		$found = 0;
	}
	else
	{
		$found = 1;
	}
}
print "\n";
if ($NUM_SCRIPT) {
	foreach my $num (split(/\s+/,$NUM_SCRIPT)) {
		$CHOOSEDTARGET{$LISTETARGET[$num-1]}=1;
	}
}
else {
	foreach my $key (@LISTETARGET) {
	    $CHOOSEDTARGET{$key}=1;
    }
}

# Test if requirement is ok
#--------------------------
foreach my $target (keys %CHOOSEDTARGET) {
    foreach my $req (split(/[,\s]/,$REQUIREMENTTARGET{$target})) {
        # Test    
        print "Test requirement for target $target: Search '$req'... ";
        $ret=`"$req" 2>&1`;
        $coderetour=$?; $coderetour2=$coderetour>>8;
        if ($coderetour != 0 && $coderetour2 == 1 && $PROGPATH) { 
            # If error not found, we try in PROGPATH
            $ret=`"$PROGPATH/$ALTERNATEPATH{$req}/$req\" 2>&1`;
            $coderetour=$?; $coderetour2=$coderetour>>8;
            $REQUIREMENTTARGET{$target}="$PROGPATH/$ALTERNATEPATH{$req}/$req";
        }    

        if ($coderetour == 0 || $coderetour2 > 1 || $ret =~ /Usage/) {
            # Pas erreur ou erreur autre que programme absent
            print " Found ".$REQUIREMENTTARGET{$target}."\n";
        } else {
            print "Not found\nCan't build target $target. Requirement '$req' not found in PATH\n";
            $CHOOSEDTARGET{$target}=-1;
            last;
        }
    }
}

print "\n";

# Update buildroot
#-----------------
my $copyalreadydone=0;
if (! $copyalreadydone) {
	print "Delete directory $BUILDROOT\n";
	$ret=`rm -fr "$BUILDROOT"`;

	mkdir "$BUILDROOT";
	print "Recopie de ~/$SOURCE dans $BUILDROOT\n";
	mkdir "$BUILDROOT";
	$ret=`cp -pr ~/"$SOURCE" "$BUILDROOT"`;

}

print "Nettoyage de $BUILDROOT\n";
$ret=`rm -f $BUILDROOT/$PROJECT/*.wbt`;
$ret=`rm -f $BUILDROOT/$PROJECT/*.tar`;
$ret=`rm -fr $BUILDROOT/$PROJECT/Thumbs.db $BUILDROOT/$PROJECT/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/*/Thumbs.db`;
$ret=`rm -fr $BUILDROOT/$PROJECT/CVS* $BUILDROOT/$PROJECT/*/CVS* $BUILDROOT/$PROJECT/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/*/CVS*`;

#rename("$BUILDROOT/$PROJECT","$BUILDROOT/$FILENAMEWBT");

# Generation des packages
#------------------------

# Build package for each target
#------------------------------
foreach $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) { next; }

    print "\nBuild pack for target $target\n";



	if ($target eq 'WBT') {
		unlink $FILENAMEWBT.wbt;
		print "Creation archive $FILENAMEWBT.wbt de $PROJECT\n";
		$ret=`tar --directory="$BUILDROOT" -cvf $FILENAMEWBT.wbt $PROJECT`;
		print "D�placement de $BUILDROOT/$PROJECT/$FILENAMEWBT.wbt dans $DESTI/$FILENAMEWBT.wbt\n";
#		rename("$BUILDROOT/$PROJECT/$FILENAMEWBT.wbt","$DESTI/$FILENAMEWBT.wbt");
		$ret=`cp -pr "$FILENAMEWBT.wbt" "$DESTI/$FILENAMEWBT.wbt"`;
	}	

}


print "\n----- Summary -----\n";
foreach $target (keys %CHOOSEDTARGET) {
    if ($CHOOSEDTARGET{$target} < 0) {
        print "Package $target not built (bad requirement).\n";
    } else {
        print "Package $target built succeessfully in $DESTI\n";
    }
}

print "\nPress key to finish...";
my $WAITKEY=<STDIN>;

0;
