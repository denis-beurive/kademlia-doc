# This script creates 2 representations:
# - the first representation shows the contents of all lower subtrees. Each subtree is given a unique color.
# - the second representation is similar to the first one, except that each node is given a unique colour.
#
# Usage:
# perl kad-grid.pl --palette=config/buckets.pal --type=buckets | dot -Tgif -Ograph
# perl kad-grid.pl --type=peers | dot -Tgif -Ograph

use strict;
use warnings FATAL => 'all';
use Data::Dumper;
use Getopt::Long;

BEGIN {
  use File::Spec ();
  sub __DIR__ () {
    my $level = shift || 0;
    my $file = (caller $level)[1];
    File::Spec->rel2abs(join '', (File::Spec->splitpath($file))[0, 1])
  }
  sub DIRECTORY_SEPERATOR {
    return $^O eq "MSWin32" ? '\\' : '/';
  }

  use lib sprintf('%s%smodules', __DIR__, DIRECTORY_SEPERATOR);
}
use color;

my $NODE_LENGTH = 5;
my @nodeIds     = ();
my @dots        = ();
my @edges       = ();

# Define some strings that will be used to create the DOT's specification.

my $dotHeader = <<END;
digraph G {
    node [style=filled];
    rankdir="LR";
END
my $spaceDot = <<END;
    subgraph  cluster_NNNN {
              style=filled;
              color=white;
              node [style=filled];
              rankdir="TD";
END

# Analyse CLI.

my $palettePath = undef;
my $gridType = undef;
my %palette = ();
my %options = ( 'palette=s' => \$palettePath, 'type=s' => \$gridType );

unless (GetOptions(%options)) {
  die("Error while parsing the command line.");
}

$gridType = defined($gridType) ? $gridType : 'buckets';

if (('buckets' ne $gridType) && ('peers' ne $gridType)) {
  die("Invalid grip type <$gridType>.");
}

# Load the palette.

if (defined($palettePath)) {
  if ('buckets' eq $gridType) {
    %palette = loadBucketPalette($palettePath);
  } else {
    %palette = loadPeerPalette($palettePath);
  }
} else {  # Create a palette.
  if ('buckets' eq $gridType) {
    $palette{'0-1'} = getRandomColor();
    for (my $i=0; $i<$NODE_LENGTH; $i++) {
      my $key = (2**$i) . '-' . (2**($i+1));
      $palette{$key} = getRandomColor();
    }
    writeBucketPalette('newBucketPalette', \%palette);
  } else {
    for (my $i=0; $i<2**$NODE_LENGTH; $i++) {
        my $bin = sprintf( "%05b", $i);
        $palette{$bin} = getRandomColor();
    }
    writePeerPalette('newPeerPalette', \%palette);
  }
}

if ($NODE_LENGTH > int(keys %palette)) {
  die("Invalid palette: not enough color defined.");
}

# For each ID's value:
# Calculate the binary representation.
# Calculate the decimal representation.
# The "distance" between this ID's value and the others ID's values.

for (my $id=0; $id<(2**$NODE_LENGTH); $id++) {
  my $n         = {};
  my @distances = ();

  $n->{'dec'} = $id;
  $n->{'bin'} = sprintf( "%05b", $id);

  for (my $nid=0; $nid<(2**$NODE_LENGTH); $nid++) {
    my $bin      = sprintf( "%05b", $nid);
    my $distance = {'dec'   => $nid,
                    'bin'   => $bin,
                    'delta' => oct('0b' . $n->{'bin'}) ^ oct('0b' . $bin)};
    push(@distances, $distance);
  }

  @distances = sort { return $b->{'delta'} <=> $a->{'delta'} } @distances;
  $n->{'data'} = \@distances;
  push(@nodeIds, $n);
}

# Start of the DOT document.

push(@dots, $dotHeader);

# Build sub graphs that contain nodes.

my $idx = 0;

foreach my $nodeId (@nodeIds) {
  my $h   = $spaceDot;
  my $dec = sprintf("%02d", $nodeId->{'dec'});
  my $bin = $nodeId->{'bin'};

  $h =~ s/NNNN/${dec}/mg;
  push(@dots, $h);

  push(@edges, nodeName($idx));
  foreach my $node (@{$nodeId->{'data'}}) {
    my $distance = $node->{'delta'};
    my $label = sprintf("%02d", $node->{'dec'}) . '=' . $node->{'bin'} . ( 0 == $distance ? '' : (' (' . sprintf("%02d", $distance) . ')') );
    my $pal = undef;
    my $bg = undef;
    my $fg = undef;

    if ('buckets' eq $gridType) {
      $pal = getBucketColor(\%palette, $distance);
    } else {
      $pal = getPeerColor(\%palette, $node->{'bin'});
    }

    $bg = $pal->{'bg'};
    $fg = $pal->{'fg'};
    push(@dots, '       "' . nodeName($idx) . "\" [label=\"$label\", shape=\"box\", fillcolor=\"$bg\", fontcolor=\"$fg\"]" . ';');
    $idx++;
  }

  push(@dots, '    }', '');
}

# Create the edges.

for (my $i=0; $i<int(@edges)-1; $i++) {
  my $from = $edges[$i];
  my $to   = $edges[$i+1];
  push(@dots, "   \"$from\" -> \"$to\" [style=\"invis\"];");
}

# End of the DOT document.s

push(@dots, '}');

print join("\n", @dots);

exit(0);

sub nodeName {
  my ($inIdx) = @_;
  return 'node' . $inIdx;
}
