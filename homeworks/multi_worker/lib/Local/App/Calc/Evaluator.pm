package Local::App::Calc::Evaluator;

use 5.010;
use strict;
use warnings;
use Exporter 'import';
our @EXPORT_OK = qw(evaluate);
BEGIN{
	if ($] < 5.018) {
		package experimental;
		use warnings::register;
	}
}
no warnings 'experimental';

sub evaluate {
	my @rpn = @{ shift() };
    my @valstack;
    my ($op1, $op2, $res);

    for my $token (@rpn) {
        given ($token) {
            when (m/[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/) {
                push @valstack, $token;
            }
            when (m/^U[\-+]$/) {
                my ($unary) = (m/^U([\-+])$/);

                $op1 = pop @valstack;

                $res = eval $unary . '(' . $op1 . ')';

                push @valstack, $res;
            }
            default {
                if ($token eq '^') { $token = '**' };

                $op2 = pop @valstack;
                $op1 = pop @valstack;

                $res = eval $op1 . $token . $op2;

                push @valstack, $res;
            }
        }
    }

    die('Extra values in stack') if @valstack > 1;
	return $valstack[0];
}

1;
