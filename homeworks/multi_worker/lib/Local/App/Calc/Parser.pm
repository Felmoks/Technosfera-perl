package Local::App::Calc::Parser;

use 5.010;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(rpn);
use Local::App::Calc::Lexer qw(tokenize);
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

our %ops = (
    'U+' => {
        assoc   => 'right',
        order   => 3,
    }, 
    'U-' => {
        assoc   => 'right',
        order   => 3,
    }, 
    '^'  => {
        assoc   => 'right',
        order   => 3,
    }, 
    '*'  => {
        assoc   => 'left',
        order   => 2,
    }, 
    '/'  => {
        assoc   => 'left',
        order   => 2,
    }, 
    '+'  => {
        assoc   => 'left',
        order   => 1,
    }, 
    '-'  => {
        assoc   => 'left',
        order   => 1,
    }, 
);

sub should_be_popped {
    my ($top_op, $new_op) = @_;

    return
        !defined($top_op)               ? 0                                            :    
        $top_op eq '('                  ? 0                                            :    
        $ops{$new_op}{assoc} eq 'left'  ? $ops{$new_op}{order} <= $ops{$top_op}{order} :
        $ops{$new_op}{assoc} eq 'right' ? $ops{$new_op}{order} <  $ops{$top_op}{order} :
                                          undef;
}

sub rpn {
	my $expr = shift;
	my $source = tokenize($expr);
	my @tokens = @$source;
	my @rpn;
	my @opstack;

    for my $token (@tokens) {
		given ($token) {
			when (/[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/) {
                push @rpn, $token;
			}
            when ([keys %ops]) {
                while (@opstack > 0 && should_be_popped($opstack[-1], $token)) {
                    push @rpn, pop @opstack;
                }
                push @opstack, $token;
            }
            when ('(') {
                push @opstack, $token;
            }
            when (')') {
                while (!($opstack[-1] eq '(')) {
                    push @rpn, pop @opstack;
                }
                pop @opstack;
            }
            default {
                die('Unknown token' . join(' ', @tokens));
            }
		}
	}

    push @rpn, reverse @opstack;

	return \@rpn;
}

1;
