=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, содержащий обратную польскую нотацию
Один элемент массива - это число или арифметическая операция
В случае ошибки функция должна вызывать die с сообщением об ошибке

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
use Data::Dumper;
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';
use FindBin;
require "$FindBin::Bin/../lib/tokenize.pl";

our %ops = (
    'U+' => {
        assoc   => 'right',
        order   => 4,
    }, 
    'U-' => {
        assoc   => 'right',
        order   => 4,
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
                while (should_be_popped($opstack[-1], $token)) {
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
		}
	}

    push @rpn, reverse @opstack;

	return \@rpn;
}

1;
