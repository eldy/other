#/usr/bin/perl
#------------------------------------------------------------
# Script extraction mot de passe et generation page list
#------------------------------------------------------------
use strict;no strict "refs";
use LWP::UserAgent;
use HTTP::Cookies;
use HTTP::Headers;
use HTTP::Request;



#------------------------------------------------------------
# VARIABLES/CONSTANTES
#------------------------------------------------------------



#------------------------------------------------------------
# FUNCTIONS
#------------------------------------------------------------

#------------------------------------------------------------
# Decode a string coded in Base64
#------------------------------------------------------------
sub DecodeBase64 ($)
{
    local($^W) = 0; # unpack("u",...) gives bogus warning in 5.001m, 5.002beta2

    my $str = shift;
    my $res = "";

    $str =~ tr|A-Za-z0-9+/||cd;             # remove non-base64 chars (padding)
    $str =~ tr|A-Za-z0-9+/| -_|;            # convert to uuencoded format
    while ($str =~ /(.{1,60})/gs) {
        my $len = chr(32 + length($1)*3/4); # compute length byte
        $res .= unpack("u", $len . $1 );    # uudecode
    }
    $res;
}



print DecodeBase64('cGllcnJlLmdvbWVzOjQ4OTE1Nzdt');



0;
