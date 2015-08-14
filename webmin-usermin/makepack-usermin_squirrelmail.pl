#!/usr/bin/perl
use Cwd;

$PROJECT="squirrelmail";
$MAJOR="1";
$MINOR="1";

$FILENAMEWBM="$PROJECT-$MAJOR.$MINOR";

#$PREF='E:';
$PREF='/media/DATA';
$SOURCE=$PREF."/Mes Developpements/webmin-usermin/usermin/$PROJECT";
$DESTI=$PREF."/Mes Sites/Web/Admin1/wwwroot/files";

@LISTETARGET=("WBM");
@CHOOSEDTARGET=();


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


# Choose package
#---------------
print "Building package for $PROJECT $MAJOR.$MINOR\n";
my $copyalreadydone=0;
my $found=0;
my $NUM_SCRIPT;
while (! $found) {
	my $cpt=0;
	print "$cpt - All\n";
	foreach my $target (@LISTETARGET) {
		$cpt++;
		print "$cpt - $target\n";
	}

	# On demande de choisir le fichier à passer
	print "Choose package number (or several separated by space): ";
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
		push @CHOOSEDTARGET, $LISTETARGET[$num-1];
	}
}
else {
	@CHOOSEDTARGET=@LISTETARGET;	
}


# Mise à jour du buildroot
#-------------------------

if (! $copyalreadydone) {
	print "Suppression du repertoire $BUILDROOT\n";
	$ret=`rm -fr "$BUILDROOT"`;

	mkdir "$BUILDROOT";
	print "Recopie de $SOURCE dans $BUILDROOT/$PROJECT\n";
	mkdir "$BUILDROOT/$PROJECT";
	$ret=`cp -pr "$SOURCE" "$BUILDROOT"`;

}

print "Nettoyage de $BUILDROOT\n";
$ret=`rm -f $BUILDROOT/$PROJECT/*.wbm`;
$ret=`rm -f $BUILDROOT/$PROJECT/*.tar`;
$ret=`rm -fr $BUILDROOT/$PROJECT/Thumbs.db $BUILDROOT/$PROJECT/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/Thumbs.db $BUILDROOT/$PROJECT/*/*/*/Thumbs.db`;
$ret=`rm -fr $BUILDROOT/$PROJECT/CVS* $BUILDROOT/$PROJECT/*/CVS* $BUILDROOT/$PROJECT/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/CVS* $BUILDROOT/$PROJECT/*/*/*/*/*/CVS*`;


# Generation des packages
#------------------------

foreach $target (@CHOOSEDTARGET) {

	if ($target eq 'WBM') {
		unlink $FILENAMEWBM.wbm;
		print "Creation archive $FILENAMEWBM.wbm de $PROJECT\n";
		$ret=`tar --directory="$BUILDROOT" -cvf $FILENAMEWBM.wbm $PROJECT`;
		print "Déplacement de $BUILDROOT/$PROJECT/$FILENAMEWBM.wbm dans $DESTI/$FILENAMEWBM.wbm\n";
#		rename("$BUILDROOT/$PROJECT/$FILENAMEWBM.wbm","$DESTI/$FILENAMEWBM.wbm");
		$ret=`cp -pr "$FILENAMEWBM.wbm" "$DESTI/$FILENAMEWBM.wbm"`;
	}	

}

print "\n";
foreach $target (@CHOOSEDTARGET) {
	print "Fichiers de type $target genere en $DESTI avec succes.\n";
}

my $WAITKEY=<STDIN>;

0;
