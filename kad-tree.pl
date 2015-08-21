use strict;
use bigint;

# -------------------------------------------------------------------
# Configuration
# -------------------------------------------------------------------

my $n     = 5;        # Number of bits used to represent a node's ID.
my $node  = '01010';  # Current node.

# -------------------------------------------------------------------
# Variables.
# -------------------------------------------------------------------

my %nodes        = ();    # Tree's nodes.
my @dot          = ();    # Dot's (GraphViz) instructions.
my $r            = $n-1;
my @peers        = ();
my %buckets      = ();
my @legend       = ();
my @legendTitles = ();

# -------------------------------------------------------------------
# Initialize buckets.
# -------------------------------------------------------------------

for (my $i=0; $i<$n; $i++) {
  my $min   = 2 ** $i;
  my $max   = 2 ** ($i + 1);
  my @color = randomColors();

  $buckets{$i} = [$min, $max, $color[0], $color[1]];
}

# -------------------------------------------------------------------
# Create the tree's nodes.
# -------------------------------------------------------------------

for (my $level=1; $level<=$n; $level++) {
  my %levelNodes = ();
  my $left       = rigthPadding($r--);
  my $leftChild  = rigthPadding($r);

  for (my $i=0; $i<2**${level}; $i++) {
    my $id     = sprintf("%0${level}b", $i);
    my $childs = undef;

    if ($level < $n) {
       my $n0 = "${id}0";
       my $n1 = "${id}1";

       $childs = ["\"${n0}${leftChild}\" [label = \"0\"]", "\"${n1}$leftChild\" [label = \"1\"]"];

       # Keep the peer's nodes IDs.
       if (length($n0) == $n) {
          push(@peers, $n0, $n1);
       }
    }

    $levelNodes{"${id}${left}"} = $childs;
  }

  $nodes{$level} = \%levelNodes;
}

# -------------------------------------------------------------------
# Create edges.
# -------------------------------------------------------------------

for (my $level=1; $level<=$n; $level++) {
  foreach my $id (keys %{$nodes{$level}}) {
    my $childs = $nodes{$level}->{"$id"};

    unless(defined($childs)) { next; }
    foreach my $child (@{$childs}) {
      push(@dot, "\"${id}\" -> $child;");
    }
  }
}

# -------------------------------------------------------------------
# Process peers' IDs.
# This step will set the color, according to the bucket.
# -------------------------------------------------------------------

push(@dot, "$node [fillcolor=\"#00ff00\", shape=\"box\"]");

for my $p (@peers) {
  my $b            = undef;
  my $bgcolor      = undef;
  my $fgcolor      = undef;
  my $distance     = undef;
  my $nodeP        = undef;
  my $nodeDistance = undef;

  if ("$p" eq "$node") {
    next;
  }

  $b        = inBucket($p, $node, \%buckets, $n);
  $bgcolor  = $b->{'bg'};
  $fgcolor  = $b->{'fg'};
  $distance = oct("0b$p") ^ oct("0b$node");

  $nodeP        = "\"$p\"";
  $nodeDistance = "\"d=$distance\"";

  push(@dot, "$nodeP [shape=\"box\", fillcolor=\"$bgcolor\", fontcolor=\"$fgcolor\"];");
  push(@dot, "$nodeDistance [shape=\"box\" style=\"rounded\"];");
  push(@dot, "$nodeP -> $nodeDistance [style=invis];");
}

for (my $level=1; $level<$n; $level++) {
  my $ns = $nodes{$level};

  foreach my $id (keys %{$ns}) {
    my $min  = $id;
    my $max  = $id;
    my $bMin = undef;
    my $bMax = undef;

    $min  =~ s/\./0/g;
    $max  =~ s/\./1/g;
    $bMin =  inBucket($min, $node, \%buckets, $n);
    $bMax =  inBucket($max, $node, \%buckets, $n);

    if ($bMin->{'bucket'} == $bMax->{'bucket'}) {
       my $bg = $bMin->{'bg'};
       my $fg = $bMin->{'fg'};

       if ($bMin->{'bucket'} != 0) {
         push(@dot, "\"$id\" [fillcolor=\"$bg\", fontcolor=\"$fg\"];");
       }
    }
  }
}

# -------------------------------------------------------------------
# Dump GravViph's representation.
# -------------------------------------------------------------------

for (my $i=0; $i<$n; $i++) {
  my $min = $buckets{$i}->[0];
  my $max = $buckets{$i}->[1];
  my $bg  = $buckets{$i}->[2];
  my $fg  = $buckets{$i}->[3];
  my $t   = "Bucket $i: $min <= distance < $max";

  push(@legend, "\"$t\" [fillcolor=\"$bg\", fontcolor=\"$fg\", shape=\"box\"];");
  push(@legendTitles, "\"$t\"");
}

for (my $i=0; $i<int(@legendTitles)-1; $i++) {
  push(@legend, $legendTitles[$i] . ' -> ' . $legendTitles[$i+1] . " [shape=point style=invis];");
}


my $dotHeader = <<END;
digraph unix {
 	node [style=filled];
END

@legend = map { "\t\t" . $_ } @legend;

my $legendDot = <<END;
	subgraph cluster_1 {
		label="legend";
		style=filled;
		color=lightgrey;
		node [style=filled];
END

my $treeDot = <<END;
        subgraph cluster_0 {
                style=filled;
                color=white;
                node [style=filled];
END

@dot = map { "\t\t" . $_ } @dot;

print "$dotHeader\n";

print "$treeDot\n";
print "\t\t\"-\" -> \"0...\";\n";
print "\t\t\"-\" -> \"1...\";\n";
print join("\n", @dot) . "\n";
print "\t}\n";

print "$legendDot\n";
print join("\n", @legend) . "\n";
print "\t}\n";

print "}\n\n\n";
print "/* perl kad-tree.pl | dot -Tgif -Ograph */\n\n";






sub rigthPadding {
  my ($n, $padding) = @_;
  my $s   = '';

  unless(defined($padding)) { $padding = '.'; }

  for (my $i=0; $i<$n; $i++) { $s .= '.'; }
  return $s;
}

sub distance {
  my ($id1, $id2, $n) = @_;
  my $res = 0;
  my $pow = $n - 1;

  for (my $i=0; $i<$n; $i++) {
    my $d1 = substr($id1, $i, 1);
    my $d2 = substr($id2, $i, 1);
    my $dg = "$d1" eq "$d2" ? 0 : 1;

    if ($dg == 1) {
       $res += 2 ** $pow;
    }

    $pow -= 1;
  }

  return $res;
}


sub randomColors {
  my ($r, $g, $b) = map { int rand 256 } 1 .. 3;
  my $lum = ($r * 0.3) + ($g * 0.59) + ($b * 0.11);
  my $bg = sprintf("#%02x%02x%02x", $r, $g, $b);
  my $fg = $lum < 128 ? "white" : "black";

  return ($bg, $fg);
}

sub inBucket {
  my ($inNodeId, $inRefNodeId, $inBuckets, $inNodeIdLength) = @_;
  my $d = distance($inNodeId, $inRefNodeId, $inNodeIdLength);

  for (my $i=0; $i<$inNodeIdLength; $i++) {
    my $min = $inBuckets->{$i}->[0];
    my $max = $inBuckets->{$i}->[1];

    if (($d >= $min) && ($d < $max)) {
      return {'bucket' => $i, 'bg' => $inBuckets->{$i}->[2], 'fg' => $inBuckets->{$i}->[3]};
    }
  }

  return undef;
}
