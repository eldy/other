#!/usr/bin/perl
###########################################################################
#
# Email: david.harrison@stress-free.co.nz 
# Internet: http://www.stress-free.co.nz 
#
###########################################################################

do './web-lib.pl';
&init_config();
&ReadParse();

print "Content-type: text/html\n\n";

unlink(_dirname(__FILE__) . '/message.html');

print "<div id=\"donation\">";
print "<div id=\"donationmessage\">";
print "<h2>Thank you for your donation</h2>";
print "</div></div>";

sub _dirname {
    # replacement for File::Basename::dirname
    my ($str) = @_;
    return undef unless defined $str;
    return '.'   unless $str;
    $str =~ tr/\/\\/\//s if $^O and $^O =~ /mswin|win32/i;
    return $str if $str =~ s@/([^/]+)$@@;
    return '.';
}