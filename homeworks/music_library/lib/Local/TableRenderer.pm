package Local::TableRenderer;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(render);

my $nrows;
my $ncols;
my @widths;

sub header {
    my ($w) = @_;

    print '/' , '-'x($w-2) , "\\\n" ;
}

sub h_separator {
    my ($w) = @_;

    print '/' , '-'x($w-2) , "\\\n" ;
}

sub footer {
    my ($w) = @_;

    print '\\' , '-'x($w-2) , "/\n" ;
}

sub pad {
    my ($str, $w) = @_;
    return ' 'x($w-length($str)) . $str;
}

sub render {
    my ($matrix) = @_;
    $nrows = @{ $matrix };
    $ncols = @{ $matrix->[0] };

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    for my $row (@$matrix) {
        print '|'; 
        map { print ' ' . pad($row->[$_], $widths[$_]) . ' |' } 0..$ncols-1;
        print "\n";
    }

    print join ' ', @widths , "\n";
   
    print $nrows, ' ', $ncols, "\n";
}

1;
