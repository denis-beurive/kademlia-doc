package color;
use strict;
use warnings;
use Data::Dumper;


use vars qw (@ISA @EXPORT);
@ISA = qw(Exporter);
@EXPORT = qw(&loadBucketPalette &loadPeerPalette &writeBucketPalette &getBucketColor &getPeerColor &writePeerPalette &getRandomColor);


# Load the palette for buckets.
# The file contains CVS: from (included) ; to (excluded) ; color

sub loadBucketPalette {
  my ($inFilePath) = @_;
  my $fd;
  my %palette = ();

  unless (open($fd, '<', $inFilePath)) {
    die("Can not open file <$inFilePath>: $!");
  }

  while (<$fd>) {
    my @tokens = ();

    if (($_ =~ m/^\s*#/) || ($_ =~ m/^\s*$/)) {
      next;
    }

    @tokens = split(/;/, $_);
    if (4 ne int(@tokens)) {
      die("Invalid scheme definition. Line <$_> is not valid.");
    }

    $palette{trim($tokens[0]) . '-' . trim($tokens[1])} = { 'bg' => trim($tokens[2]), 'fg' => trim($tokens[3]) };
  }

  close($fd);
  return %palette;
}

# Load the palette for peers.

sub loadPeerPalette {
  my ($inFilePath) = @_;
  my $fd;
  my %palette = ();

  unless (open($fd, '<', $inFilePath)) {
    die("Can not open file <$inFilePath>: $!");
  }

  while (<$fd>) {
    my @tokens = ();

    if (($_ =~ m/^\s*#/) || ($_ =~ m/^\s*$/)) {
      next;
    }

    @tokens = split(/;/, $_);
    if (3 ne int(@tokens)) {
      die("Invalid scheme definition. Line <$_> is not valid.");
    }

    $palette{trim($tokens[0])} = { 'bg' => trim($tokens[1]), 'fg' => trim($tokens[2]) };
  }

  close($fd);
  return %palette;
}

# Dump a palette into a file for buckets.

sub writeBucketPalette {
  my ($inFilePath, $inPalette) = @_;
  my $fd = undef;

  unless (open($fd, '>', $inFilePath)) {
    die("Can not open file <$inFilePath>: $!");
  }

  foreach my $key (keys %{$inPalette}) {
    my ($min, $max) = split('-', $key);
    print $fd "$min;$max;" . $inPalette->{$key}->{'bg'} . ';'. $inPalette->{$key}->{'fg'} . "\n";
  }

  close($fd);
}

# Dump a palette into a file for peers

sub writePeerPalette {
  my ($inFilePath, $inPalette) = @_;
  my $fd = undef;

  unless (open($fd, '>', $inFilePath)) {
    die("Can not open file <$inFilePath>: $!");
  }

  foreach my $key (keys %{$inPalette}) {
    print $fd "$key;" . $inPalette->{$key}->{'bg'} . ';'. $inPalette->{$key}->{'fg'} . "\n";
  }

  close($fd);
}

# Get a color for a bucket based on the distance from the node's ID.

sub getBucketColor {
  my ($inPalette, $inDistance) = @_;
  my $count = int(keys %{$inPalette}) - 1;

  if ($inDistance > (2**$count)-1) {
    die("Invalid distance: the palette does not contain enough color to render this distance.");
  }

  if (0 == $inDistance) {
    return $inPalette->{'0-1'};
  }

  for (my $i=0; $i<$count; $i++) {
    my $min = 2**$i;
    my $max = 2**($i+1);
    if (($inDistance >= $min) && ($inDistance < $max)) {
      return $inPalette->{$min . '-' . $max};
    }
  }
  die("Color not found (distance = $inDistance). The bucket's palette is not valid!")
}

sub getPeerColor {
  my ($inPalette, $inId) = @_;

  unless (exists($inPalette->{$inId})) {
    die("Can not found a color for the peer which ID is $inId.");
  }

  return $inPalette->{$inId};
}

# Get a color.

sub getRandomColor {
  my ($r, $g, $b) = map { int rand 256 } 1 .. 3;
  my $lum = ($r * 0.3) + ($g * 0.59) + ($b * 0.11);
  my $bg = sprintf("#%02x%02x%02x", $r, $g, $b);
  my $fg = $lum < 128 ? "white" : "black";

  return { 'bg' => $bg, 'fg' => $fg };
}


sub trim {
  my ($inString) = @_;
  $inString =~ s/^\s+|\s+$//g;
  return $inString
};

1;
