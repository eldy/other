#!/usr/bin/perl

# Copyright (C) 2000,2001  Rodolphe Quiedeville
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
# or see http://www.gnu.org/
#
# $Id: mail.pl,v 1.1 2002/06/25 16:17:42 rodolphe Exp $
# $Source: /cvsroot/firstjeudi/firstjeudi/mail.pl,v $

$SYSLOG_LEVEL = 'local3';
$VERSION = '1.01';
$MESSAGE_DIR = $ENV{"GLJROOT"} . "/scripts/var/";

use strict;
use vars qw/$SYSLOG_LEVEL $MESSAGE_DIR/;
use DBI;
use Sys::Syslog qw(:DEFAULT setlogsock);
###
use POSIX;
use Net::SMTP;
use Text::Wrap; # qw(wrap 80 'wrap');
###

use Getopt::Long;
 Getopt::Long::Configure("bundling");

my($version) = "1.0.1";
my($dsn, $debug, $nomail, $ville, $verbose, $testconn, $filemesg, $test, $title) = ("",0,0,0,0,0,0,0);
my($nbsql, $conffile) = (0);
my ($gljroot) = $ENV{"GLJROOT"};

# Options    
exit unless GetOptions("debug"      =>\$debug,
		       "test"       =>\$test,
		       "gljroot=s"  =>\$gljroot,
		       "title=s"    =>\$title,
		       "ville=s"    =>\$ville,
		       "file=s"     =>\$filemesg,
		       "v+"         =>\$verbose);

print "** Running in verbose mode level $verbose\n" if $verbose>0;
#

my ($mesg);

open (FH, "<$filemesg") || die "can't open $filemesg: $!";	
while (<FH>)  {
    $mesg .= $_;
}
close (FH);


my $dbh = DBI->connect("dbi:mysql:dbname=firstjeudi","","") || die $DBI::errstr ;


my($elmt_posteid, $elmt_regionid,$elmt_contratid, $elmt_site);

my $sql_elmt = "SELECT distinct(email) FROM user where email is not null AND ville='$ville'";

my $sth = $dbh->prepare("$sql_elmt") || die $dbh->errstr ;
$sth->execute;

my ($email, $i, @row);

while ( @row = $sth->fetchrow_array ) {
    ($email) = @row ;
    $i++;
    
    $mesg = wrap("","",$mesg);

    if ($test) {
	$email = "rodo\@lolix.org";
    }

    print "$email\n";

    my $smtp = Net::SMTP->new('localhost',
			   Hello => 'lolix.org',
			   Timeout => 30);
    
    $smtp->mail("webmaster\@firstjeudi.org");
    $smtp->to($email);
    
    $smtp->data();
    $smtp->datasend("From: Webmaster FirstJeudi <webmaster\@firstjeudi.org>\n");

    $smtp->datasend("Content-Type: text/plain; charset=\"iso-8859-1\"\n");
    $smtp->datasend("To: $email\n");
    $smtp->datasend("Subject: $title\n");
    $smtp->datasend("X-Mailer: FirstJeudi Mailor\n");
    $smtp->datasend("X-Activity: Grokage\n");
    $smtp->datasend("\n");

    $smtp->datasend($mesg);

    $smtp->dataend();
    $smtp->quit;

    $i++;
    if ($test) { exit 1; }
}

$sth->finish;
$dbh->disconnect;


__END__
# Below is the documentation for the script.

=head1 NAME

mail.pl - Send message to subscribers

=head1 SYNOPSIS

subs-resume.pl --file --ville --title

=head1 DESCRIPTION

subs-resume.pl read new element and send them to subscribers

=head1 OPTIONS

=over


=item B<--title>

=item B<--ville>

=item B<--file>


=back

=head1 AUTHOR

Rodolphe Quiedeville (rodolphe@quiedeville.org)
http://rodolphe.quiedeville.org/

=head1 SEE ALSO

Lolix::Export

=cut

