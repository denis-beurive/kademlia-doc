#!/usr/bin/perl
#
# Given a number of bits N, this script prints all the values from 0 (included)
# to 2^N (excluded) in binary.
#
# Usage:
#
#      perl get-all-nodes.pl
#      perl get-all-nodes.pl --size=5
#      perl get-all-nodes.pl --com
#      perl get-all-nodes.pl --com --size=5

use strict;
use warnings FATAL => 'all';
use Getopt::Long;

# Analyse CLI.

my $opt_bit_numbers = 5;
my $opt_com;
my %options = ('size=i' => \$opt_bit_numbers, 'com' => \$opt_com );

unless (GetOptions(%options)) {
    die("Error while parsing the command line.");
}

my @md = ();
for (my $nid=0; $nid<(2**$opt_bit_numbers); $nid++) {
    if ($opt_com) {
        printf( "perl kad-tree.pl --bits=5 --palette=config/buckets.pal --node=%05b | dot -Tgif -otree-%05b.gif\n", $nid, $nid);
        push(@md, sprintf("[%05b](images/tree-%05b.gif)", $nid, $nid));
    } else {
        printf( "%05b\n", $nid);
    }
}
print join(', ', @md) if ($opt_com);
