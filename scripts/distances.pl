#!/usr/bin/perl
#
# perl distances.pl  > ../doc/latex/distances.tex

use strict;
use warnings FATAL => 'all';

my $latexBegin = <<END;
\\documentclass{basic}
\\usepackage{mathtools}
\\newcommand*\\xor{\\oplus}
\\setlength{\\parindent}{0pt}
\\begin{document}
END

my $latexEnd = <<END;
\\end{document}
END

my @lines = ($latexBegin);
for (my $i=0; $i<32; $i++) {
    my $delta = sprintf( "%05b", $i);
    push(@lines, sprintf('\\(d(x_4 x_3 x_2 x_1 x_0, %s %s %s %s %s) = %d\\)\\\\',
        substr($delta, 0, 1) eq '1' ? '\bar{x_4}' : 'x_4',
        substr($delta, 1, 1) eq '1' ? '\bar{x_3}' : 'x_3',
        substr($delta, 2, 1) eq '1' ? '\bar{x_2}' : 'x_2',
        substr($delta, 3, 1) eq '1' ? '\bar{x_1}' : 'x_1',
        substr($delta, 4, 1) eq '1' ? '\bar{x_0}' : 'x_0',
        $i
    ));
}
push(@lines, $latexEnd);

printf("%s", join("\n", @lines));


