use strict;
use warnings;

use 5.010;

sub reduce(&@) {
    my ($f, @list) = @_;

    my $accum = shift @list;

    while (my $elem  = shift @list) {
        $accum = $f->($accum, $elem);
    }

    return $accum;
}

# returns 10
say reduce {
    my ($sum, $i) = @_;
    $sum * $i;
} 1, 2, 3, 4;
