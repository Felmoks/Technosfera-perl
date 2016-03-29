package Local::App::Calc::Lexer;

use 5.010;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(tokenize);
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

my $ops    = qr/[+\-*\/^]/;
my $parens = qr/[()]/;
my $number = qr/[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/;
my $sep    = qr/\s|$number|$ops|$parens/;

sub tokenize($) {
	chomp(my $expr = shift);
	my @res;

	@res = split "($sep)", $expr;
	@res = grep { defined && !m/^$|\s+/ } @res;
    
    my $expect = 'operand';
    my $parens_count = 0;

    for my $i (0..$#res) {
        given ($res[$i]) {
            when ($number) {
                die("Expecting operator: " . join(" ", @res)) if $expect eq 'operator';

                $res[$i] = 0+$res[$i];
                $expect = 'operator';
            }
            when ('(') {
                die('Expecting operator') if $expect eq 'operator';

                $parens_count += 1;
                $expect = 'operand';
            }
            when (')') {
                die('Expecting operand') if $expect eq 'operand';

                $parens_count -= 1;
                die('Unmatched closing paren') if $parens_count < 0;
                $expect = 'operator';
            }
            when (['+', '-']) {
                if ($expect eq 'operator') {
                    $expect = 'operand';
                }
                elsif ($expect eq 'operand') {
                    $res[$i] = 'U' . $res[$i];
                    $expect = 'operand';
                }
            }
            when (['*', '/', '^']) {
                die('Expecting operand') if $expect eq 'operand';

                $expect = 'operand';
            }
            default {
                die('Unknown token ' . join(" ", @res));
            }
        }
    }

    die('Expecting operand') if $expect eq 'operand';
    die('Unmatched opening paren') if $parens_count > 0;

	return \@res;
}

1;
