#/usr/bin/perl
use XML::CSV;
#use XML::Excel;

my @columns = ('first-name', 'last-name', 'email');
my $csv = XML::CSV->new({column_headings => \@columns});
#my $csv = XML::Excel->new({column_headings => \@columns});

# Read file
$csv->parse_doc("in.csv");

# Write file
$csv->print_xml('out.xml', {file_tag    => 'file', parent_tag  => 'record'} );
