package Local::BlockBuilder;

use strict;
use warnings;
use List::Util qw(max);
use Data::Dumper;
use Exporter 'import';

our @EXPORT_OK = qw(build_block);

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

sub build_block {
    my ($matrix) = @_;
    $nrows = @{ $matrix };
    $ncols = @{ $matrix->[0] };

    for my $i (0..$ncols-1) {
        $widths[$i] = max( map { length $_->[$i] } @$matrix );
    }

    my $block_data = [];

    for my $i (0..$nrows-1) {
        my @row 
            = map { +{ shell => $shells{cell}, data => $matrix->[$i][$_], len => $widths[$_] } } 0..$ncols-1;

        push @$block_data, { shell => $shells{data_row}, data => \@row, len => 1 }; 
    }

    my $block_shell = {
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

    my $block = {
        shell => $block_shell,
        data  => $block_data,
    };

    return $block;
}

1;
