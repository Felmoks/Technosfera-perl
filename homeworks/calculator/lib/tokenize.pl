=head1 DESCRIPTION

Эта функция должна принять на вход арифметическое выражение,
а на выходе дать ссылку на массив, состоящий из отдельных токенов.
Токен - это отдельная логическая часть выражения: число, скобка или арифметическая операция
В случае ошибки в выражении функция должна вызывать die с сообщением об ошибке

Знаки '-' и '+' в первой позиции, или после другой арифметической операции стоит воспринимать
как унарные и можно записывать как "U-" и "U+"

Стоит заметить, что после унарного оператора нельзя использовать бинарные операторы
Например последовательность 1 + - / 2 невалидна. Бинарный оператор / идёт после использования унарного "-"

=cut

use 5.010;
use strict;
use warnings;
use diagnostics;
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
                die('Expecting operator') if $expect eq 'operator';
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
        }
    }

    die('Expecting operand') if $expect eq 'operand';
    die('Unmatched opening paren') if $parens_count > 0;

	return \@res;
}

1;
