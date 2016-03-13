package Local::TableBuilder;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(build_matrix);

my $nrows;
my $ncols;
my @widths;

my %shells = (
    header => {
        left        => '/',
        right       => "\\\n",
        separator   => '-',
    },

    footer => {
        left        => '\\',
        right       => "/\n",
        separator   => '-',
    },

    row_separator => {
        left        => '|',
        right       => "|\n",
        separator   => '+',
    },

    data_row => {
        left        => '|',
        right       => "|\n",
        separator   => '|',
        pad         => \&pad_row,
    },

    cell => {
        left        => ' ',
        right       => ' ',
        placeholder => ' ',
        pad         => \&pad_cell_center,
    },

    border_cell => {
        left        => '-',
        right       => '-',
        placeholder => '-',
        pad         => \&pad_cell_center,
    },

);

sub build_matrix {
    my ($matrix) = @_;
    $nrows = @{ $matrix };
    $ncols = @{ $matrix->[0] };

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    my $super_matrix_data = [];

    for my $i (0..$nrows-1) {
        my @row 
            = map { +{ shell => $shells{cell}, data => $matrix->[$i][$_], len => $widths[$_] } } 0..$ncols-1;

        push @$super_matrix_data, { shell => $shells{data_row}, data => \@row, len => 1 }; 
    }

    my $super_matrix_shell = {
        left        => {
            shell => $shells{header},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
        right       => {
            shell => $shells{footer},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
        separator   => {
            shell => $shells{row_separator},
            data  => [ map { +{shell => $shells{border_cell}, data=>"", len => $_ } } @widths ],
        },
    };

    my $super_matrix = {
        shell => $super_matrix_shell,
        data  => $super_matrix_data,
    };

    return $super_matrix;
}

1;
