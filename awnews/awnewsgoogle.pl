#!/usr/bin/perl
#-------------------------------------------------------
# Get news from Google news to create a RSS file
#-------------------------------------------------------
#use strict;

use Carp;
use LWP;
use URI::Escape;
use XML::RSS;
#use utf8;
use HTML::Entities;

my $langshort="fr";
my $lang="fr_FR";

($DIR=$0) =~ s/([^\/\\]*)$//; ($PROG=$1) =~ s/\.([^\.]*)$//; $Extension=$1;
$DIR||='.';
require "$DIR/../../wwwroot/lib/lib.pl";
my $topic=$NEWSAUTO;
my $VERSION="1.2";




($nowsec,$nowmin,$nowhour,$nowday,$nowmonth,$nowyear) = localtime(time);
if ($nowyear < 100) { $nowyear+=2000; } else { $nowyear+=1900; }
$nowsmallyear=$nowyear;$nowsmallyear =~ s/^..//;
if (++$nowmonth < 10) { $nowmonth = "0$nowmonth"; }
if ($nowday < 10) { $nowday = "0$nowday"; }
if ($nowhour < 10) { $nowhour = "0$nowhour"; }
if ($nowmin < 10) { $nowmin = "0$nowmin"; }


sub ddd {
    my $mes=shift;
#    print "$mes\n";
}

sub get_news_for_topic {
	my $topic = uri_escape( $_[0] );
    &ddd("Get page for $topic");

	my @results = ();
    #http://news.google.com/news?q=chats+animaux&num=10&hl=fr&lr=lang_fr&newwindow=1&scoring=d
	my $url = "http://news.google.com/news?num=10&hl=$langshort&lr=lang_$langshort&newwindow=1&scoring=d&q=$topic";
	my $ua = LWP::UserAgent->new();
	$ua->agent('Mozilla/5.0');

	my $response = $ua->get($url);
	return unless $response->is_success;

	my $re1 = '<br><div>(.+)</div><br>';

	my( $section ) = ( $response->content =~ m/$re1/s );

	$section =~ s/\r//g;
	$section =~ s/\n//g;
	$section =~ s/<b>//g;
	$section =~ s/<\/b>//g;
	$section =~ s/<nobr>//g;
	$section =~ s/<\/nobr>//g;

	my $re2 = qr/((?:<a href=[^>]+><img src=[^>]+><\/a>)?)(?:<\/td><td>)?<a href=([^>]+)>([^<]+)<\/a><br><font size=[^>]+><font color=[^>]+>([^<]*)<\/font>([^<]*)<\/font><br><font size=[^>]+>([^<]*)<\/font>/mi;

	my @stories = split(/($re2)/m,$section);
	foreach my $story (@stories) {
		if ($story =~ m/$re2/i) {

            &ddd("x $story x\n");

			my $story_h = {};
                
			my( $img, $url, $headline, $source, $date, $summary ) = ( $1, $2, $3, $4, $5 ,$6);

            # If already found with same headline
            if ($headlines{$headline}) { next; }
            $headlines{$headline}=1;
                                    
            $url =~ s/^\"+//; $url =~ s/\"+$//;

			$source =~ s/&nbsp;/ /g;
			$source =~ s/^\s+/ /g;
			$source =~ s/[\s\-]+$//g;

			if ($date =~ /publi/i) { $date="$nowday/$nowmonth/$nowyear"; }
			$date =~ s/&nbsp;/ /g;
			$date =~ s/\s+/ /g;	
			$date =~ s/[\s\-]+$//g;
			$date =~ s/^[\s\-]//g;

			#$summary = $hs->parse($summary); $hs->eof;
			$summary =~ s#<br># #gi;
			$summary =~ s#<.+?>##gi;
        
            $headline=~s/</&lt;/g;$headline=~s/>/&gt;/g;
            $description=~s/</&lt;/g;$description=~s/>/&gt;/g;

			$story_h->{url} = $url;
			$story_h->{headline} = encode_entities("$headline");
			$story_h->{source} = $source;
			$story_h->{date} = $date;
			$story_h->{description} = encode_entities($img ." ". "$summary");

			push(@results,$story_h);

            #print "y $url, $headline, $source, $date, $summary y\n";

		}
	}

	return \@results;

}

$results = get_news_for_topic( $topic );

&ddd("Build rss");
#my $rss = XML::RSS->new(version => '1.0', encoding=>"utf8" );
my $rss = XML::RSS->new(version => '1.0');
$rss->channel(title => "Google News -- $topic -- $VERSION");
for (@{$results}) {
    # Ajout/remplacement base de données avec Id_CATEG = 0
    
    # Ajout flux RSS
    $rss->add_item(
            title => $_->{headline},
            link  => $_->{url},
            description  => $_->{description},
            dc => {
                date       => $_->{date},
                creator    => $PROG,
                publisher  => $_->{source},
                language   => $lang,
            },
            syn => {
             updatePeriod     => "daily",
             updateFrequency  => "1",
            },
    );
}

#print "Ecriture fichier $DIR/newsgoogle.rss\n";
open (FILE,">$DIR/../../wwwroot/news/news_auto/newsgoogle.rss");
print FILE $rss->as_string;
close FILE;

0;
