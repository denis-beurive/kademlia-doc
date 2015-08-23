
# perl kad-tree.pl --bits=5 --node=01010 | dot -Tgif -Ograph
# perl kad-tree.pl --bits=5 --node=01010 --palette=buckets.pal | dot -Tgif -Ograph
# perl kad-tree.pl --bits=5  --palette=buckets.pal | dot -Tgif -Ograph


use strict;
use bigint;
use kad;
use Getopt::Long;



my $palettePath    = undef;
my %palette        = ();
my $cliPalettePath = undef;
my $cliNode        = undef;
my $cliBits        = undef;
my %options        = ( 'palette=s' => \$cliPalettePath, 'node=s' => \$cliNode, 'bits=i' => \$cliBits );

unless (GetOptions(%options)) {
  die("Error while parsing the command line.");
}

unless (defined$cliBits) {
  die("Missing option --bits")
}

# Load the palette.

if (defined($cliPalettePath)) {
  %palette = loadBucketPalette($cliPalettePath);
} else {
  $palette{'0-1'} = getRandomColor();
  for (my $i=0; $i<$cliBits; $i++) {
    my $key = (2**$i) . '-' . (2**($i+1));
    $palette{$key} = getRandomColor();
  }
  writeBucketPalette('newBucketPalette', \%palette);
}

if ($cliBits > int(keys %palette)) {
  die("Invalid palette: not enough color defined.");
}

# Create the graph.

if (defined($cliNode)) {
  createGraph($cliBits, $cliNode, \%palette);
  exit(0);
}

for (my $node=0; $node<(2**$cliBits)-1; $node++) {
  createGraph($cliBits, sprintf( "%05b", $node), \%palette);
}
