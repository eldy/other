#!/usr/bin/perl
#-------------------------------------------------------
# Envoi mail
#-------------------------------------------------------
use MIME::Lite;

$EMAILFROM='nobody@ns3744.ovh.net';
$EMAILTO='l.destailleur@wanadoo.fr';
$MESSAGE="test";

my $Message = new MIME::Lite
   From =>"$EMAILFROM",
   To =>"$EMAIL",
   Cc =>'',
   Bcc =>'',
   Subject =>"Inscription de votre adresse $LIB_ADRES sur ChiensDeRace.com",
   Type =>'TEXT/HTML',
   Data =>"$MESSAGE";
$Message -> send;

0;


